#!/usr/bin/env perl


use SYTADIN::Nodes;
use warnings;
use strict;
use WWW::Mechanize;

my $var = $SYTADIN::Nodes::Nodes{"Ablis (A11xN10)"};
print  $var;
sub query_sytadin{
    my $start = shift;
    my $end   = shift;
    my $via   = shift;

    my $id_start = $SYTADIN::Nodes::Nodes{"$start"};
    my $id_end   = $SYTADIN::Nodes::Nodes{"$end"};
    my $id_via   = $SYTADIN::Nodes::Nodes{"$via"};
    print "$start($id_start) $end($id_end) $via($id_via)\n";


    my $mech = WWW::Mechanize->new();
    my $url = 'http://www.sytadin.fr/gp/itineraire.do?stat=false';

    $mech->agent_alias( 'Windows IE 6' );
    $mech->get( $url );

    $mech->cookie_jar->set_cookie(0,'arrivee',$id_end,'/','www.sytadin.fr');
    $mech->cookie_jar->set_cookie(0,'depart',$id_start,'/','www.sytadin.fr');
    $mech->cookie_jar->set_cookie(0,'mode','court','/','www.sytadin.fr');
    $mech->cookie_jar->set_cookie(0,'via1',$id_via,'/','www.sytadin.fr');
    $mech->cookie_jar->set_cookie(0,'workflow','via2','/','www.sytadin.fr');
    $mech->cookie_jar->set_cookie(0,'xtan','-','/','www.sytadin.fr');
    $mech->cookie_jar->set_cookie(0,'xtant','1','/','www.sytadin.fr');
    $mech->cookie_jar->set_cookie(0,'xtvrn','$330037$','/','www.sytadin.fr');
    
    $mech->add_header('Accept-Language' => 'fr-FR');
    
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
    return $mech->content;
}

sub scan_result_page{
    my $page = shift;

    my %result = ();
    $result{ 'traject_time' } = 'unkown';
    $result{ 'reliability' } = 'unkown';
    my $traject_time; 
    my $reliability;
    my $flag_time = 0;
    my $flag_reliability = 0;
    my @lines = split /\n/, $page;
    foreach my $line (@lines) {
        if ( $line =~ /.*Temps de parcours.*/ ){
            $flag_time = 1;
        }
        elsif ( $line =~ /.*Fiabilit.*/ ){
            $flag_reliability = 1;
        }
        elsif ( $flag_time and $line =~ />(.*)</ ){
            $result{ 'traject_time' } = $1;
            $flag_time = 0;
        }
        elsif ( $flag_reliability and $line =~ /[^\d]*(\d{1,2})[^\d]*%[^\d]*/ ){
            $result{ 'reliability' } = $1;
            $flag_reliability = 0;
        }
    }
    return %result;
}

my $page = query_sytadin('Le Petit Clamart (N118xA86)', 'Corbeil (A6xN104)', 'Janvry (A10xN104)');
my %info = scan_result_page($page);
print "temps: $info{'traject_time'} || fiabilite: $info{'reliability'}%\n";
