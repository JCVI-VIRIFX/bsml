#! /local/perl/bin/perl

use lib "../src/";
use BSML::BsmlBuilder;

open( INFILE, $ARGV[0] ) or die "Could not open pEffect input - $ARGV[0].\n";

my $ClusterGapCount = 0;
my $ClusterGeneCount = 0;
my $ClusterId = '';
my $ClusterScore = 0;

my $doc = new BSML::BsmlBuilder;

while( my $line = <INFILE> )
{
    
    my @list = split( /\s+/, $line );
    my $l = @list;
   
    if( $l == 5 )
    {
	#Encountered a cluster definition
	$ClusterGeneCount = $list[0];
	$ClusterGapCount = $list[1];
	$ClusterScore = $list[2];
	$ClusterId = $list[4];
    }

    if( $l == 4 )
    {
	my $aln = $doc->createAndAddSequencePairAlignment( 'refseq' => $list[2],
							   'compseq' => $list[3] );

	my $s = $doc->createAndAddSequencePairRun( 'alignment_pair' => $aln,
					   'refpos' => $list[0],
					   'runlength' => 0,
					   'comppos' => $list[1],
					   'runscore' => $ClusterScore,
					   'PEffect_Cluster_Id' => $ClusterId,
					   'PEffect_Cluster_Gap_Count' => $ClusterGapCount,
					   'PEffect_Cluster_Gene_Count' => $ClusterGeneCount );

    }
}

$doc->createAndAddAnalysis( 'algorithm' => 'peffect',
			    'description' => 'test analysis',
			    'name' => 'peffect',
			    'program' => 'peffect',
			    'program_version' => 'program_version',
			    'source_name' => 'source_name',
			    'source_url' => 'source_url',
			    'source_version' => 'source_version',
			    'bsml_link_relation' => 'BSMLSEQPAIRALIGNMENTS',
			    'bsml_link_url' => '#BsmlTables'
			    );

$doc->write( STDOUT );
