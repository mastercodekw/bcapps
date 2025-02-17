#!/bin/perl

# starts as a copy of bc-vsop2math.pl but now for maxima

# Converts VSOP87 barycentric coordinates to something Mathematica can
# use, just for fun (since DE430 is more accurate)

# NOTE: T is the number of Julian millenia since J2000.0 (JDE-2451545)/365250

require "/usr/local/lib/bclib.pl";

# "E" for barycentric

my($all, $fname) = cmdfile();

my(%coeffs);
my($coeff, $varno);

for $i (split(/\n/,$all)) {

#    debug("I: $i");

  # does this line have a coefficient (if so, record it and move on)

#  if ($i=~/VARIABLE\s+(\S+)\s+.*\*T\*\*(\d+)/) {

    if ($i=~/VARIABLE\s+(\S+)\s+.*\*T\*\*?(\d+)/) {
	debug("FOUND VAR LINE: $i");
	($varno, $coeff) = ($1,$2);
	next;
    }

  # only the last three fields matter
  # TODO: figure out what the other fields mean
  # Thanks to: http://www.caglow.com/info/compute/vsop87
  my(@fields) = split(/\s+/, $i);
  # rationalize to avoid Mathematica roundoff silliness
  my($a, $b, $c) = map($_=rationalize($_), @fields[-3..-1]);

  # push to appropriate array
#   push(@{$coeffs[$varno][$coeff]}, "$a*Cos[$b + $c*t]");
  push(@{$coeffs{$varno}{$coeff}}, "$a*Cos[$b + $c*t]");
}

debug("COEFFS",unfold(\%coeffs));

die "TESTING";

# there is no var0
for $varno (1..$#coeffs) {
  my(@sum);
  for $coeff (0..$#{$coeffs[$varno]}) {
    debug("$varno/$coeff");
    my($terms) = join("+\n", @{$coeffs[$varno][$coeff]});
    debug("TERMS: $terms");
    push(@sum, "($terms)*t^$coeff");
  }

  my($sum) = join("+\n", @sum);
  print "var${varno}[t_] = $sum;\n";
  # 1 AU = 149597870.7 km by definition
  # fvar is in Unix days, and uses km, not AU
  print "fvar${varno}[d_] = var${varno}[(d-10957.5000000000)/365250]*149597870.7;\n"
}

# TODO: move to lib!

=item rationalize($r)

Returns a rationalized version of the real number $r

=cut

sub rationalize {
  my($r) = @_;

  # no decimal? return as is
  unless ($r=~/^(.*?)\.(.*?)$/) {return $r;}
  my($whole,$frac) = ($1,$2);
  return "$whole$frac/".(10**length($frac));
}
