#! /local/perl/bin/perl

use lib "../src/";
use BSML::BsmlReader;
use BSML::BsmlParserTwig;
use Data::Dumper; 

my $reader = new BSML::BsmlReader;
my $parser = new BSML::BsmlParserTwig;

$parser->parse( \$reader, $ARGV[0] );

my $TranscriptCoordList = $reader->geneIdtoGenomicCoords( '_68068.t00002' );

foreach $cds (@{$reader->geneCoordstoCDSList( $TranscriptCoordList )})
{
    print $cds."\n";
}
