#!/bin/perl

# Another "useful only to me" program (although you can make it useful
# to you by using bc-parse-qfx.pl, MySQL, and categorizing your
# expenses), this program tells me how much I am spending on various
# things, my cash flow, etc.

# TODO: add available credit from credit card

# bc-budget-2.pl is a copy of bc-budget.pl that uses an SQL view to
# get most (but not all) of its information

# NOTE: for values that are essentially hashes, Im adopting the ffmpeg
# paradigm of using colons, not equal signs, to separate keys from
# values

# NOTE TO SELF: cash total is dodgy since I dont record all
# transactions and didnt record initial cash back to the beginning of
# time

# This program gets most of its info from command line options

# --income=amount: income per month

# --fixed=cat1:val1,cat2:val2,cat3:val3: treat category spending as
# fixed per month

# --extra=name1:amt1,name2:amt2,name3:amt3,...: extra money I have (or
# owe if negative) that doesn't appear in my databases (the names are
# cosmetic ways of tagging these amounts)

# --bankrename=bank1:newname,bank2:newname,... : when seeing bank1 or
# bank2, rename them to newname. This is useful when a bank account
# changes numbers and allows you to treat both accounts as a single
# account; it also allows for "vanity" names for banks

# --exclcat=cat1,cat2,cat3,...: exclude categories from consideration (eg,
# refunded transactions, transactions that move money from one account
# to another, categories that I no longer use + expect no future
# charges for, etc)

# --exclacct=acct1,acct2,acct3,...: exclude these accounts from consideration

# --days=n: how far back to go when making calculations (default = 365)

# --ignore=n: ignore the past n days (I dont check my accounts daily,
# so data for the last 14 or so days could be incomplete, making it
# look like I spend less money than I actually do)

require "/usr/local/lib/bclib.pl";

# 1 year period ending two weeks ago
defaults("days=379&ignore=14");

# convert options that are list values to hashes

my(%exclacct) = list2hash(split(/\,/,$globopts{exclacct}));
my(%exclcat) = list2hash(split(/\,/,$globopts{exclcat}));

# read options that are hashes (as hashes)

# this hideous code splits globopts{fixed} using commas and colons,
# resulting in a list that Perl will auto-convert to a hash when
# assigned to a hash (TODO: should I avoid language-specific hacks
# like this?)

my(%fixed) = split(/[\,|\:]\s*/, $globopts{fixed});
my(%bankrename) = split(/[\,|\:]\s*/, $globopts{bankrename});
my(%extra) = split(/[\,|\=]\s*/, $globopts{extra});

# the "current" time (last day were not ignoring)

# TODO: this should probably round to the nearest day or something
# (but since the db only keeps values to the day level, this may not
# be an issue)

my($now) = time()-$globopts{ignore}*86400;

# get all transactions from this view

my(@res) = mysqlhashlist("SELECT * FROM bc_budget_view ORDER BY date DESC", 
			 "test", "user");

# ignore the first empty result
shift(@res);

# get per diem totals for category, and keep track of what things are
# categories

my(%perDiemTotal, %isCategory, %acctTotal, %date, $grandTotal);

for $i (@res) {

  # added new fields to bc_budget_view (by creating new tables and
  # redefining the view), so I can tell if account is live/obsolete
  # and combine account numbers into a single name

  # if this account is obsolete, we ignore it entirely

  if ($i->{status} eq "OBSOLETE") {next;}

  # count all transactions for non-excluded accounts to get acctTotal
  # and grandTotal (= liquid net worth) (this includes positive
  # amounts and excluded categories)

  # $i->{name} combines account number changes, replacing "account"

  $acctTotal{$i->{name}} += $i->{amount};
  $grandTotal += $i->{amount};

  # age of transaction (but never less than 1 to avoid div by 0 or negative)

  my($daysago) = max(1,floor(($now - str2time($i->{date}))/86400));

  # record what day it was this many days ago

  $date{$daysago} = $i->{date};

  # if transaction is significantly old, do nothing else
  # or too new

  if ($daysago > $globopts{days} || $daysago < $globopts{ignore}) {next;}

  # is this transaction interesting to us?

  unless (isValidTransaction($i)) {next;}

  debug("VALIDCAT: $i->{category}");

  # record that this is a category

  $isCategory{$i->{category}} = 1;

  debug("DAYSAGO: $daysago");

  $perDiemTotal{$daysago}{$i->{category}} += $i->{amount};

}

# TODO: don't actually print these here

for $i (sort keys %acctTotal) {

  # round off value

  $acctTotal{$i} = round2($acctTotal{$i}, 2);

  # TODO: dont really skip here

  if ($acctTotal{$i} == 0) {next;}

  print "$i $acctTotal{$i}\n";
}

print "GRANDTOTA: $grandTotal\n";


# cumulative totals

my(%cumTotal);

# go through all days, all categories, even those without transactions

my($bulkTotal);

for $i (1..max(keys(%perDiemTotal))) {

  for $j (sort keys %isCategory) {

    # if this is a fixed value category, tweak $perDiemTotal
    # TODO: there are definitely better ways to do this

    if ($fixed{$j}) {$perDiemTotal{$i}{$j} = $fixed{$j}/$DAYSPERMONTH;}

    $cumTotal{$j} += $perDiemTotal{$i}{$j};

    my($avg) = $cumTotal{$j}/$i*$DAYSPERMONTH;

    $bulkTotal += $perDiemTotal{$i}{$j};

    print "$date{$i} $i $j $avg ($perDiemTotal{$i}{$j})\n";

  }

  my($avgTotal) = $bulkTotal/$i*$DAYSPERMONTH;

  print "AVGTOTAL: $avgTotal\n";

  debug("GAMMA");
  debug(unfold(\%cumTotal));

}


die "TESTING";

debug("BETA");

debug(max(keys(%perDiemTotal)));

debug(keys %perDiemTotal);

debug(unfold(\%perDiemTotal));

# program specific subroutine to determine if transaction is valid

sub isValidTransaction {

  my($hashref) = @_;

  # bad category
  if ($exclcat{$hashref->{category}}) {return 0;}

  # TODO: reconsider this
  # positive amount

  if ($hashref->{amount} > 0) {return 0;}

  return 1;

}














die "TESTING";

# if no start date set, set it to unix 0 time

defaults("start=1970-01-01");

# TODO: maybe warn if no arguments/options, normal invokation is via alias

# the current time

my($now) = time();

# compute how far back to go

my($maxdays) = floor(($now - str2time($globopts{start}))/86400 + 1);

# don't print if not set

unless ($globopts{start} eq "1970-01-01") {
  # TODO: print this elsewhere
#  print "MAXDAYS: $maxdays\n";
}

# convert options that are list values to hashes

my(%exclbank) = list2hash(split(/\,/,$globopts{exclbank}));
my(%exclcat) = list2hash(split(/\,/,$globopts{exclcat}));
my(%exclcard) = list2hash(split(/\,/,$globopts{exclcard}));

my(%fixed) = split(/[\,|\=]\s*/, $globopts{fixed});

# same for extra


# compute total fixed spending

my($fixedPerMonth) = 0;

for $i (keys %fixed) {$fixedPerMonth += $fixed{$i};}

my($fixedPerDay) = $fixedPerMonth/$DAYSPERMONTH;

debug("FIXED: $fixedPerMonth .... $fixedPerDay");

# TODO: subroutinize?

# how much do I currently owe on my credit cards

# TODO: should really get mysqlval into bclib.pl instead of ugly
# extraction here

# NOTE: breaking this down by card is theoretically unnecessary, but
# helps with debugging

# NOTE: credcardstatements is obsolete, so the '2' below is correct

# TODO: rounding here or should i round later?

# TODO: this amount is slightly wrong because it includes gift cards
# and other weirdnesses; however, it is fairly close

my(@ccowed) = mysqlhashlist("SELECT whichcard, ROUND(SUM(amount),2) AS
total FROM credcardstatements2 GROUP BY whichcard", "test", "user");

# compute total

my($ccowed) = 0; 

for $i (@ccowed) {
  if ($exclcard{$i->{whichcard}}) {next;}
  debug("CC: $i->{whichcard}, $i->{total}");
  $ccowed += $i->{total};
}

# now, bankstatements (my bank balance, hopefully positive)

my(@bankbals) = mysqlhashlist("SELECT bank, ROUND(SUM(amount),2) AS
total FROM bankstatements GROUP BY bank", "test", "user");

# and total

my($bankbal) = 0;

debug("EXCL", %bankexcl);

for $i (@bankbals) {
  debug("BANK: $i->{bank}, $i->{total}");
  if ($exclbank{$i->{bank}}) {next;}
  $bankbal += $i->{total};
}

# total extra

my($extra) = 0;

for $i (keys %extra) {$extra += $extra{$i};}

debug("TOTAL EXTRA: $extra");

my($liquidAssets) = $bankbal + $ccowed + $extra;

debug("LA: $liquidAssets");

# TODO: don't print here

# print "CC Bal: $ccowed\n";
# print "Bn Bal: $bankbal\n";

# TODO: currently assuming I have 0 cash on hand (pretty close to
# true), but try to compute cashtotal accurately later

# this mega query selects all my bank, credit, and cash transactions
# reverse ordered by date

# I don't need all fields, but they are useful for debugging

# TODO: could make the below a view for more flexibility

# TODO: the 'comments' are multiline and not useful at least for now

# TODO: neither HEX nor QUOTE work on strings with ctrl-ms in them

# TODO: my version of MySQL doesn't support TO_BASE64 which might work

# NOTE: in cashstatements, positive = money I give to others

my($query) = << "MARK";

SELECT amount, date, description AS merchant, category, comments, "bank", oid 
 FROM bankstatements UNION
SELECT amount, date, merchant, category, comments, "credit", oid 
 FROM credcardstatements2 UNION
SELECT -amount, date, merchant, category, comments, "cash", oid
 FROM cashstatements
ORDER BY date DESC
MARK
;

my(@res) = mysqlhashlist($query, "test", "user");

# TODO: if --start isn't set, find the oldest day and use that

my(%catperday);

for $i (@res) {

  # TODO: there are many many reasons to not count a transaction, add
  # them below

  # categories I ignore
  if ($exclcat{$i->{category}}) {next;}

  # categories that I treat as fixed
  if ($fixed{$i->{category}}) {next;}

  # don't include positive amounts (TODO: maybe allow later)
  if ($i->{amount} > 0) {next;}

  # find high value transactions which I perhaps should exclude or something
  if ($i->{amount} < -500) {
    debug("HIGH VALUE:", unfold($i));
  }

  # number of days ago for this transaction
  my($daysago) = floor(($now - str2time($i->{date}))/86400);

  # to avoid division by 0
  if ($daysago == 0) {$daysago = 1;}

  # TODO: in theory, could just break out of loop here (since sorted)

  if ($daysago > $maxdays) {next;}

#  print "$daysago $i->{category} $i->{amount}\n";
  debug("ALPHA: $daysago $i->{category} $i->{amount}");

  # record spending per category per day
  $catperday{$daysago}{$i->{category}} += $i->{amount};

  # TODO: this is just temporary
  $totalSpending{$daysago} += $i->{amount};

}


# TODO: just for fun temporary

my($incomePerDay) = $globopts{income}/$DAYSPERMONTH;

my $cumTotal, $avg;

for $i (sort {$a <=> $b} keys %totalSpending) {

  $cumTotal += $totalSpending{$i};

  # includes fixed daily expenses
  $avg = $cumTotal/$i + $fixedPerDay;

  # years I have left given money I have
  my($yearsLeft) = -$liquidAssets/($avg+$incomePerDay)/$DAYSPERMONTH/12;

  print "$i $yearsLeft\n";

  debug("BETA: DAYS: $i, TOTAL: $totalSpending{$i}, CUM: $cumTotal, AVG: $avg, YL: $yearsLeft");
}

die "TESTING";

# go through days in order (most recent first)

# TODO: this loop is fixed for now, but make it depend on --start

my(%runningTotal);

for $i (0..366) {

  debug("I: $i");

  # TODO: this may NOT be a total list of categories (ie, fixed amounts)

  my(%dayhash) = %{$catperday{$i}};

  debug("DAYHASH <HASH>", %dayhash, "</HASH>");

  for $j (sort keys %dayhash) {

    debug("J: $j");

    $runningTotal{$j} += $dayhash{$j};

#    debug("DAYHASH: $dayhash{$i}{$j}");

    debug("$i, $j, $runningTotal{$j}");
  }


}  

# debug(@res);

# debug(var_dump("catsperday", \%catperday));
