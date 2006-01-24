package BSML::BsmlParserSearch;

use strict;
use warnings;
use XML::Twig;
BEGIN {
use BSML::BsmlDoc;
use BSML::Logger;
}

my $bsmlDoc;
my $SeqConfig = { 'parse_method' => 'yes',
		  'attrs' => [ 'id', 'title', 'molecule', 'length' ],
		  'bsmlattrs' => [ 'ASSEMBLY' ]
		  };
my $SeqPairAlnConfig = { 'parse_method' => 'yes',
			 'attrs' => [ 'refseq', 'refxref', 'refstart', 'refend', 'reflength', 'compseq', 'compxref', 'method' ],
			 'bsmlattrs' => []
			 };
my $SeqPairRunConfig = { 'parse_method' => 'yes',
			 'attrs' => ['refpos', 'runlength', 'refcomplement', 'runscore', 'runprob', 'comppos', 'comprunlength', 'compcomplement'],
			 'bsmlattrs' => []
			 };

my $AnalysisConfig = { 'parse_method' => 'yes',
		       'attrs' => [],
		       'bsmlattrs' => []
		       };

sub new
  {
    my $class = shift;
    my $self = {};
    bless $self, $class;
    
    return $self;
  }

sub parse
  {
    my $self = shift;
    my ( $bsml_doc, $fileOrHandle ) = @_;
    my $bsml_logger = BSML::Logger::get_logger( "Bsml" );

    $bsmlDoc = ${$bsml_doc}; 

    if( !( $fileOrHandle ) ){   
      $bsml_logger->fatal( "No filename or handle provided for Bsml Parsing." );
    }

    if( !( $bsmlDoc ) ){
      $bsml_logger->fatal( "No BsmlDoc object to populate" );
    }

    #insure the lookup tables are using the right namespace
    $bsmlDoc->makeCurrentDocument();

    # Set a Twig Handler on the BSML Sequence Object. The handler is called
    # each time an XML subtree rooted at a Sequence element is completely
    # parsed

    my $twig = new XML::Twig( TwigHandlers => 
			  { Sequence => \&sequenceHandler, 'Seq-pair-alignment' => \&seqPairAlignmentHandler, Analysis => \&analysisHandler }
			  );
    
    # parse[file]? will die if an xml syntax error is encountered or if
    # there is an io problem

    $bsml_logger->debug( "Attempting to Parse Bsml Document: $fileOrHandle" );
    if (ref($fileOrHandle) && ($fileOrHandle->isa("IO::Handle") || $fileOrHandle->isa("GLOB"))) {
	$twig->parse( $fileOrHandle );
    } else {
	$twig->parsefile( $fileOrHandle );
    }
    $bsml_logger->info( "Successfully Parsed Bsml Document: $fileOrHandle" );

    # Twig documentation claims circular references in the twig class prevent garbage collection. Could
    # this be the source of the file handle problem? It seems like the 'twig' will go out of scope reguardlessly.

    $twig->dispose();

    # Don't want to keep the extra reference around in a class variable.

    $bsmlDoc = undef;
  }

# This is a private method implemented as an XML::Twig handler object. It is 
# called each time XML::Twig successfully and completely parses the subtree
# rooted at a Sequence element. The primary parse tree should be purged each time this
# method completes to handle memory efficiently. This method will need to be extended 
# to add support for additional BSML elements as they are chosen to be incorporated into
# the api.

sub sequenceHandler
  {
    my ($twig, $seq) = @_;

    if( $SeqConfig->{'parse_method'} eq 'yes' )
    {
	# add a new Sequence object to the bsmlDoc
	
	my $bsmlseq = $bsmlDoc->{'BsmlSequences'}[$bsmlDoc->addBsmlSequence()];
    
	# add the sequence element's attributes
	
	my $attr = $seq->atts();

	foreach my $key ( @{$SeqConfig->{'attrs'}} )
	{
	    $bsmlseq->addattr( $key, $attr->{$key} );
	}

	#put the sequence into the general object lookup table if an id was specified

	if( my $id = $bsmlseq->returnattr('id')){
	    BSML::BsmlDoc::BsmlSetDocumentLookup( $id, $bsmlseq );}
      
	# add Sequence level Bsml Attribute elements 

	foreach my $BsmlAttr ( $seq->children( 'Attribute' ) )
	{
	    my $attr = $BsmlAttr->atts();

	    foreach my $key ( @{$SeqConfig->{'bsmlattrs'}} )
	    {
		if( $attr->{'name'} eq $key )
		{
		    $bsmlseq->addBsmlAttr( $attr->{'name'}, $attr->{'content'} );
		}
	    }
	}
    }

    $twig->purge_up_to( $seq );
}

sub seqPairAlignmentHandler
  {
     my ($twig, $seq_aln) = @_;

     if( $SeqPairAlnConfig->{'parse_method'} eq 'yes' )
     {
	 # add a new BsmlSeqPairAlignment object to the bsmlDoc

	 my $bsmlaln = $bsmlDoc->{'BsmlSeqPairAlignments'}[$bsmlDoc->addBsmlSeqPairAlignment()];
     
	 # add the BsmlSeqPairAlignment element's attributes

	 my $attr = $seq_aln->atts();

	 foreach my $key ( @{ $SeqPairAlnConfig->{'attrs'}} )
	 {
	     $bsmlaln->addattr( $key, $attr->{$key} );
	 }

	 #if an id has been specified, add the alignment pair to the general object lookups
	 if( my $id = $bsmlaln->returnattr('id')){
	     BSML::BsmlDoc::BsmlSetDocumentLookup( $id, $bsmlaln );}

	 #if refseq and compseq are defined, add the alignment to the alignment lookups
	 if( (my $refseq = $bsmlaln->returnattr('refseq')) && (my $compseq = $bsmlaln->returnattr('compseq')))
	 {
	     BSML::BsmlDoc::BsmlSetAlignmentLookup( $refseq, $compseq, $bsmlaln );
	   }
   

	 # add Bsml Attribute elements to the BsmlSeqPairAlignment 

	 foreach my $BsmlAttr ( $seq_aln->children( 'Attribute' ) )
	 {
	     my $attr = $BsmlAttr->atts();

	     foreach my $key (@{ $SeqPairAlnConfig->{'bsmlattrs'}})
	     {
		 if( $key eq $attr->{'name'} )
		 {
		     $bsmlaln->addBsmlAttr( $attr->{'name'}, $attr->{'content'} );
		 }
	     }
	 }

	 if( $SeqPairRunConfig->{'parse_method'} eq 'yes' )
	 {
	     foreach my $seq_run ( $seq_aln->children('Seq-pair-run') )
	     {
		 my $bsmlseqrun = $bsmlaln->returnBsmlSeqPairRunR( $bsmlaln->addBsmlSeqPairRun() ); 
		 
		 my $attr = $seq_run->atts();
		 foreach my $key ( @{$SeqPairRunConfig->{'attrs'}} ){
		     $bsmlseqrun->addattr( $key, $attr->{$key} );
		 }

		 foreach my $BsmlAttr ( $seq_run->children( 'Attribute' ) ){
		     my $attr = $BsmlAttr->atts();

		     foreach my $key ( @{$SeqPairRunConfig->{'bsmlattrs'}} )
		     {
			 if( $key eq $attr->{'name'} )
			 {
			     $bsmlseqrun->addBsmlAttr( $attr->{'name'}, $attr->{'content'} );
			 }
		     }
		 }

	     }
	 }
       }   
     
     # Purge the twig rooted at the SeqPairAlignment Element
     $twig->purge_up_to( $seq_aln );
  }

sub analysisHandler
  {

      if( $AnalysisConfig->{'parse_method'} eq 'yes' )
      {
	  my ($twig, $analysis) = @_;

	  my $bsml_analysis = $bsmlDoc->{'BsmlAnalyses'}[$bsmlDoc->addBsmlAnalysis()];
	  my $attr = $analysis->atts();
	  
	  foreach my $key ( keys( %{$attr} ) )
	  {
	      $bsml_analysis->addattr( $key, $attr->{$key} );
	  }

	  #if an id has been specified, add the analysis to the general object lookups
	  if( my $id = $bsml_analysis->returnattr('id')){
	      BSML::BsmlDoc::BsmlSetDocumentLookup( $id, $bsml_analysis );}
	  
	  foreach my $BsmlAttr ( $analysis->children( 'Attribute' ) )
	  {
	      my $attr = $BsmlAttr->atts();
	      $bsml_analysis->addBsmlAttr( $attr->{'name'}, $attr->{'content'} );
	  }

	  foreach my $BsmlLink ( $analysis->children( 'Link' ) )
	  {
	      my $attr = $BsmlLink->atts();
	      $bsml_analysis->addBsmlLink( $attr->{'rel'}, $attr->{'href'} );
	  }
	  
      }
  }
1


