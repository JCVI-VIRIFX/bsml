package BsmlBuilder;
@ISA = qw( BsmlDoc );

=head1 NAME

  BsmlBuilder.pm - class to facilitate the creation of BSML documents using a similar
  interface to that provided by the Labbook Bsml API's Java class BsmlBuilder.

=head1 VERSION

  This document refers to version 1.0 of the BSML Object Layer

=head1 SYNOPSIS

  to be completed...

=cut

use strict;
use warnings;
use BsmlDoc;

sub createAndAddSequence
{
  my $self = shift;
  my ( $id, $title, $molecule, $length ) = @_;

  #return a reference to the created sequence
}

sub createAndAddExtendedSequence
  {
    my $self = shift;
    my ( $id, $title, $length, $molecule, $locus, $dbsource, $icAcckey, $topology, $strand ) = @_;

    #return a reference to the created sequence
  }

sub createAndAddFeatureTable
  {
    my $self = shift;
    my ( $seq, $id, $title, $class ) = @_;

    #use ref() to determine if $seq is a BsmlSequence object or a scalar containing the sequences Bsml ID
    
    #return a reference to the created Feature Table
  }

sub createAndAddReference
  {
    my $self = shift;
    my ( $FTable, $refID, $refAuthors, $refTitle, $refJournal, $dbxref );

    #use ref() to determine if $FTable is a BsmlFeatureTable or a scalar containing the table's Bsml ID
  }

sub createAndAddFeature
  {
    my $self = shift;
    my ( $FTable, $id, $title, $class, $comment, $displayAuto ) = @_;
  }

sub createAndAddFeatureWithLoc
  {
    my $self = shift;
    my ( $FTable, $id, $title, $class, $comment, $displayAuto, $start, $end, $complement );
  }



