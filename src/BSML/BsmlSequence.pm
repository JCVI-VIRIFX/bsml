package BSML::BsmlSequence;
@ISA = qw( BSML::BsmlElement );


=head1 NAME

  BsmlSequence.pm - Bsml API Object representing the Bsml Sequence Element 

=head1 VERSION
  
  This document refers to version 1.0 of the BSML Object Layer

=head1 Description

=head2 Overview

  The BsmlSequence class allows sequence data <Seq-dat> and feature tables to be added and manipulated.

=head2 Constructor and initialization

  Typically a BsmlSequence is created by the BsmlDoc object it is contained within and manipulated
  as a reference.

  my $doc = new BsmlDoc;
  my $seq = $doc->returnBsmlSequenceR( $doc->addBsmlSequence() );

=head2 Class and object methods

=over 4

=cut

BEGIN {
    require '/usr/local/devel/ANNOTATION/cas/lib/site_perl/5.8.5/BSML/BsmlCrossReference.pm';
    import BSML::BsmlCrossReference;
    require '/usr/local/devel/ANNOTATION/cas/lib/site_perl/5.8.5/BSML/BsmlNumbering.pm';
    import BSML::BsmlNumbering;
    require '/usr/local/devel/ANNOTATION/cas/lib/site_perl/5.8.5/BSML/BsmlElement.pm';
    import BSML::BsmlElement;
    require '/usr/local/devel/ANNOTATION/cas/lib/site_perl/5.8.5/BSML/BsmlFeatureGroup.pm';
    import BSML::BsmlFeatureGroup;
    require '/usr/local/devel/ANNOTATION/cas/lib/site_perl/5.8.5/BSML/BsmlFeatureTable.pm';
    import BSML::BsmlFeatureTable;
}
use XML::Writer;
use strict;
use warnings;
use Log::Log4perl qw(get_logger);
use Data::Dumper;

my $logger = get_logger("Logger::BSML");


# a bsml sequence stores raw sequence data and a list of feature tables

sub new
  {

      $logger->debug("") if $logger->is_debug;


    my $class = shift;
    my $self = {};
    bless $self, $class;
    
    $self->init();
    return $self;
  }

sub init
  {

      $logger->debug("") if $logger->is_debug;
    my $self = shift;

    $self->{ 'attr' } = {};
    $self->{ 'BsmlAttr' } = {};
    $self->{ 'BsmlFeatureTables' } = [];
    $self->{ 'BsmlFeatureGroups' } = [];
    $self->{ 'BsmlSeqData' } = undef;
    $self->{ 'BsmlSeqDataImport' } = {};
    $self->{ 'BsmlLink' } = [];
    $self->{ 'BsmlNumbering' } = undef;
    $self->{ 'BsmlCrossReference' } = [];
    $self->{ 'BsmlAttributeList' } = undef;
    
  }

=item $seq->addBsmlFeatureTable()

B<Description:> adds a feature table to the sequence object

B<Parameters:> None

B<Returns:> The index of the added feature table

=cut 

sub addBsmlFeatureTable
  {

      $logger->debug("") if $logger->is_debug;


    my $self = shift;
    push( @{$self->{'BsmlFeatureTables'}}, new BSML::BsmlFeatureTable );

    my $index = @{$self->{'BsmlFeatureTables'}} - 1;
    return $index;
  }

=item $seq->dropBsmlFeatureTable( $index )

B<Description:> deletes a feature table from the sequence object

B<Parameters:> The index of the feature table to be deleted

B<Returns:> None

=cut 

sub dropBsmlFeatureTable
  {

      $logger->debug("") if $logger->is_debug;

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

=item $seq->returnBsmlFeatureTableListR()

B<Description:> Return a list of references to all the feature table objects contained in the document.

B<Parameters:> None

B<Returns:> a list of BsmlFeatureTable object references

=cut 

sub returnBsmlFeatureTableListR
  {

      $logger->debug("") if $logger->is_debug;

    my $self = shift;

    return $self->{'BsmlFeatureTables'};
  }

=item $seq->returnBsmlFeatureTableR( $index )

B<Description:> Return a reference to a feature table object given its index

B<Parameters:> ($index) - the feature table index returned from addBsmlFeatureTable (position of the table in the reference list)

B<Returns:> a BsmlFeatureTable object reference

=cut

sub returnBsmlFeatureTableR
  {

      $logger->debug("") if $logger->is_debug;


    my $self = shift;
    my ($index) = @_;

    return $self->{'BsmlFeatureTables'}[$index];
  }

=item $seq->addBsmlSeqData( $seq_string )

B<Description:> add a sequence string <Seq_dat> to the object

B<Parameters:> ( $seq_string ) - string containing raw sequence data

B<Returns:> None

=cut

sub addBsmlSeqData
  {

      $logger->debug("") if $logger->is_debug;

    my $self = shift;

    ($self->{'BsmlSeqData'}) = @_; 
  }

=item $seq->setBsmlSeqData( $seq_string )

B<Description:> same as addBsmlSeqData - maintained to make methods consistent with the rest of the API

B<Parameters:> ( $seq_string ) - string containing raw sequence data

B<Returns:> None

=cut

sub setBsmlSeqData
  {

      $logger->debug("") if $logger->is_debug;

    my $self = shift;
    my ($seq) = @_;

    $self->addBsmlSeqData( $seq );
  }

=item $seq->dropBsmlSeqData()

B<Description:> delete the raw sequence <Seq-dat> from the sequence object

B<Parameters:> None

B<Returns:> None

=cut

sub dropBsmlSeqData
  {
      $logger->debug("") if $logger->is_debug;

    my $self = shift;
   
    $self->{'BsmlSeqData'} = undef;
  }

=item $seq->returnSeqData

B<Description:> return a string containing the raw sequence from the sequence object

B<Parameters:> None

B<Returns:> a string containing raw sequence data

=cut

sub returnSeqData
  {
      $logger->debug("") if $logger->is_debug;

    my $self = shift;

    return $self->{'BsmlSeqData'};
  }

sub addBsmlSeqDataImport
  {
      $logger->debug("") if $logger->is_debug;

    my $self = shift;
    my ($format, $source, $id, $identifier) = @_;

    $self->{'BsmlSeqDataImport'}->{'format'} = $format;
    $self->{'BsmlSeqDataImport'}->{'source'} = $source;

    $self->{'BsmlSeqDataImport'}->{'identifier'} = $identifier;

    $self->{'BsmlSeqDataImport'}->{'id'} = $id;
  }

sub setBsmlSeqDataImport
  {
      $logger->debug("") if $logger->is_debug;

    my $self = shift;
    my ($format, $source, $id, $identifier) = @_;

    $self->addBsmlSeqDataImport( $format, $source, $id, $identifier );
  }

sub dropBsmlSeqDataImport
  {
      $logger->debug("") if $logger->is_debug;

    my $self = shift;
    $self->{'BsmlSeqDataImport'} = {};
  }

sub returnBsmlSeqDataImport
  {
      $logger->debug("") if $logger->is_debug;


    my $self = shift;
    return $self->{'BsmlSeqDataImport'};
  }

=item $seq->addBsmlFeatureGroup()

B<Description:> add a feature group to the sequence

B<Parameters:> None

B<Returns:> the index of the added feature group

=cut

sub addBsmlFeatureGroup
  {
      $logger->debug("") if $logger->is_debug;

    my $self = shift;

    push( @{$self->{'BsmlFeatureGroups'}}, new BSML::BsmlFeatureGroup );

    my $index = @{$self->{'BsmlFeatureGroups'}} - 1;

    #In order to retain the relationship of genes to the assembly on which they
    #are contained in a memory efficient manner consistent with the document level
    #lookups, the sequence id is embedded in each feature group. 

    $self->{'BsmlFeatureGroups'}->[$index]->{'ParentSequenceId'} = $self->returnattr( 'id' );

    return $index;

  }

=item $seq->dropBsmlFeatureGroup( $index )

B<Description:> drop a feature group from the sequence

B<Parameters:> $index - the index of the feature group to be deleted

B<Returns:> None

=cut

sub dropBsmlFeatureGroup
  {
      $logger->debug("") if $logger->is_debug;

    my $self = shift;
    my ($index) = @_;

    my @newlist;

    for( my $i=0; $i<length(@{$self->{'BsmlFeatureGroups'}}); $i++ )
      {
	if( $i != $index )
	  {
	    push( @newlist, $self->{'BsmlFeatureGroups'}[$i] );
	  }
      }

    $self->{'BsmlFeatureGroups'} = \@newlist;    
  }

=item $seq->returnBsmlFeatureGroupListR()

B<Desciption:> returns the list of feature group references associated with the sequence

B<Parameters:> None

B<Returns:> a list of feature group references

=cut

sub returnBsmlFeatureGroupListR
  {
      $logger->debug("") if $logger->is_debug;
      
      my $self = shift;
      return $self->{'BsmlFeatureGroups'};
  }

=item $seq->returnFeatureGroupR( $index )

B<Description:> returns the feature group reference of index $index

B<Parameters:> $index - the index of the feature group to be returned

B<Returns:> a reference to a feature group

=cut

sub returnBsmlFeatureGroupR
  {
      $logger->debug("") if $logger->is_debug;

    my $self = shift;

    my ($index) = @_;
    return $self->{'BsmlFeatureGroups'}[$index];
  } 


=item $seq->write()

  B<Description:> writes the BSML elements encoded by the class to a file using XML::Writer. This method should only be called through the BsmlDoc->write() process.

  B<Parameters:> None

  B<Returns:> None

=cut 

sub addBsmlNumbering
{
      $logger->debug("") if $logger->is_debug;

    my $self = shift;
    $self->{'BsmlNumbering'} = new BSML::BsmlNumbering;

    return $self->{'BsmlNumbering'};
}

sub returnBsmlNumberingR
{
      $logger->debug("") if $logger->is_debug;

    my $self = shift;
    return $self->{'BsmlNumbering'};
}

sub dropBsmlNumbering
{
      $logger->debug("") if $logger->is_debug;

    my $self = shift;
    $self->{'BsmlNumbering'} = undef;
}


#
# Added 2004-11-02 Bugzilla case 1808
#


# sub addBsmlAttributeList {

#     my $self = shift;
#     push ( @{$self->{'BsmlAttributeList'}}, new BSML::BsmlAttributeList );
    
#     my $index = @{$self->{'BsmlAttributeList'}} - 1;
#     return $index;
# }

# sub dropBsmlAttributeList {

#     my $self = shift;
#     my ($index) = @_;

#     my $newlist = [];

#     for(  my $i=0;  $i< @{$self->{'BsmlAttributeList'}}; $i++ ) {
# 	if( $i != $index ){
# 	    push( @{$newlist}, $self->{'BsmlAttributeList'}[$i] );
# 	}
#     }

#     $self->{'BsmlAttributeList'} = $newlist;
# }

# sub returnBsmlAttributeListListR {

#     my $self = shift;
#     return $self->{'BsmlAttributeList'};

# }

# sub returnBsmlAttributeListR {

#     my $self = shift;
#     my ($index) = @_;

#     return $self->{'BsmlAttributeList'}[$index];
# }



sub write  {

      $logger->debug("") if $logger->is_debug;


    my $self = shift;
    my $writer = shift;
    
    $writer->startTag( "Sequence", %{$self->{'attr'}} );
    
    foreach my $bsmlattr (keys( %{$self->{ 'BsmlAttr'}})){

	$writer->startTag( "Attribute", 'name' => $bsmlattr, 'content' => $self->{'BsmlAttr'}->{$bsmlattr} );
	$writer->endTag( "Attribute" );
    }

    if( my $tcount = @{$self->{'BsmlFeatureTables'}} > 0 ) {

	$writer->startTag( "Feature-tables" );

	foreach my $tbl ( @{$self->{'BsmlFeatureTables'}} ) {

	    $tbl->write( $writer );
	}
	
	if( my $gcount = @{$self->{'BsmlFeatureGroups'}} > 0 )  {
	    
	    foreach my $grp ( @{$self->{'BsmlFeatureGroups'}} ){
		$grp->write( $writer );
	    }
	}
	    
	$writer->endTag( "Feature-tables" );
    }

    # either imbedded or linked sequence data is expected, not both
    
    if( $self->{'BsmlSeqData'} )  {
	$writer->startTag( "Seq-data" );
	$writer->characters( $self->{'BsmlSeqData'} );
	$writer->endTag( "Seq-data" );
    }
    else {
	
	if( $self->{'BsmlSeqDataImport'}->{'source'} ) {
	    $writer->startTag( 'Seq-data-import', %{$self->{'BsmlSeqDataImport'}} );
	    $writer->endTag( 'Seq-data-import' );
	}
    }

    if( $self->{'BsmlNumbering'} ) {

	$self->{'BsmlNumbering'}->write( $writer );
    }

    foreach my $xref (@{$self->{'BsmlCrossReference'}}){
	$xref->write( $writer );
    }
    
      foreach my $link (@{$self->{'BsmlLink'}})  {
	  $writer->startTag( "Link", %{$link} );
	  $writer->endTag( "Link" );
      }

      foreach my $listref (@{$self->{'BsmlAttributeList'}}){
	  $writer->startTag( "Attribute-list");
	    foreach my $hash ( sort {$a->{'name'} cmp $b->{'name'}} @{$listref} ){ 
		    $writer->startTag( "Attribute",  'name' => $hash->{'name'}, 'content' => $hash->{'content'} );
		    $writer->endTag( "Attribute" );
		}
	   $writer->endTag( "Attribute-list" );
      }
    
    $writer->endTag( "Sequence" );
    
}



sub detectBsmlFeatureTables {
    
    $logger->debug("") if $logger->is_debug;
    
    my $self = shift;

    if (scalar(@{$self->{'BsmlFeatureTables'}}) > 1 )  {
	return 1;
    }
    else {
	return 0;
    }

}



1

