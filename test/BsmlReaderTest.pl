#! /local/perl/bin/perl

use lib "../src/";
use BsmlReader;
use BsmlParserTwig;
use Data::Dumper; 

my $reader = new BsmlReader;
my $parser = new BsmlParserTwig;

$parser->parse( \$reader, $ARGV[0] );

my $TranscriptCoordList = $reader->geneIdtoGenomicCoords( '_68068.t00002' );

foreach $cds (@{$reader->geneCoordstoCDSList( $TranscriptCoordList )})
{
    print $cds."\n";
}
