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
Genome BSML elements as well as Research elements is expected at this here.

=head2 Class and object methods

=over 4

=cut

use BsmlElement;
use XML::Writer;
use strict;
use warnings;
use BsmlSequence;

# The default links to the BSML dtd maintained by Labbook

my $default_dtd_pID = '-//EBI//Labbook, Inc. BSML DTD//EN';
my $default_dtd_sID = 'http://www.labbook.com/dtd/bsml3_1.dtd';

# a bsml document stores a list of annotated sequences, 
# document level attributes, and Bsml Attribute Elements

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

    $self->{ 'attr' } = {};
    $self->{ 'BsmlAttr' } = {};
    $self->{ 'BsmlSequences' } = [];
    
    # bsml Genomes will probably be needed in the future...
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

=item $doc->write()

B<Description:> Writes the document to a file 

B<Parameters:> ($fname, $dtd) - output file name, optional user specified dtd which will override the library's default

B<Returns:> None

=cut

sub write
  {
    my $self = shift;
    my ($fname, $dtd) = @_;

    my $output = new IO::File( ">$fname" ) or die "could not open output file - $fname\n";

    # Setting DATA_MODE to 1 enables XML::Writer to insert newlines around XML elements for 
    # easier readability. DATA_INDENT specifies an indent of two spaces for child elements

    my $writer = new XML::Writer(OUTPUT => $output, DATA_MODE => 1, DATA_INDENT => 2);  

    $writer->xmlDecl();

    # If a local file dtd is not specified the default will be used.
    # The default points to the publicly available dtd at Labbook

    if( $dtd ){$writer->doctype( "Bsml", "", "file:$dtd" );}
    else{
      $writer->doctype( "Bsml", $default_dtd_pID, $default_dtd_sID );
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

    $writer->startTag( "Sequences" );

    foreach my $seq ( @{$self->{'BsmlSequences'}} )
      {
	$seq->write( $writer );
      }

    $writer->endTag( "Sequences" );
    $writer->endTag( "Definitions" );
    $writer->endTag( "Bsml" );
  }

1
