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

    if( ref($self) eq 'BSML::BsmlReader' ){
      return $self->returnBsmlSequenceListR();}
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

sub readSeqPairAlignment
  {
    my $self = shift;
    my ($SeqPairAln) = @_;
    my $rhash = {};

    if( ref($SeqPairAln) eq 'BSML::BsmlSeqPairAlignment' )
      {
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
	    $runDat->{'refpos'} = $SeqPairRun->returnattr( 'refpos' );
	    $runDat->{'runlength'} = $SeqPairRun->returnattr( 'runlength' );
	    $runDat->{'refcomplement'} = $SeqPairRun->returnattr( 'refcomplement' );
	    $runDat->{'comppos'} = $SeqPairRun->returnattr( 'comppos' );
	    $runDat->{'comprunlength'} = $SeqPairRun->returnattr( 'comprunlength' );
	    $runDat->{'compcomplement'} = $SeqPairRun->returnattr( 'compcomplement' );
	    $runDat->{'runscore'} = $SeqPairRun->returnattr( 'runscore' );
	    $runDat->{'runprob'} = $SeqPairRun->returnattr( 'runprob' );
	    $runDat->{'percent_identity'} = $SeqPairRun->returnBsmlAttr( 'percent_identity' );
	    $runDat->{'percent_similarity'} = $SeqPairRun->returnBsmlAttr( 'percent_similarity' );
	    $runDat->{'chain_number'} = $SeqPairRun->returnBsmlAttr( 'chain_number' );
	    $runDat->{'segment_number'} = $SeqPairRun->returnBsmlAttr( 'segment_number' );
	    $runDat->{'p_value'} = $SeqPairRun->returnBsmlAttr( 'p_value' );

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

	foreach my $featmemb (@{$FeatureGroup->returnFeatureGroupMemberListR()})
	  {
	    push( @{$returnhash->{'feature-members'}}, { 'featref' => $featmemb->{'feature'},
							 'feature-type' => $featmemb->{'feature-type'},
							 'group-type' => $featmemb->{'group-type'},
							 'cdata' => $featmemb->{'text'}
						       });
	  }

	return $returnhash;
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

#Returns a reference to a list of sequence objects given an assembly id.

sub assemblyIdtoSeqList
  {
    my $self = shift;
    my ($assemblyId) = @_;

    my $rlist = [];

    foreach my $seq ( @{$self->returnAllSequences()} )
      {
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
	# This loops through all the featuregroup set ids (genes) in the document.
	# ChecksG to see if the gene is on the assembly of interest

	if( $self->geneIdtoAssemblyId($geneId) eq $assemblyId )
	  {
	    push( @{$rlist}, $geneId );
	  }
      }

    return $rlist;
  }

# This workflow "helper" function may better serve in the client layer as it is really just
# a summary of the coordinates produced by geneIdtoGenomicCoords.

# For each gene on the input assembly, returns the coordinates of the gene, 
# namely the genomic positions that span the gene's largest transcript. Results
# are returned as a reference to anonymous hashes.  

sub fetch_gene_positions
  {
    my $self = shift;
    my ($assemblyId) = @_;

    my $rlist = [];

    foreach my $gene ( @{$self->assemblyIdtoGeneList($assemblyId)} )
      {
	my $rhash = {};
        my $geneCoords = $self->geneIdtoGenomicCoords( $gene );

	$rhash->{$gene}->{'startpos'} = $geneCoords->[0]->{'GeneSpan'}->{'startpos'};
	$rhash->{$gene}->{'endpos'} = $geneCoords->[0]->{'GeneSpan'}->{'endpos'};
	$rhash->{$gene}->{'complement'} = $geneCoords->[0]->{'GeneSpan'}->{'complement'};

	push( @{$rlist}, $rhash );
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

sub get_all_protein_dna
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

sub get_all_protein_dna_extended
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

		  #get the protein id from the sequence object linked to the CDS object
		  
		  my $feat = BSML::BsmlDoc::BsmlReturnDocumentLookup( $transcript->{'TranscriptDat'}->{'CDS_ID'} );

		  if( !(ref($feat) eq 'BSML::BsmlFeature' ) )
		  {
		      print STDERR "BsmlReader::geneCoordstoCDSHash() - Error CDS Feature not found\n";
		      return;
		  }
		 
		  foreach my $link ( @{$feat->returnBsmlLinkListR()} )
		  {
		      if( $link->{'rel'} eq 'SEQ' )
		      {
			  
			  my $seqref = $link->{'href'};
			  $seqref =~ s/#//;
			  my $seq = BSML::BsmlDoc::BsmlReturnDocumentLookup($seqref);

			  if( ref($seq) eq 'BSML::BsmlSequence' )
			  {
			      $seqHash->{$seq->returnattr('id')} = $cds;
			  }
			  else
			  {
			      print STDERR "BsmlReader::geneCoordstoCDSHash() - Error Amino Acid Sequence not found.\n";
			  }
		      }
		  }
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

		  	  #get the protein id from the sequence object linked to the CDS object
		  
		  my $feat = BSML::BsmlDoc::BsmlReturnDocumentLookup( $transcript->{'TranscriptDat'}->{'CDS_ID'} );

		  if( !(ref($feat) eq 'BSML::BsmlFeature' ) )
		  {
		      print STDERR "BsmlReader::geneCoordstoCDSHash() - Error CDS Feature not found\n";
		      return;
		  }
		 
		  foreach my $link ( @{$feat->returnBsmlLinkListR()} )
		  {
		      if( $link->{'rel'} eq 'SEQ' )
		      {
			  
			  my $seqref = $link->{'href'};
			  $seqref =~ s/#//;
			  my $seq = BSML::BsmlDoc::BsmlReturnDocumentLookup($seqref);

			  if( ref($seq) eq 'BSML::BsmlSequence' )
			  {
			      $seqHash->{$seq->returnattr('id')} = $cds;
			  }
			  else
			  {
			      print STDERR "BsmlReader::geneCoordstoCDSHash() - Error Amino Acid Sequence not found.\n";
			  }
		      }
		  }
	      }
	      
	  }
	else
	  {
	      #Prok Orf=Gene=CDS
	      
	      my $start = $transcript->{'TranscriptDat'}->{'CDS_START'}->{'sitepos'};
	      my $stop = $transcript->{'TranscriptDat'}->{'CDS_STOP'}->{'sitepos'};
	      my $complement = $transcript->{'TranscriptDat'}->{'CDS_START'}->{'complement'};
	      
	      my $cds = $self->subSequence( $seqId, $start, $stop, $complement);
	      
	      #get the protein id from the sequence object linked to the CDS object
		  
	      my $feat = BSML::BsmlDoc::BsmlReturnDocumentLookup( $transcript->{'TranscriptDat'}->{'CDS_ID'} );

	      if( !(ref($feat) eq 'BSML::BsmlFeature' ) )
	      {
		  print STDERR "BsmlReader::geneCoordstoCDSHash() - Error CDS Feature not found\n";
		  return;
		  }
	      
	      foreach my $link ( @{$feat->returnBsmlLinkListR()} )
	      {
		  if( $link->{'rel'} eq 'SEQ' )
		  {
		      
		      my $seqref = $link->{'href'};
		      $seqref =~ s/#//;
		      my $seq = BSML::BsmlDoc::BsmlReturnDocumentLookup($seqref);
		      
		      if( ref($seq) eq 'BSML::BsmlSequence' )
		      {
			  $seqHash->{$seq->returnattr('id')} = $cds;
		      }
		      else
		      {
			  print STDERR "BsmlReader::geneCoordstoCDSHash() - Error Amino Acid Sequence not found.\n";
		      }
		  }
	      }
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

sub subSequence
  {
    my $self = shift;
    my ($seqId, $start, $stop, $complement) = @_;

    if( $complement == 1 && ($start > $stop) )
    {
	($start, $stop) = ($stop, $start);
    }

    my $seq = BSML::BsmlDoc::BsmlReturnDocumentLookup( $seqId );
    
    if( !(ref($seq) eq 'BSML::BsmlSequence' ) )
    {
	print STDERR "BsmlReader::subSequence - Error Sequence ID ($seqId) was not found in the document.\n";
	return '';
    }

    my $seqdat = $seq->returnSeqData();

    if( !($seqdat) ){
	my $seqimpt = $seq->returnBsmlSeqDataImport();

	if( $seqimpt->{'format'} eq 'fasta' ){
	  $seqdat = parse_multi_fasta( $seqimpt->{'source'}, $seqimpt->{'id'} );}

	#Store the imported sequence in the object layer so further file
	#io is not necessary

	if( !($seqdat) )
	{
	    print "File: $seqimpt->{'source'} Id: $seqimpt->{'id'}\n"; 
	    die "Could not read sequence data from file\n";
	}

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

    if( $seqdat )
      {
	if( $complement == 0 )
	  {
	      my $rseq = substr( $seqdat, $start-1, ($stop-$start+1));
	      return $rseq;
	  }
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


#this function might serve better as a bitscore uitility function than in the general API

sub fetchAlignmentScoresBetweenAssemblies {

    my $reader = shift;
    my $query_asmbl_id = shift;
    my $match_asmbl_id = shift;
    #my $order = shift || '1';

    my $bit_score_hash={};
    foreach my $seq (@{$reader->assemblyIdtoSeqList($query_asmbl_id )}) {   #grab all seq obj given query_asmbl_id
	my $seq_id = $seq->returnattr( 'id' );                              #return seq_id of an seq obj
	foreach my $aln (@{$reader->fetch_all_alignmentPairs( $seq_id )}) { #return all alignment with query as $seq_id
	    if(ref($aln)) {
		my $match_ref = $reader->readSeqPairAlignment($aln);            #return all pair_runs for an alignment_pair
		my $m_asmbl_id = $reader->seqIdtoAssemblyId($match_ref->{'compseq'});
		if($m_asmbl_id eq $match_asmbl_id) {                            #check to see if match gene belongs to match asmbl_id
		    my $best_bit_score=0;
		    foreach my $pair_run(@{ $match_ref->{'seqPairRuns'} }) {
			$best_bit_score = $pair_run->{'runscore'} if($pair_run->{'runscore'} > $best_bit_score);  #store best bit_score
		    }
		    $bit_score_hash->{$seq_id}->{ $match_ref->{'compseq'} }->{'bit_score'} = $best_bit_score;
		  }
		#add the best bit score for a query gene against itself 
		#to provide a baseline for bit score comparison
		#-----------------------------------------------------
		my $aln = $reader->fetch_all_alignmentPairs($seq_id, $seq_id);
		$match_ref = $reader->readSeqPairAlignment($aln->[0]);            #return all pair_runs for an alignment_pair
		my $best_bit_score=0;
		foreach my $pair_run(@{ $match_ref->{'seqPairRuns'} }) {
		    $best_bit_score = $pair_run->{'runscore'} if($pair_run->{'runscore'} > $best_bit_score);  #store best bit_score
		}
		$bit_score_hash->{$seq_id}->{$seq_id}->{'bit_score'} = $best_bit_score;
		#------------------------------------------------------
	    }
	}

    }

	return $bit_score_hash;
}

sub fetch_genome_pairwise_matches
  {
    my $reader = shift;
    my ($query_asmbl_id, $match_asmbl_id) = @_;

    my $rlist=[];

    foreach my $seq (@{$reader->assemblyIdtoSeqList($query_asmbl_id )}) {   #grab all seq obj given query_asmbl_id
	my $seq_id = $seq->returnattr( 'id' );                              #return seq_id of an seq obj
	foreach my $aln (@{$reader->fetch_all_alignmentPairs( $seq_id )}) { #return all alignment with query as $seq_id
	    if(ref($aln)) {
		my $match_ref = $reader->readSeqPairAlignment($aln);            #return all pair_runs for an alignment_pair
		my $m_asmbl_id = $reader->seqIdtoAssemblyId($match_ref->{'compseq'});
		if($m_asmbl_id eq $match_asmbl_id || $match_asmbl_id eq 'all' )
		  {
		    my $rhash = {};
		    
		    $rhash->{'query_gene_name'} = $match_ref->{'refseq'};
		    $rhash->{'match_gene_name'} = $match_ref->{'compseq'};

		    my $best_percent_identity = 0.0;
	      
		    foreach my $pair_run(@{ $match_ref->{'seqPairRuns'} }) {


			$best_percent_identity = $pair_run->{'percent_identity'} if($pair_run->{'percent_identity'} > $best_percent_identity);
		      }

		    $rhash->{'percent_identity'} = $best_percent_identity;

		    my $best_percent_similarity = 0.0;
		    
		    foreach my $pair_run(@{ $match_ref->{'seqPairRuns'} }) {
			$best_percent_similarity = $pair_run->{'percent_similarity'} if($pair_run->{'percent_similarity'} > $best_percent_similarity);
		      }

		    $rhash->{'percent_similarity'} = $best_percent_similarity;

		    my $best_pval = 1e30;
		    foreach my $pair_run(@{ $match_ref->{'seqPairRuns'} }) {
		      $best_pval = $pair_run->{'p_value'} if($pair_run->{'p_value'} < $best_pval);
		    }

		    $rhash->{'pval'} = $best_pval;

		    push( @{$rlist}, $rhash );
		  }
		  
	      }
	  }
      }
    return $rlist;
  }


1
