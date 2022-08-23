#!/usr/bin/perl
use strict;
use warnings;
use feature qw(say);
use LWP::UserAgent;
use Getopt::Long;

my $warning;
my $critical;
my $o_url;
my $data;

#cu phap: ./check_useronline_whos -u [id->whos.amung.us] -w [warning] -c [critical] 

Getopt::Long::Configure ("bundling");
GetOptions(
  'u=s'  => \$o_url,      'url=s'  => \$o_url,
  'w=s'  => \$warning, 'warning=s' => \$warning,
  'c=s'  => \$critical, 'critical=s' => \$critical
);

my %ERRORS = ('OK'=>0,'WARNING'=>1,'CRITICAL'=>2,'UNKNOWN'=>3);

my $ua = LWP::UserAgent->new;
my $url =  "http://whos.amung.us/sitecount/$o_url";
my $req = HTTP::Request->new(GET => $url);
my $resp = $ua->request($req);
if ($resp->is_success) 
    {
        my $message = $resp->decoded_content;
		$data = int($message);
    }
else 
    {
        print "UNKNOWN - HTTP GET error: ", $resp->code, $resp->message;
        exit $ERRORS{'UNKNOWN'};
    }
if($data >= $critical ) 
	{
		say "CRITICAL: $data online";
		exit $ERRORS{'CRITICAL'};
	}
elsif($data >= $warning) 
	{
		say "WARNING: $data online";
		exit $ERRORS{'WARNING'};
	}
else 
	{
		say "OK: $data online";
		exit $ERRORS{'OK'};
	}
