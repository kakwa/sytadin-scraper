sytadin-scraper
===============

[![Join the chat at https://gitter.im/kakwa/sytadin-scraper](https://badges.gitter.im/Join%20Chat.svg)](https://gitter.im/kakwa/sytadin-scraper?utm_source=badge&utm_medium=badge&utm_campaign=pr-badge&utm_content=badge)

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
* to search nodes:
   sytadin-scraper [-h] -S '<node name>'
* to query sytadin:
   sytadin-scraper -s '<start node>' -e '<end node>' [-v '<inter node>'] [-l]

Command line utility to query www.sytadin.fr

arguments:
    -h, --help              : display this help
    -l, --light             : light output 
           (format '<traject>|<reliability>' (optional)
    -S, --search <node name>: search the nodes
           matching '.*<node name>.*' 
           in available nodes (case insensitive)
    -s, --start <start node>: node where we start 
    -e, --end <end node>    : node where we end
    -v, --via <inter node>  : intermediate node (optional)

> sytadin-scraper -S clamart
List of matching nodes:
* 'Le Petit Clamart (N118xA86)'

> ./bin/sytadin-scraper -s 'Plaisance' \
    -e 'Evry (A6xN104)' -v 'Janvry (A10xN104)'  
Plaisance to Evry (A6xN104) via Janvry (A10xN104): 35mn (44%)
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

# get the result page of sytadin (raw html)
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


[![Bitdeli Badge](https://d2weczhvl823v0.cloudfront.net/kakwa/sytadin-scraper/trend.png)](https://bitdeli.com/free "Bitdeli Badge")

