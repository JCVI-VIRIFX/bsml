package BsmlFeature;
@ISA = qw( BsmlElement );

use XML::Writer;
use BsmlElement;
use strict;
use warnings;

# The Bsml Feature element encodes feature qualifier and feature location elements

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
    $self->{ 'BsmlSite-Loc' } = [];
    $self->{ 'BsmlInterval-Loc' } = [];
    $self->{ 'BsmlQual' } = {};
  }
    


sub addBsmlQualifier
  {
    my $self = shift;
    my ( $valuetype, $value ) = @_;

    $self->{'BsmlQual'}->{ $valuetype } = $value;
  }

sub setBsmlQualifier
  {
    my $self = shift;
    my ( $valuetype, $value ) = @_;

    $self->addBsmlQualifier( $valuetype, $value );
  }

sub dropBsmlQualifier
  {
    my $self = shift;
    my ( $valuetype ) = @_;

    delete( $self->{'BsmlQual'}->{ $valuetype } );
  }

sub returnBsmlQualifierHash
  {
    my $self = shift;
    return $self->{'BsmlQual'};
  }

sub addBsmlSiteLoc
  {
    my $self = shift;
    my ( $sitepos, $comp ) = @_;

    push( @{$self->{'BsmlSite-Loc'}}, { 'sitepos' => $sitepos, 'complement' => $comp } );
  }

sub setBsmlSiteLoc
  {
    my $self = shift;
    my ( $sitepos, $comp ) = @_;

    my @newlist;

    foreach my $site ( @{$self->{'BsmlSite-Loc'}} )
      {
	if( !($site->{'sitepos'} == $sitepos ) )
	  {
	    push( @newlist, $site );
	  }
      }

    $self->{'BsmlSite-Loc'} = \@newlist;

    $self->addBsmlSiteLoc( $sitepos, $comp );
  }

sub dropBsmlSiteLoc
  {
    my $self = shift;
    my ( $sitepos, $comp ) = @_;

    my $newlist = [];
    
    foreach my $site ( @{$self->{'BsmlSite-Loc'}} )
      {
	if( !($site->{'sitepos'} == $sitepos ) )
	  {
	    push( @{$newlist}, $site );
	  }
      }

    $self->{'BsmlSite-Loc'} = $newlist;
  }

sub returnBsmlSiteLocList
  {
    my $self = shift;

    return $self->{'BsmlSite-Loc'};
  }


sub addBsmlIntervalLoc
  {
    my $self = shift;
    my ( $startpos, $endpos, $comp ) = @_;

    push( @{$self->{'BsmlInterval-Loc'}}, { 'startpos' => $startpos, 'endpos' => $endpos, 'complement' => $comp } );
  }

sub setBsmlIntervalLoc
  {
    my $self = shift;
    my ( $startpos, $endpos, $comp ) = @_;

    my @newlist;
    
    foreach my $site ( @{$self->{'BsmlInterval-Loc'}} )
      {
	if( !($site->{'startpos'} == $startpos ) && !( $site->{'endpos'} == $endpos) )
	  {
	    push( @newlist, $site );
	  }
      }

    $self->{'BsmlInterval-Loc'} = \@newlist;

    $self->addBsmlIntervalLoc( $startpos, $endpos, $comp );
  }

sub dropBsmlIntervalLoc
  {
    my $self = shift;
    my ( $startpos, $endpos, $comp ) = @_;

    my $newlist = [];
    
    foreach my $site ( @{$self->{'BsmlInterval-Loc'}} )
      {
	if( !($site->{'startpos'} == $startpos ) && !( $site->{'endpos'} == $endpos) )
	  {
	    push( @{$newlist}, $site );
	  }
      }

    $self->{'BsmlInterval-Loc'} = $newlist;
  }

sub returnBsmlIntervalLocList
  {
    my $self = shift;
    return $self->{'BsmlInterval-Loc'};
  }


sub write
  {
    my $self = shift;
    my $writer = shift;

    $writer->startTag( "Feature", %{$self->{'attr'}} );

    foreach my $bsmlattr (keys( %{$self->{ 'BsmlAttr'}}))
      {
	$writer->startTag( "Attribute",  'name' => $bsmlattr, 'content' => $self->{'BsmlAttr'}->{$bsmlattr} );
	$writer->endTag( "Attribute" );
      }

    foreach my $bsmlqual (keys( %{$self->{'BsmlQual'}} ))
      {
	my %tmp = ( 'value-type' => $bsmlqual, 'value' => $self->{'BsmlQual'}->{$bsmlqual} );
	
	$writer->startTag( "Qualifier", %tmp );
	$writer->endTag( "Qualifier" );
      }

    foreach my $bsmlsite (@{$self->{'BsmlSite-Loc'}})
      {
	$writer->startTag( "Site-loc", %{$bsmlsite} );
	$writer->endTag( "Site-loc" );
      }

    foreach my $bsmlsite (@{$self->{'BsmlInterval-Loc'}})
      {
	$writer->startTag( "Interval-loc", %{$bsmlsite} );
	$writer->endTag( "Interval-loc" );
      }
    
    $writer->endTag( "Feature" );
  }

1
