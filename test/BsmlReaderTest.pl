#! /local/perl/bin/perl

use lib "../src/";
use BsmlReader;
use BsmlParserTwig;
use Data::Dumper;

my $reader = new BsmlReader;
my $parser = new BsmlParserTwig;

$parser->parse( \$reader, $ARGV[0] );

my $href = $reader->fetch_genome_pairwise_matches( 'PNEUMO_19', 'PNEUMO_16' );

print Dumper( %{$href->[0]} );
