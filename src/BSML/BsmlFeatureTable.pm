package BsmlFeatureTable;
@ISA = qw( BsmlElement );

use BsmlElement;
use XML::Writer;
use BsmlFeature;
use BsmlReference;
use strict;
use warnings;

# A feature table contains a list of references and a list of features

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
    $self->{ 'BsmlFeatures' } = [];
    $self->{ 'BsmlReferences' } = [];

  }

sub addBsmlFeature
  {
    my $self = shift;
    push( @{$self->{'BsmlFeatures'}}, new BsmlFeature );

    my $index = @{$self->{'BsmlFeatures'}} - 1;
    return $index;
  }

sub dropBsmlFeature
  {
    my $self = shift;
    my ($index) = @_;

    my $newlist = [];

    for(  my $i=0;  $i< @{$self->{'BsmlFeatures'}}; $i++ ) 
      {
	if( $i != $index )
	  {
	    push( @{$newlist}, $self->{'BsmlFeatures'}[$i] );
	  }
      }

    $self->{'BsmlFeatures'} = $newlist;
  }

sub returnBsmlFeatureListR
  {
    my $self = shift;

    return $self->{'BsmlFeatures'};
  }

sub returnBsmlFeatureR
  {
    my $self = shift;
    my ($index) = @_;

    return $self->{'BsmlFeatures'}[$index];
  }

sub addBsmlReference
  {
    my $self = shift;
    push( @{$self->{'BsmlReferences'}}, new BsmlReference );

    my $index = @{$self->{'BsmlReferences'}} - 1;
    return $index;
  }

sub dropBsmlReference
  {
    my $self = shift;
    my ($index) = @_;

    my $newlist = [];

    for(  my $i=0;  $i < @{$self->{'BsmlReferences'}}; $i++ ) 
      {
	if( $i != $index )
	  {
	    push( @{$newlist}, $self->{'BsmlReferences'}[$i] );
	  }
      }

    $self->{'BsmlReferences'} = $newlist;
  }

sub returnBsmlReferenceListR
  {
    my $self = shift;
    
    return $self->{'BsmlReferences'};
  }

sub returnBsmlReferenceR
  {
    my $self = shift;
    my ($index) = @_;

    return $self->{'BsmlReferences'}[$index];
  }

sub write
  {
    my $self = shift;
    my $writer = shift;

    $writer->startTag( "Feature-table", %{$self->{'attr'}} );

    foreach my $bsmlattr (keys( %{$self->{ 'BsmlAttr'}}))
      {
	$writer->startTag( "Attribute", 'name' => $bsmlattr, 'content' => $self->{'BsmlAttr'}->{$bsmlattr} );
	$writer->endTag( "Attribute" );
      }

    foreach my $bsmlfeature (@{$self->{'BsmlFeatures'}})
      {
	$bsmlfeature->write( $writer );
      }

    foreach my $bsmlref (@{$self->{'BsmlReferences'}})
      {
	$bsmlref->write( $writer );
      }

    $writer->endTag( "Feature-table" );
  }

1
