package BSML::BsmlReader;
@ISA = qw( BSML::BsmlDoc );

use strict;
use warnings;
use BSML::BsmlDoc;
use Data::Dumper;

sub readSequence
  {
    my $self = shift;
    my ($seq) = @_;

    #input for $seq is either a reference to a Bsml Sequence object
    #or a valid sequence identifier

    if( !($seq) )
      {
	print "Error: Sequence not defined\n";
	return;
      }
    else
      {
	#if a sequence reference has not been passed in, get the sequence
	#with the sequence identifier provided.
	
	if( !(ref($seq) eq 'BSML::BsmlSequence' ))
	  {
	    #pull the Bsml Object with identifier $seq from the document lookup table
	    #and verify that it is a sequence object

	    $seq = BSML::BsmlDoc::BsmlReturnDocumentLookup( $seq );
	    if( !(ref($seq) eq 'BSML::BsmlSequence')){ return undef; }
	  }
      }

    my $returnhash = {};
    
    $returnhash->{ 'id' } = $seq->returnattr( 'id' );
    $returnhash->{ 'title'} = $seq->returnattr( 'title' );
    $returnhash->{ 'molecule'} = $seq->returnattr( 'molecule' );
    $returnhash->{ 'length' } = $seq->returnattr( 'length' );
    $returnhash->{ 'locus' } = $seq->returnattr( 'locus' );
    $returnhash->{ 'dbsource' } = $seq->returnattr( 'dbsource' );
    $returnhash->{ 'icAcckey' } = $seq->returnattr( 'icAcckey' );
    $returnhash->{ 'topology' } = $seq->returnattr( 'topology' );
    $returnhash->{ 'strand' } = $seq->returnattr( 'strand' );
    
    return $returnhash;
}

sub returnAllSequences
  {
    my $self = shift;

    return $self->returnBsmlSequenceListR();
  }

sub readSequenceDat
  {
    my $self = shift;
    my ($seq) = @_;

    if( ref($seq) eq 'BSML::BsmlSequence' ){
      return $seq->returnSeqData();}
  }

sub readSequenceDatImport
  {
    my $self = shift;
    my ($seq) = @_;

    if( ref($seq) eq 'BSML::BsmlSequence' ){
      return $seq->returnBsmlSeqDataImport();}
  }

sub readFeatures
  {
    my $self = shift;
    my ($input) = @_;

    my $feat_list = [];

    if( ref($input) eq 'BSML::BsmlSequence' )
      {
	#loop over all feature tables
	#add a feature record to return for each feature 

	foreach my $FTable (@{$input->returnBsmlFeatureTableListR()})
	  {
	    foreach my $Feature (@{$FTable->returnBsmlFeatureListR()})
	      {
		my $record = {};
		$record->{'FTable'} = $FTable->returnattr( 'id' );
		$record->{'id'} = $Feature->returnattr( 'id' );
		$record->{'title'} = $Feature->returnattr( 'title' );
		$record->{'class'} = $Feature->returnattr( 'class' );
		$record->{'comment'} = $Feature->returnattr( 'comment' );
		$record->{'display-auto'} = $Feature->returnattr( 'display-auto' );

		my $locations = [];

		foreach my $interval_loc (@{$Feature->returnBsmlIntervalLocListR()})
		  {
		    push( @{$locations}, {startpos => $interval_loc->{'startpos'},
					  endpos => $interval_loc->{'endpos'}} );
		  }

		foreach my $site_loc (@{$Feature->returnBsmlSiteLocListR()})
		  {
		    push( @{$locations}, {startpos => $site_loc->{'sitepos'},
					  endpos => $site_loc->{'sitepos'}} );
		  }

		$record->{'locations'} = $locations;

		my $qualifiers = [];

		my $qualhash = $Feature->returnBsmlQualifierHashR();

		foreach my $qual (keys(%{$qualhash}))
		  {
		    push( @{$qualifiers}, { key => $qual, value => $qualhash->{$qual} } );
		  }

		$record->{'qualifiers'} = $qualifiers;

		my $bsmlattr = [];
		my $bsmlhash = $Feature->returnBsmlAttrHashR();

		foreach my $qual (keys(%{$bsmlhash}))
		  {
		    push( @{$bsmlattr}, { key => $qual, value => $bsmlhash->{$qual} } );
		  }
		
		$record->{'bsmlattrs'} = $bsmlattr;

		push( @{$feat_list}, $record );
	      }
	  }
	return $feat_list;
      }
    
    if( ref($input) eq 'BSML::BsmlFeatureTable' )
      {
	 foreach my $Feature (@{$input->returnBsmlFeatureListR()})
	      {
		my $record = {};
		$record->{'FTable'} = $input->returnattr( 'id' );
		$record->{'id'} = $Feature->returnattr( 'id' );
		$record->{'title'} = $Feature->returnattr( 'title' );
		$record->{'class'} = $Feature->returnattr( 'class' );
		$record->{'comment'} = $Feature->returnattr( 'comment' );
		$record->{'display-auto'} = $Feature->returnattr( 'display-auto' );

		my $locations = [];

		foreach my $interval_loc (@{$Feature->returnBsmlIntervalLocListR()})
		  {
		    push( @{$locations}, {startpos => $interval_loc->{'startpos'},
					  endpos => $interval_loc->{'endpos'}} );
		  }

		foreach my $site_loc (@{$Feature->returnBsmlSiteLocListR()})
		  {
		    push( @{$locations}, {startpos => $site_loc->{'sitepos'},
					  endpos => $site_loc->{'sitepos'}} );
		  }

		$record->{'locations'} = $locations;

		my $qualifiers = [];

		my $qualhash = $Feature->returnBsmlQualifierHashR();

		foreach my $qual (keys(%{$qualhash}))
		  {
		    push( @{$qualifiers}, { key => $qual, value => $qualhash->{$qual} } );
		  }

		$record->{'qualifiers'} = $qualifiers;

		my $bsmlattr = [];
		my $bsmlhash = $Feature->returnBsmlAttrHashR();

		foreach my $qual (keys(%{$bsmlhash}))
		  {
		    push( @{$bsmlattr}, { key => $qual, value => $bsmlhash->{$qual} } );
		  }
		
		$record->{'bsmlattrs'} = $bsmlattr;
		
		push( @{$feat_list}, $record );
	      }
	 return $feat_list;
       }
    
    if( ref($input) eq 'BSML::BsmlFeature' )
      {
		my $record = {};
		my $Feature = $input;

		$record->{'FTable'} = '';
		$record->{'id'} = $Feature->returnattr( 'id' );
		$record->{'title'} = $Feature->returnattr( 'title' );
		$record->{'class'} = $Feature->returnattr( 'class' );
		$record->{'comment'} = $Feature->returnattr( 'comment' );
		$record->{'display-auto'} = $Feature->returnattr( 'display-auto' );

		my $locations = [];

		foreach my $interval_loc (@{$Feature->returnBsmlIntervalLocListR()})
		  {
		    push( @{$locations}, {startpos => $interval_loc->{'startpos'},
					  endpos => $interval_loc->{'endpos'}} );
		  }

		foreach my $site_loc (@{$Feature->returnBsmlSiteLocListR()})
		  {
		    push( @{$locations}, {startpos => $site_loc->{'sitepos'},
					  endpos => $site_loc->{'sitepos'}} );
		  }

		$record->{'locations'} = $locations;

		my $qualifiers = [];

		my $qualhash = $Feature->returnBsmlQualifierHashR();

		foreach my $qual (keys(%{$qualhash}))
		  {
		    push( @{$qualifiers}, { key => $qual, value => $qualhash->{$qual} } );
		  }

		$record->{'qualifiers'} = $qualifiers;

		my $bsmlattr = [];
		my $bsmlhash = $Feature->returnBsmlAttrHashR();

		foreach my $qual (keys(%{$bsmlhash}))
		  {
		    push( @{$bsmlattr}, { key => $qual, value => $bsmlhash->{$qual} } );
		  }
		
		$record->{'bsmlattrs'} = $bsmlattr;
		
		push( @{$feat_list}, $record );
		return $feat_list;
	      }
    
   
  }

sub readReferences
  {
    my $self = shift;
    my ($input) = @_;

    my $reflist = [];

    if( ref($input) eq 'BSML::BsmlSequence' )
      {
	foreach my $FTable ( @{$self->returnBsmlFeatureTableListR()} )
	  {
	    foreach my $rref ( @{$self->returnBsmlReferenceListR()} )
	      {
		my $rhash = {};
		$rhash->{'FTable'} = '';
		$rhash->{'refID'} = $rref->returnattr( 'id' );
		$rhash->{'refAuthors'} = $rref->returnBsmlRefAuthors();
		$rhash->{'refTitle'} = $rref->returnBsmlRefTitle();
		$rhash->{'refJournal'} = $rref->returnBsmlRefJournal();
		$rhash->{'dbxref'} = $rref->returnattr( 'dbxref' );

		my $bsmlattr = [];
		my $bsmlhash = $rref->returnBsmlAttrHashR();
	
		foreach my $qual (keys(%{$bsmlhash}))
		  {
		    push( @{$bsmlattr}, { key => $qual, value => $bsmlhash->{$qual} } );
		  }
	
		$rhash->{'bsmlattrs'} = $bsmlattr;	
		push( @{$reflist}, $rhash );
	      }
	  }
      }
    
    if( ref($input) eq 'BSML::BsmlFeatureTable' )
      {
	foreach my $rref ( @{$self->returnBsmlReferenceListR()} )
	  {
	    my $rhash = {};
	    $rhash->{'FTable'} = '';
	    $rhash->{'refID'} = $rref->returnattr( 'id' );
	    $rhash->{'refAuthors'} = $rref->returnBsmlRefAuthors();
	    $rhash->{'refTitle'} = $rref->returnBsmlRefTitle();
	    $rhash->{'refJournal'} = $rref->returnBsmlRefJournal();
	    $rhash->{'dbxref'} = $rref->returnattr( 'dbxref' );

	    my $bsmlattr = [];
	    my $bsmlhash = $rref->returnBsmlAttrHashR();
	
	    foreach my $qual (keys(%{$bsmlhash}))
	      {
		push( @{$bsmlattr}, { key => $qual, value => $bsmlhash->{$qual} } );
	      }
	
	    $rhash->{'bsmlattrs'} = $bsmlattr;	
	    push( @{$reflist}, $rhash );
	  }

	return $reflist;
      }

    if( ref($input) eq 'BSML::BsmlReference' )
      {
	my $rhash = {};
	$rhash->{'FTable'} = '';
	$rhash->{'refID'} = $self->returnattr( 'id' );
	$rhash->{'refAuthors'} = $self->returnBsmlRefAuthors();
	$rhash->{'refTitle'} = $self->returnBsmlRefTitle();
	$rhash->{'refJournal'} = $self->returnBsmlRefJournal();
	$rhash->{'dbxref'} = $self->returnattr( 'dbxref' );

	my $bsmlattr = [];
	my $bsmlhash = $self->returnBsmlAttrHashR();
	
	foreach my $qual (keys(%{$bsmlhash}))
	  {
	    push( @{$bsmlattr}, { key => $qual, value => $bsmlhash->{$qual} } );
	  }
	
	$rhash->{'bsmlattrs'} = $bsmlattr;	
	push( @{$reflist}, $rhash );

	return $reflist;
      }
  }

sub readBsmlAttributes
  {
    my $self = shift;
    my ($elem) = @_;

    my $bsmlattr = [];

    #it would be nice to check if $elem is a valid Bsml Object.
    #can SUPER be used???

    if( $elem )
      {
	my $bsmlhash = $elem->returnBsmlAttrHashR();

	foreach my $qual (keys(%{$bsmlhash}))
	  {
	    push( @{$bsmlattr}, { key => $qual, value => $bsmlhash->{$qual} } );
	  }
		
	return $bsmlattr;
      }
  }

sub returnAllFeatureTables
  {
    my $self = shift;
    my ($input) = @_;

    if( ref($input) eq 'BSML::BsmlSequence' )
      {
	return $input->returnBsmlFeatureTableListR();
      }
   
    if( ref($input) eq 'BSML::BsmlReader' )
      {
	my $list = [];

	foreach my $seq ( @{$self->returnBsmlSequenceListR()} )
	  {
	    push( @{$list}, @{$seq->returnBsmlFeatureTableListR()} );
	  }

	return $list;
      }
  }

sub returnAllSeqPairAlignmentsListR
  {
    my $self = shift;
    return $self->returnBsmlSeqPairAlignmentListR();
  }

# return a structured hash containing the data associated with an alignment pair and all of its seq pair runs.

sub readSeqPairAlignment
  {
    my $self = shift;
    my ($SeqPairAln) = @_;
    my $rhash = {};

    if( ref($SeqPairAln) eq 'BSML::BsmlSeqPairAlignment' )
      {
	  # Bsml Identifiers are not set for SeqPairAlignments so a "raw" reference to the SeqPairAlignment Object is returned 
	  $rhash->{'bsmlRef'} = $SeqPairAln;  

	  $rhash->{'refseq'} = $SeqPairAln->returnattr('refseq');
	  $rhash->{'compseq'} = $SeqPairAln->returnattr('compseq');
	  $rhash->{'refxref'} = $SeqPairAln->returnattr('refxref');
	  $rhash->{'refstart'} = $SeqPairAln->returnattr('refstart');
	  $rhash->{'refend'} = $SeqPairAln->returnattr('refend');
	  $rhash->{'reflength'} = $SeqPairAln->returnattr('reflength');
	  $rhash->{'method'} = $SeqPairAln->returnattr('method');
	  $rhash->{'compxref'} = $SeqPairAln->returnattr('compxref');
	  $rhash->{'seqPairRuns'} = [];

	  foreach my $SeqPairRun ( @{$SeqPairAln->returnBsmlSeqPairRunListR()} )
	  {
	      my $runDat = {};

	      # Bsml Identifiers are not set for SeqPairRuns so a "raw" reference to the SeqPairRun Object must be 
	      # placed in the return structure.
	      $runDat->{'bsmlRef'} = $SeqPairRun;
                      
	      # package the SeqPairRun data
	      $runDat->{'refpos'} = $SeqPairRun->returnattr( 'refpos' );
	      $runDat->{'runlength'} = $SeqPairRun->returnattr( 'runlength' );
	      $runDat->{'refcomplement'} = $SeqPairRun->returnattr( 'refcomplement' );
	      $runDat->{'comppos'} = $SeqPairRun->returnattr( 'comppos' );
	      $runDat->{'comprunlength'} = $SeqPairRun->returnattr( 'comprunlength' );
	      $runDat->{'compcomplement'} = $SeqPairRun->returnattr( 'compcomplement' );
	      $runDat->{'runscore'} = $SeqPairRun->returnattr( 'runscore' );
	      $runDat->{'runprob'} = $SeqPairRun->returnattr( 'runprob' );

	      # add client defined Bsml Attributes to the return structure

	      my $bsmlAttributeHashR = $SeqPairRun->returnBsmlAttrHashR();

	      foreach my $qual (keys(%{$bsmlAttributeHashR}))
	      {
		  $runDat->{$qual} = $bsmlAttributeHashR->{$qual};
	      }

	      push( @{$rhash->{'seqPairRuns'}}, $runDat );     
	  }
    
	return $rhash;
      }
  }

sub readLinks
  {
    my $self = shift;
    my ($elem) = @_;

    #it would be good to check if $elem pointed to a valid Bsml Object.
    #Can I use SUPER to do this???

    if( $elem )
      {
	return $elem->returnBsmlLinkListR();
      }
  }

sub readFeatureGroup
  {
    my $self = shift;
    my ($FeatureGroup) = @_;

    if( ref( $FeatureGroup ) eq 'BSML::BsmlFeatureGroup' )
      {
	my $returnhash = {};
	
	$returnhash->{'id'} = $FeatureGroup->returnattr( 'id' );
	$returnhash->{'group-set'} = $FeatureGroup->returnattr( 'group-set' );
	$returnhash->{'cdata'} = $FeatureGroup->returnText();
	$returnhash->{'feature-members'} = [];
	$returnhash->{'links'} = [];

	foreach my $featmemb (@{$FeatureGroup->returnFeatureGroupMemberListR()})
	  {
	    push( @{$returnhash->{'feature-members'}}, { 'featref' => $featmemb->{'feature'},
							 'feature-type' => $featmemb->{'feature-type'},
							 'group-type' => $featmemb->{'group-type'},
							 'cdata' => $featmemb->{'text'}
						       });
	  }

	foreach my $featlink (@{$FeatureGroup->returnBsmlLinkListR()})
	{
	    push( @{$returnhash->{'links'}}, { 'rel' => $featlink->{'rel'},
					       'href' => $featlink->{'href'} });
	}

	return $returnhash;
      }
  }

sub returnAllAnalysis
{
    my $self = shift;
    return $self->returnBsmlAnalysisListR();
}

sub readAnalysis
{
    my $self = shift;

    my ($analysis) = @_;

    if( ref($analysis) eq 'BSML::BsmlAnalysis' )
    {
	my $rhash = {};

	$rhash->{'algorithm'} = $analysis->returnBsmlAttr('algorithm');
	$rhash->{'description'} = $analysis->returnBsmlAttr('description');
	$rhash->{'name'} = $analysis->returnBsmlAttr('name');
	$rhash->{'program'} = $analysis->returnBsmlAttr('program');
	$rhash->{'programversion'} = $analysis->returnBsmlAttr('programversion');
	$rhash->{'sourcename'} = $analysis->returnBsmlAttr('sourcename');
	$rhash->{'sourceuri'} = $analysis->returnBsmlAttr('sourceuri');
	$rhash->{'sourceversion'} = $analysis->returnBsmlAttr('sourceversion');
	$rhash->{'queryfeature_id'} = $analysis->returnBsmlAttr('queryfeature_id');
	$rhash->{'timeexecuted'} = $analysis->returnBsmlAttr('timeexecuted');

	my $link = $analysis->returnBsmlLinkR( 0 );
	$rhash->{'bsml_link_relation'} = $link->{'rel'};
	$rhash->{'bsml_link_url'} = $link->{'href'};
	
	return $rhash;
    }
}



############################################################

# The following set of functions were implemented as helper routines
# for the scripts generating workflows from Bsml documents. 

# Returns the keys in the Feature Group lookup table. By convention.
# These keys are set to be the gene identifiers whose transcripts are
# represented as feature groups. See the Bsml Gene model for further
# information.

sub returnAllFeatureGroupSetIds
  {
    my $self = shift;

    #this returns a list of strings, probably should be made to return a reference
    #to a list for consistency.

    return BSML::BsmlDoc::BsmlReturnFeatureGroupLookupIds();
  }

# This uses the convention of our Bsml gene encoding. Each gene is represented
# as a set of feature groups. Where each feature group is a unique transcriptional
# form. Returning all the identifiers to the feature group lookups retrieves all
# the gene ids in the document. 

sub returnAllGeneIDs
  {
    my $self = shift;

    #this returns a list of strings, probably should be made to return a reference
    #to a list for consistency.
    
    return $self->returnAllFeatureGroupSetIds();
  }

# Returns a hash structure containing clusters of identifiers. 
#
# {$seqId}
#   {$geneId}
#     {$transcriptId}
#       {'exonIds'} -> [$exonId1, $exonId2, etc]
#       {'cdsId'} -> $cdsId
#       {'featureGroupId'} -> $featureGroupId
#       {'proteinId'} -> $proteinId
#
# input filters can be applied to limit return records
# seqId, geneId, transcriptId, exonId, cdsId, proteinId
#
#

sub returnAllIdentifiers
{
    my $self = shift;
    my %args = @_;

    my $rhash = {};

    # loop over all feature group sets (gene ids)
    GENE: foreach my $geneId ( $self->returnAllFeatureGroupSetIds() )
    {
	next GENE if( $args{'geneId'} && !($args{'geneId'} eq $geneId) ); 

	# loop over each feature group in the set
	TRANSCRIPT: foreach my $fgroup ( @{BSML::BsmlDoc::BsmlReturnFeatureGroupLookup($geneId)} )
	{
	    #get the parent sequence (assembly)
	    my $seqId = $fgroup->returnParentSequenceId();
	    next GENE if( $args{'seqId'} && !($args{'seqId'} eq $seqId));

	    my $groupDat = $self->readFeatureGroup( $fgroup );

	    my $transcriptId = '';
	    my $exonIds = [];
	    my $cdsId = '';
	    my $featureGroupId = $groupDat->{'id'};
	    my $proteinId = '';

	    foreach my $featmember (@{$groupDat->{'feature-members'}})
	    {
		if( $featmember->{'feature-type'} eq 'CDS' )
		{
		    # retreive the CDS id and the Protein id
		    $cdsId = $featmember->{'featref'};
		    next TRANSCRIPT if( $args{'cdsId'} && !($args{'cdsId'} eq $cdsId));
		    
		    # protein id is stored in the SEQ link of the CDS object
		    # get the CDS object from the lookups and retrieve its links

		    my $cdsObj = BSML::BsmlDoc::BsmlReturnDocumentLookup( $cdsId );

		    foreach my $link (@{$self->readLinks($cdsObj)})
		    {

			# a link of type 'SEQ' links to the protein sequence object

			if( $link->{'rel'} eq 'SEQ' )
			{
			    $proteinId = $link->{'href'};
			    $proteinId =~ s/#//;

			    next TRANSCRIPT if( $args{'proteinId'} && !($args{'proteinId'} eq $proteinId));
			}
		    }

		}

		if( $featmember->{'feature-type'} eq 'TRANSCRIPT' )
		{
		    $transcriptId = $featmember->{'featref'};

		    next TRANSCRIPT if( $args{'transcriptId'} && !($args{'transcriptId'} eq $transcriptId));
		}

		if( $featmember->{'feature-type'} eq 'EXON' )
		{
		    push( @{$exonIds}, $featmember->{'featref'} );
		}
	    }

	    if( $args{'exonId'} )
	    {
		my $searchFlag = 0;
		
		foreach my $exId (@{$exonIds})
		{
		    if( $exId eq $args{'exonId'} )
		    {
			$searchFlag = 1;
		    }
		}
		
		next TRANSCRIPT if( $searchFlag == 0 );
	    }



	    $rhash->{$seqId}->{$geneId}->{$transcriptId}->{'exonIds'} = $exonIds;
	    $rhash->{$seqId}->{$geneId}->{$transcriptId}->{'cdsId'} = $cdsId;
	    $rhash->{$seqId}->{$geneId}->{$transcriptId}->{'featureGroupId'} = $featureGroupId;
	    $rhash->{$seqId}->{$geneId}->{$transcriptId}->{'proteinId'} = $proteinId;
	}
    }

    return $rhash;
}

#Return the assembly id (eg 'PNEUMO_19') from which a sequence is contained or derived.
#Use the sequences id as input.

sub seqIdtoAssemblyId
  {
    my $self = shift;
    my ($sequenceId) = @_;

    #grab a reference to a sequence object from the lookup tables

    my $seq = BSML::BsmlDoc::BsmlReturnDocumentLookup( $sequenceId );

    #check to verify that a reference to a sequence object was returned

    if( ref($seq) eq 'BSML::BsmlSequence' )
      {
	  #return the Bsml ASSEMBLY Attribute
	  #Note, this is a custom attribute and is TIGR specific based on our
	  #gene proposal document. 
	  
	  return $seq->returnBsmlAttr( 'ASSEMBLY' );
      }
  }

# Returns a reference to a list of sequence objects given an assembly id.
# For Gene Model Bsml documents this will return references to the assembly's 
# genomic sequence and associated amino acid sequences.
#
# Pairwise alignment documents do not set this attribute and will return an
# empty list.

sub assemblyIdtoSeqList
  {
    my $self = shift;
    my ($assemblyId) = @_;

    my $rlist = [];

    # loop through all the sequence objects referenced in the document

    foreach my $seq ( @{$self->returnAllSequences()} )
      {

	  # Check if the sequence object has a BSML Attribute element with name ASSEMBLY and
	  # value equal to the input assembly id

	if( $seq->returnBsmlAttr( 'ASSEMBLY' ) eq $assemblyId )
	  {
	    push( @{$rlist}, $seq );
	  }
      }

    return $rlist;
  }

# returns a list of gene identifiers given an assembly id

sub assemblyIdtoGeneList
  {
    my $self = shift;
    my ($assemblyId) = @_;

    my $rlist = [];

    foreach my $geneId ($self->returnAllGeneIDs() )
      {
	# This loops through all the featuregroup set ids (genes) in the document and 
	# checks to see if the gene is on the assembly of interest

	if( $self->geneIdtoAssemblyId($geneId) eq $assemblyId )
	  {
	    push( @{$rlist}, $geneId );
	  }
      }

    return $rlist;
  }


# Returns all the alignments associated with a query sequence and optional match seq.
# If a matching sequence is not provided, all the matching sequences to the query will
# be returned. The output of this function is a reference to a list of Bsml alignment
# objects. 

sub fetch_all_alignmentPairs
  {
    my $self = shift;
    my ($querySeqId, $matchSeqId ) = @_;

    my $alignments = [];

    if( $matchSeqId )
      {
	  #pushes a reference to an alignment object onto the return list using the lookup tables

	  push( @{$alignments}, BSML::BsmlDoc::BsmlReturnAlignmentLookup( $querySeqId, $matchSeqId ));
      }
    else
      {
	  # this returns a reference to an anonymous hash. The hash is keyed with match query ids
	  # which point to references to alignment objects. 

	my $href = BSML::BsmlDoc::BsmlReturnAlignmentLookup( $querySeqId );

	# push the alignment objects onto the return list.

	foreach my $key ( keys(%{$href}))
	  {
	    push( @{$alignments}, $href->{$key} )
	  }
      }
    return $alignments;
  }

# Returns an assembly id (parental sequence object) given a valid gene (feature group-set) identifier

sub geneIdtoAssemblyId
  {
    my $self = shift;
    my ($geneId) = @_;
    my $fgrouplist = BSML::BsmlDoc::BsmlReturnFeatureGroupLookup($geneId);

    # Genes are referenced by ID through the feature group lookup tables. 
    # A feature group stores a refernce to the parent sequence it belongs to.

    if($fgrouplist)
      {
	  # Return the parent sequence ID of the first feature group corresponding
	  # to the gene. Note all transcripts will reference the same parental 
	  # genomic sequence. 

	return $fgrouplist->[0]->returnParentSequenceId();
      }
    else
      {
	return '';
      }
  }

# return the protein sequence id associated with a CDS feature

sub cdsIdtoProteinSeqId
{
    my $self = shift;
    my ($cdsID) = @_;

    # get the CDS feature object with id - $cdsID

    my $feat = BSML::BsmlDoc::BsmlReturnDocumentLookup( $cdsID );

    if( !(ref($feat) eq 'BSML::BsmlFeature' ) )
    {
	print STDERR "BsmlReader::cdsIdtoProteinSeqId() - Error CDS Feature not found\n";
	return;
    }
		 
    # look for a sequence object link 

		  foreach my $link ( @{$feat->returnBsmlLinkListR()} )
		  {
		      if( $link->{'rel'} eq 'SEQ' )
		      {
			  
			  # hrefs are encoded using the convention #BsmlId, so the '#' needs to be stripped

			  my $seqref = $link->{'href'};
			  $seqref =~ s/#//;

			  # look up the sequence object and return its id

			  my $seq = BSML::BsmlDoc::BsmlReturnDocumentLookup($seqref);

			  if( ref($seq) eq 'BSML::BsmlSequence' )
			  {
			      return $seq->returnattr('id');
			  }
			  else
			  {
			      print STDERR "BsmlReader::cdsIdtoProteinSeqId() - Error Amino Acid Sequence not found.\n";
			  }
		      }
		  }
}

# Returns a list of amino acid sequences given a gene identifier. Each sequence
# represents a transcriptional varient of the query gene.

# Looks up the gene by id in the Feature Group Lookups returning a list of transcript
# groups. Examines the list of feature-group members for one referencing a CDS feature.
# By following the CDS feature's SEQ link the sequence object containing AA seqdata is
# obtained.

sub geneIdtoAASeqList
  {
    my $self = shift;
    my ($geneId) = @_;

    my @returnAASequenceList;

    my $fgrouplist = BSML::BsmlDoc::BsmlReturnFeatureGroupLookup($geneId);
    
    # This series of loops essentially retrieves the CDS feaature and its associated
    # amino acid sequence from a feature group representing a single transcript. Note
    # in Prok data - Gene=Transcript=CDS.

    foreach my $fgroup (@{$fgrouplist})
      {
	foreach my $fmember (@{$fgroup->returnFeatureGroupMemberListR()})
	  {
	    if( $fmember->{'feature-type'} eq 'CDS' )
	      {
		my $feat = BSML::BsmlDoc::BsmlReturnDocumentLookup( $fmember->{'feature'} );
		foreach my $link ( @{$feat->returnBsmlLinkListR()} )
		  {
		    if( $link->{'rel'} eq 'SEQ' )
		      {
			my $sref = $link->{'href'};
			$sref =~ s/#//;
			my $seq = BSML::BsmlDoc::BsmlReturnDocumentLookup( $sref );
			
			if( my $seqdat = $seq->returnSeqData() ){
			  push( @returnAASequenceList, $seqdat );}
			else
			  {
			      # handle sequence data import tags
			      # The current document implementations inline the AA sequences...
			  }
		      }
		  }
	      }
	  }
      }
     
    return \@returnAASequenceList;
  }

# Retrieves the CDS features within the feature groups associated with the input gene. Follows the 
# SEQ link in each of these features to obtain the amino acid sequence object. Returns a hash keyed
# by the Bsml ID of the sequence associated with its raw sequence data. 

sub geneIdtoAASeqHash
  {
    my $self = shift;
    my ($geneId) = @_;

    my $returnAASequenceHash = {};

    my $fgrouplist = BSML::BsmlDoc::BsmlReturnFeatureGroupLookup($geneId);
    
    # This series of loops essentially retrieves the CDS feaature and its associated
    # amino acid sequence from a feature group representing a single transcript. Note
    # in Prok data - Gene=Transcript=CDS.

    foreach my $fgroup (@{$fgrouplist})
      {
	foreach my $fmember (@{$fgroup->returnFeatureGroupMemberListR()})
	  {
	    if( $fmember->{'feature-type'} eq 'CDS' )
	      {
		my $feat = BSML::BsmlDoc::BsmlReturnDocumentLookup( $fmember->{'feature'} );
		foreach my $link ( @{$feat->returnBsmlLinkListR()} )
		  {
		    if( $link->{'rel'} eq 'SEQ' )
		      {
			my $sref = $link->{'href'};
			$sref =~ s/#//;
			my $seq = BSML::BsmlDoc::BsmlReturnDocumentLookup( $sref );
			

			if( ref($seq) eq 'BSML::BsmlSequence' )
			{
			    if( my $seqdat = $seq->returnSeqData() ){
				my $id = $seq->returnattr('id');
				$returnAASequenceHash->{$id} = $seqdat;
			    }
			    else
			    {
				# handle sequence data import tags
				# The current document implementations inline the AA sequences...
			    }
			}
			else
			{
			    print STDERR "BsmlReader::geneIdtoAASeqHash - Error amino acid sequence object ($sref) not found.\n";
			}
		      }
		  }
	      }
	  }
      }
     
    return $returnAASequenceHash;
  }

#Return all the protein identifiers associated with their assembly ids.

sub get_all_protein_assemblyId
{
    my $self = shift;

    # return all the sequence objects referenced in the document
    my $seqList = $self->returnAllSequences();

    # return structure is a reference to a hash with key value pairs
    # of protein id -> assembly id

    my $rhash = {};

    # loop through the sequence list, checking for sequences of type amino acid

    foreach my $seq (@{$seqList})
    {
	# when an aa sequence is found, add it and its assembly id to the return structure

	if( $seq->returnattr('molecule') eq 'aa' )
	{
	    $rhash->{$seq->returnattr('id')} = $seq->returnBsmlAttr('ASSEMBLY');
	}
    }
    
    return $rhash;
}

#return all the protein sequences associated with an assembly
#returns a hash reference where the keys are sequence ids and
#the values are the sequences. Note for data containing multiple
#transcripts the ids will be set as gene-name_index where index
#is incremented as sequences are encountered. Should BsmlFGroup ids
#be used to store transcript identifiers to replace this more or 
#less arbitrary indexing???

sub get_all_protein_aa
  {
    my $self = shift;
    my ($assembly_id) = @_;

    my $returnhash = {};

    foreach my $gene( $self->returnAllGeneIDs() )
      {
	if( $self->geneIdtoAssemblyId($gene) eq $assembly_id )
	  {
	    my $aahash = $self->geneIdtoAASeqHash($gene);
	    
	    foreach my $seqId (keys(%{$aahash}))
	      {
		  $returnhash->{$seqId} = $aahash->{$seqId};
	      }
	  }
      }

    return $returnhash;
  }


sub get_all_protein_aa2
  {
    my $self = shift;
    my ($assembly_id) = @_;

    my $returnhash = {};

    foreach my $seq (@{$self->returnAllSequences()})
      {
	  my $seq_hash = $reader->readSequence($seq);
          if($seq_hash->{'id'}  =~ /\.m\d+\_protein/){ ## if this molecule is a model
	      my $seq_data = $seq->returnSeqData($seq_hash->{'id'});
	      print "$seq_data\n";
              $returnhash{$seq_hash->{'id'}} = $seq_data;
      } 
    return $returnhash;
}



# Return the sequence data associated with all the CDS features on the input assembly.
# Data is returned in a hash structure keyed by CDS id. 

sub get_all_cds_dna
  {
    my $self = shift;
    my ($assembly_id) = @_;

    my $returnhash = {};

    my $seq = BSML::BsmlDoc::BsmlReturnDocumentLookup($assembly_id);
    if(!(ref($seq) eq 'BSML::BsmlSequence'))
    {
	print STDERR "BsmlReader::get_all_protein_dna - Warning assembly id ($assembly_id) was not found.\n";
    }

    foreach my $gene( $self->returnAllGeneIDs() )
      {
	  if( $self->geneIdtoAssemblyId($gene) eq $assembly_id )
	  {
	      my $dnahash = $self->geneCoordstoCDSHash($self->geneIdtoGenomicCoords($gene));
	      
	      foreach my $seqId (keys( %{$dnahash} ))
	      {
		  $returnhash->{$seqId} = $dnahash->{$seqId};
	      }
	  }
      }
    
    return $returnhash;
}

# Returns the sequence data associated with all the CDS features in the input assembly.
# Sequences are extended by 300 bp in each direction.

sub get_all_cds_dna_extended
  {
    #This function is only designed for Prok data... I'm not sure how it will apply to Euk

    my $self = shift;
    my ($assembly_id, $extension) = @_;

 
    my $seq = BSML::BsmlDoc::BsmlReturnDocumentLookup($assembly_id);
    if( ref($seq) eq 'BSML::BsmlSequence' )
    {
	my $topo = $seq->returnattr( 'topology' );

	#loads the full assembly
	my $seq_dat = $self->subSequence( $assembly_id, -1, 0, 0 );


	my $returnhash = {};
	
	foreach my $gene( $self->returnAllGeneIDs() )
	{
	    if( $self->geneIdtoAssemblyId($gene) eq $assembly_id )
	    {
		my $coords = $self->geneIdtoGenomicCoords($gene);
		
		my $start = $coords->[0]->{'GeneSpan'}->{'startpos'};
		my $end = $coords->[0]->{'GeneSpan'}->{'endpos'};
		
		my $dnahash = $self->geneCoordstoCDSHash( $coords );
		
		foreach my $seqId (keys(%{$dnahash}))
		{   
		    if( !($seq_dat) || !($topo) || !($start) || !($end) )
		    {
			print STDERR "BsmlReader::get_all_protein_dna_extended() - Error in call to extend_seq - Gene: $gene Topo: $topo Start: $start End: $end\n";
		    }
		    
		    # This function is not peforming approriately for data on the complementary strand

		    $returnhash->{$seqId} =  extend_seq300( $seq_dat, $topo, $start, $end );
		}
	    }
	}
	    
	return $returnhash;
    }
    else
    {
	print STDERR "BsmlReader::get_all_protein_dna_extended() - Error Invalid Sequence Id ($assembly_id) passed as assembly sequence\n";
    }
}
    
#return a list of hash references containing...
#  ParentSeqID, TranscriptID, GeneSpan, CDS_START, CDS_END, Exon_Boundaries

sub geneIdtoGenomicCoords
  {
    my $self = shift;
    my ($geneID) = @_;

    my $returnlist = [];

    #loops 
    foreach my $fgroup( @{BSML::BsmlDoc::BsmlReturnFeatureGroupLookup($geneID)} )
      {
	my $coordRecord = {};
	$coordRecord->{'ParentSeq'} = $fgroup->returnParentSequenceId();
	$coordRecord->{'GeneId'} = $geneID;

	foreach my $link ( @{$fgroup->returnBsmlLinkListR()} )
	  {
	    if( $link->{'rel'} eq 'GENE' )
	      {
	
		my $generef = $link->{'href'};
		$generef =~ s/#//;
		my $feat = BSML::BsmlDoc::BsmlReturnDocumentLookup($generef);

		if($feat)
		  {
		    my $intervals = $feat->returnBsmlIntervalLocListR();
		    $coordRecord->{'GeneSpan'} = { 'startpos' => $intervals->[0]->{'startpos'},
						   'endpos' => $intervals->[0]->{'endpos'},
						   'complement' => $intervals->[0]->{'complement'}};
		  }
	      }
	  }

	$coordRecord->{'TranscriptDat'} = {};
	my $group = {};
	$group->{'EXON_COORDS'} = [];

	foreach my $fmember (@{$fgroup->returnFeatureGroupMemberListR()})
	  {
	   
	    my $featureRef = $fmember->{'feature'};
	    my $featureType = $fmember->{'feature-type'};
	    my $featureGroup = $fmember->{'group-type'};

	    if( $featureType eq 'CDS' )
	      {
		my $feat = BSML::BsmlDoc::BsmlReturnDocumentLookup($featureRef);

		if($feat)
		  {
		      $group->{'CDS_ID'} = $feat->returnattr('id');

		      foreach my $site (@{$feat->returnBsmlSiteLocListR()})
		      {
			  if($site->{'class'} eq 'START' )
			  {
			      $group->{'CDS_START'} = {'sitepos' => $site->{'sitepos'}, 'complement' => $site->{'complement'}};
			  }
			  
			  if($site->{'class'} eq 'STOP' )
			  {
			      $group->{'CDS_STOP'} = {'sitepos' => $site->{'sitepos'}, 'complement' => $site->{'complement'}};
			  }
		      }
		      
		      
		  }
	    }

	    if( $featureType eq 'EXON' )
	      {
		  my $feat = BSML::BsmlDoc::BsmlReturnDocumentLookup($featureRef);

		  if($feat)
		  {
		      foreach my $interval (@{$feat->returnBsmlIntervalLocListR()})
		      {
			
			  my $href = { startpos => $interval->{'startpos'}, endpos => $interval->{'endpos'}, complement => $interval->{'complement'}, id => $feat->returnattr('id') };
			  push( @{$group->{'EXON_COORDS'}}, $href );
		      }
		  }
	      }

	    if( $featureType eq 'TRANSCRIPT' )
	      {
		  my $feat = BSML::BsmlDoc::BsmlReturnDocumentLookup($featureRef);

		  if($feat)
		  {
		      $group->{'TRANSCRIPT_ID'} = $feat->returnattr('id');

		      foreach my $site (@{$feat->returnBsmlSiteLocListR()})
		      {
			  if($site->{'class'} eq 'START' )
			  {
			      $group->{'TRANSCRIPT_START'} = {'sitepos' => $site->{'sitepos'}, 'complement' => $site->{'complement'}};
			  }
			  
			  if($site->{'class'} eq 'STOP' )
			  {
			      $group->{'TRANSCRIPT_STOP'} = {'sitepos' => $site->{'sitepos'}, 'complement' => $site->{'complement'}};
			  }
		      }
		  }
	      }
	    
	    $coordRecord->{'TranscriptDat'} = $group;
	  }
	push( @{$returnlist}, $coordRecord );
      }

    return $returnlist;
  }

sub geneCoordstoCDSList
  {
    my $self = shift;
    my ($coords) = @_;

    my $seqList = [];

    my $seqId = $coords->[0]->{'ParentSeq'};

    foreach my $transcript (@{$coords})
      {
	if( $transcript->{'TranscriptDat'}->{'EXON_COORDS'}->[0] )
	  {
	      #Euk data join the exon subsequences with care around the CDS start and end

	      # First check to see if the gene is on the complementary strand

	      if( $transcript->{'TranscriptDat'}->{'EXON_COORDS'}->[0]->{'complement'} eq '1' )
	      {
		  # The transcript is on the complementary strand

		  # This sorts coordinate data in descending order based on startpos. Since the transcript is on 
		  # the complementary strand, this puts the first exon in the first position.

		  my @sorted_lref = sort { $b->{'startpos'} <=> $a->{'startpos'} } @{$transcript->{'TranscriptDat'}->{'EXON_COORDS'}};

		  # Adjust the start and stop positions on the first and last exon to match the CDS_START and CDS_STOP 
		  # tags.

		  $sorted_lref[0]->{'startpos'} = $transcript->{'TranscriptDat'}->{'CDS_START'}->{'sitepos'};
		  $sorted_lref[length(@sorted_lref) - 1]->{'endpos'} = $transcript->{'TranscriptDat'}->{'CDS_STOP'}->{'sitepos'};

		  # Join the DNA sequences of each exon. Note that subSequence will take care of the reverse complemnent operation.
		  my $cds = '';

		  foreach my $exon ( @sorted_lref )
		  {
		      $cds .= $self->subSequence( $seqId, $exon->{'startpos'}, $exon->{'endpos'}, $exon->{'complement'} );
		  }

		  # add the CDS to the return list.

		  push( @{$seqList}, $cds );

	      }
	      else
	      {
		  # The transcript is not on the complementary strand.

		  # This sorts coordinate data in ascending order based on startpos. Since the transcript is on 
		  # the non-complementary strand, this puts the first exon in the first position.

		  my @sorted_lref = sort { $a->{'startpos'} <=> $b->{'startpos'} } @{$transcript->{'TranscriptDat'}->{'EXON_COORDS'}};

		  # Adjust the start and stop positions on the first and last exon to match the CDS_START and CDS_STOP 
		  # tags.

		  $sorted_lref[0]->{'startpos'} = $transcript->{'TranscriptDat'}->{'CDS_START'}->{'sitepos'};
		  $sorted_lref[length(@sorted_lref) - 1]->{'endpos'} = $transcript->{'TranscriptDat'}->{'CDS_STOP'}->{'sitepos'};

		  # Join the DNA sequences of each exon. Note that subSequence will take care of the reverse complemnent operation.
		  my $cds = '';

		  foreach my $exon ( @sorted_lref )
		  {
		      $cds .= $self->subSequence( $seqId, $exon->{'startpos'}, $exon->{'endpos'}, $exon->{'complement'} );
		  }

		  # add the CDS to the return list.

		  push( @{$seqList}, $cds );
	      }
	      
	  }
	else
	  {
	    #Prok Orf=Gene=CDS

	     

	    my $start = $transcript->{'TranscriptDat'}->{'CDS_START'}->{'sitepos'};
	    my $stop = $transcript->{'TranscriptDat'}->{'CDS_STOP'}->{'sitepos'};
	    my $complement = $transcript->{'TranscriptDat'}->{'CDS_START'}->{'complement'};

	    push( @{$seqList}, $self->subSequence( $seqId, $start, $stop, $complement ));
	  }
      }
	
    return $seqList;
  }

sub geneCoordstoCDSHash
  {
    my $self = shift;
    my ($coords) = @_;

    my $seqHash = {};

    my $seqId = $coords->[0]->{'ParentSeq'};

    foreach my $transcript (@{$coords})
      {
	if( $transcript->{'TranscriptDat'}->{'EXON_COORDS'}->[0] )
	  {
	      #Euk data join the exon subsequences with care around the CDS start and end

	      # First check to see if the gene is on the complementary strand

	      if( $transcript->{'TranscriptDat'}->{'EXON_COORDS'}->[0]->{'complement'} eq '1' )
	      {
		  # The transcript is on the complementary strand

		  # This sorts coordinate data in descending order based on startpos. Since the transcript is on 
		  # the complementary strand, this puts the first exon in the first position.

		  my @sorted_lref = sort { $b->{'startpos'} <=> $a->{'startpos'} } @{$transcript->{'TranscriptDat'}->{'EXON_COORDS'}};

		  # Adjust the start and stop positions on the first and last exon to match the CDS_START and CDS_STOP 
		  # tags.

		  $sorted_lref[0]->{'startpos'} = $transcript->{'TranscriptDat'}->{'CDS_START'}->{'sitepos'};
		  $sorted_lref[length(@sorted_lref) - 1]->{'endpos'} = $transcript->{'TranscriptDat'}->{'CDS_STOP'}->{'sitepos'};

		  # Join the DNA sequences of each exon. Note that subSequence will take care of the reverse complemnent operation.
		  my $cds = '';

		  foreach my $exon ( @sorted_lref )
		  {
		      $cds .= $self->subSequence( $seqId, $exon->{'startpos'}, $exon->{'endpos'}, $exon->{'complement'} );
		  }

		  $seqHash->{$transcript->{'TranscriptDat'}->{'CDS_ID'}} = $cds;
	      }
	      else
	      {
		  # The transcript is not on the complementary strand.

		  # This sorts coordinate data in ascending order based on startpos. Since the transcript is on 
		  # the non-complementary strand, this puts the first exon in the first position.

		  my @sorted_lref = sort { $a->{'startpos'} <=> $b->{'startpos'} } @{$transcript->{'TranscriptDat'}->{'EXON_COORDS'}};

		  # Adjust the start and stop positions on the first and last exon to match the CDS_START and CDS_STOP 
		  # tags.

		  $sorted_lref[0]->{'startpos'} = $transcript->{'TranscriptDat'}->{'CDS_START'}->{'sitepos'};
		  $sorted_lref[length(@sorted_lref) - 1]->{'endpos'} = $transcript->{'TranscriptDat'}->{'CDS_STOP'}->{'sitepos'};

		  # Join the DNA sequences of each exon. Note that subSequence will take care of the reverse complemnent operation.
		  my $cds = '';

		  foreach my $exon ( @sorted_lref )
		  {
		      $cds .= $self->subSequence( $seqId, $exon->{'startpos'}, $exon->{'endpos'}, $exon->{'complement'} );
		  }

		  $seqHash->{$transcript->{'TranscriptDat'}->{'CDS_ID'}} = $cds;
	      }
	      
	  }
	else
	  {
	      #Prok Orf=Gene=CDS
	      
	      my $start = $transcript->{'TranscriptDat'}->{'CDS_START'}->{'sitepos'};
	      my $stop = $transcript->{'TranscriptDat'}->{'CDS_STOP'}->{'sitepos'};
	      my $complement = $transcript->{'TranscriptDat'}->{'CDS_START'}->{'complement'};
	      
	      my $cds = $self->subSequence( $seqId, $start, $stop, $complement);
	      
	      $seqHash->{$transcript->{'TranscriptDat'}->{'CDS_ID'}} = $cds;
	  }
      }
	
    return $seqHash;
  }

sub geneCoordstoGenomicSequence
  {
    my $self = shift;
    my ($coords) = @_;

    my $seqId = $coords->[0]->{'ParentSeq'};
    my $start = $coords->[0]->{'GeneSpan'}->{'startpos'};
    my $stop = $coords->[0]->{'GeneSpan'}->{'endpos'};
    my $complement = $coords->[0]->{'GeneSpan'}->{'complement'};

    return $self->subSequence( $seqId, $start, $stop, $complement );
  }

sub geneCoordstoTranscriptSequenceList
  {
      my $self = shift;
      my ($coords) = @_;
      
      my $seqList = [];
      
      my $seqId = $coords->[0]->{'ParentSeq'};
      
      foreach my $transcript (@{$coords})
      {
	  if( $transcript->{'TranscriptDat'}->{'EXON_COORDS'}->[0] )
	  {
	      #Euk data join the exon subsequences with care around the CDS start and end
	      
	      # First check to see if the gene is on the complementary strand
	      
	      if( $transcript->{'TranscriptDat'}->{'EXON_COORDS'}->[0]->{'complement'} eq '1' )
	      {
		  # The transcript is on the complementary strand
		  
		  # This sorts coordinate data in descending order based on startpos. Since the transcript is on 
		  # the complementary strand, this puts the first exon in the first position.
		  
		  my @sorted_lref = sort { $b->{'startpos'} <=> $a->{'startpos'} } @{$transcript->{'TranscriptDat'}->{'EXON_COORDS'}};

		  # Adjust the start and stop positions on the first and last exon to match the CDS_START and CDS_STOP 
		  # tags.
		  
		  $sorted_lref[0]->{'startpos'} = $transcript->{'TranscriptDat'}->{'TRANSCRIPT_START'}->{'sitepos'};
		  $sorted_lref[length(@sorted_lref) - 1]->{'endpos'} = $transcript->{'TranscriptDat'}->{'TRANSCRIPT_STOP'}->{'sitepos'};

		  # Join the DNA sequences of each exon. Note that subSequence will take care of the reverse complemnent operation.
		  my $cds = '';

		  foreach my $exon ( @sorted_lref )
		  {
		      $cds .= $self->subSequence( $seqId, $exon->{'startpos'}, $exon->{'endpos'}, $exon->{'complement'} );
		  }

		  # add the CDS to the return list.

		  push( @{$seqList}, $cds );

	      }
	      else
	      {
		  # The transcript is not on the complementary strand.

		  # This sorts coordinate data in ascending order based on startpos. Since the transcript is on 
		  # the non-complementary strand, this puts the first exon in the first position.

		  my @sorted_lref = sort { $a->{'startpos'} <=> $b->{'startpos'} } @{$transcript->{'TranscriptDat'}->{'EXON_COORDS'}};

		  # Adjust the start and stop positions on the first and last exon to match the CDS_START and CDS_STOP 
		  # tags.

		  $sorted_lref[0]->{'startpos'} = $transcript->{'TranscriptDat'}->{'TRANSCRIPT_START'}->{'sitepos'};
		  $sorted_lref[length(@sorted_lref) - 1]->{'endpos'} = $transcript->{'TranscriptDat'}->{'TRANSCRIPT_STOP'}->{'sitepos'};

		  # Join the DNA sequences of each exon. Note that subSequence will take care of the reverse complemnent operation.
		  my $cds = '';

		  foreach my $exon ( @sorted_lref )
		  {
		      $cds .= $self->subSequence( $seqId, $exon->{'startpos'}, $exon->{'endpos'}, $exon->{'complement'} );
		  }

		  # add the CDS to the return list.

		  push( @{$seqList}, $cds );
	      }
	      
	  }
	else
	  {
	    #Prok Orf=Gene=CDS

	    my $start = $transcript->{'TranscriptDat'}->{'CDS_START'}->{'sitepos'};
	    my $stop = $transcript->{'TranscriptDat'}->{'CDS_STOP'}->{'sitepos'};
	    my $complement = $transcript->{'TranscriptDat'}->{'CDS_START'}->{'complement'};

	    push( @{$seqList}, $self->subSequence( $seqId, $start, $stop, $complement ));
	  }
      }
	
    return $seqList;
  }

# returns the sequence substring of the input object. Substrings are bounded by the input 
# start and stop positions. Reverse complement is returned for inputs in which the 
# start position is greater then the end position. 

sub subSequence
  {
    my $self = shift;
    my ($seqId, $start, $stop, $complement) = @_;

    # Check if the substring is on the reverse complement. 
    # Note as of 4/21/03 some of the client builders are not setting
    # the complement attributes correctly. 

    if( ($start > $stop) )
    {
	($start, $stop) = ($stop, $start);
	$complement = 1;
    }

    # retrieve the sequence object from the lookup tables

    my $seq = BSML::BsmlDoc::BsmlReturnDocumentLookup( $seqId );
    
    if( !(ref($seq) eq 'BSML::BsmlSequence' ) )
    {
	print STDERR "BsmlReader::subSequence() - Error Sequence ID ($seqId) was not found in the document.\n";
	return '';
    }

    # get the sequence data if it is already in memory. (inline sequence objects)

    my $seqdat = $seq->returnSeqData();

    # otherwise pull in the data from an external file

    if( !($seqdat) )
    {
	my $seqimpt = $seq->returnBsmlSeqDataImport();
	
	if( $seqimpt->{'format'} eq 'fasta' )
	{
	    $seqdat = parse_multi_fasta( $seqimpt->{'source'}, $seqimpt->{'id'} );
	}
	
	# Both interal and external lookups for sequence data failed. 
	# Log and error and return the empty string.

	if( !($seqdat) )
	{
	    print STDERR "BsmlReader::subSequence - Error Unable to retrieve sequence data. $seqimpt->{'source'} Id: $seqimpt->{'id'}\n"; 
	    return '';
	}
	
	#Store the imported sequence in the object layer so further file
	#io is not necessary

	$seq->addBsmlSeqData( $seqdat );

      }

    #return the whole sequence if '-1' is passed as the start coordinate

    if( $start == -1 )
      {
	  if( $complement == '0' ){
	      return $seqdat;}
	  else{
	      return reverse_complement( $seqdat );}
      }

    # pull out the substring of interest and return it

    if( $seqdat )
      {
	  if( ($start-1) > length($seqdat) )
	  {
	      # Log error condition nd return the empty string
	      print STDERR "BsmlReader::subSequence() - Error: Out of Bounds Substring Access. SeqId($seqId) Start($start) Stop($stop) Complement($complement)\n";
	      return '';
	  }
	  
	  # return 5' to 3' data
	  if( $complement == 0 )
	  {
	      my $rseq = substr( $seqdat, $start-1, ($stop-$start+1));
	      return $rseq;
	  }
	  # return 3' to 5' data
	  else
	  {
	      return reverse_complement(substr( $seqdat, $start-1, ($stop-$start+1)));
	  }
      }
}

# By convention, the FASTA identifiers for genomic sequence have been set as follows.
# Database_asmbl_asmblId (ATH1_asmbl_68068)

sub parse_multi_fasta {

  my $fasta_file = shift;
  my $specified_header = shift;
  
  open (IN, $fasta_file) or die "Unable to open $fasta_file due to $!";
  my $line = <IN>;
  my $seq_ref = [];
  while(defined($line)) {
    unless($line =~ /^>([^\s]+)/) {
      $line = <IN>;
    } else {
      my $header = $1;
      if($specified_header eq $header) {
	while(defined($line=<IN>) and $line !~ /^>/ ) {
	  next if($line =~/^\s+$/);                   #skip blank lines
	  chomp($line);
	  push(@$seq_ref, $line);
	}
	last;   #seq found, terminating fasta_file parasing
      } else { $line = <IN>; };  #wrong seq, keep looking
    }
    }
  close IN;
  
  my $final_seq = join("", @$seq_ref);
  
  return $final_seq; 
}

sub reverse_complement {

    my $seq = shift;

    $seq =~ s/\n//g;
    

    my $complementation = { 'A' => 'T',
                            'T' => 'A',
                            'C' => 'G',
                            'G' => 'C'
                          };

    my $rev_seq = reverse($seq);
    
    my $final_seq;
    foreach my $base (split("",$rev_seq)) {
        my $comple_base= $complementation->{$base};
        $comple_base = $base if(!$comple_base);
        $final_seq .= $comple_base;
    }

    return $final_seq;

}

sub extend_seq300 {
#extends an gene sequence 300bp on both side.  
#returns the extended sequence 
#if it looks wierd or hard to understand, i didn't write this...

    my $DEBUG = 0;
    my($sequence, $topo, $end5, $end3) = @_;
    my($seqlen, $tmp, $tmpEnd5, $tmpEnd3, $EXseq);
    my ($rightEnd5);

    $seqlen = length($sequence);
    print "Initial end5/end3: $end5\/$end3\n" if ($DEBUG);

    if ($end5 < $end3) {
	$end5 -= 300;
	$end3 += 300;
	print "Extended end5/end3: $end5\/$end3\n" if ($DEBUG);
	if ($end5 < 1) {  ## overextended
	    print "OVEREXTENDED end5\n" if ($DEBUG);
	    if ($topo ne "linear") {  # wrap, treat unknowns as circular
		print "Not linear...\n" if ($DEBUG);
		$tmpEnd5 = $seqlen + $end5;
		$tmpEnd3 = $seqlen;
		$end5 = 1;
		$EXseq = substr($sequence, $tmpEnd5 - 1, $tmpEnd3 - $rightEnd5 + 1);
		$EXseq .= substr($sequence, $end5 - 1, $end3 - $end5 + 1);
	    } else {
		$end5 = 1;
		$EXseq=substr($sequence, $end5 - 1, $end3 - $end5 + 1);
	    }
	} elsif ($end3 > $seqlen) {  ## overextended
	    print "OVEREXTENDED end3\n" if ($DEBUG);
	    if ($topo ne "linear") {  # wrap, treat unknowns as circular
		print "Not linear...\n" if ($DEBUG);
		$tmpEnd5 = 1;
		$tmpEnd3 = $end3 - $seqlen;
		$end3 = $seqlen;
		$EXseq = substr($sequence, $end5 - 1, $end3 - $end5 + 1);
		$EXseq .= substr($sequence, $tmpEnd5 - 1, $tmpEnd3 - $rightEnd5 + 1);
	    } else {
		$end3 = $seqlen;
		$EXseq=substr($sequence, $end5 - 1, $end3 - $end5 + 1);
	    }
	} elsif (($end5 > 0) && ($end3 <= $seqlen)) {  ## OK
	    $EXseq=substr($sequence, $end5 - 1, $end3 - $end5 + 1);
	} else {
	    ## BUSTED
	}
    } elsif ($end3 < $end5) {
	$end5 += 300;
	$end3 -= 300;
	print "Extended end5/end3: $end5\/$end3\n" if ($DEBUG);
	if ($end3 < 1) {  ## overextended
	    print "OVEREXTENDED end3\n" if ($DEBUG);
	    if ($topo ne "linear") {  # wrap, treat unknowns as circular
		print "Not linear...\n" if ($DEBUG);
		$tmpEnd3 = $seqlen + $end3;
		$tmpEnd5 = $seqlen;
		$end3 = 1;
		$tmp = substr($sequence, $tmpEnd3 - 1, $tmpEnd5 - $tmpEnd3 + 1); 
		$tmp .= substr($sequence, $end3 - 1, $end5 - $end3 + 1);
	    } else {
		$end3 = 1;
		$tmp=substr($sequence, $end3 - 1, $end5 - $end3 + 1); 
	    }
	} elsif ($end5 > $seqlen) {  ## overextended
	    print "OVEREXTENDED end5\n" if ($DEBUG);
	    if ($topo ne "linear") {  # wrap, treat unknowns as circular
		print "Not linear...\n" if ($DEBUG);
		$tmpEnd3 = 1;
		$tmpEnd5 = $end5 - $seqlen;
		$end5 = $seqlen;
		$tmp = substr($sequence, $end3 - 1, $end5 - $end3 + 1); 
		$tmp .= substr($sequence, $tmpEnd3 - 1, $tmpEnd5 - $tmpEnd3 + 1); 
	    } else {
		$end5 = $seqlen;
		$tmp=substr($sequence, $end3 - 1, $end5 - $end3 + 1); 
	    }
	} elsif (($end3 > 0) && ($end5 <= $seqlen)) {  ## OK
	    $tmp=substr($sequence, $end3 - 1, $end5 - $end3 + 1); 
	} else {
	    ## BUSTED
	}

  	$EXseq = join("",reverse(split(/ */,$tmp)));
  	$EXseq =~tr/ACGTacgtyrkmYRKM/TGCAtgcarymkRYMK/;

    } else {
	# BUSTED
    }
    return($EXseq);
}




######################################################################################################3
# Helper functions for database search result imports.
# I expect these functions will eventually be migrated to their own
# derived class.

# Return the identifiers associated with query sequences (refseq) in sequence pair alignments
# 
# $queryObj = {'1'}->{'refseq'}->"ORF00001"
#             {'2'}->{'refseq'}->"ORF00002"
#             ...
#             {'count'}->"$ctr"

sub get_all_alignments
{
    my $self = shift;
    my $rhash = {};
    my $count = 1;

    my $seqList = $self->returnAllSequences();

    foreach my $seq( @{$seqList} )
    {
	my $seqId = $seq->returnattr('id');
	
	foreach my $aln (@{$self->fetch_all_alignmentPairs( $seqId )})
	{
	    if(ref($aln)) 
	    {
		my $match_ref = $self->readSeqPairAlignment($aln);
		$rhash->{$count} = $match_ref;
	        $count++;
	    }
	}
    }
    $rhash->{'count'} = $count;
    return $rhash;
}

sub get_all_alignment_references
{
    my $self = shift;
    my $rhash = {};
    my $count = 1;
    
    my $seqList = $self->returnAllSequences();

    foreach my $seq( @{$seqList} )
    {
	my $seqId = $seq->returnattr('id');
	
	foreach my $aln (@{$self->fetch_all_alignmentPairs( $seqId )})
	{
	    if(ref($aln)) 
	    {
		$rhash->{$count} = $aln;
	        $count++;
	    }
	}
    }
    $rhash->{'count'} = $count;
    return $rhash;
}

1
