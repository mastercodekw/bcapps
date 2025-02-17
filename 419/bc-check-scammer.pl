#!/bin/perl

# Confirms that all gmail/aim addresses I've pinged (not necessarily
# scammers) are on my buddy list. I will politely talk to them and
# then either whitelist them for non-scammers or lead them along if
# scammers. Note these are NOT verified scammers, just ones I'm saying hi to.

require "/usr/local/lib/bclib.pl";

# TODO: make sure to whitelist innocents who I have de-buddied to
# avoid bugging them

# TODO: currently only gmail, do more!

# current list of buddies
# (am I overdoing it with pure Unix commands?)
@buds = `fgrep -A 2 "<buddy account='leonard.zeptowitz\@gmail.com/" /home/barrycarter/.purple/blist.xml | fgrep '<name>'`;

# list of gmail addresses I've pinged
@pinged = `cut -d' ' -f 2 /home/barrycarter/BCGIT/419/pinged.txt | fgrep gmail.com`;

for $i (@pinged) {
  # cleanup slightly
  chomp($i);

  if ($i=~m/mailto:(.*?)\"/) {$i = $1;}

  $i=~s/^.*?>(.*?)<.*?/$1/isg;

}

debug("PINGED:",@pinged);

# cleanup list of buds (newline needed to match @pinged)
for $i (@buds) {$i=~s%.*<name>(.*?)</name>.*%$1%s;}

@left = minus(\@pinged, \@buds);

# new scheme: simply replace all the buds w new list
for $i (@buds,@pinged) {$all{$i}=1;}

unless (@left) {print "gmail buddy list is up to date\n"; exit;}

# print join("\n",sort keys %all),"\n";

# print in "list editing" format for GAIM/Pidgin
for $i (sort keys %all) {
  print "\t\t\t<buddy screenname='$i'/>\n";
}

# print "Add or whitelist the following:\n\n";
# print join("\n",@left),"\n\n";
