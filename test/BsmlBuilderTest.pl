#! /local/perl/bin/perl

# client script to test the functionality of the helper functions defined i
# BsmlBuilder.pm

# The BsmlBuilder class mirrors the Java API defined in the LabBook Bsml Documentation
# for building Bsml sequences.

use lib "../src/";
use BsmlBuilder;

my $seqdat = 'agctagctagctagctagctagct';

my $doc = new BsmlBuilder;
my $seq = $doc->createAndAddSequence( '_bsml001', 'test_basic_sequence', length( $seqdat ), 'dna' );

my $seq2 = $doc->createAndAddExtendedSequenceN( id => '_bsml002', title => 'test_extended_sequence', length => '24', molecule => 'dna', topology => 'linear' );

$doc->createAndAddSeqData( $seq, $seqdat );

my $FTable = $doc->createAndAddFeatureTable( '_bsml001', '_FeatT001', 'feature_table_1', 'feature-table'); 
my $FTable2 = $doc->createAndAddFeatureTable( $seq2, '_FeatT002', 'feature_table_2', 'feature-table' );
my $FTable3 = $doc->createAndAddFeatureTableN( seq => $seq2, id => '' );

$doc->createAndAddReference( $FTable3, '', 'Chris Hauser', 'Bsml Object Layer', '' );

my $feat = $doc->createAndAddFeatureWithLocN( FTable => '_FeatT001', title=>'feature-001', class=>'feature', comment=>'test', start=>'10', end=>'10', complement=>'0' );

$doc->createAndAddQualifier( $feat, 'gene', 'ubiquitin' );

$doc->write( 'output.xml' );



