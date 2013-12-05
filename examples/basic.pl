#!/usr/bin/env perl

use SYTADIN::Query;


#search nodes (case insensitive)
print "List of matching nodes:\n";
foreach (SYTADIN::Query::search_node('achères')){
 print "* '$_'\n";
};
print "\n";

my $start = 'Le Petit Clamart (N118xA86)';
my $end   = 'Corbeil (A6xN104)';
my $via   = 'Janvry (A10xN104)';

#get the result page of sytadin (raw html)
my $page = SYTADIN::Query::query_sytadin($start, $end, $via);

#basic parsing of the html page to get the traject_time and the reliability
my %info = SYTADIN::Query::scan_result_page($page);

print "traject: '$start' to '$end' via '$via':\n";
print "* traject time: $info{'traject_time'}, reliability: $info{'reliability'}%\n";
print "\n";

#another search
my $start = 'Achères (N184xD30)';
my $end   = 'Corbeil (A6xN104)';
my $via   = 'Janvry (A10xN104)';

#direct access to the data (same as query_sytadin + scan_result_page)
my %info2 = SYTADIN::Query::get_time_reliability($start, $end, $via);

print "traject: '$start' to '$end' via '$via':\n";
print "* traject time: $info2{'traject_time'}, reliability: $info2{'reliability'}%\n";
