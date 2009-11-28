use warnings;
use strict;

package Geo::ICAO;
# ABSTRACT: Airport and ICAO codes lookup

use Carp;
use List::Util qw[ first ];

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

    seek DATA, 0, 0; # reset data iterator
    my @codes;
    LINE:
    while ( my $line = <DATA>) {
        next LINE unless $line =~ /^$code/;  # filtering on $code
        my ($c, undef) = split/\|/, $line;
        push @codes, $c;
    }
    return @codes;
}

sub all_airport_names {
    my ($code) = @_;

    croak 'should provid a region or country code' unless defined $code;
    croak "'$code' is not a valid region or country code"
        unless exists $code2country{$code}
            || exists $code2region{$code};

    seek DATA, 0, 0; # reset data iterator
    my @codes;
    LINE:
    while ( my $line = <DATA>) {
        next LINE unless $line =~ /^$code/;  # filtering on $code
        my (undef, $airport, undef) = split/\|/, $line;
        push @codes, $airport;
    }
    return @codes;
}

sub airport2code {
    my ($name) = @_;

    seek DATA, 0, 0; # reset data iterator
    LINE:
    while ( my $line = <DATA>) {
        my ($code, $airport, undef) = split/\|/, $line;
        next LINE unless lc($airport) eq lc($name);
        return $code;
    }
    return;          # no airport found
}

sub code2airport {
    my ($code) = @_;

    seek DATA, 0, 0; # reset data iterator
    LINE:
    while ( my $line = <DATA>) {
        next LINE unless $line =~ /^$code\|/;
        chomp $line;
        my (undef, $airport, $location) = split/\|/, $line;
        return wantarray ? ($airport, $location) : $airport;
    }
    return;          # no airport found
}


1;
#__END__


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

__DATA__
AGAF|Afutara Airport|Afutara
AGAR|Ulawa Airport|Arona, Ulawa Island
AGAT|Uru Harbour|Atoifi, Malaita
AGBA|Barakoma Airport|Barakoma
AGBT|Batuna Airport|Batuna
AGEV|Geva Airport|Geva
AGGA|Auki Airport|Auki
AGGB|Bellona/Anua Airport|Bellona/Anua
AGGC|Choiseul Bay Airport|Choiseul Bay, Taro Island
AGGD|Mbambanakira Airport|Mbambanakira
AGGE|Balalae Airport|Shortland Island
AGGF|Fera/Maringe Airport|Fera Island, Santa Isabel Island
AGGG|Honiara FIR|Honiara, Guadalcanal
AGGH|Honiara International Airport (formerly Henderson Field)|Honiara, Guadalcanal
AGGI|Babanakira Airport|Babanakira
AGGJ|Avu Avu Airport|Avu Avu
AGGK|Kirakira Airport|Kirakira
AGGL|Santa Cruz/Graciosa Bay/Luova Airport|Santa Cruz/Graciosa Bay/Luova, Santa Cruz Island
AGGM|Munda Airport|Munda, New Georgia Island
AGGN|Nusatupe Airport|Gizo Island
AGGO|Mono Airport|Mono Island
AGGP|Marau Sound Airport|Marau Sound
AGGQ|Ontong Java Airport|Ontong Java
AGGR|Rennell/Tingoa Airport|Rennell/Tingoa, Rennell Island
AGGS|Seghe Airport|Seghe
AGGT|Santa Ana Airport|Santa Ana
AGGU|Marau Airport|Marau
AGGV|Suavanao Airport|Suavanao
AGGY|Yandina Airport|Yandina
AGIN|Isuna Heliport|Isuna
AGKG|Kaghau Airport|Kaghau
AGKU|Kukudu Airport|Kukudu
AGOK|Gatokae Aerodrome|Gatokae
AGRC|Ringi Cove Airport|Ringi Cove
AGRM|Ramata Airport|Ramata
ANYN|Nauru International Airport|Yaren (ICAO code formerly ANAU)
AYBK|Buka Airport|Buka
AYCH|Chimbu Airport|Kundiawa
AYDU|Daru Airport|Daru
AYGA|Goroka Airport|Goroka
AYGN|Gurney Airport|Alotau
AYGR|Girua Airport|Popondetta
AYHK|Hoskins Airport|Hoskins
AYKA|Kiriwini Airport|Kiriwini
AYKI|Kiunga Airport|Kiunga
AYKK|Kikori Airport|Kikori
AYKM|Kerema Airport|Kerema
AYKT|Kieta Aropa Airport|Kieta
AYKV|Kavieng Airport|Kavieng
AYKY|Kunaye Airport|Kunaye
AYLA|Lae Nadzab Airport|Lae
AYMD|Madang Airport|Madang
AYMH|Mount Hagen Airport|Mount Hagen
AYMM|Misima Airport|Misima
AYMN|Mendi Airport|Mendi
AYMO|Momote Airport|Manus Island
AYMR|Moro Airport|Moro
AYMS|Misima Airport|Misima
AYNZ|Nadzab Airport|Manguna
AYPY|Port Moresby/Jackson International Airport|Port Moresby
AYRB|Rabaul Airport|Rabaul
AYTA|Tari Airport|Tari
AYTB|Tabubil Airport|Tabubil
AYTK|Tokua Airport|Tokua
AYVN|Vanimo Airport|Vanimo
AYWD|Wapenamanda Airport|Wapenamanda
AYWK|Wewak International Airport|Wewak
BGAA|Aasiaat Airport|Aasiaat (Egedesminde, Ausiat)
BGAG|Aappilattoq (Qaasuitsup) Heliport|Aappilattoq, Qaasuitsup
BGAK|Akunaq Heliport|Akunaq
BGAM|Tasiilaq Heliport|Tasiilaq (Ammassalik, Angmagssalik)
BGAP|Alluitsup Paa Heliport|Alluitsup Paa
BGAQ|Aappilattoq (Kujalleq) Heliport|Aappilattoq, Kujalleq
BGAR|Arsuk Heliport|Arsuk
BGAS|Ammassivik Heliport|Ammassivik
BGAT|Attu Heliport|Attu
BGBW|Narsarsuaq Airport|Narsarsuaq (Narssarssuaq)
BGCH|Qasigiannguit Heliport (Christianshåb Heliport)|Qasigiannguit (Christianshåb)
BGCO|Nerlerit Inaat Airport (Constable Pynt Airport)|Jameson Land
BGET|Eqalugaarsuit Heliport|Eqalugaarsuit
BGFD|Narsaq Kujalleq Heliport|Narsaq Kujalleq
BGGD|Kangilinnguit Heliport (Grønnedal Heliport)|Kangilinnguit (Grønnedal)
BGGH|Nuuk Airport|Nuuk (Godthåb)
BGGN|Qeqertarsuaq Heliport (Godhavn Heliport)|Qeqertarsuaq (Godhavn)
BGIA|Ikerasak Heliport|Ikerasak
BGIG|Iginniarfik Heliport|Iginniarfik
BGIK|Ikerasaarsuk Heliport|Ikerasaarsuk
BGIL|Ilimanaq Heliport|Ilimanaq
BGIN|Innarsuit Heliport|Innarsuit
BGIS|Isortoq Heliport|Isortoq
BGIT|Ikamiut Heliport|Ikamiut
BGJH|Qaqortoq Heliport (Julianehab Heliport)|Qaqortoq (Julianehab)
BGJN|Ilulissat Airport (Jakobshavn Airport)|Ilulissat (Jakobshavn)
BGKA|Kangaatsiaq Heliport|Kangaatsiaq
BGKK|Kulusuk Airport|Kulusuk
BGKL|Upernavik Kujalleq Heliport|Upernavik Kujalleq
BGKM|Kuummiut Heliport|Kuummiut
BGKQ|Kullorsuaq Heliport|Kullorsuaq
BGKS|Kangersuatsiaq Heliport|Kangersuatsiaq
BGKT|Kitsissuarsuit Heliport|Kitsissuarsuit
BGLL|Illorsuit Heliport|Illorsuit
BGMO|Moriussaq Heliport|Moriusaq
BGMQ|Maniitsoq Airport|Maniitsoq (Sukkertoppen)
BGNK|Niaqornaarsuk Heliport|Niaqornaarsuk
BGNL|Nalunaq Heliport|Nalunaq
BGNN|Nanortalik Heliport|Nanortalik
BGNQ|Nuugaatsiaq Heliport|Nuugaatsiaq
BGNS|Narsaq Heliport|Narsaq
BGNT|Niaqornat Heliport|Niaqornat
BGNU|Nuussuaq Heliport|Nuussuaq
BGPT|Paamiut Airport|Paamiut (Frederikshåb)
BGQE|Qeqertaq Heliport|Qeqertaq
BGQQ|Qaanaaq Airport|Qaanaaq
BGQT|Qassimiut Heliport|Qassimiut
BGSC|Ittoqqortoormiit Heliport (Scoresbysund Heliport)|Ittoqqortoormiit (Scoresbysund)
BGSF|Kangerlussuaq Airport (Søndre Strømfjord Airport)|Kangerlussuaq (Søndre Strømfjord)
BGSG|Sermiligaaq Heliport|Sermiligaaq
BGSI|Siorapaluk Heliport|Siorapaluk
BGSQ|Saqqaq Heliport|Saqqaq
BGSS|Sisimiut Airport (Holsteinsborg Airport)|Sisimiut (Holsteinsborg)
BGST|Saattut Heliport|Saattut
BGSV|Savissivik Heliport|Savissivik
BGTA|Tasiusaq (Qaasuitsup) Heliport|Tasiusaq, Qaasuitsup
BGTL|Thule Air Base|Pituffik, Qaanaaq
BGTN|Tiniteqilaaq Heliport|Tiniteqilaaq
BGTQ|Tasiusaq (Kujalleq) Heliport|Tasiusaq, Kujalleq
BGUK|Upernavik Airport|Upernavik
BGUM|Uummannaq Heliport|Uummannaq
BGUQ|Qaarsut Airport|Qaarsut
BGUT|Ukkusissat Heliport|Ukkusissat
BIAR|Akureyri Airport|Akureyri
BIBK|Bakkafjordur Airport|Bakkafjörður
BIBL|Blönduós Airport|Blönduós
BIDV|Djupivogur Airport|Djupivogur
BIEG|Egilsstaðir Airport|Egilsstaðir
BIGR|Grímsey Airport|Grímsey
BIHN|Hornafjörður Airport|Höfn
BIHU|Húsavík Airport|Húsavík
BIIS|Ísafjörður Airport|Ísafjörður
BIKF|Keflavík International Airport (Flugstöð Leifs Eiríkssonar)|Keflavík
BIKP|Kopasker Airport|Kópasker
BIKR|Sauðárkrókur Airport|Sauðárkrókur
BINF|Nordfjordur Airport|Nordfjordur
BIPA|Patreksfjörður Airport|Patreksfjörður
BIRF|Rif Airport|Ólafsvík
BIRG|Raufarhofn Airport|Raufarhofn
BIRK|Reykjavík Airport|Reykjavík
BISI|Siglufjörður Airport|Siglufjörður
BIST|Stykkishólmur Airport|Stykkishólmur
BITE|Thingeyri Airport|Þingeyri
BITN|Thorshofn Airport|Þórshöfn
BIVM|Vestmannaeyjar Airport|Vestmannaeyjar
BIVO|Vopnafjörður Airport|Vopnafjörður
BKPR|Pristina International Airport|Pristina
CYAC|Cat Lake Airport|Cat Lake, Ontario
CYAD|La Grande-3 Airport|La Grande-3 generating station, Quebec
CYAG|Fort Frances Municipal Airport|Fort Frances, Ontario
CYAH|La Grande-4 Airport|La Grande-4 generating station, Quebec
CYAL|Alert Bay Airport|Alert Bay, British Columbia
CYAM|Sault Ste. Marie Airport|Sault Ste. Marie, Ontario
CYAQ|Kasabonika Airport|Kasabonika, Ontario
CYAS|Kangirsuk Airport|Kangirsuk, Quebec
CYAT|Attawapiskat Airport|Attawapiskat, Ontario
CYAU|Liverpool/South Shore Regional Airport|Liverpool, Nova Scotia
CYAV|Winnipeg/St. Andrews Airport|St. Andrews, Manitoba
CYAW|CFB Shearwater (Halifax/Shearwater Airport)|Shearwater, Nova Scotia
CYAX|Lac Du Bonnet Airport|Lac Du Bonnet, Manitoba
CYAY|St. Anthony Airport|St. Anthony, Newfoundland and Labrador
CYAZ|Tofino Airport|Tofino, British Columbia
CYBA|Banff Airport|Banff, Alberta
CYBB|Kugaaruk Airport|Kugaaruk, Nunavut
CYBC|Baie-Comeau Airport|Baie-Comeau, Quebec
CYBD|Bella Coola Airport|Bella Coola, British Columbia
CYBE|Uranium City Airport|Uranium City, Saskatchewan
CYBF|Bonnyville Airport|Bonnyville, Alberta
CYBG|CFB Bagotville (Bagotville Airport)|Bagotville, Quebec
CYBK|Baker Lake Airport|Baker Lake, Nunavut
CYBL|Campbell River Airport|Campbell River, British Columbia
CYBN|Borden Heliport|Borden, Ontario
CYBP|Brooks Airport|Brooks, Alberta
CYBQ|Tadoule Lake Airport|Tadoule Lake, Manitoba
CYBR|Brandon Airport (Brandon Municipal Airport, McGill Field)|Brandon, Manitoba
CYBT|Brochet Airport|Brochet, Manitoba
CYBU|Nipawin Airport|Nipawin, Saskatchewan
CYBV|Berens River Airport|Berens River, Manitoba
CYBW|Calgary/Springbank Airport (Springbank Airport)|Calgary, Alberta
CYBX|Lourdes-de-Blanc-Sablon Airport|Blanc-Sablon, Quebec
CYCA|Cartwright Airport|Cartwright, Newfoundland and Labrador
CYCB|Cambridge Bay Airport|Cambridge Bay, Nunavut
CYCC|Cornwall Regional Airport|Cornwall, Ontario
CYCD|Nanaimo Airport|Nanaimo, British Columbia
CYCE|Centralia/James T. Field Memorial Aerodrome|Centralia, Ontario
CYCG|Castlegar Airport|Castlegar, British Columbia
CYCH|Miramichi Airport|Miramichi, New Brunswick
CYCL|Charlo Airport|Charlo, New Brunswick
CYCN|Cochrane Airport|Cochrane, Ontario
CYCO|Kugluktuk Airport|Kugluktuk, Nunavut
CYCP|Blue River Airport|Blue River, British Columbia
CYCQ|Chetwynd Airport|Chetwynd, British Columbia
CYCR|Cross Lake (Charlie Sinclair Memorial) Airport|Cross Lake, Manitoba
CYCS|Chesterfield Inlet Airport|Chesterfield Inlet, Nunavut
CYCT|Coronation Airport|Coronation, Alberta
CYCW|Chilliwack Airport|Chilliwack, British Columbia
CYCX|Gagetown Heliport|Oromocto (CFB Gagetown), New Brunswick
CYCY|Clyde River Airport|Clyde River, Nunavut
CYCZ|Fairmont Hot Springs Airport|Fairmont Hot Springs, British Columbia
CYDA|Dawson City Airport|Dawson City, Yukon
CYDB|Burwash Airport|Burwash Landing, Yukon
CYDC|Princeton Airport (British Columbia)|Princeton, British Columbia
CYDF|Deer Lake Airport (Newfoundland) (Deer Lake Regional Airport)|Deer Lake, Newfoundland and Labrador
CYDH|Ottawa/Dwyer Hill Heliport|Ottawa, Ontario
CYDL|Dease Lake Airport|Dease Lake, British Columbia
CYDM|Ross River Airport|Ross River, Yukon
CYDN|Dauphin (Lt. Col W.G. (Billy) Barker VC Airport)|Dauphin, Manitoba
CYDO|Dolbeau-Saint-Félicien Airport|Dolbeau-Mistassini, Quebec
CYDP|Nain Airport|Nain, Newfoundland and Labrador
CYDQ|Dawson Creek Airport|Dawson Creek, British Columbia
CYEA|Empress Airport|Empress, Alberta
CYED|Edmonton/Namao Heliport|Edmonton, Alberta
CYEE|Midland/Huronia Airport|Midland, Ontario
CYEG|Edmonton International Airport|Edmonton Capital Region, Alberta
CYEK|Arviat Airport|Arviat, Nunavut
CYEL|Elliot Lake Municipal Airport|Elliot Lake, Ontario
CYEM|Manitowaning/Manitoulin East Municipal Airport|Manitowaning, Ontario
CYEN|Estevan Airport|Estevan, Saskatchewan
CYER|Fort Severn Airport|Fort Severn, Ontario
CYES|Edmundston Airport|Edmundston, New Brunswick
CYET|Edson Airport|Edson, Alberta
CYEU|Eureka Airport (Canada)|Eureka, Nunavut
CYEV|Inuvik (Mike Zubko) Airport|Inuvik, Northwest Territories
CYEY|Amos/Magny Airport|Amos, Quebec
CYFA|Fort Albany Airport|Fort Albany, Ontario
CYFB|Iqaluit Airport|Iqaluit, Nunavut
CYFC|Greater Fredericton Airport (Fredericton International Airport)|Fredericton, New Brunswick
CYFD|Brantford Airport|Brantford, Ontario
CYFE|Forestville Airport|Forestville, Quebec
CYFH|Fort Hope Airport|Fort Hope, Ontario
CYFJ|Rivière Rouge/Mont-Tremblant International Inc Airport|Mont-Tremblant, Quebec
CYFO|Flin Flon Airport|Flin Flon, Manitoba
CYFR|Fort Resolution Airport|Fort Resolution, Northwest Territories
CYFS|Fort Simpson Airport|Fort Simpson, Northwest Territories
CYFT|Makkovik Airport|Makkovik, Newfoundland and Labrador
CYGB|Texada/Gillies Bay Airport|Texada Island, British Columbia
CYGD|Goderich Airport (Goderich Municipal Airport)|Goderich, Ontario
CYGE|Golden Airport|Golden, British Columbia
CYGH|Fort Good Hope Airport|Fort Good Hope, Northwest Territories
CYGK|Kingston/Norman Rogers Airport (Kingston Airport)|Kingston, Ontario
CYGL|La Grande Rivière Airport|Radisson, Quebec
CYGM|Gimli Industrial Park Airport|Gimli, Manitoba
CYGO|Gods Lake Narrows Airport|Gods Lake Narrows, Manitoba
CYGP|Gaspé Airport|Gaspé, Quebec
CYGQ|Geraldton (Greenstone Regional) Airport|Geraldton, Ontario
CYGR|Îles-de-la-Madeleine Airport|Magdalen Islands, Quebec
CYGT|Igloolik Airport|Igloolik, Nunavut
CYGV|Havre Saint-Pierre Airport|Havre-Saint-Pierre, Quebec
CYGW|Kuujjuarapik Airport|Kuujjuarapik, Quebec
CYGX|Gillam Airport|Gillam, Manitoba
CYGZ|Grise Fiord Airport|Grise Fiord, Nunavut
CYHA|Quaqtaq Airport|Quaqtaq, Quebec
CYHB|Hudson Bay Airport|Hudson Bay, Saskatchewan
CYHC|Vancouver Harbour Water Airport (Vancouver Coal Harbour Seaplane Base)|Vancouver, British Columbia
CYHD|Dryden Regional Airport|Dryden, Ontario
CYHE|Hope Airport (British Columbia)|Hope, British Columbia
CYHF|Hearst (René Fontaine) Municipal Airport|Hearst, Ontario
CYHH|Nemiscau Airport|Nemaska, Quebec
CYHI|Ulukhaktok/Holman Airport|Ulukhaktok, Northwest Territories
CYHK|Gjoa Haven Airport|Gjoa Haven, Nunavut
CYHM|Hamilton/John C. Munro International Airport (Hamilton International, John C. Munro Hamilton International Airport)|Hamilton, Ontario
CYHN|Hornepayne Municipal Airport|Hornepayne, Ontario
CYHO|Hopedale Airport|Hopedale, Newfoundland and Labrador
CYHR|Chevery Airport|Chevry, Quebec
CYHT|Haines Junction Airport|Haines Junction, Yukon
CYHU|Montréal/Saint-Hubert Airport|Longueuil, Quebec
CYHY|Hay River Airport|Hay River, Northwest Territories
CYHZ|Halifax International Airport|Halifax Regional Municipality, Nova Scotia
CYIB|Atikokan Municipal Airport|Atikokan, Ontario
CYID|Digby Airport|Digby, Nova Scotia
CYIF|Saint-Augustin Airport|Saint-Augustin, Quebec
CYIK|Ivujivik Airport|Ivujivik, Quebec
CYIO|Pond Inlet Airport|Pond Inlet, Nunavut
CYIV|Island Lake Airport|Island Lake, Manitoba
CYJA|Jasper Airport|Jasper, Alberta
CYJF|Fort Liard Airport|Fort Liard, Northwest Territories
CYJM|Fort St. James (Perison) Airport|Fort St. James, British Columbia
CYJN|Saint-Jean Airport (Saint-Jean-sur-Richelieu Airport)|Saint-Jean-sur-Richelieu, Quebec
CYJP|Fort Providence Airport|Fort Providence, Northwest Territories
CYJQ|Bella Bella (Denny Island) Airport|Bella Bella, British Columbia
CYJT|Stephenville International Airport (Stephenville Airport)|Stephenville, Newfoundland and Labrador
CYKA|Kamloops Airport|Kamloops, British Columbia
CYKC|Collins Bay Airport|Collins Bay, Saskatchewan
CYKD|Aklavik/Freddie Carmichael Airport|Aklavik, Northwest Territories
CYKF|Region of Waterloo International Airport (Kitchener/Waterloo Regional Airport)|Regional Municipality of Waterloo, Ontario
CYKG|Kangiqsujuaq (Wakeham Bay) Airport|Kangiqsujuaq, Quebec
CYKJ|Key Lake Airport|Key Lake, Saskatchewan
CYKL|Schefferville Airport|Schefferville, Quebec
CYKO|Akulivik Airport|Akulivik, Quebec
CYKQ|Waskaganish Airport|Waskaganish, Quebec
CYKX|Kirkland Lake Airport|Kirkland Lake, Ontario
CYKY|Kindersley Airport|Kindersley, Saskatchewan
CYKZ|Toronto/Buttonville Municipal Airport (Buttonville Municipal Airport)|Buttonville, Ontario
CYLA|Aupaluk Airport|Aupaluk, Quebec
CYLB|Lac La Biche Airport|Lac La Biche, Alberta
CYLC|Kimmirut Airport|Kimmirut, Nunavut
CYLD|Chapleau Airport|Chapleau, Ontario
CYLH|Lansdowne House Airport|Lansdowne House, Ontario
CYLJ|Meadow Lake Airport (Saskatchewan)|Meadow Lake, Saskatchewan
CYLK|Lutselk'e Airport|Lutselk'e, Northwest Territories
CYLL|Lloydminster Airport|Lloydminster, Alberta/Saskatchewan
CYLQ|La Tuque Airport|La Tuque, Quebec
CYLR|Leaf Rapids Airport|Leaf Rapids, Manitoba
CYLT|Alert Airport|Alert, Nunavut
CYLU|Kangiqsualujjuaq (Georges River) Airport|Kangiqsualujjuaq, Quebec
CYLW|Kelowna International Airport|Kelowna, British Columbia
CYMA|Mayo Airport|Mayo, Yukon
CYME|Matane Airport|Matane, Quebec
CYMG|Manitouwadge Airport|Manitouwadge, Ontario
CYMH|Mary's Harbour Airport|Mary's Harbour, Newfoundland and Labrador
CYMJ|CFB Moose Jaw (Moose Jaw/Air Vice Marshal C.M. McEwen Airport)|Moose Jaw, Saskatchewan
CYML|Charlevoix Airport|Charlevoix, Quebec
CYMM|Fort McMurray Airport|Fort McMurray, Alberta
CYMO|Moosonee Airport|Moosonee, Ontario
CYMT|Chibougamau/Chapais Airport|Chibougamau, Quebec
CYMU|Umiujaq Airport|Umiujaq, Quebec
CYMW|Maniwaki Airport|Maniwaki, Quebec
CYMX|Montréal-Mirabel International Airport (Montréal International (Mirabel) Airport)|Montreal, Quebec
CYNA|Natashquan Airport|Natashquan, Quebec
CYNC|Wemindji Airport|Wemindji, Quebec
CYND|Gatineau-Ottawa Executive Airport (Ottawa/Gatineau Airport)|Gatineau, Quebec
CYNE|Norway House Airport|Norway House, Manitoba
CYNH|Hudson's Hope Airport|Hudson's Hope, British Columbia
CYNJ|Langley Regional Airport (Langley Airport)|Langley, British Columbia
CYNL|Points North Landing Airport|Points North Landing, Saskatchewan
CYNM|Matagami Airport|Matagami, Quebec
CYNN|Nejanilini Lake Airport|Nejanilini Lake, Manitoba
CYNR|Fort MacKay/Horizon Airport|Fort MacKay, Alberta
CYOA|Ekati Airport|Ekati Diamond Mine, Northwest Territories
CYOC|Old Crow Airport|Old Crow, Yukon
CYOD|CFB Cold Lake (Cold Lake/Group Captain R.W. McNair Airport)|Cold Lake, Alberta
CYOH|Oxford House Airport|Oxford House, Manitoba
CYOJ|High Level Airport|High Level, Alberta
CYOO|Oshawa Airport|Oshawa, Ontario
CYOP|Rainbow Lake Airport|Rainbow Lake, Alberta
CYOS|Owen Sound/Billy Bishop Regional Airport (Billy Bishop Regional Airport)|Owen Sound, Ontario
CYOW|Ottawa Macdonald-Cartier International Airport (Macdonald-Cartier International Airport)|Ottawa, Ontario
CYOY|Valcartier (W/C J.H.L. (Joe) Lecomte) Heliport|Valcartier, Quebec, Quebec
CYPA|Prince Albert (Glass Field) Airport|Prince Albert, Saskatchewan
CYPC|Paulatuk Airport|Paulatuk, Northwest Territories
CYPD|Port Hawkesbury Airport|Port Hawkesbury, Nova Scotia
CYPE|Peace River Airport|Peace River, Alberta
CYPG|Portage La Prairie/Southport Airport|Portage la Prairie, Manitoba
CYPH|Inukjuak Airport|Inukjuak, Quebec
CYPK|Pitt Meadows Airport (Pitt Meadows Regional Airport)|Pitt Meadows, British Columbia
CYPL|Pickle Lake Airport|Pickle Lake, Ontario
CYPM|Pikangikum Airport|Pikangikum, Ontario
CYPN|Port-Menier Airport|Port-Menier, Quebec
CYPO|Peawanuck Airport|Peawanuck, Ontario
CYPP|Parent Airport|Parent, Quebec
CYPQ|Peterborough Airport|Peterborough, Ontario
CYPR|Prince Rupert Airport|Prince Rupert, British Columbia
CYPS|Pemberton Airport|Pemberton, British Columbia
CYPT|Pelee Island Airport|Pelee, Ontario
CYPU|Puntzi Mountain Airport|Puntzi Mountain, British Columbia
CYPW|Powell River Airport|Powell River, British Columbia
CYPX|Puvirnituq Airport|Puvirnituq, Quebec
CYPY|Fort Chipewyan Airport|Fort Chipewyan, Alberta
CYPZ|Burns Lake Airport|Burns Lake, British Columbia
CYQA|Muskoka Airport|Muskoka, Ontario
CYQB|Québec/Jean Lesage International Airport (Jean Lesage International Airport)|Quebec City, Quebec
CYQD|The Pas Airport|The Pas, Manitoba
CYQF|Red Deer Regional Airport|Red Deer, Alberta
CYQG|Windsor Airport|Windsor, Ontario
CYQH|Watson Lake Airport|Watson Lake, Yukon
CYQI|Yarmouth Airport|Yarmouth, Nova Scotia
CYQK|Kenora Airport|Kenora, Ontario
CYQL|Lethbridge County Airport (Lethbridge Airport)|Lethbridge, Alberta
CYQM|Greater Moncton International Airport (Moncton/Greater Moncton International Airport)|Moncton, New Brunswick
CYQN|Nakina Airport|Nakina, Ontario
CYQQ|CFB Comox (Comox Airport)|Comox, British Columbia
CYQR|Regina International Airport|Regina, Saskatchewan
CYQS|St. Thomas Airport (St. Thomas Municipal Airport)|St. Thomas, Ontario
CYQT|Thunder Bay International Airport (Thunder Bay Airport)|Thunder Bay, Ontario
CYQU|Grande Prairie Airport|Grande Prairie, Alberta
CYQV|Yorkton Municipal Airport|Yorkton, Saskatchewan
CYQW|North Battleford (Cameron McIntosh) Airport|North Battleford, Saskatchewan
CYQX|Gander International Airport|Gander, Newfoundland and Labrador
CYQY|J.A. Douglas McCurdy Sydney Airport|Sydney, Nova Scotia
CYQZ|Quesnel Airport|Quesnel, British Columbia
CYRA|Gamètì/Rae Lakes Airport|Gameti, Northwest Territories
CYRB|Resolute Bay Airport|Resolute, Nunavut
CYRC|Chicoutimi/Saint-Honore Aerodrome|Chicoutimi, Quebec
CYRI|Rivière-du-Loup Airport|Rivière-du-Loup, Quebec
CYRJ|Roberval Airport|Roberval, Quebec
CYRL|Red Lake Airport|Red Lake, Ontario
CYRM|Rocky Mountain House Airport|Rocky Mountain House, Alberta
CYRO|Ottawa/Rockcliffe Airport (Rockcliffe Airport)|Ottawa, Ontario
CYRP|Ottawa/Carp Airport (Carp Airport)|Carp, Ontario
CYRQ|Trois-Rivières Airport|Trois-Rivières, Quebec
CYRS|Red Sucker Lake Airport|Red Sucker Lake, Manitoba
CYRT|Rankin Inlet Airport|Rankin Inlet, Nunavut
CYRV|Revelstoke Airport|Revelstoke, British Columbia
CYSB|Sudbury Airport (Greater Sudbury Airport)|Greater Sudbury, Ontario
CYSC|Sherbrooke Airport|Sherbrooke, Quebec
CYSD|Suffield Heliport|Suffield, Alberta
CYSE|Squamish Airport|Squamish, British Columbia
CYSF|Stony Rapids Airport|Stony Rapids, Saskatchewan
CYSG|Saint-Georges Aerodrome|Saint-Georges, Quebec
CYSH|Smiths Falls-Montague Airport (Smiths Falls-Montague (Russ Beach) Airport)|Smiths Falls, Ontario
CYSJ|Saint John Airport|Saint John, New Brunswick
CYSK|Sanikiluaq Airport|Sanikiluaq, Nunavut
CYSL|Saint-Léonard Aerodrome|St. Leonard, New Brunswick
CYSM|Fort Smith Airport|Fort Smith, Northwest Territories
CYSN|St. Catharines/Niagara District Airport|St. Catharines, Ontario
CYSP|Marathon Airport (Canada)|Marathon, Ontario
CYSQ|Atlin Airport|Atlin, British Columbia
CYSR|Nanisivik Airport|Nanisivik, Nunavut
CYST|St. Theresa Point Airport|St. Theresa Point, Manitoba
CYSU|Summerside Airport|Summerside, Prince Edward Island
CYSW|Sparwood/Elk Valley Airport|Sparwood, British Columbia
CYSY|Sachs Harbour Airport|Sachs Harbour, Northwest Territories
CYSZ|Sainte-Anne-des-Monts Aerodrome|Sainte-Anne-des-Monts, Quebec
CYTA|Pembroke Airport|Pembroke, Ontario
CYTE|Cape Dorset Airport|Cape Dorset, Nunavut
CYTF|Alma Airport|Alma, Quebec
CYTH|Thompson Airport|Thompson, Manitoba
CYTL|Big Trout Lake Airport|Big Trout Lake, Ontario
CYTN|Trenton Airport (Nova Scotia)|Trenton, Nova Scotia
CYTQ|Tasiujaq Airport|Tasiujaq, Quebec
CYTR|CFB Trenton (Trenton Airport)|Trenton, Ontario
CYTS|Timmins Airport|Timmins, Ontario
CYTZ|Billy Bishop Toronto City Airport|Toronto, Ontario
CYUB|Tuktoyaktuk/James Gruben Airport|Tuktoyaktuk, Northwest Territories
CYUL|Montréal-Pierre Elliott Trudeau International Airport|Montreal, Quebec
CYUT|Repulse Bay Airport|Repulse Bay, Nunavut
CYUX|Hall Beach Airport|Hall Beach, Nunavut
CYUY|Rouyn-Noranda Airport|Rouyn-Noranda, Quebec
CYVB|Bonaventure Airport|Bonaventure, Quebec
CYVC|La Ronge (Barber Field) Airport|La Ronge, Saskatchewan
CYVD|Virden/R.J. (Bob) Andrew Field Regional Aerodrome|Virden, Manitoba
CYVG|Vermilion Airport|Vermilion, Alberta
CYVK|Vernon Regional Airport|Vernon, British Columbia
CYVM|Qikiqtarjuaq Airport|Qikiqtarjuaq, Nunavut
CYVO|Val-d'Or Airport|Val-d'Or, Quebec
CYVP|Kuujjuaq Airport|Kuujjuaq, Quebec
CYVQ|Norman Wells Airport|Norman Wells, Northwest Territories
CYVR|Vancouver International Airport|Vancouver, British Columbia
CYVT|Buffalo Narrows Airport|Buffalo Narrows, Saskatchewan
CYVV|Wiarton Airport|Wiarton, Ontario
CYVZ|Deer Lake Airport (Ontario)|Deer Lake, Ontario
CYWA|Petawawa Airport|Petawawa, Ontario
CYWG|Winnipeg James Armstrong Richardson International Airport (Winnipeg International Airport)|Winnipeg, Manitoba
CYWH|Victoria Inner Harbour Airport (Victoria Harbour Water Airport)|Victoria, British Columbia
CYWJ|Déline Airport|Deline, Northwest Territories
CYWK|Wabush Airport|Wabush, Newfoundland and Labrador
CYWL|Williams Lake Airport (Williams Lake Regional Airport)|Williams Lake, British Columbia
CYWM|Athabasca Airport|Athabasca, Alberta
CYWP|Webequie Airport|Webequie, Ontario
CYWV|Wainwright Airport (Alberta)|Wainwright, Alberta
CYWY|Wrigley Airport|Wrigley, Northwest Territories
CYXC|Cranbrook/Canadian Rockies International Airport|Cranbrook, British Columbia
CYXD|Edmonton City Centre (Blatchford Field) Airport (Edmonton City Centre Airport)|Edmonton, Alberta
CYXE|Saskatoon/John G. Diefenbaker International Airport (Saskatoon International Airport)|Saskatoon, Saskatchewan
CYXH|Medicine Hat Airport|Medicine Hat, Alberta
CYXJ|Fort St. John Airport (North Peace Airport)|Fort St. John, British Columbia
CYXK|Rimouski Airport|Rimouski, Quebec
CYXL|Sioux Lookout Airport|Sioux Lookout, Ontario
CYXN|Whale Cove Airport|Whale Cove, Nunavut
CYXP|Pangnirtung Airport|Pangnirtung, Nunavut
CYXQ|Beaver Creek Airport|Beaver Creek, Yukon
CYXR|Earlton (Timiskaming Regional) Airport|Earlton, Ontario
CYXS|Prince George Airport|Prince George, British Columbia
CYXT|Terrace Airport|Terrace, British Columbia
CYXU|London International Airport (London Airport)|London, Ontario
CYXX|Abbotsford International Airport|Abbotsford, British Columbia
CYXY|Whitehorse International Airport|Whitehorse, Yukon
CYXZ|Wawa Airport|Wawa, Ontario
CYYB|North Bay/Jack Garland Airport (North Bay Airport)|North Bay, Ontario
CYYC|Calgary International Airport|Calgary, Alberta
CYYD|Smithers Airport|Smithers, British Columbia
CYYE|Fort Nelson Airport|Fort Nelson, British Columbia
CYYF|Penticton Regional Airport (Penticton Airport, Penticton Airport (South Okanagan Regional Airport))|Penticton, British Columbia
CYYG|Charlottetown Airport|Charlottetown, Prince Edward Island
CYYH|Taloyoak Airport|Taloyoak, Nunavut
CYYJ|Victoria International Airport|Victoria, British Columbia
CYYL|Lynn Lake Airport|Lynn Lake, Manitoba
CYYM|Cowley Airport|Cowley, Alberta
CYYN|Swift Current Airport|Swift Current, Saskatchewan
CYYO|Wynyard Airport|Wynyard, Saskatchewan
CYYQ|Churchill Airport|Churchill, Manitoba
CYYR|CFB Goose Bay (Goose Bay Airport)|Happy Valley-Goose Bay, Newfoundland and Labrador
CYYT|St. John's International Airport|St. John's, Newfoundland and Labrador
CYYU|Kapuskasing Airport|Kapuskasing, Ontario
CYYW|Armstrong Airport|Armstrong, Ontario
CYYY|Mont-Joli Airport|Mont-Joli, Quebec
CYYZ|Toronto Pearson International Airport (Toronto/Lester B. Pearson International Airport, Pearson Airport)|Toronto, Ontario
CYZD|Toronto/Downsview Airport (Downsview Airport)|Toronto, Ontario
CYZE|Gore Bay-Manitoulin Airport|Gore Bay, Ontario
CYZF|Yellowknife Airport|Yellowknife, Northwest Territories
CYZG|Salluit Airport|Salluit, Quebec
CYZH|Slave Lake Airport|Slave Lake, Alberta
CYZP|Sandspit Airport|Sandspit, British Columbia
CYZR|Sarnia (Chris Hadfield) Airport|Sarnia, Ontario
CYZS|Coral Harbour Airport|Coral Harbour, Nunavut
CYZT|Port Hardy Airport|Port Hardy, British Columbia
CYZU|Whitecourt Airport|Whitecourt, Alberta
CYZV|Sept-Îles Airport|Sept-Îles, Quebec
CYZW|Teslin Airport|Teslin, Yukon
CYZX|CFB Greenwood (Greenwood Airport)|Greenwood, Nova Scotia
CYZY|Mackenzie Airport|Mackenzie, British Columbia
CZAC|York Landing Airport|York Landing, Manitoba
CZAM|Salmon Arm Airport|Salmon Arm, British Columbia
CZBA|Burlington Airpark|Burlington, Ontario
CZBB|Boundary Bay Airport|Delta, British Columbia
CZBD|Ilford Airport|Ilford, Manitoba
CZBF|Bathurst Airport|Bathurst, New Brunswick
CZBM|Bromont Airport|Bromont, Quebec
CZEE|Kelsey Airport|Kelsey, Manitoba
CZEM|Eastmain River Airport|Eastmain, Quebec
CZFA|Faro Airport (Yukon)|Faro, Yukon
CZFD|Fond-du-Lac Airport|Fond-du-Lac, Saskatchewan
CZFG|Pukatawagan Airport|Pukatawagan, Manitoba
CZFM|Fort McPherson Airport|Fort McPherson, Northwest Territories
CZFN|Tulita Airport|Tulita, Northwest Territories
CZGF|Grand Forks Airport|Grand Forks, British Columbia
CZGI|Gods River Airport|Gods River, Manitoba
CZGR|Little Grand Rapids Airport|Little Grand Rapids, Manitoba
CZHP|High Prairie Airport|High Prairie, Alberta
CZJG|Jenpeg Airport|Jenpeg, Manitoba
CZJN|Swan River Airport|Swan River, Manitoba
CZKE|Kashechewan Airport|Kashechewan First Nation, Ontario
CZLQ|Thicket Portage Airport|Thicket Portage, Manitoba
CZMD|Muskrat Dam Airport|Muskrat Dam, Ontario
CZML|South Cariboo Regional Airport (108 Mile Ranch Airport)|South Cariboo, British Columbia
CZMN|Pikwitonei Airport|Pikwitonei, Manitoba
CZMT|Masset Airport|Masset, British Columbia
CZNG|Poplar River Airport|Poplar River, Manitoba
CZNL|Nelson Airport, Canada|Nelson, British Columbia
CZPB|Sachigo Lake Airport|Sachigo Lake, Ontario
CZPC|Pincher Creek Airport|Pincher Creek, Alberta
CZPO|Pinehouse Lake Airport|Pinehouse Lake, Saskatchewan
CZRJ|Round Lake (Weagamow Lake) Airport|Round Lake, Ontario
CZSJ|Sandy Lake Airport|Sandy Lake, Ontario
CZSN|South Indian Lake Airport|South Indian Lake, Manitoba
CZST|Stewart Airport (British Columbia)|Stewart, British Columbia
CZSW|Prince Rupert/Seal Cove Water Airport|Prince Rupert, British Columbia
CZTA|Bloodvein River Airport|Bloodvein River, Manitoba
CZTM|Shamattawa Airport|Shamattawa, Manitoba
CZUC|Ignace Municipal Airport|Ignace, Ontario
CZUM|Churchill Falls Airport|Churchill Falls, Newfoundland and Labrador
CZVL|Edmonton/Villeneuve Airport (Villeneuve Airport)|Villeneuve, Alberta
CZWH|Lac Brochet Airport|Lac Brochet, Manitoba
CZWL|Wollaston Lake Airport|Wollaston Lake, Saskatchewan
DAAB|Blida Airport|Blida
DAAE|Soummam Airport|Bejaia
DAAG|Houari Boumedienne Airport|Algiers
DAAJ|Tiska Airport|Djanet
DAAK|Boufarik Airport|Boufarik
DAAP|Illizi Airport|Illizi
DAAS|Ain Arnat Airport|Setif
DAAT|Tamanrasset Airport|Tamanrasset
DAAV|Jijel Ferhat Abbas Airport|Jijel
DAAY|Mecheria Air Base|Mecheria
DAAZ|Relizane Airport|Relizane
DABB|Rabah Bitat Airport|Annaba
DABC|Mohamed Boudiaf International Airport|Constantine
DABP|Skikda Airport|Skikda
DABS|Tébessa Airport|Tébessa
DABT|Batna Airport|Batna
DAFH|Hassi R'Mel Airport|Hassi R'Mel
DAFI|Tsletsi Airport|Djelfa
DAOB|Bou Chekif Airport|Tiaret
DAOF|Tindouf Airport|Tindouf
DAOI|Chlef International Airport|Chlef
DAOL|Oran Tafaraoui Airport|Oran
DAON|Zenata Airport|Tlemcen
DAOO|Es Senia Airport|Oran
DAOR|Béchar Ouakda Airport|Béchar
DAOV|Ghriss Airport|Ghriss
DATG|In Guezzam Airport|In Guezzam
DATM|Bordj Mokhtar Airport|Bordj Mokhtar
DAUA|Touat Cheikh Sidi Mohamed Belkebir Airport|Adrar
DAUB|Biskra Airport|Biskra
DAUE|El Golea Airport|El Golea
DAUG|Noumerate Airport|Ghardaia
DAUH|Oued Irara Airport|Hassi Messaoud
DAUI|In Salah Airport|In Salah
DAUK|Touggourt Sidi Madhi Airport|Touggourt
DAUL|L'Mekrareg Airport|Laghouat
DAUO|Guemar Airport|El Oued
DAUT|Timimoun Airport|Timimoun
DAUU|Ain el Beida Airport|Ouargla
DAUZ|In Amenas Airport|In Amenas
DBBB|Cadjehoun Airport (Cotonou Airport)|Cotonou
DBBC|Cana Airport|Bohicon
DBBD|Djougou Airport|Djougou
DBBK|Kandi Airport|Kandi
DBBN|Natitingou Airport|Natitingou
DBBO|Porga Airport|Porga
DBBP|Parakou Airport|Parakou
DBBR|Bembereke Airport|Bembereke
DBBS|Savé Airport|Savé
DFCA|Kaya Airport|Kaya
DFCC|Ouahigouya Airport|Ouahigouya
DFCJ|Djibo Airport|Djibo
DFCL|Leo Airport|Leo
DFEA|Boulsa Airport|Boulsa
DFEB|Bogande Airport|Bogande
DFED|Diapaga Airport|Diapaga
DFEE|Dori Airport|Dori
DFEF|Fada N'gourma Airport|Fada N'gourma
DFEG|Gorom Gorom Airport|Gorom Gorom
DFEL|Kantchari Airport|Kantchari
DFEM|Tambao Airport|Tambao
DFEP|Pama Airport|Pama
DFES|Sebba Airport|Sebba
DFET|Tenkodogo Airport|Tenkodogo
DFEZ|Zabre Airport|Zabré
DFFD|Ouagadougou Airport|Ouagadougou
DFOB|Banfora Airport|Banfora
DFOD|Dedougou Airport|Dedougou
DFON|Nouna Airport|Nouna
DFOO|Bobo Dioulasso Airport|Bobo Dioulasso
DFOT|Tougan Airport|Tougan
DFOU|Diebougou Airport|Diebougou
DFOY|Aribinda Airport|Aribinda
DGAA|Kotoka International Airport|Accra
DGLE|Tamale Airport|Tamale
DGLN|Navrongo Airport|Navrongo
DGLW|Wa Airport|Wa
DGLY|Yendi Airport|Yendi
DGSI|Kumasi Airport|Kumasi
DGSN|Sunyani Airport|Sunyani
DGTK|Takoradi Airport|Takoradi
DIAO|Aboisso Airport|Aboisso
DIAP|Port Bouet Airport (Felix Houphouet Boigny International Airport)|Abidjan
DIAU|Abengourou Airport|Abengourou
DIBI|Boundiali Airport|Boundiali
DIBK|Bouake Airport|Bouake
DIBN|Tehini Airport|Bouna
DIBU|Soko Airport|Bondoukou
DIDK|Dimbokro Airport|Dimbokro
DIDL|Daloa Airport|Daloa
DIDV|Divo Airport|Divo
DIFK|Ferkessedougou Airport|Ferkessedougou
DIGA|Gagnoa Airport|Gagnoa
DIGL|Guiglo Airport|Guiglo
DIKO|Korhogo Airport|Korhogo
DIMN|Man Airport|Man
DIOD|Odienne Airport|Odienne
DIOF|Ouango Fitini Airport|Ouango Fitini
DISG|Seguela Airport|Seguela
DISP|San Pédro Airport|San Pédro
DISS|Sassandra Airport|Sassandra
DITB|Tabou Airport|Tabou
DITM|Mahana Airport|Touba
DIYO|Yamoussoukro Airport|Yamoussoukro
DNAA|Nnamdi Azikiwe International Airport|Abuja, FCT
DNAK|Akure Airport|Akure, Ondo State
DNBE|Benin Airport|Benin City, Edo State
DNBI|Bida Airstrip|Bida, Borno State
DNCA|Magaret Ekpo International Airport|Calabar, Cross River State
DNEN|Akanu Ibiam International Airport|Enugu, Enugu State
DNGU|Gusau Airstrip|Gusau, Zamfara State
DNIB|Ibadan Airport|Ibadan, Oyo State
DNIL|Ilorin International Airport|Ilorin, Kwara State
DNIM|Sam Mbakwe International Cargo Airport|Owerri, Imo State
DNJO|Jos Airport|Jos, Plateau State
DNKA|Kaduna International Airport|Kaduna, Kaduna State
DNKN|Mallam Aminu Kano International Airport|Kano, Kano State
DNMA|Maiduguri International Airport|Maiduguri, Borno State
DNMK|Makurdi Air Force Base|Makurdi, Benue State
DNMM|Murtala Mohammed International Airport|Ikeja, Lagos State
DNMN|Minna Airport|Minna, Niger State
DNOS|Osogbo Airstrip|Osogbo, Osun State
DNPO|Port Harcourt International Airport|Port Harcourt, Rivers State
DNSO|Sadiq Abubakar III International Airport|Sokoto, Sokoto State
DNYO|Yola Airport|Yola, Adamawa State
DNZA|Zaria Airport|Zaria, Adamawa State
DRRA|Tessaoua Airport|Tessaoua
DRRC|Dogondoutchi Airport|Dogondoutchi
DRRD|Dosso Airport|Dosso
DRRE|Téra Airport|Téra
DRRG|Gaya Airport|Gaya
DRRL|Tillabery Airport|Tillabery
DRRM|Maradi Airport|Maradi
DRRN|Diori Hamani International Airport|Niamey
DRRP|La Tapoa Airport|La Tapoa
DRRT|Tahoua Airport|Tahoua
DRRU|Ouallam Airport|Ouallam
DRZA|Mano Dayak International Airport|Agades South
DRZD|Dirkou Airport - Dirkou|
DRZF|Diffa Airport|Diffa
DRZG|Goure Airport|Goure
DRZI|Iferouane Airport|Iferouane
DRZL|Arlit Airport|Arlit
DRZM|Maine-Soroa Airport|Maine-Soroa
DRZR|Zinder Airport|Zinder
DTKA|Tabarka - 7 Novembre International Airport|Tabarka
DTMB|Monastir - Habib Bourguiba International Airport|Monastir
DTTA|Tunis - Carthage International Airport|Tunis
DTTF|Gafsa - Ksar International Airport|Gafsa
DTTG|Gabès - Matmata International Airport|Gabès
DTTJ|Djerba - Zarzis International Airport|Djerba
DTTX|Thyna/El Maou Airport|Sfax
DTTZ|Tozeur - Nefta International Airport|Tozeur
DTNZ|Enfidha - Zine El Abidine Ben Ali International Airport|Enfidha
DXAK|Akpaka Airport|Atakpame
DXDP|Djangou Airport|Dapaong
DXKP|Kolokope Airport|Anie
DXMG|Sansanné-Mango Airport|Sansanné-Mango
DXNG|Niamtougou International Airport|Niamtougou
DXSK|Sokode Airport|Sokode
DXXX|Lomé-Tokoin Airport|Lomé
EBAW|Antwerp International Airport|Antwerp / Deurne
EBBE|Beauvechain Air Base|Beauvechain
EBBL|Kleine Brogel Air Base|Kleine Brogel
EBBR|Brussels Airport|Brussels / Zaventem
EBBT|Brasschaat AB|Brasschaat
EBBX|Jehonville Air Base|Bertrix
EBCI|Brussels South Charleroi Airport|Charleroi
EBCF|Cerfontaine AB|Cerfontaine
EBCV|Chievres AB (U.S. Air Force)|Chievres
EBFN|Koksijde AB|Koksijde
EBFS|Florennes Air Base|Florennes
EBGB|Grimbergen Airfield|Grimbergen
EBHN|Hoevenen Airport|Hoevenen
EBKH|Balen-Keiheuvel Airport|Balen-Keiheuvel
EBKT|Kortrijk-Wevelgem International Airport|Kortrijk / Wevelgem
EBLG|Liege Airport|Liège
EBLE|Beverlo Air Base|Leopoldsburg
EBMB|Melsbroek Air Base|Brussels
EBNM|Suarlee Airport|Namur
EBOS|Ostend-Bruges International Airport|Ostend
EBSG|Saint-Ghislain AB|Saint-Ghislain
EBSH|Saint-Hubert Airport|Saint-Hubert
EBSL|Zutendaal AB|Zutendaal
EBSP|La Sauveniere Airport|Spa
EBST|Sint-Truiden AB|Sint-Truiden
EBSU|Saint-Hubert Air Base|Saint-Hubert
EBTN|Goetsenhoven AB|Goetsenhoven
EBTX|Verviers Airport|Theux
EBTY|Maubray Airport|Tournai
EBUL|Ursel AB|Ursel
EBWE|Weelde Air Base|Weelde
EBZH|Hasselt Airport|Hasselt
EBZR|Zoersel-Oostmalle Airfield - Zoersel / Oostmalle|
EBZW|Zwartberg Airport|Genk
EDAC|Leipzig-Altenburg Airport|Altenburg/Leipzig
EDAD|Dessau Airport|Dessau
EDAX|Lärz/Rechlin Airport|Rechlin
EDCD|Cottbus-Drewitz Airport|Cottbus
EDCI|Klix Airfield - Bautzen|
EDDB|Berlin-Schönefeld International Airport (to be expanded and renamed Berlin Brandenburg International Airport in 2011)|Berlin
EDDC|Dresden Klotzsche Airport|Dresden
EDDE|Erfurt Airport|Erfurt
EDDF|Frankfurt International Airport|Frankfurt am Main
EDDG|Münster Osnabrück International Airport|Greven
EDDH|Hamburg Airport|Hamburg
EDDI|Tempelhof International Airport (closed in 2008)|Berlin
EDDK|Cologne Bonn Airport|Cologne/Bonn
EDDL|Düsseldorf International Airport|Düsseldorf
EDDM|Munich International Airport (Franz Josef Strauß International Airport)|Munich
EDDN|Nuremberg Airport|Nuremberg
EDDP|Leipzig/Halle Airport|Leipzig/Halle
EDDR|Saarbrücken Airport|Saarbrücken
EDDS|Stuttgart Echterdingen Airport|Stuttgart
EDDT|Tegel International Airport (closing in 2011)|Berlin
EDDV|Hanover/Langenhagen International Airport|Hanover
EDDW|Bremen Airport|Bremen
EDFE|Frankfurt Egelsbach Airport|Hesse
EDFH|Frankfurt-Hahn Airport|Rhineland-Palatinate
EDFM|Mannheim City Airport|Mannheim
EDFZ|Mainz-Finthen|Mainz
EDGS|Siegerland Airport|Burbach
EDHE|Uetersen Airport|Heist
EDHI|Hamburg Finkenwerder Airport|Hamburg
EDHK|Kiel Holtenau Airport|Kiel
EDHL|Lübeck Airport|Lübeck
EDIU|Heidelberg Airport|Heidelberg
EDJA|Allgäu Airport|Memmingen
EDKA|Aachen-Merzbrück Airport|Aachen
EDKB|Bonn-Hangelar Airport|Sankt Augustin
EDKL|Leverkusen Airport|Leverkusen
EDKV|Dahlemer Binz Airport|Dahlem
EDLC|Kamp-Lintfort|Wesel
EDLG|Goch-Asperden Airport|Goch
EDLK|Krefeld-Egelsberg Airport|Krefeld
EDLN|Düsseldorf-Mönchengladbach Airport|Mönchengladbach
EDLP|Paderborn Lippstadt Airport|Paderborn / Lippstadt
EDLS|Stadtlohn-Vreden Airport|Stadtlohn
EDLV|Weeze Airport (formerly Niederrhein Airport)|Weeze
EDLW|Dortmund Airport|Dortmund
EDNY|Bodensee Airport|Friedrichshafen
EDMA|Augsburg Airport|Augsburg
EDMQ|Donauwörth Airport|Genderkingen
EDOJ|Lüsse|Lüsse
EDOP|Schwerin-Parchim Airport|Parchim
EDQD|Bindlacher Berg Airport (Bayreuth Airport)|Bayreuth
EDQM|Hof-Plauen Airfield|Hof/Plauen
EDRB|Bitburg Airport|Bitburg
EDRI|Linkenheim Airport|Linkenheim-Hochstetten
EDRK|Koblenz Winningen|Winningen, Mosel
EDRZ|Zweibrücken Airport|Zweibrücken
EDSB|Baden Airpark|Baden-Baden / Karlsruhe
EDTY|Adolf Würth Airport|Schwäbisch Hall
EDTX|Weckrieden|Schwäbisch Hall
EDVK|Kassel Calden Airport|Kassel
EDWB|Bremerhaven Airport|Bremerhaven
EDXH|Heligoland Airport|Heligoland
EDXM|St. Michaelisdonn|St. Michaelisdonn
EDXW|Sylt Airport|Westerland, Sylt
ETAD|Spangdahlem Air Base|Spangdahlem
ETAR|Ramstein Air Base|Ramstein
ETHA|Altenstadt Army Base|Altenstadt
ETHB|Bückeburg Army Base|Bückeburg
ETHC|Celle Air Base|Celle
ETHE|Rheine Air Base|Rheine
ETHF|Fritzlar Army Base|Fritzlar
ETHL|Laupheim Army Base|Laupheim
ETHM|Mendig Army Base|Niedermendig
ETHR|Roth Army Base|Roth
ETHS|Fassberg Army Base|Fassberg
ETMN|Nordholz Naval Air Station|Nordholz
ETND|Diepholz Air Base|Diepholz
ETNG|NATO Air Base Geilenkirchen|Geilenkirchen
ETNH|Hohn Air Base|Hohn
ETNJ|Jever Air Base|Schortens
ETNL|Rostock Laage Airport|Rostock
ETNN|Nörvenich Air Base|Nörvenich
ETNS|Schleswig Air Base|Schleswig
ETNT|Wittmundhafen Air Base|Wittmund
ETNW|Wunstorf Air Base|Wunstorf
ETOR|Coleman Army Airfield|Mannheim
ETOU|Wiesbaden Army Airfield|Wiesbaden
ETSA|Landsberg-Lech Air Base|Landsberg am Lech
ETSB|Büchel Air Base|Büchel / Cochem
ETSE|Erding Air Base|Erding
ETSF|Fürstenfeldbruck Air Base|Fürstenfeldbruck
ETSH|Holzdorf Air Base|Jessen (Elster)
ETSI|Ingolstadt Manching Airport|Ingolstadt
ETSL|Lechfeld Air Base|Lechfeld
ETUL|RAF Laarbruch|Weeze (closed in 1999, now Weeze Airport, NRN/EDLV)
ETUO|RAF Gütersloh|Gütersloh (closed in 1993)
ETUR|RAF Brüggen|Brüggen (closed in 2001)
ETWM|Meppen Air Base|Meppen
EEEI|Ämari Air Base|Ämari
EEKA|Kärdla Airport|Kärdla, Hiiumaa
EEKE|Kuressaare Airport|Kuressaare, Saaremaa
EEKU|Kihnu Airfield|Kihnu
EENI|Nurmsi Airfield|Nurmsi
EENA|Narva Airfield|Narva
EEPU|Pärnu Airport|Pärnu
EERA|Rapla Airfield|Rapla
EERI|Ridali Airfield|Ridali
EERU|Ruhnu Airfield|Ruhnu
EETA|Tapa Airfield|Tapa
EETN|Tallinn Airport|Tallinn
EETU|Tartu Airport|Tartu
EEVI|Viljandi Airfield|Viljandi
EFAH|Ahmosuo Airport|Ahmosuo
EFAL|Alavus Airport|Alavus
EFET|Enontekiö Airport|Enontekiö
EFEU|Eura Airport|Eura
EFFO|Forssa Airport|Forssa
EFHA|Halli Airport|Kuorevesi
EFHF|Helsinki-Malmi Airport|Helsinki
EFHK|Helsinki-Vantaa Airport|Vantaa
EFHM|Hämeenkyrö Airport|Hämeenkyrö
EFHN|Hanko Airport (Hangö Airport)|Hanko (Hangö)
EFHV|Hyvinkää Airport|Hyvinkää
EFIK|Kiikala Airport|Kiikala
EFIL|Seinäjoki Airport|Seinäjoki / Ilmajoki
EFIM|Immola Airport|Immola
EFIT|Kitee Airport|Kitee
EFIV|Ivalo Airport|Ivalo / Inari
EFJM|Jämijärvi Airport|Jämijärvi
EFJO|Joensuu Airport|Joensuu / Liperi
EFJY|Jyväskylä Airport|Jyväskylän maalaiskunta
EFKA|Kauhava Airport|Kauhava
EFKE|Kemi-Tornio Airport|Kemi / Tornio
EFKI|Kajaani Airport|Kajaani
EFKJ|Kauhajoki Airport|Kauhajoki
EFKK|Kronoby Airport (Kokkola and Jakobstad Airport)|Kronoby / Kokkola / Jakobstad
EFKM|Kemijärvi Airport|Kemijärvi
EFKO|Kalajoki Airport|Kalajoki
EFKS|Kuusamo Airport|Kuusamo
EFKT|Kittilä Airport|Kittilä
EFKU|Kuopio Airport|Kuopio / Siilinjärvi
EFKV|Kivijärvi Airport|Kivijärvi
EFKY|Kymi Airport|Kymi
EFLA|Vesivehmaa Airport|Lahti
EFLP|Lappeenranta Airport|Lappeenranta
EFMA|Mariehamn Airport|Mariehamn
EFME|Menkijärvi Airport|Menkijärvi
EFMI|Mikkeli Airport|Mikkeli
EFNU|Nummela Airport|Nummela
EFOU|Oulu Airport|Oulunsalo
EFPI|Piikajärvi Airport|Piikajärvi
EFPK|Pieksämäki Airport|Pieksämäki
EFPO|Pori Airport|Pori
EFPU|Pudasjärvi Airport|Pudasjärvi
EFPY|Pyhäsalmi Airport|Pyhäsalmi
EFRH|Pattijoki Airport|Raahe
EFRN|Rantasalmi Airport|Rantasalmi
EFRO|Rovaniemi Airport|Rovaniemi
EFRU|Ranua Airport|Ranua
EFRV|Kiuruvesi Airport|Kiuruvesi
EFRY|Räyskälä Airport|Räyskälä
EFSA|Savonlinna Airport|Savonlinna
EFSE|Selänpää Airport|Selänpää
EFSI|Seinajoki Airport|Seinajoki
EFSO|Sodankylä Airport|Sodankylä
EFTP|Tampere-Pirkkala Airport|Tampere / Pirkkala
EFTS|Teisko Airport|Teisko
EFTU|Turku Airport|Turku
EFUT|Utti Airport|Utti / Valkeala
EFVA|Vaasa Airport|Vaasa
EFVR|Varkaus Airport|Varkaus / Joroinen
EFYL|Ylivieska Airport|Ylivieska
EGAA|Belfast International Airport|Belfast, Northern Ireland
EGAB|Enniskillen/St Angelo Airport|Enniskillen, Northern Ireland
EGAC|George Best Belfast City Airport|Belfast, Northern Ireland
EGAD|Newtownards Airport|Newtownards, Northern Ireland
EGAE|City of Derry Airport|Derry, Northern Ireland
EGBB|Birmingham International Airport|Birmingham, England
EGBC|Cheltenham Racecourse Heliport|Cheltenham Racecourse, England
EGBD|Derby Airfield|Derby, England
EGBE|Coventry Airport|Coventry, England
EGBG|Leicester Airport|Leicester, England
EGBJ|Gloucestershire Airport|Staverton, England
EGBK|Sywell Aerodrome|Northampton, England
EGBM|Tatenhill Airfield|Tatenhill, England
EGBN|Nottingham Airport|Nottingham, England
EGBO|Wolverhampton Airport|Wolverhampton, England
EGBP|Kemble Airport|Kemble, England
EGBS|Shobdon Aerodrome|Leominster, England
EGBT|Turweston Aerodrome|Turweston, England
EGBV|Silverstone Heliport|Silverstone, England
EGBW|Wellesbourne Mountford Airfield|Wellesbourne, England
EGCB|City Airport Manchester|Manchester, England
EGCC|Manchester Airport|Manchester, England
EGCD|Woodford Aerodrome|Stockport, England
EGCF|Sandtoft Airfield|Scunthorpe, England
EGCG|Strubby Airfield|Strubby, England
EGCJ|Sherburn-in-Elmet Airfield|Sherburn-in-Elmet, England
EGCK|Caernarfon Airport|Caernarfon, Wales
EGCL|Fenland Airfield|Spalding, England
EGCN|Robin Hood Airport Doncaster Sheffield|South Yorkshire, England
EGCO|Southport Birkdale Sands Airport|Southport, England
EGCS|Sturgate Airfield|Lincoln, England
EGCV|Sleap Airfield|Shrewsbury, England
EGCW|Welshpool Airport|Welshpool, Wales
EGDC|Royal Marines Base Chivenor|Braunton, England
EGDJ|Upavon Airfield|Upavon, England
EGDL|RAF Lyneham|Wiltshire, England
EGDM|MoD Boscombe Down|Amesbury, England
EGDN|Airfield Camp Netheravon|Netheravon, England
EGDO|RNAS Predannack|Mullion, England
EGDP|RNAS Portland Heliport|Portland Harbour, England
EGDR|RNAS Culdrose|Helston, England
EGDS|Salisbury Plain Airport|Bulford, England
EGDT|Wroughton Airport|Wroughton, England
EGDV|Hullavington Airport|Hullavington, England
EGDW|RNAS Merryfield|Yeovil, England
EGDX|MoD Saint Athan|St Athan, Wales
EGDY|RNAS Yeovilton|Yeovil, England
EGEC|Campbeltown Airport|Campbeltown, Scotland
EGED|Eday Airport|Eday, Scotland
EGEF|Fair Isle Airport|Fair Isle, Scotland
EGEH|Whalsay Airport|Whalsay, Scotland
EGEN|North Ronaldsay Airport|North Ronaldsay, Scotland
EGEO|Oban Airport|Oban, Scotland
EGEP|Papa Westray Airport|Papa Westray, Scotland
EGER|Stronsay Airport|Stronsay, Scotland
EGES|Sanday Airport|Sanday, Scotland
EGET|Tingwall Airport|Lerwick, Scotland
EGEW|Westray Airport|Westray, Scotland
EGFA|Aberporth Airport|Cardigan, Wales
EGFC|Cardiff Heliport|Cardiff, Wales
EGFE|Haverfordwest Aerodrome|Haverfordwest, Wales
EGFF|Cardiff International Airport|Cardiff, Wales
EGFH|Swansea Airport|Swansea, Wales
EGFP|Pembrey Airport|Pembrey, Wales
EGGD|Bristol International Airport|Bristol, England
EGGP|Liverpool John Lennon Airport|Liverpool, England
EGGW|London Luton Airport|London, England
EGHA|Compton Abbas Airfield|Shaftesbury, England
EGHB|Maypole Airfield|Maypole (Hoath), England
EGHC|Land's End Airport|St Just in Penwith, England
EGHD|Plymouth City Airport|Plymouth, England
EGHE|St. Mary's Airport|St. Mary's, England
EGHG|Yeovil/Westland Airport|Yeovil, England
EGHH|Bournemouth Airport|Bournemouth, England
EGHI|Southampton Airport|Southampton, England
EGHJ|Bembridge Airport|Sandown, England
EGHK|Penzance Heliport|Penzance, England
EGHL|Lasham Airfield|Basingstoke, England
EGHN|Isle of Wight/Sandown Airport|Sandown, England
EGHO|Thruxton Aerodrome|Andover, England
EGHP|Popham Airfield|Popham, England
EGHR|Chichester (Goodwood) Airfield|Chichester, West Sussex, England
EGHS|Henstridge Airfield|Henstridge, England
EGHT|Tresco Heliport|Tresco, England
EGHU|Eaglescott Airfield|Great Torrington, England
EGHY|Truro Aerodrome|Truro, England
EGJA|Alderney Airport|Alderney, Channel Islands
EGJB|Guernsey Airport|Guernsey, Channel Islands
EGJJ|Jersey Airport & Aviation Beauport|Jersey, Channel Islands
EGKA|Shoreham Airport|Shoreham-by-Sea, England
EGKB|London Biggin Hill Airport|London, England
EGKE|Challock Airport|Challock, England
EGKG|Goodwood Racecourse Heliport|Goodwood Racecourse, England
EGKH|Lashenden/Headcorn Airport|Maidstone, England
EGKK|London Gatwick Airport|London, England
EGKR|Redhill Aerodrome|Redhill, England
EGLA|Bodmin Airfield|Bodmin, England
EGLC|London City Airport|London, England
EGLD|Denham Aerodrome|Gerrards Cross, England
EGLF|Farnborough Airfield|Farnborough, England
EGLG|Panshanger Airport|Hertford, England
EGLJ|Chalgrove Airfield|Oxford, England
EGLK|Blackbushe Airport|Camberley, England
EGLL|London Heathrow Airport|London, England
EGLM|White Waltham Airfield|White Waltham, England
EGLS|Old Sarum Airfield|Salisbury, England
EGLT|Ascot Racecourse Heliport|Ascot Racecourse, England
EGLW|London Heliport|London, England
EGMA|Fowlmere Airport|Cambridge, England
EGMC|London Southend Airport|Southend-on-Sea, England
EGMD|London Ashford Airport|Lydd, England
EGMH|Kent International Airport|Canterbury, England
EGMJ|Little Gransden Airfield|St Neots, England
EGML|Damyns Hall Aerodrome|Upminster, England
EGNA|Hucknall Airfield|Nottingham, England
EGNB|Brough Aerodrome|Brough, England
EGNC|Carlisle Airport|Carlisle, England
EGNE|Gamston Airport|Retford, England
EGNF|Netherthorpe Airfield|Worksop, England
EGNH|Blackpool International Airport|Blackpool, England
EGNJ|Humberside Airport|Kingston upon Hull, England
EGNL|Barrow/Walney Island Airfield|Barrow-in-Furness, England
EGNM|Leeds Bradford International Airport|West Yorkshire, England
EGNO|Warton Aerodrome|Preston, England
EGNR|Hawarden Airport|Chester, England
EGNS|Isle of Man Airport|Isle of Man
EGNT|Newcastle Airport|Newcastle upon Tyne, England
EGNU|Full Sutton Airfield|York, England
EGNV|Durham Tees Valley Airport|Tees Valley, England
EGNW|Wickenby Aerodrome|Lincoln, England
EGNX|Nottingham East Midlands Airport|East Midlands, England
EGNY|Beverley/Linley Hill Airfield|Beverley, England
EGOD|Llanbedr Airport|Llanbedr, Wales
EGOE|RAF Ternhill|Ternhill, England
EGOQ|RAF Mona|Anglesey, Wales
EGOS|RAF Shawbury|Shawbury, England
EGOV|RAF Valley/Anglesey Airport|Anglesey, Wales
EGOW|RAF Woodvale|Formby, England
EGPA|Kirkwall Airport|Kirkwall, Scotland
EGPB|Sumburgh Airport|Shetland Islands, Scotland
EGPC|Wick Airport|Wick, Scotland
EGPD|Aberdeen Airport|Aberdeen, Scotland
EGPE|Inverness Airport|Inverness, Scotland
EGPF|Glasgow International Airport|Glasgow, Scotland
EGPG|Cumbernauld Airport|Cumbernauld, Scotland
EGPH|Edinburgh Airport|Edinburgh, Scotland
EGPI|Islay Airport|Islay, Scotland
EGPJ|Fife Airport|Glenrothes, Scotland
EGPK|Glasgow Prestwick International Airport|Glasgow, Scotland
EGPL|Benbecula Airport|Benbecula, Scotland
EGPM|Scatsta Airport|Lerwick, Scotland
EGPN|Dundee Airport|Dundee, Scotland
EGPO|Stornoway Airport|Stornoway, Scotland
EGPR|Barra Airport|Barra, Scotland
EGPT|Perth Airport (Scotland)|Perth, Scotland
EGPU|Tiree Airport|Tiree, Scotland
EGQK|RAF Kinloss|Kinloss, Scotland
EGQL|RAF Leuchars|Leuchars, Scotland
EGQM|RAF Boulmer|Alnwick, England
EGQS|RAF Lossiemouth|Lossiemouth, Scotland
EGSA|Shipdham Airport|Shipdham, England
EGSB|Bedford Castle Mill Airport|Bedford, England
EGSC|Cambridge Airport|Cambridge, England
EGSD|Great Yarmouth - North Denes Airport|Great Yarmouth, England
EGSF|Peterborough Business Airport|Peterborough, England
EGSG|Stapleford Aerodrome|Romford, England
EGSH|Norwich International Airport|Norwich, England
EGSJ|Seething Airfield|Norwich, England
EGSK|Hethel Airport|Hethel, England
EGSL|Andrewsfield Airport|Braintree, England
EGSM|Beccles Airport|Beccles, England
EGSN|Bourn Airport|Cambridge, England
EGSO|Crowfield Airfield|Ipswich, England
EGSP|Peterborough/Sibson Airport|Peterborough, England
EGSQ|Clacton Airport|Clacton-on-Sea, England
EGSR|Earls Colne Airfield|Halstead, England
EGSS|London Stansted Airport|London, England
EGST|Elmsett Airport|Ipswich, England
EGSU|Duxford|Cambridge, England
EGSV|Old Buckenham Airport|Norwich, England
EGSX|North Weald Airfield|North Weald, England
EGSY|Sheffield City Airport|Sheffield, England
EGTB|Wycombe Air Park/Booker Airport|High Wycombe, England
EGTC|Cranfield Airport|Cranfield, England
EGTD|Dunsfold Aerodrome|Dunsfold, England
EGTE|Exeter International Airport|Exeter, England
EGTF|Fairoaks Airport|Chobham, England
EGTG|Bristol Filton Airport|Filton, England
EGTK|Oxford Airport|Oxford, England
EGTO|Rochester Airport, England|Rochester, England
EGTP|Perranporth Airfield|Perranporth, England
EGTR|Elstree Airfield|Watford, England
EGTU|Dunkeswell Aerodrome|Honiton, England
EGTW|Oaksey Park Airport|Oaksey, England
EGUB|RAF Benson|Benson, England
EGUD|RAF Abingdon|Abingdon, England
EGUL|RAF Lakenheath|Lakenheath, England
EGUN|RAF Mildenhall|Mildenhall, England
EGUO|Colerne Airfield|Colerne, England
EGUW|RAF Wattisham|Stowmarket, England
EGUY|RAF Wyton|St Ives, England
EGVA|RAF Fairford|Fairford, England
EGVN|RAF Brize Norton|Brize Norton, England
EGVO|RAF Odiham|Odiham, England
EGVP|AAC Middle Wallop Airfield|Andover, England
EGWC|RAF Cosford|Albrighton, England
EGWE|RAF Henlow|Henlow, England
EGWN|RAF Halton|Halton, England
EGWU|RAF Northolt|Ruislip, England
EGXC|RAF Coningsby|Coningsby, England
EGXD|RAF Dishforth|North Yorkshire, England
EGXE|RAF Leeming|Leeming Bar, England
EGXG|RAF Church Fenton|Church Fenton, England
EGXH|RAF Honington|Thetford, England
EGXP|RAF Scampton|Scampton, England
EGXT|RAF Wittering|Stamford, England
EGXU|RAF Linton-on-Ouse|Linton-on-Ouse, England
EGXW|RAF Waddington|Waddington, England
EGXY|RAF Syerston|Newark-on-Trent, England
EGXZ|RAF Topcliffe|Topcliffe, England
EGYC|RAF Coltishall|Norwich, England
EGYD|RAF Cranwell|Cranwell, England
EGYE|RAF Barkston Heath|Grantham, England
EGYM|RAF Marham|Marham, England
EGYP|RAF Mount Pleasant|Falkland Islands (note: not in SF.. series)
EHAM|Amsterdam Schiphol Airport|Haarlemmermeer, near Amsterdam
EHBD|Budel Airport|Weert
EHDB|KNMI|De Bilt
EHBK|Maastricht Aachen Airport|Maastricht
EHDL|Deelen Airbase|Deelen
EHDP|De Peel Airport|Venraij
EHDR|Drachten Airfield|Drachten
EHEH|Eindhoven Airport|Eindhoven
EHGG|Groningen Airport Eelde|Eelde
EHGR|Gilze-Rijen Airbase|Gilze and Rijen
EHHO|Hoogeveen Airfield|Hoogeveen
EHHV|Hilversum Airport|Hilversum
EHKD|De Kooy|De Kooy
EHVK|Volkel Airbase|Uden
EHLE|Lelystad Airport|Lelystad
EHLW|Leeuwarden Air Base|Leeuwarden
EHMC|Nieuw-Millingen|Nieuw-Millingen
EHMZ|Midden-Zeeland|Middelburg, Zeeland
EHOW|Oostwold Airport|Scheemda
EHRD|Rotterdam Airport|Rotterdam
EHSB|Soesterberg Air Base|Soesterberg
EHSE|Seppe Airport|Hoeven
EHST|Stadskanaal Airfield|Stadskanaal
EHTE|Teuge International Airport|Deventer
EHTL|Terlet Airfield|Terlet
EHTW|Enschede Airport Twente|Enschede
EHTX|Texel International Airport|Texel
EHVB|Valkenburg Airbase|Valkenburg
EHWO|Woensdrecht Air Base|Woensdrecht
EIAB|Abbeyshrule Aerodrome|Abbeyshrule, County Longford
EIBN|Bantry Aerodrome|Bantry, County Cork
EIBR|Birr Aerodrome|Birr, County Offaly
EICA|Connemara Regional Airport|Inverin, Connemara
EICK|Cork International Airport|Cork
EICL|Clonbullogue Aerodrome|Clonbullogue, County Offaly
EICM|Galway Airport|Carnmore, County Galway
EICN|Coonagh Airport|Limerick, County Limerick
EIDL|Donegal Airport|Carrickfinn, County Donegal
EIDW|Dublin International Airport|Dublin
EIIM|Inishmore Aerodrome (Kilronan Airport)|Kilronan, County Galway
EIKL|Kilkenny Airport|Kilkenny, County Kilkenny
EIKN|Knock International Airport|Knock, County Mayo
EIKY|Kerry Airport (Farranfore Airport)|Farranfore, County Kerry
EIME|Casement Aerodrome|Baldonnel
EIMG|Moneygall Aerodrome|Moneygall, County Offaly
EIMY|Moyne Aerodrome|Thurles, County Tipperary
EINN|Shannon Airport|Shannon, County Clare
EISG|Sligo Airport|Strandhill, near Sligo
EIWF|Waterford Airport|Waterford
EIWT|Weston Airport|Leixlip, County Kildare
EKAH|Aarhus Airport|Tirstrup near Aarhus
EKBI|Billund Airport|Billund
EKCH|Copenhagen Airport|Kastrup near Copenhagen
EKEB|Esbjerg Airport|Esbjerg
EKHG|Herning Airport|Herning
EKKA|Karup Airport|Karup
EKMB|Lolland Airport|Lolland Falster Maribo
EKOD|Odense Airport|Odense
EKRK|Roskilde Airport|Tune near Roskilde
EKRN|Bornholm Airport|Rønne
EKSB|Sønderborg Airport|Sønderborg
EKSN|Sindal Airport|Sindal
EKSP|Skrydstrup Airport|Vojens
EKSV|Skive Airport|Skive
EKTS|Thisted Airport|Thisted
EKVJ|Stauning Vestjylland Airport|Skjern
EKYT|Aalborg Airport|Aalborg
EKVD|Vamdrup Airport|Kolding
EKVG|Vagar Airport|Faroe Islands
EKFA Froðba Heliport|Faroe Islands|
EKKV Klaksvík Heliport|Faroe Islands|
EKMS Mykines Heliport|Faroe Islands|
EKSY Skúvoy Heliport|Faroe Islands|
EKSR Stóra Dímun Heliport|Faroe Islands|
EKSO Svínoy Heliport|Faroe Islands|
EKTB Tórshavn/Bodanes Heliport|Faroe Islands|
ELLX|Luxembourg International Airport|Luxembourg
ELNT|Airfield Noertrange|Luxembourg
ENAL|Ålesund Airport, Vigra|Ålesund, Møre og Romsdal
ENAN|Andøya Airport, Andenes|Andenes, Nordland
ENAS|Ny-Ålesund Airport, Hamnerabben|Ny-Ålesund, Svalbard
ENAT|Alta Airport|Alta, Finnmark
ENBJ|Bear Island (Bjørnøya), Arctic|
ENBL|Førde Airport, Bringeland|Førde, Sogn og Fjordane
ENBM|Voss Airport, Bømoen|Voss, Hordaland
ENBN|Brønnøysund Airport, Brønnøy|Brønnøysund, Nordland
ENBO|Bodø Airport|Bodø, Nordland
ENBR|Bergen Airport, Flesland|Bergen, Hordaland
ENBS|Båtsfjord Airport|Båtsfjord, Finnmark
ENBV|Berlevåg Airport|Berlevåg, Finnmark
ENCN|Kristiansand Airport, Kjevik|Kristiansand, Vest-Agder
ENDI|Geilo Airport, Dagali|Geilo, Buskerud
ENDR|Draugen|Draugen oil field, Norwegian Sea
ENDU|Bardufoss Airport|Bardufoss, Troms
ENEG|Hønefoss Airport, Eggemoen|Hønefoss, Buskerud
ENEV|Harstad/Narvik Airport, Evenes|Evenes, Nordland / Troms
ENFB|Oslo Airport, Fornebu (closed)|Oslo, Akershus
ENFG|Fagernes Airport, Leirin|Fagernes, Oppland
ENFL|Florø Airport|Florø, Sogn og Fjordane
ENFR|Frigg|North Sea
ENGA|Gullfaks A|Gullfaks oil field, North Sea
ENGC|Gullfaks C|Gullfaks oil field, North Sea
ENGM|Oslo Airport, Gardermoen|Gardermoen (near Oslo), Akershus
ENHA|Hamar Airport, Stafsberg|Hamar, Hedmark
ENHD|Haugesund Airport, Karmøy|Haugesund, Rogaland
ENHE|Heidrun|Heidrun oil field, North Sea
ENHF|Hammerfest Airport|Hammerfest, Finnmark
ENHK|Hasvik Airport|Hasvik, Finnmark
ENHN|Elverum Airport, Starmoen|Elverum, Hedmark
ENHS|Hokksund Airport|Hokksund, Buskerud
ENHV|Honningsvåg Airport, Valan|Honningsvåg, Finnmark
ENJA|Jan Mayensfield|Jan Mayen
ENJB|Tønsberg Airport, Jarlsberg|Tønsberg, Vestfold
ENKB|Kristiansund Airport, Kvernberget|Kristiansund, Møre og Romsdal
ENKJ|Kjeller Airport|Kjeller, Akershus
ENKR|Kirkenes Airport, Høybuktmoen|Kirkenes, Finnmark
ENLI|Farsund Airport, Lista|Farsund, Vest-Agder
ENLK|Leknes Airport|Leknes, Nordland
ENMH|Mehamn Airport|Mehamn, Finnmark
ENML|Molde Airport, Årø|Molde, Møre og Romsdal
ENMS|Mosjøen Airport, Kjærstad|Mosjøen, Nordland
ENNA|Lakselv Airport, Banak|Lakselv, Finnmark
ENNK|Narvik Airport, Framnes|Narvik, Nordland
ENNM|Namsos Airport|Namsos, Nord-Trøndelag
ENNO|Notodden Airport|Notodden, Telemark
ENOA|Oseberg A|Oseberg oil field, North Sea
ENOL|Ørland Main Air Station|, Sør-Trøndelag
ENOP|Oppdal Airport, Fagerhaug|Oppdal, Sør-Trøndelag
ENOV|Ørsta-Volda Airport, Hovden|Ørsta/Volda, Møre og Romsdal
ENRA|Mo i Rana Airport, Røssvoll|Mo i Rana, Nordland
ENRI|Ringebu Airport, Frya|Ringebu, Oppland
ENRK|Rakkestad Airport, Åstorp|Rakkestad, Østfold
ENRM|Rørvik Airport, Ryum|Rørvik, Nord-Trøndelag
ENRO|Røros Airport|Røros, Sør-Trøndelag
ENRS|Røst Airport|Røst, Nordland
ENRV|Reinsvoll Airport|Reinsvoll, Oppland
ENSA|Svea Airport|Sveagruva, Svalbard
ENSB|Svalbard Airport, Longyear|Longyearbyen, Svalbard
ENSD|Sandane Airport, Anda|Sandane, Sogn og Fjordane
ENSG|Sogndal Airport, Haukåsen|Sogndal, Sogn og Fjordane
ENSH|Svolvær Airport, Helle|Svolvær, Nordland
ENSK|Stokmarknes Airport, Skagen|Stokmarknes, Nordland
ENSN|Skien Airport, Geiteryggen|Skien, Telemark
ENSO|Stord Airport, Sørstokken|Leirvik, Hordaland
ENSR|Sørkjosen Airport|Nordreisa, Troms
ENSS|Vardø Airport, Svartnes|Vardø, Finnmark
ENST|Sandnessjøen Airport, Stokka|Sandnessjøen, Nordland
ENSU|Sunndalsøra Airport, Vinnu|Sunndalsøra, Møre og Romsdal
ENTC|Tromsø Airport, Langnes|Tromsø, Troms
ENTO|Sandefjord Airport, Torp|Sandefjord, Vestfold
ENUK|Gol Airport, Klanten|Gol, Buskerud
ENVA|Trondheim Airport, Værnes|Stjørdal, Nord-Trøndelag
ENVD|Vadsø Airport|Vadsø, Finnmark
ENVR|Værøy Heliport|Værøy, Nordland
ENZV|Stavanger Airport, Sola|Stavanger, Rogaland
EPBY|Bydgoszcz Ignacy Jan Paderewski Airport|Bydgoszcz
EPGD|Gdańsk Lech Wałęsa Airport|Gdańsk
EPKK|John Paul II International Airport Kraków-Balice|Kraków
EPKT|International Airport Katowice in Pyrzowice|Katowice
EPLL|Łódź Władysław Reymont Airport (formerly Łódź-Lublinek Airport)|Łódź
EPMO|Modlin Airport|Nowy Dwór Mazowiecki
EPPO|Poznań-Ławica Airport|Poznań
EPRZ|Rzeszów-Jasionka Airport|Rzeszów
EPSC|Szczecin-Goleniów "Solidarność" Airport|Szczecin
EPSY|Szczytno-Szymany International Airport|Szczytno
EPWA|Warsaw Frederic Chopin Airport (formerly Okecie International Airport)|Warsaw
EPWR|Copernicus Airport Wrocław|Wrocław
EPZG|Zielona Góra-Babimost Airport|Zielona Góra
ESCF|Malmen Air Base|Linköping
ESCK|Bråvalla Air Base (closed)|Norrköping
ESCM|Uppsala Airport / Ärna Air Base (F 16)|Uppsala
ESCN|Tullinge Airport (closed)|Stockholm
ESDF|Ronneby Airport (F 17)|Ronneby
ESFA|Bokeberg Airport|Hässleholm
ESFH|Hasslösa Air Base (closed)|Hasslösa
ESFI|Knislinge Air Base (closed)|Knislinge
ESFJ|Sjöbo Air Base|Sjöbo
ESFM|Moholm Air Base (closed)|Moholm
ESFQ|Kosta Air Base (closed)|Kosta
ESFR|Råda Air Base|Råda
ESFS|Sandvik Airport|Sandvik
ESFU|Uråsa Air Base (closed)|Växjö
ESFY|Byholma Air Base|Byholma
ESGA|Backamo Airport|Uddevalla
ESGC|Ålleberg Airport|Ålleberg
ESGD|Bämmelshed Airport|Tidaholm
ESGE|Viared Airport|Borås
ESGF|Morup Airport|Falkenberg
ESGG|Göteborg-Landvetter Airport|Göteborg
ESGH|Herrljunga Airport|Herrljunga
ESGI|Alingsås Airport|Alingsås
ESGJ|Jönköping Airport|Jönköping
ESGK|Falköping Airport|Falköping
ESGL|Lidköping-Hovby Airport|Lidköping
ESGM|Öresten Airport|Öresten
ESGN|Brännebrona Airport|Götene
ESGP|Göteborg City Airport (Säve)|Göteborg
ESGR|Skövde Airport|Skövde
ESGS|Näsinge Airport|Strömstad
ESGT|Trollhättan-Vänersborg Airport|Trollhättan / Vänersborg
ESGU|Rörkärr Airport|Uddevalla
ESGV|Varberg Airport|Varberg
ESGY|Säffle Airport|Säffle
ESIA|Karlsborg Air Base|Karlsborg
ESIB|Såtenäs Air Base|Såtenäs
ESKA|Gimo Air Base|Gimo
ESKB|Barkarby Airport|Stockholm
ESKC|Sundbro Airport|Sundbro
ESKD|Dala-Järna Airport|Dala-Järna
ESKG|Gryttjom Airport|Gryttjom
ESKH|Ekshärad Airport|Ekshärad
ESKK|Karlskoga Airport|Karlskoga
ESKM|Mora-Siljan Airport|Mora
ESKN|Stockholm-Skavsta Airport|Stockholm / Nyköping
ESKO|Munkfors Airport|Munkfors
ESKS|Strangnas Air Base (closed)|Strangnas
ESKT|Tierp Airport|Tierp
ESKU|Sunne Airport|Sunne
ESKV|Arvika-Westlanda Airport|Arvika
ESKX|Björkvik Air Base (closed)|Björkvik
ESMA|Emmaboda Airport|Emmaboda
ESMB|Borglanda Airport|Borglanda
ESMC|Ränneslätt Airport|Eksjö
ESMD|Vankiva Airport|Hässleholm
ESME|Eslöv Airport|Eslöv
ESMF|Fagerhult Airport|Fagerhult
ESMG|Feringe Airport|Ljungby
ESMH|Höganäs Airport|Höganäs
ESMI|Sövdeborg Airport|Sövdeborg
ESMJ|Kågeröd Airport|Kågeröd
ESMK|Kristianstad Airport|Kristianstad
ESML|Landskrona Airport|Landskrona
ESMN|Lund Airport|Lund
ESMO|Oskarshamn Airport|Oskarshamn
ESMP|Anderstorp Airport|Anderstorp
ESMQ|Kalmar Airport|Kalmar
ESMR|Trelleborg Airport (Maglarp Airport)|Trelleborg
ESMS|Malmö-Sturup Airport|Malmö
ESMT|Halmstad Airport|Halmstad
ESMU|Möckeln Airport|Älmhult
ESMV|Hagshult Air Base|Hagshult
ESMW|Tingsryd Airport (closed)|Tingsryd
ESMX|Växjö Airport (Kronoberg Airport)|Växjö
ESMY|Smålandsstenar Airport|Smålandsstenar
ESMZ|Ölanda Airport|Ölanda
ESNA|Hallviken Airport|Hallviken
ESNB|Sollefteå Airport|Sollefteå
ESNC|Hedlanda Airport|Hede
ESND|Sveg Airport|Sveg
ESNE|Överkalix Airport|Överkalix
ESNF|Farila Air Base|Farila
ESNG|Gällivare Airport|Gällivare
ESNH|Hudiksvall Airport|Hudiksvall
ESNI|Kubbe Air Base (closed)|Kubbe
ESNJ|Jokkmokk Air Base|Jokkmokk
ESNK|Kramfors-Sollefteå Airport|Kramfors / Sollefteå
ESNL|Lycksele Airport|Lycksele
ESNM|Optand Airport|Optand
ESNN|Sundsvall-Härnösand Airport|Sundsvall / Härnösand
ESNO|Örnsköldsvik Airport|Örnsköldsvik
ESNP|Piteå Airport|Piteå
ESNQ|Kiruna Airport|Kiruna
ESNR|Orsa Airport|Orsa
ESNS|Skellefteå Airport|Skellefteå
ESNT|Sattna Air Base (closed)|Sattna
ESNU|Umeå Airport|Umeå
ESNV|Vilhelmina Airport|Vilhelmina
ESNX|Arvidsjaur Airport|Arvidsjaur
ESNY|Söderhamn Airport|Söderhamn
ESNZ|Östersund Airport (F4 Frösön Air Base)|Östersund
ESOE|Örebro Airport|Örebro
ESOH|Hagfors Airport|Hagfors
ESOK|Karlstad Airport|Karlstad
ESOL|Lemstanäs Airport|Storvik
ESOW|Stockholm-Västerås Airport (Hässlö, former F1)|Stockholm / Västerås
ESPA|Luleå Airport (Kallax Air Base)|Luleå
ESPE|Vidsel Air Base|Vidsel
ESPG|Boden Army Air Base (closed)|Boden
ESPJ|Heden Air Base (closed)|Heden
ESQO|Arboga Airport|Arboga
ESQP|Berga Airport (closed)|Berga
ESSA|Stockholm-Arlanda Airport|Stockholm
ESSB|Stockholm-Bromma Airport|Stockholm
ESSC|Ekeby Airport|Eskilstuna
ESSD|Borlänge Airport|Borlänge
ESSE|Skå-Edeby Airport|Stockholm
ESSF|Hultsfred-Vimmerby Airport|Hultsfred / Vimmerby
ESSG|Ludvika Airport|Ludvika
ESSH|Laxå Airport|Laxå
ESSI|Visingsö Airport|Visingsö
ESSK|Gävle-Sandviken Airport|Gävle / Sandviken
ESSL|Linköping-Saab Airport|Linköping
ESSM|Brattforsheden Airport|Brattforsheden
ESSN|Norrtälje Airport|Norrtälje
ESSP|Kungsängen Airport|Norrköping
ESST|Torsby Airport (Fryklanda Airport)|Torsby
ESSU|Eskilstuna Airport|Eskilstuna
ESSV|Visby Airport|Visby
ESSW|Västervik Airport|Västervik
ESSX|Johannisberg Airport|Västerås
ESSZ|Vängsö Airport|Vängsö
ESTA|Ängelholm-Helsingborg Airport|Ängelholm / Helsingborg
ESTF|Fjallbacka Airport|Fjällbacka
ESTG|Grönhögen Airport|Grönhögen
ESTL|Ljungbyhed Airport|Ljungbyhed
ESTO|Tomelilla Airport|Tomelilla
ESTT|Vellinge Airport|Vellinge
ESUA|Åmsele Air Base (closed)|Åmsele
ESUB|Arbrå Airport|Arbrå
ESUD|Storuman Airport|Storuman
ESUE|Idre Airport|Idre
ESUF|Fallfors Air Base (closed)|Fallfors
ESUG|Gargnäs Airport|Gargnäs
ESUH|Myran Airport|Härnösand
ESUI|Mellansel Airport|Mellansel
ESUJ|Tälje Airport|Ånge
ESUK|Kalixfors Army Air Base|Kalixfors
ESUL|Ljusdal Airport|Ljusdal
ESUM|Mohed Airport|Mohed
ESUO|Oviken Airport|Oviken
ESUP|Pajala Airport|Pajala
ESUR|Ramsele Airport|Ramsele
ESUS|Åsele Airport|Åsele
ESUT|Hemavan Airport|Hemavan
ESUV|Älvsbyn Airport|Älvsbyn
ESUY|Edsbyn Airport|Edsbyn
ESVA|Avesta Airport|Avesta
ESVB|Bunge Airport|Bunge
ESVG|Gagnef Airport|Gagnef
ESVH|Hällefors Airport|Hällefors
ESVK|Katrineholm Airport|Katrineholm
ESVM|Skinnlanda Airport|Malung
ESVQ|Köping Airport|Köping
ESVS|Siljansnäs Airport|Siljansnäs
EVDA|Daugavpils Airport|Daugavpils
EVLA|Liepāja International Airport|Liepāja
EVRA|Rīga International Airport|Rīga
EVVA|Ventspils International Airport|Ventspils
EYAL|Alytus Airport|Alytus
EYBI|Biržai Airport|Biržai
EYJB|Jurbarkas Airport|Jurbarkas
EYKA|Kaunas International Airport|Kaunas
EYKD|Kėdainiai Airport|Kėdainiai
EYKG|Kaunas/Gamykla Airport|Kaunas
EYKL|Klaipėda Airport|Klaipėda
EYKR|Kazlų Rūda Airport (Military)|Kazlų Rūda
EYKS|S. Darius and S. Girėnas Airport|Kaunas
EYKT|Kartena Airport|Kartena
EYMA|Tirkšliai Airport|Tirkšliai
EYMM|Sasnava Airport|Sasnava
EYNA|Akmenė Airport|Akmenė
EYND|Nida Airport|Nida
EYNE|Nemirseta Airport|Nemirseta
EYPA|Palanga International Airport|Palanga
EYPI|Panevėžys/Istra Airport|Panevėžys
EYPK|Pikeliškės Airport|Pikeliškės
EYPN|Panevėžys Airport|Panevėžys
EYPP|Pajuostis Airport (Military)|Pajuostis
EYPR|Pociūnai Airport|Pociūnai
EYRK|Rokiškis Airport|Rokiškis
EYRU|Rukla Airport|Jonava
EYSA|Šiauliai International Airport (Civil/Military)|Šiauliai
EYSB|Barysiai Airport (Civil/Military)|Barysiai
EYSE|Šeduva Airport|Šeduva
EYSI|Šilutė Airport (Military)|Šilutė
EYTL|Telšiai Airport|Telšiai
EYUT|Utena Airport|Utena
EYVA|Vilnius (MOT/CAD)|
EYVC|Vilnius (ACC/FIC/COM/RCC)|
EYVI|Vilnius International Airport|Vilnius
EYVK|Kyviškės Airport (Military)|Kyviškės
EYVL|Vilnius (FIR)|
EYVN|Vilnius (NOF/AIS)|
EYVP|Paluknys Airport|Paluknys
EYZA|Zarasai Airport|Zarasai
EYZE|Žekiškės Airport|Žekiškės
FABE|Bisho Airport|Bisho
FABL|Bloemfontein Airport|Bloemfontein
FABM|Bethlehem Airfield|Bethlehem
FABU|Butterworth Airport|Butterworth
FACD|Cradock Airport|Cradock
FACT|Cape Town International Airport|Cape Town
FADN|Durban International Airport/AFB Durban|Durban
FAEL|East London Airport|East London
FAEM|Empangeni Airport|Empangeni
FAER|Ellisras (Mitimba) Airport|Ellisras
FAFB|Ficksburg Airport|Ficksburg
FAFK|Fisantekraal Airfield|Fisantekraal,Durbanville
FAGC|Grand Central Airport|Johannesburg
FAGG|George Airport|George
FAGI|Giyani Airport|Giyani
FAGM|Rand Airport|Johannesburg
FAHL|Hluhluwe Airport|Hluhluwe
FAHR|Harrismith Airport|Harrismith
FAJS|OR Tambo International Airport|Johannesburg
FAKD|Klerksdorp Airport|Klerksdorp
FAKF|Kersefontein Farm|Hopefield
FAKM|Kimberley Airport|Kimberley
FAKN|Kruger Mpumalanga International Airport|Nelspruit (Kruger National Park)
FAKO|Komga|Komga
FAKP|Komatipoort Airport|Komatipoort
FAKR|Krugersdorp Airport|Krugersdorp
FAKU|Johan Pienaar Airport|Kuruman
FAKZ|Kleinsee Airport|Kleinsee
FALA|Lanseria Airport|Lanseria
FALC|Finsch Mine Airport|Lime Acres
FALK|Lusikisiki Airport|Lusikisiki
FALM|AFB Makhado, SAAF|Makhado
FALW|AFB Langebaanweg SAAF|Langebaan
FALY|Ladysmith Airport|Ladysmith
FAMD|Malamala Airport|Malamala
FAMG|Margate Airport|Margate
FAMM|Mmabatho International Airport|Mmabatho
FAMN|Malelane Airport|Malelane
FAMO|Mossel Bay Airport|Mossel Bay
FAMS|Messina Airport|Messina
FAMU|Mkuze Airport|Mkuze
FAMW|Mzamba (Wild Coast) Airport|Mzamba
FANC|Newcastle Airport|Newcastle
FANG|Ngala Airfield Airport|Ngala
FANS|Nelspruit Airport|Nelspruit
FAOI|Orient Airfield|Magaliesburg
FAOH|Oudtshoorn Airport|Oudtshoorn
FAPA|Port Alfred Airport|Port Alfred
FAPE|Port Elizabeth Airport|Port Elizabeth
FAPG|Plettenberg Bay Airport|Plettenberg Bay
FAPH|Hendrik Van Eck Airport|Phalaborwa
FAPJ|Port St. Johns Airport|Port St. Johns
FAPK|Prieska Airport|Prieska
FAPM|Pietermaritzburg Airport|Pietermaritzburg
FAPN|Pilanesberg International Airport|Pilanesberg (near Sun City)
FAPP|Polokwane International Airport|Polokwane
FAQT|Queenstown Airport|Queenstown
FARB|Richards Bay Airport|Richards Bay
FARS|Robertson Airport|Robertson
FASB|Springbok Airport|Springbok
FASC|Secunda Airport|Secunda
FASD|Vredenburg Airport|Saldanha Bay
FASE|Sabi Sabi|
FASH|Stellenbosch Flying Club|Stellenbosch
FASS|Sishen Airport|Sishen
FASZ|Skukuza Airport|Skukuza
FATA|Teddarfield Airpark|
FATH|P.R. Mphephu Airport|Thohoyandou
FATN|Thaba Nchu Airport|Thaba Nchu
FATP|New Tempe|Bloemfontein
FATZ|Tzaneen Airport|Tzaneen
FAUL|Ulundi Airport|Ulundi
FAUP|Upington Airport|Upington
FAUT|K. D. Matanzima Airport|Umtata
FAVB|Vryburg Airport|Vryburg
FAVG|Virginia Airport|Durban
FAVR|Vredendal Airport|Vredendal
FAVY|Vryheid Airport|Vryheid
FAWB|Wonderboom Airport|Pretoria
FAWK|AFBWaterkloof, SAAF|Tshwane
FAWM|Welkom Airport|Welkom
FAYP|Ysterplaat AFB|Cape Town
FBFT|Francistown Airport|Francistown
FBGM|Gumare Airport|Gumare
FBGZ|Ghanzi Airport|Ghanzi
FBJW|Jwaneng Airport|Jwaneng
FBKE|Kasane Airport|Kasane
FBKG|Kang Airport|Kang
FBKR|Khwai River Airport|Khwai River
FBKY|Kanye Airport|Kanye
FBLO|Lobatse Airport|Lobatse
FBMM|Makalamabedi Airport|Makalamabedi
FBMN|Maun Airport|Maun
FBNN|Nokaneng Airport|Nokaneng
FBNT|Nata Airport|Nata
FBOR|Orapa Airport|Orapa
FBPY|Palapye Airport|Palapye
FBRK|Rakops Airport|Rakops
FBSK|Sir Seretse Khama International Airport|Gaborone
FBSN|Sua Pan Airport|Sua Pan
FBSP|Selebi-Phikwe Airport|Selebi-Phikwe
FBSR|Serowe Airport|Serowe
FBSV|Savuti Airport|Savuti
FBSW|Shakawe Airport|Shakawe
FBTE|Tshane Airport|Tshane
FBTL|Tuli Lodge Airport|Tuli Lodge
FBTS|Tshabong Airport|Tshabong
FBXG|Xugana Airport|Xugana
FCBB|Maya-Maya Airport|Brazzaville
FCBD|Djambala Airport|Djambala
FCBK|Kindamba Airport|Kindamba
FCBL|Lague Airport|Lague
FCBM|Mouyondzi Airport|Mouyondzi
FCBS|Sibiti Airport|Sibiti
FCBY|Yokangassi Airport|Nkayi
FCBZ|Zanaga Airport|Zanaga
FCMM|Mossendjo Airport|Mossendjo
FCOB|Boundji Airport|Boundji
FCOE|Ewo Airport|Ewo
FCOG|Gamboma Airport|Gamboma
FCOI|Impfondo Airport|Impfondo
FCOK|Kelle Airport|Kelle
FCOM|Makoua Airport|Makoua
FCOO|Owando Airport|Owando
FCOS|Souanke Airport|Souanke
FCOT|Betou Airport|Betou
FCOU|Ouesso Airport|Ouesso
FCPA|Makabana Airport|Makabana
FCPL|Loubomo Airport|Loubomo
FCPP|Pointe Noire Airport|Pointe-Noire
FDMB|Mbabane Airport|Mbabane
FDMS|Matsapha Airport|Manzini
FEFA|Alindao Airport|Alindao
FEFB|Poste Airport|Obo
FEFC|Carnot Airport|Carnot
FEFE|Mobaye Mbanga Airport|Mobaye
FEFF|Bangui M'Poko International Airport|Bangui
FEFG|Bangassou Airport|Bangassou
FEFI|Birao Airport|Birao
FEFL|Bossembele Airport|Bossembélé
FEFM|Bambari Airport|Bambari
FEFN|N'Délé Airport|N'Délé
FEFO|Bouar Airport|Bouar
FEFP|Paoua Airport|Paoua
FEFR|Bria Airport|Bria
FEFS|Bossangoa Airport|Bossangoa
FEFT|Berberati Airport|Berbérati
FEFU|Sibut Airport|Sibut
FEFW|Ouadda Airport|Ouadda
FEFY|Yalinga Airport|Yalinga
FEFZ|Zemio Airport|Zemio
FEGC|Bocaranga Airport|Bocaranga
FEGE|M'Boki Airport|Obo
FEGF|Batangafo Airport|Batangafo
FEGL|Gordil Airport|Gordil
FEGM|Bakouma Airport|Bakouma
FEGO|Ouanda Djallé Airport|Ouanda Djallé
FEGR|Rafai Airport|Rafaï
FEGU|Bouca Airport|Bouca
FEGZ|Bozoum Airport|Bozoum
FGBT|Bata Airport|Bata
FGSL|Malabo Airport|Malabo
FHAW|Wideawake Field (Ascension Aux. AF)|Georgetown
FIMP|Sir Seewoosagur Ramgoolam International Airport|Plaine Magnien
FIMR|Sir Gaëtan Duval Airport (Plaine Corail Airport)|Rodrigues Island
FJDG|Diego Garcia Tracking Station|Diego Garcia
FKKB|Kribi Airport|Kribi
FKKC|Tiko Airport|Tiko
FKKD|Douala International Airport|Douala
FKKF|Mamfe Airport|Mamfe
FKKG|Bali Airport|Bali
FKKH|Kaélé Airport|Kaélé
FKKI|Batouri Airport|Batouri
FKKJ|Yagoua Airport|Yagoua
FKKL|Salak Airport|Maroua
FKKM|Nkounja Airport|Foumban
FKKN|N'Gaoundéré Airport|N'Gaoundéré
FKKO|Bertoua Airport|Bertoua
FKKR|Garoua International Airport|Garoua
FKKS|Dschang Airport|Dschang
FKKU|Bafoussam Airport|Bafoussam
FKKV|Bamenda Airport|Bamenda
FKKW|Ebolowa Airport|Ebolowa
FKKY|Yaoundé Airport|Yaoundé
FKYS|Yaoundé Nsimalen International Airport|Yaoundé
FLBA|Mbala Airport|Mbala
FLCP|Chipata Airport|Chipata
FLKE|Kasompe Airport|Kasompe
FLKL|Kalabo Airport|Kalabo
FLKO|Kaoma Airport|Kaoma
FLKS|Kasama Airport|Kasama
FLKW|Milliken Airport|Kabwe
FLLI|Livingstone Airport|Livingstone
FLLK|Lukulu Airport|Lukulu
FLLS|Lusaka International Airport|Lusaka
FLMA|Mansa Airport|Mansa
FLMF|Mfuwe Airport|Mfuwe
FLMG|Mongu Airport|Mongu
FLND|Ndola Airport|Ndola
FLSN|Senanga Airport|Senanga
FLSO|Southdowns Airport|Kitwe
FLSS|Sesheke Airport|Sesheke
FLSW|Solwezi Airport|Solwezi
FLZB|Zambezi Airport|Zambezi
FMCH|Prince Said Ibrahim International Airport|Moroni, Comoros
FMCI|Mohéli Bandar Es Eslam Airport|Mohéli, Comoros
FMCN|Iconi Airport|Moroni, Comoros
FMCV|Ouani Airport|Anjouan, Comoros
FMCZ|Dzaoudzi Pamandzi International Airport|Dzaoudzi, Mayotte
FMEE|Roland Garros Airport|Saint-Denis, Réunion
FMEP|Pierrefonds Airport|Saint-Pierre, Réunion
FMMC|Malaimbandy Airport|Malaimbandy, Madagascar
FMME|Antsirabe Airport|Antsirabé, Madagascar
FMMG|Antsalova Airport|Antsalova, Madagascar
FMMI|Ivato International Airport|Antanànarìvo, Madagascar
FMMK|Ankavandra Airport|Ankavandra, Madagascar
FMML|Belo sur Tsiribihina Airport|Belo sur Tsiribihina, Madagascar
FMMN|Miandrivazo Airport|Miandrivazo, Madagascar
FMMO|Maintirano Airport|Maintirano, Madagascar
FMMQ|Ilaka-Est Airport|Ilaka-Est, Madagascar
FMMR|Morafenobe Airport|Morafenobe, Madagascar
FMMS|Sainte Marie Airport|Île Sainte-Marie, Madagascar
FMMT|Toamasina Airport|Toamasina, Madagascar
FMMU|Tambohorano Airport|Tambohorano, Madagascar
FMMV|Morondava Airport|Morondava, Madagascar
FMMX|Tsiroanomandidy Airport|Tsiroanomandidy, Madagascar
FMMY|Vatomandry Airport|Vatomandry, Madagascar
FMMZ|Ambatondrazaka Airport|Ambatondrazaka, Madagascar
FMNA|Arrachart Airport|Antsiranana, Madagascar
FMNC|Mananara Nord Airport|Mananara Nord, Madagascar
FMND|Andapa Airport|Andapa, Madagascar
FMNF|Befandriana Nord Airport|Befandriana Nord, Madagascar
FMNG|Port Berge Airport|Port Berge, Madagascar
FMNH|Antsirabato Airport|Antalaha, Madagascar
FMNJ|Ambanja Airport|Ambanja, Madagascar
FMNL|Analalava Airport|Analalava, Madagascar
FMNM|Amborovy Airport|Mahajanga, Madagascar
FMNN|Fascene Airport|Nosy Be, Madagascar
FMNO|Soalala Airport|Soalala, Madagascar
FMNQ|Besalampy Airport|Besalampy, Madagascar
FMNR|Maroantsetra Airport|Maroantsetra, Madagascar
FMNS|Sambava Sud Airport|Sambava Sud, Madagascar
FMNT|Tsaratanana Airport|Tsaratanana, Madagascar
FMNV|Vohemar Airport|Vohemar, Madagascar
FMNW|Ambalabe Airport|Antsohihy, Madagascar
FMSB|Antsoa Airport|Beroroha, Madagascar
FMSC|Mandabe Airport|Mandabe, Madagascar
FMSD|Tôlanaro Airport|Tôlanaro, Madagascar
FMSF|Fianarantsoa Airport|Fianarantsoa, Madagascar
FMSI|Ihosy Airport|Ihosy, Madagascar
FMSJ|Manja Airport|Manja, Madagascar
FMSK|Manakara Airport|Manakara, Madagascar
FMSL|Bekily Airport|Bekily, Madagascar
FMSM|Mananjary Airport|Mananjary, Madagascar
FMSN|Tanandava-Samangoky Airport|Tanandava-Samangoky, Madagascar
FMSR|Morombe Airport|Morombe, Madagascar
FMST|Toliara Airport|Toliara, Madagascar
FMSV|Betioky Airport|Betioky, Madagascar
FMSY|Ampanihy Airport|Ampanihy, Madagascar
FMSZ|Ankazoabo Airport|Ankazoabo, Madagascar
FNAM|Ambriz Airport|Ambriz
FNBC|Mbanza Congo Airport|Mbanza Congo
FNBG|Benguela Airport|Benguela
FNCA|Cabinda Airport|Cabinda
FNCF|Cafunfo Airport|Cafunfo
FNCH|Dundo Airport|Chitato
FNCT|Catumbela Airport|Catumbela
FNCV|Cuito Cuanavale Airport|Cuito Cuanavale
FNCZ|Cazombo Airport|Cazombo
FNGI|Ondjiva Pereira Airport|Ondjiva (Ongiva, Ngiva, N'giva)
FNHU|Nova Lisboa Airport|Huambo
FNKU|Kuito Airport|Kuito
FNLK|Lucapa Airport|Lucapa (Lukapa)
FNLU|Quatro de Fevereiro Airport|Luanda
FNMA|Malanje Airport|Malanje
FNME|Menongue Airport|Menongue
FNMO|Namibe Airport|Namibe
FNNG|Negage Airport|Negage
FNPA|Porto Amboim Airport|Porto Amboim
FNSA|Saurimo Airport|Saurimo
FNSO|Soyo Airport|Soyo
FNUB|Lubango Airport|Lubango
FNUE|Luena Airport|Luena
FNUG|Uige Airport|Uíge
FNWK|Waco Kungo Airport|Waco Kungo
FNXA|Xangongo Airport|Xangongo
FNZE|N'zeto Airport|N'zeto
FOGA|Akieni Airport|Akieni
FOGB|Booué Airport|Booué
FOGE|Ndende Airport|Ndende
FOGF|Fougamou Airport|Fougamou
FOGG|Mbigou Airport|Mbigou
FOGI|Moabi Airport|Moabi
FOGK|Mabimbi Airport|Koulamoutou
FOGM|Mouila (City) Airport|Mouila
FOGO|Oyem Airport|Oyem
FOGQ|Okondja Airport|Okondja
FOGR|Lambaréné Airport|Lambaréné
FOOB|Bitam Airport|Bitam
FOOD|Moanda Airport|Moanda
FOOE|Mékambo Airport|Mékambo
FOOG|Port-Gentil Airport|Port-Gentil
FOOH|Hospital Airport|Omboué
FOOI|Tchongorove Airport|Iguela
FOOK|Makokou Airport|Makokou
FOOL|Leon M'Ba International Airport|Libreville
FOOM|Mitzic Airport|Mitzic
FOON|M'vengue Airport|Franceville
FOOR|Lastourville Airport|Lastourville
FOOS|Sette Cama Airport|Sette Cama
FOOT|Tchibanga Airport|Tchibanga
FOOY|Mayumba Airport|Mayumba
FPPA|Porto Alegre Airport|São Tomé
FPPR|Príncipe Airport|Príncipe
FPST|São Tomé International Airport (Salazar Airport)|São Tomé
FQAG|Angoche Airport|Angoche
FQBR|Beira Airport|Beira
FQCB|Cuamba Airport|Cuamba
FQCH|Chimoio Airport|Chimoio
FQIN|Inhambane Airport|Inhambane
FQLC|Lichinga Airport|Lichinga
FQLU|Lumbo Airport|Lumbo
FQMA|Maputo International Airport|Maputo
FQMD|Mueda Airport|Mueda
FQMP|Moçimboa da Praia Airport|Moçimboa da Praia
FQNC|Nacala Airport|Nacala
FQNP|Nampula Airport|Nampula
FQPB|Pemba Airport|Pemba
FQQL|Quelimane Airport|Quelimane
FQTT|Chingozi Airport|Tete
FQVL|Vilankulo Airport|Vilankulo
FSDR|Desroches Airport|Desroches
FSIA|Seychelles International Airport|Mahe Island
FSPP|Praslin Island Airport|Praslin Island
FSSB|Bird Island Airport|Bird Island
FSSF|Frégate Island Airport|Frégate Island
FTTA|Sarh Airport|Sarh
FTTB|Bongor Airport|Bongor
FTTC|Abéché Airport|Abéché
FTTD|Moundou Airport|Moundou
FTTE|Biltine Airport|Biltine
FTTF|Fada Airport|Fada
FTTG|Goz Beïda Airport|Goz Beïda
FTTH|Laï Airport|Laï
FTTI|Ati Airport|Ati
FTTJ|N'Djamena International Airport|N'Djamena
FTTK|Bokoro Airport|Bokoro
FTTL|Bol Airport|Bol
FTTM|Mongo Airport|Mongo
FTTN|Am-Timan Airport|Am-Timan
FTTP|Pala Airport|Pala
FTTR|Zouar Airport|Zouar
FTTS|Bousso Airport|Bousso
FTTU|Mao Airport|Mao
FTTY|Faya-Largeau Airport|Faya-Largeau
FTTZ|Zougra Airport|Bardaï
FVBU|Joshua Mqabuko Nkomo International Airport|Bulawayo
FVCH|Chipinge Airport|Chipinge
FVCP|Charles Prince Airport|Harare
FVCZ|Buffalo Range|Chiredzi
FVFA|Victoria Falls Airport|Victoria Falls
FVGR|Grand Reef Airport|Mutare
FVHA|Harare International Airport|Harare
FVKB|Kariba Airport|Kariba
FVMV|Masvingo Airport|Masvingo
FVTL|Thornhill Airport|Gweru
FVWN|Hwange National Park Airport|Hwange (Hwange National Park)
FVWT|Hwange Town Airport|Hwange Town
FWCL|Chileka International Airport|Blantyre
FWCM|Club Makokola Airport|Club Makokola
FWDW|Dwanga Airport|Dwanga
FWKA|Karonga Airport|Karonga
FWKI|Lilongwe International Airport (Kamuzu Int'l)|Lilongwe
FWMG|Mangochi Airport|Mangochi
FWMY|Monkey Bay Airport|Monkey Bay
FWSM|Salima Airport|Salima
FWUU|Mzuzu Airport|Mzuzu
FXLK|Lebakeng Airport|Lebakeng
FXLR|Leribe Airport|Leribe
FXLS|Lesobeng Airport|Lesobeng
FXMA|Matsaile Airport|Matsaile
FXMF|Mafeteng Airport|Mafeteng
FXMK|Mokhotlong Airport|Mokhotlong
FXMM|Moshoeshoe International Airport|Maseru
FXMU|Mejametalana Airport|Maseru
FXNK|Nkaus Airport|Nkaus
FXPG|Pelaneng Airport|Pelaneng
FXQG|Quthing Airport|Quthing
FXQN|Qachas' Nek Airport|Qachas' Nek
FXSK|Sekake Airport|Sekake
FXSM|Semongkong Airport|Semongkong
FXTA|Thaba Tseka Airport|Thaba Tseka
FXTK|Tlokoeng Airport|Tlokoeng
FYAR|Arandis Airport|Arandis
FYGF|Grootfontein Airport|Grootfontein
FYHI|Halali Airport|Halali
FYHH|Helmeringhausen Airstrip|Helmeringhausen
FYKB|Karasburg Airport|Karasburg
FYKT|Keetmanshoop Airport|Keetmanshoop
FYLZ|Lüderitz Airport|Lüderitz
FYMO|Mokuti Lodge Airport|Mokuti Lodge
FYMP|Mpacha Airport|Mpacha
FYNA|Namutoni Airport|Namutoni
FYNP|Nepara Airfield|Nkurenkuru
FYOA|Ondangwa Airport|Ondangwa
FYOE|Omega Airport|Omega
FYOG|Oranjemund Airport|Oranjemund
FYOH|Okahao Airport|Okahao
FYOO|Okaukuejo Airport|Okaukuejo
FYOP|Opuwa Airport|Opuwa
FYOS|Oshakati Airport|Oshakati
FYRU|Rundu Airport|Rundu
FYSM|Swakopmund Airport|Swakopmund
FYTM|Tsumeb Airport|Tsumeb
FYWB|Walvis Bay Airport|Walvis Bay
FYWE|Eros Airport|Windhoek
FYWH|Windhoek Hosea Kutako International Airport|Windhoek
FZAA|N'Djili International Airport|Kinshasa
FZAB|N'Dolo Airport|Kinshasa
FZAJ|Boma Airport|Boma
FZAL|Luozi Airport|Luozi
FZAM|Tshimpi Airport|Matadi
FZAR|Nkolo-Fuma Airport|Nkolo-Fuma
FZBA|Inongo Airport|Inongo
FZBI|Nioki Airport|Nioki
FZBO|Bandundu Airport|Bandundu
FZBT|Kiri Airport|Kiri
FZCA|Kikwit Airport|Kikwit
FZCB|Idiofa Airport|Idiofa
FZCE|Lusanga Airport|Lusanga
FZCV|Masi-Manimba Airport|Masi-Manimba
FZDO|Moanda Airport|Moanda
FZEA|Mbandaka Airport|Mbandaka
FZEN|Basankusu Airport|Basankusu
FZFA|Libenge Airport|Libenge
FZFD|Gbadolite Airport|Gbadolite
FZFK|Gemena Airport|Gemena
FZFU|Bumba Airport|Bumba
FZGA|Lisala Airport|Lisala
FZGN|Boende Airport|Boende
FZGV|Ikela Airport|Ikela
FZIC|Bangoka International Airport|Kisangani
FZIR|Yangambi Airport|Yangambi
FZJH|Matari Airport|Isiro
FZKA|Bunia Airport|Bunia
FZKJ|Buta Zega Airport|Buta Zega
FZMA|Kavumu Airport|Bukavu
FZNA|Goma International Airport|Goma
FZNP|Beni Airport|Beni
FZOA|Kindu Airport|Kindu
FZOD|Kalima Airport|Kalima
FZOP|Punia Airport|Punia
FZQA|Lubumbashi International Airport|Lubumbashi
FZQC|Pweto Airport|Pweto
FZQG|Kasenga Airport|Kasenga
FZQM|Kolwezi Airport|Kolwezi
FZRA|Manono Airport|Manono
FZRB|Moba Airport|Moba
FZRF|Kalemie Airport|Kalemie
FZRM|Kabalo Airport|Kabalo
FZRQ|Kongolo Airport|Kongolo
FZSA|Base Airport|Kamina
FZSB|Kamina Airport|Kamina
FZSK|Kapanga Airport|Kapanga
FZTK|Kaniama Airport|Kaniama
FZUA|Kananga Airport|Kananga
FZUF|Kasonga Airport|Kasonga
FZUG|Luisa Airport|Luisa
FZUH|Moma Airport|Moma
FZUK|Tshikapa Airport|Tshikapa
FZVA|Lodja Airport|Lodja
FZVI|Lusambo Airport|Lusambo
FZVM|Mweka Airport|Mweka
FZVR|Basongo Airport|Basongo
FZWA|Mbuji Mayi Airport|Mbuji Mayi
FZWC|Gandajika Airport|Gandajika
GAAO|Ansongo Airport|Ansongo
GABD|Bandiagara Airport|Bandiagara
GABF|Bafoulabe Airport|Bafoulabe
GABG|Bougouni Airport|Bougouni
GABR|Bourem Airport|Bourem
GABS|Senou International Airport|Bamako
GADZ|Douentza Airport|Douentza
GAGM|Goundam Airport|Goundam
GAGO|Gao International Airport (Korogoussou Airport)|Gao
GAKA|Kenieba Airport|Kenieba
GAKL|Kidal Airport|Kidal
GAKN|Kolokani Airport|Kolokani
GAKO|Koutiala Airport|Koutiala
GAKT|Kita Airport|Kita
GAKY|Kayes Airport|Kayes
GAMA|Markala Airport|Markala
GAMB|Mopti Airport (Barbe Airport)|Mopti
GAMK|Menaka Airport|Ménaka, Ménaka Cercle
GANF|Niafunke Airport|Niafunke
GANK|Keibane Airport|Nara
GANR|Nioro Airport|Nioro
GASK|Sikasso Airport|Sikasso
GATB|Tombouctou Airport|Tombouctou
GATS|Tessalit Airport|Tessalit
GAYE|Yelimane Airport|Yélimané
GBYD|Banjul International Airport (Yundum Int'l)|Banjul
GCFV|El Matorral Airport|Fuerteventura
GCHI|El Hierro Airport|El Hierro
GCLA|La Palma Airport|La Palma
GCLP|Gran Canaria International Airport|Gran Canaria
GCGM|La Gomera Airport|La Gomera
GCRR|Arrecife Airport (Lanzarote Airport)|Arrecife
GCTS|Tenerife South Airport (Reina Sofía)|Tenerife
GCXO|Tenerife North Airport (Los Rodeos)|Tenerife
GECT|Ceuta Heliport|Ceuta
GEML|Melilla Airport|Melilla
GFBN|Sherbro International Airport|Bonthe
GFBO|Bo Airport|Bo
GFGK|Gbangbatok Airport|Gbangbatok
GFHA|Hastings Airport|Freetown
GFKB|Kabala Airport|Kabala
GFKE|Kenema Airport|Kenema
GFLL|Lungi International Airport|Freetown
GFYE|Yengema Airport|Yengema
GGBU|Bubaque Airport|Bubaque
GGOV|Osvaldo Vieiro International Airport|Bissau
GGCF|Cufar Airport|Cufar
GLBU|Buchanan Airport|Buchanan
GLCP|Cape Palmas Airport|Harper
GLGE|Greenville/Sinoe Airport|Greenville (Sinoe)
GLLB|Lamco Airport|Buchanan
GLMR|Spriggs Payne Airport|Monrovia
GLNA|Nimba Airport|Nimba
GLRB|Roberts International Airport|Monrovia
GLST|Sasstown Airport|Sasstown
GLTN|Tchien Airport|Tchien
GLVA|Voinjama Airport|Voinjama
GMAD|Al Massira Airport (Inezgane Airport)|Agadir
GMAT|Plage Blanche Airport|Tan-Tan
GMFF|Saiss Airport|Fes
GMFK|Moulay Ali Cherif Airport|Errachida
GMFM|Bassatine Airport|Meknes
GMFN|Taouima Airport|Nador
GMFO|Angads Airport|Oujda
GMMC|Anfa Airport|Casablanca
GMME|Sale Airport|Rabat
GMMF|Sania Ramel Airport|Sidi Ifni
GMMI|Mogador Airport|Essaouira
GMMN|Mohammed V International Airport|Casablanca
GMMP|Kenitra Airport|Kenitra
GMMS|Safi Airport|Safi
GMMW|Nador International Airport|Nador
GMMX|Menara International Airport|Marrakech
GMMY|Tourisme Airport|Kenitra
GMMZ|Ouarzazate Airport|Ouarzazate
GMTA|Cherif Al Idrissi Airport|Al Hoceima
GMTN|Sania Ramel Airport|Tétouan
GMTT|Ibn Batouta International Airport (Boukhaif/Tanger Airport)|Tanger
GMMA|Smara Airport|Smara, Western Sahara
GMMH|Dakhla Airport|Dakhla (Villa Cisneros), Western Sahara
GMML|Hassan I Airport|Laâyoune (El Aaiún), Western Sahara
GOGG|Ziguinchor Airport|Ziguinchor
GOGK|Kolda North Airport|Kolda
GOGS|Cap Skiring Airport|Cap Skiring
GOOK|Kaolack Airport|Kaolack
GOOY|Léopold Sédar Senghor International Airport|Dakar
GOSM|Ouro Sogui Airport|Matam
GOSP|Podor Airport|Podor
GOSR|Richard Toll Airport|Richard Toll
GOSS|Saint-Louis Airport|Saint-Louis
GOTB|Bakel Airport|Bakel
GOTK|Kédougou Airport|Kédougou
GOTS|Simenti Airport|Simenti
GOTT|Tambacounda Airport|Tambacounda
GQNA|Aioun el Atrouss Airport|Aioun el Atrouss
GQNB|Boutilimit Airport|Boutilimit
GQNC|Tichitt Airport|Tichitt
GQND|Tidjikja Airport|Tidjikja
GQNE|Abbaye Airport|Boghe
GQNF|Kiffa Airport|Kiffa
GQNH|Timbedra Airport|Timbedra
GQNI|Nema Airport|Néma
GQNJ|Akjoujt Airport|Akjoujt
GQNK|Kaedi Airport|Kaédi
GQNL|Letfotar Airport|Moudjeria
GQNM|Dahara Airport|Timbedra
GQNN|Nouakchott International Airport|Nouakchott
GQNS|Selibaby Airport|Selibaby
GQNT|Tamchakett Airport|Tamchakett
GQPA|Atar International Airport|Atar
GQPF|Fderik Airport|Fderik
GQPP|Nouadhibou International Airport|Nouadhibou
GQPT|Bir Moghrein Airport|Bir Moghrein
GQPZ|Tazadit Airport|Zouérat
GUCY|Conakry International Airport (Gbessia Int'l)|Conakry
GUFA|Fria Airport|Fria
GUFH|Faranah Airport|Faranah
GUGO|Gbenko Airport|Banankoro
GUKR|Kawass Airport|Port Kamsar
GUKU|Kissidougou Airport|Kissidougou
GULB|Tata Airport|Labe
GUMA|Macenta Airport|Macenta
GUNZ|Nzérékoré Airport|N'zerekore
GUOK|Boké Baralande Airport|Boké
GUSA|Sangaredi Airport|Sangarédi, Guinea
GUSB|Sambailo Airport|Koundara
GUSI|Siguiri Airport|Siguiri
GUXN|Kankan Airport|Kankan
GVAC|Amílcar Cabral International Airport|Sal, Espargos
GVAN|Agostinho Neto Airport|Ponta do Sol, Santo Antão
GVBA|Rabil Airport|Boa Vista, Rabil
GVNP|Praia International Airport|Santiago, Praia
GVMA|Maio Airport|Maio, Vila do Maio
GVMT|Mosteiros Airport|Fogo, Mosteiros
GVSF|São Filipe Airport|Fogo, São Filipe
GVSN|Preguiça Airport|São Nicolau, Preguiça
GVSV|São Pedro Airport|São Vicente, São Pedro
HAAB|Bole International Airport|Addis Ababa
HAAM|Arba Minch Airport|Arba Minch
HAAX|Axum Airport|Axum
HABD|Bahir Dar Airport|Bahir Dar
HABE|Beica Airport|Beica
HABU|Bulchi Airport|Bulchi
HADC|Combolcha Airport|Dessie
HADD|Dembidolo Airport|Dembidolo
HADM|Debre Marqos Airport|Debre Marqos
HADR|Aba Tenna Dejazmach Yilma International Airport|Dire Dawa
HADT|Debre Tabor Airport|Debre Tabor
HAFN|Fincha Airport|Finicha'a
HAGB|Robe Airport|Goba
HAGM|Gambela Airport|Gambela
HAGN|Gondar Airport|Gondar
HAGO|Gode Airport (military)|Gode
HAGR|Gore Airport|Gore
HAHM|Harar Meda Airport|Debre Zeyit
HAHU|Humera Airport|Humera
HAJM|Aba Segud Airport|Jimma
HAKD|Kabri Dar Airport|Kabri Dar
HAKL|Kelafo Airport|Kelafo
HALA|Awasa Airport|Awasa
HAMK|Alula Aba Airport|Mek'ele
HAMN|Mendi Airport|Mendi
HAMT|Mizan Teferi Airport|Mizan Teferi
HANG|Neghele Airport (military)|Negele Boran
HANJ|Nejjo Airport|Nejo
HANK|Nekemte Airport|Nekemte
HASO|Asosa Airport|Asosa
HATP|Tippi Airport|Tippi
HAWC|Wacca Airport|Wacca
HBBA|Bujumbura International Airport|Bujumbura
HBBE|Gitega Airport|Gitega
HBBO|Kirundo Airport|Kirundo
HCMA|Alula Airport|Alula
HCMB|Baidoa Airport|Baidoa
HCMC|Candala Airport|Candala
HCMD|Bardera Airport|Bardera
HCME|Eil Airport|Eil
HCMF|Bender Qassim International Airport|Boosaaso
HCMG|Gardo Airport|Gardo
HCMH|Egal International Airport|Hargeisa
HCMI|Berbera Airport|Berbera
HCMK|Kisimayu Airport|Kisimayu
HCMM|Mogadishu Airport|Mogadishu
HCMO|Obbia Airport|Obbia
HCMR|Galcaio Airport|Galcaio
HCMS|Scusciuban Airport|Scusciuban
HCMU|Erigavo Airport|Erigavo
HCMV|Burao Airport|Burao
HDAG|Assa-Gueyla Airport|Assa-Gueyla
HDAM|Djibouti-Ambouli International Airport|Djibouti City
HDAS|Ali-Sabieh Airport|Ali-Sabieh
HDCH|Chabelley Airport|Chabelley
HDDK|Dikhil Airport|Dikhil
HDHE|Herkale Airport|Herkale
HDMO|Moucha Airport|Moucha Island
HDOB|Obock Airport|Obock
HDTJ|Tadjoura Airport|Tadjoura
HEAR|El Arish International Airport|El Arish
HEAT|Asyut Airport|Assiut
HEAX|El Nhouza Airport|Alexandria
HEBA|Borg El Arab Airport|Alexandria
HEBL|Abu Simbel Airport|Abu Simbel
HECA|Cairo International Airport|Cairo
HECW|Cairo West Airport|Cairo West
HEGN|Hurghada Airport|Hurghada
HEGO|El-Gona Airport|Hurghada
HEGR|El Gora Airport|El Gora
HELX|Luxor International Airport|Luxor
HEMA|Marsa Alam International Airport|Marsa Alam
HEMM|Mersa Matruh Airport|Mersa Matruh
HENV|New Valley Airport|New Valley
HEOW|Sharq Al-Owainat Airport|Sharq Al-Owainat, Egypt
HEPS|Port Said Airport|Port Said
HESC|St. Catherine International Airport|St. Catherine
HESH|Sharm El Sheikh Airport|Sharm El Sheikh
HESN|Aswan Airport|Aswan
HETB|Taba International Airport|Taba
HHAS|Asmara International Airport|Asmara
HHMS|Massawa International Airport|Massawa
HHSB|Assab International Airport|Assab
HHTS|Teseney Airport|Teseney
HKAM|Amboseli Airport|Amboseli
HKEL|Eldoret International Airport|Eldoret
HKES|Eliye Springs Airport|Eliye Springs
HKFG|Kalokol Airport|Kalokol
HKGA|Garissa Airport|Garissa
HKHO|Hola Airport|Hola
HKJK|Jomo Kenyatta International Airport (formerly Nairobi International Airport)|Nairobi
HKKI|Kisumu Airport|Kisumu
HKKL|Kilaguni Airport|Kilaguni
HKKR|Kericho Airport|Kericho
HKKT|Kitale Airport|Kitale
HKLO|Lodwar Airport|Lodwar
HKLU|Manda Airport|Lamu
HKLY|Loyengalani Airport|Loiyangalani
HKMA|Mandera Airport|Mandera
HKMB|Marsabit Airport|Marsabit
HKML|Malindi Airport|Malindi
HKMO|Moi International Airport|Mombasa
HKMY|Moyale Lower Airport|Moyale
HKNI|Nyeri Airport|Nyeri
HKNK|Nakuru Airport|Nakuru
HKNW|Wilson Airport|Nairobi
HKNY|Nanyuki Airport|Nanyuki
HKRE|Eastleigh Airport|Nairobi
HKSB|Samburu Airport|Samburu
HKWJ|Wajir Airport|Wajir
HLGT|Ghat Airport|Ghat
HLKF|Kufra Airport|Kufra
HLLB|Benina International Airport|Benghazi
HLLM|Mitiga International Airport|Tripoli
HLLQ|La Abraq Airport|Beida
HLLS|Sebha Airport|Sebha
HLLT|Tripoli International Airport|Tripoli
HLMB|Marsa Brega Airport|Marsa Brega
HLTD|Ghadames East Airport|Ghadames
HRYG|Gisenyi Airport|Gisenyi
HRYI|Butare Airport|Butare
HRYR|Kigali International Airport (formerly Gregoire Kayibanda Airport)|Kigali
HRYU|Ruhengeri Airport|Ruhengeri
HRZA|Kamembe Airport|Cyangugu
HSAT|Atbara Airport|Atbara
HSDB|Eldebba Airport|Eldebba
HSDN|Dongola Airport|Dongola
HSFS|El Fasher Airport|El Fasher
HSGG|Galegu Airport|Dinder
HSGN|Geneina Airport|Geneina
HSKA|Kassala Airport|Kassala
HSKG|Khashm El Girba Airport|Khashm El Girba
HSKI|Rabak Airport|Kosti
HSMD|Maridi Airport|Maridi
HSMR|Merowe Airport|Merowe
HSNH|En Nahud Airport|En Nahud
HSNL|Nyala Airport|Nyala
HSOB|El Obeid Airport|El Obeid
HSPN|Port Sudan New International Airport|Port Sudan
HSSJ|Juba Airport|Juba
HSSM|Malakal Airport|Malakal
HSSP|Port Sudan New International Airport|Port Sudan
HSSS|Khartoum International Airport|Khartoum
HSSW|Wadi Halfa Airport|Wadi Halfa
HSWW|Wau Airport|Wau
HTAR|Arusha Airport|Arusha
HTBU|Bukoba Airport|Bukoba
HTDA|Dar es Salaam Airport|Dar es Salaam
HTDO|Dodoma Airport|Dodoma
HTIR|Iringa Airport|Iringa
HTKA|Kigoma Airport|Kigoma
HTKI|Kilwa Masoko Airport|Kilwa Masoko
HTKJ|Kilimanjaro International Airport|Mount Kilimanjaro
HTLI|Lindi Kikwetu Airport|Lindi
HTLM|Lake Manyara Airport|Lake Manyara
HTMA|Mafia Airport|Mafia
HTMB|Mbeya Airport|Mbeya
HTMD|Mwadui Airport|Mwadui
HTMI|Masasi Airport|Masasi
HTMS|Moshi Airport|Moshi
HTMT|Mtwara Airport|Mtwara
HTMU|Musoma Airport|Musoma
HTMW|Mwanza Airport|Mwanza
HTNA|Nachingwea Airport|Nachingwea
HTNJ|Njombe Airport|Njombe
HTPE|Pemba Airport|Pemba
HTSN|Seronera Airport|Seronera
HTSO|Songea Airport|Songea
HTSU|Sumbawanga Airport|Sumbawanga
HTSY|Shinyanga Airport|Shinyanga
HTTB|Tabora Airport|Tabora
HTTG|Tanga Airport|Tanga
HTZA|Zanzibar Airport|Zanzibar
HUAR|Arua Airport|Arua
HUEN|Entebbe International Airport|Entebbe (near Kampala)
HUGU|Gulu Airport|Gulu
HUJI|Jinja Airport|Jinja
HUKC|Kampala Airport|Kampala
HUKF|Kabalega Falls Airport|Kabalega Falls
HUKS|Kasese Airport|Kasese
HUMA|Mbarara Airport|Mbarara
HUMI|Masindi Airport|Masindi
HUSO|Soroti Airport|Soroti
HUTO|Tororo Airport|Tororo
KAAA|Logan County Airport|Lincoln, Illinois
KAAF|Apalachicola Municipal Airport|Apalachicola, Florida
KAAO|Colonel James Jabara Airport|Wichita, Kansas
KAAS|Taylor County Airport|Campbellsville, Kentucky
KAAT|Alturas Municipal Airport|Alturas, California
KABE|Lehigh Valley International Airport|Allentown, Bethlehem and Easton, Pennsylvania
KABI|Abilene Regional Airport|Abilene, Texas
KABQ|Albuquerque International Sunport|Albuquerque, New Mexico
KABR|Aberdeen Regional Airport|Aberdeen, South Dakota
KABY|Southwest Georgia Regional Airport|Albany, Georgia
KACB|Antrim County Airport|Bellaire, Michigan
KACJ|Souther Field|Americus, Georgia
KACK|Nantucket Memorial Airport|Nantucket, Massachusetts
KACP|Allen Parish Airport|Oakdale, Louisiana
KACQ|Waseca Municipal Airport|Waseca, Minnesota
KACT|Waco Regional Airport|Waco, Texas
KACV|Arcata-Eureka Airport|Arcata, California
KACY|Atlantic City International Airport|Atlantic City, New Jersey
KACZ|Henderson Field|Wallace, North Carolina
KADC|Wadena Municipal Airport|Wadena, Minnesota
KADG|Lenawee County Airport|Adrian, Michigan
KADH|Ada Municipal Airport|Ada, Oklahoma
KADM|Ardmore Municipal Airport|Ardmore, Oklahoma
KADS|Addison Airport|Addison, Texas
KADT|Atwood-Rawlins County City-County Airport|Atwood, Kansas
KADU|Audubon County Airport|Audubon, Iowa
KADW|Andrews Air Force Base|Camp Springs, Maryland
KAEG|Double Eagle II Airport|Albuquerque, New Mexico
KAEL|Albert Lea Municipal Airport|Albert Lea, Minnesota
KAEX|Alexandria International Airport|Alexandria, Louisiana
KAFF|United States Air Force Academy Airfield|Colorado Springs, Colorado
KAFJ|Washington County Airport|Washington, Pennsylvania
KAFK|Nebraska City Municipal Airport|Nebraska City, Nebraska
KAFN|Jaffrey Airport - Silver Ranch Airpark|Jaffrey, New Hampshire
KAFO|Afton Municipal Airport|Afton, Wyoming
KAFP|Anson County Airport|Wadesboro, North Carolina
KAFW|Fort Worth Alliance Airport|Fort Worth, Texas
KAGC|Allegheny County Airport|West Mifflin, Pennsylvania
KAGO|Magnolia Municipal Airport|Magnolia, Arkansas
KAGR|MacDill AFB Auxiliary Field|Avon Park, Florida
KAGS|Augusta Regional Airport at Bush Field|Augusta, Georgia
KAGZ|Wagner Municipal Airport|Wagner, South Dakota
KAHC|Amedee Army Airfield|Herlong, California
KAHH|Amery Municipal Airport|Amery, Wisconsin
KAHN|Athens-Ben Epps Airport|Athens, Georgia
KAHQ|Wahoo Municipal Airport|Wahoo, Nebraska
KAIA|Alliance Municipal Airport|Alliance, Nebraska
KAID|Anderson Municipal Airport (Darlington Field)|Anderson, Indiana
KAIG|Langlade County Airport|Antigo, Wisconsin
KAIK|Aiken Municipal Airport|Aiken, South Carolina
KAIO|Atlantic Municipal Airport|Atlantic, Iowa
KAIT|Aitkin Municipal Airport (Steve Kurtz Field)|Aitkin, Minnesota
KAIV|George Downer Airport|Aliceville, Alabama
KAIZ|Lee C. Fine Memorial Airport|Lake Ozark, Missouri
KAJG|Mount Carmel Municipal Airport|Mount Carmel, Illinois
KAJO|Corona Municipal Airport|Corona, California
KAJR|Habersham County Airport|Cornelia, Georgia
KAKH|Gastonia Municipal Airport|Gastonia, North Carolina
KAKO|Colorado Plains Regional Airport|Akron, Colorado
KAKQ|Wakefield Municipal Airport|Wakefield, Virginia
KAKR|Akron Fulton International Airport|Akron, Ohio
KALB|Albany International Airport|Albany, New York
KALI|Alice International Airport|Alice, Texas
KALM|Alamogordo-White Sands Regional Airport|Alamogordo, New Mexico
KALN|St. Louis Regional Airport|Alton, Illinois
KALO|Waterloo Regional Airport|Waterloo, Iowa
KALS|San Luis Valley Regional Airport|Alamosa, Colorado
KALW|Walla Walla Regional Airport|Walla Walla, Washington
KALX|Thomas C. Russell Field|Alexander City, Alabama
KAMA|Rick Husband Amarillo International Airport|Amarillo, Texas
KAMG|Bacon County Airport|Alma, Georgia
KAMN|Gratiot Community Airport|Alma, Michigan
KAMT|Alexander Salamon Airport|West Union, Ohio
KAMW|Ames Municipal Airport|Ames, Iowa
KANB|Anniston Metropolitan Airport|Anniston, Alabama
KAND|Anderson Regional Airport|Anderson, South Carolina
KANE|Anoka County-Blaine Airport (Janes Field)|Minneapolis, Minnesota
KANJ|Sault Ste Marie Municipal Airport (Sanderson Field)|Sault Ste Marie, Michigan
KANP|Lee Airport|Annapolis, Maryland
KANQ|Tri-State Steuben County Airport|Angola, Indiana
KANW|Ainsworth Municipal Airport|Ainsworth, Nebraska
KANY|Anthony Municipal Airport|Anthony, Kansas
KAOC|Arco Butte County Airport|Arco, Idaho
KAOH|Lima Allen County Airport|Lima, Ohio
KAOO|Altoona-Blair County Airport|Altoona, Pennsylvania
KAOV|Ava Bill Martin Memorial Airport|Ava, Missouri
KAPA|Centennial Airport|Centennial, Colorado (near Denver)
KAPC|Napa County Airport|Napa, California
KAPF|Naples Municipal Airport|Naples, Florida
KAPG|Phillips Army Airfield|Aberdeen Proving Ground, Maryland
KAPH|A.P. Hill Army Airfield|Fort A.P. Hill, Virginia
KAPN|Alpena County Regional Airport|Alpena, Michigan
KAPT|Marion County Airport (Brown Field)|Jasper, Tennessee
KAPV|Apple Valley Airport|Apple Valley, California
KAQO|Llano Municipal Airport|Llano, Texas
KAQP|Appleton Municipal Airport|Appleton, Minnesota
KAQR|Atoka Municipal Airport|Atoka, Oklahoma
KAQW|Harriman-and-West Airport|North Adams, Massachusetts
KARA|Acadiana Regional Airport|New Iberia, Louisiana
KARB|Ann Arbor Municipal Airport|Ann Arbor, Michigan
KARG|Walnut Ridge Regional Airport|Walnut Ridge, Arkansas
KARM|Wharton Regional Airport|Wharton, Texas
KARR|Aurora Municipal Airport|Aurora, Illinois
KART|Watertown International Airport|Watertown, New York
KARV|Lakeland Airport (Noble F. Lee Memorial Field)|Minocqua / Woodruff, Wisconsin
KASD|Slidell Airport|Slidell, Louisiana
KASE|Aspen-Pitkin County Airport|Aspen, Colorado
KASG|Springdale Municipal Airport|Springdale, Arkansas
KASH|Boire Field|Nashua, New Hampshire
KASJ|Tri-County Airport|Ahoskie, North Carolina
KASL|Harrison County Airport|Marshall, Texas
KASN|Talladega Municipal Airport|Talladega, Alabama
KAST|Astoria Regional Airport|Astoria, Oregon
KASW|Warsaw Municipal Airport|Warsaw, Indiana
KASX|John F. Kennedy Memorial Airport|Ashland, Wisconsin
KASY|Ashley Municipal Airport|Ashley, North Dakota
KATA|Hall-Miller Municipal Airport|Atlanta, Texas
KATL|Hartsfield-Jackson Atlanta International Airport|Atlanta, Georgia
KATS|Artesia Municipal Airport|Artesia, New Mexico
KATW|Outagamie County Regional Airport|Greenville, Wisconsin near Appleton
KATY|Watertown Regional Airport|Watertown, South Dakota
KAUG|Augusta State Airport|Augusta, Maine
KAUH|Aurora Municipal Airport (Al Potter Field)|Aurora, Nebraska
KAUM|Austin Municipal Airport|Austin, Minnesota
KAUN|Auburn Municipal Airport|Auburn, California
KAUO|Auburn-Opelika Robert G. Pitts Airport|Auburn, Alabama
KAUS|Austin-Bergstrom International Airport|Austin, Texas
KAUW|Wausau Downtown Airport|Wausau, Wisconsin
KAVC|Mecklenburg-Brunswick Regional Airport|South Hill, Virginia
KAVK|Alva Regional Airport|Alva, Oklahoma
KAVL|Asheville Regional Airport|Fletcher, North Carolina, near Asheville
KAVO|Avon Park Executive Airport|Avon Park, Florida
KAVP|Wilkes-Barre/Scranton International Airport|Avoca, Pennsylvania
KAVQ|Marana Regional Airport|Marana, Arizona (near Tucson)
KAVX|Catalina Airport|Avalon / Santa Catalina Island, California
KAWG|Washington Municipal Airport|Washington, Iowa
KAWM|West Memphis Municipal Airport|West Memphis, Arkansas
KAWO|Arlington Municipal Airport|Arlington, Washington
KAXA|Algona Municipal Airport|Algona, Iowa
KAXH|Houston-Southwest Airport|Houston, Texas
KAXN|Chandler Field|Alexandria, Minnesota
KAXQ|Clarion County Airport|Clarion, Pennsylvania
KAXS|Altus/Quartz Mountain Regional Airport|Altus, Oklahoma
KAXV|Neil Armstrong Airport|Wapakoneta, Ohio
KAXX|Angel Fire Airport|Angel Fire, New Mexico
KAYS|Waycross-Ware County Airport|Waycross, Georgia
KAYX|Arnold Air Force Base|Tullahoma, Tennessee
KAZC|Colorado City Municipal Airport|Colorado City, Arizona
KAZE|Hazlehurst Airport|Hazlehurst, Georgia
KAZO|Kalamazoo/Battle Creek International Airport|Kalamazoo / Battle Creek, Michigan
KAZU|Arrowhead Assault Strip|Fort Chaffee, Arkansas
KBAB|Beale Air Force Base|Marysville, California
KBAD|Barksdale Air Force Base|Bossier City, Louisiana
KBAF|Barnes Municipal Airport|Westfield / Springfield, Massachusetts
KBAK|Columbus Municipal Airport|Columbus, Indiana
KBAM|Battle Mountain Airport|Battle Mountain, Nevada
KBAX|Huron County Memorial Airport|Bad Axe, Michigan
KBAZ|New Braunfels Municipal Airport|New Braunfels, Texas
KBBB|Benson Municipal Airport|Benson, Minnesota
KBBD|Curtis Field|Brady, Texas
KBBG|Branson Airport (currently unnamed)|Hollister, Missouri - Branson, Missouri
KBBP|Marlboro County Jetport (H.E. Avent Field)|Bennettsville, South Carolina
KBBW|Broken Bow Municipal Airport|Broken Bow, Nebraska
KBCB|VirginiaTech/Montgomery Executive Airport|Blacksburg, Virginia
KBCE|Bryce Canyon Airport|Bryce Canyon, Utah
KBCK|Black River Falls Area Airport|Black River Falls, Wisconsin
KBCT|Boca Raton Airport|Boca Raton, Florida
KBDE|Baudette International Airport|Baudette, Minnesota
KBDG|Blanding Municipal Airport|Blanding, Utah
KBDJ|Boulder Junction Airport|Boulder Junction, Wisconsin
KBDL|Bradley International Airport|Windsor Locks, Connecticut (near Hartford)
KBDQ|Morrilton Municipal Airport|Morrilton, Arkansas
KBDR|Igor I. Sikorsky Memorial Airport|Bridgeport, Connecticut
KBEC|Beech Factory Airport|Wichita, Kansas
KBED|Laurence G. Hanscom Field|Bedford, Massachusetts
KBEH|Southwest Michigan Regional Airport|Benton Harbor, Michigan
KBFA|Boyne Mountain Airport|Boyne Falls, Michigan
KBFD|Bradford Regional Airport|Bradford, Pennsylvania
KBFE|Terry County Airport|Brownfield, Texas
KBFF|Western Nebraska Regional Airport (William B. Heilig Field)|Scottsbluff, Nebraska
KBFI|Boeing Field/King County International Airport|Seattle, Washington
KBFK|Buffalo Municipal Airport|Buffalo, Oklahoma
KBFL|Meadows Field Airport|Bakersfield, California
KBFM|Mobile Downtown Airport|Mobile, Alabama
KBFR|Virgil I. Grissom Municipal Airport|Bedford, Indiana
KBFW|Silver Bay Municipal Airport|Silver Bay, Minnesota
KBGD|Hutchinson County Airport|Borger, Texas
KBGE|Decatur County Industrial Air Park|Bainbridge, Georgia
KBGF|Winchester Municipal Airport|Winchester, Tennessee
KBGM|Greater Binghamton Airport|Binghamton, New York
KBGR|Bangor International Airport|Bangor, Maine
KBHB|Hancock County-Bar Harbor Airport|Bar Harbor, Maine
KBHC|Baxley Municipal Airport|Baxley, Georgia
KBHK|Baker Municipal Airport|Baker, Montana
KBHM|Birmingham International Airport|Birmingham, Alabama
KBID|Block Island State Airport|Block Island, Rhode Island
KBIE|Beatrice Municipal Airport|Beatrice, Nebraska
KBIF|Biggs Army Airfield|Fort Bliss, El Paso, Texas
KBIH|Eastern Sierra Regional Airport|Bishop, California
KBIL|Billings Logan International Airport|Billings, Montana
KBIS|Bismarck Municipal Airport|Bismarck, North Dakota
KBIV|Tulip City Airport|Holland, Michigan
KBIX|Keesler Air Force Base|Biloxi, Mississippi
KBJC|Rocky Mountain Metropolitan Airport|Denver, Colorado
KBJI|Bemidji Regional Airport|Bemidji, Minnesota
KBJJ|Wayne County Airport|Wooster, Ohio
KBKD|Stephens County Airport|Breckenridge, Texas
KBKE|Baker City Municipal Airport|Baker City, Oregon
KBKF|Buckley Air Force Base|Aurora, Colorado
KBKL|Cleveland Burke Lakefront Airport|Cleveland, Ohio
KBKS|Brooks County Airport|Falfurrias, Texas
KBKT|Allen C. Perkinson Airport / Blackstone Army Airfield|Blackstone, Virginia
KBKV|Hernando County Airport|Brooksville, Florida
KBKW|Beckley Raleigh County Memorial Airport|Beckley, West Virginia
KBKX|Brookings Municipal Airport|Brookings, South Dakota
KBLF|Mercer County Airport|Bluefield, West Virginia
KBLH|Blythe Airport|Blythe, California
KBLI|Bellingham International Airport|Bellingham, Washington
KBLM|Monmouth Executive Airport|Belmar / Farmingdale, New Jersey
KBLU|Blue Canyon-Nyack Airport|Emigrant Gap, California
KBLV|MidAmerica St. Louis Airport / Scott Air Force Base|Belleville, Illinois
KBMC|Brigham City Airport|Brigham City, Utah
KBMG|Monroe County Airport|Bloomington, Indiana
KBMI|Central Illinois Regional Airport|Bloomington, Illinois
KBML|Berlin Regional Airport|Berlin, New Hampshire
KBMQ|Burnet Municipal Airport (Kate Craddock Field)|Burnet, Texas
KBMT|Beaumont Municipal Airport|Beaumont, Texas
KBNA|Nashville International Airport|Nashville, Tennessee
KBNG|Banning Municipal Airport|Banning, California
KBNL|Barnwell County Airport|Barnwell, South Carolina
KBNO|Burns Municipal Airport|Burns, Oregon
KBNW|Boone Municipal Airport|Boone, Iowa
KBOI|Boise Air Terminal (Gowen Field)|Boise, Idaho
KBOK|Brookings State Airport|Brookings, Oregon
KBOS|Logan International Airport|Boston, Massachusetts
KBOW|Bartow Municipal Airport|Bartow, Florida
KBPG|Big Spring Mc Mahon-Wrinkle Airport|Big Spring, Texas
KBPI|Big Piney-Marbleton Airport|Big Piney, Wyoming
KBPK|Ozark Regional Airport (formerly Baxter County Regional Airport)|Mountain Home, Arkansas
KBPP|Bowman Municipal Airport|Bowman, North Dakota
KBPT|Southeast Texas Regional Airport|Nederland, Texas (near Beaumont & Port Arthur)
KBQK|Brunswick Golden Isles Airport|Brunswick, Georgia
KBQR|Buffalo-Lancaster Airport|Lancaster, New York
KBRD|Brainerd Lakes Regional Airport|Brainerd, Minnesota
KBRL|Southeast Iowa Regional Airport|Burlington, Iowa
KBRO|Brownsville/South Padre Island International Airport|Brownsville, Texas
KBRY|Samuels Field|Bardstown, Kentucky
KBST|Belfast Municipal Airport|Belfast, Maine
KBTF|Skypark Airport|Bountiful, Utah
KBTL|W. K. Kellogg Regional Airport|Battle Creek, Michigan
KBTM|Bert Mooney Airport|Butte, Montana
KBTN|Britton Municipal Airport|Britton, South Dakota
KBTP|Butler County Airport (K.W. Scholter Field)|Butler, Pennsylvania
KBTR|Baton Rouge Metropolitan Airport|Baton Rouge, Louisiana
KBTV|Burlington International Airport|Burlington, Vermont
KBTY|Beatty Airport|Beatty, Nevada
KBUB|Cram Field|Burwell, Nebraska
KBUF|Buffalo Niagara International Airport|Buffalo, New York
KBUM|Butler Memorial Airport|Butler, Missouri
KBUR|Bob Hope Airport|Burbank, California
KBUU|Burlington Municipal Airport|Burlington, Wisconsin
KBUY|Burlington-Alamance Regional Airport|Burlington, North Carolina
KBVI|Beaver County Airport|Beaver Falls, Pennsylvania
KBVN|Albion Municipal Airport|Albion, Nebraska
KBVO|Bartlesville Municipal Airport|Bartlesville, Oklahoma
KBVS|Skagit Regional Airport|Burlington & Mount Vernon, Washington
KBVX|Batesville Regional Airport|Batesville, Arkansas
KBVY|Beverly Municipal Airport|Beverly, Massachusetts
KBWC|Brawley Municipal Airport|Brawley, California
KBWD|Brownwood Regional Airport|Brownwood, Texas
KBWG|Bowling Green-Warren County Regional Airport|Bowling Green, Kentucky
KBWI|Baltimore-Washington International Thurgood Marshall Airport|Baltimore, Maryland & Washington, DC
KBWP|Harry Stern Airport|Wahpeton, North Dakota
KBXA|George R. Carr Memorial Airfield|Bogalusa, Louisiana
KBXG|Burke County Airport|Waynesboro, Georgia
KBXK|Buckeye Municipal Airport|Buckeye, Arizona
KBYG|Johnson County Airport|Buffalo, Wyoming
KBYH|Arkansas International Airport|Blytheville, Arkansas
KBYI|Burley Municipal Airport|Burley, Idaho
KBYS|Bicycle Lake Army Airfield (Fort Irwin)|Barstow, California
KBYY|Bay City Municipal Airport|Bay City, Texas
KBZN|Gallatin Field Airport|Bozeman, Montana
KCAD|Wexford County Airport|Cadillac, Michigan
KCAE|Columbia Metropolitan Airport|West Columbia, South Carolina (near Columbia)
KCAG|Craig-Moffat Airport|Craig, Colorado
KCAK|Akron-Canton Regional Airport|Akron, Ohio (near Canton)
KCAO|Clayton Municipal Airpark|Clayton, New Mexico
KCAR|Caribou Municipal Airport|Caribou, Maine
KCAV|Clarion Municipal Airport|Clarion, Iowa
KCBE|Greater Cumberland Regional Airport|Cumberland, Maryland
KCBF|Council Bluffs Municipal Airport|Council Bluffs, Iowa
KCBG|Cambridge Municipal Airport|Cambridge, Minnesota
KCBK|Shalz Field|Colby, Kansas
KCBM|Columbus Air Force Base|Columbus, Mississippi
KCCB|Cable Airport|Upland, California
KCCO|Newnan Coweta County Airport|Newnan, Georgia
KCCR|Buchanan Field Airport|Concord, California
KCCY|Northeast Iowa Regional Airport|Charles City, Iowa
KCDC|Cedar City Regional Airport|Cedar City, Utah
KCDH|Harrell Field|Camden, Arkansas
KCDI|Cambridge Municipal Airport|Cambridge, Ohio
KCDK|George T. Lewis Airport|Cedar Key, Florida
KCDN|Woodward Field|Camden, South Carolina
KCDR|Chadron Municipal Airport|Chadron, Nebraska
KCDS|Childress Municipal Airport|Childress, Texas
KCDW|Essex County Airport|Caldwell, New Jersey
KCEA|Cessna Aircraft Field|Wichita, Kansas
KCEC|Jack McNamara Field|Crescent City, California
KCEF|Westover Metropolitan Airport / Westover Air Reserve Base|Springfield / Chicopee, Massachusetts
KCEK|Crete Municipal Airport|Crete, Nebraska
KCEU|Oconee County Regional Airport|Clemson, South Carolina
KCEV|Mettel Field|Connersville, Indiana
KCEW|Bob Sikes Airport|Crestview, Florida
KCEY|Murray-Calloway County Airport|Murray, Kentucky
KCEZ|Cortez Municipal Airport|Cortez, Colorado
KCFD|Coulter Field|Bryan, Texas
KCFE|Buffalo Municipal Airport|Buffalo, Minnesota
KCFJ|Crawfordsville Municipal Airport|Crawfordsville, Indiana
KCFS [DEL::DEL]|Tuscola Area Airport|Caro, Michigan
KCFT|Greenlee County Airport|Clifton / Morenci, Arizona
KCFV|Coffeyville Municipal Airport|Coffeyville, Kansas
KCGC|Crystal River Airport|Crystal River, Florida
KCGE|Cambridge-Dorchester Airport|Cambridge, Maryland
KCGF|Cuyahoga County Airport|Cleveland, Ohio
KCGI|Cape Girardeau Regional Airport|Cape Girardeau, Missouri
KCGS|College Park Airport|College Park, Maryland
KCGZ|Casa Grande Municipal Airport|Casa Grande, Arizona
KCHA|Chattanooga Metropolitan Airport|Chattanooga, Tennessee
KCHD|Chandler Municipal Airport|Chandler, Arizona
KCHK|Chickasha Municipal Airport|Chickasha, Oklahoma
KCHN|Wauchula Municipal Airport|Wauchula, Florida
KCHO|Charlottesville-Albemarle Airport|Charlottesville, Virginia
KCHQ|Mississippi County Airport|Charleston, Missouri
KCHS|Charleston International Airport (Charleston Air Force Base)|Charleston, South Carolina
KCHT|Chillicothe Municipal Airport|Chillicothe, Missouri
KCHU|Houston County Airport|Caledonia, Minnesota
KCIC|Chico Municipal Airport|Chico, California
KCID|The Eastern Iowa Airport|Cedar Rapids, Iowa
KCII|Choteau Airport|Choteau, Montana
KCIN|Arthur N. Neu Airport|Carroll, Iowa
KCIR|Cairo Regional Airport|Cairo, Illinois
KCIU|Chippewa County International Airport|Sault Ste Marie, Michigan
KCJJ|Ellen Church Field|Cresco, Iowa
KCJR|Culpeper Regional Airport|Culpeper, Virginia
KCKA|Kegelman Air Force Auxiliary Field|Cherokee, Oklahoma
KCKB|Harrison/Marion Regional Airport|Clarksburg, West Virginia
KCKC|Grand Marais/Cook County Airport|Grand Marais, Minnesota
KCKF|Crisp County-Cordele Airport|Cordele, Georgia
KCKI|Williamsburg Regional Airport|Kingstree, South Carolina
KCKL|Cliff Hatfield Memorial Airport|Calipatria, California
KCKM|Fletcher Municipal Airport (Fletcher Field)|Clarksdale, Mississippi
KCKN|Crookston Municipal Airport|Crookston, Minnesota
KCKP|Cherokee Municipal Airport|Cherokee, Iowa
KCKV|Outlaw Field|Clarksville, Tennessee
KCLE|Cleveland Hopkins International Airport|Cleveland, Ohio
KCLI|Clintonville Municipal Airport|Clintonville, Wisconsin
KCLK|Clinton Regional Airport|Clinton, Oklahoma
KCLL|Easterwood Airport|College Station, Texas
KCLM|William R. Fairchild International Airport|Port Angeles, Washington
KCLR|Cliff Hatfield Memorial Airport|Calipatria, California
KCLS|Chehalis-Centralia Airport|Chehalis, Washington
KCLT|Charlotte/Douglas International Airport|Charlotte, North Carolina
KCLW|Clearwater Air Park|Clearwater, Florida
KCMA|Camarillo Airport|Camarillo, California
KCMH|Port Columbus International Airport|Columbus, Ohio
KCMI|University of Illinois Willard Airport|Savoy, Illinois (Champaign-Urbana area)
KCMR|H.A. Clark Memorial Field|Williams, Arizona
KCMX|Houghton County Memorial Airport|Hancock, Michigan
KCMY|Sparta/Fort McCoy Airport|Sparta, Wisconsin
KCNC|Chariton Municipal Airport|Chariton, Iowa
KCNH|Claremont Municipal Airport|Claremont, New Hampshire
KCNK|Blosser Municipal Airport|Concordia, Kansas
KCNM|Cavern City Air Terminal|Carlsbad, New Mexico
KCNO|Chino Airport|Chino, California
KCNP|Billy G. Ray Field|Chappell, Nebraska
KCNU|Chanute Martin Johnson Airport|Chanute, Kansas
KCNW|TSTC Waco Airport|Waco, Texas
KCNY|Canyonlands Field|Moab, Utah
KCOD|Yellowstone Regional Airport|Cody, Wyoming
KCOE|Coeur d'Alene Air Terminal|Coeur d'Alene, Idaho
KCOF|Patrick Air Force Base|Cocoa Beach, Florida
KCOI|Merritt Island Airport|Merritt Island, Florida
KCOM|Coleman Municipal Airport|Coleman, Texas
KCON|Concord Municipal Airport|Concord, New Hampshire
KCOQ|Cloquet Carlton County Airport|Cloquet, Minnesota
KCOS|Colorado Springs Airport (City of Colorado Springs Municipal Airport)|Colorado Springs, Colorado
KCOT|Cotulla-La Salle County Airport|Cotulla, Texas
KCOU|Columbia Regional Airport|Columbia, Missouri
KCPC|Columbus County Municipal Airport|Whiteville, North Carolina
KCPK|Chesapeake Regional Airport|Norfolk, Virginia
KCPM|Compton/Woodley Airport|Compton, California
KCPR|Natrona County International Airport|Casper, Wyoming
KCPS|St. Louis Downtown Airport|Cahokia, Illinois (near St. Louis, Missouri)
KCPT|Cleburne Municipal Airport|Cleburne, Texas
KCPU|Calaveras County Airport (Maury Rasmussen Field)|San Andreas, California
KCQA|Lakefield Airport|Celina, Ohio
KCQB|Chandler Regional Airport|Chandler, Oklahoma
KCQM|Cook Municipal Airport|Cook, Minnesota
KCQX|Chatham Municipal Airport|Chatham, Massachusetts
KCRE|Grand Strand Airport|North Myrtle Beach, South Carolina
KCRG|Craig Municipal Airport|Jacksonville, Florida
KCRO|Corcoran Airport|Corcoran, California
KCRP|Corpus Christi International Airport|Corpus Christi, Texas
KCRQ|McClellan-Palomar Airport|Carlsbad, California
KCRS|Corsicana Municipal Airport (C. David Campbell Field)|Corsicana, Texas
KCRT|Z.M. Jack Stell Field|Crossett, Arkansas
KCRW|Yeager Airport|Charleston, West Virginia
KCRX|Roscoe Turner Airport|Corinth, Mississippi
KCRZ|Corning Municipal Airport|Corning, Iowa
KCSB|Cambridge Municipal Airport|Cambridge, Nebraska
KCSG|Columbus Metropolitan Airport|Columbus, Georgia
KCSM|Clinton-Sherman Airport|Clinton, Oklahoma
KCSQ|Creston Municipal Airport|Creston, Iowa
KCSV|Crossville Memorial Airport (Whitson Field)|Crossville, Tennessee
KCTB|Cut Bank Municipal Airport|Cut Bank, Montana
KCTJ|West Georgia Regional Airport (O.V. Gray Field)|Carrollton, Georgia
KCTK|Ingersoll Airport|Canton, Illinois
KCTY|Cross City Airport|Cross City, Florida
KCTZ|Sampson County Airport|Clinton, North Carolina
KCUB|Columbia Owens Downtown Airport|Columbia, South Carolina
KCUH|Cushing Municipal Airport|Cushing, Oklahoma
KCUL|Carmi Municipal Airport|Carmi, Illinois
KCUT|Custer County Airport|Custer, South Dakota
KCVG|Cincinnati/Northern Kentucky International Airport|Hebron, Kentucky (near Cincinnati, Ohio and Covington, Kentucky)
KCVK|Sharp County Regional Airport|Ash Flat, Arkansas
KCVN|Clovis Municipal Airport|Clovis, New Mexico
KCVO|Corvallis Municipal Airport|Corvallis, Oregon
KCVS|Cannon Air Force Base|Clovis, New Mexico
KCVX|Charlevoix Municipal Airport|Charlevoix, Michigan
KCWA|Central Wisconsin Airport|Mosinee, Wisconsin
KCWF|Chennault International Airport|Lake Charles, Louisiana
KCWI|Clinton Municipal Airport|Clinton, Iowa
KCWS|Dennis F. Cantrell Field|Conway, Arkansas
KCWV|Claxton-Evans County Airport|Claxton, Georgia
KCXE|Chase City Municipal Airport|Chase City, Virginia
KCXL|Calexico International Airport|Calexico, California
KCXO|Lone Star Executive Airport|Houston, Texas
KCXP|Carson City Airport|Carson City, Nevada
KCXU|Camilla-Mitchell County Airport|Camilla, Georgia
KCXY|Capital City Airport|Harrisburg, Pennsylvania
KCYO|Pickaway County Memorial Airport|Circleville, Ohio
KCYS|Cheyenne Regional Airport (Jerry Olson Field)|Cheyenne, Wyoming
KCYW|Clay Center Municipal Airport|Clay Center, Kansas
KCZD|Cozad Municipal Airport|Cozad, Nebraska
KCZG|Tri-Cities Airport|Endicott, New York
KCZK|Cascade Locks State Airport|Cascade Locks, Oregon
KCZL|Tom B. David Field|Calhoun, Georgia
KCZT|Dimmit County Airport|Carrizo Springs, Texas
KDAA|Davison Army Airfield|Fort Belvoir, Virginia
KDAB|Daytona Beach International Airport|Daytona Beach, Florida
KDAF|Necedah Airport|Necedah, Wisconsin
KDAG|Barstow-Daggett Airport|Daggett, California
KDAL|Dallas Love Field|Dallas, Texas
KDAN|Danville Regional Airport|Danville, Virginia
KDAW|Skyhaven Airport|Rochester, New Hampshire
KDAY|James M. Cox International Airport|Dayton, Ohio
KDBN|W. H. 'Bud' Barron Airport|Dublin, Georgia
KDBQ|Dubuque Regional Airport|Dubuque, Iowa
KDCA|Ronald Reagan Washington National Airport|Arlington County, Virginia (near Washington, DC)
KDCU|Pryor Field Regional Airport|Decatur, Alabama
KDCY|Daviess County Airport|Washington, Indiana
KDDC|Dodge City Regional Airport|Dodge City, Kansas
KDDH|William H. Morse State Airport|Bennington, Vermont
KDEC|Decatur Airport|Decatur, Illinois
KDED|DeLand Municipal Airport (Sidney H. Taylor Field)|Deland, Florida
KDEH|Decorah Municipal Airport|Decorah, Iowa
KDEN|Denver International Airport (replaced Stapleton Int'l)|Denver, Colorado
KDEQ|J. Lynn Helms Sevier County Airport|De Queen, Arkansas
KDET|Coleman A. Young Municipal Airport|Detroit, Michigan
KDEW|Deer Park Airport|Deer Park, Washington
KDFI|Defiance Memorial Airport|Defiance, Ohio
KDFW|Dallas-Fort Worth International Airport|Dallas & Fort Worth, Texas
KDGL|Douglas Municipal Airport|Douglas, Arizona
KDGW|Converse County Airport|Douglas, Wyoming
KDHN|Dothan Regional Airport|Dothan, Alabama
KDHT|Dalhart Municipal Airport|Dalhart, Texas
KDIK|Dickinson - Theodore Roosevelt Regional Airport|Dickinson, North Dakota
KDKB|DeKalb Taylor Municipal Airport|DeKalb, Illinois
KDKK|Chautauqua County/Dunkirk Airport|Dunkirk, New York
KDKR|Houston County Airport|Crockett, Texas
KDKX|Knoxville Downtown Island Airport|Knoxville, Tennessee
KDLC|Dillon County Airport|Dillon, South Carolina
KDLF|Laughlin Air Force Base|Del Rio, Texas
KDLH|Duluth International Airport|Duluth, Minnesota
KDLL|Baraboo-Wisconsin Dells Airport|Baraboo, Wisconsin
KDLN|Dillon Airport|Dillon, Montana
KDLO|Delano Municipal Airport|Delano, California
KDLS|Columbia Gorge Regional Airport (The Dalles Municipal Airport)|The Dalles, Oregon
KDLZ|Delaware Municipal Airport|Delaware, Ohio; Dale Mabry Field (1928-1961) - Tallahassee, Florida
KDMA|Davis-Monthan Air Force Base|Tucson, Arizona
KDMN|Deming Municipal Airport|Deming, New Mexico
KDMO|Sedalia Memorial Airport|Sedalia, Missouri
KDMW|Carroll County Regional Airport (Jack B. Poage Field)|Westminster, Maryland
KDNL|Daniel Field|Augusta, Georgia
KDNN|Dalton Municipal Airport|Dalton, Georgia
KDNS|Denison Municipal Airport|Denison, Iowa
KDNV|Vermilion County Airport|Danville, Illinois
KDOV|Dover Air Force Base|Dover, Delaware
KDPA|Dupage Airport|West Chicago, Illinois
KDPG|Michael Army Airfield|Dugway Proving Ground, Utah
KDPL|Duplin County Airport|Kenansville, North Carolina
KDQH|Douglas Municipal Airport|Douglas, Georgia
KDRA|Desert Rock Airport|Mercury, Nevada
KDRI|Beauregard Regional Airport|De Ridder, Louisiana
KDRO|Durango-La Plata County Airport|Durango, Colorado
KDRT|Del Rio International Airport|Del Rio, Texas
KDRU|Drummond Airport|Drummond, Montana
KDSM|Des Moines International Airport|Des Moines, Iowa
KDSV|Dansville Municipal Airport|Dansville, New York
KDTA|Delta Municipal Airport|Delta, Utah
KDTG|Dwight Airport|Dwight, Illinois
KDTL|Detroit Lakes Airport (Wething Field)|Detroit Lakes, Minnesota
KDTN|Shreveport Downtown Airport|Shreveport, Louisiana
KDTO|Denton Municipal Airport|Denton, Texas
KDTS|Destin-Fort Walton Beach Airport|Destin, Florida
KDTW|Detroit Metropolitan Wayne County Airport|Romulus, Michigan near Detroit, Michigan
KDUA|Eaker Field|Durant, Oklahoma
KDUC|Halliburton Field|Duncan, Oklahoma
KDUG|Bisbee-Douglas International Airport|Bisbee / Douglas, Arizona
KDUH|Toledo Suburban Airport|Lambertville, Michigan
KDUJ|DuBois Regional Airport (formerly DuBois-Jefferson County Airport)|DuBois, Pennsylvania
KDUX|Moore County Airport|Dumas, Texas
KDVK|Stuart Powell Field|Danville, Kentucky
KDVL|Devils Lake Municipal Airport|Devils Lake, North Dakota
KDVN|Davenport Municipal Airport|Davenport, Iowa
KDVO|Gnoss Field|Novato, California
KDVP|Slayton Municipal Airport|Slayton, Minnesota
KDVT|Phoenix Deer Valley Airport|Phoenix, Arizona
KDWH|David Wayne Hooks Memorial Airport|Spring, Texas
KDWU|Ashland-Boyd County Airport|Ashland, Kentucky
KDXE|Dexter Municipal Airport|Dexter, Missouri
KDXR|Danbury Municipal Airport|Danbury, Connecticut
KDXX|Lac qui Parle County Airport|Madison, Minnesota
KDYB|Summerville Airport|Summerville, South Carolina
KDYL|Doylestown Airport|Doylestown, Pennsylvania
KDYR|Dyersburg Regional Airport|Dyersburg, Tennessee
KDYS|Dyess Air Force Base|Abilene, Texas
KDYT|Sky Harbor Airport|Duluth, Minnesota
KEAG|Eagle Grove Municipal Airport|Eagle Grove, Iowa
KEAN|Phifer Airfield|Wheatland, Wyoming
KEAR|Kearney Municipal Airport|Kearney, Nebraska
KEAT|Pangborn Memorial Airport|Wenatchee, Washington
KEAU|Chippewa Valley Regional Airport|Eau Claire, Wisconsin
KEBG|South Texas International Airport at Edinburg|Edinburg, Texas
KEBS|Webster City Municipal Airport|Webster City, Iowa
KECG|Elizabeth City-Pasquotank County Regional Airport / Elizabeth City CGAS|Elizabeth City, North Carolina
KECS|Mondell Field|Newcastle, Wyoming
KECU|Edwards County Airport|Rocksprings, Texas
KEDE|Northeastern Regional Airport|Edenton, North Carolina
KEDG|Weide Army Airfield|Edgewood Arsenal, Aberdeen Proving Ground, Maryland
KEDJ|Bellefontaine Regional Airport|Bellefontaine, Ohio
KEDN|Enterprise Municipal Airport|Enterprise, Alabama
KEDW|Edwards Air Force Base|Rosamond, California
KEED|Needles Airport|Needles, California
KEEN|Dillant-Hopkins Airport|Keene, New Hampshire
KEEO|Meeker Airport|Meeker, Colorado
KEET|Shelby County Airport|Alabaster, Alabama
KEFC|Belle Fourche Municipal Airport|Belle Fourche, South Dakota
KEFD|Ellington Field|Houston, Texas
KEFK|Newport State Airport|Newport, Vermont
KEFT|Monroe Municipal Airport|Monroe, Wisconsin
KEFW|Jefferson Municipal Airport|Jefferson, Iowa
KEGE|Eagle County Regional Airport|Eagle, Colorado (near Vail)
KEGI|Duke Field (Eglin Auxiliary Field 3)|Crestview, Florida
KEGQ|Emmetsburg Municipal Airport|Emmetsburg, Iowa
KEGT|Wellington Municipal Airport|Wellington, Kansas
KEGV|Eagle River Union Airport|Eagle River, Wisconsin
KEHA|Elkhart-Morton County Airport|Elkhart, Kansas
KEHO|Shelby Municipal Airport|Shelby, North Carolina
KEHR|Henderson City-County Airport|Henderson, Kentucky
KEIN|Pine Ridge Airport|Pine Ridge, South Dakota
KEIW|County Memorial Airport|New Madrid, Missouri
KEKA|Murray Field|Eureka, California
KEKM|Elkhart Municipal Airport|Elkhart, Indiana
KEKN|Elkins-Randolph County Airport (Jennings Randolph Field)|Elkins, West Virginia
KEKO|Elko Regional Airport|Elko, Nevada
KEKQ|Wayne County Airport|Monticello, Kentucky
KEKX|Addington Field|Elizabethtown, Kentucky
KEKY|Bessemer Airport|Bessemer, Alabama
KELA|Eagle Lake Airport|Eagle Lake, Texas
KELD|South Arkansas Regional Airport at Goodwin Field|El Dorado, Arkansas
KELK|Elk City Municipal Airport|Elk City, Oklahoma
KELM|Elmira/Corning Regional Airport|Big Flats, New York (near Elmira & Corning)
KELN|Bowers Field|Ellensburg, Washington
KELO|Ely Municipal Airport|Ely, Minnesota
KELP|El Paso International Airport|El Paso, Texas
KELY|Ely Airport (Yelland Field)|Ely, Nevada
KELZ|Wellsville Municipal Airport|Wellsville, New York
KEMM|Kemmerer Municipal Airport|Kemmerer, Wyoming
KEMP|Emporia Municipal Airport|Emporia, Kansas
KEMT|El Monte Airport|El Monte, California
KEMV|Emporia-Greensville Regional Airport|Emporia, Virginia
KEND|Vance Air Force Base|Enid, Oklahoma
KENL|Centralia Municipal Airport|Centralia, Illinois
KENV|Wendover Airport|Wendover, Utah
KENW|Kenosha Regional Airport|Kenosha, Wisconsin
KEOK|Keokuk Municipal Airport|Keokuk, Iowa
KEOP|Pike County Airport|Waverly, Ohio
KEOS|Neosho Hugh Robinson Airport|Neosho, Missouri
KEPG|Browns Airport|Weeping Water, Nebraska
KEPH|Ephrata Municipal Airport|Ephrata, Washington
KEPM|Eastport Municipal Airport|Eastport, Maine
KEQA|Captain Jack Thomas/El Dorado Airport|El Dorado, Kansas
KEQY|Monroe Regional Airport|Monroe, North Carolina
KERI|Erie International Airport (Tom Ridge Field)|Erie, Pennsylvania
KERR|Errol Airport|Errol, New Hampshire
KERV|Kerrville Municipal Airport (Louis Schreiner Field)|Kerrville, Texas
KERY|Luce County Airport|Newberry, Michigan
KESC|Delta County Airport|Escanaba, Michigan
KESF|Esler Regional Airport|Alexandria, Louisiana
KESN|Easton/Newnam Field|Easton, Maryland
KEST|Estherville Municipal Airport|Estherville, Iowa
KESW|Easton State Airport|Easton, Washington
KETB|West Bend Municipal Airport|West Bend, Wisconsin
KETC|Tarboro-Edgecombe Airport|Tarboro, North Carolina
KETN|Eastland Municipal Airport|Eastland, Texas
KEUF|Weedon Field|Eufaula, Alabama
KEUG|Eugene Airport / Mahlon Sweet Field|Eugene, Oregon
KEUL|Caldwell Industrial Airport|Caldwell, Idaho
KEVB|New Smyrna Beach Municipal Airport|New Smyrna Beach, Florida
KEVM|Eveleth-Virginia Municipal Airport|Eveleth, Minnesota
KEVU|Northwest Missouri Regional Airport|Maryville, Missouri
KEVV|Evansville Regional Airport|Evansville, Indiana
KEVW|Evanston-Uinta County Airport (Burns Field)|Evanston, Wyoming
KEVY|Summit Airport|Middletown, Delaware
KEWB|New Bedford Regional Airport|New Bedford, Massachusetts
KEWK|Newton City/County Airport|Newton, Kansas
KEWN|Craven County Regional Airport|New Bern, North Carolina
KEWR|Newark Liberty International Airport|Newark & Elizabeth, New Jersey
KEXX|Davidson County Airport|Lexington, North Carolina
KEYE|Eagle Creek Airpark|Indianapolis, Indiana
KEYF|Curtis L. Brown Jr. Field|Elizabethtown, North Carolina
KEYQ|Weiser Air Park|Houston, Texas
KEYW|Key West International Airport|Key West, Florida
KEZF|Shannon Airport|Fredericksburg, Virginia
KEZI|Kewanee Municipal Airport|Kewanee, Illinois
KEZM|Heart of Georgia Regional Airport|Eastman, Georgia
KEZZ|Cameron Memorial Airport|Cameron, Missouri
KFAF|Felker Army Airfield|Fort Eustis, Virginia
KFAM|Farmington Regional Airport|Farmington, Missouri
KFAR|Hector International Airport|Fargo, North Dakota
KFAT|Fresno Yosemite International Airport|Fresno, California
KFAY|Fayetteville Regional Airport (Grannis Field)|Fayetteville, North Carolina
KFBG|Simmons Army Airfield|Fort Bragg, North Carolina
KFBL|Faribault Municipal Airport|Faribault, Minnesota
KFBR|Fort Bridger Airport|Fort Bridger, Wyoming
KFBY|Fairbury Municipal Airport|Fairbury, Nebraska
KFCA|Glacier Park International Airport|Kalispell, Montana
KFCH|Fresno Chandler Executive Airport|Fresno, California
KFCI|Chesterfield County Airport|Richmond, Virginia
KFCM|Flying Cloud Airport|Minneapolis, Minnesota
KFCS|Butts Army Airfield (Fort Carson)|Fort Carson, Colorado
KFCT|Vagabond Army Airfield|Yakima, Washington
KFCY|Forrest City Municipal Airport|Forrest City, Arkansas
KFDK|Frederick Municipal Airport|Frederick, Maryland
KFDR|Frederick Municipal Airport|Frederick, Oklahoma
KFDW|Fairfield County Airport|Winnsboro, South Carolina
KFDY|Findlay Airport|Findlay, Ohio
KFEP|Albertus Airport|Freeport, Illinois
KFES|Festus Memorial Airport|Festus, Missouri
KFET|Fremont Municipal Airport|Fremont, Nebraska
KFFA|First Flight Airport|Kill Devil Hills, North Carolina
KFFC|Falcon Field|Peachtree City, Georgia
KFFL|Fairfield Municipal Airport|Fairfield, Iowa
KFFM|Fergus Falls Municipal Airport (Einar Mickelson Field)|Fergus Falls, Minnesota
KFFO|Wright-Patterson Air Force Base|Dayton, Ohio
KFFT|Capital City Airport|Frankfort, Kentucky
KFFZ|Falcon Field|Mesa, Arizona
KFGX|Fleming-Mason Airport|Flemingsburg, Kentucky
KFHR|Friday Harbor Airport|Friday Harbor, Washington
KFHU|Sierra Vista Municipal Airport / Libby Army Airfield|Fort Huachuca / Sierra Vista, Arizona
KFIG|Clearfield-Lawrence Airport|Clearfield, Pennsylvania
KFIT|Fitchburg Municipal Airport|Fitchburg, Massachusetts
KFKA|Fillmore County Airport|Preston, Minnesota
KFKL|Venango Regional Airport|Franklin, Pennsylvania
KFKN|Franklin Municipal Airport (John Beverly Rose Field)|Franklin, Virginia
KFKR|Frankfort Municipal Airport|Frankfort, Indiana
KFKS|Frankfort Dow Memorial Field|Frankfort, Michigan
KFLD|Fond du Lac County Airport|Fond du Lac, Wisconsin
KFLG|Flagstaff Pulliam Airport|Flagstaff, Arizona
KFLL|Fort Lauderdale-Hollywood International Airport|Fort Lauderdale / Hollywood, Florida
KFLO|Florence Regional Airport|Florence, South Carolina
KFLP|Marion County Regional Airport|Flippin, Arkansas
KFLV|Sherman Army Airfield|Fort Leavenworth, Kansas
KFLX|Fallon Municipal Airport|Fallon, Nevada
KFME|Tipton Airport|Fort Meade / Odenton, Maryland
KFMH|Otis Air National Guard Base|Falmouth, Massachusetts
KFMN|Four Corners Regional Airport|Farmington, New Mexico
KFMY|Page Field|Fort Myers, Florida
KFMZ|Fairmont State Airfield|Fairmont, Nebraska
KFNB|Brenner Field|Falls City, Nebraska
KFNL|Fort Collins-Loveland Municipal Airport|Fort Collins / Loveland, Colorado
KFNT|Bishop International Airport|Flint, Michigan
KFOA|Flora Municipal Airport|Flora, Illinois
KFOD|Fort Dodge Regional Airport|Fort Dodge, Iowa
KFOE|Forbes Field|Topeka, Kansas
KFOK|Francis S. Gabreski Airport|Westhampton Beach, New York
KFOT|Rohnerville Airport|Fortuna, California
KFOZ|Bigfork Municipal Airport|Bigfork, Minnesota
KFPK|Fitch H. Beach Airport|Charlotte, Michigan
KFPR|St. Lucie County International Airport|Fort Pierce, Florida
KFQD|Rutherford County Airport (Marchman Field)|Rutherfordton, North Carolina
KFRG|Republic Airport|East Farmingdale, New York
KFRH|French Lick Municipal Airport|French Lick, Indiana
KFRI|Marshall Army Airfield|Fort Riley / Junction City, Kansas
KFRM|Fairmont Municipal Airport|Fairmont, Minnesota
KFRR|Front Royal-Warren County Airport|Front Royal, Virginia
KFSD|Sioux Falls Regional Airport (Joe Foss Field)|Sioux Falls, South Dakota
KFSE|Fosston Municipal Airport|Fosston, Minnesota
KFSI|Henry Post Army Airfield|Fort Sill / Lawton, Oklahoma
KFSK|Fort Scott Municipal Airport|Fort Scott, Kansas
KFSM|Fort Smith Regional Airport|Fort Smith, Arkansas
KFSO|Franklin County State Airport|Highgate, Vermont
KFST|Fort Stockton-Pecos County Airport|Fort Stockton, Texas
KFSU|Fort Sumner Municipal Airport|Fort Sumner, New Mexico
KFSW|Fort Madison Municipal Airport|Fort Madison, Iowa
KFTG|Front Range Airport|Aurora, Colorado
KFTK|Godman Army Airfield|Fort Knox, Kentucky
KFTT|Elton Hensley Memorial Airport|Fulton, Missouri
KFTW|Fort Worth Meacham International Airport|Fort Worth, Texas
KFTY|Fulton County Airport (Brown Field)|Atlanta, Georgia
KFUL|Fullerton Municipal Airport|Fullerton, California
KFVE|Northern Aroostook Regional Airport|Frenchville, Maine
KFVX|Farmville Regional Airport|Farmville, Virginia
KFWA|Fort Wayne International Airport|Fort Wayne, Indiana
KFWC|Fairfield Municipal Airport|Fairfield, Illinois
KFWN|Sussex Airport|Sussex, New Jersey
KFWQ|Rostraver Airport|Monongahela, Pennsylvania (suburb of Pittsburgh)
KFWS|Fort Worth Spinks Airport|Fort Worth, Texas
KFXE|Fort Lauderdale Executive Airport|Fort Lauderdale, Florida
KFXY|Forest City Municipal Airport|Forest City, Iowa
KFYE|Fayette County Airport|Somerville, Tennessee
KFYJ|Middle Peninsula Regional Airport|West Point, Virginia
KFYM|Fayetteville Municipal Airport|Fayetteville, Tennessee
KFYV|Drake Field / Fayetteville Municipal Airport|Fayetteville, Arkansas
KFZG|Fitzgerald Municipal Airport|Fitzgerald, Georgia
KFZI|Fostoria Metropolitan Airport|Fostoria, Ohio
KFZY|Oswego County Airport|Fulton, New York
KGAB|Gabbs Airport|Gabbs, Nevada
KGAD|Northeast Alabama Regional Airport|Gadsden, Alabama
KGAF|Grafton Municipal Airport|Grafton, North Dakota
KGAI|Montgomery County Airpark|Gaithersburg, Maryland
KGBD|Great Bend Municipal Airport|Great Bend, Kansas
KGBR|Walter J. Koladza Airport|Great Barrington, Massachusetts
KGCC|Gillette-Campbell County Airport|Gillette, Wyoming
KGCK|Garden City Regional Airport|Garden City, Kansas
KGCN|Grand Canyon National Park Airport|Grand Canyon National Park, Arizona
KGDM|Gardner Municipal Airport|Gardner, Massachusetts
KGDV|Dawson Community Airport|Glendive, Montana
KGDJ|Granbury Municipal Airport|Granbury, Texas
KGDY|Grundy Municipal Airport|Grundy, Virginia
KGED|Sussex County Airport|Georgetown, Delaware
KGEG|Spokane International Airport|Spokane, Washington
KGEU|Glendale Municipal Airport|Glendale, Arizona
KGEV|Ashe County Airport|Jefferson, North Carolina
KGEY|South Big Horn County Airport|Greybull, Wyoming
KGFA|Great Falls Air Force Base|Great Falls, Montana
KGFK|Grand Forks International Airport|Grand Forks, North Dakota
KGFL|Bennett Memorial Airport|Glens Falls, New York
KGGE|Georgetown County Airport|Georgetown, South Carolina
KGGF|Grant Municipal Airport|Grant, Nebraska
KGGG|East Texas Regional Airport|Longview, Texas
KGGI|Grinnell Regional Airport|Grinnell, Iowa
KGGW|Glasgow Airport|Glasgow, Montana
KGJT|Grand Junction Regional Airport (Walker Field)|Grand Junction, Colorado
KGKJ|Port Meadville Airport|Meadville, Pennsylvania
KGKY|Arlington Municipal Airport|Arlington, Texas
KGLD|Renner Goodland Municipal Airport|Goodland, Kansas
KGLH|Mid Delta Regional Airport|Greenville, Mississippi
KGLS|Scholes International Airport at Galveston|Galveston, Texas
KGMU|Greenville Downtown Airport|Greenville, South Carolina
KGNB|Granby-Grand County Airport|Granby, Colorado
KGNF|Grenada Municipal Airport|Grenada, Mississippi
KGNG|Gooding Municipal Airport|Gooding, Idaho
KGNT|Grants-Milan Municipal Airport|Grants, New Mexico
KGNV|Gainesville Regional Airport|Gainesville, Florida
KGON|Groton-New London Airport|Groton / New London, Connecticut
KGPT|Gulfport-Biloxi International Airport|Gulfport, Mississippi
KGRB|Austin Straubel International Airport|Green Bay, Wisconsin
KGRD|Greenwood County Airport|Greenwood, South Carolina
KGRF|Gray Army Airfield|Fort Lewis, Washington
KGRI|Central Nebraska Regional Airport|Grand Island, Nebraska
KGRN|Gordon Municipal Airport|Gordon, Nebraska
KGRR|Gerald R. Ford International Airport|Grand Rapids, Michigan
KGSB|Seymour Johnson AFB|Goldsboro, North Carolina
KGSO|Piedmont Triad International Airport|Greensboro, North Carolina
KGSP|Greenville-Spartanburg International Airport|Greer, South Carolina
KGSW|Greater Southwest International Airport (closed 1970s)|Fort Worth, Texas
KGTB|Wheeler-Sack AAF|Fort Drum, New York
KGTE|Quinn Airport|Gothenburg, Nebraska
KGTF|Great Falls International Airport|Great Falls, Montana
KGTR|Golden Triangle Regional Airport|Columbus, Mississippi
KGTU|Georgetown Municipal Airport|Georgetown, Texas
KGUC|Gunnison County Airport|Gunnison, Colorado
KGUP|Gallup Municipal Airport|Gallup, New Mexico
KGUS|Grissom Air Reserve Base|Peru, Indiana
KGVE|Gordonsville Municipal Airport|Gordonsville, Virginia
KGVT|Majors Airport|Greenville, Texas
KGVQ|Genesee County Airport|Batavia, New York
KGWO|Greenwood-Leflore Airport|Greenwood, Mississippi
KGWR|Gwinner-Roger Melroe Field|Gwinner, North Dakota
KGWS|Glenwood Springs Municipal Airport|Glenwood Springs, Colorado
KGWW|Goldsboro-Wayne Municipal Airport|Goldsboro, North Carolina
KGXY|Greeley-Weld County Airport|Greeley, Colorado
KGYB|Giddings-Lee County Airport|Giddings, Texas
KGYH|Donaldson Center Airport|Greenville, South Carolina
KGYI|Grayson County Airport|Denison, Texas
KGYR|Goodyear Municipal Airport|Phoenix, Arizona
KGYY|Gary/Chicago International Airport|Gary, Indiana
KGZH|Middleton Airport|Evergreen, Alabama
KHAB|Marion County - Rankin Fite Airport|Hamilton, Alabama
KHAF|Half Moon Bay Airport|Half Moon Bay, California
KHAR|Harford Airport|Casper, Wyoming
KHBC|Mohall Municipal Airport|Mohall, North Dakota
KHBG|Chain Municipal Airport|Hattiesburg, Mississippi
KHBI|Asheboro Regional Airport|Asheboro, North Carolina
KHBZ|Heber Springs Municipal Airport|Heber Springs, Arkansas
KHCD|Hutchinson Municipal Airport|Hutchinson, Minnesota
KHDE|Brewster Airport|Holdrege, Nebraska
KHDN|Yampa Valley Airport|Hayden, Colorado
KHDO|Hondo Municipal Airport|Hondo, Texas
KHEE|Thompson-Robbins Airport|Helena, Arkansas
KHEF|Manassas Regional Airport|Manassas, Virginia
KHEI|Hettinger Municipal Airport|Hettinger, North Dakota
KHEQ|Holyoke Municipal Airport|Holyoke, Colorado
KHEZ|Natchez-Adams County Airport|Natchez, Mississippi
KHFD|Hartford-Brainard Airport|Hartford, Connecticut
KHFF|Mackall Army Airfield|Camp Mackall, North Carolina
KHGR|Hagerstown Regional Airport|Hagerstown, Maryland
KHHR|Hawthorne Municipal Airport|Hawthorne, California
KHIE|Mount Washington Regional Airport|Whitefield, New Hampshire
KHIF|Hill Air Force Base|Ogden, Utah
KHII|Lake Havasu City Airport|Lake Havasu City, Arizona
KHIO|Hillsboro Airport|Portland, Oregon
KHJH|Hebron Municipal Airport|Hebron, Nebraska
KHJO|Hanford Municipal Airport|Hanford, California
KHKA|Blytheville Municipal Airport|Blytheville, Arkansas
KHKS|Hawkins Field|Jackson, Mississippi
KHKY|Hickory Regional Airport|Hickory, North Carolina
KHLC|Hill City Municipal Airport|Hill City, Kansas
KHLG|Wheeling-Ohio County Airport|Wheeling, West Virginia
KHLN|Helena Regional Airport|Helena, Montana
KHLX|Twin County Airport|Galax-Hillsville, Virginia
KHMN|Holloman Air Force Base|Alamogordo, New Mexico
KHMT|Hemet-Ryan Airport|Hemet, California
KHMZ|Bedford County Airport|Bedford, Pennsylvania
KHND|Henderson Executive Airport|Henderson, Nevada
KHNZ|Oxford-Henderson Airport|Oxford, North Carolina
KHOB|Lea County Regional Airport|Hobbs, New Mexico
KHOE|Homerville Airport|Homerville, Georgia
KHON|Huron Regional Airport|Huron, South Dakota
KHOP|Campbell Army Airfield|Fort Campbell, Kentucky
KHOT|Hot Springs Memorial Field Airport|Hot Springs, Arkansas
KHOU|William P. Hobby Airport|Houston, Texas
KHPN|Westchester County Airport|White Plains, New York
KHQG|Hugoton Municipal Airport|Hugoton, Kansas
KHQM|Bowerman Airport|Hoquiam, Washington
KHQU|Thomson-McDuffie County Airport|Thomson, Georgia
KHQZ|Mesquite Metro Airport|Mesquite, Texas
KHRI|Hermiston Municipal Airport|Hermiston, Oregon
KHRJ|Harnett County Airport|Erwin, North Carolina
KHRL|Valley International Airport|Harlingen, Texas
KHRO|Boone County Airport|Harrison, Arkansas
KHRU|Herington Regional Airport|Herington, Kansas
KHSA|Stennis International Airport|Bay St. Louis, Mississippi
KHSE|Billy Mitchell Airport|Hatteras, North Carolina
KHSI|Hastings Municipal Airport|Hastings, Nebraska
KHSP|Ingalls Field|Hot Springs, Virginia
KHSR|Hot Springs Municipal Airport|Hot Springs, South Dakota
KHST|Homestead Joint Air Reserve Base|Homestead, Florida
KHSV|Huntsville International Airport|Huntsville, Alabama
KHTH|Hawthorne Industrial Airport|Hawthorne, Nevada
KHTO|East Hampton Airport|East Hampton, New York
KHTS|Tri-State Airport|Huntington, West Virginia
KHUA|Redstone Army Airfield|Redstone Arsenal, Huntsville, Alabama
KHUM|Houma-Terrebonne Airport|Houma, Louisiana
KHUT|Hutchinson Municipal Airport|Hutchinson, Kansas
KHVC|Hopkinsville-Christian County Airport|Hopkinsville, Kentucky
KHVE|Hanksville Airport|Hanksville, Utah
KHVN|Tweed-New Haven Airport|New Haven, Connecticut
KHVR|Havre City County Airport|Havre, Montana
KHVS|Hartsville Regional Airport|Hartsville, South Carolina
KHWD|Hayward Executive Airport|Hayward, California
KHWQ|Wheatland County Airport|Harlowton, Montana
KHWV|Brookhaven Airport|Shirley, New York
KHXD|Hilton Head Airport|Hilton Head Island, South Carolina
KHXF|Hartford Municipal Airport|Hartford, Wisconsin
KHYA|Barnstable Municipal Airport|Hyannis, Massachusetts
KHYI|San Marcos Municipal Airport|San Marcos, Texas
KHYR|Sawyer County Airport|Hayward, Wisconsin
KHYS|Hays Regional Airport|Hays, Kansas
KHYW|Conway-Horry County Airport|Conway, South Carolina
KHYX|Saginaw County H.W. Browne Airport|Saginaw, Michigan
KHZE|Mercer County Regional Airport|Hazen, North Dakota
KHZL|Hazleton Municipal Airport|Hazleton, Pennsylvania
KHUL|Houlton International Airport|Houlton, Maine
KIAB|McConnell Air Force Base|Wichita, Kansas
KIAD|Washington Dulles International Airport|Washington, DC
KIAG|Niagara Falls International Airport|Niagara Falls, New York
KIAH|George Bush Intercontinental Airport|Houston, Texas
KIBM|Kimball Municipal Airport (Arraj Field)|Kimball, Nebraska
KICT|Wichita Mid-Continent Airport|Wichita, Kansas
KIDA|Idaho Falls Regional Airport|Idaho Falls, Idaho
KIDI|Indiana County-Jimmy Stewart Airport|Indiana, Pennsylvania
KIDL|Indianola Municipal Airport|Indianola, Mississippi
KIDP|Independence Municipal Airport|Independence, Kansas
KIFP|Laughlin/Bullhead International Airport|Bullhead City, Arizona
KIGM|Kingman Airport|Kingman, Arizona
KIGX|Horace Williams Airport|Chapel Hill, North Carolina
KIIB|Independence Municipal Airport|Independence, Iowa
KIIY|Washington-Wilkes County Airport|Washington, Georgia
KIJD|Windham Airport|Willimantic, Connecticut
KILE|Skylark Field|Killeen, Texas
KILG|New Castle County Airport|Wilmington, Delaware
KILM|Wilmington International Airport|Wilmington, North Carolina
KIML|Imperial Municipal Airport|Imperial, Nebraska
KIMM|Immokalee Airport|Immokalee, Florida
KIND|Indianapolis International Airport|Indianapolis, Indiana
KINS|Creech Air Force Base|Indian Springs, Nevada
KINT|Smith Reynolds Airport|Winston-Salem, North Carolina
KINW|Winslow-Lindbergh Regional Airport|Winslow, Arizona
KIOW|Iowa City Municipal Airport|Iowa City, Iowa
KIPJ|Lincoln County Regional Airport|Lincolnton, North Carolina
KIPL|Imperial County Airport|Imperial, California
KIPT|Williamsport Regional Airport|Williamsport, Pennsylvania
KISN|Sloulin Field International Airport|Williston, North Dakota
KISO|Kinston Regional Jetport (Stallings Field) - Kinston, North Carolina|
KISP|Long Island MacArthur Airport|Islip, New York
KITH|Ithaca Tompkins Regional Airport|Ithaca, New York
KITR|Kit Carson County Airport|Burlington, Colorado
KIWA|Phoenix-Mesa Gateway Airport|Mesa, Arizona
KIWI|Wiscasset Airport|Wiscasset, Maine
KIXD|New Century AirCenter|Olathe, Kansas
KIYK|Inyokern Airport|Inyokern, California
KIZA|Santa Ynez Airport|Santa Ynez, California
KIZG|Eastern Slopes Regional Airport|Fryeburg, Maine
KJAC|Jackson Hole Airport|Jackson Hole, Wyoming
KJAN|Jackson International Airport|Jackson, Mississippi
KJAX|Jacksonville International Airport|Jacksonville, Florida
KJBR|Jonesboro Municipal Airport|Jonesboro, Arkansas
KJDN|Jordan Airport|Jordan, Montana
KJEF|Jefferson City Memorial Airport|Jefferson City, Missouri
KJFK|John F. Kennedy International Airport|New York, New York
KJFX|Walker County Airport (Bevill Field)|Jasper, Alabama
KJER|Jerome County Airport|Jerome, Idaho
KJGG|Williamsbrug-Jamestown Airport|Williamsburg, Virginia
KJHW|Chautauqua County-Jamestown Airport|Jamestown, New York
KJKA|Jack Edwards Airport|Gulf Shores, Alabama
KJMS|Jamestown Regional Airport|Jamestown, North Dakota
KJNX|Johnston County Airport|Smithfield, North Carolina
KJQF|Concord Regional Airport|Concord, North Carolina
KJST|Johnstown-Cambria County Airport|Johnstown, Pennsylvania
KJYO|Leesburg Executive Airport|Leesburg, Virginia
KJYR|York Municipal Airport|York, Nebraska
KJZI|Charleston Executive Airport|Charleston, South Carolina
KJZP|Pickens County Airport|Jasper, Georgia
KKIC|Mesa Del Rey Airport|King City, California
KKLS|Kelso-Longview Regional Airport|Kelso, Washington
KKNB|Kanab Municipal Airport|Kanab, Utah
KTOI|Troy Municipal Airport|Troy, Alabama
KLAA|Lamar Municipal Airport|Lamar, Colorado
KLAF|Purdue University Airport|West Lafayette, Indiana
KLAM|Los Alamos Airport|Los Alamos, New Mexico
KLAR|Laramie Regional Airport|Laramie, Wyoming
KLAS|McCarran International Airport|Las Vegas, Nevada
KLAX|Los Angeles International Airport|Los Angeles, California
KLBB|Lubbock Preston Smith International Airport|Lubbock, Texas
KLBE|Arnold Palmer Regional Airport (Westmore County Airport) - Latrobe, Pennsylvania|
KLBF|North Platte Regional Airport (Lee Bird Field)|North Platte, Nebraska
KLBL|Liberal Municipal Airport|Liberal, Kansas
KLBR|Clarksville/Red River County Airport|Clarksville, Texas
KLBT|Lumberton Municipal Airport|Lumberton, North Carolina
KLCG|Wayne Municipal Airport|Wayne, Nebraska
KLCK|Rickenbacker International Airport|Columbus, Ohio
KLCH|Lake Charles Regional Airport|Lake Charles, Louisiana
KLCI|Laconia Municipal Airport|Laconia, New Hampshire
KLDJ|Linden Airport|Linden, New Jersey
KLEB|Lebanon Municipal Airport|West Lebanon, New Hampshire
KLEM|Lemmon Municipal Airport|Lemmon, South Dakota
KLEW|Auburn/Lewiston Municipal Airport|Auburn, Maine
KLEX|Blue Grass Airport|Lexington, Kentucky
KLFI|Langley Air Force Base|Hampton, Virginia
KLFK|Angelina County Airport|Lufkin, Texas
KLGA|LaGuardia International Airport|New York, New York
KLGB|Long Beach Airport|Long Beach, California
KLGD|La Grande/Union County Airport|La Grande, Oregon
KLGF|Laguna Army Airfield|Yuma, Arizona
KLGU|Logan-Cache Airport|Logan, Utah
KLHB|Hearne Municipal Airport|Hearne, Texas
KLHM|Lincoln Regional Airport (Karl Harder Field)|Lincoln, California
KLHQ|Fairfield County Airport|Lancaster, Ohio
KLHV|William T. Piper Memorial Airport|Lock Haven, Pennsylvania
KLHX|La Junta Municipal Airport|La Junta, Colorado
KLHZ|Franklin County Airport|Louisburg, North Carolina
KLIC|Limon Municipal Airport|Limon, Colorado
KLIT|Little Rock National Airport Adams Field|Little Rock, Arkansas
KLKP|Lake Placid Airport|Lake Placid, New York
KLKR|Lancaster County Airport (McWhirter Field)|Lancaster, South Carolina
KLKV|Lake County Airport|Lakeview, Oregon
KLKU|Louisa County Airport|Louisa, Virginia
KLLJ|Challis Airport|Challis, Idaho
KLLQ|Monticello Municipal Airport (Ellis Field)|Monticello, Arkansas
KLLU|Lamar Municipal Airport|Lamar, Missouri
KLMS|Louisville Winston County Airport|Louisville, Mississippi
KLMT|Klamath Falls International Airport|Klamath Falls, Oregon
KLNC|Lancaster Airport|Lancaster, Texas
KLND|Hunt Field|Lander, Wyoming
KLNK|Lincoln Airport|Lincoln, Nebraska
KLNP|Lonesome Pine Airport|Wise, Virginia
KLNS|Lancaster Airport|Lancaster, Pennsylvania
KLOL|Derby Airport|Lovelock, Nevada
KLOU|Bowman Field|Louisville, Kentucky
KLOZ|London-Corbin Airport|London, Kentucky
KLPC|Lompoc Airport|Lompoc, California
KLKQ|Pickens County Airport|Pickens, South Carolina
KLQR|Larned-Pawnee County Airport|Larned, Kansas
KLRD|Laredo International Airport|Laredo, Texas
KLRF|Little Rock Air Force Base|Jacksonville, Arkansas
KLRG|Lincoln Regional Airport|Lincoln, Maine
KLRU|Las Cruces International Airport|Las Cruces, New Mexico
KLSB|Lordsburg Municipal Airport|Lordsburg, New Mexico
KLSE|La Crosse Municipal Airport|La Crosse, Wisconsin
KLSK|Lusk Municipal Airport|Lusk, Wyoming
KLSN|Los Banos Municipal Airport|Los Banos, California
KLSV|Nellis Air Force Base|Las Vegas, Nevada
KLUF|Luke Air Force Base|Glendale, Arizona
KLUL|Hesler-Noble Field|Laurel, Mississippi
KLVK|Livermore Municipal Airport|Livermore, California
KLVL|Lawrenceville/Brunswick Municipal Airport|Lawrenceville, Virginia
KLVM|Mission Field|Livingston, Montana
KLVN|Airlake Airport|Lakeville, Minnesota
KLVS|Las Vegas Municipal Airport|Las Vegas, New Mexico
KLWB|Greenbrier Valley Airport|Lewisburg, West Virginia
KLWC|Lawrence Municipal Airport|Lawrence, Kansas
KLWL|Wells Municipal Airport|Wells, Nevada
KLWM|Lawrence Municipal Airport|Lawrence, Massachusetts
KLWS|Lewiston-Nez Perce County Airport|Lewiston, Idaho
KLWT|Lewistown Municipal Airport|Lewistown, Montana
KLXL|Little Falls/Morrison County Airport (Lindbergh Field) - Little Falls, Minnesota|
KLXN|Jim Kelly Field|Lexington, Nebraska
KLXV|Lake County Airport|Leadville, Colorado
KLYH|Lynchburg Regional Airport|Lynchburg, Virginia
KLYO|Lyons-Rice County Municipal Airport|Lyons, Kansas
KLZZ|Lampasas Airport|Lampasas, Texas
KMAC|Macon Downtown Airport|Macon, Georgia
KMAE|Madera Municipal Airport|Madera, California
KMAF|Midland International Airport|Midland, Texas
KMAI|Marianna Municipal Airport|Marianna, Florida
KMAL|Malone-Dufort Airport|Malone, New York
KMAO|Marion County Airport|Marion, South Carolina
KMBG|Mobridge Municipal Airport|Mobridge, South Dakota
KMBO|Campbell Airport|Madison, Mississippi
KMBS|MBS International Airport|Midland, Bay City, Saginaw, Michigan
KMCB|McComb-Pike County Airport (John E. Lewis Field)|McComb, Mississippi
KMCC|McClellan Airfield|Sacramento, California
KMCE|Merced Municipal Airport|Merced, California
KMCF|MacDill Air Force Base|Tampa, Florida
KMCI|Kansas City International Airport|Kansas City, Missouri
KMCK|McCook Municipal Airport|McCook, Nebraska
KMCN|Middle Georgia Regional Airport|Macon, Georgia
KMCO|Orlando International Airport|Orlando, Florida
KMCW|Mason City Municipal Airport|Mason City, Iowa
KMCZ|Martin County Airport|Williamston, North Carolina
KMDQ|Madison County Executive Airport|Huntsville, Alabama
KMDS|Madison Municipal Airport|Madison, South Dakota
KMDT|Harrisburg International Airport|Middletown, Pennsylvania
KMDW|Chicago Midway International Airport|Chicago, Illinois
KMDZ|Taylor County Airport|Medford, Wisconsin
KMEB|Laurinburg-Maxton Airport|Maxton, North Carolina
KMEI|Key Airport|Meridian, Mississippi
KMEJ|Meade Municipal Airport|Meade, Kansas
KMEM|Memphis International Airport|Memphis, Tennessee
KMER|Castle Airport|Atwater, California
KMEV|Minden-Tahoe Airport|Minden, Nevada
KMFE|McAllen-Miller International Airport|McAllen, Texas
KMFR|Rogue Valley International-Medford Airport|Medford, Oregon
KMFV|Accomack County Airport|Melfa, Virginia
KMGJ|Orange County Airport|Montgomery, New York
KMGM|Montgomery Regional Airport|Montgomery, Alabama
KMGW|Morgantown Municipal Airport|Morgantown, West Virginia
KMGY|Dayton Wright Brothers Airport|Dayton, Ohio
KMHE|Mitchell Municipal Airport|Mitchell, South Dakota
KMHK|Manhattan Regional Airport|Manhattan, Kansas
KMHL|Marshall Memorial Municipal Airport|Marshall, Missouri
KMHN|Hooker County Airport|Mullen, Nebraska
KMHR|Mather Airport|Sacramento, California
KMHT|Manchester-Boston Regional Airport|Manchester, New Hampshire
KMHV|Mojave Spaceport|Mojave, California
KMIA|Miami International Airport|Miami, Florida
KMIB|Minot Air Force Base|Minot, North Dakota
KMIC|Crystal Airport|Crystal, Minnesota
KMIT|Shafter Airport|Shafter, California
KMIV|Millville Municipal Airport|Millville, New Jersey
KMJX|Robert J. Miller Air Park|Toms River, New Jersey
KMKA|Miller Municipal Airport|Miller, South Dakota
KMKE|General Mitchell International Airport|Milwaukee, Wisconsin
KMKJ|Mountain Empire Airport|Marion-Wytheville, Virginia
KMKL|Mc Kellar-Sipes Regional Airport|Jackson, Tennessee
KMLD|Malad City Airport|Malad City, Idaho
KMLF|Milford Municipal Airport|Milford, Utah
KMLS|Miles City Municipal Airport|Miles City, Montana
KMLT|Millinocket Municipal Airport|Millinocket, Maine
KMLU|Monroe Regional Airport|Monroe, Louisiana
KMMH|Mammoth Yosemite Airport|Mammoth Lakes, California
KMMK|Meriden Markham Municipal Airport|Meriden, Connecticut
KMMS|Selfs Airport|Marks, Mississippi
KMMT|McEntire Joint National Guard Base|Eastover, South Carolina
KMMU|Morristown Municipal Airport|Morristown, New Jersey
KMMV|McMinnville Municipal Airport|McMinnville, Oregon
KMNI|Santee Cooper Regional Airport|Manning, South Carolina
KMNZ|Hamilton Municipal Airport|Hamilton, Texas
KMOB|Mobile Regional Airport|Mobile, Alabama
KMOD|Modesto City-County Airport|Modesto, California
KMOT|Minot International Airport|Minot, North Dakota
KMPE|Philadelphia Municipal Airport|Philadelphia, Mississippi
KMPJ|Petit Jean Park Airport|Morrilton, Arkansas
KMPO|Pocono Mountains Municipal Airport|Mount Pocono, Pennsylvania
KMPR|McPherson Airport|McPherson, Kansas
KMPV|Edward F. Knapp State Airport|Barre-Montpelier, Vermont
KMQI|Dare County Regional Airport|Manteo, North Carolina
KMQS|Chester County G O Carlson Airport|Coatesville, Pennsylvania
KMQY|Smyrna Airport|Smyrna, Tennessee
KMRH|Michael J. Smith Field|Beaufort, North Carolina
KMRN|Morganton-Lenoir Airport|Morganton, North Carolina
KMRY|Monterey Peninsula Airport|Monterey, California
KMRB|Eastern West Virginia Regional Airport (Shepherd Field)|Martinsburg, West Virginia
KMSL|Northwest Alabama Regional Airport|Muscle Shoals, Alabama
KMSO|Missoula International Airport|Missoula, Montana
KMSN|Dane County Regional Airport|Madison, Wisconsin
KMSP|Minneapolis-Saint Paul International Airport|Bloomington, Minnesota
KMSS|Massena International Airport|Massena, New York
KMSV|Sullivan County International Airport|Monticello, New York
KMSY|Louis Armstrong International Airport|New Orleans, Louisiana
KMTC|Selfridge Air National Guard Base|Mt. Clemens, Michigan
KMTJ|Montrose Regional Airport|Montrose, Colorado
KMTN|Martin State Airport|Baltimore, Maryland
KMTP|Montauk Airport|Montauk, New York
KMTV|Blue Ridge Airport|Martinsville, Virginia
KMUO|Mountain Home Air Force Base|Mountain Home, Idaho
KMUT|Muscatine Municipal Airport|Muscatine, Iowa
KMUU|Huntingdon County Airport|Mount Union, Pennsylvania
KMVC|Monroe County Airport|Monroeville, Alabama
KMVI|Monte Vista Municipal Airport|Monte Vista, Colorado
KMVL|Morrisville Stowe State Airport|Morrisville, Vermont
KMVM|Machias-Valley Airport|Machias, Maine
KMVY|Martha's Vineyard Airport|Vineyard Haven, Massachusetts
KMWH|Grant County International Airport|Moses Lake, Washington
KMWK|Mount Airy/Surry County Airport|Mount Airy, North Carolina
KMXA|Manila Municipal Airport|Manila, Arkansas
KMXF|Maxwell Air Force Base|Montgomery, Alabama
KMYF|Montgomery Field|San Diego, California
KMYL|McCall Airport|McCall, Idaho
KMXO|Monticello Regional Airport|Monticello, Iowa
KMYR|Myrtle Beach International Airport|Myrtle Beach, South Carolina
KMYV|Yuba County Airport|Marysville, California
KMYZ|Marysville Municipal Airport|Marysville, Kansas
KMZJ|Pinal Airpark|Pinal County, Arizona
KNAB|Albany Naval Air Station|Albany, Georgia
KNBC|Marine Corps Air Station Beaufort|Beaufort, South Carolina
KNCA|Marine Corps Air Station New River|Jacksonville, North Carolina
KNDY|Dahlgren Naval Surface Warfare Center|Dahlgren, Virginia
KNEL|Naval Air Engineering Station Lakehurst|Lakehurst, New Jersey
KNFE|Fentress NALF|Fentress, Virginia
KNFG|Marine Corps Air Station Camp Pendleton|
KNFL|Naval Air Station Fallon|Fallon, Nevada
KNGU|Norfolk Naval Station|Norfolk, Virginia
KNGZ|Alameda Naval Air Station|Alameda, California
KNHK|Naval Air Station Patuxent River|Patuxent River, Maryland
KNHZ|Naval Air Station Brunswick|Brunswick, Maine
KNID|Naval Air Weapons Station China Lake|Ridgecrest, California
KNIP|Naval Air Station Jacksonville|Jacksonville, Florida
KNJK|Naval Air Facility El Centro|El Centro, California
KNJM|Marine Corps Auxiliary Landing Field Bogue|Swansboro, North Carolina
KNJW|Williams NOLF|Meridian, Mississippi
KNKT|Marine Corps Air Station Cherry Point|Cherry Point, North Carolina
KNKX|Marine Corps Air Station Miramar|San Diego, California
KNLC|Naval Air Station Lemoore|Lemoore, California
KNMM|Naval Air Station Meridian|Meridian, Mississippi
KNOW|Coast Guard Air Station Port Angeles|Port Angeles, Washington
KNPA|Naval Air Station Pensacola - Pensacola, Florida|
KNQA|Millington Regional Jetport|Millington, Tennessee
KNQX|Naval Air Station Key West|Boca Chica Key, Florida
KNRA|Naval Outlying Field Coupeville|Coupeville, Washington
KNRB|Mayport Naval Station|Jacksonville, Florida
KNRN|Norton Municipal Airport|Norton, Kansas
KNRS|Naval Outlying Landing Field Imperial Beach|Imperial Beach, California
KNSI|Naval Outlying Field San Nicolas Island|San Nicolas Island, California
KNTD|Naval Air Station Point Mugu|Oxnard, California
KNTK|Marine Corps Air Station Tustin|Santa Ana, California
KNTU|Naval Air Station Oceana|Virginia Beach, Virginia
KNUC|Naval Auxiliary Landing Field San Clemente Island|San Clemente, California
KNUI|Webster NOLF|Saint Inigoes, Maryland
KNUQ|Moffett Federal Airfield|Mountain View, California
KNUW|Whidbey Island Naval Air Station|Oak Harbor, Washington
KNYG|Marine Corps Air Facility Quantico|Quantico, Virginia
KNYL|Marine Corps Air Station Yuma|Yuma, Arizona
KNYL|Yuma International Airport|Yuma, Arizona
KNXP|Marine Corps Air Ground Combat Center Twentynine Palms|Twentynine Palms, California
KNXX|Naval Air Station Joint Reserve Base Willow Grove|Willow Grove, Pennsylvania
KNZJ|Marine Corps Air Station El Toro|Santa Ana, California
KNZY|Naval Air Station North Island|San Diego, California
KOAJ|Ellis Airport|Jacksonville, North Carolina
KOAK|Oakland International Airport|Oakland, California
KOAR|Marina Airport|Marina, California
KOCW|Warren Airport|Washington, North Carolina
KODX|Sharp Airport|Ord, Nebraska
KOEL|Oakley Municipal Airport|Oakley, Kansas
KOFF|Offutt Air Force Base|Omaha, Nebraska
KOFK|Stefan Memorial Airport|Norfolk, Nebraska
KOFP|Hanover County Municipal Airport|Richmond/Ashland, Virginia
KOGA|Searle Airport|Ogallala, Nebraska
KOGB|Orangeburg Municipal Airport|Orangeburg, South Carolina
KOGD|Ogden-Hinckley Airport|Ogden, Utah
KOGS|Ogdensburg International Airport|Ogdensburg, New York
KOIC|Norwich Lt. Warren Eaton Airport|Norwich, New York
KOIN|Oberlin Municipal Airport|Oberlin, Kansas
KOJC|Johnson County Executive Airport|Olathe, Kansas
KOKB|Oceanside Municipal Airport|Oceanside, California
KOKC|Will Rogers World Airport|Oklahoma City, Oklahoma
KOKK|Kokomo Municipal Airport|Kokomo, Indiana
KOKS|Garden County Airport|Oshkosh, Nebraska
KOKV|Winchester Regional Airport|Winchester, Virginia
KOLD|Old Town Municipal Airport and Seaplane Base|Old Town, Maine
KOLE|Cattaraugus County-Olean Airport|Olean, New York
KOLF|L. M. Clayton Airport|Wolf Point, Montana
KOLM|Olympia Airport|Olympia, Washington
KOLS|Nogales International Airport|Nogales, Arizona
KOLU|Columbus Municipal Airport|Columbus, Nebraska
KOLV|Olive Branch Airport|Olive Branch, Mississippi
KOLZ|Oelwein Municipal Airport|Oelwein, Iowa
KOMA|Eppley Field|Omaha, Nebraska
KOMH|Orange County Airport|Orange, Virginia
KOMK|Omak Airport|Omak, Washington
KOMN|Ormond Beach Municipal Airport|Ormond Beach, Florida
KONA|Winona Municipal Airport (Max Conrad Field)|Winona, Minnesota
KONL|O'Neill Municipal Airport (Baker Field)|O'Neill, Nebraska
KONO|Ontario Municipal Airport|Ontario, Oregon
KONP|Newport Municipal Airport|Newport, Oregon
KONT|Ontario International Airport|Ontario, California
KONX|Currituck County Airport|Currituck, North Carolina
KOPF|Opa-locka Airport|Opa-locka, Florida
KOQN|Brandywine Airport|West Chester, Pennsylvania
KOQU|Quonset State Airport|North Kingstown, Rhode Island
KORD|O'Hare International Airport|Chicago, Illinois
KORE|Orange Municipal Airport|Orange, Massachusetts
KORF|Norfolk International Airport|Norfolk, Virginia
KORG|Orange County Airport|Orange, Texas
KORH|Worcester Regional Airport|Worcester, Massachusetts
KORS|Orcas Island Airport|Eastsound, Washington
KOSH|Whittman Regional Airport|Oshkosh, Wisconsin
KOSU|Ohio State University Airport|Columbus, Ohio
KOSX|Kosciusko Attala County Airport|Kosciusko, Mississippi
KOTH|North Bend Municipal Airport|North Bend, Oregon
KOUN|University of Oklahoma Westheimer Airport|Norman, Oklahoma
KOVE|Oroville Municipal Airport|Oroville, California
KOWB|Owensboro-Daviess County Regional Airport|Owensboro, Kentucky
KOWD|Norwood Memorial Airport|Norwood, Massachusetts
KOWI|Ottawa Municipal Airport|Ottawa, Kansas
KOWK|Central Maine Airport of Norridgewock|Norridgewock, Maine
KOXB|Ocean City Municipal Airport|Ocean City, Maryland
KOXC|Waterbury-Oxford Airport|Oxford, Connecticut
KOXD|Miami University Airport|Oxford, Ohio
KOXR|Oxnard Airport|Oxnard, California
KOYM|St. Marys Municipal Airport|Saint Marys, Pennsylvania
KOZR|Cairns Army Airfield|Fort Rucker, Alabama
KPAE|Snohomish County Airport (Paine Field)|Everett, Washington
KPAN|Payson Municipal Airport|Payson, Arizona
KPAO|Palo Alto Airport of Santa Clara County|Palo Alto, California
KPBF|Grider Field|Pine Bluff, Arkansas
KPBG|Plattsburgh International Airport|Plattsburg, New York
KPBX|Pike County Airport (Hatcher Field) - Pikeville, Kentucky|
KPCM|Plant City Airport|Plant City, Florida
KPCU|Picayune-Pearl River County Airport|Picayune, Mississippi
KPDK|DeKalb-Peachtree Airport|Atlanta, Georgia
KPDT|Eastern Oregon Regional Airport|Pendleton, Oregon
KPDX|Portland International Airport|Portland, Oregon
KPEO|Penn Yan Airport|Penn Yan, New York
KPFC|Pacific City State Airport|Pacific City, Oregon
KPFN|Panama City-Bay County International Airport|Panama City, FL
KPGA|Page Municipal Airport|Page, Arizona
KPGR|Kirk Airport|Paragould, Arkansas
KPGV|Pitt-Greenville Airport|Greenville, North Carolina
KPHF|Newport News/Williamsburg International Airport|Newport News, Virginia
KPHG|Phillipsburg Municipal Airport|Phillipsburg, Kansas
KPHH|Swinnie Airport|Andrews, South Carolina
KPHL|Philadelphia International Airport|Philadelphia, Pennsylvania
KPHP|Philip Airport|Philip, South Dakota
KPHT|Henry County Airport|Paris, Tennessee
KPHX|Phoenix Sky Harbor International Airport|Phoenix, Arizona
KPIA|Greater Peoria Regional Airport|Peoria, Illinois
KPIB|Hattiesburg-Laurel Regional Airport|Hattiesburg, Mississippi
KPIE|St. Petersburg-Clearwater International Airport|St. Petersburg, Florida
KPIH|Pocatello Regional Airport|Pocatello, Idaho
KPIR|Pierre Regional Airport|Pierre, South Dakota
KPIT|Pittsburgh International Airport|Pittsburgh, Pennsylvania
KPKB|Mid-Ohio Valley Regional Airport|Parkersburg, West Virginia
KPLB|Clinton County Airport|Plattsburgh, New York
KPLK|M. Graham Clark Field, Taney County Airport|Branson, Missouri, Hollister, Missouri, Point Lookout, Missouri
KPLR|St. Clair County Airport|Pell City, Alabama
KPMB|Pembina Municipal Airport|Pembina, North Dakota
KPMD|Palmdale Regional Airport|Palmdale, California
KPMV|Plattsmouth Municipal Airport|Plattsmouth, Nebraska
KPMZ|Plymouth Municipal Airport|Plymouth, North Carolina
KPNA|Wenz Airport|Pinedale, Wyoming
KPNE|Northeast Philadelphia Airport|Philadelphia, Pennsylvania
KPNN|Princeton Municipal Airport|Princeton, Maine
KPNS|Pensacola Regional Airport|Pensacola, Florida
KPOB|Pope Airforce Base|Fayetteville, North Carolina
KPOC|Brackett Airport|La Verne, California
KPOU|Dutchess County Airport|Poughkeepsie, New York
KPOY|Powell Municipal Airport|Powell, Wyoming
KPPF|Tri-City Airport|Parsons, Kansas
KPQI|Northern Maine Regional At Presque Airport|Presque Isle, Maine
KPQL|Trent Lott International Airport|Pascagoula, Mississippi
KPRB|Paso Robles Municipal Airport|Paso Robles, California
KPRC|Ernest A. Love Field|Prescott, Arizona
KPRN|Mac Crenshaw Memorial Airport|Greenville, Alabama
KPRX|Cox Field|Paris, Texas
KPSB|Mid-State Airport|Philipsburg, Pennsylvania
KPSC|Tri-Cities Airport|Pasco, Washington
KPSF|Pittsfield Municipal Airport|Pittsfield, Massachusetts
KPSK|New River Valley Airport|Dublin, Virginia
KPSM|Portsmouth International Airport at Pease|Portsmouth, New Hampshire
KPSP|Palm Springs International Airport|Palm Springs, California
KPTB|Dinwiddie County Airport|Petersburg, Virginia
KPTD|Potsdam Municipal Airport|Potsdam, New York
KPTS|Atkinson Municipal Airport|Pittsburg, Kansas
KPTT|Pratt Industrial Airport|Pratt, Kansas
KPTV|Porterville Municipal Airport|Porterville, California
KPTW|Pottstown Limerick Airport|Pottstown, Pennsylvania
KPUB|Pueblo Memorial Airport|Pueblo, Colorado
KPUC|Carbon County Airport|Price, Utah
KPUW|Pullman-Moscow Regional Airport|Pullman, Washington
KPVC|Provincetown Municipal Airport|Provincetown, Massachusetts
KPVD|T.F. Green State Airport|Providence, Rhode Island
KPVF|Placerville Airport|Placerville, California
KPVG|Hampton Roads Executive Airport|Norfolk, Virginia
KPVU|Provo Municipal Airport|Provo, Utah
KPWD|Sher-Wood Airport|Plentywood, Montana
KPWM|Portland International Jetport|Portland, Maine
KPWT|Bremerton National Airport|Bremerton, Washington
KPYG|Pageland Airport|Pageland, South Carolina
KPYM|Plymouth Municipal Airport|Plymouth, Massachusetts
KQGX|Al Dhafra AB, United Arab Emirates|
KQIR|Al Udeid AB, Qatar|
KRAC|Batten International Airport|Racine, Wisconsin
KRAL|Riverside Municipal Airport|Riverside, California
KRAP|Rapid City Regional Airport|Rapid City, South Dakota
KRAW|Warsaw Municipal Airport|Warsaw, Missouri
KRBD|Dallas Executive Airport|Dallas, Texas
KRBE|Rock County Airport (Nebraska)|Bassett, Nebraska
KRBG|Roseburg Regional Airport|Roseburg, Oregon
KRBL|Red Bluff Municipal Airport|Red Bluff, California
KRBM|Robinson Army Airfield|Camp Robinson, Arkansas
KRBW|Lowcountry Regional Airport|Walterboro, South Carolina
KRCA|Ellsworth Air Force Base|Rapid City, South Dakota
KRDD|Redding Municipal Airport|Redding, California
KRDG|Reading Regional Airport|Reading, Pennsylvania
KRDM|Roberts Field (Redmond Municipal Airport)|Redmond, Oregon
KRDR|Grand Forks Air Force Base|Grand Forks, North Dakota
KRDU|Raleigh-Durham International Airport|Raleigh, North Carolina
KRED|Red Lodge Airport|Red Lodge, Montana
KREO|Rome State Airport|Rome, Oregon
KRHP|Andrews-Murphy Airport|Andrews, North Carolina
KRHV|Reid-Hillview Airport|San Jose, California
KRIC|Richmond International Airport|Sandston, Virginia
KRIF|Richfield Municipal Airport|Richfield, Utah
KRIL|Garfield County Regional Airport|Rifle, Colorado
KRIR|Flabob Airport|Riverside, California
KRIU|Rancho Murieta Airport|Rancho Murieta, California
KRIV|March Air Reserve Base|Riverside, California
KRIW|Riverton Regional Airport|Riverton, Wyoming
KRJD|Ridgely Airpark|Ridgely, Maryland
KRKD|Knox County Regional Airport|Rockland, Maine
KRKS|Rock Springs - Sweetwater County Airport|Rock Springs, Wyoming
KRLD|Richland Airport|Richland, Washington
KRME|Griffiss Airport|Rome, New York
KRMN|Stafford Regional Airport|Stafford, Virginia
KRNM|Ramona Airport|Ramona, California
KRNO|Reno-Tahoe International Airport|Reno, Nevada
KRNT|Renton Municipal Airport|Renton, Washington
KRNV|Cleveland Municipal Airport|Cleveland, Mississippi
KROA|Roanoke Regional Airport/Woodrum Field|Roanoke, Virginia
KROC|Greater Rochester International Airport|Rochester, New York
KROG|Rogers Municipal Airport Carter Field|Rogers, Arkansas
KROW|Roswell International Air Center Airport|Roswell, New Mexico
KRPB|Belleville Municipal Airport|Belleville, Kansas
KRPX|Roundup Airport|Roundup, Montana
KRQE|Window Rock Municipal Airport|Window Rock, Arizona
KRRT|Warroad International Airport (Swede Carlson Field)|Warroad, Minnesota
KRSL|Russell Municipal Airport|Russell, Kansas
KRST|Rochester International Airport|Rochester, Minnesota
KRTN|Raton Municipal Airport-Crews Field|Raton, New Mexico
KRUE|Russellville Regional Airport|Russellville, Arkansas
KRUG|Rugby Municipal Airport|Rugby, North Dakota
KRUQ|Rowan County Airport|Salisbury, North Carolina
KRUT|Rutland State Airport|Rutland, Vermont
KRVL|Mifflin County Airport|Reedsville, Pennsylvania
KRVS|Richard Lloyd Jones Jr. Airport|Tulsa County, Oklahoma
KRWI|Rocky Mount Regional Airport|Rocky Mount, North Carolina
KRWL|Rawlins Municipal Airport|Rawlins, Wyoming
KRXE|Rexburg-Madison County Airport|Rexburg, Idaho
KRYN|Ryan Field|Tucson, Arizona
KRYV|Watertown Municipal Airport|Watertown, Wisconsin
KRYW|Rusty Allen Airport|Lago Vista, Texas
KRYY|Cobb County McCollum Field|Kennesaw, Georgia
KRZT|Ross County Regional Airport|Chillicothe, Ohio
KRZZ|Halifax County Airport|Roanoke Rapids, North Carolina
KSAA|Shively Airport|Saratoga, Wyoming
KSAC|Sacramento Executive Airport|Sacramento, California
KSAD|Safford Regional Airport|Safford, Arizona
KSAF|Santa Fe Municipal Airport|Santa Fe, New Mexico
KSAN|San Diego International Airport (Lindbergh Field)|San Diego, California
KSAS|Salton Sea Airport|Salton City, California
KSAT|San Antonio International Airport|San Antonio, Texas
KSBA|Santa Barbara Municipal Airport|Santa Barbara, California
KSBD|San Bernardino International Airport|San Bernardino, California
KSBM|Sheboygan County Memorial Airport|Sheboygan, Wisconsin
KSBP|San Luis Obispo County Regional Airport|San Luis Obispo, California
KSBS|Steamboat Springs Airport (Bob Adams Field)|Steamboat Springs, Colorado
KSBX|Shelby Airport|Shelby, Montana
KSBY|Wicomico Regional Airport|Salisbury, Maryland
KSCB|Scribner State Airport|Scribner, Nebraska
KSCD|Sylacauga Municipal Airport|Sylacauga, Alabama
KSCH|Schenectady County Airport|Schenectady, New York
KSCK|Stockton Metro Airport|Stockton, California
KSDF|Louisville International Airport|Louisville, Kentucky
KSDL|Scottsdale Municipal Airport|Scottsdale, Arizona
KSDM|Brown Municipal Airport|San Diego, California
KSDY|Sidney-Richland Municipal Airport|Sidney, Montana
KSEA|Seattle-Tacoma International Airport|Seattle, Washington
KSEE|Gillespie Airport|San Diego, California
KSEG|Penn Valley Airport|Selinsgrove, Pennsylvania
KSEM|Craig Field|Selma, Alabama
KSEZ|Sedona Airport|Sedona, Arizona
KSFB|Orlando Sanford International Airport|Sanford, Florida
KSFD|Wiley Airport|Winner, South Dakota
KSFF|Felts Field|Spokane, Washington
KSFM|Sanford Regional Airport|Sanford, Maine
KSFO|San Francisco International Airport|San Mateo County, California
KSFQ|Suffolk Executive Airport|Suffolk, Virginia
KSFZ|North Central State Airport|Pawtucket, Rhode Island
KSGF|Springfield-Branson National Airport|Springfield, Missouri
KSGT|Stuttgart Municipal Airport|Stuttgart, Arkansas
KSGU|St. George Municipal Airport|St. George, Utah
KSHD|Shenandoah Valley Regional Airport|Staunton, Virginia
KSHN|Sanderson Airport|Shelton, Washington
KSHR|Sheridan County Airport|Sheridan, Wyoming
KSIY|Siskiyou County Airport|Montague, California
KSJC|Norman Y. Mineta San José International Airport|San Jose, California
KSJN|St. Johns Industrial Air Park|St. Johns, Arizona
KSJT|Mathis Field|San Angelo, Texas
KSKA|Fairchild Air Force Base|Spokane, Washington
KSKX|Taos Regional Airport|Taos, New Mexico
KSLC|Salt Lake City International Airport|Salt Lake City, Utah
KSLE|McNary Field|Salem, Oregon
KSLG|Smith Field|Siloam Springs, Arkansas
KSLI|Los Alamitos Army Airfield|Los Alamitos, California
KSLK|Adirondack Regional Airport|Saranac Lake, New York
KSLN|Salina Municipal Airport|Salina, Kansas
KSLR|Sulphur Springs Municipal Airport|Sulphur Springs, Texas
KSMD|Smith Field|Fort Wayne, Indiana
KSMF|Sacramento International Airport|Sacramento, California
KSMN|Lemhi County Airport|Salmon, Idaho
KSMO|Santa Monica Airport|Santa Monica, California
KSMQ|Somerset Airport|Somerville, New Jersey
KSMS|Sumter Airport|Sumter, South Carolina
KSMX|Santa Maria Public Airport (Capt. G. Allan Hancock Field)|Santa Maria, California
KSNA|John Wayne-Orange County Airport|Santa Ana, California
KSNC|Chester Airport|Chester, Connecticut
KSNL|Shawnee Regional Airport|Shawnee, Oklahoma
KSNS|Salinas Airport|Salinas, California
KSNY|Sidney Municipal Airport|Sidney, Nebraska
KSOP|Moore County Airport|Southern Pines, North Carolina
KSOW|Show Low Regional Airport|Show Low, Arizona
KSPA|Spartanburg Downtown Memorial Airport - Spartanburg, South Carolina|
KSPB|Scappoose Industrial Airpark|Scappoose, Oregon
KSPF|Black Hills Airport (Clyde Ice Field)|Spearfish, South Dakota
KSPS|Wichita Falls Municipal Airport / Sheppard AFB|Wichita Falls, Texas
KSPW|Spencer Municipal Airport|Spencer, Iowa
KSPX|Houston Gulf Airport (closed 2002)|League City, Texas
KSQL|San Carlos Airport|San Carlos, California
KSRC|Searcy Municipal Airport|Searcy, Arkansas
KSRR|Sierra Blanca Regional Airport|Ruidoso, New Mexico
KSSC|Shaw AFB|Sumter, South Carolina
KSSF|Stinson Municipal Airport|San Antonio, Texas
KSSN|Seneca Army Airfield|Romulus, New York
KSSQ|Shell Lake Municipal Airport|Shell Lake, Wisconsin
KSTC|St. Cloud Regional Airport|St. Cloud, Minnesota
KSTF|George M. Bryan Airport|Starkville, Mississippi
KSTK|Sterling Municipal Airport|Sterling, Colorado
KSTL|Lambert Saint Louis International Airport|St. Louis, Missouri
KSTP|St. Paul Downtown Airport|St. Paul, Minnesota
KSTS|Sonoma County Airport|Santa Rosa, California
KSUN|Friedman Memorial Airport|Hailey, Idaho
KSUT|Brunswick County Airport|Oak Island, North Carolina
KSUU|Travis Air Force Base|Fairfield, California
KSUX|Sioux Gateway Airport|Sioux City, Iowa
KSVC|Grant County Airport|Silver City, New Mexico
KSVE|Susanville Airport|Susanville, California
KSVH|Statesville Regional Airport|Statesville, North Carolina
KSWF|Stewart International Airport|Newburgh, New York
KSWI|Sherman Municipal Airport|Sherman, Texas
KSWT|Seward Municipal Airport|Seward, Nebraska
KSXL|Summersville Airport|Summersville, West Virginia
KSYF|Cheyenne County Municipal Airport|St. Francis, Kansas
KSYR|Syracuse Hancock International Airport|Syracuse, New York
KSZP|Santa Paula Airport|Santa Paula, California
KSZT|Sandpoint Airport|Sandpoint, Idaho
KTAD|Perry Stokes Airport|Trinidad, Colorado
KTAN|Taunton Municipal Airport|Taunton, Massachusetts
KTCC|Tucumcari Municipal Airport|Tucumcari, New Mexico
KTCL|Tuscaloosa Regional Airport|Tuscaloosa, Alabama
KTCM|McChord Air Force Base|Tacoma, Washington
KTCS|Truth or Consequences Municipal Airport|Truth or Consequences, New Mexico
KTCY|Tracy Municipal Airport|Tracy, California
KTDF|Person County Airport|Roxboro, North Carolina
KTDO|Toledo-Winston Carlock Memorial Airport|Toledo, Washington
KTEB|Teterboro Airport|Teterboro, New Jersey
KTEX|Telluride Regional Airport|Telluride, Colorado
KTGI|Tangier Island Airport|Tangier, Virginia
KTHM|Thompson Falls Airport|Thompson Falls, Montana
KTHP|Hot Springs County Municipal Airport|Thermopolis, Wyoming
KTHV|York Airport|York, Pennsylvania
KTIK|Tinker Air Force Base|Oklahoma City, Oklahoma
KTIW|Tacoma Narrows Airport|Tacoma, Washington
KTKI|Collin County Regional Airport at McKinney|McKinney, Texas
KTLR|Mefford Airport|Tulare, California
KTNP|Twentynine Palms Airport|Twentynine Palms, California
KTNX|Tonopah Test Range Airport|Tonopah, Nevada
KTOA|Zamperini Airport|Torrance, California
KTOL|Toledo Express Airport|Toledo, Ohio
KTOP|Billard Municipal Airport|Topeka, Kansas
KTOR|Torrington Municipal Airport|Torrington, Wyoming
KTPA|Tampa International Airport|Tampa, Florida
KTPH|Tonopah Airport|Tonopah, Nevada
KTPL|Draughon-Miller Central Texas Regional Airport|Temple, Texas
KTQE|Tekamah Airport|Tekamah, Nebraska
KTQK|Scott City Municipal Airport|Scott City, Nebraska
KTRI|Tri-Cities Regional Airport|Blountville, Tennessee
KTRK|Truckee-Tahoe Airport|Truckee, California
KTRM|Desert Resorts Regional Airport|Palm Springs, California
KTSP|Tehachapi Municipal Airport|Tehachapi, California
KTTA|Sanford-Lee County Regional Airport|Sanford, North Carolina
KTTD|Troutdale Airport|Portland, Oregon
KTTN|Trenton-Mercer Airport|Trenton, New Jersey
KTUL|Tulsa International Airport|Tulsa, Oklahoma
KTUP|Tupelo Regional Airport|Tupelo, Mississippi
KTUS|Tucson International Airport|Tucson, Arizona
KTVL|Lake Tahoe Airport|South Lake Tahoe, California
KTVY|Bolinder Field-Tooele Valley Airport|Tooele, Utah
KTWF|Joslin Field - Magic Valley Regional Airport|Twin Falls, Idaho
KTXK|Texarkana Regional Airport-Webb Field|Texarkana, Arkansas
KTYL|Taylor Airport|Taylor, Arizona
KTYR|Tyler Pounds Regional Airport|Tyler, Texas
KTYS|McGhee Tyson Airport|Knoxville, Tennessee
KTZR|Bolton Field|Columbus, Ohio
KTZT|Belle Plaine Municipal Airport|Belle Plaine, Iowa
KUAO|Aurora State Airport|Aurora, Oregon
KUBS|Columbus-Lowndes County Airport|Columbus, Mississippi
KUCA|Oneida County Airport|Utica, New York
KUCP|New Castle Municipal Airport|New Castle, Pennsylvania
KUDD|Bermuda Dunes Airport|Palm Springs, California
KUDG|Darlington County Jetport|Dalington, South Carolina
KUGN|Waukegan Regional Airport|Waukegan, Illinois
KUIL|Quillayute Airport|Quillayute, Washington
KUKF|Wilkes County Airport|North Wilkesboro, North Carolina
KUKI|Ukiah Municipal Airport|Ukiah, California
KUKL|Coffey County Airport|Burlington, Kansas
KUKT|Quakertown Airport|Quakertown, Pennsylvania
KULS|Ulysses Airport|Ulysses, Kansas
KUNI|Gordon K. Bush Airport|Athens/Albany, Ohio
KUNV|University Park Airport|University Park, Pennsylvania
KUOS|Franklin County Airport|Sewanee, Tennessee
KUOX|University-Oxford Airport|Oxford, Mississippi
KUTS|Huntsville Municipal Airport|Huntsville, Texas
KUUU|Newport State Airport|Newport, Rhode Island
KUZA|Rock Hill/York County Airport (Bryant Field)|Rock Hill, South Carolina
KVAY|South Jersey Regional Airport|Mount Holly, New Jersey
KVBG|Vandenberg Air Force Base|Lompoc, California
KVBT|Bentonville Municipal Airport|Bentonville, Arkansas
KVBW|Bridgewater Airport|Bridgewater, Virginia
KVCB|Nut Tree Airport|Vacaville, California
KVCT|Victoria Regional Airport|Victoria, Texas
KVCV|Southern California Logistics Airport|Victorville, California
KVEL|Vernal-Uintah County Airport|Vernal, Utah
KVER|Jesse Viertel Memorial Airport|Boonville, Missouri
KVGT|North Las Vegas Airport|Las Vegas, Nevada
KVIS|Visalia Municipal Airport|Visalia, California
KVJI|Virginia Highlands Airport|Abingdon, Virginia
KVKS|Vicksburg Municipal Airport|Vicksburg, Mississippi
KVKX|Potomac Airfield|Friendly, Maryland
KVMR|Davidson Airport|Vermillion, South Dakota
KVNY|Van Nuys Airport|Van Nuys, California
KVPZ|Porter County Airport|Valparaiso, Indiana
KVSF|Hartness State Airport|Springfield, Vermont
KVTA|Newark-Heath Airport|Newark, Ohio
KVTN|Miller Field|Valentine, Nebraska
KVUJ|Stanly County Airport|Albemarle, North Carolina
KVUO|Pearson Field|Vancouver, Washington
KVVS|Joseph A. Hardy Connellsville Airport|Connellsville, Pennsylvania
KWAL|Wallops Flight Facility|Wallops Island, Virginia
KWAY|Greene County Airport|Waynesburg, Pennsylvania
KWBW|Wilkes-Barre Wyoming Valley Airport|Wilkes-Barre, Pennsylvania
KWHP|Whiteman Airport|Los Angeles, California
KWJF|General William J. Fox Airfield|Lancaster, California
KWLD|Strother Field|Winfield, Kansas
KWLW|Willows-Glenn County Airport|Willows, California
KWMC|Winnemucca Municipal Airport|Winnemucca, Nevada
KWRI|McGuire Air Force Base|Wrightstown, New Jersey
KWRL|Worland Municipal Airport|Worland, Wyoming
KWST|Westerly State Airport|Westerly, Rhode Island
KWVI|Watsonville Municipal Airport|Watsonville, California
KWVL|Waterville Robert LaFleur Airport|Waterville, Maine
KWWD|Cape May Airport|Wildwood, New Jersey
KWYS|Yellowstone Airport|West Yellowstone, Montana
KXBP|Bridgeport Municipal Airport|Bridgeport, Texas
KXFL|Flagler County Airport|Bunnell, Florida
KXMR|Cape Canaveral Air Force Station Skid Strip|Cocoa Beach, Florida
KXNA|Northwest Arkansas Regional Airport|Fayetteville / Springdale, Arkansas
KXNO|North Air Force Auxiliary Field|North, South Carolina
KXVG|Longville Municipal Airport|Longville, Minnesota
KYIP|Willow Run Airport|Detroit, Michigan
KYKM|Yakima Air Terminal (McAllister Field)|Yakima, Washington
KYKN|Chan Gurney Municipal Airport|Yankton, South Dakota
KYNG|Youngstown-Warren Regional Airport|Youngstown / Warren, Ohio
KZEF|Elkin Municipal Airport|Elkin, North Carolina
KZER|Schuylkill County Airport (Joe Zerbey Field)|Pottsville, Pennsylvania
KZPH|Zephyrhills Municipal Airport|Zephyrhills, Florida
KZUN|Black Rock Airport|Zuni Pueblo, New Mexico
KZZV|Zanesville Municipal Airport|Zanesville, Ohio
LAFK|Tirana Mil Hel Airport|Tirana
LAGJ|Gjader Air Base|Gjader
LAKO|Korçë Northwest Airport|Korçë
LAKU|Kukes Airport|Kukës
LAKV|Kuçovë Airport|Kuçovë
LASK|Shkodër Airport|Shkodër (Shkodra)
LASR|Sarandë Airport|Sarandë (Saranda)
LATI|Rinas Mother Teresa Airport|Tirana
LAVL|Vlorë Airport|Vlorë (Vlora)
LBBG|Burgas International Airport (Sarafovo Airport)|Burgas
LBBR|Ravnetz Air Base (military)|Ravnetz
LBED|Erden (private)|
LBGO|Gorna Oryahovitsa Airport|Gorna Oryahovitsa
LBHS|Uzundzhovo Air Base (military)|Haskovo
LBIA|Bezmer Air Base (military)|Bezmer, Yambol Province
LBKJ|Kyrdjali|
LBKK|Kazanlyk|
LBLS|Lesnovo (private)|
LBMG|Gabrovnitsa Air Base (military)|Gabrovnitsa (Gabrovnica)
LBMM|Montana|
LBPD|Plovdiv International Airport|Plovdiv
LBPG|Graf Ignatievo Air Base (military)|Graf Ignatievo / Plovdiv
LBPK|Pernik|
LBPL|Dolna Mitropolia Air Base (military)|Dolna Mitropoliia / Pleven
LBPR|Primorsko (private)|
LBPS|Sadovo / Cheshnigirovo|
LBRS|Ruse Airport|Rousse
LBSD|Dobroslavtsi Air Base (military)|Dobroslavtsi (Dobroslavci)
LBSF|Sofia International Airport (Vrazhdebna)|Sofia
LBSL|Sliven Airfield (military)|Sliven
LBSS|Silistra Airfield (military)|Silistra
LBSZ|Stara Zagora International Airport|Stara Zagora
LBTG|Bukhovtsi Airfield (military)|Targovishte
LBTV|Voden|
LBVD|Vidin Airfield (military)|Vidin
LBWB|Balchik Air Base (military)|Balchik
LBWC|Chaika / Varna|
LBWK|Kalimanci / Varna|
LBWN|Varna International Airport|Varna
LCEN|Ercan International Airport|Nicosia
LCLK|Larnaca International Airport|Larnaca
LCNC|Nicosia International Airport (abandoned)|Nicosia
LCPH|Paphos International Airport|Paphos
LCRA|RAF Akrotiri|Akrotiri
LDDA|Daruvar Airport|Daruvar
LDDD|Zagreb AFTN Airport|Zagreb
LDDP|Ploče Airport|Ploče
LDDU|Dubrovnik Airport|Dubrovnik
LDLO|Lošinj Airport|Lošinj
LDOB|Borovo Airport|Borovo
LDOC|Čepin Airport|Čepin
LDOR|Slavonski Brod Airport|Slavonski Brod
LDOS|Osijek Airport|Osijek
LDPL|Pula Airport|Pula
LDPM|Medulin Airport|Medulin
LDPN|Unije Airport|Unije
LDPV|Vrsar Airport|Vrsar
LDRG|Grobničko Polje Airport|Grobnik
LDRI|Rijeka Airport|Rijeka
LDRO|Otočac Airport|Otočac
LDSB|Bol Airport|Brač
LDSH|Hvar Airport|Hvar
LDSP|Split Airport|Split
LDSS|Sinj Airport|Sinj
LDVA|Varazdin Airport|Varazdin
LDVC|Čakovec Airport|Čakovec
LDVK|Koprivnica Airport|Koprivnica
LDZA|Zagreb Pleso Airport|Zagreb
LDZD|Zadar Airport|Zadar
LDZG|Zagreb City Airport|Zagreb
LDZL|Zagreb Lučko Airport|Zagreb
LDZO|Zagreb ACC Airport|Zagreb
LDZU|Udbina Airport|Udbina
LEAL|Alicante Airport (formerly El Altet Airport)|Alicante / Benidorm / Costa Blanca
LEAM|Almería International Airport|Almería
LEAS|Asturias Airport|Aviles / Gijon / Oviedo (Asturias)
LEBA|Córdoba Airport|Córdoba Andalucia
LEBB|Bilbao Airport|Bilbao, Viscaya
LEBG|Burgos Airport|Burgos, Spain
LEBL|Barcelona International Airport|Barcelona / El Prat de Llobregat
LEBZ|Badajoz Airport|Badajoz
LECO|La Coruña Airport|La Coruña / A Coruña, Galicia
LECU|Cuatro Vientos Airport|Madrid
LEGE|Girona-Costa Brava Airport|Girona / Girona (Costa Brava
LEGR|Granada Airport|Granada
LEHC|Huesca Airport|Huesca / Pirineus
LEIB|Ibiza Airport|Ibiza Island / Eivisa
LEJR|Jerez Airport|Jerez de la Frontera / Cádiz
LELC|Murcia-San Javier Airport|Murcia /Cartagena, Region de Murcia
LELL|Sabadell Airport|Sabadell / Catalunya
LELN|León Airport|León / Castilla y Leon
LELO|Logroño-Agoncillo Airport|[Logroño, La Rioja, Spain]
LEMD|Barajas International Airport|Madrid
LERL|Ciudad Real Central Airport - Ciudad Real|
LETO|Madrid-Torrejón Airport|Madrid
LEMG|Málaga Airport|Málaga / Agripina / Torremolinos,Marbella,Fuengirola(Pablo Picasso)
LEMH|Menorca Airport|Menorca,Mahon / Balearic Islands
LEPA|Palma de Mallorca Airport (or Son Sant Joan Airport)|Palma de Mallorca
LEPP|Pamplona Airport|Pamplona / Irunea
LERI|Alcantarilla Base Aérea|Alcantarilla / Murcia /Militar
LERS|Reus Airport|Reus / Tarragona /Costa Daurada
LESA|Matacán Airport|Salamanca, Spain
LESB|Son Bonet Aerodrome|Palma de Mallorca
LESL|San Luis Aerodrome|Menorca, Balearic Islands
LESO|San Sebastián Airport|San Sebastián - Donostia, Guypuscoa
LEST|Santiago de Compostela Airport|Santiago de Compostela, Galicia
LEVC|Valencia Airport|Valencia / Manises / Costa del Azahar
LEVD|Valladolid Airport|Valladolid /Spain
LEVT|Vitoria Airport|Vitoria-Gasteiz,Alava
LEVX|Vigo-Peinador Airport|Vigo, Galicia
LEXJ|Santander Airport|Santander / Cantabria
LEZG|Zaragoza Airport|Zaragoza / Aragon
LEZL|San Pablo Airport|Sevilla
LFAB|Dieppe - Saint-Aubin Airport|Dieppe
LFAC|Calais - Dunkerque Airport|Calais, Dunkerque
LFAD|Compiègne - Margny Airport|Compiègne
LFAE|Eu Mers - Le Tréport Airport|Eu, Le Tréport
LFAF|Laon - Chambry Airport|Laon
LFAG|Péronne - Saint-Quentin Airport|Péronne
LFAI|Nangis - Les Loges Airport|Nangis
LFAJ|Argentan Airport|Argentan
LFAK|Dunkerque - Les Moëres Airport|Dunkerque
LFAL|Thoree Les Pins Airport|La Flèche
LFAM|Berck-sur-Mer Airport|Berck-sur-Mer
LFAO|Bagnoles-de-l'Orne Airport|Bagnoles-de-l'Orne
LFAP|Rethel - Perthes Airport|Rethel
LFAQ|Albert-Picardie Airport|Albert
LFAR|Montdidier Airport|Montdidier
LFAS|Falaise - Monts d'Eraines Airport|Falaise
LFAT|Le Touquet-Paris-Plage Airport|Le Touquet-Paris-Plage
LFAU|Vauville Airport|Vauville
LFAV|Valenciennes - Denain Airport|Valenciennes
LFAW|Villerupt Airport|Villerupt
LFAX|Mortagne-au-Perche Airport|Mortagne-au-Perche
LFAY|Amiens-Glisy Airport|Amiens
LFAZ|Saint-Brieuc Airport|Saint-Brieuc
LFBA|Agen - La Garenne Airport|Agen
LFBD|Bordeaux - Merignac Airport|Bordeaux
LFBE|Bergerac - Roumanière Airport|Bergerac
LFBG|Cognac - Chateaubernard Airport|Cognac
LFBH|La Rochelle - Île de Ré Airport|La Rochelle
LFBI|Poitiers - Biard Airport|Poitiers
LFBJ|Saint-Junien - Airport|Saint-Junien
LFBK|Montluçon - Gueret Airport|Montluçon
LFBL|Limoges - Bellegarde Airport|Limoges
LFBM|Mont-de-Marsan Airport|Mont-de-Marsan
LFBN|Niort - Souche Airport|Niort
LFBO|Toulouse - Blagnac Airport|Toulouse
LFBP|Pau - Pyrenees Airport|Pau, Pyrenees
LFBR|Muret - Lherm Airport|Muret, Lherm
LFBS|Biscarrosse - Parentis Airport|Biscarrosse
LFBT|Tarbes - Lourdes Pyrenees Airport|Tarbes
LFBU|Angoulême - Brie Champniers Airport|Angoulême
LFBV|Brive - La Roche Airport|Brive
LFBX|Périgueux - Bassillac Airport|Périgueux
LFBY|Dax - Seyresse Airport|Dax
LFBZ|Biarritz-Bayonne - Anglet Airport|Biarritz, Bayonne, Anglet
LFCA|Châtellerault - Targe Airport|Châtellerault
LFCB|Bagnères-de-Luchon Airport|Bagnères-de-Luchon
LFCC|Cahors Lalbenque Airport|Cahors
LFCD|Andernos-les-Bains Airport|Andernos-les-Bains
LFCE|Guéret Saint-Laurent Airport|Guéret
LFCF|Figeac Livernon Airport|Figeac
LFCG|Saint-Girons Antichan Airport|Saint-Girons
LFCH|Arcachon La Teste-de-Buch Airport|Arcachon
LFCI|Albi Le Sequestre Airport|Albi
LFCJ|Jonzac Neulles Airport|Jonzac
LFCK|Castres-Mazamet Airport|Castres, Mazamet
LFCL|Toulouse-Lasbordes Airport|Toulouse
LFCM|Millau Larzac Airport|Millau
LFCN|Nogaro Airport|Nogaro
LFCO|Oloron Herere Airport|Oloron
LFCP|Pons Avy Airport|Pons
LFCQ|Graulhet Montdragon Airport|Graulhet
LFCR|Rodez Marcillac Airport|Rodez
LFCS|Bordeaux Leognan saucats Airport|Bordeaux
LFCT|Thouars Airport|Thouars
LFCU|Ussel Thalamy Airport|Ussel, Thalamy
LFCV|Villefranche-de-Rouergue Airport|Villefranche-de-Rouergue
LFCW|Villeneuve-sur-Lot Airport|Villeneuve-sur-Lot
LFCX|Castelsarrazin Moissac Airport|Castelsarrasin
LFCY|Royan Medis Airport|Royan
LFCZ|Mimizan Airport|Mimizan
LFDA|Aire-sur-l'Adour Airport|Aire-sur-l'Adour
LFDB|Montauban Airport|Montauban
LFDC|Montendre Marcillac Airport|Montendre
LFDE|Egletons Airport|Égletons
LFDF|Sainte-Foy-la-Grande Airport|Sainte-Foy-la-Grande
LFDG|Gaillac Lisle-sur-Tarn Airport|Gaillac
LFDH|Auch Lamothe Airport|Auch
LFDI|Libourne Artigues-de-Lussac Airport|Libourne
LFDJ|Pamiers Les Pujols Airport|Pamiers
LFDK|Soulac-sur-Mer Airport|Soulac-sur-Mer
LFDL|Loudun Airport|Loudun
LFDM|Marmande virazeil Airport|Marmande
LFDN|Rochefort Saint-Agnant Airport|Rochefort
LFDP|Saint-Pierre-d'Oléron Airport|Saint-Pierre-d'Oléron
LFDQ|Castelnau Magnoac Airport|Castelnau
LFDR|La Réole Floudes Airport|La Réole
LFDS|Sarlat Domme Airport|Sarlat
LFDT|Tarbes Laloubere Airport|Tarbes
LFDU|Lesparre Saint-Laurent Médoc Airport|Lesparre-Médoc
LFDV|Couhé Verac Airport|Couhé
LFDW|Chauvigny Airport|Chauvigny
LFDX|Fumel Montayral Airport|Fumel
LFDY|Bordeaux Yvrac Airport|Bordeaux
LFEA|Belle Île Airport|Belle Île
LFEB|Dinan Trelivan Airport|Dinan
LFEC|Ouessant Airport|Ouessant
LFED|Pontivy Airport|Pontivy
LFEF|Amboise Dierre Airport|Amboise
LFEG|Argenton-sur-Creuse Airport|Argenton-sur-Creuse
LFEH|Aubigny-sur-Nère Airport|Aubigny-sur-Nère
LFEI|Briare Chatillon Airport|Briare
LFEJ|Châteauroux Villers Airport|Châteauroux
LFEK|Issoudun Le Fay Airport|Issoudun
LFEL|Le Blanc Airport|Le Blanc
LFEM|Montargis Vimory Airport|Montargis
LFEN|Tours Sorigny Airport|Tours
LFEO|Saint-Servan Airport|Saint-Malo
LFEP|Pouilly Maconge Airport|Pouilly
LFEQ|Quiberon Airport|Quiberon
LFER|Redon Bains-sur-Oust Airport|Redon
LFES|Guiscriff Scaer Airport|Guiscriff
LFET|Til-Châtel Airport|Til-Châtel
LFEU|Bar-le-Duc Airport|Bar-le-Duc
LFEV|Gray Saint-Adrien Airport|Gray
LFEW|Saulieu Liernais Airport|Saulieu
LFEX|Nancy Azelot Airport|Nancy
LFEY|Île d'Yeu Airport|Île d'Yeu
LFEZ|Nancy Malzeville Airport|Nancy
LFFB|Buno Bonnevaux Airport|Buno
LFFC|Mantes Cherence Airport|Mantes
LFFD|Saint-André-de-l'Eure Airport|Saint-André-de-l'Eure
LFFE|Enghien Moisselles Airport|Enghien
LFFG|La Ferté-Gaucher Airport|La Ferté-Gaucher
LFFH|Château-Thierry Belleau Airport|Château-Thierry
LFFI|Ancenis Airport|Ancenis
LFFJ|Joinville Mussey Airport|Joinville
LFFK|Fontenay-le-Comte Airport|Fontenay-le-Comte
LFFL|Bailleau-Armenonville Airport|Bailleau-Armenonville
LFFM|Lamotte-Beuvron Airport|Lamotte-Beuvron
LFFN|Brienne-le-Château Airport|Brienne-le-Château
LFFP|Pithiviers Airport|Pithiviers
LFFQ|La Ferté-Alais Airport|La Ferté-Alais
LFFR|Bar-sur-Seine Airport|Bar-sur-Seine
LFFT|Neufchateau Rouceux Airport|Neufchâteau
LFFU|Châteauneuf-sur-Cher Airport|Châteauneuf-sur-Cher
LFFV|Vierzon Mereau Airport|Vierzon
LFFW|Montaigu saint georges Airport|Montaigu
LFFX|Tournus Cruisery Airport|Tournus
LFFY|Etrepagny Airport|Etrepagny
LFFZ|Sézanne Saint-Remy Airport|Sézanne
LFGA|Colmar Houssen Airport|Colmar
LFGB|Mulhouse Habsheim Airport|Mulhouse
LFGC|Strasbourg Neuhof Airport|Strasbourg
LFGD|Arbois Airport|Arbois
LFGE|Avallon Airport|Avallon
LFGF|Beaune Challanges Airport|Beaune
LFGG|Belfort Chaux Airport|Belfort
LFGH|Cosne-sur-Loire Airport|Cosne-Cours-sur-Loire
LFGI|Dijon Darois Airport|Dijon
LFGJ|Dôle-Tavaux Airport|Dole
LFGK|Joigny Airport|Joigny
LFGL|Lons-le-Saunier Courlaoux Airport|Lons-le-Saunier
LFGM|Montceau-les-Mines Pouilloux Airport|Montceau-les-Mines
LFGN|Paray-le-Monial Airport|Paray-le-Monial
LFGO|Pont-sur-Yonne Airport|Pont-sur-Yonne
LFGP|Saint-Florentin Cheu Airport|Saint-Florentin
LFGQ|Semur-en-Auxois Airport|Semur-en-Auxois
LFGR|Doncourt-lès-Conflans Airport|Doncourt-lès-Conflans
LFGS|Longuyon Villette Airport|Longuyon
LFGT|Sarrebourg Buhl Airport|Sarrebourg
LFGU|Sarreguemines Neunkirch Airport|Sarreguemines
LFGV|Thionville Yutz Airport|Thionville
LFGW|Verdun Le Rozelier Airport|Verdun
LFGX|Champagnole Crotenay Airport|Champagnole
LFGY|Saint-Dié Remomeix Airport|Saint-Dié
LFGZ|Nuits-Saint-Georges Airport|Nuits-Saint-Georges
LFHA|Issoire Le Broc Airport|Issoire
LFHC|Pérouges Meximieux Airport|Pérouges
LFHD|Pierrelate Airport|Pierrelatte
LFHE|Romans Saint-Paul Airport|Romans-sur-Isère
LFHF|Ruoms Airport|Ruoms
LFHG|Saint-Chamond L'Horme Airport|Saint-Chamond
LFHH|Vienne Reventin Airport|Vienne
LFHI|Morestel Airport|Morestel
LFHJ|Lyon Corbas Airport|Lyon
LFHL|Langogne Lesperon Airport|Langogne
LFHM|Megève Airport|Megève
LFHN|Bellegarde Vouvray Airport|Bellegarde ^[disambiguation needed]
LFHO|Aubenas Ardeche Meridionale Airport|Aubenas
LFHP|Le Puy Loudes Airport|Le Puy
LFHQ|Saint-Flour Coltines Airport|Saint-Flour
LFHR|Brioude Beaumont Airport|Brioude
LFHS|Bourg Ceyzeriat Airport|Bourg-en-Bresse
LFHT|Ambert Le Poyet Airport|Ambert
LFHU|LL'Alpe d'Huez Airport|L'Alpe d'Huez
LFHV|Villefranche Tarare Airport|Villefranche
LFHW|Belleville Villie Morgon Airport|Belleville, Rhône
LFHX|Lapalisse Perigny Airport|Lapalisse
LFHY|Moulins Montbeugny Airport|Moulins
LFHZ|Sallanches Mont-Blanc Airport|Sallanches
LFIB|Belvès Saint-Pardoux Airport|Belvès
LFID|Condom Valence-sur-Baise Airport|Condom
LFIF|SSaint-Affrique Belmont Airport|Saint-Affrique
LFIG|Cassagnes Beghones Airport|Cassagnes
LFIH|Chalais Airport|Chalais
LFIK|Ribérac Saint-Aulaye Airport|Ribérac
LFIL|Rion-des-Landes Airport|Rion-des-Landes
LFIM|Saint-Gaudens Montrejeau Airport|Saint-Gaudens
LFIO|Toulouse-Montaudran Airport|Toulouse-Montaudran
LFIP|Peyresourde Balestas Airport|Peyresourde
LFIR|Revel Montgey Airport|Revel
LFIT|Toulouse Bourg-Saint-Bernard Airport|Toulouse
LFIV|Vendays-Montalivet Airport|Vendays-Montalivet
LFIX|Itxassou Airport|Itxassou
LFIY|Saint-Jean-d'Angély Airport|Saint-Jean-d'Angély
LFJA|Chaumont Semoutiers Airport|Chaumont
LFJB|Mauléon Airport|Mauléon
LFJC|Clamecy Airport|Clamecy
LFJD|Corlier Aerodrome|Corlier
LFJE|La Motte-Chalancon Airport|La Motte-Chalancon
LFJF|Aubenasson Airport|Aubenasson
LFJH|Cazeres Palaminy Airport|Cazères
LFJI|Marennes Airport|Marennes
LFJL|Metz Nancy Lorraine Airport|Metz
LFJR|Angers - Loire Airport|Angers
LFJS|Soissons Courmelles Airport|Soissons
LFJT|Tours Le Louroux Airport|Tours
LFJU|Lurcy Levis Airport|Lurcy
LFKA|Albertville Airport|Albertville
LFKB|Bastia Poretta Airport|Bastia
LFKC|Calvi Sainte-Catherine Airport|Calvi
LFKD|Sollières-Sardières Airport|Sollières-Sardières
LFKE|Saint-Jean-en-Royans Airport|Saint-Jean-en-Royans
LFKF|Figari Sud Corse Airport|Figari
LFKG|Ghisonaccia Alzitone Airport|Ghisonaccia
LFKH|Saint-Jean-d'Avelanne Airport|Saint-Jean-d'Avelanne
LFKJ|Ajaccio Campo dell'Oro Airport|Ajaccio
LFKL|Lyon Brindas Airport|Lyon
LFKM|Saint Galmier Airport|Saint-Galmier
LFKO|Propriano Airport|Propriano
LFKP|La Tour-du-Pin Cessieu Airport|La Tour-du-Pin
LFKS|Solenzara Airport|Solenzara
LFKT|Corte Airport|Corte
LFKX|Meribel Bois-des-Fraisses Airport|Méribel
LFKY|Belley Peyrieu Airport|Belley
LFKZ|Saint-Claude Pratz Airport|Saint-Claude
LFLA|Auxerre Branches Airport|Auxerre
LFLB|Chambéry Aix-les-Bains Airport|Chambéry, Aix-les-Bains
LFLC|Clermont-Ferrand Auvergne Airport|Clermont-Ferrand
LFLD|Bourges Airport|Bourges
LFLE|Chambery Challes-les-Eaux Airport|Chambéry
LFLG|Grenoble - Le Versoud Aerodrome|Grenoble
LFLH|Chalon Champforgeuil Airport|Chalon
LFLI|Annemasse Airport|Annemasse
LFLJ|Courchevel Airport|Courchevel
LFLK|Oyonnax Arbent Airport|Oyonnax
LFLL|Lyon-Saint Exupéry Airport (formerly Satolas Airport)|Lyon
LFLM|Mâcon Charnay Airport|Mâcon
LFLN|Saint-Yan Airport|Saint-Yan
LFLO|Roanne Renaison Airport|Roanne
LFLP|Annecy Meythet Airport|Annecy
LFLQ|Montélimar Ancone Airport|Montélimar
LFLR|Saint-Rambert-d'Albon Airport|Saint-Rambert-d'Albon
LFLS|Grenoble Saint-Geoirs Airport|Grenoble
LFLT|Montluçon Domerat Airport|Montluçon
LFLU|Valence Chabeuil Airport|Valence
LFLV|Vichy Charmeil Airport|Vichy
LFLW|Aurillac Airport|Aurillac
LFLX|Châteauroux-Déols Airport|Châteauroux, Déols
LFLY|Lyon Bron Airport|Lyon
LFLZ|Feurs Chambeon Airport|Feurs
LFMA|Aix Les Milles Airport|Aix-les-Milles
LFMC|Le Luc - Le Cannet Airport|Le Luc
LFMD|Cannes Mandelieu Airport|Cannes
LFME|Nimes Courbessac Airport|Nîmes
LFMF|Fayence-Tourrettes Airfield|Fayence
LFMG|La Montagne Noire Airport|La Montagne Noire
LFMH|Saint-Étienne Bouthéon Airport|Saint-Étienne
LFMI|Istres Le Tube Airport|Istres
LFMK|Carcassonne Salvaza Airport|Carcassonne
LFML|Marseille Provence Airport|Marseille
LFMM|Marseille FIR|Aix-en-Provence
LFMN|Nice Côte d'Azur Airport|Nice
LFMO|Orange Caritat Airport|Orange
LFMP|Perpignan Rivesaltes Airport|Perpignan
LFMQ|Le Castellet Airport|Le Castellet
LFMR|Barcelonnette Saint-Pons Airport|Barcelonnette
LFMS|Alès Deaux Airport|Alès
LFMT|Montpellier-Méditerranée Airport|Montpellier
LFMU|Béziers-Agde-Vias Airport|Béziers
LFMV|Avignon Caumont Airport|Avignon
LFMW|Castelnaudary Villeneuve Airport|Castelnaudary
LFMX|Chateau-Arnoux Saint-Auban Airport|Chateau-Arnoux
LFMZ|Lezignan Corbieres Airport|Lezignan
LFNA|Gap Tallard Airport|Gap
LFNB|Mende Brenoux Airport|Mende
LFNC|Mont-Dauphin Saint-Crepin Airport|Mont-Dauphin
LFND|Pont-Saint-Esprit Airport|Pont-Saint-Esprit
LFNE|Salon Eyguieres Airport|Salon
LFNF|Vinon Airport|Vinon
LFNG|Montpellier Candillargues Airport|Montpellier
LFNH|Carpentras Airport|Carpentras
LFNJ|Aspres-sur-Buech Airport|Aspres-sur-Buëch
LFNL|Saint-Martin-de-Londres Airport|Saint-Martin-de-Londres
LFNO|Florac Sainte-Enimie Airport|Florac
LFNP|Pézenas Nizas Airport|Pézenas
LFNQ|Mont-Louis La Quillane Airport|Mont-Louis
LFNR|Berre La Fare Airport|Berre
LFNS|Sisteron Theze Airport|Sisteron
LFNT|Avignon Pujaut Airport|Avignon
LFNU|Uzès Airport|Uzès
LFNV|Valréas Visan Airport|Valréas
LFNW|Puivert Airport|Puivert
LFNX|Bédarieux La Tour-sur-Orb Airport|Bédarieux
LFNZ|Le Mazet-de-Romanin Airport|Le Mazet
LFOB|Beauvais Tillé Airport|Beauvais
LFOC|Châteaudun Air Base|Châteaudun
LFOD|Saumur Saint-Florent Airport|Saumur
LFOE|Evreux Fauville Airport|Evreux
LFOF|Alençon Valframbert Airport|Alençon
LFOG|Flers Saint-Paul Airport|Flers
LFOH|Le Havre Octeville Airport|Le Havre
LFOI|Abbeville - Buigny-Saint-Maclou Aerodrome|Abbeville
LFOJ|Orléans - Bricy Air Base|Orléans
LFOK|Chalons Vatry Airport|Châlons-en-Champagne
LFOL|L'Aigle Saint-Michel Airport|L'Aigle
LFOM|Lessay Airport|Lessay
LFON|Vernouillet Airport|Dreux
LFOO|Les Sables-d'Olonne Talmont Airport|Les Sables-d'Olonne
LFOP|Rouen Vallée de Seine Airport|Rouen
LFOQ|Blois Le Breuil Airport|Blois
LFOR|Chartres Champhol Airport|Chartres
LFOS|Saint-Valery Vittefleur Airport|Saint-Valery
LFOT|Tours Val de Loire Airport|Tours
LFOU|Cholet Le Pontreau Airport|Cholet
LFOV|Laval Entrammes Airport|Laval
LFOW|Saint-Quentin Roupy Airport|Saint-Quentin
LFOX|Étampes Montdesir Airport|Étampes
LFOY|Le Havre Saint-Romain Airport|Le Havre
LFOZ|Orléans Saint-Denis-de-l'Hotel Airport|Orléans
LFPA|Persan-Beaumont Airport|Persan, Beaumont
LFPB|Paris Le Bourget Airport|Paris
LFPC|Creil Airport|Creil
LFPD|Bernay Saint-Martin Airport|Bernay
LFPE|Meaux Esbly Airport|Meaux
LFPF|Beynes Thiverval Airport|Beynes
LFPG|Paris Charles de Gaulle Airport (Roissy Airport)|Paris
LFPH|Chelles Le Pin Airport|Chelles
LFPI|Paris Issy-les-Moulineaux Airport|Paris
LFPK|Coulommiers-Voisins Airport|Coulommiers
LFPL|Lognes Emerainville Airport|Lognes
LFPM|Melun-Villaroche Airport|Melun
LFPN|Toussus-le-Noble Airport|Toussus-le-Noble
LFPO|Paris Orly Airport|Orly (near Paris)
LFPP|Le Plessis-Belleville Airport|Le Plessis-Belleville
LFPQ|Fontenay Tresigny Airport|Fontenay
LFPT|Pontoise - Cormeilles-en-Vexin Airport|Pontoise
LFPU|Moret Episy Airport|Moret
LFPV|Vélizy - Villacoublay Air Base|Villacoublay
LFPX|Chavenay Villepreux Airport|Chavenay
LFPY|Brétigny-sur-Orge Air Base|Bretigny-sur-Orge
LFPZ|Saint-Cyr-l'École Airport|Saint-Cyr-l'École
LFQA|Reims-Prunay Airport|Reims
LFQB|Troyes Barberey Airport|Troyes
LFQC|Lunéville-Croismare Airport|Lunéville
LFQD|Arras Roclincourt Airport|Arras
LFQF|Autun Bellevue Airport|Autun
LFQG|Nevers Fourchambault Airport|Nevers
LFQH|Châtillon-sur-Seine Airport|Châtillon-sur-Seine
LFQI|Cambrai Epinoy Airport|Cambrai
LFQJ|Maubeuge Elesmes Airport|Maubeuge
LFQK|Chalons Ecury-sur-Coole Airport|Chalons
LFQL|Lens Benifontaine Airport|Lens
LFQM|Besançon La Veze Airport|Besançon
LFQN|Saint-Omer Wizernes Airport|Saint-Omer
LFQO|Lille Marcq-en-Baroeul Airport|Lille
LFQQ|Lille Lesquin Airport|Lille
LFQR|Romilly-sur-Seine Airport|Romilly-sur-Seine
LFQS|Vitry-en-Artois Airport|Vitry-en-Artois
LFQT|Merville Calonne Airport|Merville / Hazebrouck
LFQU|Sarre-Union Airport|Sarre-Union
LFQV|Charleville-Mézières Airport|Charleville-Mézières
LFQW|Vesoul Frotey Airport|Vesoul
LFQX|Juvancourt Airport|Juvancourt
LFQY|Saverne Steinbourg Airport|Saverne
LFQZ|Dieuze Gueblange Airport|Dieuze
LFRB|Brest Bretagne Airport|Brest
LFRC|Cherbourg Maupertus Airport|Cherbourg
LFRD|Dinard Pleurtuit Saint-Malo Airport|Dinard
LFRE|La Baule-Escoublac Airport|La Baule-Escoublac
LFRF|Granville Airport|Granville
LFRG|Deauville Saint-Gatien Airport|Deauville
LFRH|Lorient South Brittany Airport|Lorient
LFRI|La Roche-sur-Yon Les Ajoncs Airport|La Roche-sur-Yon
LFRJ|Landivisiau Airport|Landivisiau
LFRK|Caen Carpiquet Airport|Caen
LFRM|Le Mans Arnage Airport|Le Mans
LFRN|Rennes - Saint-Jacques Airport|Rennes
LFRO|Lannion Airport|Lannion
LFRP|Ploermel Loyat Airport|Ploërmel
LFRQ|Quimper Pluguffan Airport|Quimper
LFRS|Nantes Atlantique Airport (formerly Aéroport Château Bougon)|Nantes
LFRT|Saint-Brieuc - Armor Airport|Saint-Brieuc
LFRU|Morlaix Ploujean Airport|Morlaix
LFRV|Vannes-Meucon Airport|Vannes
LFRW|Avranches Le Val Saint-Pere Airport|Avranches
LFRZ|Saint-Nazaire Montoir Airport|Saint-Nazaire
LFSA|Besançon Thise Airport|Besançon
LFSB|Bâle Mulhouse Airport (EuroAirport Basel-Mulhouse-Freiburg)|Basel (Switzerland) / Mulhouse
LFSD|Dijon Bourgogne - Longvic Airport|Dijon
LFSE|Epinal dogneville Airport|Epinal
LFSF|Metz Frescaty Airport|Metz
LFSG|Épinal Mirecourt Airport|Épinal
LFSH|Haguenau Airport|Haguenau
LFSJ|Sedan Douzy Airport|Sedan
LFSK|Vitry-le-François Vauclerc Airport|Vitry-le-François
LFSM|Montbéliard Courcelles Airport|Montbéliard
LFSN|Nancy Essey Airport|Nancy
LFSP|Pontarlier Airport|Pontarlier
LFSQ|Belfort Fontaine Airport|Belfort
LFSR|Reims Champagne Airport|Reims
LFST|Strasbourg Entzheim Airport|Strasbourg
LFSU|Langres Rolampont Airport|Langres
LFSV|Pont-Saint-Vincent Airport|Pont-Saint-Vincent
LFSW|Épernay Plivot Airport|Épernay
LFSY|Chaumont - La Vendue Airport|Chaumont
LFSZ|Vittel Champ-de-Courses Airport|Vittel
LFTB|Marignane Berre Airport|Marignane
LFTF|Cuers Pierrefeu Airport|Cuers
LFTH|Hyères Le Palyvestre Airport|Toulon
LFTM|Serres La Batie Montsaleon Airport|Serres-la-Batie
LFTN|La Grand'Combe Airport|La Grand'Combe
LFTP|Puimoisson Airport|Puimoisson
LFTQ|Chateaubriant Pouance Airport|Châteaubriant
LFTR|Toulon-St. Mandrier Heliport|Saint-Mandrier-sur-Mer
LFTU|Frejus Saint-Raphael Airport|Frejus
LFTW|Nîmes-Arles-Camargue Airport|Nîmes
LFTZ|La Mole Airport|La Mole
LFXA|Ambérieu-en-Bugey Air Base|Amberieu
LFXB|Saintes Thenac Airport|Saintes
LFXM|Mourmelon Airport|Mourmelon
LFXN|Narbonne Airport|Narbonne
LFXU|Les Mureaux Airport|Les Mureaux
LFYG|Cambrai Niergnies Airport|Cambrai
LFYR|Romorantin Pruniers Airport|Romorantin
LFYS|Sainte-Léocadie Airport|Sainte-Léocadie
LFVM|Miquelon Airport|Miquelon
LFVP|Saint Pierre Airport|Saint-Pierre
LGAL|Alexandroupolis International Airport, "Dimokritos" (Democritus)|Alexandroupolis
LGAD|Andravida Airport|Andravida
LGAV|Athens International Airport, "Eleftherios Venizelos"|Athens (Athina)
LGBL|International Airport of Central Greece|Nea Anchialos/Volos
LGHI|Chios Island National Airport|Chios
LGIK|Ikaria Island National Airport|Ikaria
LGIO|Ioannina National Airport|Ioannina
LGIR|Heraklion International Airport, "Nikos Kazantzakis"|Heraklion (Iraklion), Crete
LGKA|Kastoria National Airport, "Aristotelis"|Kastoria
LGKC|Kithira Island National Airport|Kythira (Kithira)
LGKF|Kefalonia Island International Airport|Kefalonia (Kefallinia, Cephallonia)
LGKJ|Kastelorizo Island Public Airport|Kastelorizo
LGKL|Kalamata International Airport|Kalamata
LGKO|Kos Island International Airport, "Ippokratis" (Hippocrates)|Kos
LGKP|Karpathos Island National Airport|Karpathos
LGKR|Ioannis Kapodistrias International Airport|Corfu (Kerkyra, Kerkira)
LGKS|Kassos Island Public Airport|Kasos (Kassos)
LGKV|Kavala International Airport, "Megas Alexandros"|Kavala
LGKZ|Kozani National Airport, "Filippos"|Kozani
LGLM|Lemnos International Airport|Lemnos (Limnos)
LGMK|Mykonos Island National Airport|Mykonos (Mikonos)
LGML|Milos Island National Airport|Milos
LGMT|Mytilene International Airport, "Odysseas Elytis"|Mytilene (Mitilini), Lesbos
LGNX|Naxos Island National Airport|Naxos
LGPA|Paros National Airport|Paros
LGPL|Astypalaia Island National Airport|Astypalaia
LGPZ|Aktion National Airport (Lefkada Airport)|Preveza
LGRP|Rhodes International Airport, "Diagoras"|Rhodes (Rhodos, Rodos)
LGRX|Araxos Airport|Araxos
LGSA|Chania International Airport, "Ioannis Daskalogiannis"|Chania, Crete
LGSK|Skiathos Island National Airport|Skiathos
LGSM|Samos International Airport, "Aristarchos"|Samos
LGSO|Syros Island National Airport|Syros (Siros)
LGSR|Santorini (Thira) National Airport|Santorini (Thira)
LGST|Sitia Public Airport|Sitia, Crete
LGSY|Skyros Island National Airport|Skyros (Skiros)
LGTS|Thessaloniki International Airport, "Makedonia"|Thessaloniki
LGZA|Zakynthos International Airport, "Dionysios Solomos"|Zakynthos (Zakinthos)
LHBP|Budapest Ferihegy International Airport|Budapest
LHBS|Budaörs Airport|Budaörs
LHDC|Debrecen International Airport|Debrecen
LHDK|Dunakeszi Airport|Dunakeszi
LHEC|Érsekcsanád Airport|Érsekcsanád
LHEM|Esztergom Airport|Esztergom
LHFM|Fertőszentmiklós Airport|Fertőszentmiklós
LHKE|Kecskemét Airport|Kecskemét
LHNY|Nyíregyháza Airport|Nyíregyháza
LHOY|Őcsény Airport|Őcsény
LHPA|Pápa Airport|Pápa
LHPP|Pécs Pogány Airport|Pécs
LHPR|Győr Pér Airport|Győr, Pér
LHSA|Szentkirályszabadja Airport|Szentkirályszabadja
LHSM|Sármellék International Airport|Sármellék
LHSN|Szolnok Airport|Szolnok
LHSK|Siófok-Kiliti Airport|Ságvár
LHTA|Taszár Airport|Taszár
LHTL|Tököl Airport|Tököl
LIAF|Foligno Airport|Foligno
LIAP|Preturo Airport|L'Aquila
LIAT|Pontedera Airport|Pontedera, Pisa
LIAU|Capua Airport|Capua
LIBA|Amendola Air Force Base|Foggia
LIBC|Crotone Airport (Sant'Anna Airport)|Crotone
LIBD|Bari Karol Wojtyla International Airport|Bari
LIBF|Gino Lisa Airport|Foggia
LIBG|Grottaglie Airport|Taranto
LIBN|Lecce Airport (military)|Lecce
LIBP|Abruzzo International Airport|Pescara
LIBR|Casale Airport|Brindisi
LIBV|Gioia del Colle Air Base|Gioia del Colle, Bari
LIBX|Martina Franca Air Force Base|Martina Franca, Taranto
LICA|Lamezia Terme International Airport|Lamezia Terme, Catanzaro
LICB|Comiso Airport|Comiso
LICC|Catania-Fontanarossa Airport (Catania-Fontanarossa Airport)|Catania
LICD|Lampedusa Airport|Lampedusa
LICG|Pantelleria Airport|Pantelleria, Trapani
LICJ|Palermo International Airport (Punta Raisi Falcone-Borsellino Airport)|Palermo / Punta Raisi
LICP|Palermo-Boccadifalco Airport|Palermo
LICR|Reggio Calabria Airport|Reggio Calabria
LICT|Vincenzo Florio Airport (Birgi Airport)|Trapani
LICZ|Sigonella Airport (military)|Catania
LIDA|Asiago Airport|Asiago, Vicenza
LIDB|Belluno Airport|Belluno
LIDE|Reggio Emilia Airport|Reggio Emilia
LIDF|Fano Airport|Fano, Pesaro & Urbino
LIDG|Lugo di Romagna Airport|Lugo di Romagna, Ravenna
LIDR|Ravenna Airport|Ravenna
LIDT|G. Caproni Airport (Mattarello Airport)|Trento
LIDU|Carpi Budrione Airport|Carpi
LIEA|Fertilia Airport (Alghero Airport)|Alghero, Sassari
LIED|Decimomannu Air Base|Decimomannu, Cagliari
LIEE|Cagliari - Elmas Airport|Cagliari
LIEO|Olbia - Costa Smeralda Airport|Olbia
LIER|Oristano-Fenosu Airport|Oristano
LIET|Tortolì Airport|Tortoli
LILE|Cerrione Airport|Biella
LILG|Vergiate Airport|Vergiate, Varese
LILH|Rivanazzano Airport|Voghera, Pavia
LILN|Venegono Airport|Varese
LILR|Migliaro Airport|Cremona
LIMA|Aeritalia Airport|Turin (Torino)
LIMB|Bresso Airport|Milan
LIMC|Malpensa International Airport|Milan
LIME|Orio al Serio International Airport|Bergamo
LIMF|Turin International Airport (Torino Caselle Airport)|Turin (Torino)
LIMG|Villanova d'Albenga International Airport (C. Panero Airport)|Albenga, Savona
LIMJ|Genoa Cristoforo Colombo Airport (Sestri Airport)|Genoa (Genova)
LIML|Linate Airport|Milan
LIMN|Cameri Air Force Base|Cameri, Novara
LIMP|Parma Airport (G. Verdi Airport)|Parma
LIMS|San Damiano Air Force Base|Piacenza
LIMW|Aosta Airport (Corrado Gex Airport)|Aosta
LIMZ|Cuneo Levaldigi Airport|Cuneo
LIPA|Aviano Air Base|Aviano, Pordenone
LIPB|Bolzano Dolomiti Airport|Bolzano, Bolzano-Bozen
LIPC|Cervia Air Force Base|Cervia, Ravenna
LIPD|Campoformido Airport (military?)|Campoformido / Udine
LIPE|Bologna Airport (Guglielmo Marconi Airport)|Bologna
LIPF|Ferrara Airport|Ferrara
LIPH|Treviso Airport (Sant'Angelo Airport)|Treviso
LIPI|Rivolto Air Force Base|Rivolto / Udine
LIPK|Forlì Airport (L. Ridolfi Airport)|Forlì
LIPL|Ghedi Airport (military)|Ghedi, Brescia
LIPM|Modena Marzaglia Airport|Modena
LIPN|Boscomantico Airport|Verona
LIPO|Montichiari Airport|Brescia
LIPQ|Friuli Venezia Giulia Airport (Trieste Ronchi dei Legionari Airport)|Ronchi dei Legionari / Trieste
LIPR|Federico Fellini International Airport|Rimini
LIPS|Istrana Air Force Base|Treviso
LIPT|Vicenza Trissino Airport|Vicenza
LIPU|Padova Airport (Gino Allegri Airport)|Padua (Padova)
LIPV|San Nicolo Airport|Venice (Venezia)
LIPX|Verona Airport (Villafranca International Airport, Valerio Catullo)|Verona
LIPY|Falconara Airport (Raffaello Sanzio Airport)|Ancona
LIPZ|Marco Polo International Airport (Marco Polo Venice Airport)|Venice (Venezia)
LIQL|Tassignano Airport|Lucca
LIQS|Siena Airport|Siena
LIQW|Luni Airport (military?)|Sarzana, Genoa
LIRA|Ciampino Airport (Giovan Battista Pastine Airport)|Rome
LIRC|Centocelle Air Force Base|Centocelle, Rome
LIRE|Pratica di Mare Air Force Base|Pomezia, Rome
LIRF|Leonardo da Vinci International Airport (Fiumicino International Airport)|Rome
LIRG|Guidonia Air Force Base|Guidonia Montecelio, Rome
LIRI|Salerno Costa d'Amalfi Airport|Salerno
LIRJ|Marina di Campo Airport|Marina di Campo, Elba
LIRL|Latina Airport (military?)|Latina
LIRM|Grazzanise Airport (military?)|Caserta
LIRN|Naples International Airport (Capodichino Airport)|Naples
LIRP|Galileo Galilei Airport (Pisa International Airport)|Pisa
LIRQ|Amerigo Vespucci Airport (Florence Airport)|Florence (Firenze)
LIRS|Grosseto Airport|Grosseto
LIRU|Rome Urbe Airport|Rome
LIRV|Viterbo Air Force Base / Rome Viterbo Airport|Viterbo
LIRZ|San Egidio Airport|Perugia
LJAJ|Ajdovščina Airport|Ajdovščina
LJBL|Lesce-Bled Airport|Lesce
LJBO|Bovec Airport|Bovec
LJCE|Cerklje ob Krki Airbase|Cerklje ob Krki, Brežice
LJCL|Celje Airport|Celje (Levec)
LJLA|Ljubljana ACC-FIR-AFTN Airport|Ljubljana
LJLJ|Ljubljana Jože Pučnik Airport (Brnik Airport)|Ljubljana
LJMB|Maribor Edvard Rusjan Airport|Maribor
LJMS|Murska Sobota Airport|Murska Sobota (Rakičan)
LJNM|Novo Mesto-Prečna Airport|Novo Mesto (Prečna)
LJPO|Postojna Airport|Postojna
LJPT|Ptuj Airport|Ptuj (Moškanjci)
LJPZ|Portorož Airport|Portorož
LJSG|Slovenj Gradec Airport|Slovenj Gradec
LJVE|Velenje Airport|Velenje (Lajše)
LKBA|Břeclav Airport|Břeclav
LKBE|Benešov Airport|Benešov
LKBR|Broumov Airport|Broumov
LKBU|Bubovice Airport|Bubovice
LKCB former|Cheb Airport|Cheb
LKCE|Česká Lípa Airport|Česká Lípa
LKCH|Chomutov Airport|Chomutov
LKCM|Medlánky Airport|Medlánky
LKCS|České Budějovice Airport|České Budějovice
LKCT|Chotěboř Airport|Chotěboř
LKDK|Dvůr Králové nad Labem Airport|Dvůr Králové nad Labem
LKHB|Havlíčkův Brod Airport|Havlíčkův Brod
LKHC|Hořice Airport|Hořice
LKHD|Hodkovice nad Mohelkou Airport|Hodkovice nad Mohelkou
LKHN|Hranice Airport|Hranice
LKHO|Holešov Airport|Holešov
LKJA|Jaroměř Airport|Jaroměř
LKJC|Jičín Airport|Jičín
LKJH|Jindřichův Hradec Airport|Jindřichův Hradec
LKJI|Jihlava Airport|Jihlava
LKKB|Praha Kbely|Praha
LKKL|Kladno Airport|Kladno
LKKO|Kolín Airport|Kolín
LKKR|Krnov Airport|Krnov
LKKA|Křižanov Airport|Křižanov
LKKT|Klatovy Airport|Klatovy
LKKU|Kunovice Airport|Kunovice
LKKV|Karlovy Vary Airport|Karlovy Vary
LKKY|Kyjov Airport|Kyjov
LKLT|Letňany Airport|Letňany
LKMB|Mladá Boleslav Airport|Mladá Boleslav
LKMH|Mnichovo Hradiště Airport|Mnichovo Hradiště
LKMI|Mikulovice Airport|Mikulovice
LKMK|Moravská Třebová Airport|Moravská Třebová
LKMO|Most Airport|Most
LKMR|Mariánské Lázně Airport|Mariánské Lázně
LKMT|Ostrava-Mošnov International Airport|Ostrava
LKNM|Nové Město Airport|Nové Město nad Metují
LKOL|Olomouc Airport|Olomouc
LKOT|Otrokovice Airfield|Otrokovice
LKPA|Polička Airport|Polička
LKPD|Pardubice Airport|Pardubice
LKPI|Přibyslav Airport|Přibyslav
LKPL|Letkov Airport|Letkov
LKPM|Příbram Airport|Příbram
LKPN|Podhořany Airport|Podhořany
LKPO|Přerov Airport|Přerov
LKPR|Ruzyně International Airport|Prague
LKPS|Plasy Airport|Plasy
LKRA|Raná u Loun Airport|Raná u Loun
LKRK|Rakovník Airport|Rakovník
LKRO|Roudnice Airport|Roudnice
LKSA|Staňkov Airport|Staňkov
LKSK|Skuteč Airport|Skuteč
LKSN|Slaný Airport|Slaný
LKSO|Soběslav Airport|Soběslav
LKSR|Strunkovice Airport|Strunkovice
LKST|Strakonice Airport|Strakonice
LKSU|Šumperk Airport|Šumperk
LKSZ|Sazená Airport|Sazená
LKTA|Tábor Airport|Tábor
LKTB|Brno-Tuřany Airport|Brno
LKTC|Točná Airport|Točná
LKTO|Toužim Airport|Toužim
LKUO|Ústí nad Orlicí Airport|Ústí nad Orlicí
LKVL|Vlašim Airport|Vlašim
LKVM|Vysoké Mýto Airport|Vysoké Mýto
LKVO|Vodochody Airport|Vodochody
LKVP|Velké Poříčí Airport|Velké Poříčí
LKVR|Vrchlabí Airport|Vrchlabí
LKVY|Vyškov Airport|Vyškov
LKZA|Zábřeh Airport|Zábřeh
LKZB|Zbraslavice Airport|Zbraslavice
LLBG|Ben Gurion International Airport|Lod / Tel Aviv
LLBS|Be'er Sheva Airport (Teyman Airport)|Beersheba (Be'er Sheva)
LLEK|Tel Nof Israeli Air Force Base|Tel Nof (Tel Nov)
LLES|Ein Shemer Airfield|Ein Shemer (Eyn-Shemer)
LLET|Eilat Airport (J. Hozman Airport)|Eilat
LLEY|Ein Yahav Airfield|Ein Yahav (Eyn-Yahav)
LLFK|Fiq Airfield|Fiq, Golan Heights
LLHA|Haifa International Airport (U. Michaeli Airport)|Haifa
LLHB|Hatzerim Airbase (Hatzerim)|Beersheba (Be'er Sheva)
LLHS|Hatzor Airbase|Hatzor
LLHZ|Herzliya Airport|Herzliya (Herzlia)
LLIB|Rosh Pina Airport (Ben Ya'aqov Airport)|Rosh-Pina
LLJR|Atarot Airport (Jerusalem International Airport)|Jerusalem (currently closed)
LLKS|Qiryat Shemona Airport|Qiryat Shemona (Kiryat-Shmona)
LLMG|Megiddo Airport|Megiddo (Meggido)
LLMR|Mitzpe Ramon Airfield|Mitzpe Ramon
LLMZ|Bar Yehuda Airfield|Masada
LLNV|Nevatim Israeli Air Force Base|Nevatim
LLOV|Ovda International Airport|Negev
LLRD|Ramat David Israeli Air Force Base|Megiddo
LLRM|Ramon Airbase|Mitzpe Ramon
LLSD|Sde Dov Airport (Dov Hoz Airport)|Tel Aviv
LLYT|Yotvata Airfield|Yotvata
LMML|Malta International Airport (Luqa Airport)|Luqa
LNMC|Monaco Heliport|Monte Carlo
LOAN|Wiener Neustadt East Airport|Wiener Neustadt, Lower Austria
LOKF|Feldkirchen Airfield|Ossiacher See
LOLG|St. Georgen Airfield [1]|Leutzmannsdorf
LOLO|Linz Ost Airfield (Linz East Airfield)|Linz, Upper Austria
LOLW|Wels Airport|Wels, Upper Austria
LOWG|Graz Airport (Thalerhof Airport)|Graz, Styria
LOWI|Innsbruck Airport (Kranebitten Airport)|Innsbruck, Tyrol
LOWK|Klagenfurt Airport (Woerthersee Airport)|Klagenfurt, Carinthia
LOWL|Linz Airport (Blue Danube Airport)|Linz, Upper Austria
LOWS|Salzburg Airport (W. A. Mozart Airport)|Salzburg, Salzburg
LOWW|Vienna International Airport (Schwechat Airport)|Vienna
LOXZ|Zeltweg Air Base|Zeltweg, Styria
LPAR|Alverca Air Base|Alverca do Ribatejo, Vila Franca de Xira
LPAV|São Jacinto Airport (Aveiro Airport)|Aveiro
LPBG|Bragança Airport|Bragança
LPBJ|Beja Air Base|Beja
LPBR|Braga Airport|Palmeira,Braga
LPCH|Chaves Airport|Chaves
LPCO|Coimbra Airport (Antanhol / Cernache /Coimbra) Bissaya Barreto Airport|Coimbra
LPCS|Tires Airport ,São Domingos da Rana, (Cascais Airport) Tires,Cascais|Cascais / Estoril - Sintra Coast / Greater Lisbon
LPCV|Covilhã Airport|Covilhã / Cova da Beira / Guarda / Beiras / Serra da Estrela
LPEV|Évora Airport|Évora / Alentejo Central
LPFR|Faro Airport|Faro / Algarve Int. Faro
LPIN|Espinho Airport|Paramos / Silvalde/Espinho
LPMF|Monfortinho Airport|Monfortinho, Idanha-a-Nova
LPMI|Mirandela Airport|Mirandela
LPMO|Montargil Airport|Montargil, Ponte de Sor
LPMR|Monte Real Air Base|Monte Real, Leiria
LPMT|Montijo Air Base|Montijo
LPOT|Ota Air Base|Ota, Alenquer
LPOV|Ovar Air Base|Maceda,Ovar
LPPM|Portimão Airport|Montes de Alvor /Penina / Alvor, Portimão,Barlavento Algarvio
LPPR- Francisco Sá Carneiro Airport Int.|Porto / Oporto|Pedras Rubras,Moreira,Maia;Greater Porto area:Matosinhos,Vila do Conde,Maia,Grande Porto
LPPT|Portela Airport (Lisbon Airport), Lisbon / Lisboa|Portela,Lisbon / Prior Velho, Loures ( Lisbon) Int.
LPPV|Praia Verde Airport|Praia Verde,Altura Castro Marim / Tavira / Sotavento area.
LPSC|Santa Cruz Airport Torres Vedras /Santa Cruz Beach|Praia de Santa Cruz, Torres Vedras
LPSI|Sines Airport|Sines /Alentejo Litoral
LPSR|Santarém Airport|Santarém
LPST|Sintra Air Base|Granja do Marquês / Pero Pinheiro, Sintra
LPTN|Tancos Air Base|Tancos, Vila Nova da Barquinha, Médio Tejo
LPVL|Maia Airport {Maia Airfield} (Vilar da Luz Airport)|Maia
LPVM|Vilamoura Airport|Vilamoura / Quarteira, Loulé
LPVR|Vila Real Airport|Vila Real / Alto Douro
LPVZ|Viseu Airport (Gonçalves Lobato Airport)|Lordosa, Viseu (Viséu)
LPAZ|Santa Maria Airport|Santa Maria Island / Vila do Porto
LPCR|Corvo Airport|Corvo Island / Vila do Corvo
LPFL|Flores Airport|Flores Island / Santa Cruz das Flores
LPGR|Graciosa Airport|Graciosa Island / Santa Cruz da Graciosa
LPHR|Horta Airport|Horta, Faial Island
LPLA|Lajes Air Base Int.|Terceira Island /Praia da Vitoria /Angra do Heroísmo area
LPPD|Ponta Delgada João Paulo II Airport ,formerlyNordela Int.|Ponta Delgada, São Miguel Island
LPPI|Pico Airport|Pico Island (Madalena,São Roque,Lajes do Pico)
LPSJ|São Jorge Airport|São Jorge Island /Velas
LPMA|Madeira Airport Int. (Funchal Airport)|Funchal, Madeira Island (Santa Cruz) /Funchal area {Madeira Island}
LPPS|Porto Santo Airport|Porto Santo Island / Vila Baleira {Porto Santo Island}
LQBI|Bihać Airport|Bihać
LQBK|Banja Luka International Airport|Banja Luka
LQBU|Sarajevo Butmir Airport|Sarajevo
LQBZ|Banja Luka Zalužani Airport|Banja Luka
LQCO|Ćoralići Airport|Ćoralići
LQGL|Glamoč Airport|Glamoč
LQJL|Tuzla Jegen Lug Airport|Tuzla
LQKU|Kupres Bajramovići Airport|Kupres
LQLV|Livno Airport|Livno
LQMJ|Mostar Jasenica Airport|Mostar
LQMO|Mostar International Airport|Mostar
LQPD|Prijedor Airport|Prijedor
LQSA|Sarajevo International Airport|Sarajevo
LQSV|Sarajevo Military Airport|Sarajevo
LQTG|Tomislavgrad Airport|Tomislavgrad
LQTR|Novi Travnik Airport|Novi Travnik
LQTZ|Tuzla International Airport|Tuzla
LQVI|Visoko Airport|Visoko
LRAR|Arad International Airport|Arad
LRBC|Bacău International Airport|Bacău
LRBM|Baia Mare Airport|Baia Mare
LRBS|Bucharest "Aurel Vlaicu" Vlaicu International Airport|Bucharest
LRCK|Constanţa "Mihail Kogălniceanu" International Airport|Constanţa
LRCL|Cluj-Napoca International Airport|Cluj-Napoca
LRCS|Caransebeş Airport|Reşiţa
LRCV|Craiova Airport|Craiova
LRIA|Iaşi International Airport|Iaşi
LROD|Oradea International Airport|Oradea
LROP|Bucharest "Henri Coandǎ" International Airport|Bucharest
LRSB|Sibiu International Airport|Sibiu
LRSM|Satu Mare International Airport|Satu Mare
LRSV|Suceava Airport|Suceava
LRTC|Tulcea Airport|Tulcea
LRTM|Târgu Mureş International Airport|Târgu-Mureş
LRTR|Timişoara "Traian Vuia" International Airport|Timişoara
LSER|Raron Heliport|Raron
LSEZ|Zermatt Heliport|Zermatt
LSGB|Bex Airport|Bex
LSGC|Les Eplatures Airport|La Chaux-de-Fonds
LSGE|Fribourg-Ecuvillens Airfield|Ecuvillens
LSGG|Geneva Cointrin International Airport|Geneva
LSGK|Saanen Airport|Saanen
LSGL|Lausanne Airport|Lausanne / Blécherette
LSGN|Neuchâtel Airport|Neuchâtel
LSGP|La Côte Airport|La Côte
LSGR|Reichenbach Airport|Reichenbach
LSGS|Sion Airport|Sion (ICAO code applies to civilian airport)
LSGT|Gruyères Airport|Gruyères
LSGY|Yverdon-les-Bains Airport|Yverdon-les-Bains
LSHC|Collombey-Muraz Heliport|Collombey-Muraz
LSHG|Gampel Heliport|Gampel
LSMA|Alpnach Air Base|Alpnach (military)
LSMD|Dübendorf Air Base|Dübendorf (military)
LSME|Emmen Air Base|Emmen (military)
LSMM|Meiringen Air Base|Meiringen (military)
LSMP|Payerne Air Base|Payerne (military)
LSMS|Sion Air Base|Sion (military)
LSPA|Amlikon Airport|Amlikon
LSPD|Dittingen Airport|Dittingen
LSPF|Schaffhausen Airport|Schaffhausen
LSPG|Kägiswil Airport|Kägiswil
LSPH|Winterthur Airport|Winterthur
LSPK|Hasenstrick Airport|Hasenstrick
LSPL|Langenthal Airport|Langenthal
LSPM|Ambri Airport|Ambri
LSPN|Triengen Airport|Triengen
LSPO|Olten Airport|Olten
LSPV|Wangen-Lachen Airport|Wangen-Lachen
LSTB|Bellechasse Airport|Bellechasse, Canton of Fribourg
LSTO|Môtiers Airport|Môtiers
LSTR|Montricher Airport|Montricher
LSTS|St. Stephan Airport|St. Stephan
LSXB|Balzers Heliport|Balzers
LSXG|Gsteigwiler Heliport|Gsteigwiler
LSXI|Interlaken Heliport|Interlaken
LSXK|Benken Heliport|Benken
LSXL|Lauterbrunnen Heliport|Lauterbrunnen
LSXO|Trogen Heliport|Trogen
LSXS|Schindellegi Heliport|Schindellegi
LSXT|Trogen Heliport|Trogen
LSXU|Untervaz Heliport|Untervaz
LSXW|Würenlingen Heliport|Würenlingen
LSXY|Leysin Heliport|Leysin
LSZA|Lugano Airport|Lugano / Agno
LSZB|Berne Airport|Berne / Belp
LSZC|Buochs Airport|Buochs
LSZD|Ascona Airport|Ascona
LSZE|Bad Ragaz Airport|Bad Ragaz
LSZF|Birrfeld Airport|Birrfeld
LSZG|Grenchen Airport|Grenchen
LSZH|Zürich Airport (Kloten Airport)|Zürich / Kloten
LSZI|Fricktal-Schupfart Airport|Fricktal-Schupfart
LSZJ|Courtelary Airport|Courtelary
LSZK|Speck-Fehraltorf Airport|Speck-Fehraltorf
LSZL|Locarno Airport|Locarno
LSZN|Hausen am Albis Airport|Hausen am Albis
LSZO|Luzern-Beromünster Airport|Luzern-Beromünster
LSZP|Biel-Kappelen Airport|Biel-Kappelen
LSZR|St. Gallen-Altenrhein Airport|St. Gallen / Altenrhein
LSZS|Samedan Airport (Engadin Airport)|Samedan
LSZT|Lommis Airport|Lommis
LSZU|Buttwil Airport|Buttwil
LSZV|Sitterdorf Airport|Sitterdorf
LSZW|Thun Airport|Thun
LSZX|Schänis Airport|Schänis
LSZY|Porrentruy Airport|Porrentruy
LFSB|EuroAirport Basel-Mulhouse-Freiburg|Basel (Switzerland), Mulhouse (France) and Freiburg (Germany)
LTAC|Ankara Esenboğa International Airport|Ankara
LTAF|Adana Şakirpaşa Airport|Adana
LTAI|Antalya Airport|Antalya
LTAJ|Oğuzeli Airport|Gaziantep
LTAK|Hatay Airport|Antakya
LTAL|Kastamonu Airport|Kastamonu
LTAN|Konya Airport|Konya
LTAR|Sivas Airport|Sivas
LTAT|Malatya Erhaç Airport|Malatya
LTAU|Kayseri Erkilet International Airport|Kayseri
LTAY|Denizli Çardak Airport|Denizli
LTAZ|Nevşehir Kapadokya Airport|Nevşehir
LTBA|Istanbul Atatürk International Airport|Istanbul
LTBH|Çanakkale Airport|Çanakkale
LTBJ|İzmir Adnan Menderes Airport|İzmir
LTBR|Bursa Yenişehir Airport|Bursa
LTBS|Dalaman Airport|Muğla
LTBU|Çorlu Airport|Tekirdağ
LTBW|Istanbul Hezarfen Airfield|Istanbul
LTCA|Elazığ Airport|Elazığ
LTCC|Diyarbakır Airport|Diyarbakır
LTCD|Erzincan Airport|Erzincan
LTCE|Erzurum Airport|Erzurum
LTCF|Kars Airport|Kars
LTCG|Trabzon Airport|Trabzon
LTCH|Şanlıurfa Airport|Şanlıurfa
LTCI|Van Ferit Melen Airport|Van
LTCJ|Batman Airport|Batman
LTCK|Muş Airport|Muş
LTCL|Siirt Airport|Siirt
LTCN|Kahramanmaraş Airport|Kahramanmaraş
LTCO|Ağrı Airport|Ağrı
LTCP|Adıyaman Airport|Adıyaman
LTCR|Mardin Airport|Mardin
LTFC|Süleyman Demirel Airport|Isparta
LTFD|Edremit Körfez Airport|Balıkesir
LTFE|Milas-Bodrum Airport|Milas
LTFH|Samsun-Çarşamba Airport|Samsun
LTFJ|Istanbul Sabiha Gökçen International Airport|Istanbul
LUBL|Bălţi Airport|Bălţi
LUBM|Mărculeşti Airport|Mărculeşti
LUCH|Cahul Airport|Cahul
LUCM|Camenca Airport|Camenca
LUKK|Chişinău International Airport|Chişinău
LUSR|Soroca Airport|Soroca
LUTG|Tighina Airport|Tighina
LUTR|Tiraspol Airport|Tiraspol
LVGZ|Yasser Arafat International Airport (formerly Gaza International Airport)|Rafah
LWOH|Ohrid Airport|Ohrid
LWSK|Skopje Airport|Skopje
LXGB|Gibraltar Airport|Gibraltar
LYBE|Belgrade Nikola Tesla International Airport|Belgrade
LYBT|Batajnica Airport|Batajnica / Belgrade
LYKV|Kraljevo-Lađevci Airport|Kraljevo
LYNI|Niš Constantine the Great International Airport|Niš
LYNS|Novi Sad-Čenej Airport|Novi Sad
LYTR|Trstenik Airport|Trstenik
LYUZ|Užice-Ponikve Airport|Užice
LYVR|Vršac Airport|Vršac
LYZR|Zrenjanin Airport|Zrenjanin
LYBR|Berane Airport|Berane, Montenegro
LYPJ|Golubovci Airbase|Golubovci, Montenegro
LYNK|Kapino Polje Airport|Nikšić, Montenegro
LYPG|Podgorica Airport|Podgorica, Montenegro
LYPO|Ćemovsko Polje Airport|Podgorica, Montenegro
LYTV|Tivat Airport|Tivat, Montenegro
LZIB|Milan Rastislav Štefánik Airport (Bratislava Airport)|Bratislava
LZKZ|Košice International Airport|Košice
LZPP|Piešťany Airport|Piešťany
LZSE|Senica Airport|Senica
LZSL|Sliač Airport|Sliač
LZTT|Poprad-Tatry Airport|Poprad
LZZI|Žilina Airport|Žilina
MBGT|JAGS McCartney International Airport (Grand Turk Int'l)|Grand Turk Island
MBMC|Middle Caicos Airport|Middle Caicos
MBNC|North Caicos Airport|North Caicos
MBPI|Pine Cay Airport|Pine Cay
MBPV|Providenciales International Airport|Providenciales
MBSC|South Caicos Airport|South Caicos
MBSY|Salt Cay Airport|Salt Cay
MBAC|Harold Charles International Airport|Ambergris Cay
MDAB|Arroyo Barril International Airport|Samaná
MDBH|María Montez International Airport|Barahona
MDCR|Cabo Rojo Airport|Pedernales
MDCZ|Constanza Airport|Constanza
MDCY|Samaná El Catey International Airport|Samaná
MDJB|La Isabela International Airport (Dr. Joaquín Balaguer)|Santo Domingo
MDLR|La Romana International Airport|La Romana
MDPC|Punta Cana International Airport|Punta Cana / Higüey
MDPO|El Portillo Airport|Samaná
MDPP|Gregorio Luperón International Airport|Puerto Plata
MDSB|Sabana de la Mar Airport|Sabana de la Mar
MDSD|Las Américas-JFPG International Airport (Dr. José Fco. Peña Gómez)|Punta Caucedo (near Santo Domingo)
MDSI|San Isidro Air Base|San Isidro
MDSJ|San Juan de la Maguana Airport|San Juan de la Maguana
MDST|Cibao International Airport (Santiago Municipal)|Santiago
MGBN|Bananera Airport|Bananera, Izabal
MGCB|Cobán Airport|Cobán, Alta Verapaz
MGCR|Carmelita Airport|Carmelita, El Petén
MGCT|Coatepeque Airport|Coatepeque, Quetzaltenango
MGES|Esquipulas Airport|Esquipulas, Chiquimula
MGGT|La Aurora International Airport|Guatemala City
MGHT|Huehuetenango Airport|Huehuetenango, Huehuetenango
MGLL|La Libertad Airport|La Libertad, El Petén
MGML|Malacatan Airport|Malacatan, San Marcos
MGMM|Melchor de Mencos Airport|Melchor de Mencos, El Petén
MGPB|Puerto Barrios Airport|Puerto Barrios, Izabal
MGPP|Poptun Airport|Poptún, El Petén
MGQC|Quiché Airport|Quiché, El Quiché
MGQZ|Quetzaltenango Airport|Quetzaltenango, Quetzaltenango
MGRB|Rubelsanto Airport|Rubelsanto, Alta Verapaz
MGRT|Retalhuleu Airport / Base Aérea del Sur|Retalhuleu, Retalhuleu
MGSJ|San José Airport|Puerto San José, Escuintla
MGSM|San Marcos Airport|San Marcos, San Marcos
MGTK|Mundo Maya International Airport (Santa Elena)|Flores, El Petén
MGZA|Zacapa Airport|Zacapa, Zacapa
MHAM|Amapala Airport (Los Pelonas)|Amapala
MHCA|Catacamas Airport|Catacamas
MHCC|Cenamer ACC/FIC|Cenamer
MHCG|Comayagua Airport|Comayagua
MHCH|Choluteca Airport|Choluteca
MHCT|Puerto Castilla Airport|Puerto Castilla
MHDU|Mocorón Airport (Durzona)|Mocorón
MHIC|Isla del Cisne Airport|Isla del Cisne
MHJU|Juticalpa Airport|Juticalpa
MHLC|Golosón International Airport|La Ceiba
MHLE|La Esperanza Airport|La Esperanza
MHLM|Ramón Villeda Morales International Airport|La Mesa (near San Pedro Sula) (MHSP)
MHMA|Marcala Airport|Marcala
MHNJ|Guanaja Airport|Guanaja
MHNV|Nuevo Ocotepeque Airport|Nuevo Ocotepeque
MHOA|Olanchito Airport|Olanchito
MHPE|El Progreso Airport|El Progreso
MHPL|Puerto Lempira Airport|Puerto Lempira
MHPU|Puerto Cortes Airport|Puerto Cortes
MHRO|Juan Manuel Gálvez International Airport (Roatán Intl)|Roatán
MHRU|Ruinas de Copan Airport|Ruinas de Copan
MHSB|Santa Bárbara Airport|Santa Bárbara (MHSZ)
MHSC|Palmerola Air Base (Coronel Enrique Soto Cano Air Base)|Comayagua (MHPA/ENQ)
MHSR|Santa Rosa de Copán Airport|Santa Rosa de Copán
MHTG|Toncontín International Airport|Tegucigalpa
MHTJ|Trujillo Airport|Trujillo
MHTL|Tela Airport|Tela (MHTE)
MHUT|Útila Airport|Útila
MHYR|Yoro Airport|Yoro
MKBS|Boscobel Aerodrome|Ocho Rios
MKJP|Norman Manley International Airport|Kingston
MKJS|Sangster International Airport|Montego Bay
MKKJ|Ken Jones Airport|Port Antonio
MKNG|Negril Airport|Negril
MKTP|Tinson Pen Airport|Kingston
MMAA|General Juan N. Álvarez International Airport|Acapulco, Guerrero
MMAS|Lic. Jesús Terán Peredo International Airport|Aguascalientes, Aguascalientes
MMBT|Bahías de Huatulco International Airport|Huatulco, Oaxaca
MMCB|General Mariano Matamoros Airport|Cuernavaca, Morelos
MMCC|Ciudad Acuña International Airport|Ciudad Acuña, Coahuila
MMCE|Ciudad del Carmen International Airport|Ciudad del Carmen, Campeche
MMCL|Federal de Bachigualato International Airport|Culiacán, Sinaloa
MMCM|Chetumal International Airport|Chetumal, Quintana Roo
MMCN|Ciudad Obregón International Airport|Ciudad Obregón, Sonora
MMCP|Ing. Alberto Acuña Ongay International Airport|Campeche, Campeche
MMCS|Abraham González International Airport|Ciudad Juárez, Chihuahua
MMCU|General Roberto Fierro Villalobos International Airport|Chihuahua, Chihuahua
MMCV|General Pedro J. Méndez National Airport|Ciudad Victoria, Tamaulipas
MMCY|Captain Rogelio Castillo National Airport|Celaya, Guanajuato
MMCZ|Cozumel International Airport|Cozumel, Quintana Roo
MMDO|General Guadalupe Victoria International Airport|Durango, Durango
MMEP|Amado Nervo National Airport|Tepic, Nayarit
MMES|Ensenada Airport|Ensenada, Baja California
MMGL|Don Miguel Hidalgo y Costilla International Airport|Guadalajara, Jalisco
MMGM|General José María Yáñez International Airport|Guaymas, Sonora
MMGR|Guerrero Negro Airport|Guerrero Negro, Baja California Sur
MMHO|General Ignacio Pesqueira Garcia International Airport|Hermosillo, Sonora
MMIA|Lic. Miguel de la Madrid Airport|Colima, Colima
MMIO|Plan de Guadalupe International Airport|Saltillo, Coahuila
MMJA|El Lencero Airport|Jalapa (Xalapa), Veracruz
MMLC|Lázaro Cárdenas Airport|Lázaro Cárdenas, Michoacán
MMLM|Federal del Valle del Fuerte International Airport|Los Mochis, Sinaloa
MMLO|Aeropuerto Internacional de Guanajuato (known as Del Bajío)|Silao, Guanajuato
MMLP|Manuel Márquez de León International Airport|La Paz, Baja California Sur
MMLT|Loreto International Airport|Loreto, Baja California Sur
MMMA|General Servando Canales International Airport|Matamoros, Tamaulipas
MMMD|Manuel Crescencio Rejón International Airport|Mérida, Yucatán
MMML|General Rodolfo Sánchez Taboada International Airport|Mexicali, Baja California
MMMM|General Francisco J. Mujica International Airport|Morelia, Michoacán
MMMT|Minatitlán/Coatzacoalcos National Airport|Minatitlán, Veracruz
MMMV|Venustiano Carranza International Airport|Monclova, Coahuila
MMMX|Lic. Benito Juárez International Airport|Mexico City, Distrito Federal
MMMY|General Mariano Escobedo International Airport|Monterrey, Nuevo León
MMMZ|General Rafael Buelna International Airport|Mazatlán, Sinaloa
MMNL|Quetzalcóatl International Airport|Nuevo Laredo, Tamaulipas
MMOX|Xoxocotlán International Airport|Oaxaca, Oaxaca
MMPA|El Tajín National Airport|Poza Rica, Veracruz
MMPB|Hermanos Serdán International Airport|Puebla, Puebla
MMPG|Piedras Negras International Airport|Piedras Negras, Coahuila
MMPN|Lic. y Gen. Ignacio López Rayón Airport|Uruapan, Michoacán
MMPR|Lic. Gustavo Díaz Ordaz International Airport|Puerto Vallarta, Jalisco
MMPS|Puerto Escondido International Airport|Puerto Escondido, Oaxaca
MMQT|Ing. Fernando Espinoza Gutiérrez International Airport|Querétaro, Querétaro
MMRX|General Lucio Blanco International Airport|Reynosa, Tamaulipas
MMSC|San Cristóbal de las Casas National Airport (Aeropuerto Nacional de San Cristóbal de las Casas)|Chiapas
MMSD|Los Cabos International Airport|Los Cabos, Baja California Sur
MMSL|Cabo San Lucas International Airport|Cabo San Lucas, Baja California Sur
MMSP|Ponciano Arriaga International Airport|San Luis Potosí, San Luis Potosí
MMTC|Francisco Sarabia International Airport a.k.a. Torreón International Airport|Torreón, Coahuila
MMTG|Francisco Sarabia National Airport a.k.a. Angel Albino Corzo Airport|Tuxtla Gutiérrez, Chiapas
MMTJ|General Abelardo L. Rodríguez International Airport|Tijuana, Baja California
MMTM|General Francisco Javier Mina International Airport|Tampico, Tamaulipas
MMTN|Tamuín National Airport|Tamuín, San Luis Potosí
MMTO|Lic. Adolfo López Mateos International Airport|Toluca, Estado de México
MMTP|Tapachula International Airport|Tapachula, Chiapas
MMUN|Cancún International Airport|Cancún, Quintana Roo
MMVA|Carlos Rovirosa Pérez International Airport|Villahermosa, Tabasco
MMVR|General Heriberto Jara International Airport|Veracruz, Veracruz
MMZC|General Leobardo C. Ruiz International Airport a.k.a. La Calera Airport|Zacatecas, Zacatecas
MMZH|Ixtapa-Zihuatanejo International Airport|Ixtapa-Zihuatanejo, Guerrero
MMZO|Playa de Oro International Airport|Manzanillo, Colima
MNAL|Alamikamba Airport|Alamikamba, RAAN (Zelaya)
MNAM|Altmira Airport|Altmira, Boaco
MNBC|Boaco Airport|Boaco, Boaco
MNBL|Bluefields Airport|Bluefields, RAAS (Zelaya)
MNBR|Los Brasiles Airport|Los Brasiles, Managua
MNBZ|Bonanza Airport (San Pedro)|Bonanza, RAAN (Zelaya)
MNCH|Chinandega Airport|Chinandega, Chinandega
MNCI|Corn Island Airport|Corn Island, RAAS (Zelaya)
MNCT|Corinto Airport|Corinto, Chinandega
MNDM|Dos Montes Airport|Dos Montes, León
MNEP|La Esperanza Airport|La Esperanza, RAAS (Zelaya)
MNES|Estelí Airport|Estelí, Estelí
MNFC|Punta Huete Airport (Panchito)|Punta Huete, Managua
MNFF|El Bluff Airport|El Bluff, RAAS (Zelaya)
MNFM|Fertimar Airport|Fertimar, Chontales
MNHG|Hato Grande Airport|Hato Grande, Chontales
MNJG|Jinotega Airport|Jinotega, Jinotega
MNJU|Juigalpa Airport|Juigalpa, Chontales
MNKW|Karawala Airport|Karawala, RAAS (Zelaya)
MNLL|Las Lajas Airport|Las Lajas, Granada
MNLN|León Airport (Fanor Urroz)|León, León
MNLP|La Paloma Airport|La Paloma, Rivas
MNMA|Macantaca Airport|Macantaca (Makantaca), RAAN (Zelaya)
MNMG|Managua International Airport (Augusto Cesar Sandino Intl)|Managua, Managua
MNMR|Montelimar Airport|Montelimar, Managua
MNNG|Nueva Guinea Airport|Nueva Guinea, RAAS (Zelaya)
MNPC|Puerto Cabezas Airport|Puerto Cabezas, RAAN (Zelaya)
MNPP|El Papalonal Airport|El Papalonal, León
MNPR|Palo Ralo Airport|Palo Ralo, Río San Juan
MNRS|Rivas Airport|Rivas, Rivas
MNRT|Rosita Airport|Rosita, RAAN (Zelaya)
MNSC|San Carlos Airport|San Carlos, Río San Juan
MNSI|Siuna Airport|Siuna, RAAN (Zelaya)
MNWP|Waspam Airport|Waspam, RAAN (Zelaya)
MPBO|Bocas del Toro "Isla Colon" International Airport|Bocas del Toro
MPCE|Herrera Alonso Valderrama Airport|Chitre
MPCH|Captain Manuel Niño International Airport|Changuinola
MPDA|Enrique Malek International Airport|David
MPEJ|Enrique Adolfo Jiménez Airport|Colón
MPFS|Fort Sherman|Fuerte Sherman
MPHO|Howard Air Force Base|Balboa
MPJE|Jaque Airport|Jaque
MPLB|Albrook AFS|Balboa
MPLP|Captain Ramon Xatruch Airport|La Palma
MPMG|Albrook "Marcos A. Gelabert" International Airport|Panama City
MPNU|Augusto Vergara Airport|Los Santos
MPOA|Puerto Obaldia Airport|Puerto Obaldia
MPRH|Captain Scarlet Martinez Airport|Rio Hato
MPSA|Ruben Cantu Airport|Santiago
MPTO|Tocumen International Airport|Panama City
MPVR|El Porvenir Airport|El Porvenir
MPWN|San Blas Airport|Wannukandi
MRAN|La Fortuna Airport|La Fortuna
MRAO|Tortuguero Airport|Tortuguero
MRBA|Buenos Aires Airport|Buenos Aires
MRBC|Barra del Colorado Airport|Barra del Colorado
MRCA|Codela Airport|Cañas
MRCC|Coto 47 Airport|Coto 47
MRCH|Chacarita Airport|Chacarita
MRCR|Carrillo Airport|Carrillo
MRCV|Cabo Velas Airport|Cabo Velas
MRDK|Drake Bay Airport|Drake Bay
MRDO|Dieciocho Airport (military)|Dieciocho
MREC|El Carmen de Siquirres Airport|El Carmen de Siquirres
MRFI|Nuevo Palmar Sur Airport|Nuevo Palmar Sur
MRFL|Flamingo Airport (Costa Rica)|Flamingo
MRFS|Finca 63 Airport|Finca 63
MRGF|Golfito Airport|Golfito
MRGP|Guápiles Airport|Guápiles
MRIA|Punta Islita Airport|Punta Islita
MRLB|Daniel Oduber International Airport|Liberia
MRLC|Los Chiles Airport|Los Chiles
MRLE|Laurel Airport|Laurel
MRLF|La Flor Airport|La Flor
MRLM|Limón International Airport|Limón
MRLP|Las Piedras Airport|Las Piedras
MRLT|Las Trancas Airport|Las Trancas
MRNC|Nicoya Guanacaste Airport|Nicoya Guanacaste
MRNS|Nosara Airport|Nosara
MROC|Juan Santamaría International Airport|San José
MRPA|Palo Arco Airport|Palo Arco
MRPD|Pandora Airport|Pandora
MRPJ|Puerto Jimenez Airport|Puerto Jimenez
MRPM|Palmar Sur Airport|Palmar Sur
MRPV|Tobías Bolaños International Airport|San José
MRQP|La Managua Airport|Quepos
MRRF|Rio Frio O Progreso Airport|Rio Frio O Progreso
MRSA|San Alberto Airport|San Alberto
MRSG|Santa Clara de Guapiles Airport|Santa Clara de Guapiles
MRSL|Salama Airport|Salama
MRSO|Santa Maria de Guacimo Airport|Santa Maria de Guacimo
MRSV|San Vito de Java Airport|San Vito de Java
MRTM|Tamarindo Airport|Tamarindo
MRTR|Tambor Airport|Tambor
MRUP|Upala Airport|Upala
MSBS|Barrillas Airport|Barrillas
MSCB|La Cabana Airport|La Cabana
MSCD|Ceiba Doblada Airport|Ceiba Doblada
MSCH|La Chepona Airport|La Chepona
MSCM|Corral De Mulas Airport|Corral De Mulas
MSCN|Cumichin Airport|Cumichin
MSCR|La Carrera Airport|La Carrera
MSCS|Las Cachas Airport|Las Cachas
MSEJ|El Jocotillo Airport|El Jocotillo
MSER|Entre Rios Airport|Entre Rios
MSES|Espiritu Santo Airport|Espiritu Santo
MSET|El Tamarindo Airport|El Tamarindo
MSLD|Los Comandos Airport|Los Comandos (San Francisco Gotera)
MSLP|El Salvador International Airport|San Salvador
MSPP|El Papalon Airport|El Papalon
MSPT|El Platanar Airport|El Platanar
MSRC|El Ronco Airport|El Ronco
MSSA|El Palmer Airport|Santa Ana
MSSC|Santa Clara Airport|Santa Clara
MSSJ|Punta San Juan Airport|Punta San Juan
MSSM|San Miguel Airport (El Papalon)|San Miguel
MSSS|Ilopango International Airport|San Salvador
MSZT|El Zapote Airport|El Zapote
MTCA|Les Cayes Airport|Les Cayes
MTCH|Cap-Haitien International Airport|Cap-Haitien
MTJA|Jacmel Airport|Jacmel
MTJE|Jérémie Airport|Jérémie
MTPP|Port-au-Prince International Airport (Toussaint Louverture Int'l)|Port-au-Prince
MTPX|Port-de-Paix Airport|Port-de-Paix
MUBA|Gustavo Rizo Airport|Baracoa
MUBR|Las Brujas Airport|Las Brujas
MUBY|Carlos Manuel de Cespedes Airport|Bayamo
MUCA|Maximo Gomez International Airport|Ciego de Ávila
MUCB|Caibarien Airport|Caibarién
MUCC|Jardines del Rey Airport|Cunagua, Cayo Coco
MUCF|Jaime González Airport|Cienfuegos
MUCL|Vilo Acuña Airport|Cayo Largo del Sur
MUCM|Ignacio Agramonte International Airport|Camagüey
MUCU|Antonio Maceo International Airport|Santiago
MUFL|Florida Airport|Florida
MUGM|NAS Guantanamo Bay|Guantánamo Bay
MUGT|Mariana Grajales Airport|Guantánamo
MUHA|José Martí International Airport|Havana
MUHG|Frank País Airport|Holguín
MUKW|Kawama Airport|Kawama
MULB|Ciudad Libertad Airport|Havana
MULM|La Coloma Airport|Pinar del Río
MUMG|Managua Airport|Managua
MUML|Mariel Airport|Mariel
MUMO|Orestes Acosta Airport|Moa
MUMZ|Sierra Maestra Airport|Manzanillo
MUNB|San Nicolas de Bari Airport|San Nicolas de Bari
MUNC|Nicaro Airport|Nicaro
MUNG|Rafael Cabrera Airport|Nueva Gerona
MUOC|Cayo Coco Airport|Cayo Coco
MUPB|Playa Baracoa Airport|Havana
MUPR|Pinar del Río Norte Airport|Pinar del Río Norte
MUSA|San Antonio de los Banos Airport|San Antonio de los Baños
MUSC|Abel Santa María Airport|Santa Clara
MUSJ|San Julian Air Base|Pinar del Río
MUSL|Santa Lucia Airport|Playa Santa Lucia
MUSN|Siguanea Airport|Isla de la Juventud
MUSS|Sancti Spiritus Airport|Sancti Spíritus
MUTD|Alberto Delgado Airport|Trinidad
MUVR|Juan Gualberto Gomez International Airport|Varadero
MUVT|Hermanos Ameijeiras Airport|Las Tunas
MWCB|Gerrard Smith International Airport|Cayman Brac
MWCG|Grand Cayman Airport|Grand Cayman
MWCL|Edward Bodden Airfield (Little Cayman Airport)|Little Cayman
MWCR|Owen Roberts International Airport|Georgetown, Grand Cayman
MYAB|Clarence A. Bain Airport|Andros
MYAF|Andros Town International Airport|Andros Town, Andros
MYAG|Gorda Cay Airport (private)|Gorda Cay, Abaco
MYAK|Congo Town Airport|Congo Town, Andros
MYAM|Marsh Harbour Airport|Marsh Harbour, Abaco
MYAN|San Andros Airport|Andros
MYAO|Mores Island Airport|Mores Island, Abaco
MYAP|Spring Point Airport|Spring Point, Acklins
MYAS|Sandy Point Airport|Sandy Point, Abaco
MYAT|Treasure Cay Airport|Treasure Cay, Abaco
MYAW|Walker Cay Airport|Walker Cay, Abaco
MYAX|Spanish Cay Airport|Spanish Cay, Abaco
MYBC|Chub Cay International Airport|Chub Cay, Berry Islands
MYBG|Great Harbour Cay Airport|Great Harbour Cay, Berry Islands
MYBO|Ocean Cay Airport|Ocean Cay, Bimini
MYBS|South Bimini Airport|South Bimini, Bimini
MYBW|Big Whale Cay Airport|Big Whale Cay, Berry Islands
MYBX|Lt. Whale Cay Airport|Lt. Whale Cay, Berry Islands
MYCA|Arthur's Town Airport|Arthur's Town, Cat Island
MYCB|New Bight Airport|New Bight, Cat Island
MYCC|Cat Cay Airport|Cat Cay, Bimini
MYCH|Hawks Nest Airport|Hawks Nest, Cat Island
MYCI|Colonial Hill Airport|Colonial Hill, Crooked Island
MYCP|Pitts Town Airport|Pitts Town, Crooked Island
MYCS|Cay Sal Airport (private)|Cay Sal
MYCX|Cutlass Bay Airport|Cutlass Bay, Cat Island
MYEB|Black Point Airport|Black Point, Exuma
MYEC|Cape Eleuthera Airport (closed)|Cape Eleuthera, Eleuthera
MYEF|Exuma International Airport|Great Exuma Island, Exuma
MYEH|North Eleuthera Airport|North Eleuthera, Eleuthera
MYEL|Lee Stocking Airport|Lee Stocking, Exuma
MYEM|Governor's Harbour Airport|Governor's Harbour, Eleuthera
MYEN|Norman's Cay Airport|Norman's Cay, Exuma
MYER|Rock Sound International Airport|Rock Sound, Eleuthera
MYES|Staniel Cay Airport|Staniel Cay, Exuma
MYEY|Hog Cay Airport|Hog Cay, Exuma
MYGF|Grand Bahama International Airport (Freeport Int'l)|Freeport, Grand Bahama
MYGW|West End Airport|Grand Bahama
MYIG|Inagua Airport (Matthew Town Airport)|Matthew Town, Inagua
MYLD|Deadman's Cay Airport|Deadman's Cay, Long Island
MYLM|Cape Santa Maria Airport|Cape Santa Maria, Long Island
MYLR|Hard Bargain Airport|Long Island
MYLS|Stella Maris Airport|Long Island
MYMM|Mayaguana Airport|Mayaguana
MYNN|Lynden Pindling International Airport (Nassau Intl)|Nassau, New Providence
MYPI|New Providence Airport|Paradise Island, New Providence
MYRD|Duncan Town Airport|Duncan Town, Ragged Island
MYRP|Port Nelson Airport|Port Nelson, Rum Cay
MYSM|San Salvador Airport (Cockburn Town Airport)|Cockburn Town, San Salvador Island
MZBZ|Philip S. W. Goldson International Airport|Belize City
NCAI|Aitutaki Airport (Araura Airport)|Aitutaki (Araura)
NCAT|Enua Airport|Atiu (Enua Manu)
NCMG|Mangaia Airport|Mangaia (Auau Enua)
NCMH|Manihiki Island Airport|Manihiki (Humphrey Island)
NCMK|Mauke Airport|Mauke (Akatoka Manava)
NCMN|Manuae airstrip|Manuae Island
NCMR|Mitiaro Airport (Nukuroa Airport)|Mitiaro (Nukuroa)
NCPY|Tongareva Airport|Penrhyn Island (Tongareva)
NCRG|Rarotonga International Airport|Avarua, Rarotonga
NFCI|Cicia Airport|Cicia
NFCS|Castaway Island Airport|Castaway Island (Qalito), Mamanuca Islands
NFFA|Ba Airport|Ba, Viti Levu
NFFN|Nadi International Airport|Nadi, Viti Levu
NFFO|Malolo Lailai Airport|Malolo Lailai
NFFR|Rabi Airport|Rabi
NFKB|Kaibu airstrip|Kaibu Island
NFKD|Vunisea Airport|Vunisea (Namalata), Kadavu
NFMA|Mana Island Airport|Mana Island
NFMO|Moala Airport|Moala
NFNA|Nausori International Airport|Suva, Viti Levu
NFNB|Levuka Airfield|Bureta
NFND|Pacific Harbour / Deumba SPB|Pacific Harbour / Deuba, Viti Levu
NFNG|Ngau Airport|Ngau (Gau), Ngau Island
NFNH|Laucala Airport|Laucala Island (Lauthala Island)
NFNK|Lakemba Airport|Lakeba (Lakemba)
NFNL|Lambasa Airport|Labasa (Lambasa), Vanua Levu
NFNM|Taveuni Island Airport|Matei, Taveuni
NFNO|Koro Airport|Koro
NFNR|Rotuma Island Airport|Rotuma
NFNS|Savu Savu Airport|Savu Savu
NFNU|Bua Airport|Bua, Vanua Levu
NFNV|Vatukoula Airport|Vatukoula, Viti Levu
NFNW|Wakaya Airport|Wakaya
NFOL|Ono-i-Lau Airport|Ono-i-Lau
NFSW|Yasawa Airport|Yasawa
NFVB|Vanuabalavu Airport|Vanua Balavu (Vanuabalavu)
NFVL|Vatulele Airport|Vatulele
NFTE|Eua Airport|Eua
NFTF|Fuaʻamotu International Airport|Nukuʻalofa, Tongatapu
NFTL|Lifuka Island Airport (Salote Pilolevu Airport)|Lifuka, Ha'apai
NFTO|Mata'aho Airport|Niuafo'ou
NFTP|Niuatoputapu Airport (Kuini Lavenia Airport)|Niuatoputapu
NFTV|Vava'u International Airport (Lupepau'u Airport)|Vava'u
NGAB|Abaiang Atoll Airport|Abaiang
NGBR|Beru Island Airport|Beru Island
NGKT|Kuria Airport|Kuria
NGMA|Maiana Airport|Maiana
NGMK|Marakei Airport|Marakei
NGMN|Makin Airport|Makin
NGNU|Nikunau Airport|Nikunau
NGON|Onotoa Airport|Onotoa
NGTA|Bonriki International Airport|Tarawa
NGTB|Abemama Atoll Airport|Abemama
NGTE|Tabiteuea North Airport|Tabiteuea North
NGTM|Tamana Airport|Tamana
NGTO|Nonouti Airport|Nonouti
NGTR|Arorae Island Airport|Arorae
NGTS|Tabiteuea South Airport|Tabiteuea South
NGTU|Butaritari Atoll Airport|Butaritari
NGUK|Aranuka Airport|Aranuka
NGFU|Funafuti International Airport|Funafuti
NIUE|Niue Hanan International Airport|Alofi
NLWF|Futuna - Pointe Vele Airport (Maopoop Airport)|Futuna Island
NLWW|Hihifo Airport|Wallis Island
NSAU|Asau Airport|Asau
NSFA|Faleolo International Airport|Apia
NSFI|Fagali'i Airport|Fagali'i
NSMA|Maota Airport|Salelologa
NSAS|Ofu airstrip|Ofu Island
NSFQ|Fitiuta Airport|Fitiuta
NSTU|Pago Pago International Airport (Tutuila Intl)|Pago Pago
NTAA|Faa'a International Airport|Faa'a, Tahiti
NTAR|Rurutu Airport|Rurutu, Austral Islands
NTAT|Tubuai Airport|Tubuai, Austral Islands
NTGA|Anaa Airport|Anaa, Tuamotus
NTGB|Fangatau Airport|Fangatau, Tuamotus
NTGC|Tikehau Airport|Tikehau
NTGD|Apataki Airport|Apataki, Tuamotus
NTGE|Reao Island Airport|Reao, Tuamotus
NTGF|Fakarava Airport|Fakarava
NTGH|Hikueru Airport|Hikueru, Tuamotus
NTGI|Manihi Airport|Manihi, Tuamotus
NTGJ|Totegegie Airport|Totegegie, Gambier Islands
NTGK|Kaukura Airport|Kaukura Atoll
NTGM|Makemo Airport|Makemo, Tuamotus
NTGN|Napuka Airport|Napuka, Disappointment Islands
NTGO|Tatakoto Airport|Tatakoto
NTGP|Puka-Puka Airport|Puka-Puka, Tuamotus
NTGQ|Pukarua Airport|Pukarua, Tuamotus
NTGT|Takapoto Airport|Takapoto, Tuamotus
NTGU|Arutua Airport|Arutua
NTGV|Mataiva Airport|Mataiva, Tuamotus
NTGW|Nukutavake Airport|Nukutavake
NTKH|Fakahina Airport|Fakahina
NTKN|Niau Airport|Niau
NTKO|Raroia Airport|Raroia
NTKR|Takaroa Airport|Takaroa
NTMD|Nuku-Hiva Airport|Nuku Hiva, Marquesas Islands
NTMN|Atuona Airport|Hiva Oa, Marquesas Islands
NTMP|Ua Pou Airport|Marquesas Islands
NTMU|Ua-Huka Airport|Ua Huka, Marquesas Islands
NTTB|Bora Bora Airport (Motu-Mute Airport)|Bora Bora, located on Moto Mute
NTTE|Tetiaroa Airport|Society Islands
NTTG|Rangiroa Airport|Rangiroa, Tuamotus
NTTH|Fare Airport|Huahine, Leeward Islands (Society Islands)
NTTM|Temae Airport|Moorea, Windward Islands (Society Islands)
NTTO|Hao Airport|Hao Island
NTTP|Maupiti Airport|Maupiti
NTTR|Uturoa Airport|Raiatea, Society Islands
NTUV|Vahitahi Airport|Vahitahi
NVSC|Vanua Lava Island Airport|Sola
NVSE|Siwo Airport|Émaé
NVSF|Craig Cove Airport|Craig Cove
NVSG|Longana Airport|Longana
NVSH|Sara Airport|Sara
NVSL|Malekoula Island Airport|Lamap
NVSM|Lamen Bay Airport|Lamen-Bay
NVSN|Maewo-Naone Airport|Maewo-Naone
NVSO|Lonorore Airport|Lonorore
NVSP|Norsup Airport|Norsup
NVSR|Redcliff Airport|Redcliff
NVSS|Santo-Pekoa International Airport|Luganville, Espiritu Santo
NVST|Tongoa Airport|Tongoa
NVSU|Ulei Airport|Ulei
NVSV|Valesdir Airport|Valesdir
NVSW|Walaha Airport|Walaha
NVSX|South West Bay Airport|South West Bay
NVVB|Aniwa Airport|Aniwa
NVVD|Dillon's Bay Airport|Dillon's Bay
NVVF|Futuna Airport|Futuna
NVVI|Ipota Airport|Ipota
NVVQ|Quoin Hill Airport|Quoin Hill
NVVV|Bauerfield International Airport|Port Vila
NVVW|White Grass Airport|Tanna
NWWA|Tiga Airport|Tiga Island
NWWC|Belep Islands Airport|Waala, Belep
NWWD|Kone Airport|Koné
NWWE|Moue Airport|L'Île-des-Pins
NWWH|Nesson Airport|Houailou
NWWK|Koumac Airport|Koumac
NWWL|Ouanaham Airport (Wanaham Airport)|Lifou
NWWM|Nouméa Magenta Airport|Nouméa
NWWO|Ile Ouen/Edmond Cane Airport|Ile Ouen
NWWP|Poum Airport|Poum
NWWQ|Nickel Airport|Mueo
NWWR|La Roche Airport|Maré
NWWT|La Foa - Oua Tom Airport|La Foa
NWWU|Touho Airport|Touho
NWWV|Ouloup Airport|Ouvéa
NWWW|La Tontouta International Airport|Nouméa
NWWX|Canala Airport|Canala
NZAA|Auckland Airport|Auckland
NZAL|Avalon Heliport|Lower Hutt, Wellington
NZAP|Taupo Airport|Taupo
NZAR|Ardmore Airport|Auckland
NZAS|Ashburton Aerodrome|Ashburton
NZAU|Waiouru Airfield|Waiouru
NZBA|Balclutha Aerodrome|Balclutha
NZBC|ASB Bank Centre Heliport|Auckland
NZBW|Burwood Hospital Heliport|Christchurch
NZCH|Christchurch International Airport|Christchurch
NZCI|Chatham Islands / Tuuta Airport|Chatham Islands
NZCS|Cromwell Racecourse Aerodrome|Cromwell
NZCX|Coromandel Aerodrome|Coromandel Peninsula, North Island
NZDA|Dargaville Aerodrome|Dargaville
NZDC|Dunedin City Heliport|Dunedin
NZDH|Dunedin Hospital Heliport|Dunedin
NZDN|Dunedin International Airport|Mosgiel, Dunedin
NZDV|Dannevirke Aerodrome|Dannevirke
NZFF|Forest Field Aerodrome|Rangiora
NZFI|Feilding Aerodrome|Feilding
NZFJ|Franz Josef Aerodrome|Franz Josef Village
NZFP|Foxpine Aerodrome|Foxton
NZGA|Galatea Aerodrome|Galatea
NZGB|Great Barrier Aerodrome|Great Barrier Island
NZGC|Gore Aerodrome|Gore
NZGI|Garden City Heliport|Christchurch
NZGM|Greymouth Aerodrome|Greymouth
NZGR|Great Mercury Aerodrome|Great Mercury Island
NZGS|Gisborne Airport|Gisborne
NZGT|Glentanner Aerodrome|Lake Pukaki
NZGY|Glenorchy Aerodrome|Glenorchy
NZHA|Hawera Aerodrome|Hawera
NZHK|Hokitika Aerodrome|Hokitika
NZHN|Hamilton International Airport|Hamilton
NZHR|Hanmer Springs Aerodrome|Hanmer Springs
NZHS|Hastings Aerodrome|Hastings
NZHT|Haast Aerodrome|Haast
NZIR|McMurdo Sea ice runway|Antarctica
NZJA|Tauranga Hospital Heliport|Tauranga
NZJC|Christchurch Hospital Heliport|Christchurch
NZJE|Dargaville Hospital Heliport|Dargaville
NZJG|Gisborne Hospital Heliport|Gisborne
NZJH|Hastings Hospital Heliport|Hastings
NZJI|Bay of Islands Heliport|Kerikeri
NZJK|Kaitaia Hospital Heliport|Kaitaia
NZJL|Auckland Hospital Heliport|Auckland
NZJM|Palmerston North Hospital Heliport|Palmerston North
NZJO|Rotorua Hospital Heliport|Rotorua
NZJQ|Taranaki Base Hospital Heliport|New Plymouth
NZJR|Whangarei Hospital Heliport|Whangarei
NZJS|Southland/Kew Hospital Heliport|Invercargill
NZJT|Taumarunui Hospital Heliport|Taumarunui
NZJU|Wanganui Hospital Heliport|Wanganui
NZJY|Wairoa Hospital Heliport|Wairoa
NZJZ|Taupo Hospital Heliport|Taupo
NZKE|Waiheke Island Aerodrome|Waiheke Island
NZKF|Kaipara Flats Aerodrome|Kaipara District
NZKI|Kaikoura Aerodrome|Kaikoura
NZKK|Kerikeri/Bay of Islands Airport|Kerikeri / Bay of Islands
NZKM|Karamea Aerodrome|Karamea
NZKO|Kaikohe Aerodrome|Kaikohe
NZKT|Kaitaia Airport|Kaitaia
NZLT|Lake Taupo Water|Lake Taupo
NZLX|Alexandra Aerodrome|Alexandra
NZMA|Matamata Aerodrome|Matamata
NZMB|Mechanics Bay Heliport|Auckland
NZMC|Mount Cook Aerodrome|Aoraki/Mount Cook
NZME|Mercer Aerodrome|Mercer
NZMF|Milford Sound Airport|Milford Sound
NZMH|Masterton Hospital Heliport|Masterton
NZMK|Motueka Aerodrome|Motueka
NZMO|Manapouri Aerodrome|Te Anau / Manapouri
NZMR|Murchison Aerodrome|Murchison
NZMS|Masterton Aerodrome|Masterton
NZMT|Martinborough Aerodrome|Martinborough
NZMW|Makarora Aerodrome|Makarora
NZNE|North Shore Aerodrome|Auckland
NZNH|Nelson Hospital Heliport|Nelson
NZNP|New Plymouth Airport|New Plymouth
NZNR|Napier Airport|Napier
NZNS|Nelson Airport|Nelson
NZNV|Invercargill Airport|Invercargill
NZOA|Omarama Aerodrome|Omarama
NZOH|Ohakea Airbase (RNZAF)|Ohakea
NZOM|Omaka Aerodrome|Blenheim
NZOP|Opotiki Aerodrome|Opotiki
NZOU|Oamaru Aerodrome|Oamaru
NZPA|Paihia Heliport|Paihia
NZPG|Pegasus blue ice runway|Antarctica
NZPI|Parakai Aerodrome|Parakai
NZPM|Palmerston North International Airport|Palmerston North
NZPN|Picton Aerodrome|Picton - Koromiko
NZPP|Paraparaumu Airport|Paraparaumu
NZQN|Queenstown Airport|Queenstown
NZQW|Queens Wharf Heliport|Wellington
NZRA|Raglan Aerodrome|Raglan
NZRC|Ryans Creek Aerodrome|Half Moon Bay, Stewart Island
NZRK|Rangitaiki Aerodrome|Rangitaiki
NZRO|Rotorua Airport|Rotorua
NZRT|Rangiora Aerodrome|Rangiora
NZRU|Waiouru Airbase (NZ Army)|Waiouru
NZRW|Ruawai Aerodrome|Ruawai
NZRX|Roxburgh Aerodrome|Roxburgh
NZSD|Stratford Aerodrome|Stratford
NZSP|Amundsen-Scott South Pole Station|Antarctica
NZTG|Tauranga Airport|Tauranga
NZTH|Thames Aerodrome|Thames
NZTK|Takaka Aerodrome|Takaka
NZTL|Tekapo Aerodrome|Tekapo
NZTM|Taumarunui Aerodrome|Taumarunui
NZTN|Turangi Aerodrome|Turangi
NZTO|Tokoroa Aerodrome|Tokoroa
NZTT|Te Kuiti Aerodrome|Te Kuiti
NZTU|Richard Pearse Airport|Timaru
NZTZ|Te Anau Aerodrome|Te Anau
NZUK|Pukaki Aerodrome|Twizel
NZUN|Pauanui Beach Aerodrome|Pauanui
NZVL|Mandeville Aerodrome|Mandeville, Gore
NZVR|Taihape Aerodrome|Taihape
NZWB|Woodbourne Airport|Blenheim (ICAO code also listed as NZBM)
NZWD|Williams Field|Antarctica
NZWF|Wanaka Airport|Wanaka
NZWG [DEL:|Wigram Aerodrome|Wigram, Christchurch :DEL] closed March 1, 2009
NZWH|Wellington Hospital Heliport|Wellington
NZWK|Whakatane Aerodrome|Whakatane
NZWM|Waimate Aerodrome|Waimate
NZWN|Wellington International Airport|Wellington
NZWO|Wairoa Aerodrome|Wairoa
NZWP|RNZAF Base Auckland|Auckland
NZWR|Whangarei Airport|Whangarei
NZWL|West Melton Aerodrome|West Melton
NZWS|Westport Airport|Westport
NZWT|Whitianga Aerodrome|Whitianga
NZWU|Wanganui Airport|Wanganui
NZWV|Waihi Beach Aerodrome|Waihi Beach
NZYP|Waipukurau Aerodrome|Waipukurau
OABN|Bamyan Airport|Bamyan
OABT|Bost Airport|Bost
OACC|Chaghcharan Airport|Chaghcharan
OADZ|Darwaz Airport|Darwaz
OAFR|Farah Airport|Farah
OAFZ|Faizabad Airport|Faizabad
OAHN|Khwahan Airport|Khwahan
OAHR|Herat Airport|Herat
OAIX|Bagram Air Base|Bagram near Charikar
OAJL|Jalalabad Airport|Jalalabad
OAKB|Kabul International Airport|Kabul
OAKN|Kandahar Airport|Kandahar
OAKS|Khost Airport|Khost
OAMN|Maymana Airport|Maymana
OAMS|Mazar Airport|Mazari Sharif
OAQN|Qala i Naw Airport|Qala i Naw
OASN|Sheghnan Airport|Sheghnan
OATN|Tereen Airport|Tereen
OATQ|Taloqan Airport|Taloqan
OAUZ|Kunduz Airport|Kunduz
OAZJ|Zaranj Airport|Zaranj
OBBI|Bahrain International Airport|Manama
OBBS|Sheik Isa Air Base|
OEAA|Abu Ali Airport|Jubail
OEAB|Abha Regional Airport|Abha
OEAH|al-Ahsa Domestic Airport|Al-Ahsa
OEBA|al-Baha Domestic Airport|al-Baha
OEBH|Bisha Domestic Airport|Bisha
OEBQ|Abqaiq Airport|Abqaiq
OEDF|King Fahd International Airport|Dammam
OEDR|King Abdulaziz Air Base (formerly Dhahran International Airport)|Dhahran
OEDW|Dawadmi Domestic Airport|Dawadmi
OEGN|Gizan Regional Airport|Gizan (also known as Jizan or Jazan)
OEGS|Gassim Regional Airport|Gassim (also known as al Gassim or al Qasim)
OEGT|Gurayat Domestic Airport|Gurayat (also known as Guriat)
OEHL|Ha'il Regional Airport|Ha'il
OEHR|Haradh Airport|Haradh
OEJB|Jubail Airport|Jubail
OEJN|King Abdulaziz International Airport|Jeddah
OEKK|Hafr al-Batin Domestic Airport (KKMC) - limited civilian flights|KKMC
OEKM|King Khalid Airbase (KKMC) - RSAF|KKMC
OEMA|Prince Mohammad Bin Abdulaziz Airport|Medina
OENG|Najran Domestic Airport|Najran (also known as Nejran)
OEPA|Qaisumah Domestic Airport|Qaisumah (also known as Qaysumah)
OERF|Rafha Domestic Airport|Rafha
OERK|King Khalid International Airport|Riyadh
OERM|Ras Al-Mishab Airport|Ras Al-Mishab
OERR|Arar Domestic Airport|Arar (also known as Ar'ar)
OERT|Ras Tanura Airport|Ras Tanura
OESB|Shaybah Airport|Shaybah
OESH|Sharurah Domestic Airport|Sharurah (also known as Sharorah)
OESK|al-Jouf Domestic Airport|al-Jouf (also known as al-Jawf)
OETB|Tabuk Regional Airport|Tabuk
OETF|Ta’if Regional Airport|Ta’if
OETH|Thumamah Airport|Ath Thumamah
OETN|Tanajib Airport|Tanajib
OETR|Turaif Domestic Airport|Turaif
OEUD|Udhayliyah Airport|Udhayliyah
OEWD|Wadi al-Dawasir Domestic Airport|Wadi al-Dawasir
OEWJ|Wedjh Domestic Airport|Wedjh (also known as Wejh)
OEYN|Yanbu Domestic Airport|Yanbu (also known as Yenbo)
OIAA|Abadan Airport|Abadan
OIAD|Dezful Airport|Dezful
OIAJ|Omidiyeh Air Base|Omidiyeh
OIAM|Mahshahr Airport|Mahshahr
OIAW|Ahvaz Airport|Ahwaz
OIBB|Bushehr Airport|Bushehr
OIBI|Asalouyeh Airport|Asalouyeh
OIBK|Kish Airport|Kish Island
OIBL|Bandar Lengeh Airport|Bandar Lengeh
OIBP|Persian Gulf Airport|Khalije Fars
OIBQ|Khark Airport|Khark Island
OIBS|Sirri Island Airport|Sirri Island
OIBV|Lavan Airport|Lavan Island
OICC|Shahid Ashrafi Esfahani Airport|Kermanshah
OICI|Ilam Airport|Ilam
OICK|Khorramabad Airport|Khorramabad
OICS|Sanandaj Airport|Sanandaj
OIFM|Isfahan International Airport (Esfahan Shahid Beheshti Int'l)|Isfahan (Esfahan)
OIFS|Shahrekord Airport|Shahrekord
OIGG|Rasht Airport|Rasht
OIHH|Hamadan Airport|Hamadan
OIHS|Hamedan Air Base‎ (Shahrokhi Air Base‎)|Hamadan
OIID|Doshan Tappeh Air Base|Tehran
OIIE|Imam Khomeini International Airport|Tehran
OIII|Mehrabad International Airport|Tehran
OIKB|Bandar Abbas International Airport|Bandar Abbas
OIKJ|Jiroft Airport|Jiroft
OIKK|Kerman Airport|Kerman
OIKM|Bam Airport|Bam
OIKQ|Dayrestan Airport|Qeshm
OIKR|Rafsanjan Airport|Rafsanjan
OIKY|Sirjan Airport|Sirjan
OIMB|Birjand Airport|Birjand
OIMC|Sarakhs Airport|Sarakhs
OIMM|Mashhad International Airport (Shahid Hashemi Nejad Airport)|Mashhad
OIMN|Bojnourd Airport|Bojnourd
OIMS|Sabzevar Airport|Sabzevar
OIMT|Tabas Airport|Tabas
OING|Gorgan Airport|Gorgan
OINN|Noshahr Airport|Noshahr
OINR|Ramsar Airport|Ramsar
OINZ|Dasht-e Naz Airport|Sari
OISL|Larestan International Airport|Lar
OISR|Lamerd Airport|Lamerd
OISS|Shiraz International Airport (Shiraz Shahid Dastghaib Int'l)|Shiraz
OISY|Yasuj Airport|Yasuj
OITK|Khoy Airport|Khoy
OITL|Ardabil Airport|Ardabil
OITP|Parsabad-Moghan Airport|Parsabad
OITR|Urmia Airport|Urmia
OITT|Tabriz International Airport|Tabriz
OIYY|Shahid Sadooghi Airport|Yazd
OIZB|Zabol Airport|Zabol
OIZC|Konarak Airport|Chah Bahar
OIZH|Zahedan International Airport|Zahedan
OJAI|Queen Alia International Airport|Amman
OJAM|Marka International Airport|Amman
OJAQ|Aqaba International Airport (King Hussein International Airport)|Aqaba
OKAJ|Ahmed Al Jaber Air Base|
OKAS|Ali Al Salem Air Base|
OKBK|Kuwait International Airport|Al-Maqwa, near Kuwait City
OLBA|Beirut Air Base/Rafic Hariri International Airport (Beirut International)|Beirut
OLKA|Rene Mouawad Air Base|Kleyate
OLRA|Rayak Air Base|Rayak
OMAA|Abu Dhabi International Airport|Abu Dhabi
OMAD|Bateen Airport|Abu Dhabi
OMAL|Al Ain International Airport|Al Ain
OMAM|Al Dhafra Air Base|Muqatra
OMDB|Dubai International Airport|Dubai
OMFJ|Fujairah International Airport|Fujairah
OMRK|Ras Al Khaimah International Airport|Ras al-Khaimah
OMSJ|Sharjah International Airport|Sharjah
OOKB|Khasab Air Base|Khasab
OOMA|Masirah Air Base|Masirah
OOMS|Seeb International Airport|Muscat
OONR|Marmul Airport|Marmul
OOSA|Salalah Airport|Salalah
OOTH|Thumrait Air Base|Thumrait
OPAB|Abbottabad|
OPBN|Bannu Airport|Bannu
OPBW|Bahawalpur Airport|Bahawalpur
OPCH|Chitral Airport|Chitral
OPCL|Chilas Airport|Chilas
OPDB|Dalbandin Airport|Dalbandin
OPDG|Dera Ghazi Khan Airport|Dera Ghazi Khan
OPDI|Dera Ismail Khan Airport|Dera Ismail Khan
OPFA|Faisalabad International Airport|Faisalabad
OPGD|Gwadar International Airport|Gwadar
OPGT|Gilgit Airport|Gilgit
OPJA|Jacobabad Airbase|Jacobabad
OPJI|Jiwani Airport|Jiwani
OPKC|Jinnah International Airport|Karachi
OPKD|Hyderabad Airport|Hyderabad
OPKH|Khuzdar Airport|Khuzdar
OPKT|Kohat Airbase|Kohat
OPLA|Allama Iqbal International Airport|Lahore
OPLH|Walton Airport|Lahore
OPMA|Mangla Airport|Mangla
OPMF|Muzaffarabad Airport|Muzaffarabad
OPMI|Mianwali Airbase|Mianwali
OPMJ|Moenjodaro Airport|Mohenjo-daro
OPMP|Sindhri Airport|Sindhri Tharparkar
OPMR|Masroor Airbase|Karachi
OPMS|Minhas, Kamara Airbase|Kamra
OPMT|Multan International Airport|Multan
OPNH|Nawabshah Airport|Nawabshah
OPOR|Ormara Airport|Ormara
OPPC|Parachinar Airport|Parachinar
OPPG|Panjgur Airport|Panjgur
OPPI|Pasni Airport|Pasni City
OPPS|Peshawar International Airport|Peshawar
OPQS|Dhamial Army Airbase|Rawalpindi
OPQT|Quetta International Airport|Quetta
OPRK|Shaikh Zayed International Airport|Rahim Yar Khan
OPRN|Islamabad International Airport/Chaklala Airbase|Islamabad
OPRQ|Rafiqui Airbase|Shorkot
OPRT|Rawalakot Airport|Rawalakot
OPSB|Sibi Airport|Sibi
OPSD|Skardu Airport|Skardu
OPSK|Sukkur Airport|Sukkur
OPSN|Sehwan Sharif Airport|Sehwan Sharif
OPSR|Mushaf Airbase|Sargodha
OPSS|Saidu Sharif Airport|Saidu Sharif
OPST|Sialkot International Airport|Sialkot
OPSU|Sui Airport|Sui
OPSW|Sahiwal Airport|Sahiwal
OPTA|Tarbela Dam Airport|Tarbela Dam
OPTU|Turbat Airport|Turbat
OPZB|Zhob Airport|Zhob
ORAA|Al Asad Airbase|Al Anbar
ORAI|Al Iskandariyah Airport|
ORAN|An Numaniyah Airport|
ORAT|Al Taqaddum Airbase|Al Anbar
ORBD|Balad Southeast Airport|Al Bakr
ORBI|Baghdad International Airport|Baghdad (changed from ORBS in 2003)
ORBM|Mosul International Airport|Mosul
ORBR|Bashur Airport|Bashur
ORER|Erbil International Airport|Erbil (Hewlêr),
ORJA|Jalibah Southeast Airport|Jalibah
ORKK|Kirkuk Airport|Kirkuk
ORMM|Basrah International Airport|Basrah
ORQT|Qasr Tall Mihl|
ORQW|Qayyarah West Airport|Qayyarah
ORSH|Al Sahra AAF|Tikrit
ORSU|Sulaimaniyah International Airport|Sulaimaniyah (Silêmanî), Iraqi Kurdistan
ORTF|Tall Afar AAF|Tall Afar
ORTI|Al Taji AAF|Al Taji
ORTK|Tikrit East Airport|Tikrit
ORTL|Ali Air Base (formerly Tallil Air Base)|Nasiriyah
ORTS|Tikrit South Airport|Tikrit
ORUB|Ubaydah Bin Al Jarrah Airport|Al Kut
ORUQ|Umm Qasr Airport|Umm Qasr
OSAP|Aleppo International Airport|Aleppo
OSDI|Damascus International Airport|Damascus
OSDZ|Deir ez-Zor Airport|Deir ez-Zor
OSKL|Kamishly Airport|Kamishly
OSLK|Bassel Al-Assad International Airport|Latakia
OSPR|Palmyra Airport|Palmyra
OTBD|Doha International Airport|Doha
OTBH|Al Udeid Air Base|Doha
OYAA|Aden International Airport|Aden
OYAB|Abbs Airport|Abbs
OYAT|Ataq Airport|Ataq
OYBN|Beihan Airport|Beihan
OYBQ|Al-Bough Airport|Al-Bough
OYGD|Al-Ghaidah Airport|Al-Ghaidah
OYHD|Hodeidah International Airport|Hodeidah
OYMB|Marib Airport|Marib
OYMK|Mukeiras Airport|Mukeiras
OYQN|Qishn Airport|Qishn
OYRN|Riyan Airport|Mukalla
OYSH|Saadah Airport|Saadah
OYSN|Sana'a International Airport|Sana'a
OYSQ|Moori Airport|Socotra
OYSY|Sayun Airport|Sayun
OYTZ|Ta'izz International Airport|Taiz
PAAK|Atka Airport (FAA: AKA)|Atka, Alaska
PAAL|Port Moller Air Force Station (FAA: 1AK3)|Cold Bay, Alaska
PAAM|Driftwood Bay Air Force Station (FAA: AK23)|Dutch Harbor, Alaska
PAAN|Gold King Creek Airport (FAA: AK7)|Fairbanks, Alaska
PAAP|Port Alexander Seaplane Base (FAA: AHP)|Port Alexander, Alaska
PAAQ|Palmer Municipal Airport|Palmer, Alaska
PAAT|Casco Cove Coast Guard Station|Attu Island, Alaska
PABA|Barter Island LRRS Airport|Barter Island, Alaska
PABE|Bethel Airport|Bethel, Alaska
PABG|Beluga Airport (FAA: BLG)|Beluga, Alaska
PABI|Allen Army Airfield (formerly Big Delta Army Airfield)|Fort Greely / Delta Junction, Alaska
PABL|Buckland Airport (FAA: BVK)|Buckland, Alaska
PABM|Big Mountain Air Force Station (FAA: 37AK)|Big Mountain, Alaska
PABN|Devils Mountain Lodge Airport (FAA: IBN)|Nabesna, Alaska
PABR|Wiley Post-Will Rogers Memorial Airport|Barrow, Alaska
PABT|Bettles Airport|Bettles, Alaska
PABU|Bullen Point Air Force Station (FAA: 8AK7)|Kaktovik, Alaska
PABV|Birchwood Airport (FAA: BCV)|Birchwood, Alaska
PACA|Cape Spencer Coast Guard Heliport|Cape Spencer, Alaska
PACD|Cold Bay Airport|Cold Bay, Alaska
PACE|Central Airport|Central, Alaska
PACH|Chuathbaluk Airport (FAA: 9A3)|Chuathbaluk, Alaska
PACI|Chalkyitsik Airport|Chalkyitsik, Alaska
PACK|Chefornak Airport (FAA: CFK)|Chefornak, Alaska
PACL|Clear Airport / Clear Air Force Station (FAA: Z84)|Clear, Alaska
PACM|Scammon Bay Airport|Scammon Bay, Alaska
PACR|Circle City Airport (FAA: CRC)|Circle, Alaska
PACS|Cape Sarichef Airport (FAA: 26AK)|Cape Sarichef, Alaska
PACV|Merle K. (Mudhole) Smith Airport|Cordova, Alaska
PACX|Coldfoot Airport|Coldfoot, Alaska
PACY|Yakataga Airport|Cape Yakataga, Alaska
PACZ|Cape Romanzof LRRS Airport|Cape Romanzof, Alaska
PADE|Deering Airport (FAA: DEE)|Deering, Alaska
PADG|Red Dog Airport (FAA: DGG)|Red Dog Mine, Alaska
PADK|Adak Airport (Mitchell Field)|Adak Island, Alaska
PADL|Dillingham Airport|Dillingham, Alaska
PADM|Marshall Don Hunter Sr. Airport (FAA: MDM)|Marshall, Alaska
PADQ|Kodiak Airport|Kodiak, Alaska
PADT|Duffy's Tavern Airport (FAA: DDT)|Slana, Alaska
PADU|Unalaska Airport (Tom Madsen Airport)|Unalaska, Alaska
PADY|Kongiganak Airport (FAA: DUY)|Kongiganak, Alaska
PAED|Elmendorf Air Force Base|Anchorage, Alaska
PAEE|Eek Airport|Eek, Alaska
PAEG|Eagle Airport|Eagle, Alaska
PAEH|Cape Newenham LRRS Airport|Cape Newenham, Alaska
PAEI|Eielson Air Force Base|Fairbanks, Alaska
PAEL|Elfin Cove Seaplane Base|Elfin Cove, Alaska
PAEM|Emmonak Airport (FAA: ENM)|Emmonak, Alaska
PAEN|Kenai Municipal Airport|Kenai, Alaska
PAEW|Newtok Airport (FAA: EWU)|Newtok, Alaska
PAFA|Fairbanks International Airport|Fairbanks, Alaska
PAFB|Ladd Army Airfield (Fort Wainwright AAF)|Fairbanks, Alaska / Fort Wainwright
PAFE|Kake Airport (FAA: AFE)|Kake, Alaska
PAFK|Farewell Lake Seaplane Base (FAA: FKK)|Farewell Lake, Alaska
PAFL|Tin Creek Airport (FAA: TNW)|Farewell Lake, Alaska
PAFM|Ambler Airport (FAA: AFM)|Ambler, Alaska
PAFR|Bryant Army Heliport (has a runway)|Fort Richardson
PAFS|Nikolai Airport (FAA: FSP)|Nikolai, Alaska
PAFV|Five Mile Airport (FAA: FVM)|Five Mile, Alaska
PAFW|Farewell Airport|Farewell, Alaska
PAGA|Edward G. Pitka Sr. Airport|Galena, Alaska
PAGB|Galbraith Lake Airport|Galbraith Lake, Alaska
PAGG|Kwigillingok Airport (FAA: GGV)|Kwigillingok, Alaska
PAGH|Shungnak Airport|Shungnak, Alaska
PAGK|Gulkana Airport|Gulkana, Alaska
PAGL|Golovin Airport (FAA: N93)|Golovin, Alaska
PAGM|Gambell Airport|Gambell, Alaska
PAGN|Angoon Seaplane Base|Angoon, Alaska
PAGQ|Big Lake Airport|Big Lake, Alaska
PAGS|Gustavus Airport|Gustavus, Alaska
PAGT|Nightmute Airport (FAA: IGT)|Nightmute, Alaska
PAGY|Skagway Airport|Skagway, Alaska
PAHC|Holy Cross Airport (FAA: HCA)|Holy Cross, Alaska
PAHL|Huslia Airport (FAA: HLA)|Huslia, Alaska
PAHN|Haines Airport|Haines, Alaska
PAHO|Homer Airport|Homer, Alaska
PAHP|Hooper Bay Airport|Hooper Bay, Alaska
PAHU|Hughes Airport|Hughes, Alaska
PAHV|Healy River Airport (FAA: HRR)|Healy, Alaska
PAHX|Shageluk Airport|Shageluk, Alaska
PAHY|Hydaburg Seaplane Base|Hydaburg, Alaska
PAIG|Igiugig Airport|Igiugig, Alaska
PAII|Egegik Airport (FAA: EII)|Egegik, Alaska
PAIK|Bob Baker Memorial Airport|Kiana, Alaska
PAIL|Iliamna Airport|Iliamna, Alaska
PAIM|Indian Mountain LRRS Airport|Indian Mountain, Alaska
PAIN|McKinley National Park Airport (FAA: INR)|McKinley Park, Alaska
PAIW|Wales Airport (FAA: IWK)|Wales, Alaska
PAJC|Chignik Airport (FAA: AJC)|Chignik, Alaska
PAJN|Juneau International Airport|Juneau, Alaska
PAJO|Johnstone Point Airport (FAA: 2AK5)|Hinchinbrook, Alaska
PAJV|Jonesville Mine Airport (FAA: JVM)|Sutton, Alaska
PAJZ|Koliganek Airport (FAA: JZZ)|Koliganek, Alaska
PAKD|Kodiak Municipal Airport|Kodiak, Alaska
PAKF|False Pass Airport|Aleutians East Borough, Alaska
PAKH|Akhiok Airport|Akhiok, Alaska
PAKI|Kipnuk Airport (FAA: IIK)|Kipnuk, Alaska
PAKK|Koyuk Alfred Adams Airport|Koyuk, Alaska
PAKL|Kulik Lake Airport|Kulik Lake, Alaska
PAKN|King Salmon Airport|King Salmon, Alaska
PAKO|Nikolski Air Station|Nikolski, Alaska
PAKP|Anaktuvuk Pass Airport|Anaktuvuk Pass, Alaska
PAKT|Ketchikan International Airport|Ketchikan, Alaska
PAKU|Ugnu-Kuparuk Airport (FAA: UBW)|Kuparuk, Alaska
PAKV|Kaltag Airport|Kaltag, Alaska
PAKW|Klawock Airport (FAA: AKW)|Klawock, Alaska
PAKY|Karluk Airport|Karluk, Alaska
PALB|Larsen Bay Airport (FAA: 2A3)|Larsen Bay, Alaska
PALG|Kalskag Airport|Kalskag, Alaska
PALH|Lake Hood Seaplane Base (FAA: LHD)|Anchorage, Alaska
PALJ|Port Alsworth Airport (FAA: TPO)|Port Alsworth, Alaska
PALN|Lonely Air Station (FAA: AK71)|Lonely, Alaska
PALP|Alpine Airstrip (FAA: AK15)|Deadhorse, Alaska
PALR|Chandalar Lake Airport|Chandalar Lake, Alaska
PALU|Cape Lisburne LRRS Airport|Cape Lisburne, Alaska
PAMB|Manokotak Airport (FAA: MBA)|Manokotak, Alaska
PAMC|McGrath Airport|McGrath, Alaska
PAMD|Middleton Island Airport|Middleton Island, Alaska
PAMH|Minchumina Airport|Lake Minchumina, Alaska
PAMK|St. Michael Airport|St. Michael, Alaska
PAML|Manley Hot Springs Airport|Manley Hot Springs, Alaska
PAMM|Metlakatla Seaplane Base|Metlakatla, Alaska
PAMO|Mountain Village Airport|Mountain Village, Alaska
PAMR|Merrill Field|Anchorage, Alaska
PAMX|McCarthy Airport (FAA: 15Z)|McCarthy, Alaska
PAMY|Mekoryuk Airport|Mekoryuk, Alaska
PANA|Napakiak Airport|Napakiak, Alaska
PANC|Ted Stevens Anchorage International Airport|Anchorage, Alaska
PANI|Aniak Airport|Aniak, Alaska
PANN|Nenana Municipal Airport|Nenana, Alaska
PANO|Nondalton Airport (FAA: 5NN)|Nondalton, Alaska
PANR|Funter Bay Seaplane Base|Funter Bay, Alaska
PANT|Annette Island Airport|Annette Island, Alaska
PANU|Nulato Airport|Nulato, Alaska
PANV|Anvik Airport|Anvik, Alaska
PANW|New Stuyahok Airport|New Stuyahok, Alaska
PAOB|Kobuk Airport|Kobuk, Alaska
PAOC|Portage Creek Airport (FAA: A14)|Portage Creek, Alaska
PAOH|Hoonah Airport|Hoonah, Alaska
PAOM|Nome Airport|Nome, Alaska
PAOO|Toksook Bay Airport|Toksook Bay, Alaska
PAOR|Northway Airport|Northway, Alaska
PAOT|Ralph Wien Memorial Airport|Kotzebue, Alaska
PAOU|Nelson Lagoon Airport (FAA: OUL)|Nelson Lagoon, Alaska
PAPB|St. George Airport (FAA: PBV)|St. George, Alaska
PAPC|Port Clarence Coast Guard Station|Port Clarence, Alaska
PAPE|Perryville Airport (FAA: PEV)|Perryville, Alaska
PAPG|Petersburg James A. Johnson Airport|Petersburg, Alaska
PAPH|Port Heiden Airport|Port Heiden, Alaska
PAPK|Napaskiak Airport|Napaskiak, Alaska
PAPM|Platinum Airport|Platinum, Alaska
PAPN|Pilot Point Airport (FAA: PNP)|Pilot Point, Alaska
PAPO|Point Hope Airport|Point Hope, Alaska
PAPR|Prospect Creek Airport|Prospect Creek, Alaska
PAQC|Klawock Seaplane Base (FAA: AQC)|Klawock, Alaska
PAQH|Quinhagak Airport (FAA: AQH)|Quinhagak, Alaska
PAQT|Nuiqsut Airport (FAA: AQT)|Nuiqsut, Alaska
PARC|Arctic Village Airport|Arctic Village, Alaska
PARS|Russian Mission Airport|Russian Mission, Alaska
PARY|Ruby Airport|Ruby, Alaska
PASA|Savoonga Airport|Savoonga, Alaska
PASC|Deadhorse Airport|Deadhorse, Alaska
PASD|Sand Point Airport|Sand Point, Alaska
PASH|Shishmaref Airport|Shishmaref, Alaska
PASI|Sitka Rocky Gutierrez Airport|Sitka, Alaska
PASK|Selawik Airport|Selawik, Alaska
PASL|Sleetmute Airport|Sleetmute, Alaska
PASM|St. Mary's Airport|St. Mary's, Alaska
PASN|St. Paul Island Airport|St. Paul Island, Alaska
PASO|Seldovia Airport|Seldovia, Alaska
PASP|Sheep Mountain Airport|Sheep Mountain, Alaska
PAST|Summit Airport|Summit, Alaska
PASV|Sparrevohn LRRS Airport|Sparrevohn, Alaska
PASW|Skwentna Airport|Skwentna, Alaska
PASX|Soldotna Airport|Soldotna, Alaska
PASY|Eareckson Air Station|Shemya Island, Alaska
PATA|Ralph M. Calhoun Memorial Airport|Tanana, Alaska
PATC|Tin City LRRS Airport|Tin City, Alaska
PATE|Teller Airport (FAA: TER)|Teller, Alaska
PATG|Togiak Airport|Togiak, Alaska
PATJ|Tok Airport|Tok, Alaska
PATK|Talkeetna Airport|Talkeetna, Alaska
PATL|Tatalina LRRS Airport|Tatalina, Alaska
PATQ|Atqasuk Edward Burnell Sr. Memorial Airport|Atqasuk, Alaska
PATW|Cantwell Airport (FAA: TTW)|Cantwell, Alaska
PAUK|Alakanuk Airport|Alakanuk, Alaska
PAUM|Umiat Airport|Umiat, Alaska
PAUN|Unalakleet Airport|Unalakleet, Alaska
PAUO|Willow Airport (FAA: UUO)|Willow, Alaska
PAVA|Chevak Airport|Chevak, Alaska
PAVC|King Cove Airport|King Cove, Alaska
PAVD|Valdez Airport (Pioneer Field)|Valdez, Alaska
PAVE|Venetie Airport|Venetie, Alaska
PAVL|Kivalina Airport|Kivalina, Alaska
PAWB|Beaver Airport|Beaver, Alaska
PAWD|Seward Airport|Seward, Alaska
PAWG|Wrangell Airport|Wrangell, Alaska
PAWI|Wainwright Airport (FAA: AWI)|Wainwright, Alaska
PAWM|White Mountain Airport|White Mountain, Alaska
PAWN|Noatak Airport|Noatak, Alaska
PAWR|Whittier Airport (FAA: IEM)|Whittier, Alaska
PAWS|Wasilla Airport (FAA: IYS)|Wasilla, Alaska
PAWT|Wainwright Air Station (FAA: AK03)|Wainwright, Alaska
PAXK|Paxson Airport (FAA: PXK)|Paxson, Alaska
PAYA|Yakutat Airport|Yakutat, Alaska
PFAK|Akiak Airport|Akiak, Alaska
PFAL|Allakaket Airport (FAA: 6A8)|Allakaket, Alaska
PFCB|Chenega Bay Airport (FAA: C05)|Chenega, Alaska
PFCL|Clarks Point Airport|Clarks Point, Alaska
PFEL|Elim Airport|Elim, Alaska
PFKA|Kasigluk Airport (FAA: Z09)|Kasigluk, Alaska
PFKK|Kokhanok Airport (FAA: 9K2)|Kokhanok, Alaska
PFKO|Kotlik Airport (FAA: 2A9)|Kotlik, Alaska
PFKT|Brevig Mission Airport|Brevig Mission, Alaska
PFKU|Koyukuk Airport|Koyukuk, Alaska
PFKW|Kwethluk Airport|Kwethluk, Alaska
PFNO|Robert (Bob) Curtis Memorial Airport (FAA: D76)|Noorvik, Alaska
PFSH|Shaktoolik Airport (FAA: 2C7)|Shaktoolik, Alaska
PFTO|Tok Junction Airport (FAA: 6K8)|Tok, Alaska
PFWS|South Naknek Nr 2 Airport|South Naknek, Alaska
PFYU|Fort Yukon Airport|Fort Yukon, Alaska
POLI|Oliktok LRRS Airport|Oliktok Point, Alaska
PPIZ|Point Lay LRRS Airport|Point Lay, Alaska
PCIS|Canton Airfield (abandoned)|Canton Island
PGUA|Andersen Air Force Base|Agana
PGUM|Antonio B. Won Pat International Airport (Guam International)|Agana
PGRO|Rota International Airport (FAA: GRO)|Rota Island
PGSN|Saipan International Airport (Francisco C. Ada) (FAA: GSN)|Saipan Island
PGWT|Tinian International Airport (West Tinian) (FAA: TNI)|Tinian Island
PHDH|Dillingham Airfield|Waialua, Hawaii
PHHF|French Frigate Shoals Airport|Tern Island, French Frigate Shoals, Hawaii
PHHI|Wheeler Army Airfield|Wahiawa, Hawaii
PHHN|Hana Airport|Hana, Hawaii
PHIK|Hickam AFB|Honolulu, Hawaii
PHJH|Kapalua Airport (Kapalua West Mau'i Airport)|Lahaina, Hawaii
PHJR|Kalaeloa Airport (John Rodgers Field)|Kapolei, Hawaii
PHKO|Kona International Airport|Kailua-Kona, Hawaii
PHLI|Lihu'e Airport|Lihue, Hawaii
PHLU|Kalaupapa Airport|Kalaupapa, Hawaii
PHMK|Molokai Airport|Kaunakakai, Hawaii
PHMU|Waimea-Kohala Airport|Kamuela, Hawaii
PHNL|Honolulu International Airport|Honolulu, Hawaii
PHNY|Lanai Airport|Lanai City, Hawaii
PHOG|Kahului Airport|Kahului, Hawaii
PHTO|Hilo International Airport|Hilo, Hawaii
PHUP|Upolu Airport|Hawi, Hawaii
PKMA|Enewetak Auxiliary Airfield|Enewetak
PKMJ|Marshall Islands International Airport (Amata Kabua Int'l)|Majuro
PKRO|Dyess Army Airfield (Freeflight International Airport)|Roi-Namur
PKWA|Kwajalein Airport|Kwajalein
PLCH|Cassidy International Airport|Kiritimati (Christmas Island)
PLPA|Palmyra (Cooper) Airport|Palmyra Atoll
PMDY|Henderson Field (Naval Air Facility)|Sand Island
PTKK|Chuuk International Airport|Weno, Chuuk
PTPN|Pohnpei International Airport|Pohnpei
PTSA|Kosrae International Airport (FAA: TTK)|Kosrae
PTYA|Yap International Airport (FAA: T11)|Yap
PTRO|Palau International Airport (Babelthuap/Koror Airport)|Airai, Palau
PWAK|Wake Island Airfield|
RCBS|Kinmen Airport|Kinmen
RCCM|Cimei Airport|Cimei
RCFG|Matsu Nangan Airport|Nangan
RCFN|Taitung Airport|Taitung
RCGI|Lyudao Airport|Lyudao
RCKH|Kaohsiung International Airport|Kaohsiung City
RCKU|Chiayi Airport|Chiayi
RCKW|Hengchun Airport|Hengchun
RCLY|Lanyu Airport|Lanyu (Orchid Island)
RCMQ|Taichung Airport|Taichung
RCMT|Matsu Beigan Airport|Matsu Islands
RCNN|Tainan Airport|Tainan City
RCPO|Hsinchu Air Base|Hsinchu
RCQC|Makung Airport|Makung
RCSQ|Pingtung Airport|Pingtung
RCSS|Taipei Songshan Airport|Taipei City
RCTP|Taiwan Taoyuan International Airport|Taipei
RCWA|Wangan Airport|Wang-an
RCYU|Hualien Airport|Hualien
RJAA|Narita International Airport (Old name : New Tokyo International Airport)|Narita, Chiba
RJAF|Matsumoto Airport|Matsumoto, Nagano
RJAH|Hyakuri Airfield (military base; civil aviation facility under construction; to open as Ibaraki Airport)|Omitama, Ibaraki
RJAM|Minami Torishima Airport|Ogasawara, Tokyo (Minami Torishima)
RJAN|Niijima Airport|Niijima, Tokyo
RJAW|Iwo Jima Air Base|Ogasawara, Tokyo (Iwo Jima)
RJAZ|Kozushima Airport|Kozushima, Tokyo
RJBB|Kansai International Airport|Izumisano, Osaka
RJBD|Nanki-Shirahama Airport|Shirahama, Wakayama
RJBE|Kobe Airport|Kobe, Hyōgo
RJBH|Hiroshima-Nishi Airport|Hiroshima, Hiroshima
RJBT|Tajima Airport|Toyooka, Hyōgo
RJCB|Obihiro Airport (Tokachi-Obihiro)|Obihiro, Hokkaido
RJCC|New Chitose Airport|Chitose, Hokkaido (near Sapporo)
RJCH|Hakodate Airport|Hakodate, Hokkaido
RJCJ|Chitose Air Base (was Chitose Airport until 1988)|Chitose, Hokkaido (near Sapporo)
RJCK|Kushiro Airport|Kushiro, Hokkaido
RJCM|Memanbetsu Airport|Ozora, Hokkaido
RJCN|Nakashibetsu Airport|Nakashibetsu, Hokkaido
RJCO|Okadama Airport (Sapporo Airfield)|Sapporo, Hokkaido
RJCR|Rebun Airport|Rebun, Hokkaido
RJCT|Tokachi Airfield|Obihiro, Hokkaidō
RJCW|Wakkanai Airport|Wakkanai, Hokkaido
RJDA|Amakusa Airfield|Amakusa, Kumamoto
RJDB|Iki Airport|Iki, Nagasaki
RJDC|Yamaguchi Ube Airport|Ube, Yamaguchi
RJDK|Kamigoto Airport|Shinkamigotō, Nagasaki
RJDO|Ojika Airport (Nagasaki Ojika)|Ojika, Nagasaki
RJDT|Tsushima Airport|Tsushima, Nagasaki
RJEB|Monbetsu Airport (Okhotsk-Monbetsu)|Monbetsu, Hokkaido
RJEC|Asahikawa Airport|Higashikagura, Hokkaidō
RJEO|Okushiri Airport|Okushiri, Hokkaido
RJER|Rishiri Airport|Rishirifuji, Hokkaido
RJFC|Yakushima Airport|Yakushima, Kagoshima
RJFE|Fukue Airport|Gotō, Nagasaki
RJFF|Fukuoka Airport|Fukuoka, Fukuoka
RJFG|New Tanegashima Airport|Nakatane, Kagoshima
RJFK|Kagoshima Airport|Kirishima, Kagoshima
RJFM|Miyazaki Airport|Miyazaki, Miyazaki
RJFO|Oita Airport|Kunisaki, Ōita
RJFR|New Kitakyushu Airport|Kitakyushu, Fukuoka
RJFS|Saga Airport|Saga, Saga
RJFT|Kumamoto Airport|Mashiki, Kumamoto
RJFU|Nagasaki Airport|Omura, Nagasaki
RJGG|Chubu Centrair International Airport (Centrair)|Chita, Aichi
RJKA|Amami Airport|Amami, Kagoshima
RJKB|Okinoerabu Airport|Wadomari, Kagoshima
RJKI|Kikai Airport|Kikai, Kagoshima
RJKN|Tokunoshima Airport|Amagi, Kagoshima
RJNA|Nagoya Airfield (Prefectural Nagoya Airport)|Toyoyama, Aichi
RJNF|Fukui Airport|Sakai, Fukui
RJNH|Hamamatsu Air Base|Hamamatsu, Shizuoka
RJNK|Komatsu Airport|Komatsu, Ishikawa
RJNO|Oki Airport|Okinoshima, Shimane
RJNT|Toyama Airport|Toyama, Toyama
RJNW|Noto Airport|Wajima, Ishikawa
RJOA|Hiroshima Airport|Mihara, Hiroshima
RJOB|Okayama Airport|Okayama, Okayama
RJOC|Izumo Airport|Hikawa, Shimane
RJOH|Miho Airfield (Yonago Airport)|Sakaiminato, Tottori
RJOI|Marine Corps Air Station Iwakuni|Iwakuni, Yamaguchi
RJOK|Kochi Airport|Nankoku, Kochi
RJOM|Matsuyama Airport|Matsuyama, Ehime
RJOO|Osaka International Airport (Itami Airport)|Itami, Hyogo
RJOR|Tottori Airport|Tottori, Tottori
RJOS|Tokushima Airport|Matsushige, Tokushima
RJOT|Takamatsu Airport|Takamatsu, Kagawa
RJOW|Iwami Airport|Masuda, Shimane
RJOY|Yao Airport|Yao, Osaka
RJSA|Aomori Airport|Aomori, Aomori
RJSC|Yamagata Airport|Higashine, Yamagata
RJSD|Sado Airport|Sado, Niigata
RJSF|Fukushima Airport|Tamakawa, Fukushima
RJSI|Hanamaki Airport|Hanamaki, Iwate
RJSK|Akita Airport|Akita, Akita
RJSM|Misawa Air Base / Misawa Airport|Misawa, Aomori
RJSN|Niigata Airport|Niigata, Niigata
RJSR|Odate-Noshiro Airport (Akita-kita Airport)|Akita, Akita
RJSS|Sendai Airport|Natori, Miyagi
RJSU|Katsuminome Airport|Sendai, Miyagi
RJSY|Shonai Airport|Sakata, Yamagata
RJTA|Naval Air Facility Atsugi|Ayase, Kanagawa
RJTC|Tachikawa Airfield|Tachikawa, Tokyo
RJTF|Chofu Airport|Chōfu, Tokyo
RJTH|Hachijojima Airport|Hachijō, Tokyo
RJTK|Kisarazu Auxiliary Landing Field|Kisarazu, Chiba
RJTO|Oshima Airport|Ōshima, Tokyo
RJTQ|Miyakejima Airport|Miyake, Tokyo
RJTT|Tokyo International Airport (Haneda)|Ota, Tokyo
RJTY|Yokota Air Base|Fussa, Tokyo
ROAH|Naha Airport|Naha, Okinawa
RODN|Kadena Air Base|Okinawa, Okinawa
ROIG|Ishigaki Airport|Ishigaki, Okinawa
ROIT|Oitakenou Airport|Bungo-ōno, Ōita
ROKJ|Kumejima Airport|Kumejima, Okinawa
ROKR|Kerama Airport|Zamami, Okinawa
ROMD|Minami-Daito Airport|Minamidaito, Okinawa
ROMY|Miyako Airport|Miyakojima, Okinawa
RORA|Aguni Airport|Aguni, Okinawa
RORE|Iejima Airport|Ie, Okinawa
RORH|Hateruma Airport|Taketomi, Okinawa
RORK|Kita-Daito Airport|Kitadaito, Okinawa
RORS|Shimojishima Airport|Miyakojima, Okinawa
RORT|Tarama Airport|Tarama, Okinawa
RORY|Yoron Airport|Yoron, Kagoshima
ROTM|Marine Corps Air Station Futenma|Ginowan, Okinawa
ROYN|Yonaguni Airport|Yonaguni, Okinawa
RKJB|Muan International Airport|Muan
RKJJ|Gwangju Airport|Gwangju
RKJK|Gunsan Airport|Gunsan
RKJM|Mokpo Airport|Yeongam County (near Mokpo)
RKJK|Kunsan Air Base|Kunsan
RKJY|Yeosu Airport|Yeosu
RKND|Sokcho Airport|Sokcho
RKNN|Gangneung Airbase|Kangnung
RKNW|Wonju Airport|Wonju
RKNY|Yangyang International Airport|Yangyang County
RKPC|Jeju International Airport|Jeju
RKPK|Gimhae International Airport|Pusan
RKPS|Sacheon Airport|Sacheon
RKPU|Ulsan Airport|Ulsan
RKSI|Incheon International Airport|Incheon (near Seoul)
RKSM|Seoul Airbase|Seongnam
RKSO|Osan Air Base|Osan
RKSS|Gimpo International Airport|Seoul
RKTE|Seongmu Airport|Seongmu
RKTH|Pohang Airport|Pohang
RKTN|Daegu Airport|Daegu
RKTU|Cheongju Airport|Cheongju
RPEN|El Nido Airport [private]|El Nido, Palawan
RPLA|Pinamalayan Airport|Pinamalayan, Oriental Mindoro
RPLB|Subic Bay International Airport|Subic Bay Freeport Zone, Bataan
RPLC|Diosdado Macapagal International Airport (Clark International Airport)|Angeles City
RPLG|Wasig Airport|Mansalay, Oriental Mindoro
RPLI|Laoag International Airport|Laoag City, Ilocos Norte
RPLJ|Jomalig Airport|Jomalig, Quezon
RPLL|Ninoy Aquino International Airport (Manila International Airport)/Villamor Air Base [military]|Metro Manila
RPLN|Palanan Airport|Palanan, Isabela
RPLO|Cuyo Airport|Cuyo, Palawan
RPLP|Legazpi Airport|Legazpi City, Albay
RPLQ|Crow Valley Gunnery Range [military]|Capas, Tarlac
RPLR|Rosales Airport|Rosales, Pangasinan
RPLS|Atienza Air Base [military] (formerly U.S. Naval Station Sangley Point)|Cavite City, Cavite
RPLT|Itbayat Airport|Itbayat, Batanes
RPLU|Lubang Airport|Lubang, Occidental Mindoro
RPLV|Fort Magsaysay Airfield [military]|Palayan City, Nueva Ecija
RPLX|Kindley Landing Field (Corregidor)|Cavite City, Cavite
RPLY|Alabat Airport|Perez, Quezon
RPLZ|Sorsogon Airport|Sorsogon City, Sorsogon
RPMA|Allah Valley Airport|Surallah, South Cotabato
RPMB - Rajah Buayan Air Base [military]|General Santos City (formerly assigned to U.S. Naval Air Station Cubi Point, now RPLB - Subic Bay International Airport)|
RPMC|Awang Airport (Cotabato Airport)|Datu Odin Sinsuat, Maguindanao (formerly assigned to Cebu-Lahug Airport, now closed)
RPMD|Francisco Bangoy International Airport|Davao City
RPME|Bancasi Airport (Butuan Airport)|Butuan City
RPMF|Bislig Airport|Bislig City, Surigao del Sur
RPMG|Dipolog Airport|Dipolog City, Zamboanga del Norte
RPMH|Camiguin Airport|Mambajao, Camiguin
RPMI|Maria Cristina Airport (Iligan Airport)|Baloi, Lanao del Norte
RPMJ|Jolo Airport|Jolo, Sulu
RPMK|Tacurong Airport (Kenram Airport)|Tacurong City, Sultan Kudarat (formerly assigned to Clark Air Base, now RPLC - Diosdado Macapagal (Clark) International Airport)
RPML|Lumbia Airport (Cagayan de Oro Airport)|Cagayan de Oro City (formerly assigned to Laoag International Airport, now RPLI)
RPMM|Malabang Airport|Malabang, Lanao del Sur (formerly assigned to Ninoy Aqunio (Manila) International Airport, now RPLL)
RPMN|Sanga-Sanga Airport (Bongao Airport)|Bongao, Tawi-Tawi
RPMO|Labo Airport(Ozamiz Airport)|Ozamiz City, Misamis Occidental
RPMP|Pagadian Airport|Pagadian City, Zamboanga del Sur (formerly assigned to Legazpi Airport, now RPLP)
RPMQ|Imelda R. Marcos Airport (Mati Airport)|Mati, Davao Oriental
RPMR|General Santos International Airport|General Santos City (formerly assigned to an airfield in Romblon Island, now inactive)
RPMS|Surigao Airport|Surigao City, Surigao del Norte (formerly assigned to U.S. Naval Station Sangley Point, now RPLS - Atienza Air Base)
RPMT|Del Monte Plantation Airstrip [private]|Manolo Fortich, Bukidnon (formerly assigned to Mactan Air Base, now part of RPVM - Mactan-Cebu International Airport)
RPMU|Cagayan de Tawi-Tawi Airport|Mapun, Tawi-Tawi
RPMV|Ipil Airport|Ipil, Zamboanga Sibugay
RPMW|Tandag Airport|Tandag, Surigao del Sur
RPMX|Liloy Airport|Liloy, Zamboanga del Norte
RPMY|Malaybalay Airport|Malaybalay City, Bukidnon
RPMZ|Zamboanga International Airport|Zamboanga City
RPNO|Siocon Airport|Siocon, Zamboanga del Norte
RPNS|Sayak Airport (Siargao Airport)|Del Carmen, Surigao del Norte
RPOB|Pagbilao Grande Airport [private]|Pagbilao, Quezon
RPPN|Rancudo Airfield [military]|Kalayaan, Palawan
RPSB|Bantayan Airport|Santa Fe, Cebu
RPSD|Taytay-Sandoval Airport (Cesar Lim Rodriguez Airport)|Taytay, Palawan
RPSG|Sicogon Airport|Carles, Iloilo
RPSM|Panan-awan Airport|Maasin City, Southern Leyte
RPSN|Ubay Airport|Ubay, Bohol
RPSR|Semirara Airport [private]|Caluya, Antique
RPTP|Tarumpitao Point Airport|Rizal, Palawan
RPUA|Aparri Airport|Aparri, Cagayan
RPUB|Loakan Airport|Baguio City
RPUC|Cabanatuan Airport|Cabanatuan City, Nueva Ecija
RPUD|Bagasbas Airport|Daet, Camarines Norte
RPUE|Lucena Airport|Lucena City
RPUF|Basa Air Base [military]|Floridablanca, Pampanga
RPUG|Lingayen Airport|Lingayen, Pangasinan
RPUH|San Jose Airport|San Jose, Occidental Mindoro
RPUI|Iba Airport|Iba, Zambales
RPUJ|Castillejos Airfield [private]|Castillejos, Zambales
RPUK|Calapan Airport|Calapan City, Oriental Mindoro
RPUL|Fernando Air Base [military]|Lipa City, Batangas
RPUM|Mamburao Airport|Mamburao, Occidental Mindoro
RPUN|Naga Airport (Pili Airport)|Pili, Camarines Sur
RPUO|Basco Airport|Basco, Batanes
RPUP|Jose Panganiban Airport|Jose Panganiban, Camarines Norte
RPUQ|Mindoro Airport (Vigan Airport)|Vigan City, Ilocos Sur
RPUR|Baler Airport|Baler, Aurora
RPUS|San Fernando Airport (Poro Point Airport)|San Fernando City , La Union
RPUT|Tuguegarao Airport|Tuguegarao City, Cagayan
RPUU|Bulan Airport|Bulan, Sorsogon
RPUV|Virac Airport|Virac, Catanduanes
RPUW|Marinduque Airport|Gasan, Marinduque
RPUX|Plaridel Airport|Plaridel, Bulacan
RPUY|Cauayan Airport|Cauayan City, Isabela
RPUZ|Bagabag Airport|Bagabag, Nueva Vizcaya
RPVA|Daniel Z. Romualdez Airport (Tacloban Airport)|Tacloban City
RPVB|New Bacolod-Silay Airport|Silay City, Negros Occidental
RPVC|Calbayog Airport|Calbayog City, Samar
RPVD|Sibulan Airport (Dumaguete Airport)|Sibulan, Negros Oriental
RPVE|Caticlan Airport (Godofredo P. Ramos Airport)|Malay, Aklan
RPVF|Catarman National Airport|Catarman, Northern Samar
RPVG|Guiuan Airport|Guiuan, Eastern Samar
RPVH|Hilongos Airport|Hilongos, Leyte
RPVI|Iloilo International Airport|Cabatuan, Iloilo
RPVJ|Masbate Airport|Masbate City, Masbate
RPVK|Kalibo Airport|Kalibo, Aklan
RPVL|Roxas-del Pilar Airport|Roxas, Palawan
RPVM|Mactan-Cebu International Airport|Lapu-Lapu City
RPVN|Medellin Airport|Medellin, Cebu
RPVO|Ormoc Airport|Ormoc City
RPVP|Puerto Princesa Airport|Puerto Princesa City
RPVQ|Biliran Airport (Naval Airport)|Naval, Biliran
RPVR|Roxas Airport|Roxas City, Capiz
RPVS|Evelio Javier Airport (Antique Airport)|San Jose de Buenavista, Antique
RPVT|Tagbilaran Airport|Tagbilaran City, Bohol
RPVU|Tugdan Airport (Tablas/Romblon Airport)|Tablas, Romblon
RPVV|Francisco Reyes Airport (Busuanga Airport)|Coron, Palawan
RPVW|Borongan Airport|Borongan, Eastern Samar
RPVX|Dolores Airport|Dolores, Eastern Samar
RPVY|Catbalogan Airport|Catbalogan, Samar
RPVZ also RPSQ|Siquijor Airport|Siquijor, Siquijor
RPWV|Buenavista Airfield|Buenavista, Agusan del Norte
RPXX|used for civilian airports and airstrips with no ICAO code yet|
RPZZ|used for military airports and airstrips with no ICAO code yet|
RPAF|Nichols Field/Villamor Air Base (now part of RPLL - Ninoy Aquino International Airport)|
RPBY|Ubay Airport (now RPSN)|
RPCA|Catbalogan Airport (now RPVY)|
RPCU|Cuyo Airport (now RPLO)|
RPNA|Biliran Airport (now RPVQ)|
RPPA|Palanan Airport (now RPLN)|
RPSI|Sayak Airport (Siargao Airport) (now RPNS)|
RPWA|Alah Valley Airport (now RPMA)|
RPWC|Awang Airport (now RPMC)|
RPWD|Francisco Bangoy International Airport (now RPMD)|
RPWE|Bancasi Airport (Butuan Airport) (now RPME)|
RPWG|Dipolog Airport (now RPMG)|
RPWI|Labo Airport (Ozamiz Airport) (now RPMO)|
RPWJ|Jolo Airport (now RPMJ)|
RPWK|Tacurong Airport (now RPMK)|
RPWL|Lumbia Airport (now RPML)|
RPWM|Malabang Airport (now RPMM)|
RPWN|Sanga-Sanga Airport (now RPMN)|
RPWP|Pagadian Airport (now RPMP)|
RPWS|Surigao Airport (now RPMS)|
RPWT|Del Monte Plantation Airstrip (now RPMT)|
RPWW|Tandag Airport (now RPMW)|
RPWX|Maria Cristina Airport (now RPMI)|
RPWY|Malaybalay Airport (now RPMY)|
RPWZ|Bislig Airport (now RPMF)|
RPXC|Crow Valley Gunnery Range (now RPLQ)|
RPXI|Itbayat Airport (now RPLT)|
RPXJ|Jomalig Airport (now RPLJ)|
RPXG|Lubang Airport (now RPLU)|
RPXM|Fort Magsaysay Airfield (now RPLV)|
RPXP|Wallace Air Station (Poro Point) (reassigned RPLW|now also obsolete
RPXR|Kindley Landing Field (Corregidor) (now RPLX)|
RPXT|Alabat Airport (now RPLY)|
RPXU|Sorsogon Airport (now RPLZ)|
SAAC|Comodoro J.J. Pierrestegui Airport|Concordia, Entre Ríos Province
SAAG|Gualeguaychú Airport|Gualeguaychú, Entre Ríos Province
SAAJ|Junín Airport|Junín, Buenos Aires Province
SAAK|Martín García Island Airport|Isla Martín García, Buenos Aires Province
SAAP|General Justo José de Urquiza Airport|Paraná, Entre Ríos Province
SAAR|Rosario - Islas Malvinas International Airport|Rosario, Santa Fe Province
SAAV|Sauce Viejo Airport|Santa Fe, Santa Fe Province
SABA|Buenos Aires Airport|Buenos Aires
SABE|Jorge Newbery Airport|Buenos Aires
SACC|La Cumbre Airport|La Cumbre, Córdoba Province
SACO|Ingeniero Ambrosio L.V. Taravella International Airport|Córdoba, Córdoba Province
SACP|Chepes Airport|Chepes, La Rioja Province
SADD|Don Torcuato Aerodrome|Don Torcuato, Buenos Aires Province
SADF|San Fernando Airport|San Fernando, Buenos Aires Province
SADL|La Plata Airport|La Plata, Buenos Aires Province
SADM|Morón Airport and Air Base|Morón, Buenos Aires Province
SADP|El Palomar Airport|El Palomar
SAEZ|Ministro Pistarini International Airport (Ezeiza International Airport)|Ezeiza, Buenos Aires Province
SAHE|Caviahue Airport|Caviahue, Neuquén Province
SAHS|Rincón de los Sauces Airport|Rincón de los Sauces, Neuquén Province
SAHZ|Zapala Airport|Zapala, Neuquén Province
SAME|Governor Francisco Gabrielli International Airport (El Plumerillo Int'l)|Mendoza, Mendoza Province
SAMM|Comodoro D. Ricardo Salomón Airport|Malargüe, Mendoza Province
SAMR|San Rafael Airport|San Rafael, Mendoza Province
SANC|Coronel Felipe Varela Airport|Catamarca, Catamarca Province
SANE|Vicecomodoro Ángel de la Paz Aragonés Airport|Santiago del Estero, Santiago del Estero Province
SANH|Las Termas Airport|Termas de Río Hondo, Santiago del Estero Province
SANL|Capitán Vicente Almandos Almonacid Airport|La Rioja, La Rioja Province
SANO|Chilecito Airport|Chilecito, La Rioja Province
SANT|Tte. Gral. Benjamín Matienzo International Airport (Lt. Gen. Benjamín Matienzo)|Tucumán, Tucumán Province
SANU|Domingo Faustino Sarmiento Airport|San Juan, San Juan Province
SANW|Ceres Airport|Ceres, Santa Fe Province
SAOC|Las Higueras Airport|Río Cuarto, Córdoba Province
SAOD|Villa Dolores Airport|Villa Dolores, Córdoba Province
SAOR|Villa Reynolds Airport|Villa Reynolds, San Luis Province
SAOU|San Luis Airport|San Luis, San Luis Province
SARC|Doctor Fernando Piragine Niveyro International Airport|Corrientes, Corrientes Province
SARE|Resistencia International Airport|Resistencia, Chaco Province
SARF|Formosa International Airport|Formosa, Formosa Province
SARI|Cataratas del Iguazú International Airport (Iguazú Falls)|Puerto Iguazú, Misiones Province
SARL|Paso de los Libres Airport|Paso de los Libres, Corrientes Province
SARM|Monte Caseros Airport|Monte Caseros, Corrientes Province
SARP|Libertador General José de San Martín Airport|Posadas, Misiones Province
SASA|Martín Miguel de Güemes International Airport (El Aybal Airport)|Salta, Salta Province
SASJ|Gobernador Horacio Guzmán International Airport|San Salvador de Jujuy, Jujuy Province
SASO|Orán Airport|Orán, Salta Province
SAST|General Enrique Mosconi Airport|Tartagal, Salta Province
SATC|Clorinda Airport|Clorinda, Formosa Province
SATG|Goya Airport|Goya, Corrientes Province
SATK|Alférez Armando Rodríguez Airport|Las Lomitas, Formosa Province
SATM|Mercedes Airport|Mercedes, Corrientes Province
SATR|Daniel Jurkic Airport|Reconquista, Santa Fe Province
SATU|Curuzú Cuatiá Airport|Curuzú Cuatiá, Corrientes Province
SAVB|El Bolsón Airport|El Bolsón, Río Negro Province
SAVC|General Enrique Mosconi Airport|Comodoro Rivadavia, Chubut Province
SAVD|El Maitén Airport|El Maitén, Chubut Province
SAVE|Esquel Airport|Esquel, Chubut Province
SAVH|Las Heras Airport|Las Heras, Santa Cruz Province
SAVN|San Antonio Oeste Airport (Antoine de Saint Exupéry Airport)|San Antonio Oeste, Río Negro Province
SAVR|Alto Río Senguer Airport|Alto Río Senguer, Chubut Province
SAVS|Sierra Grande Airport|Sierra Grande, Río Negro Province
SAVT|Almirante Marco Andrés Zar Airport|Trelew, Chubut Province
SAVV|Gobernador Edgardo Castello Airport|Viedma, Río Negro Province
SAVY|El Tehuelche Airport|Puerto Madryn, Chubut Province
SAWC|Comandante Armando Tola International Airport|El Calafate, Santa Cruz Province
SAWD|Puerto Deseado Airport|Puerto Deseado, Santa Cruz Province
SAWE|Hermes Quijada International Airport|Río Grande, Tierra del Fuego Province
SAWG|Piloto Civil Norberto Fernández International Airport|Río Gallegos, Santa Cruz Province
SAWH|Ushuaia - Malvinas Argentinas International Airport|Ushuaia, Tierra del Fuego Province
SAWJ|Cap D Jose D Vazquez Airport|San Julián, Santa Cruz Province
SAWM|Río Mayo Airport|Río Mayo, Chubut Province
SAWP|Perito Moreno Airport|Perito Moreno, Santa Cruz Province
SAWR|Gobernador Gregores Airport|Gobernador Gregores, Santa Cruz Province
SAWS|José de San Martín Airport|José de San Martín, Chubut Province
SAWT|El Turbio Airport|Río Turbio, Santa Cruz Province
SAWU|Santa Cruz Airport|Santa Cruz, Santa Cruz Province
SAZA|Azul Airport|Azul, Buenos Aires Province
SAZB|Comandante Espora Airport|Bahía Blanca, Buenos Aires Province
SAZG|General Pico Airport|General Pico, La Pampa Province
SAZH|Tres Arroyos Airport|Tres Arroyos, Buenos Aires Province
SAZI|Bolivar Airport|Bolívar, Buenos Aires Province
SAZL|Santa Teresita Airport|Santa Teresita, Buenos Aires Province
SAZM|Ástor Piazzola International Airport|Mar del Plata, Buenos Aires Province
SAZN|Presidente Perón International Airport|Neuquén, Neuquén Province
SAZO|Necochea Airport|Necochea, Buenos Aires Province
SAZP|Comodoro P. Zanni Airport|Pehuajó, Buenos Aires Province
SAZR|Santa Rosa Airport|Santa Rosa, La Pampa Province
SAZS|San Carlos de Bariloche International Airport|San Carlos de Bariloche, Río Negro Province
SAZT|Tandil Airport|Tandil, Buenos Aires Province
SAZV|Villa Gesell Airport|Villa Gesell, Buenos Aires Province
SAZW|Cutral Có Airport|Cutral Có, Neuquén Province
SAZY|Aviador Carlos Campos Airport (Chapelco Airport)|San Martín de los Andes, Neuquén Province
SBAA|Conceicao do Araguaia Airport|Conceição do Araguaia, Pará
SBAN|Anápolis Air Base|Anápolis, Goiás
SBAQ|Araraquara Airport|Araraquara, São Paulo
SBAR|Santa Maria Airport|Aracaju, Sergipe
SBAS|Assis Airport|Assis, São Paulo
SBAT|Alta Floresta Airport|Alta Floresta, Mato Grosso
SBAU|Araçatuba Airport|Araçatuba, São Paulo
SBBE|Val de Cães International Airport|Belém, Pará
SBBG|Comandante Gustavo Kraemer Airport|Bagé, Rio Grande do Sul
SBBH|Pampulha Domestic Airport|Belo Horizonte, Minas Gerais
SBBI|Bacacheri Airport|Curitiba, Paraná
SBBQ|Barbacena Airport|Barbacena, Minas Gerais
SBBR|Presidente Juscelino Kubitschek International Airport|Brasília, Brazilian Federal District
SBBT|Chafei Amsei Airport|Barretos, São Paulo
SBBU|Bauru Airport|Bauru, São Paulo
SBBV|Boa Vista International Airport|Boa Vista, Roraima
SBBW|Barra do Garças Airport|Barra do Garças, Mato Grosso
SBBZ|Umberto Modiano Airport|Búzios, Rio de Janeiro
SBCA|Cascavel Airport|Cascavel, Paraná
SBCB|Cabo Frio International Airport|Cabo Frio, Rio de Janeiro
SBCC|Cachimbo Airport|Itaituba, Pará
SBCF|Tancredo Neves International Airport|Belo Horizonte, Minas Gerais
SBCG|Campo Grande International Airport|Campo Grande, Mato Grosso do Sul
SBCH|Chapecó Airport|Chapecó, Santa Catarina
SBCI|Carolina Airport|Carolina, Maranhão
SBCJ|Carajás Airport|Carajás, Pará
SBCM|Forquinhinha Airport|Criciúma, Santa Catarina
SBCO|Canoas Air Base|Porto Alegre, Rio Grande do Sul
SBCP|Bartolomeu Lisandro Airport|Campos, Rio de Janeiro
SBCR|Corumbá International Airport|Corumbá, Mato Grosso do Sul
SBCT|Afonso Pena International Airport|Curitiba, Paraná
SBCV|Caravelas Airport|Caravelas, Bahia
SBCX|Campo dos Bugres Airport|Caxias do Sul, Rio Grande do Sul
SBCY|Marechal Rondon Airport|Cuiabá, Mato Grosso
SBCZ|Cruzeiro do Sul International Airport|Cruzeiro do Sul, Acre
SBDN|Presidente Prudente Airport|Presidente Prudente, São Paulo
SBEG|Eduardo Gomes International Airport|Manaus, Amazonas
SBEK|Jacare-Acanga Airport|Jacareacanga, Pará
SBEX|Erechim Airport|Erechim, Rio Grande do Sul
SBFI|Foz do Iguaçu International Airport (Cataratas Int'l)|Foz do Iguaçu, Paraná
SBFL|Hercilio Luz International Airport|Florianópolis, Santa Catarina
SBFN|Fernando de Noronha Airport|Fernando de Noronha, Pernambuco
SBFZ|Pinto Martins International Airport|Fortaleza, Ceará
SBGL|Rio de Janeiro-Galeão International Airport|Rio de Janeiro, Rio de Janeiro
SBGM|Guajará-Mirim Airport|Guajará-Mirim, Rondônia
SBGO|Santa Genoveva Airport|Goiânia, Goiás
SBGP|Embraer Unidade Gavião Peixoto Airport|Gavião Peixoto, São Paulo
SBGR|São Paulo-Guarulhos International Airport|São Paulo, São Paulo
SBGS|Ponta Grossa Airport|Ponta Grossa, Paraná
SBGW|Guaratinguetá Airport|Guaratinguetá, São Paulo
SBHT|Altamira Airport|Altamira, Pará
SBIC|Itacoatiara Airport|Itacoatiara, Amazonas
SBIH|Itaituba Airport|Itaituba, Pará
SBIL|Ilhéus Jorge Amado Airport|Ilhéus, Bahia
SBIP|Usiminas Airport|Ipatinga, Minas Gerais
SBIZ|Prefeito Renato Moreira Airport|Imperatriz, Maranhão
SBJF|Francisco de Assis Airport|Juiz de Fora, Minas Gerais
SBJP|Presidente Castro Pinto International Airport|João Pessoa, Paraíba
SBJR ()|Jacarepaguá Airport|Rio de Janeiro, Rio de Janeiro
SBJV|Joinville-Lauro Carneiro de Loyola Airport|Joinville, Santa Catarina
SBKG|Joao Suassuna Airport|Campina Grande, Paraíba
SBKP|Viracopos International Airport|Campinas, São Paulo
SBLB|Lábrea Airport|Lábrea, Amazonas
SBLJ|Lages Airport|Lages, Santa Catarina
SBLN|Lins Airport|Lins, São Paulo
SBLO|Londrina Airport|Londrina, Paraná
SBLP|Bom Jesus da Lapa Airport|Bom Jesus da Lapa, Bahia
SBMA|Marabá Airport|Marabá, Pará
SBMC|Minaçu Airport|Minaçu, Goiás
SBMD|Monte Dourado Airport|Monte Dourado, Pará
SBME|Macaé Airport|Macaé, Rio de Janeiro
SBMG|Maringá - Sílvio Name Júnior Regional Airport|Maringá, Paraná
SBMK|Montes Claros Airport|Montes Claros, Minas Gerais
SBML|Marília Airport|Marília, São Paulo
SBMN|Ponta Pelada Airport|Manaus, Amazonas
SBMO|Zumbi dos Palmares Airport (Campo dos Palmares)|Maceió, Alagoas
SBMQ|Macapá International Airport|Macapá, Amapá
SBMS|Dix Sept Rosado Airport|Mossoró, Rio Grande do Norte
SBMT|Campo de Marte Airport|São Paulo, São Paulo
SBMY|Manicoré Airport|Manicoré, Amazonas
SBNF|Ministro Victor Konder International Airport|Navegantes, Santa Catarina
SBNM|Santo Ângelo Airport|Santo Ângelo, Rio Grande do Sul
SBNT|Augusto Severo International Airport|Natal, Rio Grande do Norte
SBOI|Oiapoque Airport|Oiapoque, Amapá
SBOU|Ourinhos Airport|Ourinhos, São Paulo
SBPA|Salgado Filho International Airport|Porto Alegre, Rio Grande do Sul
SBPB|Parnaíba-Prefeito Dr. João Silva Filho International Airport|Piauí, Parnaíba
SBPC|Poços de Caldas Airport|Poços de Caldas, Minas Gerais
SBPF|Lauro Kurtz Airport|Passo Fundo, Rio Grande do Sul
SBPG|Paranaguá Airport|Paranaguá, Paraná
SBPI|Pico do Couto Airport|Petrópolis, Rio de Janeiro
SBPJ|Palmas Airport|Palmas, Tocantins
SBPK|Pelotas Airport|Pelotas, Rio Grande do Sul
SBPL|Petrolina Airport|Petrolina, Pernambuco
SBPN|Porto Nacional Airport|Porto Nacional, Goiás
SBPP|Ponta Porã International Airport|Ponta Porã, Mato Grosso do Sul
SBPS|Porto Seguro Airport|Porto Seguro, Bahia
SBPV|Governador Jorge Teixeira de Oliveira International Airport|Porto Velho, Rondônia
SBQV|Vitória da Conquista Airport|Vitória da Conquista, Bahia
SBRB|Rio Branco International Airport(Presidente Medici Airport)|Rio Branco, Acre
SBRF|Guararapes International Airport (Gilberto Freyre Int'l)|Recife, Pernambuco
SBRG|Rio Grande Airport|Rio Grande, Rio Grande do Sul
SBRJ|Santos Dumont Regional Airport|Rio de Janeiro, Rio de Janeiro
SBRP|Leite Lopes Airport|Ribeirão Preto, São Paulo
SBSC|Santa Cruz Air Force Base|Santa Cruz, Rio de Janiero
SBSJ|São José dos Campos Regional Airport|São José dos Campos, São Paulo
SBSL|Marechal Cunha Machado International Airport|São Luís, Maranhão
SBSM|Santa Maria Airport|Santa Maria, Rio Grande do Sul
SBSN|Santarém-Maestro Wilson Fonseca Airport|Santarém, Pará
SBSP|Congonhas-São Paulo International Airport|São Paulo, São Paulo
SBSR|São José do Rio Preto Airport|São José do Rio Preto, São Paulo
SBST|Santos Air Base|Santos, São Paulo
SBSV|Deputado Luís Eduardo Magalhães International Airport (Dois de Julho Airport)|Salvador, Bahia
SBSY|Santa Isabel do Morro Airport|Santa Isabel do Morro, Tocantins
SBTA|Heliponto Airport|Taubaté, São Paulo
SBTB|Trombetas Airport|Trombetas, Pará
SBTE|Teresina Airport|Teresina, Piauí
SBTF|Tefé Airport|Tefé, Amazonas
SBTK|Tarauacá Airport|Tarauacá, Acre
SBTL|Telêmaco Borba Airport|Telêmaco Borba, Paraná
SBTS|Óbidos Airport|Óbidos, Pará
SBTT|Tabatinga International Airport|Tabatinga, Amazonas
SBTU|Tucuruí Airport|Tucuruí, Pará
SBTX|Tubarão Airport|Tubarão, Santa Catarina
SBUA|São Gabriel da Cachoeira Airport|São Gabriel da Cachoeira, Amazonas
SBUF|Paulo Afonso Airport|Paulo Afonso, Bahia
SBUG|Rubem Berta Airport|Uruguaiana, Rio Grande do Sul
SBUL|Ten. Cel. Av. César Bombonato Airport|Uberlândia, Minas Gerais
SBUP|Urubupungá Airport|Urubupungá, São Paulo
SBUR|Uberaba Airport|Uberaba, Minas Gerais
SBVG|Major Brigadeiro Trompowsky Airport|Varginha, Minas Gerais
SBVH|Vilhena Airport|Vilhena, Rondônia
SBVT|Goiabeiras Airport|Vitória, Espírito Santo
SBWX|Santarém Airport|Santarém, Pará
SBYS|Campo Fontenelle Airport|Pirassununga, São Paulo
SDAG|Angra dos Reis Airport|Angra dos Reis, Rio de Janeiro
SDAM|Aerodromo de Amarais|Campinas, São Paulo
SDCO|Sorocaba Airport|Sorocaba, São Paulo
SDIL|Fazenda Pedra Branca Airport|Angra dos Reis, Rio de Janeiro
SDJD|Jundiaí Airport|Jundiaí, São Paulo
SDLP|Lençóis Paulista Airport|Lençóis Paulista, São Paulo
SDRS|Resende Airport|Resende, Rio de Janeiro
SDRR|Avaré Airport|Avaré, São Paulo
SDSC|São Carlos Airport|São Carlos, São Paulo
SIAB|Leda Mello Resende Airport|Três Pontas, Minas Gerais
SIMK|Franca Airport (was SBFC)|Franca, São Paulo
SIFV|Aeródromo Primo Bitti|Aracruz, Espírito Santo
SJAU|Araguacema Airport|Araguacema, Tocantins
SJBY|João Silva Airport|Santa Inês, Maranhão
SJDB|Bonito Airport|Bonito, Mato Grosso do Sul
SJGU|Araguatins Airport|Araguatins, Tocantins
SJTC|Bauru-Arealva Airport|Bauru/Arealva, São Paulo
SJUR|Terravista Resort|Trancoso, Bahia
SNAG|Araguari Airport|Araguari, Minas Gerais
SNAI|Alto Parnaíba Airport|Alto Parnaíba, Maranhão
SNAR|Almenara Airport|Almenara, Minas Gerais
SNBL|Belmonte Airport|Belmonte, Bahia
SNBR|Barreiras Airport|Barreiras, Bahia
SNDM|Chapada Daimantina Airport|Lençóis, Bahia
SNEC|Outeiro das Brisas Airport|Porto Seguro, Bahia
SNFE|Alfenas Airport|Alfenas, Minas Gerais
SNGI|Guanambi Airport|Guanambi, Bahia
SNHA|Itabuna Airport|Itabuna, Bahia
SNMU|Mucuri Airport|Mucuri, Bahia
SNMZ|Pôrto de Moz Airport|Pôrto de Moz, Pará
SNOB|Sobral Airport|Sobral, Ceará
SNSM|Salinópolis Airport|Salinópolis, Pará
SNSW|Soure Airport|Soure, Pará
SNTO|Teófilo Otoni Airport|Teófilo Otoni, Minas Gerais
SNVB|Valença Airport|Valença, Bahia
SNVS|Breves Airport|Breves, Pará
SNWC|Camocim Airport|Camocim, Ceará
SNYE|Pinheiro Airport|Pinheiro, Maranhão
SSAL|Federal Airport|Alegrete, Rio Grande do Sul
SSAP|Apucarana Airport|Apucarana, Paraná
SSBL|Blumenau Airport|Blumenau, Santa Catarina
SSCK|Concordia Airport|Concordia, Amazonas
SSCN|Canela Airport|Canela, Rio Grande do Sul
SSDO|Dourados Airport|Dourados, Minas Gerais
SSER|Erechim Airport|Erechim, Rio Grande do Sul
SSGB|Guaratuba Airport|Guaratuba, Paraná
SSIJ|Ijuí Airport|Ijuí, Rio Grande do Sul
SSIQ|Itaqui Airport|Itaqui, Rio Grande do Sul
SSKM|Campo Mourão Airport|Campo Mourão, Paraná
SSLI|Dos Galpoes Airport|Santana do Livramento, Rio Grande do Sul
SSPB|Pato Branco Airport|Pato Branco, Paraná
SSPG|Paranaguá Airport|Paranaguá, Paraná
SSPS|Palmas Airport|Palmas, Paraná
SSUV|União da Vitória Airport|União da Vitória, Paraná
SSVI|Videira Airport|Videira, Santa Catarina
SSVN|Veranópolis Airport|Veranópolis, Rio Grande do Sul
SSZR|Santa Rosa Airport|Santa Rosa, Rio Grande do Sul
SWBC|Barcelos Airport|Barcelos, Amazonas
SWBR|Borba Airport|Borba, Amazonas
SWCA|Carauari Airport|Carauari, Amazonas
SWJI|Ji-Paraná Airport|Ji-Paraná, Rondônia
SWKC|Cáceres Airport|Cáceres, Minas Gerais
SWKN|Caldas Novas Airport|Caldas Novas, Goiás
SWKO|Coari Airport|Coari, Amazonas
SWKT|Catalão Airport|Catalão, Goiás
SWLC|General Leite de Castro Airport|Rio Verde, Goiás
SWNK|Novo Campo Airport|Boca do Acre, Amazonas
SWNS|Anapolis Airport|Anapolis, Goiás
SWNV|Aeródromo Nacional de Aviação|Goiânia, Goiás
SWPI|Julio Belem Airport|Parintins, Amazonas
SWRD|Rondonópolis Airport|Rondonópolis, Mato Grosso
SWSI|Sinop Airport|Sinop, Mato Grosso
SWXV|Nova Xavantina Airport|Nova Xavantina, Mato Grosso
SWYM|Fazenda Anhanguera Airport|Pontes e Lacerda, Mato Grosso
SCAC|Pupelde Airport|Ancud
SCAG|El Avellano Airport|Los Angeles
SCAP|Alto Palena Airport|Alto Palena
SCAR|Chacalluta International Airport|Arica
SCBA|Balmaceda Airport|Balmaceda
SCBE|Barriles Airport|Tocopilla
SCCC|Chile Chico Airport|Chile Chico
SCCF|El Loa Airport|Calama
SCCH|General Bernardo O'Higgins Airport|Chillán
SCCI|Carlos Ibanez Del Campo International Airport|Punta Arenas
SCCY|Teniente Vidal Airport|Coyhaique
SCDA|Diego Aracena International Airport|Iquique
SCEL|Comodoro Arturo Merino Benítez International Airport|Santiago
SCES|El Salvador Bajo Airport|El Salvador
SCFA|Cerro Moreno International Airport|Antofagasta
SCFM|Capitan Fuentes Martinez Airport|Porvenir
SCGZ|Guardia Marina Zañartu Airport|Puerto Williams
SCHA|Chamonate Airport|Copiapó
SCHR|Cochrane Airport|Cochrane
SCIC|General Freire Airport|Curicó
SCIE|Carriel Sur International Airport|Concepción
SCIP|Mataveri International Airport|Easter Island (Isla de Pascua)
SCIR|Robinson Crusoe Airport|Juan Fernandez Islands
SCJO|Canal Bajo Airport|Osorno
SCKU|Chuquicamata Airport|Chuquicamata
SCLC|Santiago Municipal de Vitacura|Santiago
SCLL|Vallenar Airport|Vallenar
SCNT|Teniente Julio Gallardo Airport|Puerto Natales
SCOV|Ovalle Tuqui Airport|Ovalle Tuqui
SCPC|Pucón Airport|Pucón
SCRA|Chanaral Airport|Chanaral
SCRG|De La Independencia Airport|Rancagua
SCRM|Teniente R. Marsh Airport|Teniente Roldofo Marsh Martin Base and Villa Las Estrellas
SCSB|Franco Blanco Airport|Cerro Sombrero
SCSE|La Florida Airport|La Serena
SCST|Gamboa Airport|Castro
SCTC|Maquehue Airport|Temuco
SCTE|El Tepual International Airport|Puerto Montt
SCTI|Los Cerrillos Airport|Santiago
SCTL|Panguilemo Airport|Talca
SCTN|Chaiten Airport|Chaiten
SCTO|Victoria Airport|Victoria
SCTT|Las Breas Airport|Taltal
SCVA|Valparaíso Airport|Valparaíso
SCVD|Pichoy Airport|Valdivia
SCVL|Las Marías Airport|Valdivia
SCVM|Viña Del Mar Airport|Viña del Mar
SEAM|Chachoan Airport|Ambato
SEBC|Los Perales Airport|Bahia de Caraquez
SECE|Santa Cecilia Airport|Santa Cecilia
SECO|Francisco de Orellana Airport|Coca
SECU|Mariscal Lamar Airport|Cuenca
SEES|General Rivadeneira Airport|Esmeraldas
SEGS|Seymour Airport|Galápagos (Baltra)
SEGU|José Joaquín de Olmedo International Airport|Guayaquil
SEJI|Jipijapa Airport|Jipijapa
SELT|Cotopaxi International Airport|Latacunga
SELA|Lago Agrio Airport|Lago Agrio
SELO|Camilo Ponce Enriquez Airport|Loja
SEMA|J.M. Velasco Ibarra Airport|Macara
SEMC|Macas Airport|Macas
SEMH|General M. Serrano Airport|Machala
SEMT|Eloy Alfaro International Airport|Manta
SEPA|Rio Amazonas Airport|Pastaza
SEPD|Pedernales Airport|Pedernales
SEPT|Putumayo Airport|Putumayo
SEPV|Reales Tamarindos Airport|Portoviejo
SEQU|Mariscal Sucre International Airport|Quito
SESA|General Ulpiano Paez Airport|Salinas
SESC|Sucua Airport|Sucua
SEST|San Cristóbal Airport|San Cristóbal Island, Galápagos Islands
SETH|Taisha Airport|Taisha
SETI|Tiputini Airport|Tiputini
SETR|Tarapoa Airport|Tarapoa
SETU|Teniente Coronel Luis a Mantilla International Airport|Tulcán
SFAL|Port Stanley Airport|Stanley, Falkland Islands
SGAS|Silvio Pettirossi International Airport|Asunción
SGAY|Juan de Ayolas Airport|Ayolas
SGCO|Teniente Coronel Carmelo Peralta Airport|Concepción
SGEN|Teniente Primero Alarcón Airport|Encarnacion
SGES|Guaraní International Airport|Ciudad Del Este
SGFI|Fernheim Airport|Filadelfia
SGME|Dr. Luis Maria Argaña International Airport|Mariscal Estigarribia
SGPI|Carlos Miguel Gimenez Airport|Pilar
SGPJ|Augusto R. Fuster International Airport|Pedro Juan Caballero
SKAC|Araracuara Airport|Araracuara
SKAD|Alcides Fernández Airport|Acandí
SKAG|Hacaritama Airport|Aguachica
SKAM|Amalfi Airport|Amalfi
SKAN|Andes Airport|Andes
SKAP|Gomez Nino-Apiay Airport|Apiay
SKAR|El Edén International Airport|Armenia
SKAS|Tres de Mayo Airport|Puerto Asís
SKBC|Las Flores Airport|El Banco
SKBG|Palonegro Airport|Lebrija (near Bucaramanga)
SKBO|El Dorado International Airport|Bogotá
SKBQ|Ernesto Cortissoz International Airport|Barranquilla
SKBS|José Celestino Mutis Airport|Bahía Solano
SKBU|Gerardo Tobar López Airport|Buenaventura
SKCA|Capurganá Airport|Capurganá
SKCC|Camilo Daza International Airport|Cúcuta
SKCD|Mandinga Airport|Condoto
SKCG|Rafael Núñez International Airport|Cartagena
SKCI|Carimagua Airport|Carimagua
SKCL|Alfonso Bonilla Aragón International Airport|Cali
SKCM|Cimitarra Airport|Cimitarra
SKCO|La Florida Airport|Tumaco
SKCU|Caucasia Airport|Caucasia
SKCV|Coveñas Airport|Coveñas
SKCZ|Las Brujas Airport|Corozal
SKEB|El Bagre Airport|El Bagre
SKEJ|Yarigüies Airport|Barrancabermeja
SKFL|Gustavo Artunduaga Paredes Airport|Florencia
SKGI|Santiago Vila Airport|Girardot
SKGO|Santa Ana Airport|Cartago
SKGP|Guapi Airport|Guapi
SKHA|Chaparral Airport|Chaparral
SKHC|Hato Corozal Airport|Hato Corozal
SKIB|Perales Airport|Ibagué
SKIG|Chigorodó Airport|Chigorodó
SKIP|San Luis Airport|Ipiales
SKIU|Tibú Airport|Tibú
SKLC|Antonio Roldán Betancourt Airport|Apartadó
SKLG|Caucaya Airport|Puerto Leguízamo
SKLM|La Mina Airport|Maicao
SKLP|La Pedrera Airport|La Pedrera
SKLT|Alfredo Vásquez Cobo International Airport|Leticia
SKMD|Olaya Herrera Airport|Medellín
SKMF|Miraflores Airport|Miraflores
SKMG|Baracoa Airport|Magangué
SKMR|Los Garzones Airport|Montería
SKMU|Fabio Alberto León Bentley Airport|Mitú
SKMZ|La Nubia Airport|Manizales
SKNC|Antioquia Airport|Necoclí
SKNQ|Reyes Murillo Airport|Nuquí
SKNV|Benito Salas|Neiva
SKOC|Aguas Claras Airport|Ocaña
SKOE|Orocue Airport|Orocue
SKOT|Otu Airport|Otu
SKPB|Puerto Bolívar Airport|Guajira Department
SKPC|Puerto Carreño Airport|Puerto Carreño
SKPD|Obando Airport|Puerto Inírida
SKPE|Matecaña International Airport|Pereira
SKPI|Pitalito Airport|Pitalito
SKPL|Plato Airport|Plato
SKPP|Guillermo León Valencia Airport|Popayán
SKPQ|German Olano AB|Palanquero
SKPS|Antonio Narino Airport|Pasto
SKPV|El Embrujo Airport|Providencia Island
SKPZ|Paz de Ariporo Airport|Paz de Ariporo
SKQU|Mariquita Airport|Mariquita
SKRG|José María Córdova International Airport|Medellín/Rionegro
SKRH|Almirante Padilla Airport|Riohacha
SKSA|Los Colonizadores Airport|Saravena
SKSJ|Jorge Enrique González Airport|San José del Guaviare
SKSM|Simón Bolívar International Airport|Santa Marta
SKSP|Gustavo Rojas Pinilla International Airport (Sesquicentenario Airport)|San Andrés Island
SKSR|San Marcos Airport|San Marcos
SKSV|Eduardo Falla Solano Airport|San Vicente del Caguán
SKTD|Trinidad Airport|Trinidad
SKTJ|Gustavo Rojas Pinilla Airport|Tunja
SKTM|Tame Airport|Tame
SKTQ|Tres Esquinas AB|Tres Esquinas
SKTU|Gonzalo Mejía Airport|Turbo
SKUA|Marandúa AB|Marandúa
SKUC|Santiago Pérez Airport|Arauca
SKUI|El Caraño Airport|Quibdó
SKUL|Farfan Airport|Tuluá
SKUR|Urrao Airport|Urrao
SKVG|Villa Garzón Airport|Villa Garzón
SKVP|Alfonso López Pumarejo Airport|Valledupar
SKVV|La Vanguardia Airport|Villavicencio
SKYA|Yaguara Airport|Yaguara
SKYP|El Alcaraván Airport|Yopal
SLAP|Apolo Airport|Apolo
SLAS|Ascenscion de Guarayos Airport|Ascencion de Guarayos
SLBJ|Bermejo Airport|Bermejo
SLBN|Bella Union Airport|Bella Union
SLCA|Camiri Airport|Camiri
SLCB|Jorge Wilstermann International Airport|Cochabamba
SLCO|Capitan Anibal Arab Airport|Cobija
SLCP|Concepcion Airport|Concepción
SLET|El Trompillo Airport|Santa Cruz
SLGY|Guayaramerín Airport|Guayaramerin
SLJE|San Jose de Chiquitos Airport|San José de Chiquitos
SLJO|San Joaquin Airport|San Joaquin
SLJV|San Javier Airport|San Javier
SLLP|El Alto International Airport|La Paz
SLMG|Magdalena Airport|Magdalena
SLOR|Oruro Airport|Oruro
SLPO|Capitan Nicolas Rojas Airport|Potosí
SLPR|Puerto Rico Airport|Puerto Rico
SLPS|Puerto Suárez International Airport|Puerto Suarez
SLRA|San Ramon Airport|San Ramon
SLRB|Robore Airport|Robore
SLRI|Riberalta Airport|Riberalta
SLRQ|Rurrenabaque Airport|Rurrenabaque
SLRY|Reyes Airport|Reyes
SLSA|Santa Ana del Yacuma Airport|Santa Ana del Yacuma
SLSB|Capitán Germán Quiroga Guardia Airport|San Borja
SLSI|San Igancio de Velasco Airport|San Ignacio de Velas
SLSM|San Ignacio de Moxos Airport|San Ignacio de Moxos
SLSU|Juana Azurduy de Padilla International Airport|Sucre
SLTJ|Capitán Oriel Lea Plaza Airport|Tarija
SLTR|Teniente Jorge Henrich Arauz Airport|Trinidad
SLVM|Villamontes Airport|Villamontes
SLVR|Viru Viru International Airport|Santa Cruz
SLYA|Yacuiba Airport|Yacuiba
SMBN|Albina Airstrip|Albina
SMCI|Coeroenie Airstrip|Coeroeni
SMCO|Totness Airstrip|Totness, Coronie District
SMDA|Drietabbetje Airstrip|Drietabbetje
SMJP|Johan Adolf Pengel International Airport (Zanderij Int'l)|Zanderij
SMKA|Kabalebo Airstrip|Kabalebo
SMKE|Kayser Airstrip|Kayser
SMNI|Nieuw-Nickerie Airport|Nieuw-Nickerie (New Nickerie)
SMPA|Vincent Fayks Airport|Paloemeu
SMST|Stoelmans Eiland Airstrip|Stoelmans Eiland
SMTB|Tafelberg Airstrip|Tafelberg
SMWA|Wageningen Airstrip|Wageningen
SMZO|Zorg en Hoop Airport|Paramaribo
SOCA|Cayenne-Rochambeau Airport|Cayenne
SOOA|Maripasoula Airport|Maripasoula
SOOG|Saint-Georges-de-l'Oyapock Airport|Saint-Georges-de-l'Oyapock
SOOM|Saint-Laurent-du-Maroni Airport|Saint-Laurent-du-Maroni
SOOR|Régina Airport|Régina
SOOS|Saül Airport|Saül
SOOY|Sinnamary Airport|Sinnamary
SPAO|San Juan Aposento Airport|San Juan Aposento
SPAR|Alerta Airport|Alerta, Ucayali Region
SPAS|Alferez FAP Alfredo Vladimir Sara Bauer Airport|Andoas, Loreto Region
SPAY|Tnte. Gral. Gerardo Pérez Pinedo Airport|Atalaya, Ucayali Region
SPBB|Moyobamba Airport|Moyobamba, San Martín Region
SPBC|Caballococha Airport|Caballococha, Loreto Region
SPBL|Huallaga Airport|Bellavista, San Martín Region
SPBR|Iberia Airport|Iberia
SPBS|Bellavista Airport|Jeberos, Loreto Region
SPCH|Tocache Airport|Tocache, San Martín Region
SPCL|Capitán Rolden Airport (or Capitán FAP David Abenzur Rengifo Airport)|Pucallpa, Ucayali Region
SPCM|Contamana Airport|Contamana, Loreto Region
SPDR|Trompeteros Airport|Corrientes
SPEO|Teniente FAP Jaime A. de Montreuil Morales Airport|Chimbote, Ancash Region
SPEQ|Cesar Torque Podesta Airport|Moquegua, Moquegua Region
SPGM|Tingo María Airport|Tingo María, Huánuco Region
SPHI|Capitán FAP José A. Quiñones Gonzales Airport|Chiclayo, Lambayeque Region
SPHO|Coronel FAP Alfredo Mendívil Duarte Airport|Ayacucho, Ayacucho Region
SPHU|Huancayo Airport|Huancayo, Junín Region
SPHV|Huánuco Viejo Airport|Huánuco Viejo, Huánuco Region
SPHY|Andahuaylas Airport|Andahuaylas, Apurímac Region
SPHZ|Comandante FAP Germán Arias Graziani Airport|Anta/Huaraz, Ancash Region
SPIL|Quince Mil Airport|Quince Mil, Cusco Region
SPIM|Jorge Chávez International Airport|Callao/Lima, Lima Metropolitan Area
SPIP|Satipo Airport|Satipo
SPIZ|Uchiza Airport|Uchiza
SPJA|Juan Simons Vela Airport|Rioja, San Martín Region
SPJB|Pampa Grande Airport|Cajabamba, Cajamarca Region
SPJE|Shumba Airport|Jaén, Cajamarca Region
SPJI|Juanjuí Airport|Juanjuí, San Martín Region
SPJJ|Francisco Carle Airport|Jauja, Junín Region
SPJL|Inca Manco Cápac International Airport|Puno/Juliaca, Puno Region
SPJN|San Juan de Marcona Airport|San Juan de Marcona
SPJR|Major General FAP Armando Revoredo Iglesias Airport|Cajamarca, Cajamarca Region
SPLC|Mariano Melgar Airport|La Joya, Arequipa Region
SPLN|San Nicolas Airport|Rodriquez de Mendoza
SPLO|Ilo Airport|Ilo, Moquegua Region
SPLP|Las Palmas Air Base (military)|Barranco, Lima Province
SPME|Capitán FAP Pedro Canga Rodríguez Airport|Tumbes, Tumbes Region
SPMF|Manuel Prado Ugarteche Airport|Mazamari, Junín Region
SPMR|Santa Maria Airport, Peru|Santa Maria
SPMS|Moisés Benzaquen Rengifo Airport|Yurimaguas, Loreto Region
SPNC|Alférez FAP David Figueroa Fernandini Airport|Huánuco, Huánuco Region
SPOA|Saposoa Airport|Saposoa
SPOV|Shiringayoc/Hacienda Mejia Airport|Leon Velarde
SPPY|Chachapoyas Airport|Chachapoyas, Amazonas Region
SPQN|Requena Airport|Requena, Loreto Region
SPQT|Coronel FAP Francisco Secada Vignetta Airport|Iquitos, Loreto Region
SPQU|Rodríguez Ballón International Airport|Arequipa, Arequipa Region
SPRF|San Rafael Airport (Peru)|San Rafael
SPRM|Capitán FAP Leonardo Alvariño Herr Airport|San Ramón, Junín Region
SPRU|Capitán FAP Carlos Martínez de Pinillos Airport|Trujillo, La Libertad Region
SPSF|San Francisco Airport|San Francisco
SPSO|Capitán FAP Renán Elías Olivera Airport|Pisco, Ica Region
SPSP|San Pablo Airport|San Pablo, Cajamarca Region
SPST|Comandante FAP Guillermo del Castillo Paredes Airport|Tarapoto, San Martín Region
SPSY|Shiringayoc Airport|Shiringayoc
SPTN|Coronel FAP Carlos Ciriani Santa Rosa Airport|Tacna, Tacna Region
SPTP|El Pato Air Base|Talara, Piura Region
SPTU|Padre José de Aldamiz International Airport|Puerto Maldonado, Madre de Dios Region
SPUR|Capitán FAP Guillermo Concha Iberico Airport|Piura/Talara, Piura Region
SPVR|San Isidoro Airport|Vitor
SPVT|Mayor FAP Guillermo Protset del Castillo Airport|Vitor
SPYL|Capitán FAP Victor Montes Arias|Talara, Piura Region
SPZA|María Reiche Neuman Airport|Nazca, Ica Region
SPZO|Subteniente FAP Alejandro Velasco Astete International Airport|Cusco, Cusco Region
SUAG|Artigas Airport|Artigas
SUCA|Colonia Airport|Colonia
SUDU|Santa Bernardina International Airport|Durazno
SULS|Capitan Corbeta CA Curbelo International Airport|Maldonado
SUMO|Cerro Largo Airport|Melo
SUMU|Carrasco International Airport|Montevideo
SUPE|El Jaguel International Airport|Punta del Este
SUPU|Paysandú Airport|Paysandú
SURV|Rivera International Airport|Rivera
SUSO|Salto Airport|Salto
SUTB|Tacuarembó Airport|Tacuarembó
SUTR|Treinta y Tres Airport|Treinta y Tres
SUVO|Vichadero Airport|Vichadero
SVAC|Oswaldo Guevara Mujica Airport|Acarigua
SVAN|Anaco Airport|Anaco, Anzoátegui
SVBC|Generál José Antonio Anzoátegui International Airport|Barcelona, Anzoátegui
SVBI|Barinas Airport|Barinas, Barinas State
SVBL|El Libertador Airbase|Maracay, Aragua
SVBM|Jacinto Lara International Airport|Barquisimeto
SVBS|Mariscal Sucre Airport (Venezuela)|Maracay, Aragua
SVCB|Tomás de Heres Airport|Ciudad Bolívar, Bolívar
SVCD|Caicara de Orinoco Airport|Caicara del Orinoco
SVCL|Calabozo Airport|Calabozo, Guárico
SVCN|Canaima Airport|Canaima
SVCO|Carora Airport|Carora, Lara
SVCP|General José Francisco Bermúdez Airport|Carupano
SVCR|José Leonardo Chirinos Airport|Coro, Falcón
SVCU|Antonio José de Sucre Airport|Cumaná, Sucre
SVED|El Dorado Airport (Venezuela)|El Dorado
SVEZ|Elorza Airport|Elorza, Apure
SVFM|Generalissimo Francisco de Miranda Airbase|Caracas Lacar
SVGD|Guasdualito Airport|Guasdualito, Apure
SVGI|Guiria Airport|Guiria, Sucre
SVGU|Guanare Airport|Guanare, Portuguesa
SVIC|Icabaru Airport|Icabaru, Bolívar
SVJC|Josefa Camejo International Airport|Paraguaná, Falcón
SVKA|Kavanayen Airport|Bolívar
SVKM|Kamarata Airport|Bolívar
SVLF|La Fria Airport|La Fria, Táchira
SVMC|La Chinita International Airport|Maracaibo, Zulia
SVMD|Alberto Carnevalli Airport|Mérida, Mérida
SVMG|Del Caribe International Airport (Gen. Santiago Marino Airport)|Porlamar, Isla Margarita
SVMI|Simón Bolívar International Airport (Maiquetia International Airport)|Maiquetía, Vargas (near Caracas)
SVMT|Maturín Airport|Maturín, Monagas
SVPA|Cacique Aramare Airport|Puerto Ayacucho, Amazonas
SVPC|Bartolome Salom Airport|Puerto Cabello, Carabobo
SVPM|Paramillo Airport|San Cristóbal, Táchira
SVPR|Manuel Carlos Piar Guayana Airport|Ciudad Guayana, Bolívar
SVPT|Palmarito Airport|Apure
SVSA|Juan Vicente Gómez International Airport|San Antonio del Táchira, Táchira
SVSE|Santa Elena de Uairen Airport|Bolívar
SVSO|Mayor Buenaventura Vivas Airport|Santo Domingo
SVSP|Sub Teniente Nestor Arias Airport|San Felipe, Yaracuy
SVSR|Las Flecheras Airport|San Fernando de Apure, Apure
SVST|San Tomé Airport|San Tomé
SVTC|Tucupita Airport|Tucupita, Delta Amacuro
SVTM|Tumeremo Airport|Tumeremo
SVUM|Uriman Airport|Bolívar
SVVA|Arturo Michelena International Airport|Valencia, Carabobo
SVVG|Juan Pablo Perez Alfonso Airport|El Vigia
SVVL|Dr. Antonio Nicolás Briceno Airport|Valera, Trujillo
SYAN|Annai Airport|Annai
SYBR|Baramita Airport|Baramita
SYBT|Bartica Airport|Bartica
SYCJ|Cheddi Jagan International Airport|Georgetown
SYGO|Ogle Airport|Ogle
SYIB|Imbaimadai Airport|Imbaimadai
SYKM|Kamarang Airport|Kamarang
SYKR|Karanambo Airport|Karanambo
SYKS|Karasabai Airport|Karasabai
SYKT|Kato Airport|Kato
SYLT|Lethem Airport|Lethem
SYMB|Mabaruma Airport|Mabaruma
SYMD|Mahdia Airport|Mahdia
SYMM|Monkey Mountain Airport|Monkey Mountain, Guyana
SYNA|New Amsterdam Airport|New Amsterdam
SYOR|Orinduik Airport|Orinduik
SYPR|Paruima Airport|Paruima
SYTM|Timehri International Airport|Georgetown
TAPA|VC Bird International Airport|Saint John's, Antigua
TAPH|Codrington Airport|Codrington, Barbuda
TAPT|Coco Point Lodge Airport|Coco Point, Barbuda
TBPB|Grantley Adams International Airport|Bridgetown
TBPO|Bridgetown Heliport|Bridgetown
TDCF|Canefield Airport|Roseau
TDPD|Melville Hall Airport|Marigot
TFFA|Grande-Anse Airport|Grande-Anse, La Désirade
TFFB|Baillif Airport|Baillif, Basse-Terre
TFFC|Saint-François Airport|Saint-François, Grande-Terre
TFFM|Marie-Galante Airport|Grand-Bourg, Marie-Galante
TFFR|Pointe-à-Pitre - Le Raizet Airport|Pointe-à-Pitre, Grande-Terre
TFFS|Les Saintes Airport|Terre-de-Haut, Les Saintes
TFFF|Fort-de-France - Le Lamentin Airport|Le Lamentin, Fort-de-France
TFFJ|Gustaf III Airport|St. Jean
TFFG|L'Espérance Airport|Grand Case
TGPY|Point Salines International Airport|St. George's
TIST|Cyril E. King Airport|St. Thomas
TISX|Henry E. Rohlsen Airport|St. Croix
TJAB|Antonio (Nery) Juarbe Pol Airport|Arecibo
TJBQ|Rafael Hernández Airport|Aguadilla
TJCG|Vieques Airport (Antonio Rivera Rodríguez Airport)|Vieques
TJCP|Benjamin Rivera Noriega Airport|Culebra
TJFA|Diego Jimenez Torres Airport|Fajardo
TJIG|Fernando Ribas Dominicci Airport (Isla Grande Airport)|San Juan
TJMZ|Eugenio María de Hostos Airport|Mayagüez
TJNR|Roosevelt Roads Naval Station|Ceiba
TJPS|Mercedita Airport|Ponce
TJSJ|Luis Muñoz Marín International Airport|San Juan
TKPK|Robert L. Bradshaw International Airport|Basseterre, Saint Kitts
TKPN|Vance W. Amory International Airport|Charlestown, Nevis
TLPC|George F. L. Charles Airport (formerly Vigie Airport)|Castries, Saint Lucia
TLPL|Hewanorra International Airport|Vieux-Fort, Saint Lucia
TNCB|Flamingo International Airport|Kralendijk, Bonaire, Netherlands Antilles
TNCC|Hato International Airport|Willemstad, Curaçao, Netherlands Antilles
TNCE|F.D. Roosevelt Airport|Sint Eustatius, Netherlands Antilles
TNCM|Princess Juliana International Airport|Philipsburg, Sint Maarten, Netherlands Antilles
TNCS|Juancho E. Yrausquin Airport|Saba, Netherlands Antilles
TNCA|Queen Beatrix International Airport|Oranjestad, Aruba
TQPF|Anguilla Wallblake Airport|The Valley
TRPG|Gerald's Airport|Gerald's Park
TTCP|Crown Point Airport|Scarborough, Tobago
TTPP|Piarco International Airport|Port of Spain, Trinidad
TUPA|Auguste George Airport|Anegada
TUPJ|Terrance B. Lettsome International Airport|Beef Island / Tortola
TUPW|Virgin Gorda Airport|Virgin Gorda
TVSB|J.F. Mitchell Airport|Bequia, Grenadines
TVSC|Canouan Airport|Canouan, Grenadines
TVSM|Mustique Airport|Mustique, Grenadines
TVSU|Union Island Airport|Union Island, Grenadines
TVSV|E.T. Joshua Airport|Arno Vale (near Kingstown), Saint Vincent
TXKF|Bermuda International Airport|Ferry Reach
UEAA|Aldan Airport|Aldan, Russia
UEEE|Yakutsk Airport|Yakutsk, Russia
UELL|Chulman Airport|Chulman, Russia
UERP|Polyarny Airport|Polyarny, Russia
UERR|Mirny Airport|Mirny, Russia
UESO|Chokurdakh Airport|Chokurdakh, Russia
UESS|Chersky Airport|Chersky, Russia
UEST|Tiksi Airport|Tiksi, Russia
UHBB|Ignatyevo Airport|Blagoveschensk, Russia
UHBI|Magdagachi Airport|Magdagachi, Russia
UHHH|Novy Airport|Khabarovsk, Russia
UHMA|Ugolny Airport|Anadyr, Russia
UHMD|Provideniya Bay Airport|Provideniya, Russia
UHMM|Sokol Airport|Magadan, Russia
UHMP|Pevek Airport|Pevek, Russia
UHPP|Yelizovo Airport|Petropavlovsk-Kamchatsky, Russia
UHPX|Nikolskoye Airport|Nikolskoye, Kamchatka Krai, Russia
UHSS|Yuzhno-Sakhalinsk Airport|Yuzhno-Sakhalinsk, Russia
UHWW|Vladivostok International Airport|Vladivostok, Russia
UIAA|Kadala Airport|Chita, Russia
UIBB|Bratsk Airport|Bratsk, Russia
UIII|Irkutsk International Airport|Irkutsk, Russia
UIUU|Mukhino Airport|Ulan-Ude, Russia
ULAA|Talagi Airport|Arkhangelsk, Russia
ULAM|Naryan-Mar Airport|Naryan-Mar, Russia
ULDD|Amderma Airport|Amderma, Russia
ULKK|Kotlas Airport|Kotlas, Russia
ULLI|Pulkovo Airport|Saint Petersburg, Russia
ULSS|Rzhevka Airport|Saint Petersburg, Russia
ULMM|Murmansk Airport|Murmansk, Russia
ULOL|Velikiye Luki Airport|Velikiye Luki, Russia
ULOO|Pskov Airport|Pskov, Russia
ULPB|Besovets Airport|Petrozavodsk, Russia
ULWW|Vologda Airport|Vologda, Russia
UMKK|Khrabrovo Airport|Kaliningrad, Russia
UNAA|Abakan Airport|Abakan, Russia
UNBB|Barnaul Airport|Barnaul, Russia
UNCC|Severny Airport|Novosibirsk, Russia
UNEE|Kemorovo Airport|Kemerovo, Russia
UNIW|Vanavara Airport|Vanavara, Russia
UNKL|Krasnoyarsk Yemelyanovo Airport|Krasnoyarsk, Russia
UNKY|Kyzyl Airport|Kyzyl, Russia
UNNT|Novosibirsk Tolmachevo Airport|Novosibirsk, Russia
UNOO|Tsentralny Airport|Omsk, Russia
UNTT|Bogashevo Airport|Tomsk, Russia
UNWW|Novokuznetsk Spichenkovo Airport|Novokuznetsk, Russia
UOHH|Khatanga Airport|Khatanga, Russia
UOOO|Norilsk Airport|Norilsk, Russia
URKA|Vityazevo Airport|Anapa, Russia
URKK|Pashkovsky Airport|Krasnodar, Russia
URKM|Maykop Airport|Maykop, Russia
URML|Uytash Airport|Makhachkala, Russia
URMM|Mineralnye Vody Airport|Mineralnye Vody, Russia
URMN|Nalchik Airport|Nalchik, Russia
URMO|Beslan Airport|Vladikavkaz, Russia
URMT|Shpakovskoye Airport|Stavropol, Russia
URRR|Rostov-on-Don Airport|Rostov-on-Don, Russia
URSS|Adler-Sochi International Airport|Sochi, Russia
URWA|Astrakhan Airport|Astrakhan, Russia
URWI|Elista Airport|Elista, Russia
URWW|Gumrak Airport|Volgograd, Russia
USCC|Balandino Airport|Chelyabinsk, Russia
USCM|Magnitogorsk Airport|Magnitogorsk, Russia
USDD|Salekhard Airport|Salekhard, Russia
USHH|Khanty-Mansiysk Airport|Khanty-Mansi Autonomous Okrug, Russia
USKK|Kirov Airport|Kirov, Russia
USMM|Nadym Airport|Nadym, Russia
USMU|Novy Urengoy Airport|Novy Urengoy, Russia
USNN|Nizhnevartovsk Airport|Nizhnevartovsk, Russia
USNR|Raduzhny Airport|Raduzhny, Russia
USPI|Izhevsk Airport|Izhevsk, Russia
USPP|Bolshoye Savino Airport|Perm, Russia
USRK|Kogalym Airport|Kogalym, Russia
USRO|Noyabrsk Airport|Noyabrsk, Russia
USRR|Surgut Airport|Surgut, Russia
USSS|Koltsovo International Airport|Yekaterinburg, Russia
USTO|Tobolsk Airport|Tobolsk, Russia
USTR|Roschino Airport|Tyumen, Russia
USUU|Kurgan Airport|Kurgan, Russia
UUBB|Bykovo Airport|Moscow, Russia
UUBP|Bryansk Airport|Bryansk, Russia
UUDD|Domodedovo International Airport|Moscow, Russia
UUEE|Sheremetyevo International Airport|Moscow, Russia
UUEM|Migalovo Airport|Tver, Russia
UUMO|Ostafievo International Airport|Moscow, Russia
UUOB|Belgorod Airport|Belgorod, Russia
UUOO|Chertovitskoye Airport|Voronezh, Russia
UUWR|Dyagilevo Airport|Ryazan, Russia
UUWV|Moskva FIR|Moscow, Russia
UUWW|Vnukovo Airport|Moscow, Russia
UUYH|Ukhta Airport|Ukhta, Russia
UUYP|Pechora Airport|Pechora, Russia
UUYW|Vorkuta Airport|Vorkuta, Russia
UUYY|Syktyvkar Airport|Syktyvkar, Russia
UWGG|Strigino Airport|Nizhny Novgorod, Russia
UWKD|Kazan Airport|Kazan, Russia
UWKE|Begishevo Airport|Nizhnekamsk, Russia
UWKS|Cheboksary Airport|Cheboksary, Russia
UWKI|Chistopol Airport|Yoshkar-Ola, Russia
UWLW|Vostochny Airport|Ulyanovsk, Russia
UWOO|Tsentralny Airport|Orenburg, Russia
UWOR|Orsk Airport|Orsk, Russia
UWPP|Penza Airport|Penza, Russia
UWPS|Saransk Airport|Saransk, Russia
UWSS|Tsentralny Airport|Saratov, Russia
UWUK|Oktyabrsky Airport|Oktyabrsky, Russia
UWUU|Ufa International Airport|Ufa, Russia
UWWW|Kurumoch Airport|Samara, Russia
UAAA|Almaty Airport|Almaty, Kazakhstan
UAAH|Balkhash Airport|Balkhash, Kazakhstan
UACC|Astana International Airport|Astana, Kazakhstan
UADD|Taraz Airport|Taraz, Kazakhstan
UAII|Shymkent Airport|Shymkent (Chimkent), Kazakhstan
UAKD|Zhezkazgan Airport|Zhezkazgan, Kazakhstan
UAKK|Karaganda Airport|Karaganda, Kazakhstan
UAOO|Kyzylorda Airport|Kyzylorda, Kazakhstan
UARR|Uralsk Airport|Uralsk, Kazakhstan
UASK|Ust Kamenogorsk Airport|Ust Kamenogorsk, Kazakhstan
UASP|Pavlodar Airport|Pavlodar, Kazakhstan
UASS|Semipalatinsk Airport|Semipalatinsk, Kazakhstan
UATE|Aktau Airport|Aktau, Kazakhstan
UATG|Atyrau Airport|Atyrau, Kazakhstan
UATT|Aktyubinsk Airport|Aktyubinsk, Kazakhstan
UAUR|Arkalyk Airport|Arkalyk, Kazakhstan
UAUU|Narimanovka Airport|Kostanay, Kazakhstan
UAFL|Tamchy Airport|Tamchy, Kyrgyzstan
UAFM|Manas International Airport|Bishkek, Kyrgyzstan
UAFO|Osh Airport|Osh, Kyrgyzstan
UAFW|Kant Airport|Kant, Kyrgyzstan
UBBB|Heydar Aliyev International Airport|Baku
UBBG|Gyandzha Airport|Ganja (Gyandzha)
UBBN|Nakhichevan Airport|Nakhichevan
UBEE|Yevlakh Airport|Yevlakh
UDLS|Stepanavan Airport|Stepanavan, Armenia
UDSG|Shirak Airport|Gyumri, Armenia
UDYE|Erebuni Airport|Yerevan, Armenia
UDYZ|Zvartnots International Airport|Zvartnots (near Yerevan), Armenia
UGKO|Kopitnari Airport|Kutaisi, Georgia
UGSB|Batumi Airport|Batumi, Georgia
UGSS|Sukhumi Dranda Airport|Sukhumi, Abkhazia
UGTB|Tbilisi International Airport|Tbilisi, Georgia
UKBB|Boryspil International Airport|Boryspil (near Kiev), Ukraine
UKBC|Bila Tserkva, Ukraine|
UKBF|Konotop Air Base, Konotop, Ukraine|
UKBM|Myrhorod Airport|Myrhorod, Ukraine
UKCC|Donetsk Airport|Donetsk, Ukraine
UKCK|Kramatorsk, Ukraine|
UKCM|Mariupol Airport|Mariupol, Ukraine
UKCS|Sieverodonetsk Airport|Sieverodonetsk, Ukraine
UKCW|Luhansk International Airport|Luhansk, Ukraine
UKDB|Berdyansk Airport|Berdyansk, Ukraine
UKDD|Dnipropetrovsk International Airport|Dnipropetrovsk, Ukraine
UKDE|Zaporizhia International Airport|Zaporizhia, Ukraine
UKDM|Melitopol, Ukraine|
UKDP|Pidhorodne, Ukraine|
UKDR|Kryvyi Rih International Airport|Kryvyi Rih, Ukraine
UKFB|"Belbek" Sevastopol International Airport|Sevastopol, Ukraine
UKFF|Simferopol International Airport|Simferopol, Ukraine
UKFI|Saky, Ukraine|
UKFK|Kerch Airport|Kerch, Ukraine
UKFV|Yevpatoriya, Ukraine|
UKFW|Zavodske Airfield|Simferopol, Ukraine
UKFY|Dzhankoy, Ukraine|
UKHE|Petrovske, Ukraine|
UKHH|Kharkiv International Airport|Kharkiv, Ukraine
UKHK|Kremenchuk Airfield|Kremenchuk, Ukraine
UKHP|Poltava Airport|Poltava, Ukraine
UKHS|Sumy Airport|Sumy, Ukraine
UKKA|Ukraviatrans|Kiev, Ukraine
UKKD|Drabiv, Ukraine|
UKKE|Cherkasy Airport|Cherkasy, Ukraine
UKKG|Kirovohrad Airport|Kirovograd, Ukraine
UKKH|Chepelevka Airport|Uzyn, Ukraine
UKKJ|Chaika Airfield|Kiev, Ukraine
UKKK|Kiev International Airport|Kiev, Ukraine
UKKL|Chernihiv Shestovitsa Airport|Chernihiv, Ukraine
UKKM|Gostomel Airport|Gostomel, Ukraine
UKKO|Ozerne Airport|Zhytomyr, Ukraine
UKKR|UKRAERORUKH UkSATSE|Kiev, Ukraine
UKKS|Semenivka, Ukraine|
UKKT|Sviatoshyn Airfield|Kiev, Ukraine
UKKV|Zhytomyr, Ukraine|
UKLA|Kalyniv, Ukraine|
UKLB|Brody, Ukraine|
UKLC|Lutsk Airport|Lutsk, Ukraine
UKLF|Tsuniv, Ukraine|
UKLH|Khmelnytskyi Airport|Khmelnytskyi, Ukraine
UKLI|Ivano-Frankivsk Airport|Ivano-Frankivsk, Ukraine
UKLL|Lviv International Airport|Lviv, Ukraine
UKLN|Chernivtsi Airport|Chernivtsi, Ukraine
UKLO|Kolomyia, Ukraine|
UKLR|Rivne Airport|Rivne, Ukraine
UKLS|Starokostiantyniv, Ukraine|
UKLT|Ternopil Airport|Ternopil, Ukraine
UKLU|Uzhhorod Airport|Uzhhorod, Ukraine
UKOG|Henichesk, Ukraine|
UKOH|Husakivka Airport|Kherson, Ukraine
UKOI|Izmail International Airport|Izmail, Ukraine
UKOM|Lymanske Airport|Lymanske, Ukraine
UKON|Mykolaiv Airport|Mykolaiv, Ukraine
UKOO|Odessa International Airport|Odessa, Ukraine
UKRN|Nizhyn, Ukraine|
UKWW|Vinnytsia Airport|Vinnytsia, Ukraine
UMBB|Brest Airport|Brest, Belarus
UMGG|Gomel Airport|Gomel, Belarus
UMII|Vostochny Airport|Vitebsk, Belarus
UMKK|Khrabrovo Airport|Kaliningrad, Russia
UMMG|Hrodna Airport|Obukhovo, Belarus
UMMS|Minsk International Airport|Minsk, Belarus
UMMM|Minsk-1|Minsk, Belarus
UMOO|Mogilev Airport|Mogilev, Belarus
UTAA|Ashgabat Airport (Ashkhabad Airport)|Ashgabat (Ashkhabad), Turkmenistan
UTAK|Turkmenbashi Airport|Turkmenbashi, Turkmenistan
UTAM|Mary Airport|Mary, Turkmenistan
UTAT|Dashoguz Airport|Dashoguz, Turkmenistan
UTAV|Turkmenabat Airport|Turkmenabat (Chardzhou), Turkmenistan
UTDD|Dushanbe Airport|Dushanbe, Tajikistan
UTDL|Khudzhand Airport|Khudzhand, Tajikistan
UTOD|Khorog Airport|Khorog, Tajikistan
UTDK|Kulob Airport|Kulyab, Tajikistan
UTDT|Qurghonteppa International Airport|Kurgan Tyube, Tajikistan
UTFA|Andizhan Airport|Andizhan, Uzbekistan
UTFF|Fergana Airport|Fergana, Uzbekistan
UTFN|Namangan Airport|Namangan, Uzbekistan
UTNN|Nukus Airport|Nukus, Uzbekistan
UTNU|Urgench Airport|Urgench, Uzbekistan
UTSB|Bukhara Airport|Bukhara, Uzbekistan
UTSK|Karshi Airport|Karshi, Uzbekistan
UTSL|Karshi Khanabad Airport|Karshi Khanabad, Uzbekistan
UTSS|Samarkand Airport|Samarkand, Uzbekistan
UTST|Termez Airport|Termez, Uzbekistan
UTTT|Tashkent Airport|Tashkent, Uzbekistan
VAHB|Hubli Airport / Hubli Air Force Base|Hubli
VAAH|Sardar Vallabhbhai Patel International Airport (Ahmadabad Airport)|Ahmedabad
VAAK|Akola Airport|Akola
VAAU|Aurangabad Airport|Aurangabad
VABB|Chatrapati Shivaji International Airport|Mumbai (Bombay)
VABI|Bilaspur Airport|Bilaspur
VABJ|Bhuj Airport|Bhuj, Gujarat, India
VABM|Belgaum Airport|Belgaum
VABO|Vadodara Airport / Vadodara Air Force Base|Vadodara (Baroda)
VABP|Bhopal Airport (Bairagarh Airport)|Bhopal
VABV|Bhavnagar Airport|Bhavnagar
VADN|Daman Airport|Daman
VADZ|Daparizo Airport|Daparizo
VAGN|Guna Airport|Guna
VAGO|Dabolim Airport (Goa Airport) / Dabolim Navy Airbase|Dabolim
VAID|Devi Ahilyabai Holkar International Airport|Indore
VAJB|Jabalpur Airport|Jabalpur
VAJJ|Juhu Airport|Mumbai (Bombay)
VAJM|Jamnagar Airport / Jamnagar Air Force Base|Jamnagar
VAKD|Khandwa Airport|Khandwa
VAKE|Kandla Airport (Gandhidham Airport)|Gandhidham / Kandla
VAKJ|Khajuraho Airport|Khajuraho
VAKP|Kolhapur Airport|Kolhapur
VAKS|Junagadh Airport (Keshod Airport)|Keshod
VAND|Nanded Airport|Nanded
VANP|Dr. Babasaheb Ambedkar International Airport / Sonegaon Air Force Base|Nagpur
VANR|Gandhinagar Airport|Nasik
VAPO|Pune Airport / Lohegaon Air Force Base|Pune (Poona)
VAPR|Porbandar Airport|Porbandar
VARG|Ratnagiri Airport|Ratnagiri
VARK|Rajkot Airport|Rajkot
VARP|Raipur Airport|Raipur
VASL|Solapur Airport|Sholapur (Solapur)
VASU|Surat Airport|Surat
VAUD|Udaipur Airport|Udaipur
VEAN|Along Airport|Along
VEAT|Agartala Airport|Agartala
VEAZ|Turial Air Force Base|Aizwal
VEBA|Behala Airport|Behala
VEBD|Bagdogra Airport / Bagdogra Air Force Base|Bagdogra / Siliguri
VEBG|Balurghat Airport|Balurghat
VEBI|Shillong Airport (Barapani Airport)|Shillong
VEBS|Biju Patnaik Airport|Bhubaneswar
VECC|Netaji Subhash Chandra Bose International Airport|Kolkata (Calcutta)
VECK|Chakulia Airport|Chakulia
VECO|Cooch Behar Airport|Cooch Behar
VEDB|Dhanbad Airport|Dhanbad
VEDZ|Daporijo Airport|Daporijo
VEGK|Gorakhpur Air Force Base|Gorakhpur
VEGT|Lokpriya Gopinath Bordoloi International Airport (Guwahati Int'l) / Guwahati Air Force Base|Guwahati
VEGY|Gaya Airport|Gaya
VEHK|Hirakud Airport|Hirakud
VEIM|Imphal Airport (Tulihal Airport)|Imphal
VEJH|Jharsuguda Airport|Jharsuguda
VEJP|Jeypore Airport|Jeypore
VEJS|Sonari Airport|Jamshedpur
VEJT|Chabua Air Force Base (Jorhat Airport)|Jorhat
VEKM|Kamalpur Airport|Kamalpur
VEKR|Kailashahar Airport|Kailashahar
VEKU|Silchar Airport (Kumbhirgram Air Force Base)|Silchar
VEKW|Khowai Airport|Khowai
VELR|Lilabari Airport|North Lakhimpur
VEMH|Malda Airport|Malda
VEMN|Dibrugarh Airport (Mohanbari Airport)|Dibrugarh
VEMR|Dimapur Airport (Dimapur Air Force Base)|Dimapur
VEMZ|Muzzafarpur Airport|Muzzafarpur
VEPG|Pasighat Airport|Pasighat (Passighat)
VEPH|Panagarh Airport|Panagarh
VEPT|Lok Nayak Jaya Prakash Narayan Airport (Patna Airport)|Patna
VEPU|Purnea Airport|Purnia (Purnea)
VERC|Birsa Munda Airport (Ranchi Airport)|Ranchi
VERK|Rourkela Airport|Rourkela
VERL|Raxaul Airport|Raxaul
VERU|Rupsi Airport|Rupsi
VETJ|Tezu Airport|Tezu
VETZ|Tezpur Airport (Tezpur Air Force Base)|Tezpur
VEVZ|Visakhapatnam Airport|Visakhapatnam (Vishakhapatnam)
VEZO|Ziro Airport|Ziro, India
VIAG|Agra Airport / Agra Air Force Station|Agra
VIAL|Bamrauli Air Force Base|Allahabad
VIAM|Ambala Air Force Base|Ambala
VIAR|Raja Sansi International Airport (Amritsar Int'l)|Amritsar
VIAX|Sirsa Air Force Base|Adampur / Jullundur
VIBK|Nal Air Force Base|Bikaner
VIBL|Bakshi Ka Talab Air Force Base|Bareilly
VIBN|Varanasi Airport|Varanasi
VIBR|Bhuntar Airport|Kullu / Manali
VIBT|Bhisiana Air Force Base|Bhatinda
VICG|Chandigarh Airport (Chandigarh Air Force Base)|Chandigarh
VICX|Chakeri Air Force Station|Kanpur
VIDD|Safdarjung Airport (Safdarjung Air Force Station)|New Delhi
VIDN|Jolly Grant Airport|Dehradun
VIDP|Indira Gandhi International Airport|New Delhi
VIGG|Gaggal Airport (Kangra Airport)|Kangra / Dharamsala
VIDX|Hindon Air Force Base|Ghaziabad
VIGR|Gwalior Airport / Maharajpur Air Force Base|Gwalior
VIHR|Hissar Airport|Hissar
VIJN|Jhansi Airport|Jhansi
VIJO|Jodhpur Airport / Jodhpur Air Force Base|Jodhpur
VIJP|Jaipur Airport (Sanganer Airport)|Jaipur
VIJR|Jaisalmer Airport|Jaisalmer (Jaiselmer)
VIJU|Jammu Airport|Jammu
VIKA|Kanpur Airport (Chakeri Airport)|Kanpur
VIKO|Kota Airport|Kota
VILD|Sahnewal Airport|Ludhiana
VILH|Leh Kushok Bakula Rimpochee Airport|Leh
VILK|Amausi Airport|Lucknow
VIPK|Pathankot Airport|Pathankot
VIPT|Pant Nagar Airport (Pantnagar Airport)|Pant Nagar / Nainital
VISM|Shimla Airport|Shimla
VISR|Srinagar Air Force Base|Srinagar
VISR|Srinagar Airport / Srinagar Air Force Base|Srinagar
VIST|Satna Airport|Satna
VIUT|Uttarlai Airport|Uttarlai
VIUX|Udhampur Air Force Base|Udhampur
VOBI|Bellary Airport|Bellary
VOBL|Bengaluru International Airport|Bengaluru
VOBG|HAL Airport|Bangalore - Old
VOBR|Bidar Air Force Station|Bidar
VOBZ|Vijayawada Airport|Vijayawada
VOCB|Coimbatore Airport|Coimbatore
VOCC|Cochin Navy Airbase|Kochi
VOCI|Cochin International Airport (Kochi Int'l)|Kochi / Nedumbassery
VOCL|Calicut International Airport (Karipur Airport)|Kozhikode (Calicut)
VOCP|Cuddapah Airport|Cuddapah
VOCX|Car Nicobar Air Force Base|Car Nicobar
VODG|Dundigul Air Force Academy|Hyderabad
VODK|Donakonda Airport|Donakonda
VOHK|Hakimpet Air Force Station|Secunderabad
VOHY|Begumpet Airport|Hyderabad
VOHS|Rajiv Gandhi International Airport|Hyderabad, India
VOMD|Madurai Airport|Madurai
VOML|Mangalore International Airport|Mangalore
VOMM|Chennai International Airport|Chennai / Madras
VOMY|Mysore Airport|Mysore
VONV|Neyvafli Airport|Neyvafli
VOPB|Vir Savarkar Airport (Port Blair Airport)|Port Blair
VOPC|Pondicherry Airport|Pondicherry
VOPN|Sri Sathya Sai Airport|Puttaparthi
VORG|Ramagundam Airport|Ramagundam
VORY|Rajahmundry Airport|Rajahmundry
VOSM|Salem Airport|Salem
VOSX|Sulur Air Force Base|Sulur
VOTJ|Tanjore Air Force Base|Tanjore (Thanjavur)
VOTP|Tirupati Airport|Tirupati (Tirupathi)
VOTR|Tiruchirapalli Airport|Tiruchirapalli (Trichy)
VOTV|Thiruvananthapuram International Airport (formerly Trivandrum Int'l)|Thiruvananthapuram
VOTX|Tambaram Air Force Station|Chennai
VOWA|Warangal Airport|Warangal (Warrangal)
VOYK|Yelahanka Air Force Station|Yelahanka
VCBI|Bandaranaike International Airport|Colombo
VCCA|Anuradhapura Airport|Anuradhapura
VCCB|Batticaloa Airport|Batticaloa
VCCC|Ratmalana Airport|Colombo
VCCG|Amparai Airport|Gal Oya
VCCJ|Kankesanturai Airport|Jaffna
VCCK|Koggala Airport|Galle
VCCN|Katukurunda Airport|Kalutara
VCCT|China Bay Airport|Trincomalee
VCCW|Weerawila International Airport (New airport)|
VDBG|Battambang Airport|Battambang
VDKC|Kampong Cham Airport|Kampong Cham
VDKH|Kampong Chhnang Airport|Kompong Chhnang
VDKK|Koh Kong Airport|Koh Kong
VDKT|Kratie Airport|Kratie
VDMK|Mondulkiri Airport|Mondulkiri
VDPP|Phnom Penh International Airport (Pochentong International)|Phnom Penh
VDRK|Ratanankiri Airport|Ratanankiri
VDSR|Angkor International Airport|Siem Reap
VDST|Stung Treng Airport|Stung Treng
VDSV|Sihanoukville International Airport|Sihanoukville
VGBR|Barisal Airport|Barisal
VGCB|Cox's Bazar Airport|Cox's Bazar
VGCM|Comilla Airport|Comilla
VGEG|Shah Amanat International Airport (M.A. Hannan Int'l)|Chittagong
VGIS|Ishurdi Airport|Ishurdi
VGJR|Jessore Airport|Jessore
VGSH|Shamshernagar Airport|Shamshernagar
VGSY|Osmani International Airport|Sylhet
VGTJ|Tejgaon Airport|Dhaka
VGZR|Zia International Airport|Dhaka
VHHH|Hong Kong International Airport|Chek Lap Kok
VHHX|Kai Tak Airport (closed 1998)|Kowloon
VHSK|Shek Kong Airfield|Shek Kong (RAF Shek Kong)
VLAO|Vientiane Airport|Vientiane
VLAP|Attopeu Airport|Attopeu
VLHS|Ban Huoeisay Airport (Ban Houei Sai/Ban Houay Xay)|Ban Hat Tai
VLKG|Khong Airport|Khong Island
VLLB|Luang Prabang International Airport|Luang Prabang
VLLN|Luang Namtha Airport|Luang Namtha
VLOS|Oudomsay Airport|Muang Xay
VLPS|Pakse Airport|Pakse
VLSB|Sayaboury Airport|Sayaboury
VLSK|Savannakhet Airport|Savannakhet
VLSN|Sam Neua Airport|Sam Neua
VLSV|Saravane Airport|Saravane
VLTK|Thakhek Airport|Thakhek
VLVT|Wattay International Airport|Vientiane (Viangchan)
VLXK|Xieng Khouang Airport|Xieng Khouang
VMMC|Macau International Airport|Taipa Island (Ilha da Taipa)
VNBG|Bajhang Airport|Bajhang
VNBJ|Bhojpur Airport|Bhojpur
VNBL|Baglung Airport|Baglung
VNBP|Bharatpur Airport|Bharatpur
VNBR|Bajura Airport|Bajura
VNBT|Baitadi Airport|Baitadi
VNBW|Bhairahawa Airport|Bhairahawa
VNDP|Dolpa Airport|Dolpa
VNJL|Jumla Airport|Jumla
VNKT|Tribhuvan International Airport|Kathmandu
VNLD|Lamidanda Airport|Lamidanda
VNLK|Lukla Airport|Lukla
VNLT|Langtang Airport|Langtang
VNMA|Manang Airport|Manang
VNMG|Meghauli Airport|Meghauli
VNMN|Mahendranagar Airport|Mahendranagar
VNNG|Nepalgunj Airport|Nepalgunj
VNPK|Pokhara Airport|Pokhara
VNPL|Phaplu Airport|Phaplu
VNRB|Rajbiraj Airport|Rajbiraj
VNRC|Ramechhap Airport|Ramechhap
VNRK|Rukumkot Airport|Rukumkot
VNRP|Rolpa Airport|Rolpa
VNRT|Rumjatar Airport|Rumjatar
VNSB|Syanboche Airport|Syanboche
VNSK|Surkhet Airport|Surkhet
VNSR|Sanfebagar Airport|Sanfebagar
VNST|Simikot Airport|Simikot
VNTJ|Taplejung Airport|Taplejung
VNTP|Tikapur Airport|Tikapur
VNTR|Tumlingtar Airport|Tumlingtar
VNVT|Biratnagar Airport|Biratnagar
VQPR|Paro Airport|Paro
VQTU|Thimbu Airport|Thimbu
VRMG|Gan International Airport|Gan Island, Seenu Atoll
VRMH|Hanimaadhoo Airport|Hanimaadhoo Island, Haa Dhaalu Atoll
VRMK|Kadhdhoo Airport|Kadhdhoo Island, Laamu Atoll
VRMM|Malé International Airport|Hulhulé Island, North Malé Atoll
VRMT|Kaadedhdhoo Airport|Kaadedhdhoo Island, Gaafu Dhaalu Atoll
VTBC|Chanthaburi Airstrip (Royal Thai Navy)|Chantaburi (Chanthaburi)
VTBD|Don Muang International Airport (Old Bangkok International Airport)|Bangkok
VTBF|Pattaya Airport|Pattaya
VTBG|Kanchanaburi Airport|Kanchanaburi
VTBK|Kamphaeng Saen Airport|Kamphaeng Saen / Nakhon Pathom
VTBL|Khok Kathiam Air Force Base|Lopburi
VTBN|Pranburi Airport|Prachuap Khiri Khan
VTBO|Trat Airport|Trat
VTBP|Prachuap Khiri Khan Military Airport|Prachuap Khiri Khan
VTBS|Suvarnabhumi Airport (New Bangkok International Airport)|Samut Prakan (near Bangkok)
VTBT|Bang Phra Airport|Chonburi (Chon Buri)
VTBU|U-Tapao International Airport (Utapao/U-Taphao)|Rayong (near Pattaya)
VTBW|Watthana Nakhon Airport|Watthana Nakhon / Prachin Buri
VTCC|Chiang Mai International Airport|Chiang Mai
VTCH|Mae Hong Son Airport|Mae Hong Son
VTCL|Lampang Airport|Lampang
VTCM|Ban Thi Airport (Lanna Airfield)|Chiang Mai
VTCN|Nan Airport|Nan
VTCO|Lamphun Airport|Lamphun
VTCP|Phrae Airport|Phrae
VTCR|Chiang Rai Airport|Chiang Rai
VTCS|Mae Sariang Airport|Mae Sariang
VTCT|Chiang Rai International Airport|Chiang Rai
VTPB|Phetchabun Airport|Phetchabun
VTPH|Hua Hin Airport|Hua Hin / Prachuap Khiri Khan
VTPI|Takhli Air Force Base|Nakhon Sawan
VTPL|Lom Sak Airport|Lom Sak / Phetchabun
VTPM|Mae Sot Airport|Mae Sot
VTPO|Sukhothai Airport|Sukhothai
VTPP|Phitsanulok Airport|Phitsanulok
VTPR|Photharam Airport (Potaram Ratchaburi Airport)|Photharam
VTPT|Tak Airport|Tak
VTPU|Uttaradit Airport|Uttaradit
VTPY|Phumipol Dam Airport|Phumipol Dam / Khuan Phumiphon
VTSB|Surat Thani Airport|Surat Thani
VTSC|Narathiwat Airport|Narathiwat
VTSE|Chumphon Airport|Chumphon
VTSFNakhon Si Thammarat Airport|Nakhon Si Thammarat|
VTSG|Krabi Airport|Krabi
VTSH|Songkhla Airport|Songkhla
VTSK|Pattani Airport|Pattani
VTSM|Samui Airport|Ko Samui (Ko Samui)
VTSN|Cha Ian Airport|Nakhon Si Thammarat
VTSP|Phuket International Airport|Phuket
VTSR|Ranong Airport|Ranong
VTSS|Hat Yai International Airport|Hat Yai / Songkhla
VTST|Trang Airport|Trang
VTUD|Udon Thani International Airport|Udon Thani
VTUI|Sakon Nakhon Airport|Sakon Nakhon
VTUJ|Surin Airport|Surin
VTUK|Khon Kaen Airport|Khon Kaen
VTUL|Loei Airport|Loei
VTUN|Khorat Air Force Base|Nakhon Ratchasima (Khorat)
VTUO|Buriram Airport|Buriram (Buri Ram)
VTUQ|Nakhon Ratchasima Airport|Nakhon Ratchasima (Khorat)
VTUR|Rob Muang Airport|Roi Et (Roiet)
VTUU|Ubon Ratchathani Airport|Ubon Ratchathani
VTUV|Roi Et Airport (Roiet Airport)|Roi Et (Roiet)
VTUW|Nakhon Phanom Airport|Nakhon Phanom
VVBM|Buon Ma Thuot Airport|Buon Ma Thuot
VVCI|Cat Bi Airport|Hai Phong
VVCL|Cam Ly Airport|Da Lat
VVCM|Ca Mau Airport|Ca Mau
VVCR|Cam Ranh Airport|Nha Trang
VVCS|Co Ong Airport|Con Dao
VVCT|Tra Noc Airport|Can Tho
VVDB|Dien Bien Phu Airport|Dien Bien Phu
VVDL|Lien Khuong Airport|Da Lat
VVDN|Da Nang International Airport|Da Nang
VVGL|Gia Lam Airbase|Hanoi
VVNB|Noi Bai International Airport|Hanoi
VVNS|Na San Airport|Son La
VVNT|Nha Trang Airport|Nha Trang
VVPB|Phu Bai Airport|Huế
VVPC|Phu Cat Airport|Qui Nhon
VVPK|Pleiku Airport|Pleiku
VVPQ|Duong Dong Airport|Phu Quoc
VVPT|Phan Thiet Airport|Phan Thiet
VVRG|Rach Gia Airport|Rach Gia
VVTH|Dong Tac Airport|Tuy Hoa
VVTS|Tan Son Nhat International Airport|Ho Chi Minh City
VVVH|Vinh Airport|Vinh
VYAS|Anisakan Airport|Anisakan
VYBG|Nyaung U Airport|Bagan (Pagan)
VYBM|Banmaw Airport|Bhamo
VYCI|Coco Island Airport|Coco Island
VYCZ|Mandalay Chanmyathazi Airport|Mandalay
VYDW|Dawei Airport|Dawei (Tavoy)
VYEL|Naypyidaw Airport (Ela Airport) -- Naypyidaw|
VYGG|Gangaw Airport|Gangaw
VYGW|Gwa Airport|Gwa
VYHB|Hmawby Airport (military) -- Hmawby|
VYHH|Heho Airport|Heho
VYHL|Homalin Airport|Homalin (Hommalin)
VYHN|Tilin Airport|Tilin
VYKG|Kengtung Airport|Kengtung (Kengtong)
VYKI|Khamti Airport|Khamti
VYKL|Kalaymyo Airport|Kalaymyo (Kalemyo)
VYKP|Kyaukpyu Airport|Kyaukpyu
VYKT|Kawthaung Airport|Kawthaung (Kawthoung)
VYKU|Kyauktu Airport|Kyauktu
VYLK|Loikaw Airport|Loikaw
VYLS|Lashio Airport|Lashio
VYLY|Lanywa Airport|Lanywa
VYMD|Mandalay International Airport|Mandalay
VYME|Myeik Airport|Myeik (Mergui)
VYMK|Myitkyina Airport|Myitkyina (Pamti)
VYML|Meiktila Airport (military) -- Meiktila|
VYMM|Mawlamyaing Airport|Mawlamyaing (Mawlamyine)
VYMN|Manaung Airport|Manaung
VYMO|Momeik Airport|Momeik
VYMS|Monghsat Airport|Monghsat (Mong Hsat)
VYMT|Mong-Tong Airport|Mong-Tong (Hong Ton)
VYMW|Magwe Airport|Magwe
VYMY|Monywar Airport|Monywar
VYNP|West Nampong Airport (military) -- Myitkyina|
VYNS|Namsang Airport|Namsang
VYNT|Namtu Airport|Namtu
VYPA|Hpa-An Airport|Hpa-An (Pa-An)
VYPK|Pauk Airport|Pauk
VYPN|Pathein Airport|Pathein (Bassein)
VYPP|Hpapun Airport|Hpapun
VYPT|Putao Airport|Putao
VYPU|Pakokku Airport|Pakokku
VYPY|Pyay Airport|Pyay (Prome)
VYST|Shante Airport (military) -- Shante|
VYSW|Sittwe Airport|Sittwe
VYTD|Thandwe Airport|Thandwe
VYTL|Tachilek Airport|Tachilek (Tachileik)
VYYE|Ye Airport|Ye
VYYY|Yangon International Airport|Yangon (Rangoon)
WAAA|Sultan Hasanuddin International Airport|Makassar / Ujung Pandang, South Sulawesi
WAAB|Betoambari Airport|Bau Bau
WAAJ|Tampa Padang Airport|Mamuju, West Sulawesi
WAAM|Andi Jemma Airport|Masamba
WAAS|Soroako Airport|Soroako
WAAU|Wolter Monginsidi Airport|Kendari, South East Sulawesi
WABB|Frans Kaisiepo Airport|Biak, Papua
WABD|Moanamani Airport|Moanamani
WABF|Jembruwo Airport|Noemfoor
WABG|Wagethe Airport|Wagethe
WABI|Nabire Airport|Nabire
WABL|Ilaga Airport|Ilaga
WABP|Timika Airport|Tembagapura
WABT|Enarotali Airport|Enarotali
WADD|Ngurah Rai International Airport|Denpasar, Bali (ICAO code also given as WRRR)
WAJA|Arso Airport|Arso
WAJB|Bokondini Airport|Bokondini
WAJJ|Sentani Airport|Jayapura, Papua
WAJL|Lereh Airport|Lereh
WAJM|Mulia Airport|Mulia
WAJO|Oksibil Airport|Oksibil
WAJR|Waris Airport|Waris
WAJS|Senggeh Airport|Senggeh
WAJW|Wamena Airport|Wamena
WAKD|Mindiptana Airport|Mindiptana
WAKE|Bade Airport|Bade
WAKK|Mopah Airport|Merauke
WAKO|Okaba Airport|Okaba
WAKP|Kepi Airport|Kepi
WAKT|Tanah Merah Airport|Tanah Merah
WALL|Sepinggan International Airport|Balikpapan, East Kalimantan
WAMA|Gamarmalamo Airport|Galela
WAMH|Naha Airport (Indonesia)|Naha
WAMI|Lalos Airport|Toli Toli
WAML|Mutiara Airport|Palu, Central Sulawesi
WAMM|Sam Ratulangi International Airport|Manado, North Sulawesi
WAMN|Melangguane Airport|Melangguane
WAMP|Kasiguncu Airport|Poso, Central Sulawesi
WAMR|Pitu Airport|Morotai, Maluku Islands
WAMT|Babullah Airport|Ternate, Maluku Islands
WAMW|Bubung Airport|Luwuk, Central Sulawesi
WAPA|Amahai Airport|Amahai, West Papua
WAPD|Dobo Airport|Dobo
WAPE|Mangole Airport|Mangole Island
WAPI|Saumlaki Airport|Saumlaki
WAPL|Dumatubin Airport|Langgur
WAPN|Sanana Airport|Sanana
WAPP|Pattimura Airport|Ambon, Maluku
WAPR|Namlea Airport|Namlea
WAPT|Taliabu Airport|Taliabu
WARI|Iswahyudi Airfield|Madiun
WARR|Juanda International Airport|Sidoarjo (near Surabaya)
WASC|Abresso Airport|Ransiki
WASE|Kebar Airport|Kebar
WASF|Torea Airport|Fak Fak
WASI|Inanwatan Airport|Inanwatan
WASK|Kaimana Airport|Kaimana
WASM|Merdei Airport|Merdei
WASO|Babo Airport|Babo
WASR|Rendani Airport|Manokwari
WASS|Sorong Airport|Sorong
WAST|Teminabuan Airport|Teminabuan
WASW|Wasior Airport|Wasior
WATO|Komodo Airport|Labuan Bajo, East Nusa Tenggara
WIAA|Maimun Saleh Airport|Sabang, Aceh
WIAS|Abdul Rachman Saleh Airport|Malang, East Java
WIBB|Sultan Syarif Qasim II International Airport (Simpang Tiga Airport)|Pekanbaru, Riau
WIBD|Pinang Kampai Airport|Dumai, Riau
WIBR|Rokot Airport|Sipura
WIBT|Sunjai Bati Airport|Tanjung Balai
WICC|Husein Sastranegara Airport|Bandung, West Java
WICD|Penggung Airport|Cirebon Regency, West Java
WICM|Tasikmalaya Airport|Tasikmalaya, West Java
WIDD|Hang Nadim Airport|Batam, Riau Islands
WIHH|Halim Perdanakusuma International Airport|Jakarta
WIHL|Tunggul Wulung Airport|Cilacap, Central Java
WIIC|Penggung Airport|Cirebon, West Java
WIII|Soekarno-Hatta International Airport|Cengkareng, Banten (near Jakarta)
WIIJ|Adisucipto International Airport|Yogyakarta, Yogyakarta (special region)
WIIP|Pondok Cabe Airport|Jakarta
WIIS|Achmad Yani International Airport|Semarang, Central Java
WIIT|Radin Inten II Airport (Branti Airport)|Bandar Lampung, Lampung
WIIX|Jakarta (City) Airport|Jakarta
WIKD|Bulutumbang Airport|Tanjung Pandan
WIKK|Pangkal Pinang Airport|Pangkal Pinang, Bangka-Belitung Islands
WIKL|Silampari Airport|Lubuk Linggau, Musi Rawas, South Sumatra
WIKN|Raja Haji Fisabilillah Airport|Tanjung Pinang, Riau Islands
WIKS|Dabo Airport|Singkep, Riau
WIMB|Binaka Airport|Gunungsitoli, North Sumatra
WIME|Aek Godang Airport|Padang Sidempuan
WIMG|Tabing Airport (replaced by Minangkabau International Airport)|Padang, West Sumatra
WIMM|Polonia International Airport|Medan, North Sumatra
WIOG|Nanga Pinoh Airport|Kalimantan
WIOK|Rahadi Oesman Airport|Ketapang
WIOM|Matak Airport|Anambas Islands, Riau Province
WION|Ranai Airport|Natuna, Riau Islands
WIOO|Supadio Airport|Pontianak, West Kalimantan
WIOP|Pangsuma Airport|Putussibau
WIOS|Sintang Airport|Sintang
WIPA|Sultan Thaha Airport|Jambi
WIPL|Fatmawati Soekarno Airport|Bengkulu
WIPP|Sultan Mahmud Badaruddin II Airport|Palembang, South Sumatra
WIPQ|Pendopo Airport|Pendopo
WIPR|Japura Airport|Rengat, Riau
WIPT|Minangkabau International Airport (replaced Tabing Airport)|Ketaping / Padang, West Sumatra
WIPU|Muko Muko Airport|Sumatra
WIPV|Keluang Airport|Keluang
WITA|Teuku Cut Ali Airport|Tapak Tuan
WITC|Cut Nyak Dien Airport|Meulaboh, Aceh
WITL|Lhok Sukon Airport|Lhok Sukon (Lhoksukon), Aceh
WITT|Sultan Iskandarmuda Airport (Blang Bintang Airport)|Banda Aceh, Aceh
WQKN|Primapun Airport|Primapun
WAOO|Syamsudin Noor Airport|Banjarmasin, South Kalimantan
WAOC|Batulicin Airport|Batulicin, South Kalimantan
WAOI|Iskandar Airport|Pangkalan Bun
WAOK|Stagen Airport|Kotabaru
WAON|Warukin Airport|Tanjung, South Kalimantan
WAOP|Tjilik Riwut Airport (Panarung Airport)|Palangkaraya, Central Kalimantan
WAOS|Sampit Airport|Sampit
WRKA|Haliwen Airport|Atambua
WRKB|Padhameleda Airport|Bajawa
WATC|Maumere Airport|Maumere
WATE|H. Hasan Aroeboesman Airport|Ende, East Nusa Tenggara
WATG|Satartacik Airport|Ruteng
WATT|El Tari Airport (Eltari Airport)|Kupang, East Nusa Tenggara
WRKL|Gewayentana Airport|Larantuka
WRKO|Komodo Airport|Labuhan Bajo
WRLB|Long Bawan Airport|Long Bawan
WRLC|Bontang Airport|Bontang
WRLF|Nunukan Airport|Nunukan, East Kalimantan
WRLH|Tanah Grogot Airport|Tanah Grogot
WRLP|Long Apung Airport|Long Apung
WRLR|Juwata Airport|Tarakan, East Kalimantan
WRLS|Temindung Airport|Samarinda, East Kalimantan
WRLT|Santan Airport|Tanjung Santan
WRLV|Bunyu Airport|Bunyu, East Kalimantan
WRRA|Selaparang Airport|Mataram, West Nusa Tenggara
WADB|Muhammad Salahuddin Airport|Bima
WADS|Sumbawa Besar Airport|Sumbawa, West Nusa Tenggara
WADT|Tambolaka Airport|Waikabubak, East Nusa Tenggara
WADW|Waingapu Airport|Waingapu, East Nusa Tenggara
WARC|Ngloram Airport|Cepu
WARR|Juanda International Airport|Surabaya, East Java
WARQ|Adisumarmo International Airport (Adi Sumarmo Wiryokusumo)|Surakarta (Solo), Central Java
WRST|Trunojoyo Airport|Sumenep
WBAK|Anduki Airfield|Anduki / Seria
WBSB|Brunei International Airport|Bandar Seri Begawan
WBGA|Long Atip Airport|Long Atip
WBGB|Bintulu Airport|Bintulu, Sarawak
WBGC|Belaga Airport|Belaga, Sarawak
WBGD|Long Semado Airport|Long Semado / Lawas, Sarawak
WBGE|Long Geng Airport|Long Geng
WBGF|Long Lellang Airport|Long Lellang, Sarawak
WBGG|Kuching International Airport|Kuching, Sarawak
WBGI|Long Seridan Airport|Long Seridan, Sarawak
WBGJ|Limbang Airport|Limbang, Sarawak
WBGK|Mukah Airport|Mukah, Sarawak
WBGL|Long Akah Airport|Long Akah
WBGM|Marudi Airport|Marudi, Sarawak
WBGN|Sematan Airport|Sematan
WBGO|Lio Matu Airport|Lio Matu
WBGP|Kapit Airport|Kapit, Sarawak
WBGQ|Ba'kelalan Airport|Ba'kelalan, Sarawak
WBGR|Miri Airport|Miri, Sarawak
WBGS|Sibu Airport|Sibu, Sarawak
WBGT|Tanjung Manis Airport|Tanjung Manis
WBGU|Long Sukang Airport|Long Sukang, Sarawak
WBGW|Lawas Airport|Lawas, Sarawak
WBGY|Simanggang Airport|Sri Aman, Sarawak
WBGZ|Bario Airport|Bario, Sarawak
WBKA|Semporna Airport|Semporna, Sabah
WBKB|Kota Belud Airport|Kota Belud, Sabah
WBKD|Lahad Datu Airport|Lahad Datu, Sabah
WBKE|Telupid Airport|Telupid
WBKG|Keningau Airport|Keningau, Sabah
WBKH|Sahabat Airport|Sahabat, Sabah
WBKK|Kota Kinabalu International Airport|Kota Kinabalu, Sabah
WBKL|RMAF Labuan|Labuan, Sabah
WBKM|Tommanggong Airport|Tommanggong
WBKN|Long Pasia Airport|Long Pasia, Sabah
WBKO|Sepulot Airport|Sepulot
WBKP|Pamol Airport|Pamol
WBKR|Ranau Airport|Ranau, Sabah
WBKS|Sandakan Airport|Sandakan, Sabah
WBKT|Kudat Airport|Kudat, Sabah
WBKU|Kuala Penyu Airport|Kuala Penyu, Sabah
WBKW|Tawau Airport|Tawau, Sabah
WBMU|Mulu Airport|Mulu, Sarawak
WMAA|Bahau Airport|Bahau, Negeri Sembilan
WMAB|Batu Pahat Airport|Batu Pahat, Johor
WMAC|Benta Airport|Benta, Pahang
WMAD|Bentong Airport|Bentong, Pahang
WMAE|Bidor Airport|Bidor, Perak
WMAH|RMAF Grik|Grik
WMAJ|Jendarata Airport|Jendarata
WMAN|Sungai Tiang Airport|Sungai Tiang
WMAO|Kong Kong Airport|Kong Kong, Johor
WMAP|Kluang Airport|Kluang, Johor
WMAQ|Labis Airport|Labis, Johor
WMAU|Mersing Airport|Mersing, Johor
WMAV|Muar Airport|Muar, Johor
WMAZ|Segamat Airport|Segamat, Johor
WMBA|Sitiawan Airport|Sitiawan, Perak
WMBB|Sungei Patani Airport|Sungei Patani
WMBE|Temerloh Airport|Temerloh, Pahang
WMBF|Ulu Bernam Airport|Ulu Bernam
WMBH|RMAF Kroh|Kroh
WMBI|Tekah Airport / Taiping Airport|Taiping, Perak
WMBJ|Jugra Airport|Jugra, Selangor
WMBT|Tioman Airport|Tioman Island (Pulau Tioman), Pahang
WMGK|RMAF Gong Kedak|Gong Kedak Terengganu
WMKA|Sultan Abdul Halim Airport|Alor Star, Kedah
WMKB|RMAF Butterworth|Butterworth, Penang
WMKC|Sultan Ismail Petra Airport|Kota Bharu, Kelantan
WMKD|Sultan Haji Ahmad Shah Airport (formally Padang Geroda Airport) / (RMAF Kuantan)|Kuantan, Pahang
WMKE|Kerteh Airport|Kerteh, Terengganu
WMKF|Simpang Airport / RMAF Simpang|Sungai Besi, Kuala Lumpur
WMKI|Sultan Azlan Shah Airport|Ipoh, Perak
WMKJ|Senai International Airport (Sultan Ismail Int'l)|Senai / Johor Bahru, Johor
WMKK|Kuala Lumpur International Airport|Sepang, Selangor
WMKL|Langkawi International Airport|Langkawi (Pulau Langkawi), Kedah
WMKM|Batu Berendam Airport (Malacca Airport)|Malacca
WMKN|Sultan Mahmud Airport|Kuala Terengganu, Terengganu
WMKP|Penang International Airport|George Town, Penang
WMKS|Sungai Besi Airport|Kuala Lumpur
WMLH|Lumut Airport|Lumut, Perak
WMLU|Lutong Airport|Lutong
WMPA|Pangkor Airport|Pulau Pangkor
WMPR|Redang Airport|Pulau Redang
WMSA|Sultan Abdul Aziz Shah Airport|Subang Jaya, Selangor
WPAT|Atauro Airport|Atauro
WPDB|Suai Airport|Suai
WPDL|Presidente Nicolau Lobato International Airport (Comoro Int'l)|Dili
WPEC|Cakung Airport|Baucau
WPFL|Fuiloro Airport|Fuiloro
WPMN|Maliana Airport|Maliana
WPOC|Oecussi Airport|Oecussi
WPVQ|Viqueque Airport|Viqueque
WSAC|Changi Air Base (RSAF)|Changi
WSAG|Sembawang Air Base (RSAF)|Singapore
WSAP|Paya Lebar Air Base (RSAF)|Singapore
WSAT|Tengah Air Base (RSAF)|Tengah
WSSL|Seletar Airport|Seletar
WSSS|Singapore Changi Airport|Changi
YABA|Albany Airport|Albany, Western Australia
YAMB|RAAF Amberley|Ipswich, Queensland
YAPH|Alpha Airport|Alpha, Queensland
YARA|Ararat Airport|Ararat, Victoria
YARM|Armidale Airport|Armidale, New South Wales
YAYE|Ayers Rock Airport|Yulara, Northern Territory
YBAF|Archerfield Airport|Archerfield, Queensland
YBAR|Barcaldine Airport|Barcaldine, Queensland
YBAS|Alice Springs Airport|Alice Springs, Northern Territory
YBBN|Brisbane Airport|Brisbane, Queensland
YBCG|Gold Coast Airport|Coolangatta, Queensland
YBCK|Blackall Airport|Blackall, Queensland
YBCS|Cairns International Airport|Cairns, Queensland
YBCV|Charleville Airport|Charleville, Queensland
YBDG|Bendigo Airport|Bendigo, Victoria
YBDV|Birdsville Airport|Birdsville, Queensland
YBHI|Broken Hill Airport|Broken Hill, New South Wales
YBHM|Hamilton Island Airport|Hamilton Island, Queensland
YBIE|Bedourie Airport|Bedourie, Queensland
YBKE|Bourke Airport|Bourke, New South Wales
YBLA|Benalla Airport|Benalla, Victoria
YBLN|Busselton Regional Airport|Busselton, Western Australia
YBLT|Ballarat Airport|Ballarat, Victoria
YBMA|Mount Isa Airport|Mount Isa, Queensland
YBMC|Maroochydore/Sunshine Coast Airport|Marcoola, Queensland
YBMK|Mackay Airport|Mackay, Queensland
YBNA|Ballina/Byron Gateway Airport|Ballina, New South Wales
YBNS|Bairnsdale Airport|Bairnsdale, Victoria
YBOK|Oakey Army Aviation Centre|Oakey, Queensland
YBOU|Boulia Airport|Boulia, Queensland
YBPN|Proserpine / Whitsunday Coast Airport|Proserpine, Queensland
YBRK|Rockhampton Airport|Rockhampton, Queensland
YBRM|Broome International Airport|Broome, Western Australia
YBRN|Balranald Airport|Balranald, New South Wales
YBRS|Barwon Heads Airport|Barwon Heads, Victoria
YBRW|Brewarrina Airport|Brewarrina, New South Wales
YBSG|RAAF Scherger|Weipa, Queensland
YBSS|Bacchus Marsh Airport|Bacchus Marsh, Victoria
YBTH|Bathurst Airport|Bathurst, New South Wales
YBTI|Bathurst Island Airport|Bathurst Island, Northern Territory
YBTL|Townsville International Airport / RAAF Townsville (joint use)|Townsville, Queensland
YBTR|Blackwater Airport|Blackwater, Queensland
YBUD|Bundaberg Airport|Bundaberg, Queensland
YBWP|Weipa Airport|Weipa, Queensland
YCAR|Carnarvon Airport|Carnarvon, Western Australia
YCBA|Cobar Airport|Cobar
YCBB|Coonabarabran Airport|Coonabarabran, New South Wales
YCBG|Cambridge Aerodrome|Cambridge, Tasmania
YCBP|Coober Pedy Airport|Coober Pedy, South Australia
YCBR|Collarenebri Airport|Collarenebri, New South Wales
YCCA|Chinchilla Airport|Chinchilla, Queensland
YCCY|Cloncurry Airport|Cloncurry, Queensland
YCDE|Cobden Airport|Cobden, Victoria
YCDU|Ceduna Airport|Ceduna, South Australia
YCEE|Cleve Airport|Cleve, South Australia
YCEM|Coldstream Airport|Coldstream, Victoria
YCFS|Coffs Harbour Airport|Coffs Harbour, New South Wales
YCHT|Charters Towers Airport|Charters Towers, Queensland
YCIN|RAAF Curtin|Derby, Western Australia
YCKI|Croker Island Airport|Croker Island, Northern Territory
YCKN|Cooktown Airport|Cooktown, Queensland
YCMT|Clermont Airport|Clermont, Queensland
YCMU|Cunnamulla Airport|Cunnamulla, Queensland
YCNK|Cessnock Airport|Cessnock, New South Wales
YCNM|Coonamble Airport|Coonamble, New South Wales
YCOE|Coen Airport|Coen, Queensland
YCOM|Cooma - Snowy Mountains Airport|Cooma, New South Wales
YCOR|Corowa Airport|Corowa, New South Wales
YCRG|Corryong Airport|Corryong, Victoria
YCTM|Cootamundra Airport|Cootamundra, New South Wales
YCUE|Cue Airport|Cue, Western Australia
YCWL|Cowell Airport|Cowell, South Australia
YCWR|Cowra Airport|Cowra, New South Wales
YDBI|Dirranbandi Airport|Dirranbandi, Queensland
YDBY|Derby Airport|Derby, Western Australia
YDKI|Dunk Island Airport|Dunk Island, Australia
YDLQ|Deniliquin Airport|Deniliquin, New South Wales
YDOC|Dochra Airfield|Singleton, New South Wales
YDPO|Devonport Airport|Devonport, Tasmania
YDYS|Dysart Airport|Dysart, Queensland
YECH|Echuca Airport|Echuca, Victoria
YELD|Elcho Island Airport|Elcho Island, Northern Territory
YEML|Emerald Airport|Emerald, Queensland
YENO|Enoggera HLS|Enoggera, Queensland
YESP|Esperance Airport|Esperance, Western Australia
YEVD|Evans Head Memorial Aerodrome|Evans Head, New South Wales
YFBS|Forbes Airport|Forbes, New South Wales
YFLI|Flinders Island Airport|Flinders Island (Whitemark), Tasmania
YFRT|Forrest Airport|Forrest, Western Australia
YFSK|Fiskville CFA Training Ground Airstrip|Fiskville, Victoria near Ballan
YFTZ|Fitzroy Crossing Airport|Fitzroy Crossing, Western Australia
YGAD|HMAS Stirling|Garden Island, Western Australia
YGDH|Gunnedah Airport|Gunnedah, New South Wales
YGDI|Goondiwindi Airport|Goondiwindi, Queensland
YGEL|Geraldton Airport|Geraldton, Western Australia
YGFN|Clarence Valley Regional Airport|Grafton, New South Wales
YGIN|RAAF Base Gingin|Gingin, Western Australia
YGLA|Gladstone Airport|Gladstone, Queensland
YGLB|Goulburn Airport|Goulburn, New South Wales
YGLG|Geelong Airport|Grovedale, Victoria
YGLI|Glen Innes Airport|Glen Innes, New South Wales
YGNB|RAAF Base Glenbrook (helipads only)|Glenbrook, New South Wales
YGPT|Garden Point Airport|Melville Island, Northern Territory
YGTE|Groote Eylandt Airport|Groote Eylandt (Alyangula), Northern Territory
YGTH|Griffith Airport|Griffith, New South Wales
YGWA|Goolwa Airport|Goolwa, South Australia
YGYM|Gympie Airport|Gympie, Queensland
YHAY|Hay Airport|Hay, New South Wales
YHBA|Hervey Bay Airport|Hervey Bay, Queensland
YHID|Horn Island Airport|Horn Island, Queensland
YHLC|Halls Creek Airport|Halls Creek, Western Australia
YHML|Hamilton Airport|Hamilton, Victoria
YHOT|Mount Hotham Airport|Bright, Victoria
YHOX|Hoxton Park Airport|Hoxton Park, New South Wales
YHPN|Hopetoun Airport|Hopetoun, Victoria
YHSM|Horsham Airport|Horsham, Victoria
YIMB|Kimba Airport|Kimba, South Australia
YITT|Mitta Mitta Airport|Mitta Mitta, Victoria
YIVL|Inverell Airport|Inverell, New South Wales
YJBY|Jervis Bay Airport|Jervis Bay, New South Wales
YKBY|Streaky Bay Airport|Streaky Bay, South Australia
YKER|Kerang Airport|Kerang, Victoria
YKII|King Island Airport|King Island (Currie), Tasmania
YKKG|Kalkgurung Airport|Kalkaringi, Northern Territory
YKMB|Karumba Airport|Karumba, Queensland
YKMP|Kempsey Airport|Kempsey, New South Wales
YKOW|Kowanyama Airport|Kowanyama, Queensland
YKRY|Kingaroy Airport|Kingaroy, Queensland
YKSC|Kingscote Airport|Kingscote, Kangaroo Island, South Australia
YKTN|Kyneton Airport|Kyneton, Victoria
YLEC|Leigh Creek Airport|Leigh Creek, South Australia
YLED|Lethbridge Airpark|Lethbridge, Victoria
YLEG|Leongatha Airport|Leongatha, Victoria
YLEO|Leonora Airport|Leonora, Western Australia
YLHI|Lord Howe Island Airport|Lord Howe Island, New South Wales
YLHR|Lockhart River Airport|Lockhart River, Queensland
YLIL|Lilydale Airport|Lilydale, Victoria
YLIS|Lismore Airport|Lismore, New South Wales
YLOX|Loxton Airport|Loxton, South Australia
YLRD|Lightning Ridge Airport|Lightning Ridge, New South Wales
YLRE|Longreach Airport|Longreach, Queensland
YLST|Leinster Airport|Leinster, Western Australia
YLTN|Laverton Airport|Laverton, Western Australia
YLTV|Latrobe Valley Airport|Morwell, Victoria
YLVK|Lavarack Barracks|Townsville, Queensland
YMAV|Avalon Airport|Avalon, Victoria
YMAY|Albury Airport|Albury, New South Wales
YMBA|Mareeba Airport|Mareeba, Queensland
YMBD|Murray Bridge Airport|Murray Bridge, South Australia
YMBU|Maryborough Airport|Maryborough, Victoria
YMCO|Mallacoota Airport|Mallacoota, Victoria
YMDG|Mudgee Airport|Mudgee, New South Wales
YMEK|Meekatharra Airport|Meekatharra, Western Australia
YMEN|Essendon Airport|Essendon North, Victoria
YMER|Merimbula Airport|Merimbula, New South Wales
YMES|RAAF East Sale|Sale, Victoria
YMGD|Maningrida Airport|Maningrida, Northern Territory
YMHB|Hobart International Airport|Cambridge, Tasmania
YMIA|Mildura Airport|Mildura, Victoria
YMLT|Launceston Airport|Launceston, Tasmania
YMMB|Moorabbin Airport|Moorabbin, Victoria
YMML|Melbourne Airport|Melbourne Airport, Victoria
YMNE|Mount Keith Airport|Mount Keith, Western Australia
YMNG|Mangalore Airport|Mangalore, Victoria
YMOG|Mount Magnet Airport|Mount Magnet, Western Australia
YMOR|Moree Airport|Moree, New South Wales
YMPC|RAAF Williams|Point Cook, Victoria
YMRB|Moranbah Airport|Moranbah, Queensland
YMRY|Moruya Airport|Moruya, New South Wales
YMTG|Mount Gambier Airport|Mount Gambier, South Australia
YMYB|Maryborough Airport|Maryborough, Queensland
YNAR|Narrandera Airport|Narrandera, New South Wales
YNBR|Narrabri Airport|Narrabri, New South Wales
YNGU|Ngukurr Airport|Roper River, Northern Territory
YNHL|Nhill Airport|Nhill, Victoria
YNRC|Naracoorte Airport|Naracoorte, South Australia
YNRM|Narromine Airport|Narromine, New South Wales
YNTN|Normanton Airport|Normanton, Queensland
YNWN|Newman Airport|Newman, Western Australia
YNYN|Nyngan Airport|Nyngan, New South Wales
YOLA|Colac Airport|Colac, Victoria
YOLW|Onslow Airport|Onslow, Western Australia
YOOD|Oodnadatta Airport|Oodnadatta, South Australia
YORB|Orbost Airport|Orbost, Victoria
YORG|Orange Airport|Orange, New South Wales
YPAD|Adelaide International Airport|Adelaide, South Australia
YPAG|Port Augusta Airport|Port Augusta, South Australia
YPBO|Paraburdoo Airport|Paraburdoo, Western Australia
YPCC|Cocos (Keeling) Island International Airport|Cocos (Keeling) Islands
YPDN|Darwin International Airport / RAAF Darwin (joint use)|Darwin, Northern Territory
YPEA|RAAF Pearce|Bullsbrook, Western Australia
YPED|RAAF Edinburgh|Salisbury, South Australia
YPGV|Gove Airport|Nhulunbuy, Northern Territory
YPIR|Port Pirie Airport|Port Pirie, South Australia
YPJT|Jandakot Airport|Jandakot, Western Australia
YPKA|Karratha Airport|Karratha, Western Australia
YPKG|Kalgoorlie-Boulder Airport|Kalgoorlie, Western Australia
YPKS|Parkes Airport|Parkes, New South Wales
YPKT|Port Keats Airfield|Port Keats, Northern Territory
YPKU|Kununurra Airport|Kununurra, Western Australia
YPLC|Port Lincoln Airport|Port Lincoln, South Australia
YPLM|RAAF Learmonth (joint use)|Exmouth, Western Australia
YPMQ|Port Macquarie Airport|Port Macquarie, New South Wales
YPOD|Portland Airport|Portland, Victoria
YPPD|Port Hedland International Airport|Port Hedland, Western Australia
YPPF|Parafield Airport|Salisbury, South Australia
YPPH|Perth International Airport|Redcliffe, Western Australia
YPTN|RAAF Tindal|Katherine, Northern Territory
YPWR|RAAF Woomera|Woomera, South Australia
YPXM|Christmas Island Airport|Christmas Island
YPAM|Palm Island Airport|Palm Island, Queensland
YQLP|Quilpie Airport|Quilpie, Queensland
YRED|Redcliffe Airport|Rothwell, Queensland
YREN|Renmark Airport|Renmark, South Australia
YRMD|Richmond Airport|Richmond, Queensland
YROI|Robinvale Airport|Robinvale, Victoria
YROM|Roma Airport|Roma, Queensland
YRTI|Rottnest Island Airport|Rottnest Island, Western Australia
YSBK|Bankstown Airport|Bankstown, New South Wales
YSCB|Canberra International Airport|Canberra, Australian Capital Territory
YSCN|Camden Airport|Camden, New South Wales
YSDU|Dubbo Airport|Dubbo, New South Wales
YSGE|Saint George Airport|Saint George, Queensland
YSHK|Shark Bay Airport|Denham, Western Australia
YSHR|Whitsunday Airport|Shute Harbour, Airlie Beach, Queensland
YSHT|Shepparton Airport|Shepparton, Victoria
YSHW|Holsworthy Barracks|Holsworthy, New South Wales
YSMI|Smithton Airport|Smithton, Tasmania
YSNB|Snake Bay Airport|Melville Island, Northern Territory
YSNF|Norfolk Island Airport|Norfolk Island
YSNW|HMAS Albatross|Nowra, New South Wales
YSPT|Southport Airport|Southport, Queensland
YSRI|RAAF Richmond|Richmond, New South Wales
YSRN|Strahan Airport|Strahan, Tasmania
YSSY|Sydney Airport|Mascot, New South Wales
YSTH|Saint Helens Airport|Saint Helens, Tasmania
YSTW|Tamworth Airport|Tamworth, New South Wales
YSWG|Wagga Wagga Airport|Wagga Wagga, New South Wales
YSWH|Swan Hill Airport|Swan Hill, Victoria
YSWL|Stawell Airport|Stawell, Victoria
YTAM|Taroom Airport|Taroom, Queensland
YTEM|Temora Airport|Temora, New South Wales
YTGM|Thargomindah Airport|Thargomindah, Queensland
YTIB|Tibooburra Airport|Tibooburra, New South Wales
YTMU|Tumut Airport|Tumut, New South Wales
YTNG|Thangool Airport|Thangool, Queensland
YTNK|Tennant Creek Airport|Tennant Creek, Northern Territory
YTOC|Tocumwal Airport|Tocumwal, New South Wales
YTQY|Torquay Airport|Torquay, Victoria
YTRE|Taree Airport|Taree, New South Wales
YTWB|Toowoomba Airport|Toowoomba, Queensland
YTYA|Tyabb Airport|Tyabb, Victoria
YWBL|Warrnambool Airport|Warrnambool, Victoria
YWDH|Windorah Airport|Windorah, Queensland
YWGT|Wangaratta Airport|Wangaratta, Victoria
YWHA|Whyalla Airport|Whyalla, South Australia
YWIS|Williamson Airfield|Rockhampton, Queensland
YWKB|Warracknabeal Airport|Warracknabeal, Victoria
YWKI|Waikerie Airport|Waikerie, South Australia
YWKS|Wilkins Runway|Wilkes Land, Antarctica
YWLG|Walgett Airport|Walgett, New South Wales
YWLM|Newcastle - Williamtown Airport / RAAF Williamtown (joint use)|Newcastle, New South Wales
YWLU|Wiluna Airport|Wiluna, Western Australia
YWOL|Illawarra Regional Airport|Wollongong, New South Wales
YWRN|Warren Airport|Warren, New South Wales
YWSG|Watts Bridge Memorial Airfield|Watts Bridge, Queensland
YWSL|West Sale Airport|Sale, Victoria
YWTN|Winton Airport|Winton, Queensland
YWUD|Wudinna Airport|Wudinna, South Australia
YWVA|Warnervale Airport|Warnervale, New South Wales
YWWL|West Wyalong Airport|West Wyalong, New South Wales
YWYM|Wyndham Airport|Wyndham, Western Australia
YWYY|Burnie Airport|Wynyard, Tasmania
YYNG|Young Airport|Young, New South Wales
YYRM|Yarram Airport|Yarram, Victoria
YYWG|Yarrawonga Airport|Yarrawonga, Victoria
ZBAA|Beijing Capital International Airport|Beijing
ZBCF|Chifeng Airport|Chifeng, Inner Mongolia
ZBCZ|Changzhi Airport|Changzhi, Shanxi
ZBDT|Datong Airport|Datong, Shanxi
ZBHH|Hohhot Baita International Airport|Hohhot, Inner Mongolia
ZBLA|Hailar Dongshan Airport|Hailar, Inner Mongolia
ZBNY|Beijing Nanyuan Airport|Beijing
ZBOW|Baotou Airport|Baotou, Inner Mongolia
ZBSH|Qinhuangdao Shanhaiguan Airport|Qinhuangdao, Hebei
ZBSJ|Shijiazhuang Daguocun International Airport|Shijiazhuang, Hebei
ZBTJ|Tianjin Binhai International Airport|Tianjin
ZBTL|Tongliao Airport|Tongliao, Inner Mongolia
ZBUL|Ulanhot Airport|Ulanhot, Inner Mongolia
ZBXT|Xingtai Airport|Xingtai, Hebei
ZBYN|Taiyuan Wusu Airport|Taiyuan, Shanxi
ZGBH|Beihai Airport|Beihai, Guangxi
ZGGG|Guangzhou Baiyun International Airport|Guangzhou, Guangdong
ZGHA|Changsha Huanghua International Airport|Changsha, Hunan
ZGHY|Hengyang Airport|Hengyang, Hunan
ZGKL|Guilin Liangjiang International Airport|Guilin, Guangxi
ZGNN|Nanning Wuxu International Airport|Nanning, Guangxi
ZGOW|Shantou Airport|Shantou, Guangdong
ZGSD|Zhuhai International Airport|Zhuhai, Guangdong
ZGSY|Sanya Fenghuang International Airport|Sanya, Hainan
ZGSZ|Shenzhen Bao'an International Airport|Shenzhen, Guangdong
ZGWZ|Wuzhou Changzhoudao Airport|Wuzhou, Guangxi
ZGZH|Liuzhou Airport|Liuzhou, Guangxi
ZGZJ|Zhanjiang Airport|Zhanjiang, Guangdong
ZHAY|Anyang Airport|Anyang, Henan
ZHCC|Zhengzhou Xinzheng International Airport|Zhengzhou, Henan
ZHHH|Wuhan Tianhe Airport|Wuhan, Hubei
ZHLY|Luoyang Airport|Luoyang, Henan
ZHNY|Nanyang Airport|Nanyang, Henan
ZHSS|Shashi Airport|Shashi (Jingzhou), Hubei
ZHXF|Xiangfan Airport|Xiangfan, Hubei
ZHYC|Yichang Airport|Yichang, Hubei
ZJSY|Sanya Phoenix International Airport|Sanya, Hainan
ZLAN|Lanzhou Airport|Lanzhou, Gansu
ZLDH|Dunhuang Airport|Dunhuang, Gansu
ZLGM|Golmud Airport|Golmud, Qinghai
ZLHZ|Hanzhong Airport|Hanzhong, Shaanxi
ZLIC|Yinchuan Helanshan Airport|Yinchuan, Ningxia
ZLJN|Jining Airport|Jining, Shandong
ZLJQ|Jiuquan Airport|Jiuquan, Gansu
ZLLL|Lanzhou Zhongchuan Airport (Lanzhou West Airport)|Lanzhou, Gansu
ZLQY|Qingyang Airport|Qingyang, Gansu
ZLXN|Xining Caojiabu Airport|Xining, Qinghai
ZLXY|Xi'an Xianyang International Airport|Xi'an, Shaanxi
ZLYA|Yan'an Airport|Yan'an, Shaanxi
ZLYL|Yulin Airport|Yulin, Shaanxi
ZPBS|Baoshan Airport|Baoshan, Yunnan
ZPJH|Xishuangbanna Gasa Airport|Jinghong, Yunnan
ZPLJ|Lijiang Airport|Lijiang, Yunnan
ZPLX|Luxi Mangshi Airport|Luxi City, Yunnan
ZPPP|Kunming Wujiaba International Airport|Kunming, Yunnan
ZPSM|Simao Airport|Simao, Yunnan
ZPZT|Zhaotong Airport|Zhaotong, Yunnan
ZSAM|Xiamen Gaoqi International Airport|Xiamen, Fujian
ZSAQ|Anqing Airport|Anqing, Anhui
ZSBB|Bengbu Airport|Bengbu, Anhui
ZSCG|Changzhou Benniu Airport|Changzhou, Jiangsu
ZSCN|Nanchang Changbei International Airport|Nanchang, Jiangxi
ZSFY|Fuyang Airport|Fuyang, Anhui
ZSFZ|Fuzhou Changle International Airport|Fuzhou, Fujian
ZSGZ|Ganzhou Huangjin Airport|Ganzhou, Jiangxi
ZSHC|Hangzhou Xiaoshan International Airport|Hangzhou, Zhejiang
ZSJD|Jingdezhen Airport|Jingdezhen, Jiangxi
ZSJJ|Jiujiang Lushan Airport|Jiujiang, Jiangxi
ZSJN|Jinan Yaoqiang Airport|Jinan, Shandong
ZSLG|Lianyungang Airport|Lianyungang, Jiangsu
ZSLQ|Huangyan Luqiao Airport|Huangyan, Zhejiang
ZSNB|Ningbo Lishe International Airport|Ningbo, Zhejiang
ZSNJ|Nanjing Lukou International Airport|Nanjing, Jiangsu
ZSOF|Hefei Luogang International Airport|Hefei, Anhui
ZSPD|Shanghai Pudong International Airport|Shanghai
ZSQD|Qingdao Liuting International Airport|Qingdao, Shandong
ZSQZ|Quanzhou Jinjiang Airport|Quanzhou, Fujian
ZSSL|Longhua Airport|Shanghai
ZSSS|Shanghai Hongqiao International Airport|Shanghai
ZSSZ|Suzhou Guangfu Airport|Suzhou, Jiangsu
ZSTX|Huangshan Tunxi International Airport|Huangshan, Anhui
ZSWF|Weifang Airport|Weifang, Shandong
ZSWX|Wuxi Airport|Wuxi, Jiangsu
ZSWY|Nanping Wuyishan Airport|Wuyishan, Nanping, Fujian
ZSWZ|Wenzhou International Airport|Wenzhou, Zhejiang
ZSXZ|Xuzhou Airport|Xuzhou, Jiangsu
ZSYT|Yantai Laishan Airport|Yantai, Shandong
ZSYW|Yiwu Airport|Yiwu, Zhejiang
ZSZS|Zhoushan Airport|Zhoushan, Zhejiang
ZUBD|Qamdo Bangda Airport|Bangda, Tibet Autonomous Region
ZUCK|Chongqing Jiangbei International Airport|Chongqing
ZUDX|Dachuan Airport|Dazhou, Sichuan
ZUGY|Guiyang Longdongbao Airport|Guiyang, Guizhou
ZUJZ|Jiuzhaigou Huanglong Airport|Songpan, Sichuan
ZULS|Lhasa Gonggar Airport|Lhasa, Tibet Autonomous Region
ZUNC|Nanchong Airport|Nanchong, Sichuan
ZUTR|Tongren Daxing Airport|Tongren, Guizhou
ZUUU|Chengdu Shuangliu International Airport|Chengdu, Sichuan
ZUXC|Xichang Qingshan Airport|Xichang, Sichuan
ZUYB|Yibin Airport|Yibin, Sichuan
ZUZY|Zunyi Airport|Zunyi, Guizhou
ZWAK|Aksu Airport|Aksu, Xinjiang
ZWAT|Altay Airport|Altay, Xinjiang
ZWFY|Fuyun Airport|Fuyun, Xinjiang
ZWHM|Hami Airport|Hami (Kumul), Xinjiang
ZWKC|Kuqa Airport|Kuqa (Kucha), Xinjiang
ZWKL|Korla Airport|Korla, Xinjiang
ZWKM|Karamay Airport|Karamay, Xinjiang
ZWSH|Kashgar Airport (Kashi Airport)|Kashgar (Kashi), Xinjiang
ZWTN|Hotan Airport|Hotan (Khotan), Xinjiang
ZWWW|Urumqi Diwopu International Airport|Urumqi, Xinjiang
ZWYN|Yining Airport|Yining, Xinjiang
ZYAS|Anshan Airport|Anshan, Liaoning
ZYCC|Changchun Longjia International Airport|Changchun, Jilin
ZYDD|Dandong Airport|Dandong, Liaoning
ZYHB|Harbin Taiping International Airport|Harbin, Heilongjiang
ZYHE|Heihe Airport|Heihe, Heilongjiang
ZYJL|Jilin Airport|Jilin City, Jilin
ZYJM|Jiamusi Airport|Jiamusi, Heilongjiang
ZYJZ|Jinzhou Airport|Jinzhou, Liaoning
ZYMD|Mudanjiang Airport|Mudanjiang, Heilongjiang
ZYQQ|Qiqihar Airport|Qiqihar, Heilongjiang
ZYTL|Dalian Zhoushuizi International Airport|Dalian, Liaoning
ZYTN|Tonghua Liuhe Airport|Tonghua, Jilin
ZYTX|Shenyang Taoxian International Airport|Shenyang, Liaoning
ZYYJ|Yanji Chaoyangchuan Airport|Yanji, Jilin
ZKPY|Sunan International Airport|Pyongyang
ZMAH|Arvaikheer Airport|Arvaikheer, Övörkhangai
ZMAT|Altai Airport|Altai, Govi-Altai
ZMBH|Bayankhongor Airport|Bayankhongor, Bayankhongor
ZMBN|Bulgan Airport|Bulgan, Bulgan
ZMBS|Bulgan Airport, Khovd|Bulgan, Khovd, Khovd
ZMBU|Baruun-Urt Airport|Baruun-Urt, Sükhbaatar
ZMCD|Choibalsan Airport|Choibalsan, Dornod
ZMDZ|Dalanzadgad Airport|Dalanzadgad, Ömnögovi
ZMHH|Kharkhorin Airport|Kharkhorin, Övörkhangai
ZMHU|Khujirt Airport|Khujirt, Övörkhangai
ZMKD|Khovd Airport|Khovd, Khovd
ZMMG|Mandalgovi Airport|Mandalgovi, Dundgovi
ZMMN|Mörön Airport|Mörön, Khövsgöl
ZMTG|Tsetserleg Airport|Tsetserleg, Arkhangai
ZMUB|Chinggis Khaan International Airport (formerly Buyant Ukhaa Airport)|Ulan Bator (Ulaanbaatar)
ZMUG|Ulaangom Airport|Ulaangom, Uvs
ZMUH|Öndörkhaan Airport|Öndörkhaan, Khentii
ZMUL|Ölgii Airport|Ölgii, Bayan Ölgii
