#! /local/perl/bin/perl

use lib "../src/";
use BSML::BsmlReader;
use BSML::BsmlParserTwig;
use Data::Dumper; 

my $reader = new BSML::BsmlReader;
my $parser = new BSML::BsmlParserTwig;

$parser->parse( \$reader, $ARGV[0] );

$aahash = $reader->get_all_protein_dna( $ARGV[1] );
my @list = keys( %{$aahash} );

foreach my $k (@list)
{
    print ">$k\n";
    print $aahash->{$k};
    print "\n";
}

