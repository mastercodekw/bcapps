#!/bin/perl

# TODO: I might be able to use this via xinetd or websocket proxy, see
# if I want do to that though

# TODO: https (or proxy)

# TODO: cleanup, this is ugly

# NOTE: my tilesizes are 512 x 256 (other option was 256 x 128)

# The main map server

require "/usr/local/lib/bclib.pl";

# TODO: pathify?
require "$bclib{githome}/MAPS/bc-maps.pl";

use IO::Socket::INET;
use IO::Socket::SSL;


# ignore children completion
$SIG{CHLD} = 'IGNORE';

# my($cmd, $map, $z, $x, $y) = @ARGV;
# print mapData(str2hashref("cmd=$cmd&map=$map&z=$z&x=$x&y=$y"));
# print mapData(str2hashref("cmd=data&map=timezones&z=1&x=0&y=0"));
# die "TESTING";

my $server = getServer();

while (my $conn = $server->accept()) {

  # fork (parent ignores, child handles)
  if (fork()) {next;}

  # TODO: set ALRM to timeout to avoid hangs

  my(@data);
  my($req);

  while ($in = <$conn>) {
    debug("GOT: $in");
    push(@data, $in);

    # TODO: handle POST/etc requests nicely

    # the GET line (allows for non-HTTP/1.1 requests if they have no spaces
    # note the / is not considered part of the request

    if ($in=~m%^GET\s*/(\S+)%) {$request = $1; next;}

    # the blank line means end of headers
    if ($in=~/^\s*$/) {last;}
  }

  # process request

  debug("PROCESSING: $request");
  my($ret) = JSON::to_json(mapData(str2hashref($request)));

  # TODO: this should print as header but isnt for some reason
#  print $conn "Content-type: text/plain\n\n";
  
  print $conn $ret;

  # as the child, I must exit
  exit();

}

=item mapData(%hash)

Given hash below, return the associated data in the data field of a hash:

name: short name of the path

z, x, y: the z/x/y tile desired, on a equirectanagular projection

layer: the layer to query (vector maps)

TODO: allow single pixel requests

=cut

sub mapData {

  my($hr) = @_;

  # determine lat/lng extents and tile width/height in degrees

  # TODO: adding this to $hr MIGHT be a bad idea, but could be useful

  $hr->{width} = 360/2**$hr->{z};
  $hr->{wlng} = $hr->{x}*$hr->{width} - 180;
  $hr->{elng} = $hr->{wlng} + $hr->{width};
  $hr->{nlat} = 90-$hr->{y}*$hr->{width}/2;
  $hr->{slat} = $hr->{nlat} - $hr->{width}/2;

  # info on this map + tmpfile to store data

  my($mi) = $maps{$hr->{map}};
  my($tmp) = my_tmpfile2();
  my($cmd);

  if ($mi->{type} eq "raster") {

    # NOTE TO SELF: 20190530/runme.sh contains test showing this is
    # fastest or at least fast enough

    # NOTE: $hr->{nlat} MUST come before $hr->{slat} even though it's larger
    $cmd = "gdal_translate $mi->{filename} -outsize 512 256 -projwin $hr->{wlng} $hr->{nlat} $hr->{elng} $hr->{slat} -ot $mi->{size} -of Ehdr $tmp.bin";

  } elsif ($mi->{type} eq "vector") {
    $cmd = "gdal_rasterize $mi->{filename} -a $mi->{attribute} -ts 512 256 -te $hr->{wlng} $hr->{slat} $hr->{elng} $hr->{nlat} -ot $mi->{size} -of Ehdr $tmp.bin";
  } else {
    $hr->{error} = "Map $hr->{map} can't determine type vector or raster";
    return $hr;
  }

  # base64 encoding hopefully doesn't make space usage much worse
  $hr->{encoding} = "base64";
  
  # TODO: caching doesn't help here since tmpfile changes each time

  my($out, $err, $res) = cache_command2($cmd);
  debug("CMD: $cmd, ERR: $err, RES: $res");

  # JSON is actually WORSE with this than w/ base64
  # $hr->{data} = read_file("$tmp.bin");
  $hr->{data} = encode_base64(read_file("$tmp.bin"));
  return $hr;
}

# specific to this prog

sub getServer {

    # directory where encryption keys are stored
    my($dir) = "/etc/letsencrypt/live/ws.terramapadventure.com";
    my($server);

    # secure if possible, insecure otherwise

    if (-d $dir) {
	$server = IO::Socket::SSL->new(
	    Listen => 5, LocalPort => 22779, Proto => 'tcp', 
	    SSL_cert_file => "$dir/fullchain.pem", 
	    SSL_key_file => "$dir/privkey.pem"
	    );
    } else {
	$server = IO::Socket::INET->new(
	    Listen => 5, LocalPort => 22779, Proto => 'tcp'
	    );
    }

    debug("SERVER: $server, ERR: $! (if any)");
    return $server;
}



