package BSML::BsmlParserTwig;

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
use BSML::BsmlDoc;

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

    #insure the lookup tables are using the right namespace
    $bsmlDoc->makeCurrentDocument();

    # Set a Twig Handler on the BSML Sequence Object. The handler is called
    # each time an XML subtree rooted at a Sequence element is completely
    # parsed

    my $twig = new XML::Twig( TwigHandlers => 
			  { Sequence => \&sequenceHandler, 'Seq-pair-alignment' => \&seqPairAlignmentHandler, Analysis => \&analysisHandler }
			  );
    
    # parsefile will die if an xml syntax error is encountered or if
    # there is an io problem

    $bsml_logger->debug( "Attempting to Parse Bsml Document: $filename" );
    $twig->parsefile( $filename );
    $bsml_logger->info( "Successfully Parsed Bsml Document: $filename" );

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

    #put the sequence into the general object lookup table if an id was specified

    if( my $id = $bsmlseq->returnattr('id')){
      BSML::BsmlDoc::BsmlSetDocumentLookup( $id, $bsmlseq );}
      
    # add Sequence level Bsml Attribute elements 

    foreach my $BsmlAttr ( $seq->children( 'Attribute' ) )
      {
	my $attr = $BsmlAttr->atts();
	$bsmlseq->addBsmlAttr( $attr->{'name'}, $attr->{'content'} );
      }

    # add any Bsml Links

    foreach my $BsmlLink ( $seq->children( 'Link' ) )
      {
	my $attr = $BsmlLink->atts();
	$bsmlseq->addBsmlLink( $attr->{'title'}, $attr->{'href'} );
      }

    # add raw sequence data if found 

    my $seqDat = $seq->first_child( 'Seq-data' );
    
    if( $seqDat ){
      $bsmlseq->addBsmlSeqData( $seqDat->text() );
    }

    # add appended sequence data if found

    my $seqDatImport = $seq->first_child( 'Seq-data-import' );
    
    if( $seqDatImport )
      {
	my $attr = $seqDatImport->atts();
	$bsmlseq->addBsmlSeqDataImport( $attr->{'format'}, $attr->{'source'}, $attr->{'id'});
      }

    # add Feature Tables with Feature, Reference, and Feature-group Elements

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

            #if an id has been specified, add the table to the general object lookups
	    if( my $id = $table->returnattr('id')){
	      BSML::BsmlDoc::BsmlSetDocumentLookup( $id, $table );}

	    foreach my $BsmlLink ( $BsmlFTable->children( 'Link' ) )
	      {
		my $attr = $BsmlLink->atts();
		$table->addBsmlLink( $attr->{'title'}, $attr->{'href'} );
	      }

	    foreach my $BsmlRef ($BsmlFTable->children( 'Reference' ) )
	      {
		my $ref = $table->{'BsmlReferences'}[$table->addBsmlReference()];
		my $attr = $BsmlRef->atts();

		foreach my $key ( keys( %{$attr} ) )
		  {
		    $ref->addattr( $key, $attr->{$key} );
		  }

                #if an id has been specified, add the reference to the general object lookups
	        if( my $id = $ref->returnattr('id')){
	            BSML::BsmlDoc::BsmlSetDocumentLookup( $id, $ref );}

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

		foreach my $BsmlLink ( $BsmlRef->children( 'Link' ) )
		  {
		    my $attr = $BsmlLink->atts();
		    $ref->addBsmlLink( $attr->{'title'}, $attr->{'href'} );
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

		 #if an id has been specified, add the feature to the general object lookups
	         if( my $id = $feat->returnattr('id')){
	           BSML::BsmlDoc::BsmlSetDocumentLookup( $id, $feat );}

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
		    $feat->addBsmlSiteLoc( $attr->{'sitepos'} , $attr->{'complement'}, $attr->{'class'} ); 
		  }

		foreach my $BsmlLink ( $BsmlFeature->children( 'Link' ) )
		  {
		    my $attr = $BsmlLink->atts();
		    $feat->addBsmlLink( $attr->{'rel'}, $attr->{'href'} );
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

	    #if an id has been specified, add the table to the general object lookups
	    if( my $id = $group->returnattr('id')){
	      BSML::BsmlDoc::BsmlSetDocumentLookup( $id, $group );}

	    if( $BsmlFGroup->text() ){
	      $group->setText( $BsmlFGroup->text() ); 
	    }

	    foreach my $BsmlLink ( $BsmlFGroup->children( 'Link' ) )
	      {
		my $attr = $BsmlLink->atts();
		$group->addBsmlLink( $attr->{'rel'}, $attr->{'href'} );
	      }

	    foreach my $BsmlFGroupMember ( $BsmlFGroup->children( 'Feature-group-member' ))
	      {
		my $attr = $BsmlFGroupMember->atts();
		my $text = $BsmlFGroupMember->text();

		$group->addBsmlFeatureGroupMember( $attr->{'featref'}, $attr->{'feature-type'}, $attr->{'group-type'}, $text );
	      }

	    #if the feature group is part of a group-set, put it into the lookup tables
	    #this is the basis for returning all the transcripts (feature-groups) associated 
	    #with a gene

	    if( my $groupset = $group->returnattr('group-set'))
		{
		  BSML::BsmlDoc::BsmlSetFeatureGroupLookup( $groupset, $group );
		}
	    
	  }
	
      }
      
    #$twig->purge_up_to( $seq );
  }

sub seqPairAlignmentHandler
  {
     my ($twig, $seq_aln) = @_;

     # add a new BsmlSeqPairAlignment object to the bsmlDoc

     my $bsmlaln = $bsmlDoc->{'BsmlSeqPairAlignments'}[$bsmlDoc->addBsmlSeqPairAlignment()];
     
     # add the BsmlSeqPairAlignment element's attributes

     my $attr = $seq_aln->atts();

     foreach my $key ( keys( %{$attr} ) )
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
	$bsmlaln->addBsmlAttr( $attr->{'name'}, $attr->{'content'} );
      }

     foreach my $BsmlLink ( $seq_aln->children( 'Link' ) )
       {
	 my $attr = $BsmlLink->atts();
	 $bsmlaln->addBsmlLink( $attr->{'ref'}, $attr->{'href'} );
       }
     
     foreach my $seq_run ( $seq_aln->children('Seq-pair-run') )
       {
	 my $bsmlseqrun = $bsmlaln->returnBsmlSeqPairRunR( $bsmlaln->addBsmlSeqPairRun() ); 

	 my $attr = $seq_run->atts();
	 foreach my $key ( keys( %{$attr} ) ){
	   $bsmlseqrun->addattr( $key, $attr->{$key} );
	 }

	 foreach my $BsmlAttr ( $seq_run->children( 'Attribute' ) ){
	   my $attr = $BsmlAttr->atts();
	   $bsmlseqrun->addBsmlAttr( $attr->{'name'}, $attr->{'content'} );
	 }

	 foreach my $BsmlLink ( $seq_run->children( 'Link' ) )
	   {
	     my $attr = $BsmlLink->atts();
	     $bsmlseqrun->addBsmlLink( $attr->{'title'}, $attr->{'href'} );
	   }
       }     
  }

sub analysisHandler
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
	$bsml_analysis->addBsmlLink( $attr->{'title'}, $attr->{'href'} );
      }

  }
1
