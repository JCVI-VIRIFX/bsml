package BsmlDoc;
@ISA = qw( BsmlElement );

use BsmlElement;
use XML::Writer;
use strict;
use warnings;
use BsmlSequence;

my $default_dtd_pID = '-//EBI//Labbook, Inc. BSML DTD//EN';
my $default_dtd_sID = 'http://www.labbook.com/dtd/bsml3_1.dtd';

# a bsml document stores a list of annotated sequences

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
    
    #bsml Genomes will probably be needed in the future...
  }

sub addBsmlSequence
  {
    my $self = shift;
     
    push( @{$self->{'BsmlSequences'}}, new BsmlSequence );

    my $index = @{$self->{'BsmlSequences'}} - 1;
    return $index;    
  }

sub dropBsmlSequence
  {
    my $self = shift;

    my ($index) = @_;

    my @newlist;

    for(  my $i=0;  $i<length(@{$self->{'BsmlSequences'}}); $i++ ) 
      {
	if( $i != $index )
	  {
	    push( @newlist, $self->{'BsmlSequences'}[$i] );
	  }
      }

    $self->{'BsmlSequences'} = \@newlist;
  }

sub returnBsmlSequenceListR
  {
    my $self = shift;

    return $self->{'BsmlSequences'};
  }

sub returnBsmlSequence
  {
    my $self = shift;
    my ($index) = @_;

    return $self->{'BsmlSequences'}[$index];  
  }

sub write
  {
    my $self = shift;
    my ($fname, $dtd) = @_;

    my $output = new IO::File( ">$fname" ) or die "could not open output file - $fname\n";

    my $writer = new XML::Writer(OUTPUT => $output, DATA_MODE => 1, DATA_INDENT => 2);  

    $writer->xmlDecl();

    # If a local file dtd is not specified the default will be used.
    # The default points to the publicly available dtd at Labbook

    if( $dtd ){$writer->doctype( "Bsml", "", "file:$dtd" );}
    else{
      $writer->doctype( "Bsml", $default_dtd_pID, $default_dtd_sID );
      }
   
    $writer->startTag( "Bsml", %{$self->{'attr'}} );

    foreach my $bsmlattr (keys( %{$self->{ 'BsmlAttr'}}))
      {
	$writer->startTag( "Attribute", 'name' => $bsmlattr, 'content' => $self->{'BsmlAttr'}->{$bsmlattr} );
	$writer->endTag( "Attribute" );
      }

    $writer->startTag( "Definitions" );
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
