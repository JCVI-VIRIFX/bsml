package BsmlDoc;
@ISA = qw( BsmlElement );

=head1 NAME

BsmlDoc.pm - Bsml Document Class

=head1 VERSION

This document refers to version 1.0 of the BSML Object Layer

=head1 SYNOPSIS

  Reading a BSML document and writing it back out from the object layer.

  my $doc = new BsmlDoc;
  my $parser = new BsmlParserTwig;
  $parser->parse( \$doc, $inputfile );
  $doc->write( $outputfile );

  Creating BSML objects and writing them out to a BSML file.

  my $doc = new BsmlDoc;
  my $seq = $doc->returnBsmlSequenceR( $doc->addBsmlSequence() );
  $seq->addBsmlSeqData( "ggtaccttctgaggcggaaagaaccagccggatccctcgaggg" );
  $doc->write();

=head1 DESCRIPTION

=head2 Overview

  This file provides a document level class for storing, creating, 
  and writing BSML elements

=head2 Constructor and initialization

When a BsmlDoc is created an empty document skeleton is created which currently supports 
document level attributes, BSML Attribute elements, and sequence data. Future support for 
Genome BSML elements as well as Research elements is expected at here.

If a path to a valid Log4Perl configuration file is passed to the constructor, the default
logging will be over-ridden.

=head2 Class and object methods

=over 4

=cut

use BsmlElement;
use XML::Writer;
use strict;
use warnings;
use BsmlSequence;
use BsmlSeqPairAlignment;
use BsmlAnalysis;
use Log::Log4perl qw(get_logger :levels);

# The default links to the BSML dtd maintained by Labbook

my $default_dtd_pID = '-//EBI//Labbook, Inc. BSML DTD//EN';
my $default_dtd_sID = 'http://www.labbook.com/dtd/bsml3_1.dtd';

my $log4perl_defaults = 
'log4perl.logger.Bsml=FATAL, A1
log4perl.appender.A1=Log::Dispatch::File
log4perl.appender.A1.filename=bsml.log
log4perl.appender.A1.mode=append
log4perl.appender.A1.layout=Log::Log4perl::Layout::PatternLayout
log4perl.appender.A1.layout.ConversionPattern=%d %p> %F{1}:%L %M - %m%n';

# a bsml document stores a list of annotated sequences, 
# document level attributes, and Bsml Attribute Elements

sub new
  {
    my $class = shift;
    my ($logger_conf) = @_;
    my $self = {};
    bless $self, $class;    
    $self->init( $logger_conf );
    return $self;
  }

sub init
  {
    my $self = shift;
    my ($logger_conf) = @_;

    $self->{ 'attr' } = {};
    $self->{ 'BsmlAttr' } = {};
    $self->{ 'BsmlSequences' } = [];
    $self->{ 'BsmlSeqPairAlignments' } = [];
    $self->{ 'BsmlAnalyses' } = [];
    
    # bsml Genomes will probably be needed in the future...

    #initialize Log4perl

    if( $logger_conf ){
      Log::Log4perl->init( $logger_conf );
    }else{
      Log::Log4perl->init( \$log4perl_defaults );
    }

    my $bsml_logger = get_logger( "Bsml" );
        
    $bsml_logger->info( "Created new BsmlDoc" );
  }

=item $doc->addBsmlSequence()

B<Description:> This is a method to add a Bsml Sequence Object to the document.

B<Parameters:> None - A $ref parameter will probably be added to allow a sequence reference to be returned directly by the function.

B<Returns:> The reference index of the added sequence

=cut

sub addBsmlSequence
  {
    my $self = shift;
     
    push( @{$self->{'BsmlSequences'}}, new BsmlSequence );

    my $index = @{$self->{'BsmlSequences'}} - 1;

    my $bsml_logger = get_logger( "Bsml" );
    $bsml_logger->info( "Added BsmlSequence: $index" );

    return $index;    
  }

=item $doc->dropBsmlSequence()

B<Description:> Delete a Bsml Sequence from the document.

B<Parameters:> ($index) - the sequence index returned from addBsmlSequence (position of the sequence in the reference list)

B<Returns:> None

=cut

sub dropBsmlSequence
  {
    my $self = shift;

    my ($index) = @_;

    my $newlist;

    for(  my $i=0;  $i< @{$self->{'BsmlSequences'}}; $i++ ) 
      {
	if( $i != $index )
	  {
	    push( @{$newlist}, $self->{'BsmlSequences'}[$i] );
	  }
      }

    $self->{'BsmlSequences'} = $newlist;

    my $bsml_logger = get_logger( "Bsml" );
    $bsml_logger->info( "Dropped BsmlSequence: $index" );
  }

=item $doc->returnBsmlSequenceListR()

B<Description:> Return a list of references to all the sequence objects contained in the document.

B<Parameters:> None

B<Returns:> a list of BsmlSequence object references

=cut 

sub returnBsmlSequenceListR
  {
    my $self = shift;

    return $self->{'BsmlSequences'};
  }

=item $doc->returnBsmlSequenceR()

B<Description:> Return a reference to a sequence object given its index

B<Parameters:> ($index) - the sequence index returned from addBsmlSequence (position of the sequence in the reference list)

B<Returns:> a BsmlSequence object reference

=cut

sub returnBsmlSequenceR
  {
    my $self = shift;
    my ($index) = @_;

    return $self->{'BsmlSequences'}[$index];  
  }

sub returnBsmlSequenceByIDR
  {
    my $self = shift;
    my ($id) = @_;

    foreach my $seq (@{$self->{'BsmlSequences'}})
      {
	if( $seq->returnattr( 'id' ) eq $id ){
	  return $seq;}
      }

    return;
  }

sub addBsmlSeqPairAlignment
  {
    my $self = shift;
     
    push( @{$self->{'BsmlSeqPairAlignments'}}, new BsmlSeqPairAlignment );

    my $index = @{$self->{'BsmlSeqPairAlignments'}} - 1;

    my $bsml_logger = get_logger( "Bsml" );
    $bsml_logger->info( "Added BsmlSeqPairAlignment: $index" );

    return $index;    
  }

sub dropBsmlSeqPairAlignment
{
   my $self = shift;
   my ($index) = @_;

   my $newlist;
   for(  my $i=0;  $i< @{$self->{'BsmlSeqPairAlignments'}}; $i++ ) 
      {
	if( $i != $index )
	  {
	    push( @{$newlist}, $self->{'BsmlSeqPairAlignments'}[$i] );
	  }
      }

    $self->{'BsmlSeqPairAlignements'} = $newlist;

    my $bsml_logger = get_logger( "Bsml" );
    $bsml_logger->info( "Dropped BsmlSeqPairAlignment: $index" );
}

sub returnBsmlSeqPairAlignmentListR
{
  my $self = shift;
  return $self->{'BsmlSeqPairAlignments'};
}

sub returnBsmlSeqPairAlignmentR
{
  my $self = shift;
  my ($index) = @_;

  return $self->{'BsmlSeqPairAlignments'}[$index];
}

sub addBsmlAnalysis
  {
    my $self = shift;
     
    push( @{$self->{'BsmlAnalyses'}}, new BsmlAnalysis );

    my $index = @{$self->{'BsmlAnalyses'}} - 1;

    my $bsml_logger = get_logger( "Bsml" );
    $bsml_logger->info( "Added BsmlAnalysis: $index" );

    return $index;    
  }

sub dropBsmlAnalysis
{
   my $self = shift;
   my ($index) = @_;

   my $newlist;
   for(  my $i=0;  $i< @{$self->{'BsmlAnalyses'}}; $i++ ) 
      {
	if( $i != $index )
	  {
	    push( @{$newlist}, $self->{'BsmlAnalyses'}[$i] );
	  }
      }

    $self->{'BsmlAnalyses'} = $newlist;

    my $bsml_logger = get_logger( "Bsml" );
    $bsml_logger->info( "Dropped BsmlAnalyses: $index" );
}

sub returnBsmlAnalysisListR
{
  my $self = shift;
  return $self->{'BsmlAnalyses'};
}

sub returnBsmlAnalysisR
{
  my $self = shift;
  my ($index) = @_;

  return $self->{'BsmlAnalyses'}[$index];
}

=item $doc->write()

B<Description:> Writes the document to a file 

B<Parameters:> ($fname, $dtd) - output file name, optional user specified dtd which will override the librarys default

B<Returns:> None

=cut

sub write
  {
    my $self = shift;
    my ($fname, $dtd) = @_;

    my $bsml_logger = get_logger( "Bsml" );

    $bsml_logger->debug( "Attempting to write BsmlDoc" );

    my $output = new IO::File( ">$fname" );

    if( !( $output ) )
    {
      $bsml_logger->fatal( "Could not open output file - $fname" );
      die "could not open output file - $fname\n";
    }

    # Setting DATA_MODE to 1 enables XML::Writer to insert newlines around XML elements for 
    # easier readability. DATA_INDENT specifies an indent of two spaces for child elements

    my $writer = new XML::Writer(OUTPUT => $output, DATA_MODE => 1, DATA_INDENT => 2);  

    $writer->xmlDecl();

    # If a local file dtd is not specified the default will be used.
    # The default points to the publicly available dtd at Labbook

    if( $dtd ){$writer->doctype( "Bsml", "", "file:$dtd" );}
    else{
      $writer->doctype( "Bsml", $default_dtd_pID, $default_dtd_sID );
      $bsml_logger->debug( "DTD not specified - using $default_dtd_sID" );
      }
   
    # write the root node

    $writer->startTag( "Bsml", %{$self->{'attr'}} );

    # write any Bsml Attribute children

    foreach my $bsmlattr (keys( %{$self->{ 'BsmlAttr'}}))
      {
	$writer->startTag( "Attribute", 'name' => $bsmlattr, 'content' => $self->{'BsmlAttr'}->{$bsmlattr} );
	$writer->endTag( "Attribute" );
      }

    # write the Defintions section, current API only supports Sequences

    $writer->startTag( "Definitions" );

    # write the sequence elements

    if( @{$self->{'BsmlSequences'}} )
    {
      $writer->startTag( "Sequences" );

      foreach my $seq ( @{$self->{'BsmlSequences'}} )
        {
	  $seq->write( $writer );
        }

      $writer->endTag( "Sequences" );
    }

    if( @{$self->{'BsmlSeqPairAlignments'}} )
    {
      $writer->startTag( "Tables" );

      foreach my $seqAlignment ( @{$self->{'BsmlSeqPairAlignments'}} )
      {
        $seqAlignment->write( $writer );
      }

      $writer->endTag( "Tables" );
    }

    $writer->endTag( "Definitions" );

    if( @{$self->{'BsmlAnalyses'}} )
      {
	$writer->startTag( 'Research' );
	$writer->startTag( 'Analyses' );
	
	foreach my $analysis ( @{$self->{'BsmlAnalyses'}} )
	  {
	    $analysis->write( $writer );
	  }

	$writer->endTag( 'Analyses' );
	$writer->endTag( 'Research' );
      }
	
    
    $writer->endTag( "Bsml" );
    
    $bsml_logger->debug( "BsmlDoc successfully written" );
  }

1
