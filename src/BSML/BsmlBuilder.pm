package BsmlBuilder;
@ISA = qw( BsmlDoc );

=head1 NAME

  BsmlBuilder.pm - class to facilitate the creation of BSML documents using a similar
  interface to that provided by the Labbook Bsml APIs Java class BsmlBuilder.

=head1 VERSION

  This document refers to version 1.0 of the BSML Object Layer

=head1 SYNOPSIS

use BsmlBuilder;

my $seqdat = 'agctagctagctagctagctagct';
my $doc = new BsmlBuilder;
my $seq = $doc->createAndAddSequence( '_bsml001', 'test_basic_sequence', length( $seqdat ), 'dna' );
my $seq2 = $doc->createAndAddExtendedSequenceN( id => '_bsml002', title => 'test_extended_sequence', length => '24', molecule => 'dna', topology => 'linear' );
$doc->createAndAddSeqData( $seq, $seqdat );
$doc->write( 'output_file.xml' );

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

  if( !($id) )
    {
      $id = "Bsml"."$elem_id";
      $elem_id++;

      #replace with log4perl
      print "Warning: id not approriately defined. Using $id\n";
    }

  if( !($title) )
    {
      $title = 'unspecified';

      #replace with log4perl
      print "Warning: title not approriately defined. Using $title\n";
    }

  if( !($molecule) )
    {
      $molecule = 'mol-not-set';

      #replace with log4perl
      print "Warning: molecule not appropriately defined. Using $molecule.\n";
    }
  else
    {
      if( !(($molecule eq 'mol-not-set') || ($molecule eq 'dna') || ($molecule eq 'rna') || ($molecule eq 'aa') || ($molecule eq 'na') || ($molecule eq 'other-mol')) )
	{
	  print "molecule: $molecule\n";
	  $molecule = 'mol-not-set';
	  
	  #replace with log4perl 
	  print "Warning: molecule type not with controlled vocabulary. Using $molecule.\n";
	}
    }

  my $seq = $self->returnBsmlSequenceR( $self->addBsmlSequence() );
  $seq->setattr( 'id', $id );
  $seq->setattr( 'title', $title );
  $seq->setattr( 'molecule', $molecule );

  if( defined($length) && !($length eq '') ){ $seq->setattr( 'length', $length ); }
  
  #return a reference to the new sequence

  return $seq;
}

=item $builder->createAndAddExtendedSequence( $id, $title, $length, $molecule, $locus, $dbsource, $icAcckey, $topology, $strand )

B<Description:> Add a new sequence to the document with extended attributes

B<Parameters:> 
  $id - document wide unique identifier for the sequence
  $title - text description of sequence
  $length - integer value representing the total length of the sequence
  $molecule - type of molecule ( mol-not-set, dna, rna, aa, na, other-mol )
  $locus - sequence name
  $dbsource - database source of the sequence
  $icAcckey - internationl collboration accession number
  $topology - molecule shape (top-not-set, linear, circular, tandem, top-other )
  $strand - (std-not-set, ss, ds, mixed, std-other)

B<Returns:>
  A reference to the created sequence

=cut

sub createAndAddExtendedSequence
  {
    my $self = shift;
    my ( $id, $title, $length, $molecule, $locus, $dbsource, $icAcckey, $topology, $strand ) = @_;

    my $seq = $self->createAndAddSequence( $id, $title, $length, $molecule );

    if( $locus    ){ $seq->setattr('locus', $locus);}
    if( $dbsource ){ $seq->setattr('dbsource', $dbsource);}
    if( $icAcckey ){ $seq->setattr('ic-acckey', $icAcckey);}

    if( $topology ){ 
      if( $topology eq 'top-not-set' || $topology eq 'linear' || $topology eq 'circular' || $topology eq 'tandem' || $topology eq 'top-other' ){
	$seq->setattr('topology', $topology);}
      else{
	$topology = 'top-not-set';
	print "Warning: topology not in controled vocabulary. Using $topology\n";
	$seq->setattr('topology', $topology);}
    }

    if( $strand ){ 
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

=item $builder->createAndAddExtendedSequenceN( key => value )

B<Description:>
  Add a new sequence to the document with named extended attributes

B<Parameters:> 
  Looks for the following keys corresponding to the descriptions given above.
  {id, title, length, molecule, locus, dbsource, icAcckey, topology, strand}

B<Returns:>
  A reference to the created sequence

=cut

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

    if( !($id) )
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
	if( $title ){ $FTable->setattr('title', $title); }
	if( $class ){ $FTable->setattr('class', $class); }

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
		if( $title ){ $FTable->setattr('title', $title); }
		if( $class ){ $FTable->setattr('class', $class); }

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
    my ( $FTable, $refID, $refAuthors, $refTitle, $refJournal, $dbxref ) = @_;

    if( !($refID) )
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
		if( $FeatureTable->returnattr( 'id' )){
		  #if( $FeatureTable->returnattr('id') eq $FTable )
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

     if( !($id) )
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

sub createAndAddBsmlAttribute
  {
    my $self = shift;
    my ($elem, $key, $value ) = @_;

    $elem->addBsmlAttr( $key, $value );
  }

sub createAndAddBsmlAtributeN
  {
    my $self = shift;
    my %args = @_;

    my $elem = $args{'elem'};
    $elem->addBsmlAttr( $args{'key'}, $args{'value'} ); 
  }

sub createAndAddAttribute
  {
    my $self = shift;
    my ($elem, $key, $value) = @_;

    $elem->addattr( $key, $value );
  }

sub createAndAddAttributeN
  {
    my $self = shift;
    my %args = @_;

    my $elem = $args{'elem'};
    $elem->addattr( $args{'key'}, $args{'value'} );
  }

sub createAndAddLink
  {
    my $self = shift;
    my ($elem, $title, $href) = @_;

    $elem->addBsmlLink( $title, $href );
  }

sub createAndAddLinkN
  {
    my $self = shift;
    my %args = @_;
    my $elem = $args{'elem'};
    $elem->addBsmlLink( $args{'title'}, $args{'href'} );
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
    
    return $self->createAndAddSeqData( $args{'seq'}, $args{'seqdat'} );
  }

sub createAndAddSeqDataImport
  {
    my $self = shift;
    my ( $seq, $format, $source ) = @_;

    if( ref($seq) eq 'BsmlSequence' )
      {
	$seq->addBsmlSeqDataImport( $format, $source  );	
	return $seq;
      }
    else
      {
	my $sequences = $self->returnBsmlSequenceListR();
	
	foreach my $seqR ( @{$sequences} )
	  {
	    if( $seqR->returnattr('id') eq $seq )
	      {
		$seqR->addBsmlSeqDataImport( $format, $source );
		
		return $seqR;
	      }
	  }
      }
  }

sub createAndAddSeqDataImportN
  {
    my $self = shift;
    my %args = @_;
    
    return $self->createAndAddSeqDataImport( $args{'seq'}, $args{'format'}, $args{'source'} );
  }

sub createAndAddFeatureGroup
  {
    my $self = shift;
    my ( $sequence, $id, $title, $featureIdList ) = @_;    
  }

sub createAndAddBtabLine
  {
    my $self = shift;
    my ( $query_name, $date, $query_length, $blast_program, $search_database, $dbmatch_accession, $start_query, 
	 $stop_query, $start_hit, $stop_hit, $percent_identity, $percent_similarity, $bit_score, $chain_number,
	 $segment_number, $dbmatch_header, $unknown1, $unknown2, $e_value, $p_value ) = @_;

    return $self->createAndAddBtabLineN( query_name => $query_name, date => $date, query_length => $query_length, 
					 blast_program => $blast_program, search_database => $search_database, 
					 dbmatch_accession => $dbmatch_accession, start_query => $start_query,
					 stop_query => $stop_query, start_hit => $start_hit, stop_hit => $stop_hit, 
					 percent_identity => $percent_identity,
					 percent_similarity => $percent_similarity, bit_score => $bit_score, chain_number => $chain_number,
					 segment_number => $segment_number, dbmatch_header => $dbmatch_header, unknown1 => $unknown1, 
					 unknown2 => $unknown2, e_value => $e_value, p_value => $p_value );
  }

sub createAndAddBtabLineN
  {
    my $self = shift;
    my %args = @_;

    #determine if the query name and the dbmatch name are a unique pair in the document

    foreach my $alignment_pair ( @{$self->returnBsmlSeqPairAlignmentListR()} )
      {
	if( ( $alignment_pair->returnattr( 'refseq' ) eq "_$args{'query_name'}") && ($alignment_pair->returnattr( 'compseq' ) eq "_$args{'dbmatch_accession'}") )
	  {

	    #add a new BsmlSeqPairRun to the alignment pair and return
	    my $seq_run = $alignment_pair->returnBsmlSeqPairRunR( $alignment_pair->addBsmlSeqPairRun() );

	    if( $args{'start_query'} > $args{'stop_query'} )
	      {
		$seq_run->setattr( 'refpos', $args{'stop_query'} );
		$seq_run->setattr( 'runlength', $args{'start_query'} - $args{'stop_query'} + 1 );
		$seq_run->setattr( 'refcomplement', 1 );
	      }
	    else
	      {
		$seq_run->setattr( 'refpos', $args{'start_query'} );
		$seq_run->setattr( 'runlength', $args{'stop_query'} - $args{'start_query'} + 1 );
		$seq_run->setattr( 'refcomplement', 0 );
	      }

	    #the database sequence is always 5' to 3'

	    $seq_run->setattr( 'comppos', $args{'start_hit'} );
	    $seq_run->setattr( 'comprunlength', $args{'stop_hit'} - $args{'start_hit'} + 1 );
	    $seq_run->setattr( 'compcomplement', 0 );

	    $seq_run->setattr( 'runscore', $args{'bit_score'} );
	    $seq_run->setattr( 'runprob', $args{'e_value'} );

	    $seq_run->addBsmlAttr( 'percent_identity', $args{'percent_identity'} );
	    $seq_run->addBsmlAttr( 'percent_similarity', $args{'percent_similarity'} );
	    $seq_run->addBsmlAttr( 'chain_number', $args{'chain_number'} );
	    $seq_run->addBsmlAttr( 'segment_number', $args{'segment_number'} );
	    $seq_run->addBsmlAttr( 'p_value', $args{'p_value'} );

	    return $alignment_pair;
	  }
      } 

    #no alignment pair matches, add a new alignment pair and sequence run

    #check to see if sequences exist in the BsmlDoc

    if( !( $self->returnBsmlSequenceByIDR( "_$args{'query_name'}")) ){
      $self->createAndAddSequence( "_$args{'query_name'}", "$args{'query_name'}", $args{'query_length'}, 'mol-not-set' );}

    if( !( $self->returnBsmlSequenceByIDR( "_$args{'dbmatch_accession'}")) ){
      $self->createAndAddSequence( "_$args{'dbmatch_accession'}", "$args{'dbmatch_accession'}", '', 'mol-not-set' );}

    my $alignment_pair = $self->returnBsmlSeqPairAlignmentR( $self->addBsmlSeqPairAlignment() );
    

    $alignment_pair->setattr( 'refseq', "_$args{'query_name'}" );
    $alignment_pair->setattr( 'compseq', "_$args{'dbmatch_accession'}" );

    $alignment_pair->setattr( 'refxref', ':'.$args{'query_name'});
    $alignment_pair->setattr( 'refstart', 0 );
    $alignment_pair->setattr( 'refend', $args{'query_length'} - 1 );
    $alignment_pair->setattr( 'reflength', $args{'query_length'} );

    $alignment_pair->setattr( 'method', $args{'blast_program'} );

    $alignment_pair->setattr( 'compxref', $args{'search_database'}.':'.$args{'dbmatch_accession'} );

    my $seq_run = $alignment_pair->returnBsmlSeqPairRunR( $alignment_pair->addBsmlSeqPairRun() );

    if( $args{'start_query'} > $args{'stop_query'} )
      {
	$seq_run->setattr( 'refpos', $args{'stop_query'} );
	$seq_run->setattr( 'runlength', $args{'start_query'} - $args{'stop_query'} + 1 );
	$seq_run->setattr( 'refcomplement', 1 );
      }
    else
      {
	$seq_run->setattr( 'refpos', $args{'start_query'} );
	$seq_run->setattr( 'runlength', $args{'stop_query'} - $args{'start_query'} + 1 );
	$seq_run->setattr( 'refcomplement', 0 );
      }

    #the database sequence is always 5' to 3'
    
    $seq_run->setattr( 'comppos', $args{'start_hit'} );
    $seq_run->setattr( 'comprunlength', ($args{'stop_hit'} - $args{'start_hit'} + 1));
    $seq_run->setattr( 'compcomplement', 0 );
    
    $seq_run->setattr( 'runscore', $args{'bit_score'} );
    $seq_run->setattr( 'runprob', $args{'e_value'} );

    $seq_run->addBsmlAttr( 'percent_identity', $args{'percent_identity'} );
    $seq_run->addBsmlAttr( 'percent_similarity', $args{'percent_similarity'} );
    $seq_run->addBsmlAttr( 'chain_number', $args{'chain_number'} );
    $seq_run->addBsmlAttr( 'segment_number', $args{'segment_number'} );
    $seq_run->addBsmlAttr( 'p_value', $args{'p_value'} );

    return $alignment_pair;
  }

1
