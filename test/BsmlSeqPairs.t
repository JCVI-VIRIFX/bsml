#! /local/perl/bin/perl

use lib "../src/";
use BSML::BsmlBuilder;
use BSML::BsmlReader;
use BSML::BsmlParserTwig;
use BSML::BsmlParserSerialSearch;

print '1..8',"\n";

my $doc = new BSML::BsmlBuilder;

my $scores = [
	      [ 'Seq0001', 'Seq0002', 0, 0, 150, 1000 ],
	      [ 'Seq0001', 'Seq0003', 0, 0, 200, 1200 ],
	      [ 'Seq0004', 'Seq0002', 0, 0, 300, 9999 ],
	      [ 'Seq0001', 'Seq0002', 125, 125, 1000, 2000 ]
	      ];

foreach my $listR ( @{$scores} )
{
    
    my @list = @{$listR};
    my $l = @list;
   
    my $aln = $doc->createAndAddSequencePairAlignment( 'refseq' => $list[0],
						       'compseq' => $list[1] );

    my $s = $doc->createAndAddSequencePairRun( 'alignment_pair' => $aln,
					       'refpos' => $list[2],
					       'runlength' => $list[4],
					       'comppos' => $list[3],
					       'runscore' => $list[5] );

    $s->addBsmlAttr( 'TESTATTR', 'testattr' );
    
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

$doc->write( "tmp.bsml" );

my $reader = new BSML::BsmlReader;
my $parser = new BSML::BsmlParserTwig;
$parser->parse( \$reader, "tmp.bsml" );

# Check that four sequence stubs were written

my $rlist = $reader->returnAllSequences();

if( @{$rlist} == 4 ){
    print 'ok 1',"\n";}
else{
    print 'not ok 1',"\n";}

my $foundIt = 0;

foreach my $seq ( @{$rlist} )
{
    if ($seq->returnattr( 'id' ) eq 'Seq0004' )
    {
	$foundIt = 1;
    }
}

if( $foundIt ){
    print 'ok 2',"\n";}
else{
    print 'not ok 2',"\n";}

# Verify SeqPair Alignment
# -  Verify attributes have been written
# -  Verify bsml attributes have been written

my $rhash = $reader->get_all_alignments();

$foundIt = 0;

foreach my $key (keys( %{$rhash} ))
{
    if ( $rhash->{$key}->{'refseq'} eq 'Seq0001' &&  $rhash->{$key}->{'compseq'} eq 'Seq0003' )
    {
	foreach my $SeqPairRun ( @{$rhash->{$key}->{'seqPairRuns'}} )
	{
	    if( $SeqPairRun->{'runscore'} == 1200 && $SeqPairRun->{'TESTATTR'} eq 'testattr' )
	    {
		$foundIt = 1;
	    }
	}
    }
}

if( $foundIt ){
    print 'ok 3',"\n";}
else{
    print 'not ok 3',"\n";}

# Verify Analysis Object

my $analysisL = $reader->returnAllAnalysis();

my $rhash = $reader->readAnalysis( $analysisL->[0] );
$foundIt = 0;

if( $rhash->{'algorithm'} eq "peffect" && $rhash->{'bsml_link_relation'} eq 'BSMLSEQPAIRALIGNMENTS' )
{
    $foundIt = 1;
}

if( $foundIt ){
	print 'ok 4',"\n";}
    else{
	print 'not ok 4',"\n";}

$reader = new BSML::BsmlReader;


# test the serial parser

my $parser = new BSML::BsmlParserSerialSearch( AlignmentCallBack => \&alignmentTest, AnalysisCallBack => \&analysisTest, SequenceCallBack => \&sequenceTest );
my $AlnFoundIt = 0;
my $SeqFoundIt = 0;
my $AnalysisFoundIt = 0;

$parser->parse( 'tmp.bsml' );

if( $AlnFoundIt ){
    print 'ok 5',"\n";}
else{
    print 'not ok 5',"\n";}

if( $AnalysisFoundIt ){
    print 'ok 6',"\n";}
else{
    print 'not ok 6',"\n";}

if( $SeqFoundIt ){
    print 'ok 7',"\n";}
else{
    print 'not ok 7',"\n";}

sub alignmentTest
{
    my $alnref = shift;
    my $rhash = $reader->readSeqPairAlignment( $alnref );

    if ( $rhash->{'refseq'} eq 'Seq0001' &&  $rhash->{'compseq'} eq 'Seq0003' )
    {
	foreach my $SeqPairRun ( @{$rhash->{'seqPairRuns'}} )
	{
	    if( $SeqPairRun->{'runscore'} == 1200 && $SeqPairRun->{'TESTATTR'} eq 'testattr' )
	    {
		$AlnFoundIt = 1;
	    }
	}
    }
}

sub analysisTest
{
    my $alnref = shift;
    my $rhash = $reader->readAnalysis( $alnref );

    if( $rhash->{'algorithm'} eq "peffect" && $rhash->{'bsml_link_relation'} eq 'BSMLSEQPAIRALIGNMENTS' )
    {
	$AnalysisFoundIt = 1;
    }
}

sub sequenceTest
{
    my $seq = shift;
    if ($seq->returnattr( 'id' ) eq 'Seq0004' )
    {
	$SeqFoundIt = 1;
    }
}


my $rvalue = system( "/usr/local/annotation/PNEUMO/chauser_dir/xmlvalid-1-0-0-Linux-i586/xmlvalid -q tmp.bsml" );

if( $rvalue == 0 )
{
    #print "Successfully validated temporary gene-sequence BSML document\n"; 
    print 'ok 8',"\n";
}
else
{
    print 'not ok 8',"\n";
}

unlink 'tmp.bsml';
