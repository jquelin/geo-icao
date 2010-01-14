use 5.008;
use warnings;
use strict;

package Geo::ICAO;
# ABSTRACT: Airport and ICAO codes lookup

use Carp;
use File::ShareDir qw{ dist_dir };
use List::Util     qw{ first    };
use Path::Class;
use Readonly;


# exporting.
use base qw[ Exporter ];
our (@EXPORT_OK, %EXPORT_TAGS);
{
    my @regions   = qw[ all_region_codes all_region_names region2code code2region ];
    my @countries = qw[ all_country_codes all_country_names country2code code2country ];
    my @airports  = qw[ all_airport_codes all_airport_names airport2code code2airport ];
    @EXPORT_OK = (@regions, @countries, @airports);
    %EXPORT_TAGS = (
        region  => \@regions,
        country => \@countries,
        airport => \@airports,
        all     => \@EXPORT_OK,
    );
}


#--
# private module vars.

# - vars defined statically

# list of ICAO codes for the regions with their name.
my %code2region = (
    A => 'Western South Pacific',
    B => 'Iceland/Greenland',
    C => 'Canada',
    D => 'West Africa',
    E => 'Northern Europe',
    F => 'Southern Africa',
    G => 'Northwestern Africa',
    H => 'Northeastern Africa',
    K => 'USA',
    L => 'Southern Europe and Israel',
    M => 'Central America',
    N => 'South Pacific',
    O => 'Southwest Asia, Afghanistan and Pakistan',
    P => 'Eastern North Pacific',
    R => 'Western North Pacific',
    S => 'South America',
    T => 'Caribbean',
    U => 'Russia and former Soviet States',
    V => 'South Asia and mainland Southeast Asia',
    W => 'Maritime Southeast Asia',
    Y => 'Australia',
    Z => 'China, Mongolia and North Korea',
);

# list of ICAO codes for the countries with their name.
my %code2country = (
    'AG' => q{Solomon Islands},
    'AN' => q{Nauru},
    'AY' => q{Papua New Guinea},
    'BG' => q{Greenland},
    'BI' => q{Iceland},
    'BK' => q{Kosovo},
    'C'  => q{Canada},
    'DA' => q{Algeria},
    'DB' => q{Benin},
    'DF' => q{Burkina Faso},
    'DG' => q{Ghana},
    'DI' => q{Côte d'Ivoire},
    'DN' => q{Nigeria},
    'DR' => q{Niger},
    'DT' => q{Tunisia},
    'DX' => q{Togolese Republic},
    'EB' => q{Belgium},
    'ED' => q{Germany (civil)},
    'EE' => q{Estonia},
    'EF' => q{Finland},
    'EG' => q{United Kingdom},
    'EH' => q{Netherlands},
    'EI' => q{Ireland},
    'EK' => q{Denmark},
    'EL' => q{Luxembourg},
    'EN' => q{Norway},
    'EP' => q{Poland},
    'ES' => q{Sweden},
    'ET' => q{Germany (military)},
    'EV' => q{Latvia},
    'EY' => q{Lithuania},
    'FA' => q{South Africa},
    'FB' => q{Botswana},
    'FC' => q{Republic of the Congo},
    'FD' => q{Swaziland},
    'FE' => q{Central African Republic},
    'FG' => q{Equatorial Guinea},
    'FH' => q{Ascension Island},
    'FI' => q{Mauritius},
    'FJ' => q{British Indian Ocean Territory},
    'FK' => q{Cameroon},
    'FL' => q{Zambia},
    'FM' => q{Comoros, Madagascar, Mayotte, Réunion},
    'FN' => q{Angola},
    'FO' => q{Gabon},
    'FP' => q{São Tomé and Príncipe},
    'FQ' => q{Mozambique},
    'FS' => q{Seychelles},
    'FT' => q{Chad},
    'FV' => q{Zimbabwe},
    'FW' => q{Malawi},
    'FX' => q{Lesotho},
    'FY' => q{Namibia},
    'FZ' => q{Democratic Republic of the Congo},
    'GA' => q{Mali},
    'GB' => q{The Gambia},
    'GC' => q{Canary Islands (Spain)},
    'GE' => q{Ceuta and Melilla (Spain)},
    'GF' => q{Sierra Leone},
    'GG' => q{Guinea-Bissau},
    'GL' => q{Liberia},
    'GM' => q{Morocco},
    'GO' => q{Senegal},
    'GQ' => q{Mauritania},
    'GS' => q{Western Sahara},
    'GU' => q{Guinea},
    'GV' => q{Cape Verde},
    'HA' => q{Ethiopia},
    'HB' => q{Burundi},
    'HC' => q{Somalia},
    'HD' => q{Djibouti},
    'HE' => q{Egypt},
    'HF' => q{Djibouti},
    'HH' => q{Eritrea},
    'HK' => q{Kenya},
    'HL' => q{Libya},
    'HR' => q{Rwanda},
    'HS' => q{Sudan},
    'HT' => q{Tanzania},
    'HU' => q{Uganda},
    'K'  => q{USA},
    'LA' => q{Albania},
    'LB' => q{Bulgaria},
    'LC' => q{Cyprus},
    'LD' => q{Croatia},
    'LE' => q{Spain},
    'LF' => q{France},
    'LG' => q{Greece},
    'LH' => q{Hungary},
    'LI' => q{Italy},
    'LJ' => q{Slovenia},
    'LK' => q{Czech Republic},
    'LL' => q{Israel},
    'LM' => q{Malta},
    'LN' => q{Monaco},
    'LO' => q{Austria},
    'LP' => q{Portugal},
    'LQ' => q{Bosnia and Herzegovina},
    'LR' => q{Romania},
    'LS' => q{Switzerland},
    'LT' => q{Turkey},
    'LU' => q{Moldova},
    'LV' => q{Areas Under the Control of the Palestinian Authority},
    'LW' => q{Macedonia},
    'LX' => q{Gibraltar},
    'LY' => q{Serbia and Montenegro},
    'LZ' => q{Slovakia},
    'MB' => q{Turks and Caicos Islands},
    'MD' => q{Dominican Republic},
    'MG' => q{Guatemala},
    'MH' => q{Honduras},
    'MK' => q{Jamaica},
    'MM' => q{Mexico},
    'MN' => q{Nicaragua},
    'MP' => q{Panama},
    'MR' => q{Costa Rica},
    'MS' => q{El Salvador},
    'MT' => q{Haiti},
    'MU' => q{Cuba},
    'MW' => q{Cayman Islands},
    'MY' => q{Bahamas},
    'MZ' => q{Belize},
    'NC' => q{Cook Islands},
    'NF' => q{Fiji, Tonga},
    'NG' => q{Kiribati (Gilbert Islands), Tuvalu},
    'NI' => q{Niue},
    'NL' => q{Wallis and Futuna},
    'NS' => q{Samoa, American Samoa},
    'NT' => q{French Polynesia},
    'NV' => q{Vanuatu},
    'NW' => q{New Caledonia},
    'NZ' => q{New Zealand, Antarctica},
    'OA' => q{Afghanistan},
    'OB' => q{Bahrain},
    'OE' => q{Saudi Arabia},
    'OI' => q{Iran},
    'OJ' => q{Jordan and the West Bank},
    'OK' => q{Kuwait},
    'OL' => q{Lebanon},
    'OM' => q{United Arab Emirates},
    'OO' => q{Oman},
    'OP' => q{Pakistan},
    'OR' => q{Iraq},
    'OS' => q{Syria},
    'OT' => q{Qatar},
    'OY' => q{Yemen},
    'PA' => q{Alaska only},
    'PB' => q{Baker Island},
    'PC' => q{Kiribati (Canton Airfield, Phoenix Islands)},
    'PF' => q{Fort Yukon, Alaska},
    'PG' => q{Guam, Northern Marianas},
    'PH' => q{Hawaiʻi only},
    'PJ' => q{Johnston Atoll},
    'PK' => q{Marshall Islands},
    'PL' => q{Kiribati (Line Islands)},
    'PM' => q{Midway Island},
    'PO' => q{Oliktok Point, Alaska},
    'PP' => q{Point Lay, Alaska},
    'PT' => q{Federated States of Micronesia, Palau},
    'PW' => q{Wake Island},
    'RC' => q{Republic of China (Taiwan)},
    'RJ' => q{Japan (most of country)},
    'RK' => q{South Korea},
    'RO' => q{Japan (Okinawa Prefecture and Yoron)},
    'RP' => q{Philippines},
    'SA' => q{Argentina},
    'SB' => q{Brazil},
    'SC' => q{Chile},
    'SD' => q{Brazil},
    'SE' => q{Ecuador},
    'SF' => q{Falkland Islands},
    'SG' => q{Paraguay},
    'SI' => q{Brazil},
    'SJ' => q{Brazil},
    'SK' => q{Colombia},
    'SL' => q{Bolivia},
    'SM' => q{Suriname},
    'SN' => q{Brazil},
    'SO' => q{French Guiana},
    'SP' => q{Peru},
    'SS' => q{Brazil},
    'SU' => q{Uruguay},
    'SV' => q{Venezuela},
    'SW' => q{Brazil},
    'SY' => q{Guyana},
    'TA' => q{Antigua and Barbuda},
    'TB' => q{Barbados},
    'TD' => q{Dominica},
    'TF' => q{Guadeloupe},
    'TG' => q{Grenada},
    'TI' => q{U.S. Virgin Islands},
    'TJ' => q{Puerto Rico},
    'TK' => q{Saint Kitts and Nevis},
    'TL' => q{Saint Lucia},
    'TN' => q{Netherlands Antilles, Aruba},
    'TQ' => q{Anguilla},
    'TR' => q{Montserrat},
    'TT' => q{Trinidad and Tobago},
    'TU' => q{British Virgin Islands},
    'TV' => q{Saint Vincent and the Grenadines},
    'TX' => q{Bermuda},
    'U'  => q{Russia},
    'UA' => q{Kazakhstan, Kyrgyzstan},
    'UB' => q{Azerbaijan},
    'UD' => q{Armenia},
    'UG' => q{Georgia},
    'UK' => q{Ukraine},
    'UM' => q{Belarus and Kaliningrad, Russia},
    'UT' => q{Tajikistan, Turkmenistan, Uzbekistan},
    'VA' => q{India (West Zone, Mumbai Center)},
    'VC' => q{Sri Lanka},
    'VD' => q{Cambodia},
    'VE' => q{India (East Zone, Kolkata Center)},
    'VG' => q{Bangladesh},
    'VH' => q{Hong Kong, China},
    'VI' => q{India (North Zone, Delhi Center)},
    'VL' => q{Laos},
    'VM' => q{Macau, China},
    'VN' => q{Nepal},
    'VO' => q{India (South Zone, Chennai Center)},
    'VQ' => q{Bhutan},
    'VR' => q{Maldives},
    'VT' => q{Thailand},
    'VV' => q{Vietnam},
    'VY' => q{Myanmar},
    'WA' => q{Indonesia},
    'WB' => q{Malaysia, Brunei},
    'WI' => q{Indonesia},
    'WM' => q{Malaysia},
    'WP' => q{Timor-Leste},
    'WQ' => q{Indonesia},
    'WR' => q{Indonesia},
    'WS' => q{Singapore},
    'Y'  => q{Australia},
    'Z'  => q{People's Republic of China},
    'ZK' => q{North Korea},
    'ZM' => q{Mongolia},
);

Readonly my $FDATA => file( dist_dir('Geo-ICAO'), 'icao.data' );

# - vars computed after other vars

my %region2code = reverse %code2region;
my %country2code;
{ # need to loop, since some countries have more than one code.
    foreach my $code ( keys %code2country ) {
        my $country = $code2country{$code};
        push @{ $country2code{$country} }, $code;
    }
}


#--
# subs handling regions.

sub all_region_codes { return keys %code2region; }
sub all_region_names { return keys %region2code; }
sub region2code { return $region2code{$_[0]}; }
sub code2region {
    my ($code) = @_;
    my $letter = substr $code, 0, 1; # can be called with an airport code
    return $code2region{$letter};
}


#--
# subs handling countries.

sub all_country_codes {
    my ($code) = @_;

    return keys %code2country unless defined $code; # no filters
    croak "'$code' is not a valid region code" unless defined code2region($code);
    return grep { /^$code/ } keys %code2country;    # filtering
}

sub all_country_names {
    my ($code) = @_;

    return keys %country2code unless defined $code; # no filters
    croak "'$code' is not a valid region code" unless defined code2region($code);

    # %country2code holds array refs. but even if a country has more
    # than one code assigned, they will be in the same region: we just
    # need to test the first code.
    return grep { $country2code{$_}[0] =~ /^$code/ } keys %country2code;
}

sub country2code {
    my ($country) = @_;
    my $codes = $country2code{$country};
    return defined $codes ? @$codes : undef;
}

sub code2country {
    my ($code) = @_;
    return $code2country{$code}
        || $code2country{substr($code,0,2)}
        || $code2country{substr($code,0,1)};
}


#--
# subs handling airports

sub all_airport_codes {
    my ($code) = @_;

    croak 'should provid a region or country code' unless defined $code;
    croak "'$code' is not a valid region or country code"
        unless exists $code2country{$code}
            || exists $code2region{$code};

    open my $fh, '<', $FDATA or die "can't open $FDATA: $!";
    my @codes;
    LINE:
    while ( my $line = <$fh>) {
        next LINE unless $line =~ /^$code/;  # filtering on $code
        my ($c, undef) = split/\|/, $line;
        push @codes, $c;
    }
    close $fh;
    return @codes;
}

sub all_airport_names {
    my ($code) = @_;

    croak 'should provid a region or country code' unless defined $code;
    croak "'$code' is not a valid region or country code"
        unless exists $code2country{$code}
            || exists $code2region{$code};

    open my $fh, '<', $FDATA or die "can't open $FDATA: $!";
    my @codes;
    LINE:
    while ( my $line = <$fh>) {
        next LINE unless $line =~ /^$code/;  # filtering on $code
        my (undef, $airport, undef) = split/\|/, $line;
        push @codes, $airport;
    }
    close $fh;
    return @codes;
}

sub airport2code {
    my ($name) = @_;

    open my $fh, '<', $FDATA or die "can't open $FDATA: $!";
    LINE:
    while ( my $line = <$fh>) {
        my ($code, $airport, undef) = split/\|/, $line;
        next LINE unless lc($airport) eq lc($name);
        close $fh;
        return $code;
    }
    close $fh;
    return;          # no airport found
}

sub code2airport {
    my ($code) = @_;

    open my $fh, '<', $FDATA or die "can't open $FDATA: $!";
    LINE:
    while ( my $line = <$fh>) {
        next LINE unless $line =~ /^$code\|/;
        chomp $line;
        my (undef, $airport, $location) = split/\|/, $line;
        close $fh;
        return wantarray ? ($airport, $location) : $airport;
    }
    close $fh;
    return;          # no airport found
}


1;
__END__


=head1 SYNOPSIS

    use Geo::ICAO qw[ :all ];

    my @region_codes = all_region_codes();
    my @region_names = all_region_names();
    my $code   = region2code('Canada');
    my $region = code2region('C');

    my @country_codes = all_country_codes();
    my @country_names = all_country_names();
    my @codes   = country2code('Brazil');
    my $region  = code2country('SB');

    my @airport_codes = all_airport_codes('B');
    my @airport_names = all_airport_names('B');
    my $code    = airport2code('Lyon Bron Airport');
    my $airport = code2airport('LFLY');
    my ($airport, $location) = code2airport('LFLY'); # list context



=head1 EXPORT

Nothing is exported by default. But all the functions described below
are exportable: it's up to you to decide what you want to import.

Note that the keyword C<:all> will import everything, and each category
of function provides its own keyword.



=head1 FUNCTIONS

=head2 Regions

The first letter of an ICAO code refer to the region of the airport. The
region is quite loosely defined as per the ICAO. This set of functions
allow retrieval and digging of the regions.

Note: you can import all those functions with the C<:region> keyword.


=over 4

=item . my @codes = all_region_codes()

Return the list of all single letters defining an ICAO region. No
parameter needed.


=item . my @regions = all_region_names()

Return the list of all ICAO region names. No parameter needed.


=item . my $code = region2code( $region )

Return the one-letter ICAO C<$code> corresponding to C<$region>. If the
region does not exist, return undef.


=item . my $region = code2region( $code )

Return the ICAO C<$region> corresponding to C<$code>. Note that C<$code>
can be a one-letter code (region), two-letters code (country) or a
four-letters code (airport): in either case, the region will be
returned.

Return undef if the associated region doesn't exist.

=back



=head2 Countries

The first two letters of an ICAO code refer to the country of the
airport. Once again, the rules are not really set in stone: some codes
are shared by more than one country, some countries are defined more
than once... and some countries (Canada, USA, Russia, Australia and
China) are even coded on only one letter - ie, the country is the same
as the region). This set of functions allow retrieval and digging of the
countries.

Note: you can import all those functions with the C<:country> keyword.


=over 4

=item . my @codes = all_country_codes( [$code] )

Return the list of all single- or double-letters defining an ICAO
country. If a region C<$code> is given, return only the country codes of
this region. (Note: dies if C<$code> isn't a valid ICAO region code).


=item . my @countries = all_country_names( [$code] )

Return the list of all ICAO country names. If a region C<$code> is
given, return only the country names of this region. (Note: dies if
C<$code> isn't a valid ICAO region code).


=item . my @codes = country2code( $country )

Return the list of ICAO codes corresponding to C<$country>. It's a list
since some countries have more than one code. Note that the codes can be
single-letters (USA, etc.)


=item . my $country = code2country( $code )

Return the ICAO C<$country> corresponding to C<$code>. Note that
C<$code> can be a classic country code, or a four-letters code
(airport): in either case, the region will be returned.

Return undef if the associated region doesn't exist.

=back



=head2 Airports

This set of functions allow retrieval and digging of the airports, which
are defined on 4 letters.

Note: you can import all those functions with the C<:airport> keyword.


=over 4

=item . my @codes = all_airport_codes( $code )

Return the list of all ICAO airport codes in the C<$code> country
(C<$code> can also be a region code). Note that compared to the region
or country equivalent, this function B<requires> an argument. It will
die otherwise (or if C<$code> isn't a valid ICAO country or region
code).


=item . my @codes = all_airport_names( $code )

Return the list of all ICAO airport names in the C<$code> country
(C<$code> can also be a region code). Note that compared to the region
or country equivalent, this function B<requires> an argument. It will
die otherwise (or if C<$code> isn't a valid ICAO country or region
code).


=item . my $code = airport2code( $airport )

Return the C<$code> of the C<$airport>, undef i no airport matched. Note
that the string comparison is done on a case-insensitive basis.


=item . my $airport = code2airport( $code )

Return the C<$airport> name corresponding to C<$code>. In list context,
return both the airport name and its location (if known).

=back



=head1 SEE ALSO

You can look for information on this module at:

=over 4

=item * Search CPAN

L<http://search.cpan.org/dist/Geo-ICAO>

=item * See open / report bugs

L<http://rt.cpan.org/NoAuth/Bugs.html?Dist=Geo-ICAO>

=item * Git repository

L<http://github.com/jquelin/geo-icao>

=item * AnnoCPAN: Annotated CPAN documentation

L<http://annocpan.org/dist/Geo-ICA>

=item * CPAN Ratings

L<http://cpanratings.perl.org/d/Geo-ICAO>

=back

=cut
