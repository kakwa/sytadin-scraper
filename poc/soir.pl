#!/usr/bin/env perl

use strict;
use WWW::Mechanize;
use Data::Dumper;
use URI::Escape;
my $mech = WWW::Mechanize->new();

my $url = 'http://www.sytadin.fr/gp/itineraire.do?stat=false';
$mech->agent_alias( 'Windows IE 6' );

$mech->get( $url );

my @forms = $mech->forms;
foreach my $form (@forms) {

            my @inputfields = $form->param;

                    print Dumper \@inputfields;
            }  

$mech->cookie_jar->set_cookie(0,'arrivee','26000046','/','www.sytadin.fr');
$mech->cookie_jar->set_cookie(0,'depart','26000076','/','www.sytadin.fr');
$mech->cookie_jar->set_cookie(0,'mode','court','/','www.sytadin.fr');
$mech->cookie_jar->set_cookie(0,'via1','26000049','/','www.sytadin.fr');
$mech->cookie_jar->set_cookie(0,'workflow','via2','/','www.sytadin.fr');
$mech->cookie_jar->set_cookie(0,'xtan','-','/','www.sytadin.fr');
$mech->cookie_jar->set_cookie(0,'xtant','1','/','www.sytadin.fr');
$mech->cookie_jar->set_cookie(0,'xtvrn','$330037$','/','www.sytadin.fr');

$mech->submit_form(
    form_id   => 'ItineraireForm',
    fields    => { 
        #depart     => 'Le Petit Clamart (N118xA86)',
        depart     => 'Le',
        iddepart   => '26000076',
        arrivee    => 'Corbeil (A6xN104)',
        idarrivee  => '26000046',
        via1       => 'Janvry (A10xN104)',
        idvia1     => '26000049',
        via2       => '',
        idvia2     => '',
        via3       => '',
        idvia3     => '',
        critereRoutier => 'DISTANCE_MINIMUM',
        eviterPeage    => 'OUI',
    },
    #submit    => "Calculer l'itinéraire",
);

print $mech->cookie_jar->as_string;
#print Dumper $mech->cookie_jar;
print $mech->cookie_jar->as_string;
print $mech->content;
print uri_escape('Le Petit Clamart (N118xA86)','()');
