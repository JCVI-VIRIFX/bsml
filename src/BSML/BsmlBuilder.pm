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

# class variable used to create unique element identifiers
my $elem_id = 0;

=item $builder->createAndAddSequence( $id, $title, $length, $molecule )

B<Description:> Creates a simple Bsml sequence containing minimum attributes

B<Parameters:> $id - the identifier of the Bsml element (unique at the document level)
  $title - the title of the sequence
  $length - the sequence length
  $molecule - the type of molecule from the controled vocabulary ( mol-not-set, dna, rna, aa, na, other-mol ) the default is mol-net-set

B<Returns:> a sequence object reference

=cut 

sub createAndAddSequence
{
  my $self = shift;
  my ( $id, $title, $length, $molecule ) = @_;

  if( !(defined($id) || $id eq '' ) )
    {
      $id = "Bsml"."$elem_id";
      $elem_id++;

      #replace with log4perl
      print "Warning: id not approriately defined. Using $id\n";
    }

  if( !(defined($title) || $title eq '' ) )
    {
      $title = 'unspecified';

      #replace with log4perl
      print "Warning: title not approriately defined. Using $title\n";
    }

  if( !( defined($molecule) || $molecule eq '' ) )
    {
      $molecule = 'mol-not-set';

      #replace with log4perl
      print "Warning: molecule not appropriately defined. Using $molecule.\n";
    }
  else
    {
      if( !($molecule eq 'mol-not-set') || !($molecule eq 'dna') || !($molecule eq 'rna') || !($molecule eq 'aa') || !($molecule eq 'na') || !($molecule eq 'other-mol') )
	{
	  $molecule = 'mol-not-set';
	  
	  #replace with log4perl 
	  print "Warning: molecule type not with controlled vocabulary. Using $molecule.\n";
	}
    }

  my $seq = returnBsmlSequenceR( addBsmlSequence() );
  $seq->setattr( 'id', $id );
  $seq->setattr( 'title', $title );
  $seq->setattr( 'molecule', $molecule );

  if( defined($length) && !($length eq '') ){ $seq->setattr( 'length', $length ); }
  
  #return a reference to the new sequence

  return $seq;
}

# The permisible values for the topology and strand parameters are controled
# topology (top-not-set, linear, circular, tandem, top-other )
# strand (std-not-set, ss, ds, mixed, std-other) 

sub createAndAddExtendedSequence
  {
    my $self = shift;
    my ( $id, $title, $length, $molecule, $locus, $dbsource, $icAcckey, $topology, $strand ) = @_;

    my $seq = $self->createAndAddSequence( $id, $title, $length, $molecule );

    if( defined($locus) && !($locus eq '') ){ $seq->setattr('locus', $locus);}
    if( defined($dbsource) && !($dbsource eq '') ){ $seq->setattr('dbsource', $dbsource);}
    if( defined($icAcckey) && !($icAcckey eq '') ){ $seq->setattr('ic-acckey', $icAcckey);}
    
    if( defined($topology) && !($topology eq '') ){ 
      if( $topology eq 'top-not-set' || $topology eq 'linear' || $topology eq 'circular' || $topology eq 'tandem' || $topology eq 'top-other' ){
	$seq->setattr('topology', $topology);}
      else{
	$topology = 'top-not-set';
	print "Warning: topology not in controled vocabulary. Using $topology\n";
	$seq->setattr('topology', $topology);}
    }

    if( defined($strand) && !($strand eq '') ){ 
      if( $strand eq 'std-not-set' || $strand eq 'ss' || $strand eq 'ds' || $strand eq 'mixed' || $strand eq 'std-other' ){
	$seq->setattr('strand', $strand);}
      else{
	$strand = 'std-not-set';
	print "Warning: strand not in controled vocabulary. Using $strand\n";
	$seq->setattr('strand', $strand);}
    }
		
    #return a reference to the created sequence

    return $seq;
  }

sub createAndAddExtendedSequenceN
  {
    my $self = shift;
    my %args = @_;

    return $self->createAndAddExtendedSequence( $args{'id'}, $args{'title'}, $args{'length'}, $args{'molecule'}, $args{'locus'}, $args{'dbsource'}, $args{'icAcckey'}, $args{'topology'}, $args{'strand'});

  }

sub createAndAddFeatureTables
  {
    #not used in the Bsml API
  }

sub createAndAddFeatureTable
  {
    my $self = shift;
    my ( $seq, $id, $title, $class ) = @_;

    if( !(defined($id) || $id eq '' ) )
      {
	$id = "Bsml"."$elem_id";
	$elem_id++;

	#replace with log4perl
	print "Warning: id not approriately defined. Using $id\n";
      }

    if( ref($seq) eq 'BsmlSequence' )
      {
	my $FTable = $seq->returnBsmlFeatureTableR( $seq->addBsmlFeatureTable() );
	$FTable->setattr( 'id', $id );
	if( defined($title) && !($title eq '') ){ $FTable->setattr('title', $title); }
	if( defined($class) && !($class eq '') ){ $FTable->setattr('class', $class); }

	return $FTable;
      }
    else
      {
	my $sequences = $self->returnBsmlSequenceListR();

	foreach my $seqR ( @{$sequences} )
	  {
	    if( $seqR->returnattr('id') eq $seq )
	      {
		my $FTable = $seqR->returnBsmlFeatureTableR( $seqR->addBsmlFeatureTable() );
		$FTable->setattr( 'id', $id );
		if( defined($title) && !($title eq '') ){ $FTable->setattr('title', $title); }
		if( defined($class) && !($class eq '') ){ $FTable->setattr('class', $class); }

		return $FTable;
	      }
	  }
      }
  }

sub createAndAddFeatureTableN
  {
    my $self = shift;

    my %args = @_;

    return $self->createAndAddFeatureTable( $args{'seq'}, $args{'id'}, $args{'title'}, $args{'class'} );
  }

sub createAndAddReference
  {
    my $self = shift;
    my ( $FTable, $refID, $refAuthors, $refTitle, $refJournal, $dbxref );

    if( !(defined($refID) || $refID eq '' ) )
      {
	$refID = "Bsml"."$elem_id";
	$elem_id++;

	#replace with log4perl
	print "Warning: id not approriately defined. Using $refID\n";
      }

     if( ref($FTable) eq 'BsmlFeatureTable' )
      {
	my $rref = $FTable->returnBsmlReferenceR( $FTable->addBsmlReference() );
	$rref->setattr( 'id', $refID );

	if( defined($refAuthors) && !($refAuthors eq '') ){ $rref->addBsmlRefAuthors( $refAuthors ); }
	if( defined($refTitle) && !($refTitle eq '')){ $rref->addBsmlRefTitle( $refTitle ); }
	if( defined($refJournal) && !($refJournal eq '')){ $rref->addBsmlRefJournal( $refJournal ); }

	if( defined($dbxref) && !($dbxref eq '' )){ $rref->setattr( 'dbxref', $dbxref ); }

	return $rref;
      }
    else
      {
	my $seqs =  $self->returnBsmlSequenceListR();

	foreach my $seq ( @{$seqs} )
	  {
	    foreach my $FeatureTable ( @{$seq->returnBsmlFeatureTableListR()} )
	      {
		if( $FeatureTable->returnattr( 'id' ) eq $FTable )
		  {
		    my $rref = $FeatureTable->returnBsmlReferenceR( $FeatureTable->addBsmlReference() );
		    
		    $rref->setattr( 'id', $refID );

		    if( defined($refAuthors) && !($refAuthors eq '') ){ $rref->addBsmlRefAuthors( $refAuthors ); }
		    if( defined($refTitle) && !($refTitle eq '')){ $rref->addBsmlRefTitle( $refTitle ); }
		    if( defined($refJournal) && !($refJournal eq '')){ $rref->addBsmlRefJournal( $refJournal ); }

		    if( defined($dbxref) && !($dbxref eq '' )){ $rref->setattr( 'dbxref', $dbxref ); }

		    return $rref;
		  }
	      }
	  }
      }
  }

sub createAndAddReferenceN
  {
    my $self = shift;
    my %args = @_;

    return $self->createAndAddReferenceN( $args{'FTable'}, $args{'refID'}, $args{'refAuthors'}, $args{'refTitle'}, $args{'refJournal'}, $args{'dbxref'} );
  }

sub createAndAddFeature
  {
    my $self = shift;
    my ( $FTable, $id, $title, $class, $comment, $displayAuto ) = @_;

     if( !(defined($id) || $id eq '' ) )
      {
	$id = "Bsml"."$elem_id";
	$elem_id++;

	#replace with log4perl
	print "Warning: id not appropriately defined. Using $id\n";
      }

      if( ref($FTable) eq 'BsmlFeatureTable' )
      {
	my $fref = $FTable->returnBsmlFeatureR( $FTable->addBsmlFeature() );
	$fref->setattr( 'id', $id );

	if( defined($title) && !($title eq '') ){ $fref->setattr( 'title', $title ); }
	if( defined($class) && !($class eq '')){ $fref->setattr('class', $class); }
	if( defined($comment) && !($comment eq '')){ $fref->setattr('comment', $comment); }

	if( defined($displayAuto) && !($displayAuto eq '' )){ $fref->setattr( 'display-auto', $displayAuto ); }

	return $fref;
      }
    else
      {
	my $seqs =  $self->returnBsmlSequenceListR();

	foreach my $seq ( @{$seqs} )
	  {
	    foreach my $FeatureTable (@{$seq->returnBsmlFeatureTableListR()})
	      {
		if( $FeatureTable->returnattr( 'id' ) eq $FTable )
		  {
		    my $fref = $FeatureTable->returnBsmlFeatureR( $FeatureTable->addBsmlFeature() );
		    $fref->setattr( 'id', $id );

		    if( defined($title) && !($title eq '') ){ $fref->setattr( 'title', $title ); }
		    if( defined($class) && !($class eq '')){ $fref->setattr('class', $class); }
		    if( defined($comment) && !($comment eq '')){ $fref->setattr('comment', $comment); }

		    if( defined($displayAuto) && !($displayAuto eq '' )){ $fref->setattr( 'display-auto', $displayAuto ); }

		    return $fref;
		  }
	      }
	  }
	}
  }

sub createAndAddFeatureN
  {
    my $self = shift;
    my %args = @_;

    return $self->createAndAddFeature( $args{'FTable'}, $args{'id'}, $args{'$title'}, $args{'class'}, $args{'comment'}, $args{'displayAuto'} );
  }

sub createAndAddFeatureWithLoc
  {
    my $self = shift;
    my ( $FTable, $id, $title, $class, $comment, $displayAuto, $start, $end, $complement ) = @_;

    my $feature = $self->createAndAddFeature( $FTable, $id, $title, $class, $comment, $displayAuto );

    if( $start == $end )
      {
	#add a site position to the feature
	$feature->addBsmlSiteLoc( $start, $complement );
      }
    else
      {
	#add an interval location to the feature
	$feature->addBsmlIntervalLoc( $start, $end, $complement );
      }

    return $feature;     
  }

sub createAndAddFeatureWithLocN
  {
    my $self = shift;
    my %args = @_;

    return $self->createAndAddFeatureWithLoc( $args{'FTable'}, $args{'id'}, $args{'title'}, $args{'class'}, $args{'comment'}, $args{'displayAuto'}, $args{'start'}, $args{'end'}, $args{'complement'} )
  }

sub createAndAddIntervalLoc
  {
    my $self = shift;
    my ( $feature, $start, $end, $complement ) = @_;

    if( ref($feature) eq 'BsmlFeature' )
      {
	$feature->addBsmlIntervalLoc( $start, $end, $complement );
      }
    else
      {
	my $seqs =  $self->returnBsmlSequenceListR();

	foreach my $seq ( @{$seqs} )
	  {
	    foreach my $FeatureTable ( @{$seq->returnBsmlFeatureTableListR()} )
	      {
		foreach my $rFeature( @{$FeatureTable->returnBsmlFeatureListR()} )
		  {
		    if( $rFeature->returnattr( 'id' ) eq $feature )
		      {
			$rFeature->addBsmlIntervalLoc( $start, $end, $complement );
		      }
		  }
	      }
	  }
      }

    return $feature;
  }

sub createAndAddIntervalLocN
  {
    my $self = shift;
    my %args = @_;

    return $self->createAndAddIntervalLoc( $args{'feature'}, $args{'start'}, $args{'end'}, $args{'complement'});
  }

sub createAndAddSiteLoc
  {
    my $self = shift;
    my ( $feature, $site, $complement ) = @_;

    if( ref($feature) eq 'BsmlFeature' )
      {
	$feature->addBsmlSiteLoc( $site, $complement );
      }
    else
      {
	my $seqs =  $self->returnBsmlSequenceListR();

	foreach my $seq ( @{$seqs} )
	  {
	    foreach my $FeatureTable ( @{$seq->returnBsmlFeatureTableListR()} )
	      {
		foreach my $rFeature( @{$FeatureTable->returnBsmlFeatureListR()} )
		  {
		    if( $rFeature->returnattr( 'id' ) eq $feature )
		      {
			$rFeature->addBsmlSiteLoc( $site, $complement );
		      }
		  }
	      }
	  }
      }

    return $feature;
  }

sub createAndAddSiteLocN
  {
    my $self = shift;
    my %args = @_;

    return $self->createAndAddSiteLoc( $args{'feature'}, $args{'site'}, $args{'complement'} );
  }

sub createAndAddQualifier
  {
    my $self = shift;
    my ( $feature, $valuetype, $value ) = @_;

    if( ref($feature) eq 'BsmlFeature' )
      {
	$feature->addBsmlQualifier( $valuetype, $value );
      }
    else
      {
	my $seqs =  $self->returnBsmlSequenceListR();

	foreach my $seq ( @{$seqs} )
	  {
	    foreach my $FeatureTable ( @{$seq->returnBsmlFeatureTableListR()} )
	      {
		foreach my $rFeature( @{$FeatureTable->returnBsmlFeatureListR()} )
		  {
		    if( $rFeature->returnattr( 'id' ) eq $feature )
		      {
			$rFeature->addBsmlQualifier( $valuetype, $value );
		      }
		  }
	      }
	  }
      }

    return $feature;
  }

sub createAndAddQualifierN
  {
    my $self = shift;
    my %args = @_;

    return $self->createAndAddQualifier( $args{'feature'}, $args{'valuetype'}, $args{'value'} )
  }

sub createAndAddSeqData
  {
    my $self = shift;
    my ( $seq, $seqdat ) = @_;

    if( ref($seq) eq 'BsmlSequence' )
      {
	$seq->addBsmlSeqData( $seqdat );	
	return $seq;
      }
    else
      {
	my $sequences = $self->returnBsmlSequenceListR();
	
	foreach my $seqR ( @{$sequences} )
	  {
	    if( $seqR->returnattr('id') eq $seq )
	      {
		$seqR->addBsmlSeqData( $seqdat );
		
		return $seqR;
	      }
	  }
      }
  }

sub createAndAddSeqDataN
  {
    my $self = shift;
    my %args = @_;
    
    return $self->createAndAddSeqDataN( $args{'seq'}, $args{'seqdat'} );
  }

sub createAndAddFeatureGroup
  {
    my $self = shift;
    my ( $sequence, $id, $title, $featureIdList ) = @_;

    
  }
