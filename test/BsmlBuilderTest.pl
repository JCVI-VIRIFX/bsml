#! /local/perl/bin/perl

# client script to test the functionality of the helper functions defined i
# BsmlBuilder.pm

# The BsmlBuilder class mirrors the Java API defined in the LabBook Bsml Documentation
# for building Bsml sequences.

use lib "../src/";
use BsmlBuilder;

my $seqdat = 'agctagctagctagctagctagct';

my $doc = new BsmlBuilder;
$doc->makeCurrentDocument();

my $seq = $doc->createAndAddSequence( 'PF14_0392', 'pfa1 PF14_0392', '', 'dna' );
$doc->createAndAddSeqDataImport( $seq, 'fasta', '/usr/local/annotation/chr001.fa', 'CT1234' );

my $FTable = $doc->createAndAddFeatureTable( $seq, '', ''); 
my $FGroup = $doc->createAndAddFeatureGroup( $seq, 'FGroup1', 'PF14_0392-relationships' );

my $Feat = $doc->createAndAddFeatureWithLoc( $FTable, 'M1396-03861','' , 'GENE', '', '', 1, 7366, 0 );
$doc->createAndAddQualifier( $Feat, 'name', 'PF14_0392' );
$doc->createAndAddLink( $FGroup, 'GENE', '#M1396-03861' );

$Feat = $doc->createAndAddFeatureWithLoc( $FTable, 'M1396-03861-TRANSCRIPT', '', 'TRANSCRIPT', '', '', 1, 7366, 0 );
$doc->createAndAddFeatureGroupMember( $FGroup, 'M1396-03861-TRANSCRIPT', 'TRANSCRIPT', '', '' );

$Feat = $doc->createAndAddFeature( $FTable, 'M1396-03861-CDS', '', 'CDS', '', '' );
$doc->createAndAddSiteLoc( $Feat, 70, 0 );

$doc->createAndAddFeatureWithLoc( $FTable, 'M1396-03861-EXON1', '', 'EXON', '', '', 70, 110, 0 );
$doc->createAndAddFeatureGroupMember( $FGroup, 'M1396-03861-EXON1', 'EXON', '', '' );
$doc->createAndAddFeatureWithLoc( $FTable, 'M1396-03861-EXON2', '', 'EXON', '', '', 229, 289, 0 );
$doc->createAndAddFeatureGroupMember( $FGroup, 'M1396-03861-EXON2', 'EXON', '', '' );
$doc->createAndAddFeatureWithLoc( $FTable, 'M1396-03861-EXON3', '', 'EXON', '', '', 437, 660, 0 ); 
$doc->createAndAddFeatureGroupMember( $FGroup, 'M1396-03861-EXON3', 'EXON', '', '' );
$doc->createAndAddFeatureWithLoc( $FTable, 'M1396-03861-EXON4', '', 'EXON', '', '', 774, 982, 0 );
$doc->createAndAddFeatureGroupMember( $FGroup, 'M1396-03861-EXON4', 'EXON', '', '' );
$doc->createAndAddFeatureWithLoc( $FTable, 'M1396-03861-EXON5', '', 'EXON', '', '', 1256, 7366, 0 );
$doc->createAndAddFeatureGroupMember( $FGroup, 'M1396-03861-EXON5', 'EXON', '', '' );

$doc->write( 'output.xml' );



