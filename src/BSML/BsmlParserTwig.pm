package BsmlParserTwig;

=head1 NAME

  BsmlParserTwig.pm - Bsml Parsing Class built on XML::Twig

=head1 VERSION

This document refers to version 1.0 of the BSML Object Layer

=head1 SYNOPSIS

  Parsing a BSML Document into the BSML Object Layer

  my $doc = new BsmlDoc;
  my $parser = new BsmlParserTwig;

  $parser->parse( $doc, $fname );

=head1 DESCRIPTION

=head2 Overview

  This file provides a parsing class written on top of XML::Twig to populate 
  a BsmlDoc with data provided in a BSML file. XML::Twig is used to process 
  subtrees at the Sequence level. XML::Twig does not apply XML validation.

=head2 Constructor and initialization

  my $parser = new BsmlParserTwig;

=head2 Class and object methods

=over 4

=cut

use strict;
use warnings;
use XML::Twig;
use Log::Log4perl qw(get_logger :levels);

my $bsmlDoc;

sub new
  {
    my $class = shift;
    my $self = {};
    bless $self, $class;
    
    return $self;
  }

=item $parser->parse( $bsml_doc, $filename )

B<Description:> parse the contents of $filename into the BSML Document Object $bsml_doc

B<Parameters:> ($bsml_doc, $filename) - a BsmlDoc object, a filename pointing to a BSML document

B<Returns:> None

=cut

sub parse
  {
    my $self = shift;
    my ( $bsml_doc, $filename ) = @_;
    my $bsml_logger = get_logger( "Bsml" );

    $bsmlDoc = ${$bsml_doc}; 

    if( !( $filename ) ){   
      $bsml_logger->fatal( "Filename not provided for Bsml Parsing." );
    }

    if( !( $bsmlDoc ) ){
      $bsml_logger->fatal( "No BsmlDoc object to populate" );
    }

    # Set a Twig Handler on the BSML Sequence Object. The handler is called
    # each time an XML subtree rooted at a Sequence element is completely
    # parsed

    my $twig = new XML::Twig( TwigHandlers => 
			  { Sequence => \&sequenceHandler }
			  );
    
    # parsefile will die if an xml syntax error is encountered or if
    # there is an io problem

    $bsml_logger->debug( "Attempting to Parse Bsml Document: $filename" );
    $twig->parsefile( $filename );
    $bsml_logger->info( "Successfully Parsed Bsml Document: $filename" );
  }

# This is a private method implemented as an XML::Twig handler object. It is 
# called each time XML::Twig successfully and completely parses the subtree
# rooted at a Sequence element. The primary parse tree should be purged each time this
# method completes to handle memory efficiently. This method will need to be extended 
# to add support for additional BSML elements as they are chosen to be incorporated into
# the api.

sub sequenceHandler
  {
    my $bsml_logger = get_logger( "Bsml" );
    $bsml_logger->info( "Parsing Sequence Twig" );

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
	foreach my $BsmlFGroup  ($BsmlFTables->children( 'Feature-group' )) 
	  {
	    my $group = $bsmlseq->{'BsmlFeatureGroups'}[$bsmlseq->addBsmlFeatureGroup()];
	    
	    my $attr = $BsmlFGroup->atts();
	    
	    foreach my $key ( keys( %{$attr} ) )
	      {
		$group->addattr( $key, $attr->{$key} );
	      }

	    if( $BsmlFGroup->text() ){
	      $group->setText( $BsmlFGroup->text() ); 
	    }

	    foreach my $BsmlFGroupMember ( $BsmlFGroup->children( 'Feature-group-member' ))
	      {
		my $attr = $BsmlFGroupMember->atts();
		my $text = $BsmlFGroupMember->text();

		$group->addBsmlFeatureGroupMember( $attr->{'featref'}, $attr->{'feature-type'}, $attr->{'group-type'}, $text );
	      }
	    
	  }
	
      }
      
    $twig->purge_up_to( $seq );
  }

1
