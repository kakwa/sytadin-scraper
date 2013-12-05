sytadin-scraper
===============

www.sytadin.fr traffic info scraper written in perl.

License
-------

sytadin-scraper is released under MIT.

Dependancies
------------

* WWW::Mechanize
* Getopt::Long

Command line
------------

```bash
> sytadin-scraper -h
usage: 
   sytadin-scraper [-h] -S '<node name>' #search node
   sytadin-scraper -s '<start node>' -e '<end node>' [-v '<inter node>'] [-l]

Command line utility to query www.sytadin.fr

args:
    -h: display this help
    -S <node name>: search the name matching '.*<node name>.*' 
        in available nodes (case insensitive)
    -s <start node>: node where we start 
    -e <end node>: node where we end
    -l: light output (format '<traject>|<reliability>' (optional)
    -v <inter node>: intermediate node (optional)

> sytadin-scraper -S clamart
List of matching nodes:
* 'Le Petit Clamart (N118xA86)'

> sytadin-scraper -s 'Le Petit Clamart (N118xA86)' \
         -e 'Evry (A6xN104)' -v 'Janvry (A10xN104)'
Le Petit Clamart (N118xA86) to Evry (A6xN104) via Janvry (A10xN104): 23mn (61%)
```

Library
-------

```perl
use SYTADIN::Query;


# search nodes (case insensitive)
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

# basic parsing of the html page 
# to get the traject_time and the reliability
my %info = SYTADIN::Query::scan_result_page($page);

print "traject: '$start' to '$end' via '$via':\n";
print "* traject time: $info{'traject_time'}\n";
print "* reliability: $info{'reliability'}%\n";
print "\n";

# another search
my $start = 'Achères (N184xD30)';
my $end   = 'Corbeil (A6xN104)';
my $via   = 'Janvry (A10xN104)';

# direct access to the data (same as query_sytadin + scan_result_page)
my %info2 = SYTADIN::Query::get_time_reliability($start, $end, $via);

print "traject: '$start' to '$end' via '$via':\n";
print "* traject time: $info2{'traject_time'}\n";
print "* reliability: $info2{'reliability'}%\n";
```
