#!/bin/perl

# Wait until a given process has stopped + then report
# --nox: do not send xmessage, just end
# --message: add this to standard message
# --sms: send sms in addition to xmessage
# --email: sent email to specified address

require "/usr/local/lib/bclib.pl";

my($pid) = @ARGV;
unless ($pid) {die "Usage: $0 pid|string";}
defaults("message=No message");
my($stringq) = 0;

# if argument is string, use pgrep
unless ($pid=~/^\d+$/) {
  $stringq = 1;
  my(@procs) = `pgrep $pid`;

  if ($#procs==-1) {die "No procs matching: $pid";}
  if ($#procs>0) {warn ">= 2 procs match: $pid; only watching first";}
  $pid = $procs[0];
  chomp($pid);
}

# determine process name
my(@arr) = `ps -wwwp $pid`;
$arr[1]=~s/^\s+//;
my(@proc) = split(/\s+/, $arr[1]);
my($name) = $proc[3];

if ($stringq) {print "'$ARGV[0]' matches: $name ($pid)\n";}

while (!system("ps -p $pid > /dev/null")) {sleep 5;}

# TODO: allow for email customization
if ($globopts{email}) {
  sendmail("alert\@barrycarter.info", "alert\@barrycarter.info", "$pid $name done: $globopts{message}", "Process complete");
}

# TODO: --nox fails with --sms because bc-alarm.pl xmessages anyway!
unless ($globopts{nox}) {xmessage("'$pid ($name) done: $globopts{message}'",1);}

if ($globopts{sms}) {
  debug("bc-alarm.pl now $pid $name done: $globopts{message}");
  # TODO: I shouldnt have to give a path here!
  system("$bclib{githome}/bc-alarm.pl now $pid $name done: $globopts{message}");
}

