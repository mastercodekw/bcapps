#!/bin/perl

# Computes implicit volatility of NADEX binary options. Options:
#  --under=x: assume underlying price is x, do not call forex_quote
#  --nopost: don't post results to my blog, just calculate them
#  --noimage: don't put image in post to blog

push(@INC, "/home/barrycarter/BCGIT/");
require "bclib.pl";

$now = time(); #<h>for all good men to come to the aid of their country</h>

# read parity from arg (format: eg, USDCAD)
($parity) = @ARGV;

# I have 3 different formats for parity: USD-CAD, USD/CAD,
# USDCAD. Create vars for each of them
$parity=~/^([A-Z]{3})([A-Z]{3})$/||die("BAD PARITY: $parity");
($paritysource,$paritydest) = ($1,$2);
$paritydash = "$paritysource-$paritydest";
$parityslash = "$paritysource/$paritydest";

# special case: NADEX version of USD-JPY is USD-YEN
if ($parity eq "USDJPY") {$paritydash="USD-YEN";}

# currently, only USDCAD generates a page on my site
unless ($parity eq "USDCAD") {$globopts{nopost}=1;}

# tmp file depends on parity (USDCAD was original, special)
if ($parity eq "USDCAD") {
  $tmpfile = "/tmp/nadex.m";
} else {
  $tmpfile = "/tmp/nadex.m.$parity";
}

# TODO: add theta, delta, vega, etc, based on calculated volt(?) [done
# for bid, now for ask]

# HACK: TODO: this only works if underlying prices change slowly: if
# there's a big change <h>(say USDJPY dropping 300 points in
# minutes)</h>, this program yields inaccurate results

# TODO: standardize USD-CAD USD/CAD USDCAD convention

# obtain hash containing inverse std normal
# TODO: this is hideously ugly, because it doesn't cache AND I need a more
# uniform way of converting mathematica output to Perl
# NOTE: I chose NOT to use nestify() here, it would've made things worse?
$invnor = read_file("/home/barrycarter/BCGIT/data/inv-norm-as-list.txt");
# mathematica precision oddness + other cleanup
$invnor=~s/\`[\d\.]+//isg;
# NOTE: yes, I should backslash {} below, but it's cool that I don't have to
$invnor=~s/[{}]//isg;
$invnor=~s/\s+/ /isg;
# and hashify
%invnor = split(/\,\s*/, $invnor);

# Obtain NADEX quotes and FOREX quotes
%hash = nadex_quotes($paritydash);

unless (%hash) {die "No data, stopping";}

# NADEX runs on Eastern time
# TODO: this may break when we stop daylight time(?)
$ENV{TZ} = "EST";

open(A,">$tmpfile.new");
print A "nadex={\n";

# Table header
# expdatetime, strike, bid, ask, bidvol, askvol, pricetime, underatpricetime

$str = << "MARK";

Do not rely on this information. I update this table "manually", there
are no automated upates. Does not include intraday options. Other
parities not available on request. Void where prohibited. Not actually
the Beatles. Generated by bc-nadex-vol.pl (<a href="https://github.com/barrycarter/bcapps/blob/master/bc-nadex-vol.pl">source code</a>).

<table class="sortable" border><tr>
<th>Expiration</th>
<th>Strike</th>
<th>Bid<br>(hover for Greeks)</th>
<th>Ask<br>(no Greeks yet)</th>
<th>Volt<br>(Bid)</th>
<th>Volt<br>(Ask)</th>
<th>Exp Time<br>(hours)</th>
<th>Pips<br>Away</th>
<th>Last Updated</th>
<th>Underlying<br>Price</th>
<th>Notes</th>
</tr>

MARK
;

debug(unfold(%hash));

for $strike (sort keys %{$hash{$parity}}) {
  for $exp (sort keys %{$hash{$parity}{$strike}}) {
    debug("DOING: $parity/$strike/$exp");

    # already expired?
    if ($exp < $now) {
      warnlocal("IGNORING EXPIRED OPTION: $strike/$exp");
      next;
    }

    %k = %{$hash{$parity}{$strike}{$exp}};
    ($bid, $ask, $updated) = ($k{bid}, $k{ask}, $k{updated});
    debug("UPDATED: $updated");

    # obtain FOREX quote when this NADEX quote was last updated
    my($under);
    if ($globopts{under}) {
      $under = $globopts{under}
    } else {
      debug("$parityslash price at $updated...");
      $under = forex_quote($parityslash, $updated);
    }

    # output for Mathematica (doesn't really need all of these, but...)
    if ($parity eq "USDJPY") {
      $printstrike = $strike/100;
      $printunder = $under/100;
    } else {
      $printstrike = $strike;
      $printunder = $under;
    }

    print A "{$printstrike, $exp, $bid, $ask, $printunder, $updated},\n";

    # logdiff + exptime (seconds)
    unless ($under) {die "Unable to obtain price for $parity at $updated";}
    debug("$strike / $under");
    $logdiff = log($strike/$under);
    $exptime = $exp - $updated;

    debug("BID: $bid, ASK: $ask");

    # bid and ask represent what values of standard normal dist?
    $bidsn = $invnor{$bid/100};
    $asksn = $invnor{$ask/100};

    # TODO: fix this (.50 implies meaningless volatility, but should
    # note that, not avoid it)
    if (!$bidsn || !$asksn) {
      warnlocal("BID OR ASK 50 or 0/100, VOL NOT COMPUTED");
      next;
    }

    debug("BIDSN: $bidsn, ASKSN: $asksn");

    # normalize SD for actual expiration time
    $bidsd = $logdiff/$bidsn;
    $asksd = $logdiff/$asksn;

    # and adjust to yearly
    $bidsdy = $bidsd*sqrt(365.2425*86400/$exptime);
    $asksdy = $asksd*sqrt(365.2425*86400/$exptime);

    # round and fix sign
    $bidsdy = sprintf("%0.2f", abs($bidsdy*100));
    $asksdy = sprintf("%0.2f", abs($asksdy*100));

    # notes
    $notes="&nbsp;";

    if ($bid<=50 && $ask>=50) {
      $notes="BID/ASK crosses 50<br>volt meaningless";
    }

    # compute (bid) volatility using new function I created
    debug("bin_volt($bid, $strike, ($exp-$updated)/86400/365.2425, $under)");
    $newvol = bin_volt($bid, $strike, ($exp-$updated)/86400/365.2425, $under);
    # and the greeks (experimental on bid only for now)
    # $val is obviously redundant and just a  check
    ($val, $delta, $theta, $vega) = greeks_bin($under, $strike, ($exp-$updated)/86400/365.2425, $newvol);
    $title = sprintf("DELTA/PIP: %0.4f, THETA/HOUR: %0.4f, VEGA/.01: %0.4f",
		     $delta*100, $theta*100, $vega*100);
    debug("GREEKS: $val/$delta/$theta/$vega");

    debug("NEWVOL: $newvol");

    # printing table here just to have some output; real work is above
    $str.= "<tr>\n";
    $str.= strftime("<td>%F<br>%H:%M:%S ET</td>\n", localtime($exp));
    $str.= "<td>$strike</td>\n";
    $str.= "<td title='$title'>$bid</td>\n";
    $str.= "<td>$ask</td>\n";
    $str.= "<td>$bidsdy</td>\n";
    $str.= "<td>$asksdy</td>\n";
    $str.= sprintf("<td>%0.2f</td>\n", ($exp-$updated)/3600);
    $str.= sprintf("<td>%d</td>\n", 10000*($strike-$under));
    $str.= strftime("<td>%F<br>%H:%M:%S ET</td>\n", localtime($updated));
    $str.= "<td>$under</td>\n";
    $str.= "<td>$notes</td>\n";
    $str.= "</tr>\n";

    debug("$strike/$exp/$bid/$ask/$updated/$under");
    debug("$logdiff/$exptime/$bidsn/$asksn");
    debug("BIDSD: $bidsd, ASKSK: $asksd");
    debug("FINAL: $bidsdy/$asksdy");
  }
}

$str.="</table>\n";

unless ($globopts{noimage}) {

# attempt to generate good looking table
# TODO: arguably the most hideous code I've ever written

$str2 = $str;
$str2=~s/^.*<table/<table/si;
write_file($str2, "/tmp/nadex-vol.html");
system("html2ps -s 0.8 /tmp/nadex-vol.html 1> /tmp/nadex-vol.ps");
system("convert -trim -density 200x200 /tmp/nadex-vol.ps /tmp/nadex-vol.png");
system("base64 /tmp/nadex-vol.png > /tmp/nadex-vol.b64");
$b64 = read_file("/tmp/nadex-vol.b64");
$b64=~s/\s//isg;

# TODO: ugly ugly ugly!
$str=~s%horrible.%horrible (<a href='data:image/png;base64,$b64'>here's how it should look</a>)%si;

}

# info about my blog
# TODO: put this somewhere where any prog can get it, but not in
# bclib.pl, since other people don't want it

$pw = read_file("/home/barrycarter/bc-wp-pwd.txt"); chomp($pw);
$author = "barrycarter";
$wp_blog = "wordpress.barrycarter.info";

# Make current time part of subject, and also actual timestamp
$subject= strftime("NADEX USDCAD Implied Volatility(s) (%F %H:%M:%S ET)", localtime($now));

print A "}\n";

close(A);

# this only happens if/when program doesn't die
system("mv -f $tmpfile $tmpfile.old; mv $tmpfile.new $tmpfile");

# for consistency
if ($tmpfile eq "/tmp/nadex.m") {system("cp $tmpfile $tmpfile.$parity");}

# update on blog (unless --nopost)
unless ($globopts{nopost}) {
  post_to_wp($str, "action=wp.editPage&site=$wp_blog&author=$author&password=$pw&postid=9410&wp_slug=nadex&live=1&subject=$subject&timestamp=$now");
}

