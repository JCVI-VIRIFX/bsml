package BSML::BsmlDoc;
@ISA = qw( BSML::BsmlElement );

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


use XML::Writer;
use warnings;
use Log::Log4perl qw(get_logger :easy);

use BSML::BsmlElement;
use BSML::BsmlSequence;
use BSML::BsmlSeqPairAlignment;
use BSML::BsmlMultipleAlignmentTable;
use BSML::BsmlAnalysis;
use BSML::BsmlGenome;


# The default links to the BSML dtd maintained by Labbook

my $default_dtd_pID = '-//EBI//Labbook, Inc. BSML DTD//EN';
my $default_dtd_sID = 'http://www.labbook.com/dtd/bsml3_1.dtd';

# The document level id lookup tables

$BsmlIdLookups = [];
$BsmlSeqAlignmentLookups = [];
$BsmlFeatureGroupLookups = [];
$BsmlTableIdCount = 0;
$BsmlCurrentTableId = 0;

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
    $self->{ 'BsmlMultipleAlignmentTables' } = [];
    $self->{ 'BsmlAnalyses' } = [];
    $self->{ 'BsmlGenomes' } = [];

    # initialize a namespace table
    $self->{ 'BsmlTableId' } = $BsmlTableIdCount;
    @{$BsmlIdLookups}[$BsmlTableIdCount] = {};
    @{$BsmlSeqAlignmentLookups}[$BsmlTableIdCount] = {};
    @{$BsmlFeatureGroupLookups}[$BsmlTableIdCount] = {};
    $BsmlTableIdCount++;

    my $bsml_logger = get_logger( "Bsml" );
    $bsml_logger->info( "Created new BsmlDoc" );
    $bsml_logger->level($WARN);
  }

sub DESTROY
  {
    my $self = shift;

    #free the memory associated with the global lookup table

    @{$BsmlIdLookups}[$self->{'BsmlTableId'}] = undef;
    @{$BsmlSeqAlignmentLookups}[$self->{'BsmlTableId'}] = undef;
    @{$BsmlFeatureGroupLookups}[$self->{'BsmlTableId'}] = undef;
  }

sub BsmlSetDocumentLookup
  {
    my ($BsmlID, $BsmlRef) = @_;
    $BsmlIdLookups->[$BsmlCurrentTableId]->{$BsmlID} = $BsmlRef;
  }

sub BsmlSetAlignmentLookup
  {
    my ($Seq1, $Seq2, $aln) = @_;
    $BsmlSeqAlignmentLookups->[$BsmlCurrentTableId]->{$Seq1}->{$Seq2} = $aln;
  }

sub BsmlSetFeatureGroupLookup
  {
    my ($id, $fgroupid) = @_;
    
    if( (my $listref = $BsmlFeatureGroupLookups->[$BsmlCurrentTableId]->{$id}) )
      {
	push( @{$listref}, $fgroupid );
      }
    else
      {
	$BsmlFeatureGroupLookups->[$BsmlCurrentTableId]->{$id} = [$fgroupid];
      }
  }

sub BsmlReturnDocumentLookup
  {
    my ($BsmlID) = @_;
    return $BsmlIdLookups->[$BsmlCurrentTableId]->{$BsmlID};
  }

sub BsmlReturnAlignmentLookup
  {
    my ($Seq1, $Seq2) = @_;

    if( $Seq2 )
      {
	#returns a list of alignment objects
	return $BsmlSeqAlignmentLookups->[$BsmlCurrentTableId]->{$Seq1}->{$Seq2};
      }
    else
      {
	#returns a hash reference where each key specifies a list of alignment objects
	return $BsmlSeqAlignmentLookups->[$BsmlCurrentTableId]->{$Seq1};
      }
  }

sub BsmlReturnFeatureGroupLookup
  {
    my ($BsmlId) = @_;
    return $BsmlFeatureGroupLookups->[$BsmlCurrentTableId]->{$BsmlId};
  }

sub BsmlReturnFeatureGroupLookupIds
  {
    return keys( %{$BsmlFeatureGroupLookups->[$BsmlCurrentTableId]} );
  }

sub BsmlSetCurrentDocumentLookupTable
  {
    my ($index) = @_;
    $BsmlCurrentTableId = $index;
  }

sub makeCurrentDocument
  {
    my $self = shift;
    BsmlSetCurrentDocumentLookupTable( $self->{'BsmlTableId'} );
  }

=item $doc->addBsmlSequence()

B<Description:> This is a method to add a Bsml Sequence Object to the document.

B<Parameters:> None - A $ref parameter will probably be added to allow a sequence reference to be returned directly by the function.

B<Returns:> The reference index of the added sequence

=cut

sub addBsmlSequence
  {
    my $self = shift;
     
    push( @{$self->{'BsmlSequences'}}, new BSML::BsmlSequence );

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

    return $BsmlIdLookups->[$BsmlCurrentTableId]->{$id};
  }

sub addBsmlSeqPairAlignment
  {
    my $self = shift;
     
    push( @{$self->{'BsmlSeqPairAlignments'}}, new BSML::BsmlSeqPairAlignment );

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

sub addBsmlMultipleAlignmentTable
{
    my $self = shift;
    push( @{$self->{'BsmlMultipleAlignmentTables'}}, new BSML::BsmlMultipleAlignmentTable );

    my $index = @{$self->{'BsmlMultipleAlignmentTables'}} - 1;
    return $index;
}

sub dropBsmlMultipleAlignmentTable
  {
    my $self = shift;
    my ($index) = @_;

    my @newlist;

    for( my $i=0; $i<length(@{$self->{'BsmlMultipleAlignmentTables'}}); $i++ )
      {
	if( $i != $index )
	  {
	    push( @newlist, $self->{'BsmlMultipleAlignmentTables'}[$i] );
	  }
      }

    $self->{'BsmlMultipleAlignmentTables'} = \@newlist;    
  }

sub returnBsmlMultipleAlignmentTableListR
{
    my $self = shift;
    return $self->{'BsmlMultipleAlignmentTables'};
}

sub returnBsmlMultipleAlignmentTableR
{
    my $self = shift;
    my ($index) = @_;

    return $self->{'BsmlMultipleAlignmentTables'}[$index];
}


sub addBsmlAnalysis
  {
    my $self = shift;
     
    push( @{$self->{'BsmlAnalyses'}}, new BSML::BsmlAnalysis );

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

sub addBsmlGenome
{
    my $self = shift;

    push( @{$self->{'BsmlGenomes'}}, new BSML::BsmlGenome );

    my $index = @{$self->{'BsmlGenomes'}} - 1;

    return $index;    
}

sub returnBsmlGenomeListR
{
  my $self = shift;
  return $self->{'BsmlGenomes'};
}

sub returnBsmlGenomeR
{
  my $self = shift;
  my ($index) = @_;

  return $self->{'BsmlGenomes'}[$index];
}

sub dropBsmlGenome
{
   my $self = shift;
   my ($index) = @_;

   my $newlist;
   for(  my $i=0;  $i< @{$self->{'BsmlGenomes'}}; $i++ ) 
      {
	if( $i != $index )
	  {
	    push( @{$newlist}, $self->{'BsmlGenomes'}[$i] );
	  }
      }

    $self->{'BsmlGenomes'} = $newlist;
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
    my $output;

    if( !($fname eq 'STDOUT') )
      {
	$output = new IO::File( ">$fname" ) or die "could not open output file - $fname $!\n";;

	if( !( $output ) )
	  {
	    $bsml_logger->fatal( "Could not open output file - $fname $!" );
	    die "could not open output file - $fname $!\n";
	  }
      }

    # Setting DATA_MODE to 1 enables XML::Writer to insert newlines around XML elements for 
    # easier readability. DATA_INDENT specifies an indent of two spaces for child elements

    my $writer;

    if( $fname eq 'STDOUT' ){ $writer = new XML::Writer( DATA_MODE => 1, DATA_INDENT => 2);}
    else{$writer = new XML::Writer(OUTPUT => $output, DATA_MODE => 1, DATA_INDENT => 2);}

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

    if( @{$self->{'BsmlGenomes'}} )
    {
	$writer->startTag( "Genomes" );
	
	foreach my $genome ( @{$self->{'BsmlGenomes'}} )
	{
	    $genome->write( $writer );
	}
	
	$writer->endTag( "Genomes" );
    }

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

    if( @{$self->{'BsmlSeqPairAlignments'}} || @{$self->{'BsmlMultipleAlignmentTables'}} )
    {
      $writer->startTag( "Tables", 'id' => 'BsmlTables' );

      foreach my $seqAlignment ( @{$self->{'BsmlSeqPairAlignments'}} )
      {
        $seqAlignment->write( $writer );
      }

      foreach my $malnTable ( @{$self->{'BsmlMultipleAlignmentTables'}} )
      {
	  $malnTable->write( $writer );
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

    #clean up open fhs
    $writer->end();
    
    if( !($fname eq 'STDOUT') )
      {
	  $output->close();
	  $bsml_logger->info("Output handle $output closed for file $fname $!");
      }

    $bsml_logger->debug( "BsmlDoc successfully written" );
  }

1
