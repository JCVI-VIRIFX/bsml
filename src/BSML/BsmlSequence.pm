package BsmlSequence;
@ISA = qw( BsmlElement );

use BsmlElement;
use XML::Writer;
use strict;
use warnings;
use BsmlFeatureTable;

# a bsml sequence stores raw sequence data and a list of feature tables

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
    $self->{ 'BsmlFeatureTables' } = [];
    $self->{ 'BsmlSeqData' } = '';
  }

sub addBsmlFeatureTable
  {
    my $self = shift;
    push( @{$self->{'BsmlFeatureTables'}}, new BsmlFeatureTable );

    my $index = @{$self->{'BsmlFeatureTables'}} - 1;
    return $index;
  }

sub dropBsmlFeatureTable
  {
    my $self = shift;
    my ($index) = @_;

    my @newlist;

    for( my $i=0; $i<length(@{$self->{'BsmlFeatureTables'}}); $i++ )
      {
	if( $i != $index )
	  {
	    push( @newlist, $self->{'BsmlFeatureTables'}[$i] );
	  }
      }

    $self->{'BsmlFeatureTables'} = \@newlist;    
  }

sub returnFeatureTableListR
  {
    my $self = shift;

    return $self->{'BsmlFeatureTables'};
  }

sub returnFeatureTable
  {
    my $self = shift;
    my ($index) = @_;

    return $self->{'BsmlFeatureTables'}[$index];
  }

sub addBsmlSeqData
  {
    my $self = shift;

    ($self->{'BsmlSeqData'}) = @_; 
  }

sub setBsmlSeqData
  {
    my $self = shift;
    my ($seq) = @_;

    $self->addBsmlSeqData( $seq );
  }

sub dropBsmlSeqData
  {
    my $self = shift;
   
    $self->{'BsmlSeqData'} = '';
  }

sub returnSeqData
  {
    my $self = shift;

    return $self->{'BsmlSeqData'};
  }

sub write
  {
    my $self = shift;
    my $writer = shift;

    $writer->startTag( "Sequence", %{$self->{'attr'}} );

    foreach my $bsmlattr (keys( %{$self->{ 'BsmlAttr'}}))
      {
	$writer->startTag( "Attribute", 'name' => $bsmlattr, 'content' => $self->{'BsmlAttr'}->{$bsmlattr} );
	$writer->endTag( "Attribute" );
      }

    $writer->startTag( "Feature-tables" );

    foreach my $tbl ( @{$self->{'BsmlFeatureTables'}} )
      {
	$tbl->write( $writer );
      }

    $writer->endTag( "Feature-tables" );

    if( $self->{'BsmlSeqData'} )
      {
	$writer->startTag( "Seq-data" );
	$writer->characters( $self->{'BsmlSeqData'} );
	$writer->endTag( "Seq-data" );
      }

    $writer->endTag( "Sequence" );
    
  }

1

