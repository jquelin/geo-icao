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

use Geo::ICAO qw[ :region ];
use Test::More tests => 8;


# all_region_names()
my @names = all_region_names();
is( scalar @names, 22, 'all_region_names() returns 22 names' );


# all_region_codes()
my @codes = all_region_codes();
my %length = (); $length{ length $_ }++ foreach @codes;
is( scalar @codes, 22, 'all_region_codes() returns 22 codes' );
is( $length{1},    22, 'all_region_codes() returns 1-letter codes' );


# code2region()
is( code2region('K'),    'USA', 'basic code2region() usage' );
is( code2region('KJFK'), 'USA', 'code2region() with an airport code' );
is( code2region('I'),    undef, 'code2region() with unknown code' );


# region2code()
is( region2code('Canada'),  'C',   'basic region2code() usage' );
is( region2code('Unknown'), undef, 'region2code() with unknown name' );


exit;
