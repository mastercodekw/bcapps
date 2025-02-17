#!/bin/perl

# Script where I test code snippets; anything that works eventually
# makes it into a library or real program

# TODO: cleanup this file -- lots of stuff has been (or should be)
# moved to production

# chunks are normally separated with 'die "TESTING";' (TODO: use
# subroutines instead?)

# TODO: create a version of cache_command that knows how often a given
# URL is updated, and only dls as needed; eg, if URL is updated every
# 6h at 0000,0600,1200,1800 GMT, use that info to dl as needed instead
# of "is my cache x hours old"

require "/usr/local/lib/bclib.pl";
# below lets me override functions when testing
# require "/home/barrycarter/BCGIT/bclib-playground.pl";
# require "bc-astro-lib.pl";
require "bc-weather-lib.pl";
# starting to store all my private pws, etc, in a single file
require "/home/barrycarter/bc-private.pl";
use XML::Simple;
use Data::Dumper 'Dumper';
use Time::JulianDay;
use XML::Bare;
$Data::Dumper::Indent = 0;
require "bc-twitter.pl";
use GD;
use Algorithm::GoldenSection;
use Inline::Python;
use FFI::Raw;
use v5.10;
use Google::ProtocolBuffers;

open(A, "/home/barrycarter/20181011/planet-latest.osm.pbf");

my($line) = <A>;

debug("LINE: $line");

# debug("RES: $res");

die "TESTING";

create_el_tz_file();

die "TESTING";

# one off to spit out third wednesday of each month for personal reasons

for $i (2015..2029) {
  for $j ("01".."12") {
    print weekdayAfterDate("$i${j}01",3,2),"\n";
  }
}

sub weekdayAfterDate {
  my($date,$day,$n) = @_;
  my($time) = str2time("$date 12:00:00 UTC");
  # the -3 makes Monday = 1
  my($wday) = ($time/86400-3)%7;
  # add appropriate amount for first weekday after date
  $time += ($day-$wday)%7*86400 + $n*86400*7;
  return strftime("%Y%m%d", gmtime($time));
}

die "TESTING";

system("ls -l");
system("ls","-l");


die "TESTING";

my $str = << "MARK";
hello,"world",there,"this has commas,yes"
MARK
;

$str=~s/\"(.*?)\"/"\001$1\001"/g;
@a = csv($str);
map(s/\001/"/g, @a);
debug("A",@a);


die "TESTING";

# create a 10 second random snippet from an MP3 file

chdir("/home/barrycarter/MP3/");
@mp3s = randomize([glob("*.mp3")]);

for $i (@mp3s) {
  debug("I: $i");
  my($length) = `exiftool '$i' | fgrep Duration`;
  $length=~s/Duration.*?:\s*//;
  $length=~s/\s*\(approx\)\s*//;
  unless ($length=~/^(\d+):(\d+)$/) {warn "BAD LENGTH: $length"; next;}
  $length = $1*60+$2;

  my($rand) = floor(rand()*($length-10));
  # the 22nd to 38th second
  system("ffmpeg -ss 22 -t 16 -i '$i' 'GAME/$i'");
}

die "TESTING";

# @mat = matrixmult([[1,0,0], [0,1,0], [0,0,1]], [[1],[2],[3]]);
# debug("MAT",unfold(@mat));

# ($x, $y, $z) = (3.99167512e+08, -5.71599972e+08, -2.48953490e+08);

# jupiter pole in ICRS terms, in radians
$ra = 268.057*$DEGRAD;
$dec = 64.496*$DEGRAD;

debug(sph2xyz($ra, $dec, 1));

# -0.0145987218963993
# -0.430326550289791
# 0.902555226805917

die "TESTING";

# debug("PI: $PI");

@matx = rotrad(-$ra, "z");
debug("MATX", unfold(@matx));
@res1 = matrixmult(\@matx, [[$x], [$y], [$z]]);
debug("APPLY", unfold(@res1));
@maty = rotrad(-$dec, "y");
debug("MATY", unfold(@maty));
@matfinal = matrixmult(\@maty, \@matx);
debug("MATFINAL",unfold(@matfinal));
debug("XYZ: $x $y $z");
@f = matrixmult(\@matfinal, [[$x],[$y],[$z]]);
debug(unfold(@f));

# debug(unfold(@matfinal));

die "TESTING";

debug(unfold(matrixmult(\@mat, [[$x,$y,$z]])));

# debug("ATAN", atan2($y,$x)*$RADDEG, atan2($z,sqrt($x*$x+$y*$y))*$RADDEG);



die "TESTING";

chdir("/usr/local/etc/metawiki");
my(@res) = diffuwr("pbs3", "pbs3-test");

debug("DIFFER", @{$res[0]});
debug("IN pbs3 only:", @{$res[1]});
debug("IN pbs3-test only:", @{$res[2]});
debug("SAME", @{$res[3]});

=item diffuwr($dir1,$dir2)

Given two directories, runs something like "diff -uwr" on them, and
returns an array of arrays, with indexes as follows (semi-inspired by
comms output):

0: files that are in both $dir1 and $dir2 but differ in the two dirs
1: files in $dir1 that are not in $dir2
2: files in $dir2 that are not in $dir1
3: files that are in both $dir1 and $dir2 and are identical in the two dirs

=cut

sub diffuwr {
  my(@dirs) = @_;
  my(@res);
  my($out, $err, $res) = cache_command2("diff -s -q -r '$dirs[0]' '$dirs[1]'");
  for $i (split(/\n/, $out)) {
    if ($i=~/^Files $dirs[0]\/(.*?) and $dirs[1]\/\1 are identical$/) {
      push(@{$res[3]}, $1);
    }  elsif ($i=~/^Files $dirs[0]\/(.*?) and $dirs[1]\/\1 differ$/) {
      push(@{$res[0]}, $1);
    } elsif ($i=~/^Only in $dirs[0]: (.*?)$/) {
      push(@{$res[1]}, $1);
    } elsif ($i=~/^Only in $dirs[1]: (.*?)$/) {
      push(@{$res[2]}, $1);
    } else {
      warn "DIFFUWR BAD LINE: $i";
    }
  }
  return @res;
}

die "TESTING";

write_wiki_page("http://pebesw.referata.com/w/api.php", "Sandbox", "I am putting some sand in my sandbox", "dusty!", $private{referata}{user}, $private{referata}{pass});

die "TESTING";

write_wiki_page("http://pearls-before-swine-bc.wikia.com/api.php", "Mediawiki:zonk0", "<img src='http://assets.amuniversal.com/e553d9009ab3012e2f8200163e41dd5b?width=300' />", "low resolution image", $wikia{user}, $wikia{pass});

die "TESTING";

my($token) = get_wiki_token("http://pearls-before-swine-bc.wikia.com/api.php", $wikia{user}, $wikia{pass});
debug("TOKEN: $token");

my($cmd) = "curl -L 'http://pearls-before-swine-bc.wikia.com/api.php' -d 'action=upload&filename=remote.png&file=\@/mnt/extdrive/GOCOMICS/pearlsbeforeswine/300/page-2003-12-24.gif&token=$token'";

system($cmd);

debug($cmd);

=item get_wiki_token($wiki, $user="", $pass="")

Obtain an edit token for the Main Page of $wiki with username $user
and password $pass (w/ intent to upload files)

=cut

sub get_wiki_token {
  my($wiki, $user, $pass)= @_;

  # cookie file must be consistent, so I can cache
  my($cookiefile) = "/var/tmp/".sha1_hex("$user-$wiki");

  # authenticate to wiki (but cache, so not doing this constantly)
  # get token and sessionid and cookie prefix
  my($out, $err, $res) = cache_command2("curl -L -b  $cookiefile -c $cookiefile '$wiki' -d 'action=login&lgname=$user&lgpassword=$pass&format=xml'", "age=3600");
  debug("ALPHA: $out");
  unless($out=~/token=\"(.*?)\"/) {warn "BAD TOKEN"; return;}
  debug("TOKEN: $1");
  # and use it to login
  ($out,$err,$res) = cache_command2("curl -L -b $cookiefile -c $cookiefile '$wiki' -d 'action=login&lgname=$user&lgpassword=$pass&lgtoken=$1&format=xml'", "age=3600");
  debug("COOKEFIE: $cookiefile");
  debug("BETA: $out");
  # now obtain token any page
  # TODO: requesting tokens 1-page-at-a-time is probably bad
  ($out, $err, $res) = cache_command2("curl -L -b $cookiefile -c $cookiefile '$wiki?action=query&prop=info&intoken=edit&titles=Main+Page&format=xml'", "age=3600");
  debug("GAMMA: $out");
  unless ($out=~/edittoken=\"(.*?)\"/) {warn "BAD TOKEN"; return;}
  return $1;
}

die "TESTING";

$all = read_file("/home/barrycarter/BCGIT/ASTRO/ascp1950.430.bz2.tab");
debug("ALL: $all");
for $i (split(/\n/,$all)) {
  ($i=~/^(\d+)\s+/) || die "BAD!";
  push(@list, $1);
}

$res = 
bzip2seek("/home/barrycarter/BCGIT/ASTRO/ascp1950.430.bz2",11280851,100,\@list);

debug(length($res));

# debug("LIST",@list);

die "TESTING";

=item bzip2seek($file, $start, $len, \@list)

Thin wrapper around seek-bunzip.

Given a bzip2'd file $file, return the $len bytes starting at byte
$start in the original file.

@list is the first column of what "bzip-table" generates for the bzip2'd file

=cut

sub bzip2seek {
  my($file, $start, $len, $listref) = @_;
  my(@list) = @{$listref};
  my($si, $ei, $str);

  # figure out which chunks I'll need to read
  for $i (0..$#list) {
    if ($start >= $list[$i]) {$si = $i;}
    if ($start+$len-1 >= $list[$i]) {$ei = $i;}
  }

  # and read them
  for $i ($si..$ei) {
    debug("CHUNK: $i");
    my($cmd) = "seek-bunzip $list[$i] < $file";
    debug("CMD: $cmd");
    my($out, $err, $res) = cache_command2("seek-bunzip $list[$i] < $file");
    debug("OUT:",length($out));
    $str.=$out;
  }

  # and give user part they want
  debug("RETURNING: $start, $list[$si], LEN:",length($str));
  return substr($str, $start-$list[$si], $len);
}



die "TESTING";

$BZIP2 = "1AY&SY";

open(A,"/home/barrycarter/BCGIT/ASTRO/ascp1950.430.bz2");
seek(A,4792800,0);
# bzip2 blocks never exceed this size??
read(A,$buf,2**21);

$buf=~s/^.*?$BZIP2//;

debug("BUF SIZE:", length($buf));


die "TESTING";

foobar();
foobar();
foobar();
foobar();
foobar();

say "say say what you want";

sub foobar {
  state $x;
  $x++;
  debug("X: $x");
}


# $foo = "bar";

$foo //= "foo";

debug($foo);

die "TESTING";

debug(var_dump("fas",find_attached_scanners()));

# debug("SCANNERS",@scanners);

die "TESTING";

# @all = split(/\n/, read_file"/home/barrycarter/20131202/c.csv");

open(A,$0);
seek(A,517,SEEK_SET);

while (tell(A)>0) {
  debug(current_line2(\*A,"\n",-1));
  debug(tell(A));
}

die "TESTING";

# $ans = unixsort("10","9","-n");
# $foo = ("10" cmp "9");
# debug("ANS: $ans, FOO: $foo");
# debug("PROG ENDS");

for $i (-3..3) {push(@l,10**$i,10**$i-1);}
debug(@l);

debug("FIRST");
debug(sort {unixsort($a,$b,"")} @l);
debug("AND NOW");
debug(sort {unixsort($a,$b,"-n")} @l);

die "TESTING";

$o = new Observer();
$s = new Sun();
debug("S: $s and $o");
$o->{date} = "2013/11/27 MST7MDT";
$o->{lat} = "35.1";
$o->{lon} = "-106.5";
$o->{elevation} = 1528;
$o->{pressure} = 0;
debug($o,$s);
debug($o->next_rising($s));
$m = new Moon();
debug("M: $m");
# debug($o->next_rising($m));

die "TESTING";


cache_command2([\&cos, [1]]);

die "TESTING";

cache_perl_func(\&cos, [1]);

=item cache_perl_func(\&f,\@args,$options)

Given a reference to a function f and a reference to a list of
arguments @args, evaluate f(@args), but cache the results. Similar to
cache_command()/cache_command2() but for functions.

Options:

 salt=xyz: store results in file determined by hashing function w/ salt
 (useful if running multiple instances of the same function)

 age=n: if output file is less than n seconds old + no error, return cached

 fake=1: dont run the command at all, just say what would be done

NOTE: this replicates much of the functionality of Memoize, but with
slight differences.

=cut

sub cache_perl_func {
  my($f,$args,$options) = @_;
  my($now) = time(); # useful to know when run above/beyond file timestamp
  my($cached) = 0; # default: not cached
  my(%opts) = parse_form($options);

  # the (hopefully-but-not-always-unique) string defining this function call
  my($cmd) = join("\n", "FUNCTION", (var_dump("f",$f), var_dump("args",$args)));
  # filename
  my($file) = sha1_hex("$opts{salt}$cmd$opts{salt}");
  # split into two levels of subdirs
  $file=~m/^(..)(..)/;
  my($d1,$d2) = ($1, $2);
  # put in /var/tmp/cache (add username to avoid collision)
  $file = "/var/tmp/cache/$d1/$d2/$file-$ENV{USER}";
  # make sure dir exists
  unless (-d "/var/tmp/cache/$d1/$d2") {
    # /tmp style directory
    system("mkdir -p /var/tmp/cache/$d1/$d2; chmod -f 1777 /var/tmp/cache/$d1 /var/tmp/cache/$d1/$d2");
  }

  # TODO: slightly inefficient to compute this when unneeded
  my($fileage) = (-M $file)*86400;

  # TODO: using same global option for not caching system calls an functions
  # calls = bad?
  if ($globopts{nocache}) {
    # if global nocache, then not cached
    debug("--nocache, not cached");
  } elsif (!(-f $file)) {
    debug("$file does not exist, not cached");
  } elsif ($opts{age}<=0) {
    # setting age=-1 can be useful for testing (instead of just omitting age=)
    debug("opts{age} < 0, not cached");
  } elsif ($fileage > $opts{age}) {
    debug("$file age $fileage > opts{age} $opts{age}, not cached");
  } else {
    debug("result cached in $file ($fileage <= $opts{age})");
    $cached = 1;
  }

  unless ($cached) {
    # if fake, just say command would be run
    if ($opts{fake}) {return "NOT CACHED: $command";}
    # otherwise, run command
    my($res) = system("($command) 1> $file-out 2> $file-err");
    my($stdout,$stderr) = (read_file("$file-out"), read_file("$file-err"));
    # delete now unneeded files
    unlink("$file-out","$file-err");
    # write cached results to $file
    write_file(join("\n", (
			   "<cmd>$command</cmd>",
			   "<time>$now</time>",
			   "<stdout>", $stdout, "</stdout>",
			   "<stderr>", $stderr, "</stderr>",
			   "<status>$res</status>", "\n"
			   )), $file);
    # and return them
    return $stdout, $stderr, $res;
  }







  debug($cmd);
}

die "TESTING";

my($foo) = FFI::Raw->new
("/usr/lib/python2.6/site-packages/ephem/_libastro.so", 
		    "actan", FFI::Raw::double, FFI::Raw::double, FFI::Raw::struct);

debug($foo->call(1.,2.));

die "TESTING";

# $gs = Algorithm::GoldenSection->new( { function => sub { my $x = shift; my $b = $x * sin($x) - 2 * cos($x); return $b },
# x_low => 4,
# x_int => 4.7,} );

$gs = Algorithm::GoldenSection->new({
function => sub {$_[0]**2},
x_low => 3,
x_int => 10
});


my ($x_min, $f_min, $iterations) = $gs->minimise;
print qq{\nMinimisation results: x a minimum = $x_min, function value at minimum = $f_min. Calculation took $iterations iterations};

die "TESTING";

$f = sub {return $_[0]**2-7};

debug(findroot2($f, 0, 10, 0.0000000000000001,"maxsteps=200"));

die "TESTING";

=item findroot2(\&f, $le, $ri, $e, $options)

Does what findroot() does but chooses more intelligent midpoints using
"secant method" (plus minor coding improvements)

Find where f [a one-argument function] reaches 0 (to an accuracy of
$e) between $le and $ri. Stop if $opts{maxsteps} reached before specified
accuracy. Options:

delta: stop and return when the x difference reaches this value,
regardless of difference if y value


=cut

sub findroot2 {
  my($f,$le,$ri,$e,$options)=@_;
  my(%opts) = parse_form("maxsteps=50&$options");
  debug("MAX: $opts{maxsteps}");
  my($steps,$mid,$fmid,$fle,$fri);

  # loop "forever"
  for (;;) {
    # count steps; return what we have so far if too many
    if ($steps++>$opts{maxsteps}) {
      warnlocal("TOO MANY STEPS");
      return $mid;
    }

    # value of the function at interval edges
    # TODO: would caching f() be useful?
    ($fle,$fri)=(&$f($le),&$f($ri));

    # same sign on both sides of interval? bad!
    if (signum($fle) == signum($fri)) {
      warnlocal("INVALID BINARY SEARCH");
      return();
    }

    # the weighted "midpoint" and function value
    $mid = ($ri*$fle - $le*$fri)/($fle-$fri);
    $fmid=&$f($mid);

    debug("RANGE: $le/$mid/$ri");

    # is x delta small?
    if ($opts{delta}&&(abs($ri-$le)<$opts{delta})) {return $mid;}

    # close enough? return midpoint
    if (abs($fmid)<$e) {return($mid);}

    # $mid now becomes either the right or left endpoint
    if (signum($fmid) == signum($fle)) {$le = $mid;} else {$ri = $mid;}
  }
}

=item signum($x)

Returns whether x is positive, negative, or 0.

=cut

sub signum {
  my($x) = @_;
  if ($x>0) {return 1;}
  if ($x<0) {return -1;}
  return 0;
}

die "TESTING";

option_check(["foo","bar"]);

die "TESTING";

# fun w/ tennis

debug(wii_tennis_ns(1900));

die "TESTING";

@l = tennis_probs(0.99);

for $i (@l) {$tot+=$i;}

debug("TOT: $tot",@l);

sub tennis_probs {
  my($p) = @_;
  my($q) = 1-$p;

  return($p**4, 4*$q*$p**4, 10*$q**2*$p**4, (20*$p**5*$q**3)/(1-2*$p*$q),
  (20*$q**5*$p**3)/(1-2*$p*$q), 10*$p**2*$q**4, 4*$p*$q**4, $q**4);
}

sub wii_tennis_ns {
  my($cur) = @_;
  my(@res);

  # asymptotes per
  # http://orden-y-concierto.blogspot.de/2013/04/wii-sports-tennis-skill-points-system.html
  # for Elisa/Sarah
  my(@asy) = (2400, 2250, 2100, 2000, 1600, 1500, 1350, 1200);

  for $i (@asy) {push(@res, ($i+19*$cur)/20);}
  return @res;
}


die "TESTING";

# fun with dates (1893481200 = 2030)
for ($i=1384196400+86400; $i< 1893481200; $i+=86400*7) {
  print strftime("%Y%m%d\n", localtime($i));
}

die "TESTING";

sub foo {return $_[0];}
print foo("bar");
print &foo("bar");

printf("%s","hello\n");
&printf("%s", "hello\n");

die "TESTING";

# perl pair oddness

my(@pairs);

for $i (0..5) {
  for $j (0..5) {
    push(@pairs,[$i,$j]);
  }
}

@pairs = sort {abs($a->[1]-$a->[0]) <=> abs($b->[1]-$b->[0])} @pairs;

for $i (@pairs) {
  debug("I: $i");
  debug("0: $i->[0]");
  @list = @{$i};
  print "$list[0],$list[1]\n";
}

die "TESTING";

# device testing (did "chmod a+r /dev/sdb3" first)
open(A,"/dev/sdb3");
seek(A, 91672576, SEEK_SET);
read(A,$foo,512);
debug("FOO: $foo");

die "TESTING";

for ($i=0; $i<=4e+12; $i+=512) {
  seek(A, $i, SEEK_SET);
  read(A,$foo,512);
  # get rid of nulls and "fulls"
#  $foo=~s/\xff//isg;
#  $foo=~s/\x00//isg;
  $foo=~s/[^ -~]//isg;
  unless (length($foo)>50) {next;}
  debug("I: $i",$foo);
}

die "TESTING";

%hash=(1=>2,3=>4);

debug(0+keys %hash);

die "TESTING";

my($file) = my_tmpfile2();
debug("FILE: $file");
write_file("hello",$file);

$res = sqlite3val("SELECT follow_reply FROM bc_multi_follow WHERE action='SOURCE_UNFOLLOWS_TARGET'","/usr/local/etc/bc-multi-follow.db");

$res = decode_base64($res);

$res=~m%<out>(.*?)</out>%is;
$res = $1;

$json = JSON::from_json($res);

debug("JSON:",dump_var("json",$json));

die "TESTING";

use Flickr::API;

debug($flickr{apikey},$flickr{apisecret});
my $api = new Flickr::API({
		'key'    => $flickr{apikey},
                'secret' => $flickr{apisecret}
        });

  my $response = $api->execute_method('flickr.test.echo', {
                'foo' => 'bar',
                'baz' => 'quux',
        });

debug(dump_var($api));
debug(dump_var($response));

die "TESTING";

# spit out 2nd wednesdays of each month
for $i (2013..2032) {
  for $j ("01".."12") {
    my($dom) = sprintf("%02d",14-(str2time("$i-$j-1 12:00:00")/86400)%7);
    print "$i$j$dom\n";
  }
}

die "TESTING";

my($x) = 7;
a();
sub a {print "HELLO, $x\n"; b()}
sub b {print "$x still 7!\n"; c()}
sub c {my($x); print "but not $x now\n";}

die "TESTING";

bc_check_domain_exp();

die "TESTING";

my($out,$err,$res) = cache_command2("date +%x","age=30");

debug("OUT: $out");

die "TESTING";

%hash = recent_forecast();

debug(unfold($hash{KABQ}{TMP}));

die "TESTING";

my($out,$err,$res) = cache_command("curl http://nws.noaa.gov/mdl/forecast/text/avnmav.txt", "age=3600");
$out=~/\n(\s*KABQ.*?)\n +\n/is;
debug($1);


die "TESTING";

wii_tennis("L",40,1928,-18);

die "TESTING";


%ret = recent_forecast();
for $i (sort keys %ret) {
  print "$i $ret{$i}{hilo}\n";
}

# debug(unfold(recent_forecast()));

die "TESTING";

# TODO: try fly
# create a 100K pixel image is faster than libGL?

$im = new GD::Image(800,600);
$white = $im->colorAllocate(255,255,255);
$black = $im->colorAllocate(0,0,0);

for $i (1..1000000) {
  $im->setPixel(rand()*800,rand()*600,$black);
}

write_file($im->png,"temp.png");

die "TESTING";

use OpenGL qw(:all);

glutInit();

# use double buffering + depth buffering
glutInitDisplayMode(GLUT_DEPTH | GLUT_DOUBLE | GLUT_RGBA);

# optional: window size
glutInitWindowSize(800,600);

# create the window
glutCreateWindow("Particle Man");

# glutDisplayFunc(): what to do when display is damaged
glutDisplayFunc(display);

# glutIdleFunc(): what to do when application is idle
# often same as glutDisplayFunc()
glutIdleFunc(display);

glutMainLoop();

sub display {
  glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);

  for $i (1..100000) {
    glBegin(GL_POINTS);
    glColor3f(rand(),rand(),rand());
    glVertex2f(2*rand()-1,2*rand()-1);
    glEnd();
  }

  glutSwapBuffers();

  if (++$count>100) {die "ETSTING";}

}

die "TESTING";


debug(stardate(time(), "localtime=1"));

die "TESTING";

bc_check_files_age("/home/barrycarter/.getmail/oldmail-imap*", 10);

die "TESTING";

die "TESTING";

bc_head_size("http://s3.amazonaws.com/plivocloud/4c743546-7e1b-11e2-9060-002590662312.mp3", 1962720);

die "TESTING";

bcinfolog();

die "TESTING";

# extract_emails_phones("leonard.zeptowitz+130130143936\@gmail.com");

# die "TESTING";

open(A,"/home/barrycarter/mail/leonard.zeptowitz");
while (($head,$body) = next_email_fh(\*A)) {
  unless ($head) {last;}
  extract_emails_phones($body);
}

=item extract_emails_phones($str)

Returns a list of phone numbers and email addresses in $str

This subroutine doesnt necessarily work well, just subroutinizing it
for consistency.

=cut

sub extract_emails_phones {
  my($str) = @_;

#  debug("STR: $str");

  # worthless junk that seems to show up a lot in email
  $str=~s/=[0-9A-F][0-9A-F]//isg;

  # email addresses CAN have spaces, but its rare nowadays
  # address must end in alphanumeric (just alpha?) [.com/.net/.mobi/.sg/etc]
  # and start with alphanum
  while ($str=~s/([a-z0-9][^\s<>;:\"\&\?\(\)\*\,\[\]\{\}]+\@[^\s<>;:\"\&\?\(\)\*\,\[\]\{\}]+[a-z0-9])//i) {
    my($cand) = $1;

    # reject pure numericals pre @ and double dots
    if ($cand=~/^\d+\@/) {next;}
    if ($cand=~/\.\./) {next;}

#    debug("EMAIL: $1");
  }

  # and phone numbers (harder)
  while ($str=~s/(\+[^a-z]+)//i) {
    my($cand) = $1;
    $cand=~s/\D//isg;
    unless (length($cand)>=5) {next;}
    debug("PHONE: $cand");
  }
}

die "TESTING";

open(A,"/home/barrycarter/mail/leonard.zeptowitz");
while (($head,$body) = next_email_fh(\*A)) {
  unless ($head) {last;}

  $head=~/^From: (.*?)$/im;
  my($from) = $1;

  # remove refs to my own email addresses
  $body=~s/\+(\d+)\@gmail\.com//isg;

  if ($body=~/(\+[^a-z]{5,})\n/is) {
    my($phone) = $1;
#    debug("PRE: $phone");
#    $phone = trim($phone);
    $phone=~s/\D//isg;
    # no interesting phone numbers less than 5 digits
    unless (length($phone)>=5) {next;}

    debug("$phone [$from]");
#    debug("BODY: $body");
  }
}

die "TESTING";

use Data::Faker;

my $faker = Data::Faker->new();

for $i (sort $faker->methods()) {
  print "$i: ". $faker->$i(). "\n";
}

die "TESTING";


         print "Name:    ".$faker->name."\n";
         print "Company: ".$faker->company."\n";
         print "Address: ".$faker->street_address."\n";
         print "         ".$faker->city.", ".$faker->us_state_abbr." ".$faker->us_zip_code."\n";

die "TESTING";

=item sunhoriz($yr,$mo,$da,$long,$lat,$type="rise|set",$seek=+-1)

Determine the sunrise or set on $yr/$mo/$da for $lat/$long in GMT.

If there is no sunrise/set, seek forward ($seek=1) or backwards
($seek=-1) to nearest sunrise/set.

Thin wrapper around Astro::Sunrise

=cut

sub sunhoriz {
  my($yr,$mo,$da,$long,$lat,$type,$seek) = @_;
  # prevents Astro::Sunrise from carping improperly
  local $SIG{__WARN__} = sub { die $_[0] };
  my(@res);

  # basic try
  @res = eval{sunrise($yr,$mo,$da,$long,$lat)};

  unless ($@) {
    if ($type eq "rise") {return $res[0];}
    return $res[1];
  }

  debug("ERF: $@");

  # now need to seek
  # TODO: everything
}

debug(sunhoriz(2012,5,15,0,70,"rise"));

$ENV{TZ}="UTC";
system("date");
print sun_rise(0,70,0),"\n";
$ENV{TZ}="America/Denver";
system("date");
print sun_rise(0,70,-0.999),"\n";

# ($sunrise, $sunset) = sunrise(2012,11,26,0,70,0,0);
# local $SIG{__WARN__} = sub { die $_[0] };
# @res = eval{sunrise(2012,9,26,0,70,0,0)};
# debug("0: $@");
# debug("RES",@res,$@);
# debug($sunrise,$sunset);
# $sunrise = sun_rise(0,70);
# $sunset = sun_set(0,70);

die "TESTING";

my $lat = deg2rad(70);
my $long = deg2rad(0);
my $alt = 0;
my $sun = Astro::Coord::ECI::Sun->new();
my $sta = Astro::Coord::ECI->
     universal (time ())->
     geodetic ($lat, $long, $alt);
 my ($time, $rise) = $sta->next_elevation ($sun);
 print "Sun @{[$rise ? 'rise' : 'set']} is ",
     scalar gmtime $time, " UT\n";

die "TESTING";

=item str2emails($str)

Attempts to returns all email addresses in $str

Subroutine-izing this so, if I ever figure out the magic regexs, I
won't have to change in multiple places. No guarentee this works well.

=cut

sub str2emails {
  my($str) = @_;

  while ($str=~s///) {}




}





die "TESTING";


=item dothisfirst

: create a file with two large MIME-encoded files separated by a triple newline(dd if=/dev/urandom bs=2000 count=1000 | base64 ; echo "\n\n\n" ; dd if=/dev/urandom bs=2000 count=1000 | base64 ) >! /tmp/testfile.txt

=cut

# our goal: capture the MIME-encode of the first file in a single
# string without capturing the MIME-encode of the second file

# in other words, we want the first ~675K characters of
# /tmp/testfile.txt (however, in production, we wouldnt know how long
# the MIME-encode was)

undef $/;
open(A,"/tmp/testfile.txt");
$all = <A>;
close(A);

$all=~s/\n/\*/isg;

debug("ALL: $all");

my($chars) = "[a-zA-Z0-9\+\/]";

# below yields full length of $all (MIME-encode of both files)
# $all=~s/^(.*)$/foo($1)/iseg;

# below yields "2523137" then "178467" then "2523137" then "178544"

# In other words, it captures the first 2523137 character of the first
# file, then the next 178467 characters of the first file, instead of
# capturing all 2701604 characters of the first file like I want. Note
# that 2523137 is approximately 77*32767 (and each line of
# /tmp/testfile.txt is 77 characters long)

$all=~s/(\*($chars{50,}\=*\*)+)($chars+\=*\*)/foo("$1$3")/eg;

die "TESTING";

# this is @ikegami solution (I think)
$all=~s/((\n($chars{50,}\=*\n){0,20000})+)($chars+\=*\n)//seg;
print STDERR "1 is $1\n";
print STDERR "2 is $2\n";
print STDERR "3 is $3\n";
print STDERR "4 is $4\n";
print STDERR "5 is $5\n";
print STDERR "6 is $6\n";

# below makes foo() print 2391992 [which is ~73*32767] many times
# $all=~s/(\n($chars{50,}\=*\n)+)/foo("$1")/seg;

# $all=~s/((\n($chars{50,}\=*\n){0,20000})+)/foo("$1")/seg;

sub foo {print STDERR length($_[0]),"\n";}

# debug($1);

die "TESTING";

for $i (-24..24) {
  objriseset("sun", 35, -106.5, -1, 1, time()+$i*3600,0);
}

# $res = objriseset("sun",70,0,86400*87.75+str2time("May 01 2012 00:00:00 GMT"),-.8333333333333);

# debug($res);

die "TESTING";

# debug(find_nearest_zenith("sun",35,-106,time(),"nadir=0&which=-1"));

# $ENV{TZ}="UTC";

# debug(gmst(time()));

# debug(str2time("2012-05-06 04:16"));

# die "TESTING";

# ($ra,$dec) = position("sun",str2time("2012-05-06 04:09 GMT"));

# debug("RADEC: $ra $dec");

# debug(radecazel($ra,$dec,55,0,str2time("2012-05-06 04:09 GMT")));

# debug(radecazel(43.4062357/15,16.5861687,55,0,str2time("2012-05-06 04:09 GMT")));

# $res = objriseset2("sun",70,0,86400*87.75+str2time("May 01 2012 00:00:00 GMT"),-.8333333333333);
# $res = objriseset2("sun",70,0,str2time("Jan 18 2012 12:00:00 GMT"),-5/6.);

$res = objriseset2("moon",35.05,-106.5,time()-12*3600,-5/6.+0.942433227487068);

system("date -d \@$res");

die "TESTING";

=item upc2nutrition(\@codes)

Given a list of UPC codes (assumed to be food items), return
nutritional information for these codes using db at
dfoods.db.94y.info. Allow for loss of leading 0s and UPC code short
forms. Uses LEFT JOIN, so returns all codes, including those w/o
information in db (primarily for testing)

NOTE: this is a fairly trivial function, and I feel silly writing
it. Its a thin wrapper around an SQL query.

=cut

sub upc2nutrition {
  # TODO: below is annoyingly bad Perl
  for $i (@{$_[0]}) {
    # UPC codes are 12 digits, so a 12 digit code is fine as is
    if (length($i) == 12) {next;}
    debug("I: $i");
  }

  my($codes) = 
  my($query) = "SELECT * FROM foods WHERE UPC IN ()";


}

die "TESTING";

$foo = "x"x50000;

$foo=~/(x{6000})(x{6000})(x{6000})(x{6000})(x{6000})(x{6000})(x{6000})/;

debug("$&",@_,@+);

die "TESTING";

for $i (0..255) {
  for $j (0..255) {
    printf("%02x %02x\n",$i,$j);
  }
}

die "TESTING";

gnumeric2sqlite3("/home/barrycarter/BCGIT/FOODTRACK/foods.gnumeric", "foods", "/home/barrycarter/BCINFO/sites/DB/foods.db");

die "TESTING";

for $i (split(/\n/,read_file("/tmp/bwl.txt"))) {
  ($x,$y) = split(/\s+/,$i);
  push(@x,$x);
  push(@y,$y);
}

# @x= (1,2,3,4);
# @y=(3,5,7,9);

# @x=(1,2);
# @y=(3,5);

($a,$b,$sumy,$ref) = linear_regression(\@x,\@y);

debug($a,$b,$sumy,$ref);
@running = @{$ref};

while (@running) {
  ($x,$y) = (shift(@running), shift(@running));
  if (++$n<10) {next;}
#  print "$x[$n-1] $y\n";
  print "$x[$n-1] $x\n";
}

# debug("RUNNING",@running);

die "TESTING";

%test = obtain_weights(str2time("20120911 192058 MDT"));

for $i (keys %test) {
 push(@x, $i);
 push(@y,$test{$i});
}

debug("X",@x,"Y",@y);

($a,$b) = linear_regression(\@x, \@y);

debug("LIN: $a $b");

die "TESTING";

# does clustering harm linear regression (apparently not)

@x=(1,2,3);
@y=(4,6,8);

for $i (1..1000) {
  push(@x,3+$i/1000000);
  push(@y,8);
}

($a,$b,$c) = linear_regression(\@x,\@y);

debug("RES: $a $b $c");

# <h>ETSTING is like testing, only moreso</h>
die "ETSTING";

@arr=gnumeric2array("/home/barrycarter/BCGIT/FOODTRACK/foods.gnumeric");

($foo, $bar) = arraywheaders2hashlist(\@arr, "UPC");

debug("RES",unfold($bar));

die "TESTING";

# following discussion at http://erisds.co.uk/code/twitter-oauth-simple-curl-requests-for-your-own-data

# all variables are defined in bc-private.pl

%oauth = ('oauth_consumer_key' => $consumer_key,
	  'oauth_nonce' => time(),
	  'oauth_signature_method' => 'HMAC-SHA1',
	  'oauth_token' => $oauth_access_token,
	  'oauth_timestamp' => time(),
	  'oauth_version' => '1.0');

for $i (keys %oauth) {push(@strs,"$i=$oauth{$i}");}
$str = join("&", @strs);

($out, $err, $res) = cache_command("curl 'https://api.twitter.com/oauth/request_token?$str'","age=3000");

debug("STR: $str");
debug("OUT: $out");



die "ETSTING";

$all = read_file("/tmp/piout.txt");

while ($all=~s/\'(.*?)\'(, |$)//) {
  my($res) = $1;

#  debug("RES: $res");

  # convert hex
  $res=~s/\\x([0-9a-f][0-9a-f])/chr(hex($1))/iseg;
  $res=~s/\\r/\r/isg;
  $res=~s/\\n/\n/isg;
  $res=~s/\\\'/\'/isg;
  $res=~s/\\\\/\\/isg;

  $temp++;
  write_file($res,"/tmp/temp-$temp.png");

  die "TESTING";

#  debug("RES: $res");
}

# debug($all);

die "TESTING";

picloud_commands("date", "time ls", "ls -l /usr/local/etc/");

die "TESTING";

$res = twitter_highuser();
debug("RES: $res");
debug(twitter_get_info($res));

die "TESTING";

print join("\n",twitter_dump_unfollowers($supertweet{user},$supertweet{pass}));

die "TESTING";

warnlocal("Is warn local borken");

$ob = new XML::Bare(text=>'<xml><name>Bob</name></xml>');
for $i (keys %{$ob->{xml}}) {print "KEY: $i\n";}

# debug(unfold($ob));

die "TESTING";

exit;

$str = "food"x12;

if ($str=~/((food)+)/) {
  debug("MATCH: $1, $2");
}

# debug($str);

die "TESTING";

# for $i (1337118123-1..1337118123+1) {
#   debug("I: $i");
#  debug(radecazel2(position("moon", $i), 35.11083, -106.61, $i));
# }

# debug(objriseset2("moon", 35.11083, -106.61));

for $i (0..180) {
#  $ret =objriseset2("moon", 35.11083, -106.61, time()+86400*$i, 0.949659);
#  $ret =objriseset2("sun", 35.11083, -106.61, time()+86400*$i, 0)
#  $ret =objriseset2("sun", 71.29556, -156.76639, time()+86400*$i, 0);
  $ret =objriseset2("sun", 70, 0, time()+86400*$i, 0);
  print "$i: $ret\n";
}

die "TESTING";

=item objriseset($obj, $lat, $lon, $which, $when, $time=time(), $el=0)

Determines when a next ($when=1) or previously ($when=-1) rises/rose
[above $el] ($which=1) or set/sets [below $el] ($which=-1) at $lat
$lon before/after $time

Uses code from soon-to-be-defunct objriseset2()

=cut

sub objriseset {
  my($obj, $lat, $lon, $which, $when, $time, $el) = @_;
  unless ($time) {$time=time();}

  # find LST
  my($lst) = fmodp(gmst($time) + ($lon/15), 24);

  # get object RA
  my($ra,$dec) = position($obj,$time);

  # siderial hours to culmination
  my($dist) = fmodp($ra-$lst,24);

  # if more than 12 to culm, object is sinking, else not
  # opted not to use $rising as varname, ambigious meaning
  my($sinking) = ($dist>=12);

  # current elevation of object (and if its above or below $el)
  my($objaz, $objel) = radecazel($ra, $dec, $lat, $lon, $time);
  my($above) = ($objel>=$el);




  return;

  my(@l);

  # find objects next/previous zenith/nadir (all 4)
  for $i (0,1) {
    for $j (-1,1) {
      $l[$i][$j] = find_nearest_zenith($obj, $lat, $lon, $time, "which=$j&nadir=$i");
    }
  }

  # TODO: too many cases below

  debug("LL",@l);
}

=item objriseset2($obj, $lat, $lon, $time=now(), $el=0)

Find the nearest time to $time that $obj crosses elevation $el
(default $el=0=horizon) at $lat/$lon

=cut

sub objriseset2 {
  my($obj, $lat, $lon, $time, $el) = @_;
  unless ($time) {$time=time();}

  # find objects nearest nadir and zenith
  my($zen) = find_nearest_zenith($obj, $lat, $lon, $time);
  my($nad) = find_nearest_zenith($obj, $lat, $lon, $time, "nadir=1");

  # objects elevation at zenith and nadir ($x=unwanted)
  my($x, $zenel) = radecazel(position($obj, $zen), $lat, $lon, $zen);
  my($x, $nadel) = radecazel(position($obj, $nad), $lat, $lon, $nad);

  # if object never crosses $el, warn and return nothing
  # positive*positive = negative*negative = positive
  # TODO: handle this special case
  if (($zenel-$el)*($nadel-$el)>0) {
    warn "CASE NOT YET HANDLED";
    return;
  }

  # create one-variable function ($time) for which we want to find 0
  my($func) = sub {
    my($t) = @_;
    my($x, $objel) = radecazel(position($obj, $t), $lat, $lon, $t);
    my($eldiff) = $objel-$el;
    debug("f($t) = $eldiff");
    return $eldiff;
  };

  return findroot($func, $nad, $zen, 0.005, 50);

}


debug(find_nearest_zenith("moon",35,-106,time()+3600,"nadir=1"));

die "TESTING";

for $i (0..365) {
  $res = find_nearest_zenith("sun",35,-106,time()+$i*86400)%86400;
  print "$res\n";
}

die "TESTING";

debug(linear_regression([3,5],[4,7]));

die "TESTING";

$planet = "mercury";

for $planet ("venus", "sun", "moon", "mars", "jupiter", "saturn", "uranus") {
  @ret = planet_points($planet, .1, "dec");
  write_file(join("\n",@ret), "/home/barrycarter/BCGIT/db/$planet-approx-dec.txt");
}

die "TESTING";

# for mercury, test that interpolation results (in
# /home/barrycarter/20120505/merc3.txt) match real results with 0.1
# degree

# this file is only 684 lines long (wow?!)
for $i (split(/\n/, read_file("/home/barrycarter/20120505/merc5.txt"))) {
  $i=~/^(.*?)\s+(.*)$/;
  # now storing "starting_ra slope" in est
  $est{$1} = $2;
}

# and now the actual data
open(A,"bzcat /home/barrycarter/BCINFO/sites/DATA/planets/mercury.csv.bz2|");

while (<A>) {
  # too slow to analyze all points, so... (TODO: this is ugly)
  unless (rand()<.1) {next;}

  # find time/ra/dec (we may use dec later)
  /^(.*?)[, ]+(.*?),(.*?),*$/;
  ($time, $ra, $dec) = ($1, $2, $3);
  $guess = linear_interpolate(\%est, $time);
  $diff = $ra-$guess;
  debug("RA: $ra, GUESS: $guess, DIFF: $diff");
  print "$time $diff\n";
}

die "TESTING";

=item linear_interpolate(\%hash, $point)

Given %hash which represents points for linear interpolation (keys are
x values, "ra slope" are vals), return value of interpolation at
$point.

TODO: this is extremely inefficient and for testing purposes only

=cut

sub linear_interpolate {
  my($hashref, $point) = @_;
  my(%hash) = %{$hashref};
  my($pos);

  # sort the keys and fince where $point belongs
  my(@xvals) = sort keys %hash;

  for $i (0..$#xvals) {
    debug("I: $i");
    debug("TESTING: $xvals[$i] vs $point vs $xvals[$i+1]");
    if (($xvals[$i] < $point) && ($point <= $xvals[$i+1])) {
      debug("SETTING POS: $pos");
      $pos = $i;
      last;
    }
  }

  debug("$point is between $xvals[$pos] and $xvals[$pos+1]");

  # split y value into initial value and slope
  my($iv, $slope) = split(/\ /, $hash{$xvals[$pos]});

  # it's between the ith and i+1-th element of xvals, so the interp is
  my($guess) = ($point-$xvals[$pos])*$slope + $iv;
  return $guess;

}

die "TESTING";

=item planet_points($planet, $tolerance, $which="ra|dec")

One-off subroutine that looks at
/home/barrycarter/BCINFO/sites/DATA/planets/$planet.csv.bz2 and
returns (as a list) the fewest points to convert $which to
linear interpolation within $tolerance. Return value is array of:

"$time $value $slope"

Where $slope is good until next $time

TODO: not working for dec yet

=cut

sub planet_points {
  my($planet, $tolerance, $which) = @_;
  local *A;
  my($xstart, $ystart, $minslope, $maxslope, $ptmin, $ptmax, $n);
  my(@ret);

  # open file
  open(A,"bzcat /home/barrycarter/BCINFO/sites/DATA/planets/$planet.csv.bz2|");

  while (<A>) {

    # find time/ra/dec (we may use dec later)
    /^(.*?)[, ]+(.*?),(.*?),*$/;
    ($time, $ra, $dec) = ($1, $2, $3);

    # this is just plain hideous
    if ($which eq "dec") {$ra = $dec;}

    # first line? (TODO: remove this icky special case?)
    if (++$n==1) {
      $xstart = $time;
      $ystart = $ra;
      ($minslope, $maxslope) = (-Infinity, +Infinity);
      ($prevtime, $prevra, $prevdec) = ($time, $ra, $dec);
      next;
    }

    # not first line?
    # acceptable ranges of slope for this point
    $ptmax = ($ra+$tolerance-$ystart)/($time-$xstart);
    $ptmin = ($ra-$tolerance-$ystart)/($time-$xstart);
    
    # is there no way this point can fit? If so, write out previous
    # slope range (as midpoint) and treat current value as new start
    # value (and recompute $ptmin/max)
    
    if ($ptmax < $minslope || $ptmin > $maxslope) {
      # the ra that falls within $prevra +- $tolerance AND creates a slope
      # that can be used by any points in between
      my($accslope) = ($minslope + $maxslope)/2;
      push(@ret, "$xstart $ystart $accslope");
      $xstart = $prevtime;
      $ystart = $prevra;
      ($minslope, $maxslope) = (-Infinity, +Infinity);
      $ptmax = ($ra+$tolerance-$ystart)/($time-$xstart);
      $ptmin = ($ra-$tolerance-$ystart)/($time-$xstart);
  }

    # min and max slope for all points so far
    if ($ptmax < $maxslope) {$maxslope = $ptmax;}
    if ($ptmin > $minslope) {$minslope = $ptmin;}

    # keep track of current ra/dec/time
    ($prevtime, $prevra, $prevdec) = ($time, $ra, $dec);
  }

  return @ret;
}

die "TESTING";

# earlier method too inefficient, so...

$tolerance=0.1;


while (<A>) {
  /^(.*?)[, ]+(.*?),(.*?),*$/;
  ($time, $ra, $dec) = ($1, $2, $3);

  # use db to estimate!
  @prev = sqlite3hashlist("SELECT * FROM foo WHERE time<=$time ORDER BY time DESC LIMIT 1", "tmp/test.db");
  @next = sqlite3hashlist("SELECT * FROM foo WHERE time>=$time ORDER BY time LIMIT 1", "tmp/test.db");

  # ignoring this case for now
  unless (@prev) {next;}

  %prevhash = %{$prev[0]};
  %nexthash = %{$next[0]};

  # another special case to ignore (for now)
  if ($prevhash{time} == $nexthash{time}) {next;}

  debug("PREV",%prevhash,"NEXT",%nexthash);

  $slope = ($nexthash{angle}-$prevhash{angle})/($nexthash{time}-$prevhash{time});
  $guess = ($time-$prevhash{time})*$slope + $prevhash{angle};
  debug("GUESS: $guess, REAL: $ra");
  print $guess-$ra,"\n";
#  debug("SLOPE: $slope");

#  debug("PREV",unfold(@prev));
#  debug("NEXT",unfold(@next));

#  warn "TESTING";
  next;



  # first line?
  if (++$n==1) {
    $xstart = $time;
    $ystart = $ra;
    ($minslope, $maxslope) = (-Infinity, +Infinity);
    print "$time $ra\n";
    next;
  }

  # not first line?
  # acceptable ranges of slope for this point
  $ptmax = ($ra+$tolerance-$ystart)/($time-$xstart);
  $ptmin = ($ra-$tolerance-$ystart)/($time-$xstart);

  # is there no way this point can fit? If so, write out previous
  # slope range (as midpoint) and treat current value as new start
  # value (and recompute $ptmin/max)

  if ($ptmax < $minslope || $ptmin > $maxslope) {
    # the ra that falls within $prevra +- $tolerance AND creates a slope
    # that can be used my any points in between
    $accslope = ($minslope + $maxslope)/2;
    $estra = ($prevtime-$xstart)*$accslope + $ystart;
    print "$prevtime $estra\n";
    $xstart = $prevtime;
    $ystart = $prevra;
    ($minslope, $maxslope) = (-Infinity, +Infinity);
    $ptmax = ($ra+$tolerance-$ystart)/($time-$xstart);
    $ptmin = ($ra-$tolerance-$ystart)/($time-$xstart);
  }

  # min and max slope for all points so far
  if ($ptmax < $maxslope) {$maxslope = $ptmax;}
  if ($ptmin > $minslope) {$minslope = $ptmin;}

  # keep track of current ra/dec/time
  ($prevtime, $prevra, $prevdec) = ($time, $ra, $dec);
    
  debug("RANGE: $ptmin-$ptmax, TIGHT: $minslope-$maxslope");
}

die "TESTING";

# not random, but more useful (lunar "ra" values)
system("bzcat /home/barrycarter/BCINFO/sites/DATA/planets/moon.csv.bz2 | cut -d, -f 4 > /tmp/list.txt");
@l = split(/\n/, read_file("/tmp/list.txt"));

debug("ANSWER", unfold(best_linear(\@l, 0.25)));

# srand(20120502); # I need a reliable stream of "random" numbers for testing
# for $i (1..100) {push(@l,$i+rand());}

write_file(join("\n",@l), "/tmp/gnuplotme.txt");
system("echo plot \\\"/tmp/gnuplotme.txt\\\" with linespoints|gnuplot -persist");

=item best_linear(\@list, $tolerance)

Given a @list of numbers, find the least complex piecewise linear
function that fits the @list within $tolerance

Return value is a list of (slope,#elements)

=cut

sub best_linear {
  debug("BEST_LINEAR(",@_,")");
  my($listref, $tolerance) = @_;
  my(@list) = @{$listref};
  debug("GOT LIST OF $#list+1 size");
  my(@ret);
  my($i); # this shouldn't be necessary

  # initial setting for minslope/maxslope
  my($minslope, $maxslope) = (-Infinity, +Infinity);

  # go thru 2nd-last element of list
  for $i (1..$#list) {
    debug("I: $i");

    # each element limits the slope
    # TODO: allow tolerance for first element too (non-trivial)
    my($slopeplus) = ($list[$i]-$list[0]+$tolerance)/$i;
    my($slopeminus) = ($list[$i]-$list[0]-$tolerance)/$i;

    debug("$i, $list[0], $list[$i], $minslope, $maxslope");

    # if this element can't possibly fit in existing range, recurse
    # or we've reached last element 
    if ($slopeplus < $minslope || $slopeminus > $maxslope || $i==$#list) {
      push(@ret, [$list[0], $i, ($minslope+$maxslope)/2]);
      my(@remainder) = @list[$i..$#list];
      if (@remainder) {push(@ret, best_linear([@remainder], $tolerance));}
      return @ret;
    }

    # does this element limit the slope more than previously? 
    if ($slopeplus < $maxslope) {
      $maxslope = $slopeplus;
    }
    
    if ($slopeminus > $minslope) {
      $minslope = $slopeminus;
    }
  }
}



die "TESTING";

# use Astro::Coords::Planet;
# $c = new Astro::Coords::Planet( 'uranus' );
# debug($c->summary());


die "TESTING";

use Astro::Coord::ECI::Moon;
my $loc = Astro::Coord::ECI->geodetic (0, 0, 0);
$moon = Astro::Coord::ECI::Moon->new ();
@almanac = $moon->almanac($loc, time());

debug(unfold(@almanac));

die "TESTING";

$foo = "hello";
@bar = ("hel");
for $i (@bar) {
  print "I: $i\n";
#  if ($foo=~/hello/) {print "ONE\n";}
  if ($foo=~/$i/) {print "TWO\n";}
}

die "TESTING";

debug(unfold(recent_weather()));

die "TESTING";

debug(cpanel($cpanel{site},$cpanel{user},$cpanel{pass}));


die "TESTING";

# ugly hack for testing bc-twitter.pl

# ($user, $pass) = ($supertweet{user}, $supertweet{pass});
# debug(twitter_follower_ids($user,$pass));

debug(twitter_public_timeline());

# debug(twitter_rate_limit_status());

# debug(twitter_search("math help"));
# debug(twitter_get_info("barrycarter"));
# debug(twitter_get_friends_followers("barrycarter", "followers"));
# twitter_follow("marileetombo",0);
# $test = `date`x10;
# $str = "#hash \@you This is a long #hish $test for \@bob";
# debug(tweet2list($str));

die "TESTING";

# find_zenith("sun", 35, -106);
find_zenith("moon", -35, -106);

# sunriseset(time(),35.0844869067959,-106.651138463684);
sunriseset(time(),77.0844869067959,-106.651138463684);

# debug(sunel(1342173287), sunel(1342173287+4*3600));
# findmax(\&sunel, 1342173287, 1342173287+12*3600, 1);

die "TESTING";

# simpler version of objriseset for sun (and later moon?) since I get
# ra/dec in other ways?

=item sunriseset($t,$lat,$lon,$el)

Return the sunrise and set nearest to (and "bracketing") $t for
position, $lat, $lon, elevation $el feet (currently ignored). Also
returns twilight times

=cut

sub sunriseset {
  my($t,$lat,$lon) = @_;

  # function to hit minimize (TODO: anonymize)
  sub sunel {
    my($t) = @_;

    # find solar RA/DEC at given time
    my($ra,$dec) = position("sun", $t);

    # And AZEL at this lat/lon
    my($az,$el) = radecazel($ra,$dec,$lat,$lon,$t);

    # and return elevation
    return $el;
  }

#  debug(sunel(1340467535), sunel(1340510735));
#  debug(findmax(\&sunel, 1340467535, 1340510735, 1));
#  die "TESTING";

  my(%sol);

  # use findmin to find last/next time sun was above/below 0/-6 degrees
  # using 12 hour windows with 6 hour jumps to avoid corner cases

  # NOTE: despite the names, this does NOT find zenith/nadir; it just
  # finds times when sun is above/below given threshold

  for $i ("prev","next") {
    for $j ("nadir", "zenith") {
      for $k ("horizon", "twilight") {
	# if already defined, ignore
	if ($sol{$i}{$j}{$k}) {next;}

	# otherwise, loop to find
	for $n (0..1460) {

	  debug("$i/$j/$k/$n");

	  # window to look in
	  my($st,$val,$thres);
	  if ($i eq "prev") {
	    $st = $t - $n*6*3600 - 12*3600;
	  } else {
	    $st = $t + $n*6*3600;
	  }

	  # 12 hour window
	  $en = $st + 12*3600;

	  if ($j eq "nadir") {
	    $val = findmin(\&sunel, $st, $en, 1);
	  } else {
	    $val = findmax(\&sunel, $st, $en, 1);
#	    debug("findmax $st/$en yields $val",sunel($val));
	  }

	  if ($k eq "horizon") {
	    $thres = 0;
	  } else {
	    $thres = -6;
	  }

	  if ($val && $j eq "nadir" && sunel($val) < $thres) {
	    $sol{$i}{$j}{$k} = $val;
	    last;
	  }

	  if ($val && $j eq "zenith" && sunel($val) > $thres) {
	    $sol{$i}{$j}{$k} = $val;
	    last;
	  }
	    
	}

#	debug("$i/$j/$k -> $sol{$i}{$j}{$k}");
#	print "$i/$j/$k -> $sol{$i}{$j}{$k}\n";
	print "$i/$j/$k -> ". strftime("%F %T", localtime($sol{$i}{$j}{$k})) . " ". sunel($sol{$i}{$j}{$k}) ."\n";

      }
    }
  }
}

die "TESTING";

# Monte Carlo testing for "dice problem"

# roll 6-sided die 100 times and look at distribution of max frequency

for(1..999999) {
  %count = ();
  $n=0;

  # loop until jump out
  for (;;) {
    $n++;
    if (++$count{int(rand(6)+1)}==10) {last;}
  }

  print "$n\n";

}

# debug(sort {$count{$a} <=> $count{$b}} (keys %count));

die "TESTING";

open(A,"bzcat /home/barrycarter/BCGIT/db/KABQ-hourly.txt.bz2|");

while (<A>) {
  # get data
  /^(\d{4})\-(\d{2})\-(\d{2})\s+(\d{2}):(\d{2}):(\d{2}).*?\s+(.*?)$/;
  ($yr, $mo, $da, $hr, $mi, $se, $tempc) = ($1, $2, $3, $4, $5, $6, $7);

  # ignore null readings
  if ($tempc eq "null") {next;}

  # convert to days since 1 Jan 1901
  $day = julian_day($yr, $mo, $da)-julian_day(1901,1,1)+1;
  # add hr/mi/se
  $day += $hr/24 + $mi/1440 + $se/86400;

  # convert to 10ths for better accuracy (nah)
  # $day/=10;

  # data required for linear regress
  $sum_x2 += $day*$day;
  $sum_y2 += $tempc*$tempc;
  $sum_x += $day;
  $sum_y += $tempc;
  $sum_xy += $day*$tempc;
  $points++;

  # slope so far
  # THIS IS ABSOLUTELY AND COMPLETELY WRONG!
  $den = ($points*$sum_x2) - $sum_x**2;
  if ($den == 0) {next;}
  $num = $points*$sum_xy - $sum_x*$sum_y;
  $a = $num/$den;

print "$a\n";

$vals = << "MARK";

X2: $sum_x2
Y2: $sum_y2
X: $sum_x
Y: $sum_y
XY: $sum_xy
POINTS: $points

MARK
;

  debug("VALS: $vals");
  debug("SLOPE ($points): $a, NUM:$num, DEN: $den","");


}

debug("X: $x");

die "TESTING";

# triangle shading, approach 2

@points = ([0,0], [600,0], [300,600]);
@hues = (0, .825, .5);

for $i (0..600) {
  for $j (0..600) {
  }
}



die "TESTING";

# triangle shading

print "new\nsize 600,600\nsetpixel 0,0,0,0,0\n";

# hue of the bottom point, and the rightmostpoint
$bottomhue = .875;
$rightpointhue = 0.125;

for $y (1..600) {

  # "upside down" triangle
  $xleft = $y/2.;
  $xright = 600-$y/2.;

  # hue for left and right most pixels (assume third point is .25 hue)
  $lefthue = $bottomhue*$y/600;
  $righthue = $rightpointhue - ($rightpointhue-$bottomhue)*$y/600;
  debug("$y: $lefthue .. $righthue");

  for $x ($xleft..$xright) {

    # hue to be based on xy values later
    $hue = $lefthue + ($righthue-$lefthue)*($x-$xleft)/($xright-$xleft);
    # 255 color limit!
    $hue = int($hue*255)/255;

    $color = hsv2rgb($hue,1,1,"format=decimal");
    print "setpixel $x,$y,$color\n";
  }
}

die "TESTING";

$str="KYKN 302135Z AUTO 30022G26KT 10SM CLR A2997 RMK AO1,KYKN,2011-10-30T21:35:00Z,42.92,-97.37,,,300,22,26,10.0,29.970472,,,TRUE,TRUE,,,,,,,CLR,,,,,,,,VFR,,,,,,,,,,,,METAR,398.0";

$str=~s/,,/, ,/isg;

debug(csv($str));

die "TESTING";

# http://programmers.stackexchange.com/questions/116346/get-100-highest-numbers-from-an-infinite-list
# Using whole number to mean "natural number" (n>=1)

for (;;) {
  # new number
  $i = int(rand(2**31));

  # it's too low?
  if ($i < $min) {next;}

  

  debug($i);
}



die "TESTING";

# debug(unfold(recent_weather()));

for $i (recent_weather()) {
  %hash = %{$i};

  my(%newhash) = {};

  $newhash{id} = $hash{station_id};
#  ($newhash{x}, $newhash{y}) = to_mercator($hash{latitude}, $hash{longitude}, "order=xy");
  ($newhash{x}, $newhash{y}) = ($hash{longitude}, $hash{latitude});
  $newhash{label} = $hash{station_id};
  $f = $hash{temp_c}*1.8+32;
  $color = 5/6-($f/100)*5/6;
  $newhash{color} = hsv2rgb($color,1,1,"kml=1&opacity=40");
#  debug("COLOR: $newhash{color}");

  # cleanup
  for $j (sort keys %newhash) {$newhash{$j}=~s/[^a-z0-9 _\.\-\#]//isg;}

  push(@res, \%newhash);
}

debug(unfold(@res));

die "TESTING";

$file = voronoi_map(\@res);
print $file."\n";

die "TESTING";

# SVG thingy

print << "MARK";
<svg xmlns="http://www.w3.org/2000/svg" version="1.1"
 width="1000px" height="1000px"
 viewBox="0 0 1000 1000"
>
MARK
;

# cheating by using stuff you don't have access to, but just testing
for $i (split(/\n/, read_file("/home/barrycarter/.xearth-markers"))) {
  debug("I: $i");
  $i=~/^\s*(\S+)\s+(\S+)\s+\"(.*?)\"/;
  ($lat, $lon, $name) = ($1, $2, $3);
  if (abs($lat)>85) {next;}

  ($x, $y) = to_mercator($lat, $lon, "order=xy");
  $x*=1024;
  $y*=1024;
  debug("$x/$y");

  # this is wrong on purpose
  print qq%<text x="$x" y="$y" fill="red" style="font-size:15">$name</text>\n%;

}

print "</svg>\n";

die "TESTING";

# system("metafsrc2raw.pl -Fsynop_nws sample-data/SHIPS/sn.0040.txt | metaf2xml.pl -TSYNOP -x /tmp/test1.xml");

# system("metafsrc2raw.pl -Fbuoy_nws sample-data/DBUOY/sn.0040.txt | metaf2xml.pl -TBUOY -x /tmp/test2.xml");

# system("metafsrc2raw.pl -Fsynop_nws sample-data/SYNOP/sn.0040.txt | metaf2xml.pl -TSYNOP -x /tmp/test3.xml");

# system("metafsrc2raw.pl -Fmetaf_nws sample-data/METAR/sn.0038.txt | metaf2xml.pl -x /tmp/test4.xml");

# get lat/lon for metar and SYNOP stations
# NOTE: I have a metar.stations table, but it doesn't include SYNOP info alas

@res = sqlite3hashlist("SELECT * FROM stations","db/stations.db");

for $i (@res) {
  %hash = %{$i};
  # set lat/lon for METAR name
  $lat{$hash{metar}} = $hash{latitude};
  $lon{$hash{metar}} = $hash{longitude};
  # and synop station
  $lat{$hash{wmob}*1000+$hash{wmos}} = $hash{latitude};
  $lon{$hash{wmob}*1000+$hash{wmos}} = $hash{longitude};
}

$xml = new XML::Simple;
$data = $xml->XMLin("/tmp/test3.xml");
%data = %{$data};

# passed: test[12].xml

# for test1.xml, fields that look ok: id, lat/lon, cloudcover,
for $i ("metar", "synop", "buoy") {
  @reports = @{$data{reports}{$i}};
  if ($#reports>-1) {last;}
}


for $i (@reports) {
#  debug("I: $i",dump_var("I",\%{$i}));
  %hash = %{$i};
  %ret = weather_hash(\%hash);
#  debug("ALPHA: TIME:",dump_var("ALPHA",{%hash}));

  # debugging so I can sort results and check
  for $j (sort keys %ret) {debug("ALPHA: $j -> $ret{$j}");}

  push(@hashes, {%ret});
}

@queries = hashlist2sqlite(\@hashes, "weather");
warn "For tests, deleting first!";
unshift(@queries, "DELETE FROM weather");
unshift(@queries, "BEGIN");
push(@queries, "COMMIT");
write_file(join(";\n",@queries).";\n", "/tmp/playground.tmp");
system("sqlite3 /home/barrycarter/BCINFO/sites/DB/test.db < /tmp/playground.tmp");


die "TESTING";

srand(1044); # consistent randomness

for $i (1..10) {
  push(@x,rand(),rand());
}

@res = voronoi(\@x,"infinityok=1");
debug("RES",@res);
debug("A",dump_var("POLY",\@res),"B");

while (@x) {
  ($x, $y) = (shift(@x)*100, shift(@x)*100);
  print "setpixel $x $y\n";
}


die "TESTING";

for $i (1..10000) {
  %hash=();
  $hash{y} = rand()*180-90;
  $hash{x} = rand()*360-180;
  $hash{id} = ++$count;
  $hash{label} = "Point $count";
  $hash{color} = hsv2rgb(rand(),1,1,"kml=1");
  push(@l, {%hash});
}

# @poly = voronoi(\@l);

for $i (@l) {
  debug("I: $i");
}

die "TESTING";

=item metaf2xml

METAR:

$hash{temperature}{*} = same as SHIPS/SYNOP
$hash{QNH} = sea level pressure
$hash{sfcWind}{wind} = surface level winds, gusts in gustSpeed
$hash{obsTime}{timeAt} = observation time (hour/minute/day)
@{$hash{cloud}} = cloud cover (as list)
$hash{obsStationId}{id} = station ID

SHIPS AND SYNOP:

$hash{temperature}{air}{temp} = air temperature
$hash{temperature}{dewpoint} = dew point
$hash{temperature}{relHumid[1-4]} = relative humidity, computed in 4 diff ways
$hash{stationPosition} = station position
$hash{SLP} = sea level pressure (adjusted for altitude)
$hash{sfcWind} = surface level winds
$hash{synop_section3}{highestGust}{wind}{speed} = wind gust
$hash{obsTime}{timeAt} = observation time, day and hour only
$hash{totalCloudCover}{oktas} = cloud cover (in 8ths)
$hash{callSign}{id} = ship ID

BUOYS:

$hash{buoy_section1}{temperature}{air}{temp} = air temperature
$hash{buoy_section1}{temperature}{relHumid1} = relative humidity
$hash{stationPosition} = station position
$hash{buoy_section1}{SLP} = sea level pressure (adjusted)
$hash{buoy_section1}{sfcWind}{wind} = wind speed and direction
$hash{obsTime}{timeAt} = observation time (hours/minute/month/day/year-unit)
$hash{buoyId}{id} = buoy ID

=cut

# For SYNOP REPORTS:

# debug("ALL: $all");


die "TESTING";

chdir("/home/barrycarter/BCINFO/sites/DATA/");
print "Content-type: text/plain\n\n";
print join(",",overhead_sky())."\n";

# the latitude/longitude where the sun or moon is overhead
sub overhead_sky {
  ($ra, $dec) = position("sun", $now);
  $sdm = gmst($now);
  $dege = ($ra-$sdm)*15;
  ($lat, $lon) = ($dec, $dege);
  return ($lat, $lon);
}

die "TESTING";

$ship = read_file("/home/barrycarter/BCGIT/sample-data/SHIPS/sn.0005.txt");

# SHIP: BBXX, BUOY: ZZYY

while ($ship=~s/BBXX\s*(.*?)\s*\=//s) {
  $i = $1;
  $i=~s/\s+/ /isg;
  debug("OBS: $i");
  %rethash = parse_ship($i);
  debug("RET:", %rethash);
#  print "$rethash{latitude} $rethash{longitude}\n";
}

die "TESTING";

# all PWS in ABQ
open(A,"grep KNMALBUQ db/wstations.txt|");

while (<A>) {
  chomp;
  push(@cmd, "curl -s -o /tmp/pws-$_.xml 'http://api.wunderground.com/weatherstation/WXCurrentObXML.asp?ID=$_'");
}

write_file(join("\n",@cmd)."\n", "/tmp/pws-suck.sh");
system("parallel < /tmp/pws-suck.sh");

for $i (glob("/tmp/pws-*.xml")) {
  $data = read_file($i);
  %hash = ();

  while ($data=~s%<(.*?)>(.*?)</\1>%%) {$hash{$1}=$2};

  $time = str2time($hash{observation_time_rfc822});

  # wanted: data below
  debug("DATA: $hash{latitude}, $hash{longitude}, $hash{station_id}, $hash{temp_f}, $hash{observation_time_rfc822}, $time");

#  debug("HASH:",%hash);
}

# debug(@cmd);

die "TESTING";

# pipe stuff
$|=1;
my($pid) = open(A,"curl -sN http://test.barrycarter.info/bc-slow-cgi.pl|");

debug("PID: $pid");

while (<A>) {
  print "THUNK: $_\n";
  if (/5$/) {last;}
}

print "LOOP EXIT\n";
system("kill $pid");
close(A);
print "A CLOSED\n";

die "TESTING";

# Moon pos now
debug(position("moon"));

die "TESTING";

($az, $el) = radec2azel(13,-3.67594,35,-106, time());
debug("$az/$el");
($az, $el) = radec2azel(13,-3.67594,35,-106, time()+12*3600*364.2425/365.2425);
debug("$az/$el");



die "TESTING";

=item orbital_elements_mars

2455801.500000000 = A.D. 2011-Aug-28 00:00:00.0000 (CT)
 EC= 9.347044661513308E-02 QR= 1.381233968224160E+00 IN= 1.848831171264561E+00
 OM= 4.952474133890512E+01 W = 2.865779111208922E+02 Tp=  2455629.987808809150
 N = 5.240542156642154E-01 MA= 8.988168683134815E+01 TA= 1.005334943873345E+02
 A = 1.523650236296000E+00 AD= 1.666066504367840E+00 PR= 6.869518252872292E+02

EC=Eccentricity,e
QR=Periapsis distance,q(AU)
IN=Inclination w.r.t xy-plane,i(degrees)
OM=Longitude of Ascending Node,OMEGA,(degrees)
W=Argument of Perifocus,w(degrees)
Tp=Time of periapsis (Julian day number)
N=Mean motion,n(degrees/day)
MA=Mean anomaly,M(degrees)
TA=True anomaly,nu(degrees)
A=Semi-major axis,a(AU)
AD=Apoapsis distance(AU)
PR=Orbital period (day)

=cut


debug(radec2azel(10.4,9.7,35,-106));

die "TESTING";

write_wiki_page("http://wiki.barrycarter.info/api.php", "Hello", "`date`", "Comment", $bcwiki{user}, $bcwiki{pass});

die "TESTING";

($user, $pass) = ($geonames{user}, $geonames{pass});
debug(%geonames);

debug("USER: $user");

# get alt names (shouldn't require login)

$cmd = "curl 'http://www.geonames.org/servlet/geonames?srv=150&id=5551752&callback=getAlternateNames'";

# this just sets cookie
$cmd = qq%curl -b /tmp/cookies.txt -c /tmp/cookies.txt -e "http://www.geonames.org/login" -d "username=$user" -d "password=$pass" -d "rememberme=1" -d "srv=12" "http://www.geonames.org/servlet/geonames?"%;

($out, $err, $res) = cache_command($cmd, "age=3600");

# alt names get info: http://sws.geonames.org/5454711/about.rdf [but
# not real time?]

# now to modify it (this is state of NM, not city of Abq)
$cmd = "curl -b /tmp/cookies.txt -c /tmp/cookies.txt 'http://www.geonames.org/servlet/geonames?srv=151&&alternateNameId=0&id=5481136&alternateName=Land+of+Enchantment&alternateNameLocale=en&isOfficialName=false&isShortName=false'";

die "TESTING";

($out, $err, $res) = cache_command($cmd, "age=3600");

debug($out,$err,$res);

die "TESTING";

# write to a mediawiki installation

# authenticate
$pw = read_file("/home/barrycarter/bc-wiki-pw.txt");
chomp($pw);

# ($token) = cache_command("curl -b /tmp/curlcook.txt -c /tmp/curlcook.txt -H 'Cookie: my_wiki_session=a696f041bcc497ee4cfa201dc4c54e65' http://wiki.barrycarter.info/api.php -d 'action=login&lgname=Barry+Carter&lgpassword=$pw&lgtoken=fadd1feaf1c21187769619ec1e2fa0f9&format=xml'", "age=3600");

($token) = cache_command("curl -b /tmp/curlcook.txt -c /tmp/curlcook.txt http://wiki.barrycarter.info/api.php -d 'action=login&lgname=Barry+Carter&lgpassword=$pw&lgtoken=5df347b68a72fd2185010321debac1b1&format=xml'", "age=3600");

# obtain token

($token) = cache_command("curl -b /tmp/curlcook.txt -c /tmp/curlcook.txt 'http://wiki.barrycarter.info/api.php?action=query&prop=info&intoken=edit&titles=Test%20Page&format=xml'", "age=3600");

debug("TOKEN: $token");

# write with trivial token

($res) = cache_command("curl -b /tmp/curlcook.txt -c /tmp/curlcook.txt 'http://wiki.barrycarter.info/api.php' -d 'action=edit&title=Test&text=article%20content&token=424f1be5e8cb9bdd008fc55b5f337758%2B%5C'", "age=3600");

debug($res);

die "TESTING";

# read EL ELM files

$all = read_file("/home/barrycarter/BCGIT/EL/startmap.elm");

# the .e3d chunks start here (length 64+80=144)
$e3d = hex("947c");

$x = substr($all,$e3d,144);

for ($i=0; $i<=length($all); $i+=144) {
  $x = substr($all,$e3d+$i,144);
  $file = substr($x,0,64);
  $file=~s/\0//isg;
  debug("X: $x", "FILE: $file");
}

die "TESTING";

# solve the EL HE/SR problem

for $i (1..1000) {
  $he = $i/41*16;
  $sr = $i/41*5;
  debug("$i: $he HE, $sr SR");
}

die "TESTING";

# find all el-services.net bots (does not work for other bots)

($res) = cache_command("curl http://bots.el-services.net/", "age=3600");

while ($res=~s/<a class="arrow" href="(.*?)">//) {
  push(@bots, $1);
}

for $i (@bots) {
  debug("BOT: $i");
  ($res) = cache_command("curl http://bots.el-services.net/$i", "age=3600");
  debug("RES: $res");

  # find the location (ugly)
  $res=~s%<tr class="botinfo-location"><td class="botinfo-leftmargin"></td><td class="botinfo-location" colspan="2">(.*?)</td></tr>%%is;
  $loc = $1;
  # break into map, coords
  $loc=~/^\s*(.*?)\s*\[(\d+\s*\,\d+)\]/;
  ($map, $coord) = ($1,$2);
  debug("LOC: $map/$coord");

  # find the selling section (ugly)
  $res=~s/<div id="selling">(.*?)<div id="purchasing">//s;
  ($sell, $buy) = ($1, $res);

  # items
  while ($sell=~s%<td class="public2">(.*?)</td>\s*<td class="public_right">(.*?)</td>\s*<td class="public_right">(.*?)</td>%%is) {
    print join("\t", "SELL", $i, $1, $2, $3)."\n";
  }

  while ($res=~s%<td class="public2">(.*?)</td>\s*<td class="public_right">(.*?)</td>\s*<td class="public_right">(.*?)</td>%%is) {
    print join("\t", "BUY", $i, $1, $2, $3)."\n";
  }


}

die "TESTING";


create_el_tz_file();

=item create_el_tz_file()

Creates a timezone file for Eternal Lands. Use "zic" (as root) to
compile it and then "setenv TZ Test/ELT" to use it. You must create a
"TEST" subdirectory in /usr/share/zoneinfo or the equivalent

=cut

sub create_el_tz_file {
  # current EL time
  my($now) = time();

  # update every minute for the next year (serious overkill?)
  for ($i=$now; $i<=$now+60*24*365.2425; $i+=60) {
    debug("I: $i");
    my(@elt) = unix2el($i);
    debug("$i:", @elt);
  }

}

die "TESTING";

@foo = sendmail("bob\@clown.com", "test20110701-2\@barrycarter.info", "This is my subject", "This is my life");

debug("FOO:",@foo);

die "TESTING";


# TODO: this will NOT catch things that redirect to Desert Pines

$res = cache_command("fgrep -R '[[Desert Pines]] at' /usr/local/etc/wiki/EL-WIKI.NET", "age=3600");

debug(read_file($res));

die "TESTING";

# RPC-XML

# get password
$pw = read_file("/home/barrycarter/bc-wp-pwd.txt"); chomp($pw);

debug(xmlrpc("http://wordpress.barrycarter.info/xmlrpc.php", "mt.getRecentPostTitles", ["x", "admin", $pw, 10]));

die "TESTING";

debug(xmlrpc("http://wordpress.barrycarter.info/xmlrpc.php", "blogger.getRecentPosts", ["x", "x", "admin", $pw, 10]));

die "TESTING";

# using raw below so i can cache and stuff

$req=<<"MARK";
<?xml version="1.0"?><methodCall>
<methodName>mt.getRecentPostTitles</methodName>
<params>
<param><value>x</value></param>
<param><value>admin</value></param>
<param><value>$pw</value></param>
<param><value><int>10</int></value></param>
</params>
</methodCall>
MARK
;

write_file($req,"/tmp/rpc1.txt");
system("curl -o /tmp/rpc2.txt --data-binary \@/tmp/rpc1.txt http://wordpress.barrycarter.info/xmlrpc.php");
# system("curl -o /tmp/rpc2.txt --data-binary \@/tmp/rpc1.txt http://joomla.barrycarter.info/xmlrpc/index.php");

die "TESTING";

# update existing page attempt
# info about my blog
$pw = read_file("/home/barrycarter/bc-wp-pwd.txt"); chomp($pw);
$author = "barrycarter";
$wp_blog = "wordpress.barrycarter.info";

sub post_to_wp_test {
  my($body, $options) = @_;
  my(%opts) = parse_form($options);
  defaults("live=0");

  # timestamp (in ISO8601 format)
  my($timestamp) = strftime("%Y%m%dT%H:%M:%S", gmtime($opts{timestamp}));

my($req) =<< "MARK";

<?xml version="1.0"?>
<methodCall> 
<methodName>wp.editPage</methodName> 
<params>

<param><value><string>x</string></value></param>

<param><value><string>9410</string></value></param>

<param><value><string>$opts{author}</string></value></param> 

<param><value><string>$opts{password}</string></value></param>

<param> 
<struct> 

<member><name>categories</name> 
<value><array><data><value>$opts{category}</value></data></array></value> 
</member> 

<member>
<name>description</name> 
<value><string><![CDATA[$body]]></string></value>
</member> 

<member> 
<name>title</name> 
<value>$opts{subject}</value> 
</member> 

<member> 
<name>dateCreated</name> 
<value>
<dateTime.iso8601>$timestamp</dateTime.iso8601> 
</value> 
</member> 

</struct> 
</param> 

<param><value><boolean>$live</boolean></value></param> 

</params></methodCall>
MARK
;

  write_file($req,"/tmp/request");
  debug($req);

  if ($globopts{fake}) {return;}

  # curl sometimes sends 'Expect: 100-continue' which WP doesn't like.
  # The -H 'Expect:' below that cancels this
  system("curl -H 'Expect:' -o /tmp/answer --data-binary \@/tmp/request http://$opts{site}/xmlrpc.php");

  debug($req);

  debug(read_file("/tmp/answer"));
}

die "TESTING";

print "Content-type: text/html\n\n";

print `fortune`;

exit(0);

die "TESTING";

push(@INC,"/usr/local/lib");

=item box_option_value($p0, $v, $p1, $p2, $t1, $t2)

Computes the fair value of a box option, given $p0, the current price
of the underlying, $v, the volatility, $p1-$p2 the price range of the
box option, and $t1-$t2, the time interval of the box option in years

=cut

sub box_option_value {
  my($p0, $v, $p1, $p2, $t1, $t2) = @_;


}




die "TESTING";

$data = read_file("data/moonfakex.txt");
$data2 = read_file("data/moonfakey.txt");
@l = nestify($data);
@l = @{$l[0]};
@l2 = nestify($data2);
@l2 = @{$l2[0]};

for $i (@l) {
  @j = @{$i};
  $j[0]=~s/\*\^(\d+)/e+$1/isg;
  push(@xvals, $j[0]);
  push(@yvals, $j[1]);
}

for $i (@l2) {
  @j = @{$i};
  $j[0]=~s/\*\^(\d+)/e+$1/isg;
  push(@xvals2, $j[0]);
  push(@yvals2, $j[1]);
}

$now = time();

for $i (0..48) {
  $time = 1306281600+$i*3600;

  debug(position("moon",$time));
#  debug(position("sun",$time));

  next;



  $xcoord = hermione($time, \@xvals, \@yvals);
  $ycoord = hermione($time, \@xvals2, \@yvals2);

  $ra = atan2($ycoord,$xcoord)/$PI*180;
  if ($ra<0) {$ra+=360;}

  # just to match math
  $dec = (sqrt($xcoord**2+$ycoord**2)-$PI)/$PI*180;

  print "$ra $dec\n";
}

die "TESTING";

$xvals = [1,2,3,4,5,6];
$yvals = [1,8,27,64,125,216];

@xvals=@{$xvals};
@yvals=@{$yvals};

for $i (2..5) {

  # slopes in this, next, prev interv
  $sf = $yvals[$i+1]-$yvals[$i];
  $st = $yvals[$i]-$yvals[$i-1];
  $sp = $yvals[$i-1]-$yvals[$i-2];

  # second derv = average of forward and backward change
  $sd = ($sf-$sp)/2;

  # if this interval is (-.5,+.5), this is quadratic
  $x = 0;
  $test = $sd/2*$x*$x + ($yvals[$i+1]-$yvals[$i])*$x +
 (4*$yvals[$i]+4*$yvals[$i+1] - $sd)/8;
  debug("$x -> $test");
 


}


die "TESTING";

debug(hermite(2.5, $xvals, $yvals));

for $i (100..600) {
  $x = $i/100;
  $h = hermite($x, $xvals, $yvals);
  debug("A",$yvals[floor($x)],$yvals[floor($x+1)],$yvals[floor($x+2)]);
  $hp = h00($x-floor($x))*$yvals[floor($x-1)] +
    h01($x-floor($x))*$yvals[floor($x)];

  debug("HP:", $h-$hp);

#  print $x," ", $h-$hp,"\n";
#  print $x," ", $h-$hp,"\n";
}

die "TESTING";

for $i (0..60) {
  ($ra,$dec) = position("sun", 1305936000+86400*$i);
  print "$dec\n";
}

die "TESTING";


# NOTE: graphs of the hermite functions look fine, so its got to be
# the way I'm taking the slope

for $i (0..100) {
  print h11($i/100)."\n";
}

die "TESTING";

for $i (0..100) {
  print hermite(3+$i/100, $xvals, $yvals);
  print "\n";
}

die "TESTING";

# debug(position("moon"));

debug(position("sun", 1305936000));

die "TESTING";

%points = (
 "Albuquerque" => "35.08 -106.66",
 "Paris" => "48.87 2.33",
 "Barrow" => "71.26826 -156.80627",
 "Wellington" => "-41.2833 174.783333",
 "Rio de Janeiro" => "-22.88  -43.28"
);

$EARTH_CIRC = 4.007504e+7;
$r1 = $EARTH_CIRC/2;

# the dividing circle between two points is a circle w/ center on earth

die "Command below will not work, need API key";

system("cp /usr/local/etc/sun/gbefore.txt /home/barrycarter/BCINFO/sites/TEST/playground.html");

open(A, ">>/home/barrycarter/BCINFO/sites/TEST/playground.html");

$hue = -1/8;

for $i (sort keys %points) {
  $hue += 1/8;
  for $j (sort keys %points) {
    if ($i eq $j) {next;}

    # don't double do
    if ($done{$i}{$j}) {next;}
    $done{$j}{$i} = 1;

    # vector between cities
    ($lat1, $lon1) = split(/\s+/, $points{$i});
    ($lat2, $lon2) = split(/\s+/, $points{$j});

    ($x1, $y1, $z1) = sph2xyz($lon1, $lat1, 1, "degrees=1");
    ($x2, $y2, $z2) = sph2xyz($lon2, $lat2, 1, "degrees=1");
    ($x3, $y3, $z3) = ($x1-$x2, $y1-$y2, $z1-$z2);

    debug("$x3 $y3 $z3");

    # convert back to polar
    ($theta, $phi) = xyz2sph($x3, $y3, $z3, "degrees=1");
    debug("$theta, $phi");

    # fillcolor
    $col = hsv2rgb($hue,1,1);

  print A << "MARK";

pt = new google.maps.LatLng($phi,$theta);

new google.maps.Circle({
 center: pt,
 radius: 10018760,
 map: map,
 strokeWeight: 1,
 strokeColor: "$col",
 fillOpacity: 0,
 fillColor: "#ff0000"
});

MARK
;
  }
}

system("/bin/cat /usr/local/etc/sun/gend.txt >> /home/barrycarter/BCINFO/sites/TEST/playground.html");

sub xyz2sph {
  my($x,$y,$z,$options) = @_;
  my(%opts) = parse_form($options);

  my($r) = sqrt($x*$x+$y*$y+$z*$z);
  my($phi) = asin($z/$r);
  my($theta) = atan2($y,$x);

  if ($opts{degrees}) {
    return $theta*180/$PI, $phi*180/$PI, $r;
  } else {
    return $theta, $phi, $r;
  }
}

die "TESTING";

# final hermite testing pre-production

for $i (1..10) {
  push(@xvals,$i);
  push(@yvals,$i*$i);
}

debug(@xvals,@yvals);

for ($i=1; $i<=10; $i+=.01) {
  print "$i -> ". hermite($i, \@xvals, \@yvals) ."\n";
}

die "TESTING";

# hermite testing
# <h>No hermits were harmed during these tests</h>

@xvals = @{$l[0][0][2]};
@yvals = @{$l[0][0][3]};

# convert mathematica to perl form
map(s/\*\^/e+/, @xvals);
map(s/\*\^/e+/, @yvals);

# 3.5107128*^9 is April 2nd at 6am is our test case

debug("ALPHA");
debug(hermite(3510755800, \@xvals, \@yvals));

# debug("X",@xvals,"Y",@yvals);

die "TESTING";

# TODO: cache like crazy!
# moonxyz.txt contains 10 arrays

die "TESTING";

# read_mathematica("data/sunxyz.txt");

$all = read_file("data/sunxyz.txt");

while ($all=~s/[\{\[]([^\{\}\[\]]*)[\}\]]/f2($1)/eisg) {}

# debug($all);
# debug($res[441]);
# debug($res[431]);
# debug($res[400]);
# debug($res[367]);
# debug($res[25]);

# debug("RES",@res);
$all=~s/\s//isg;
debug($all);

@res = f3($all);

debug("RES",unfold(@res));

sub f3 {
  my(@ret);
  my($val) = @_;
  for $i (split(/\,\s*/,$val)) {
    if ($i=~/RES(\d+)/) {
      push(@ret, [f3($res[$1])]);
    } else {
      push(@ret, $i);
    }
  }

  return @ret;
}


# NOTES: only reads (possibly nested) lists, uses static var, returns ref

sub read_mathematica {
  my($file) = @_;
  if ($static{mathematica}{$file}) {return $static{mathematica}{$file};}
  my($data) = read_file($file);

  # only what's between the {}
  $data=~m%(\{.*?\})%isg || warnlocal("No braces: $data");

  # convert mathematica's {} to []
  $data=~tr/\{\}/\[\]/;
  # remove bad chars
  $data=~s/\`//isg;

  debug($data);

  my(@l) = eval($data);
  debug($@);

  debug(@l);

}



die "TESTING";

# use Math::MatrixReal;

# my($a) = Math::MatrixReal->new_random(5, 5);

debug($a);


die "TESTING";

# TESTS
# order is irrelevant
# print convert_time(1001, "%M minutes %S seconds")."\n";
# print convert_time(1001, "%S seconds %M minutes")."\n";

# just in seconds
# print convert_time(1001, "%S seconds")."\n";

# hours and seconds (no minutes)
# print convert_time(3600*7+60*4, "%H hours, %S seconds")."\n";
# with minutes, but weird order
# print convert_time(3600*7+60*4, "%M minutes, %H hours, %S seconds")."\n";

# larger value testing
# below doesn't agree with calendar because of leap year
# print convert_time(time(), "%Y years, %m months, %d days")."\n";
print convert_time(time(), "%Y years, %m months, %d days, %H hours, %M minutes, %S seconds")."\n";
# print convert_time(time(), "%U weeks")."\n";
# print convert_time(time(), "%S seconds plus %U weeks")."\n";
# print convert_time(time(), "%S seconds")."\n";

die "TESTING";

# use PDL::Transform::Cartography;
#        $a = earth_coast();
#        $a = graticule(10,2)->glue(1,$a);
#        $t = t_mercator;
#        $w = pgwin(xs);
#        $w->lines($t->apply($a)->clean_lines());

die "TESTING";


# debug(to_mercator(-85,0,"order=xy"));

debug(from_mercator(0,0));


sub from_mercator {
  my($x, $y, $options) = @_;
  my(%opts) = parse_form($options);
  return atan(sinh($y)), $x*360-180;
}


=item project($lay, $lox, $proj, $dir)

Projects latitude/longitude $lay/$lox to xy coordinates for the
projection $proj; if $dir is 1, does the reverse and converts xy
coordinates to latitude/longitude.

$lax: the latitude or y-coordinate
$loy: the longitude or x-coordinate

(note the order of the xy coordinates are reversed, so that latitude
matches y and longitude matches x)

Note: center of map is 0,0; x and y values range from -0.5 to +0.5

NOT YET DONE!

=cut

sub project {
  my($lay, $lox, $proj, $dir) = @_;

  # this is an ugly way to do this (if/elsif/else)

  # Specifically, google's mercator projection
  if ($proj=~/^merc/) {
    if ($dir) {
      return (atan(sinh($lay)), $lox*360);
    } else {
      return (-1*(log(tan($PI/4+$lay/180*$PI/2))/2/$PI), $lox/360);
    }
  }
}

die "TESTING";

@pts = (35.08, -106.66, 48.87, 2.33, 71.26826, -156.80627, -41.2833,
174.783333, -22.88, -43.28);

debug("ALPHA");
debug(unfold(voronoi(\@pts,"infinityok=1")));

die "TESTING";


exit 1;

die "TESTING";

$all="{this, {is, some, {deeply, nested}, text}, for, you}";

# $all = read_file("data/sunxyz.txt");

# could try to match newline, but this is easier
$all=~s/\n/ /isg;

# <h>It vaguely annoys me that Perl doesn't require escaping curly braces</h>
while ($all=~s/{([^{}]*?)}/handle($1)/seg) {
  $n++;
  debug("AFTER RUN $n, ALL IS:",$all);
}

debug(*$all);

debug("ALL",$all);

debug("ALL",@{$all});


sub handle {
  my($str) = @_;
  debug("Handling $str");
  return \{split(/\,\s*/, $str)};
  debug("L IS:",@l);
  debug("Returning ". \@l);
  return \@l;
}

die "TESTING";

$all="{this, {is, some, {deeply, nested}, text}, for, you}";

while ($all=~s/\{([^{}]*?)\}/f($1)/seg) {
  debug("ALL: $all");
}

sub f {
  my($x) = @_;
  return \$x;
}

debug(*$all);

# sub f {return \{split(",",$_[0])};}

# debug(unfold(@res));


die "TESTING";

debug(project(1,0,"mercator",1));


die "TESTING";

# reading Mathematica interpolation files

$all = read_file("sample-data/manytables.txt");

while ($all=~s/InterpolatingFunction\[(.*?)\]//s) {
  $func = $1;

  # get rid of pointless domain
  # {} are not special to Perl?!
  $func=~s/{{(.*?)}}//;

  # xvals
  $func=~s/{{(.*?)}}//s;
  $xvals = $1;
  debug("XV: $xvals");

  # split and fix
  @xvals=split(/\,|\n/s, $xvals);

  for $i (@xvals) {
    $i=~s/(.*?)\*\^(\d+)/$1*10**$2/iseg;
  }

  debug($func);

}

