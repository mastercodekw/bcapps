#!/bin/perl

# I use Alpine, an ancient mail program, and have/had its mailcap for
# value "text/html" set to '/bin/firefox --new-tab "%s"';
# unfortunately, the file %s sometimes doesn't exist which causes
# firefox errors like "Firefox can't find the file at
# /tmp/img--42364.htm"; I even tried putting a "sleep 1" in front of
# the firefox which helped, but didnt solve the problem; this script
# waits for %s to exist before opening firefox

# --profile: bring up this specific profile in firefox

require "/usr/local/lib/bclib.pl";

my($url) = @ARGV;

# xmessage("GOT $url", 1);

# copy $url since alpine kills it once this script exists

# TODO: don't use constant file name here

my($out, $err, $res) = cache_command("cp $url /tmp/bahhp.html");

# this is what I did previously, if it doesnt work, I will tweak it

if ($globopts{profile}) {$extra = "-P $globopts{profile}";}

($out, $err, $res) = cache_command("/home/user/bin/firefox $extra --new-tab file:///tmp/bahhp.html");



