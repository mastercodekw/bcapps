#!/usr/bin/perl

# Split an mbox style mailbox into individual messages (useful for
# checking dupes)

# --nofrom: do not include the "from space" line when splitting
# emails; useful for comparing emails that are identical on a server
# but whose timestamp is different when downloaded (eg, via getmail)

require "/usr/local/lib/bclib.pl";

$file=shift||die("Usage: $0 file");
open(A,$file)||die("Can't open $file, $!");
# will use Perl magic that 000000++ is 000001
$i="0"x12;

while (<A>) {
  # for alpine compatibility split lines must also have date
  if (/^From / && /(Sun|Mon|Tue|Wed|Thu|Fri|Sat)/) {
    $i++;
    close(B);
    open(B,">mail.$i");
    if ($globopts{nofrom}) {next;}
  }
  print B $_;
}

close(B);


