#! /local/perl/bin/perl

# client script to test the functionality of the helper functions defined i
# BsmlBuilder.pm

# The BsmlBuilder class mirrors the Java API defined in the LabBook Bsml Documentation
# for building Bsml sequences.

use lib "/export/CVS/bsml/src/";

use BSML::BsmlBuilder;
use BSML::BsmlReader;
use BSML::BsmlParserTwig;
use Data::Dumper;

my $max = $ARGV[0];

for( my $i=0; $i<$max; $i++ )
{
    my $doc = new BSML::BsmlBuilder;
    $doc->makeCurrentDocument();

    my $seq = $doc->createAndAddSequence( 'PF14_0392', 'pfa1 PF14_0392', '', 'dna' );

    $doc->write( $i.'.bsml' );
}


my $parser = new BSML::BsmlParserTwig;

for( my $i=0; $i<$max; $i++ )
{
    my $reader = new BSML::BsmlReader;
    print "Reading ".$i.".bsml\n";
    $parser->parse( \$reader, $i.'.bsml' );
}
