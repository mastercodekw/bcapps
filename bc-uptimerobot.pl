#!/bin/perl

# given an API key on the command line that works with uptimerobot.com:

# https://api.uptimerobot.com/v2/getMonitors?api_key=[argument]

# report errors to ~/ERR/

# TODO: if result file is empty or doesnt have any status, that's an error

# -nocurl: dont actually query uptimerobot API (useful for testing)

require "/usr/local/lib/bclib.pl";

dodie('chdir("/var/tmp/uptimerobot")');

my(@errors);

unless ($#ARGV == 0) {die("Usage: $0 apikey");}

# TODO: caching is really only for testing

# per https://uptimerobot.com/api/ adding some optional parameters as
# of 27 Mar 2022

my($out, $err, $res) = cache_command("curl -X POST -L -d \47all_time_uptime_ratio=1&all_time_uptime_durations=1&logs=1&response_times=1&alert_contacts=1&mwindows=1&ssl=1&custom_http_headers=1&custom_http_statuses=1&timezone=1&api_key=$ARGV[0]\47 https://api.uptimerobot.com/v2/getMonitors | tee api-results-$ARGV[0].txt", "age=3600");

# TODO: annoyingly, the API doesn't return a "time of test"

my($json) = JSON::from_json($out);

debug(var_dump("json", $json));

for $i (@{$json->{monitors}}) {

  # per https://uptimerobot.com/api/ 2 means up

  unless ($i->{status} == 2) {
    push(@errors, "nagios.uptimerobot.$i->{friendly_name} down");
  }

}

write_file_new(join("\n",@errors)."\n", "/home/user/ERR/uptimerobot-$ARGV[0].err");

