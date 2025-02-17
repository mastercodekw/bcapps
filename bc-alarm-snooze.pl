#!/bin/perl

# An alarm with a snooze button(s) using yad

# TODO: add logging?

# Usage: $0 message

# Options:
# --width: width of popup
# --fontsize: displayed font size

# TODO: this is bad because Perl script keeps running until snooze or
# cancel is hit

# TODO: maybe allow more options

# Sample yad: yad --button=1:1 --button=2:2 --button=3:3

require "/usr/local/lib/bclib.pl";

# default option values

defaults("width=1600&fontsize=20");

# TODO: this might be bad-- maybe required quoted arg[0]

my($msg) = join(" ", @ARGV);

# this maps exit values to button names (note: 0 = done)

# some of these time values are important only to me

# flipping 0m and DONE so hitting space won't kill program

my(@times) = ("0m", "DONE", "1m", "2m", "3m", "4m", "5m", "6m", "7m", "10m",
	      "15m", "30m", "45m", "1h", "90m", "2h", "4h", "8h");

my(@buttons);

for $i (0..$#times) {
  debug("I: $i");
  push(@buttons, "--button $times[$i]:$i");
}

debug(@buttons);

my $buttons = join(" ", @buttons);

debug("BUTTONS: $buttons");

# --fontname doesn't work w/ text entry, this is the hack

$msg2 = qq%<span font="$globopts{fontsize}">$msg</span>%;

# undecorated is a real pain, so changing 10/12/19

# my($cmd) = qq%yad --no-escape --text='$msg2' --text-align='center' 
#            --width=$globopts{width} 
#            $buttons  --buttons-layout='spread' --sticky --undecorated%;

my($cmd) = qq%yad --no-escape --text='$msg2' --text-align='center' 
            --width=$globopts{width} 
            $buttons  --buttons-layout='spread' --sticky%;

$cmd=~s/\n/ /sg;

debug($cmd);

my($out, $err, $res) = cache_command2($cmd);

# TODO: would be REALLY nice to get this as stdout, like in zenity, or
# to run a program when button is pressed instead of waiting above

debug("OUT: $out, ERR: $err, RES: $res");

# Perl returns $res vals * 256

$res>>=8;

# blank value disallowed, DONE value disallowed

if ($times[$res] eq "DONE") {exit(0);}

# if user hits space (or 0m for some reason), just bring message back up again)

# convert to time and send to at

$times[$res]=~s/m/ minutes/;
$times[$res]=~s/h/ hours/;

# TODO: this still generates stdout so redirecting to /dev/null
open(A, "|at -M 'now + $times[$res]' > /dev/null");

# TODO: better way to do this?

print A "$0 $msg";

close(A);

# TODO: setting button tags to non-numeric runs command (but not working?)
