#!perl
#
# This file is part of Geo::ICAO.
# Copyright (c) 2007 Jerome Quelin, all rights reserved.
#
# This program is free software; you can redistribute it and/or modify
# it under the same terms as Perl itself.
#
#

use strict;
use warnings;
use ExtUtils::MakeMaker;

WriteMakefile(
    NAME                => 'Geo::ICAO',
    AUTHOR              => 'Jerome Quelin <jquelin@cpan.org>',
    VERSION_FROM        => 'lib/Geo/ICAO.pm',
    ABSTRACT_FROM       => 'lib/Geo/ICAO.pm',
    PL_FILES            => {},
    PREREQ_PM => {
        'Test::More' => 0,
    },
    dist  => { COMPRESS => 'gzip -9f', SUFFIX => 'gz', },
    clean => { FILES => [
                'Geo-ICAO-*', 'MANIFEST.bak',
                map { ( '*/' x $_ ) . '*~' } 0..4
        ] },
);
