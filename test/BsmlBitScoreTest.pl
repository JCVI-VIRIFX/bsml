#! /local/perl/bin/perl

use lib "../src/";
use BSML::BsmlReader;
use BSML::BsmlParserTwig;
use Data::Dumper; 

my $reader = new BSML::BsmlReader;
my $parser = new BSML::BsmlParserTwig;

$parser->parse( \$reader, $ARGV[0] );

foreach my $seqobj (@{$reader->returnAllSequences()})
{
    my $seqId = $seqobj->returnattr('id');
   
    # this is a quick hack to get around the CDS vs. Protein Seq problem...
    # take care of the CDS to Protein Id conversions...

    my $compId = $seqId;
    $compId =~ s/ORFtmp/Protein/;

    # return the alignment object corresponding to the query sequences verses itself.

    my $alignment_list = $reader->fetch_all_alignmentPairs( $seqId, $compId );
    
    #if there is a match against itself use the sequence as a base...

    if( $alignment_list->[0] )
    {
	my $base_alignment = $reader->readSeqPairAlignment( $alignment_list->[0] );
	my $base_score = $base_alignment->{'seqPairRuns'}->[0]->{'runscore'};
	
	# get all the alignment objects having $seqId as the query sequence

	$alignment_list = $reader->fetch_all_alignmentPairs( $seqId );

	# foreach alignment, calculate the percent bit score for each seq pair run

	foreach my $align (@{$alignment_list})
	{
	    my $alignmentDat = $reader->readSeqPairAlignment( $align );

	    foreach my $run ( @{$alignmentDat->{'seqPairRuns'}} )
	    {
		my $score = $run->{'runscore'};
		my $PercentBitScore = $score / $base_score * 100;

		# add a bsml attribute to the document for percent bit score

		$run->{'bsmlRef'}->addBsmlAttr( 'percent_bit_score', $PercentBitScore );
	    }
	}
    }
}

# write the altered file to disk

$reader->write( 'output.bsml' );
