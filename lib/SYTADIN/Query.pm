package SYTADIN::Query;

our $VERSION = '0.0.2';

=head1 NAME

SYTADIN::Query - Package to get traject time and reliability on www.sytadin.fr

=head1 SYNOPSIS

use SYTADIN::Query;

 #search nodes (case insensitive)
 print "List of matching nodes:\n";
 foreach (SYTADIN::Query::search_node('achères')){
  print "* '$_'\n";
 };
 print "\n";
 
 my $start = 'Le Petit Clamart (N118xA86)';
 my $end   =  'Corbeil (A6xN104)';
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
 my $end   =  'Corbeil (A6xN104)';
 my $via   = 'Janvry (A10xN104)';
 
 #direct access to the data (same as query_sytadin + scan_result_page)
 my %info2 = SYTADIN::Query::get_time_reliability($start, $end, $via);
 
 print "traject: '$start' to '$end' via '$via':\n";
 print "* traject time: $info2{'traject_time'}, reliability: $info2{'reliability'}%\n";

=cut

use SYTADIN::Nodes;
use warnings;
use strict;
use WWW::Mechanize;

sub query_sytadin{
    my $start = shift;
    my $end   = shift;
    my $via   = shift;

    #we get the corresponding ids of the nodes
    my $id_start = $SYTADIN::Nodes::Nodes{"$start"};
    my $id_end   = $SYTADIN::Nodes::Nodes{"$end"};
    my $id_via   = $SYTADIN::Nodes::Nodes{"$via"};


    #we initialize the form
    my $mech = WWW::Mechanize->new();
    my $url = 'http://www.sytadin.fr/gp/itineraire.do?stat=false';

    $mech->agent_alias( 'Windows IE 6' );

    #we get the form
    $mech->get( $url );

    #apparently we need to set some cookies
    $mech->cookie_jar->set_cookie(0,'arrivee',$id_end,'/','www.sytadin.fr');
    $mech->cookie_jar->set_cookie(0,'depart',$id_start,'/','www.sytadin.fr');
    $mech->cookie_jar->set_cookie(0,'mode','court','/','www.sytadin.fr');
    $mech->cookie_jar->set_cookie(0,'via1',$id_via,'/','www.sytadin.fr');
    $mech->cookie_jar->set_cookie(0,'workflow','via2','/','www.sytadin.fr');
    $mech->cookie_jar->set_cookie(0,'xtan','-','/','www.sytadin.fr');
    $mech->cookie_jar->set_cookie(0,'xtant','1','/','www.sytadin.fr');
    $mech->cookie_jar->set_cookie(0,'xtvrn','$330037$','/','www.sytadin.fr');
    
    #and we need to set this header 
    $mech->add_header('Accept-Language' => 'fr-FR');
    
    #we submit the form
    $mech->submit_form(
        form_id   => 'ItineraireForm',
        fields    => { 
            depart     => $start,
            iddepart   => $id_start,
            arrivee    => $end,
            idarrivee  => $id_end,
            via1       => $via,
            idvia1     => $id_via,
            via2       => '',
            idvia2     => '',
            via3       => '',
            idvia3     => '',
            critereRoutier => 'DISTANCE_MINIMUM',
            eviterPeage    => 'OUI',
        },
    );
    #we return the raw html
    return $mech->content;
}

#a basic search function (match .*<input>.* (case insensitve)
sub search_node{
    my $search_string = shift;

    my @result = ();
    foreach my $key ( keys %SYTADIN::Nodes::Nodes ){
        if ( $key =~ /.*$search_string.*/i ){
            push (@result, $key);
        }
    }
    return @result;
}

#very basic parsing of the page, returns a hash with 'traject_time' and 'reliability'
sub scan_result_page{
    my $page = shift;

    my %result = ();
    $result{ 'traject_time' } = 'unknown';
    $result{ 'reliability' } = '0';


    my $flag_time = 0;
    my $flag_reliability = 0;
    my $flag_additianal_time = 0;
    my @lines = split /\n/, $page;

    #we parse the page line by line
    foreach my $line (@lines) {
        #if we match this, traject time must be near, so we set the flag for the traject time
        if ( $line =~ /.*Temps de parcours.*/ ){
            $flag_time = 1;
        }
        #same with reliability
        elsif ( $line =~ /.*Fiabilit.*/ ){
            $flag_reliability = 1;
        }
        #apparently, we have the traject time
        elsif ( $flag_time and $line =~ />(.*)</ ){
            $result{ 'traject_time' } = $1;
            $flag_time = 0;

            #if traject time is > 1h, traject time is on two lines
            #the first line is hours if time > 1h, so, if we match \d{1,2}h
            #it means that we have a second line near this line with the minutes
            #so we set a flag
            if ( $result{ 'traject_time' } =~ /\d{1,2}h/ ){
                $flag_additianal_time = 1;
            }
        }
        #apparently, we have the minutes of the traject time
        elsif ( $flag_additianal_time and $line =~ />(.*)</ ){
            $result{ 'traject_time' } = "$result{ 'traject_time' }$1";
            $flag_additianal_time = 0;
        }
        #apparently, we have the traject reliability
        elsif ( $flag_reliability and $line =~ /[^\d]*(\d{1,2})[^\d]*%[^\d]*/ ){
            $result{ 'reliability' } = $1;
            $flag_reliability = 0;
        }
    }

    #if we didn't collect coherent data we reset to the default values
    if (not($result{ 'traject_time' } =~ /(\d{1,2}h)?\d{1,2}mn/) or not($result{ 'reliability' } =~ /\d{1,2}/)){
        $result{ 'traject_time' } = 'unknown';
        $result{ 'reliability' }  = '0';
    }
    #we return the hash
    return %result;
}

sub get_time_reliability{
    my $start = shift;
    my $end   = shift;
    my $via   = shift;

    return scan_result_page(query_sytadin($start, $end, $via));
}

1;
