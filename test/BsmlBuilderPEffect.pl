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
	my $aln = $doc->createAndAddSequencePairAlignment( 'query_name' => $list[2],
							   'dbmatch_accession' => $list[3] );

	my $s = $doc->createAndAddSequencePairRun( 'alignment_pair' => $aln,
					   'start_query' => $list[0],
					   'runlength' => 0,
					   'start_hit' => $list[1],
					   'runscore' => $ClusterScore,
					   'PEffect_Cluster_Id' => $ClusterId,
					   'PEffect_Cluster_Gap_Count' => $ClusterGapCount,
					   'PEffect_Cluster_Gene_Count' => $ClusterGeneCount );

    }
}

$doc->write( STDOUT );
