#! /local/perl/bin/perl

# client script to test the functionality of the helper functions defined i
# BsmlBuilder.pm

# The BsmlBuilder class mirrors the Java API defined in the LabBook Bsml Documentation
# for building Bsml sequences.

use lib "../src/";
use BSML::BsmlBuilder;
use BSML::BsmlReader;
use BSML::BsmlParserTwig;
use Data::Dumper;

$outfile = 'multi-out.bsml';

if( $ARGV[0] ){ $outfile = $ARGV[0] };

my $doc = new BSML::BsmlBuilder;
$doc->makeCurrentDocument();

$doc->createAndAddSequence( 'PF14_0392', 'pfa1 PF14_0392', '', 'dna' );
$doc->createAndAddSequence( 'PF14_0393', 'pfa1 PF14_0393', '', 'dna' );
$doc->createAndAddSequence( 'PF14_0394', 'pfa1 PF14_0394', '', 'dna' );

my $table = $doc->createAndAddMultipleAlignmentTable( 'molecule-type', 'nucleotide' );
my $summary = $doc->createAndAddAlignmentSummary( 'multipleAlignmentTable' => $table,
						  'seq-type' => 'nucleotide',
						  'seq-format' => 'FASTA' );

 $doc->createAndAddAlignedSequence( 'alignmentSummary' => $summary,
				   'seqref' => 'PF14_0392',
				   'seqnum' => '0',
				   'length' => '512',
				   'name' => 'pfa1 PF14_0392' );




$doc->createAndAddAlignedSequence( 'alignmentSummary' => $summary,
				   'seqref' => 'PF14_0393',
				   'seqnum' => '1',
				   'length' => '512',
				   'name' => 'pfa1 PF14_0393' );

$doc->createAndAddAlignedSequence( 'alignmentSummary' => $summary,
				   'seqref' => 'PF14_0394',
				   'seqnum' => '2',
				   'length' => '512',
				   'name' => 'pfa1 PF14_0394' );

my $pairs = $doc->createAndAddPairwiseAlignments( 'multipleAlignmentTable' => $table );

$doc->createAndAddAlignedPair( 'pairwiseAlignments' => $pairs,
			       'seqnum1' => 0,
			       'seqnum2' => 1,
			       'score' => 999 );

$doc->createAndAddAlignedPair( 'pairwiseAlignments' => $pairs,
			       'seqnum1' => 0,
			       'seqnum2' => 2,
			       'score' => 990 );

$doc->createAndAddAlignedPair( 'pairwiseAlignments' => $pairs,
			       'seqnum1' => 1,
			       'seqnum2' => 2,
			       'score' => 980 );

my $aln = $doc->createAndAddSequenceAlignment( 'multipleAlignmentTable' => $table,
					       'sequences' => 3 );

my $ref = $doc->createAndAddSequenceData( 'sequenceAlignment' => $aln,
				'seq-name' => 'pfa1 PF14_0392',
				'seq-data' => 'AGCTAGCTAGCT------------------------------------------' );

$ref->addBsmlAttr( 'seqnum', 5 );

$doc->createAndAddSequenceData( 'sequenceAlignment' => $aln,
				'seq-name' => 'pfa1 PF14_0393',
				'seq-data' => 'AGCTAGCTAGCT------------------------------------------' );

$doc->createAndAddSequenceData( 'sequenceAlignment' => $aln,
				'seq-name' => 'pfa1 PF14_0394',
				'seq-data' => 'AGCTAGCTAGCT------------------------------------------' );

my $organism = $doc->createAndAddOrganism( 'genome' => $doc->createAndAddGenome(),
					   'genus' => 'test-genus',
					   'species' => 'test-species' );

my $strain = $doc->createAndAddStrain( 'organism' => $organism,
				       'name' => 'test-strain-name',
				       'database' => 'chado_pmonas',
				       'source_database' => 'gps' );

$doc->write( $outfile );

my $reader = new BSML::BsmlReader;
my $parser = new BSML::BsmlParserTwig;

$parser->parse( \$reader, $outfile );

$reader->write( 'output_final.bsml' );

