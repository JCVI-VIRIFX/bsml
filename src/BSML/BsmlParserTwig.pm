package BsmlParserTwig;

#
# package to parse bsml input from file using XML::Twig
#

use strict;
use warnings;
use XML::Twig;

my $bsmlDoc;

sub new
  {
    my $class = shift;
    my $self = {};
    bless $self, $class;
    
    $self->init();
    return $self;
  }

sub init
  {
    my $self = shift;
  }

# parse the contents of $filename into the BSML Document Object $bsml_doc

sub parse
  {
    my $self = shift;
    my ( $bsml_doc, $filename ) = @_;

    $bsmlDoc = ${$bsml_doc}; 

    # Set a Twig Handler on the BSML Sequence Object. The handler is called
    # each time an XML subtree rooted at a Sequence element is completely
    # parsed

    my $twig = new XML::Twig( TwigHandlers => 
			  { Sequence => \&sequenceHandler }
			  );
    
    # parsefile will die if an xml syntax error is encountered or if
    # there is an io problem

    $twig->parsefile( $filename );
  }

sub sequenceHandler
  {

    my ($twig, $seq) = @_;

    # add a new Sequence object to the bsmlDoc

    my $bsmlseq = $bsmlDoc->{'BsmlSequences'}[$bsmlDoc->addBsmlSequence()];

    
    # add the sequence element's attributes

    my $attr = $seq->atts();

    foreach my $key ( keys( %{$attr} ) )
      {
	$bsmlseq->addattr( $key, $attr->{$key} );
      }

    # add Sequence level Bsml Attribute elements 

    foreach my $BsmlAttr ( $seq->children( 'Attribute' ) )
      {
	my $attr = $BsmlAttr->atts();
	$bsmlseq->addBsmlAttr( $attr->{'name'}, $attr->{'content'} );
      }

    # add raw sequence data if found 

    my $seqDat = $seq->first_child( 'Seq-data' );
    
      if( $seqDat ){
	$bsmlseq->addBsmlSeqData( $seqDat->text() );
      }

    # add Feature Tables with Feature and Reference Elements
    # support for Feature-group forthcoming

    my $BsmlFTables = $seq->first_child( 'Feature-tables' );

    if( $BsmlFTables )
      {
	foreach my $BsmlFTable ( $BsmlFTables->children( 'Feature-table' ) )
	  {
	    my $table = $bsmlseq->{'BsmlFeatureTables'}[$bsmlseq->addBsmlFeatureTable()];

	    my $attr = $BsmlFTable->atts();

	    foreach my $key ( keys( %{$attr} ) )
	      {
		$table->addattr( $key, $attr->{$key} );
	      }

	    foreach my $BsmlRef ($BsmlFTable->children( 'Reference' ) )
	      {
		my $ref = $table->{'BsmlReferences'}[$table->addBsmlReference()];
		my $attr = $BsmlRef->atts();

		foreach my $key ( keys( %{$attr} ) )
		  {
		    $ref->addattr( $key, $attr->{$key} );
		  }

		foreach my $BsmlAuthor ($BsmlRef->children( 'RefAuthors' ))
		  {
		    $ref->addBsmlRefAuthors( $BsmlAuthor->text() );
		  }

		foreach my $BsmlRefTitle ($BsmlRef->children( 'RefTitle' ))
		  {
		    $ref->addBsmlRefTitle( $BsmlRefTitle->text() );
		  }

		foreach my $BsmlRefJournal ($BsmlRef->children( 'RefJournal' ))
		  {
		    $ref->addBsmlRefJournal( $BsmlRefJournal->text() );
		  }
	      }
	  

	    foreach my $BsmlFeature ($BsmlFTable->children( 'Feature' ))
	      {
		my $feat = $table->{'BsmlFeatures'}[$table->addBsmlFeature()];
		my $attr = $BsmlFeature->atts();

		foreach my $key ( keys( %{$attr} ) )
		  {
		    $feat->addattr( $key, $attr->{$key} );
		  }

		foreach my $BsmlQualifier ($BsmlFeature->children( 'Qualifier' ))
		  {
		    my $attr = $BsmlQualifier->atts();
		    $feat->addBsmlQualifier( $attr->{'value-type'} , $attr->{'value'} ); 
		  }

		foreach my $BsmlIntervalLoc ($BsmlFeature->children( 'Interval-loc' ))
		  {
		    my $attr = $BsmlIntervalLoc->atts();
		    if( !( $attr->{'complement'} ) ){ $attr->{ 'complement' } = 0 };

		    $feat->addBsmlIntervalLoc( $attr->{'startpos'} , $attr->{'endpos'}, $attr->{'complement'} ); 
		  }

		foreach my $BsmlSiteLoc ($BsmlFeature->children( 'Site-loc' ))
		  {
		    my $attr = $BsmlSiteLoc->atts();

		    if( !( $attr->{'complement'} ) ){ $attr->{ 'complement' } = 0 };
		    $feat->addBsmlSiteLoc( $attr->{'sitepos'} , $attr->{'complement'} ); 
		  }
	      }
	  }
      }
  }

1
