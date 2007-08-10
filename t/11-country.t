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

use Geo::ICAO qw[ :country ];
use Test::More tests => 4;


# all_country_names()
my @names = all_country_names();
is( scalar @names, 226, 'all_country_names() returns 226 names' );
# Brazil=5, Indonesia=4, Djibouti=2
# ==> 4+3+1=8 names not counted


# all_country_codes()
my @codes = all_country_codes();
my %length = (); $length{ length $_ }++ foreach @codes;
is( scalar @codes, 234, 'all_country_codes() returns 234 codes' );
is( $length{1},    5,   'all_country_codes() returns 5 countries with 1-letter code' );
is( $length{2},    229, 'all_country_codes() returns countries with 2-letters codes' );


# code2country()
#is( code2country('K'),    'USA', 'basic code2country() usage' );
#is( code2country('KJFK'), 'USA', 'code2country() with an airport code' );
#is( code2country('I'),    undef, 'code2country() with unknown code' );


# country2code()
#is( country2code('Canada'),  'C',   'basic country2code() usage' );
#is( country2code('Unknown'), undef, 'country2code() with unknown name' );


exit;
