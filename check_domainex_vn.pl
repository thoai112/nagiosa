#!/usr/bin/perl

use POSIX;
use strict;
use warnings;
use feature qw(say);
use LWP::UserAgent;
use JSON qw(from_json);
use Date::Parse;
use Time::Local;

#cu phap: ./check_domainex_vn  [tenmien] [warning] [critical] 

my ($url) = @ARGV;
my $warning = int($ARGV[1]);
my $critical = int($ARGV[2]);

my $server_endpoint = "https://whois.inet.vn/api/whois/domainspecify/$url";
my($pyear,$pmon,$pday,$cyear,$cmon,$cday,$countdown);

my %ERRORS = ('OK'=>0,'WARNING'=>1,'CRITICAL'=>2,'UNKNOWN'=>3);

my $ua = LWP::UserAgent->new;
my $req = HTTP::Request->new(GET => $server_endpoint);
my $resp = $ua->request($req);

if ($resp->is_success)
        {
                my $message = $resp->decoded_content;
        		my $fromjson = from_json($message);
                if ($fromjson->{'code'} == "0")
                {
                        my $date = $fromjson->{'expirationDate'};
                        my ($d,$m,$y) = $date =~ m|(\d+)-(\d+)-(\d+)|;
                        ($pyear,$pmon,$pday) = ((int($y)-1900),(int($m)-1),int($d));
                        ($cyear,$cmon,$cday) = ((localtime())[5],(localtime())[4],(localtime())[3]);
                        my $paid_time = mktime(0,0,0,$pday,$pmon,$pyear);
                        my $current_time = mktime(0,0,0,$cday,$cmon,$cyear);
                        my $margin = $paid_time - $current_time;
                        $countdown = $margin/86400;
                }
                else
                {
                        print "UNKNOWN - Ten mien chua duoc dang ki ". "\n";
                        exit $ERRORS{'UNKNOWN'};
                }
        }
else
        {
    print "UNKNOWN - HTTP GET error: ", $resp->code, $resp->message;
        exit $ERRORS{'UNKNOWN'};
        }

if($warning < $countdown)
        {
                say "OK: $countdown days left";
                exit $ERRORS{'OK'};
        }
elsif(($critical  < $countdown)&&($countdown <= $warning))
        {
                say "WARNING: $countdown days left";
                exit $ERRORS{'WARNING'};
        }
elsif($countdown <= $critical)
        {
                say "CRITICAL: $countdown days left";
                exit $ERRORS{'CRITICAL'};
        }
else
	{
		say "UNKNOWN";
		exit $ERRORS{'UNKNOWN'};
	}

