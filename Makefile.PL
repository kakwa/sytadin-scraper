#!/usr/bin/env perl

use ExtUtils::MakeMaker;

WriteMakefile(
    NAME              => "SYTADIN::",
    VERSION_FROM      => "lib/SYTADIN/Query.pm",
    EXE_FILES         => [ 'bin/sytadin-scraper' ],
);
