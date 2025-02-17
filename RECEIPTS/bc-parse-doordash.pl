#!/bin/perl

# parses doordash order history

require "/usr/local/lib/bclib.pl";

my($data, $fname) = cmdfile();

# this actually splits ratings separately from orders, but ok with that

my(@list) = split(/<a class=\".*?\"/, $data);

for $i (@list) {


  # order number
  unless ($i=~s%href="https://www.doordash.com/orders/(\d+)/"%%s) {next;}
  my($order) = $1;

  # name of restaurant
  unless ($i=~s%<span>(.*?)</span>%%s) {warn "No restaurant name found";}
  my($rest) = $1;

  # time of pickup/delivery and number of items
  unless ($i=~s%<div><div>(.*?)</div><div>(.*?)</div>%%is) {
    warn "No time or #items found";
  }

  my($time, $items) = ($1, $2);

  # shorten phrases

  $time=~s/Delivered: /D /;
  $time=~s/Order for Pickup: Ready by /P /;

  debug("BEFORE: $rest");
  $rest=~s/&amp;/&/g;
  debug("AFTER: $rest");

  # nicely(?) formatted string

  my($print) = " "x80;

  # TODO: this not really portable

  substr($print, 69, length($items)) = $items;
  substr($print, 42, length($time)) = $time;
  substr($print, 10, length($rest)) = $rest;
  substr($print, 0, length($order)) = $order;

  print "$print\n";

#  print "$order $rest\t$time\t$items\n";

#  print join("\t", $order, $rest, $time, $items),"\n";
  
  debug("ORDER: $order/$rest/$time/$items\nREST: $i");

}

# debug("DATA: $data");

