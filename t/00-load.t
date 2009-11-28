#!perl

use strict;
use warnings;

use Test::More tests => 1;

BEGIN { use_ok( 'Geo::ICAO' ); }
diag( "Testing Geo::ICAO $Geo::ICAO::VERSION, Perl $], $^X" );

exit;
