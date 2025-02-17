#!/bin/perl

# gives radii for objects known to SPICE but that do not have radii in SPICE

# (trying to give radii for all objects in small-body-db.csv.bz2
# yields to kernel out of memory error)

require "/usr/local/lib/bclib.pl";

# load list of NAIF ids known to SPICE

for $i (split(/\n/, read_file("/home/user/BCGIT/ASTRO/bc-naif-ids-known-to-spice.txt"))) {

    if ($i=~m/^\s*$/ || $i=~m/^\#/) {next;}
    $inspice{$i} = 1;
}

existing_spice_radii();

open(A, "bzcat /home/user/SPICE/KERNELS/small-body-db.csv.bz2|");

$headers = <A>;

@headers = split(/\,/, $headers);

# fields we want: spkid, full_name, diameter, extent, ?albedo?

print "\\begindata\n";

while (<A>) {

    chomp;

    my(@data) = split(/\,/, $_);
    my(%hash) = ();

    for $i (0..$#headers) {$hash{$headers[$i]} = $data[$i];}

    if ($hasradii{$hash{spkid}}) {next;}

    unless ($inspice{$hash{spkid}}) {next;}

    if ($hash{extent}) {

	unless ($hash{extent}=~/^"?\s*([\d\.]+)\s*x\s*([\d\.]+)\s*x\s*([\d\.]+)\s*"?$/) {
	    warn "BAD EXTENT: $hash{extent}";
	    next;
	}

	debug("EXTENT: $1 $2 $3");

	# radii are half of diameters
	print "BODY$hash{spkid}_RADII = (",$1/2," ",$2/2," ",$3/2,")\n";


    } elsif ($hash{diameter}) {

	# divide diameter by 2 for radii
	my($rad) = $hash{diameter}/2;

	print "BODY$hash{spkid}_RADII = ($rad $rad $rad)\n";
    } else {
	# TODO: should I worry more about this?
	debug("BADLINE: $_");
	for $i (keys %hash) {debug("BADLINE ($i) -> $hash{$i}");}
    }
}


#    for $i (sort keys %hash) {debug("$i: $hash{$i}");}

#    for $i ("spkid", "full_name", "diameter", "extent") {
#	debug("$i: $hash{$i}");
#    }

# TODO: this function should NOT be in two places
# copied from bc-extract-naif-ids.pl

sub existing_spice_radii {

    my($data) = read_file("/home/user/SPICE/KERNELS/pck00010.tpc");
    my($indata) = 0;

    for $i (split(/\n/, $data)) {

	if ($i=~/^\s*\\begindata\s*$/) {
	    $indata = 1;
	    next;
	}

	if ($i=~/^\s*\\begintext\s*$/) {
	    $indata = 0;
	    next;
	}

	unless ($indata) {next;}

	unless ($i=~/BODY(\d+)_RADII/i) {next;}

	$hasradii{$1} = 1;
    }
}


