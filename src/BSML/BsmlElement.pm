package BSML::BsmlElement;

use warnings;
use strict;

=head1 NAME

BsmlElement.pm - Base Class for Bsml Elements

=head1 VERSION

This document refers to version 1.0 of the BSML Object Layer

=head1 SYNOPSIS

  $bsmlelem->setattr( 'id', 'A11243' );
  $hashref = $bsmlelem->returnattrHashR();

  foreach my $key ( keys( %{$hashref} ))
  {
    print "$hashref->{$key}\n";
  }

=head1 DESCRIPTION

=head2 Overview

  This file provides a base class for handling element attributes and BSML elements.

=head2 Constructor and initialization 

  A BsmlElement is not useful by itself. It should be only used as a base class.

=head2 Class and object methods

=over 4

=cut

=item $elem->addattr( $key, $value )

B<Description:> add an attribute to a Bsml element

B<Parameters:> ($key, $value) - a key value pair 

B<Returns:> None

=cut

sub addattr
  {
    my $self = shift;
    my ( $key, $value ) = @_;
    if( defined( $value ) ){
	$self->{ 'attr' }->{ $key } = $value;}
  }

=item $elem->setattr( $key, $value )

B<Description:> sets an attribute (equivalent to addattr(), but kept for consistency with other API classes)

B<Parameters:>  ($key, $value) - a key value pair 

B<Returns:> None

=cut

sub setattr
  {
    my $self = shift;
    my ( $key, $value ) = @_;

    $self->addattr( $key, $value );
  }

=item $elem->setattrh( $hashref )

B<Description:> sets an elements attributes according to the key/value pairs defined in the hash pointed to by $hashref

B<Parameters:> ($hashref) a reference pointing to a hash containing the key value pairs to be added as element attributes

B<Returns:> None

=cut

sub setattrh
  {
    my $self = shift;

    my ($href) = @_;

    foreach my $key (keys(%{$href}))
      {
	$self->addattr( $key, $href->{$key} );
      }
  }

=item $elem->dropattr( $key )

B<Description:> removes an attribute from a BSML element

B<Parameters:> ($key) - the attribute key

B<Returns:> None

=cut

sub dropattr
  {
    my $self = shift;
    my ( $key, $value ) = @_;

    delete($self->{'attr'}->{$key});
  }

=item $elem->returnattrHashR()

B<Description:> returns a hash reference to the key, value pairs making up an elements attribute set

B<Parameters:> None

B<Returns:> hash reference

=cut

sub returnattrHashR
  {    
    my $self = shift;
    return $self->{'attr'};
  }

=item $elem->returnattr( $key )

B<Description:> returns an attributes value given its key

B<Parameters:> ( $key ) - an attribute key

B<Returns:> an attribute value

=cut

sub returnattr
  {
    my $self = shift;
    my ($key) = @_;

    return $self->{'attr'}->{$key};
  }

=item $elem->addBsmlAttr( $key, $value )

B<Description:> add a BSML attribute to a Bsml element

B<Parameters:> ($key, $value) - a key value pair 

B<Returns:> None

=cut

sub addBsmlAttr
  {
    my $self = shift;
    my ( $key, $value ) = @_;
    if( defined( $value ) ){
	$self->{ 'BsmlAttr' }->{ $key } = $value;
    }
  }

=item $elem->setattr( $key, $value )

B<Description:> sets a BSML attribute (equivalent to addBsmlAttr(), but kept for consistency with other API classes)

B<Parameters:>  ($key, $value) - a key value pair 

B<Returns:> None

=cut

sub setBsmlAttr
  {
    my $self = shift;
    my ( $key, $value ) = @_;
    
    $self->addBsmlAttr( $key, $value );
  }

=item $elem->setBsmlAttrh( $hashref )

B<Description:> sets BSML attributes according to the key/value pairs defined in the hash pointed to by $hashref

B<Parameters:> ($hashref) a reference pointing to a hash containing the key value pairs to be added as Bsml attributes

B<Returns:> None

sub setBsmlAttrh
  {
    my $self = shift;

    my ($href) = @_;

    foreach my $key (keys(%{$href}))
      {
	$self->addBsmlAttr( $key, $href->{$key} );
      }
  }


=item $elem->dropBsmlAttr( $key )

B<Description:> removes a BSML attribute from a BSML element

B<Parameters:> ($key) - the attribute key

B<Returns:> None

=cut

sub dropBsmlAttr
  {
    my $self = shift;
    my ( $key, $value ) = @_;

    delete($self->{ 'BsmlAttr' }->{ $key });
  }

=item $elem->returnBsmlAttrHashR()

B<Description:> returns a hash reference to the key, value pairs making up an elements attribute set

B<Parameters:> None

B<Returns:> hash reference

=cut

sub returnBsmlAttrHashR
  {
    my $self = shift;
    return $self->{ 'BsmlAttr' };
  }

=item $elem->returnBsmlAttr( $key )

B<Description:> returns a BSML attribute value given its key

B<Parameters:> ($key) - the attribute key

B<Returns:> attribute value

=cut

sub returnBsmlAttr
{
  my $self = shift;
  my ($key) = @_;
  return $self->{'BsmlAttr'}->{$key};
}

sub addBsmlLink
  {
    my $self = shift;
    my ($rel, $href) = @_;

    if( defined($rel) && defined($href) )
    {
	push(@{$self->{'BsmlLink'}}, {rel=>$rel, href=>$href});
	return @{$self->{'BsmlLink'}} - 1;
    }
  }

sub setBsmlLink
  {
    my $self = shift;
    my ($rel, $href) = @_;
    
    return $self->addBsmlLink( $rel, $href );
  }

sub dropBsmlLink
  {
    my $self = shift;
    my ($index) = @_;

    my $newlist;

    for( my $i=0; $i< @{$self->{'BsmlLink'}}; $i++ )
      {
	if( $i != $index )
	  {
	    push( @{$newlist}, $self->{'BsmlLink'}[$i] );
	  }
      }

    $self->{'BsmlLink'} = $newlist;
  }

sub returnBsmlLinkListR
  {
    my $self = shift;
    return $self->{'BsmlLink'};
  }

sub returnBsmlLinkR
  {
    my $self = shift;
    my ($index) = @_;

    return $self->{'BsmlLink'}[$index];
  }

sub write()
  {
    
  }

1
