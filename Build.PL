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
use Module::Build;

my $builder = Module::Build->new (
    module_name         => 'Geo::ICAO',
    dist_author         => 'Jerome Quelin <jquelin@cpan.org>',
    license             => 'perl',
    dist_version_from   => 'lib/Geo/ICAO.pm',
    add_to_cleanup => [
        'Geo-ICAO-*', 'MANIFEST.bak',
        map { ( '*/' x $_ ) . '*~' } 0..4 ],
    script_files   => [ ],
    build_requires => {
        'perl'       => '5.008',
        'Test::More' => 0,
    },
    requires       => { 
    },
);

$builder->create_build_script();
