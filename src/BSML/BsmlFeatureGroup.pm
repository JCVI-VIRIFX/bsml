package BsmlFeatureGroup;
@ISA = qw( BsmlElement );

use BsmlElement;
use XML::Writer;
use strict;
use warnings;

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
    $self->{ 'BsmlFeatureGroupMembers' } = [];
    $self->{ 'text' } = '';
  }

sub addBsmlFeatureGroupMember
  {
    my $self = shift;
    my ( $feat, $feature_type, $group_type, $text ) = @_;

    my $href = { 'feature' => $feat, 'feature-type' => $feature_type, 'group-type' => $group_type, 'text' => $text };

    push( @{$self->{'BsmlFeatureGroupMembers'}}, $href );

    my $index = @{$self->{'BsmlFeatureGroupMembers'}} - 1;
    return $index;
  }

sub dropBsmlFeatureGroupMember
  {
    my $self = shift;
    my ($index) = @_;

    my @newlist;

    for( my $i=0; $i<length(@{$self->{'BsmlFeatureGroupMembers'}}); $i++ )
      {
	if( $i != $index )
	  {
	    push( @newlist, $self->{'BsmlFeatureGroupMembers'}[$i] );
	  }
      }

    $self->{'BsmlFeatureGroupMembers'} = \@newlist;    
  }

sub setText
  {
    my $self = shift;
    my ($text) = @_;

    $self->{'text'} = $text;
  }

sub returnText
  {
    my $self = shift;
    return $self->{'text'};
  }

sub returnFeatureGroupMemberListR
  {
    my $self = shift;
    return $self->{'BsmlFeatureGroupMembers'};
  }

sub returnFeatureGroupMemberR
  {
    my $self = shift;
    my ($index) = @_;

    return $self->{'BsmlFeatureGroupMembers'}[$index];
  }

sub write
  {
    my $self = shift;
    my $writer = shift;

    $writer->startTag( 'Feature-group', %{$self->{'attr'}} );

    foreach my $bsmlattr (keys( %{$self->{ 'BsmlAttr'}}))
      {
	$writer->startTag( "Attribute", 'name' => $bsmlattr, 'content' => $self->{'BsmlAttr'}->{$bsmlattr} );
	$writer->endTag( "Attribute" );
      }

    foreach my $bsmlfeaturemember ( @{$self->{'BsmlFeatureGroupMembers'}} )
      {
	my $h = {};

	if( $bsmlfeaturemember->{'feature'} ){ $h->{'featref'} = $bsmlfeaturemember->{'feature'};}
	if( $bsmlfeaturemember->{'feature-type'} ){$h->{'feature-type'} = $bsmlfeaturemember->{'feature-type'};}
	if( $bsmlfeaturemember->{'group-type'} ){$h->{'group-type'} = $bsmlfeaturemember->{'feature-type'};}

	$writer->startTag( "Feature-group-member", %{ $h } );
	if( $bsmlfeaturemember->{'text'} ){ $writer->characters( $bsmlfeaturemember->{'text'} ); }
	$writer->endTag( "Feature-group-member" );
      }

    $writer->endTag( "Feature-group" );

  }

1

