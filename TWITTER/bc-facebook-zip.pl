#!/bin/perl

# does what bc-twitter-zip.pl does but for facebook

# TODO: this really belongs in a FACEBOOK dir, not a TWITTER dir

use Archive::Zip;
require "/usr/local/lib/bclib.pl";
$ENV{TZ} = "UTC";

# read in the given file

my($file) = @ARGV;
my($zip) = Archive::Zip->new();
$zip->read($file);

# find data/js/user_details.js, mtime, and contents (for username)

# my($data) = $zip->memberNamed("index.htm");
# fb changes to index.html ~ Apr 2018
my($data) = $zip->memberNamed("index.html");
my($mtime) = strftime("%Y%m%d.%H%M%S", gmtime($data->lastModTime()));
my($contents) = $data->contents();

debug("CONTENTS: $contents");

# this is ugly in case FB decides other links

unless ($contents=~s%https?://www.facebook.com/([^\?].*?)\"%%) {die "NO USERNAME";}

my($sn) = $1;

# print the recommended action

# print "ln -s '$file' $sn-$mtime.zip\n";

warn("CODE HAS RECENTLY CHANGED, DO SANITY CHECK");

if (-f "$sn-$mtime.zip") {
  print "$sn-$mtime.zip already exists\n";
  exit(-1);
}

print "mv '$file' $sn-$mtime.zip\n";

debug("DATA: $data", $data->lastModTime(), $data->contents());

# debug("MEM", $zip->members());

# debug("ZIP:", var_dump("ZIP", $zip));



