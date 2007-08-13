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

use Geo::ICAO qw[ :airport ];
use Test::More tests => 9;


#--
# all_airport_codes()
#my @codes = all_airport_codes();
#my %length = (); $length{ length $_ }++ foreach @codes;
#is( scalar @codes, 234, 'all_airport_codes() returns 234 codes' );
#is( $length{1},    5,   'all_airport_codes() returns 5 countries with 1-letter code' );
#is( $length{2},    229, 'all_airport_codes() returns countries with 2-letters codes' );
##- limiting to a region
#@codes = all_airport_codes('H');
#is( scalar @codes, 13, 'all_airport_codes() - limiting to a region' );
#eval { @codes = all_airport_codes('I'); };
#like( $@, qr/^'I' is not a valid region code/,
#      'all_airport_codes() - limiting to a non-existent region' );


#--
# all_airport_names()
#my @names = all_airport_names();
#is( scalar @names, 226, 'all_airport_names() returns 226 names' );
## Brazil=5, Indonesia=4, Djibouti=2
## ==> 4+3+1=8 duplicated names not counted
#@names = all_airport_names('H');
#is( scalar @names, 12, 'all_airport_names() - limiting to a region' );
#eval { @names = all_airport_names('I'); };
#like( $@, qr/^'I' is not a valid region code/,
#      'all_airport_names() - limiting to a non-existent region' );


#--
# code2airport()
is  ( code2airport('LFLY'), 'Lyon Bron Airport', 'code2airport() basic usage' );
like( code2airport('LFLL'), qr/^Lyon Saint-Exu/, 'code2airport() - rewinding' );
is  ( code2airport('IIII'), undef,               'code2airport() - unknown code' );
my @details = code2airport('LFLY');
is( scalar @details, 2,      'code2airport() - list context' );
is( $details[1],     'Lyon', 'code2airport() - location' );


#--
# airport2code()
is( airport2code('Lyon Bron Airport'),  'LFLY', 'airport2code() basic usage' );
is( airport2code('Courchevel Airport'), 'LFLJ', 'airport2code() - rewinding' );
is( airport2code('Foobar Airport'),     undef,  'airport2code() - unknown name' );
is( airport2code('lyon bron airport'),  'LFLY', 'airport2code() - case insensitive' );


exit;
