#!/usr/bin/env perl

use ExtUtils::MakeMaker;

WriteMakefile(
    AUTHOR            => 'Pierre-Francois Carpentier <carpentier.pf@gmail.com>', 
    LICENSE           => 'MIT',
    NAME              => "SYTADIN::",
    VERSION_FROM      => "lib/SYTADIN/Query.pm",
    EXE_FILES         => [ 'bin/sytadin-scraper' ],
    PREREQ_PM         => {
        'WWW::Mechanize' => 0,
        'Getopt::Long'   => 0,
    },
);
