#! /local/perl/bin/perl

use lib "../src/";
use BsmlReader;
use BsmlParserTwig;
use Data::Dumper;

my $reader = new BsmlReader;
my $parser = new BsmlParserTwig;

$parser->parse( \$reader, $ARGV[0] );

my $aa_seqs = $reader->geneIdtoGenomicCoords( 'ORFO01806' );

print Dumper( %{$aa_seqs->[0]} );
