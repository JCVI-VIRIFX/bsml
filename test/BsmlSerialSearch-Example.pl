#! /local/perl/bin/perl

use lib '../src/';
use BSML::BsmlParserSerialSearch;
use BSML::BsmlSeqPairAlignment;
use BSML::BsmlReader;
use Data::Dumper;

# A reader object can be used to "package" the data contained in BsmlSequence, BsmlSeqPairAlignment, and BsmlAnalysis objects
# into structured hashes. 

my $reader = new BSML::BsmlReader;

# The constructor for the serial parser accepts three optional arguments. Each of these arguments defines a reference to a callback function.
# The parser will call these functions with an object reference at parse time as element is encoutered. 

my $parser = new BSML::BsmlParserSerialSearch( AlignmentCallBack => \&alignmentPrint, AnalysisCallBack => \&analysisPrint, SequenceCallBack => \&sequencePrint );
# my $parser = new BSML::BsmlParserSerialSearch( GenomeCallBack => \&genomePrint );

# Begin BSML parse. If no filename is provided the parser defaults to STDIN. 

if( $ARGV[0] ){
    $parser->parse( $ARGV[0] );}
else{
    $parser->parse();}


# Callback function for alignment objects demonstrating low-level object usage.

sub alignmentPrint
{
    return;
    my $alnref = shift;    
    print "ALN: ";

    # Element attributes can be returned using the returnattr method.
    # Equivalently BSML Attributes ie. <Attribute name="percent_identity" content="100"/> can
    # be returned with returnBsmlAttr(). Both are defined in the BsmlElement base class.

    # Print the reference ids of the query and subject sequences.
    print $alnref->returnattr( 'refseq' );
    print " ";
    print $alnref->returnattr( 'compseq' );
    print "\n";

    # An array of BSML::SeqPairRun objects is stored within each BSML::SeqPairAlignment. It can
    # be accessed with the following method.

    my $runs = $alnref->returnBsmlSeqPairRunListR();

    # Print the start position of each run relative to the query sequence.

    print "   -> ";
    foreach my $seqpairrun ( @{$runs} )
    {
	print $seqpairrun->returnattr( 'refpos' )." ";
    }
    print "\n";
}

# A callback function for the analysis object demonstrating the usage of the BsmlReader class.

sub analysisPrint 
{
    my $analysisref = shift;
    print Dumper( $reader->readAnalysis( $analysisref ) );
}

# A callback function for sequence objects.

sub sequencePrint
{
    return;
    my $seqref = shift;
    print "SEQ: ";
    print $seqref->returnattr( 'id' );
    print "\n";
}

# A callback for Genome Objects

sub genomePrint
{
    return;
    my $genome = shift;
    my $rhash = $reader->readGenome( $genome );

    print "Print Genome<<\n";
    print Dumper( $rhash );
    print ">>\n";
}
