package BsmlReader;
@ISA = qw( BsmlDoc );

#use strict;
#use warnings;
use BsmlDoc;
use Data::Dumper;

sub readSequence
  {
    my $self = shift;
    my ($seq) = @_;

    if( !($seq) )
      {
	print "Error: Sequence not defined\n";
	return;
      }
    else
      {
	if( !(ref( $seq ) eq 'BsmlSequence') )
	  {
	    foreach my $sequence (@{$self->returnBsmlSequenceListR()})
	      {
		if( $sequence->returnattr( 'id' ) eq $seq )
		  {
		    $seq = $sequence;
		    last;
		  }
	      }
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

    if( ref($self) eq 'BsmlReader' ){
      return $self->returnBsmlSequenceListR();}
  }

sub readSequenceDat
  {
    my $self = shift;
    my ($seq) = @_;

    if( ref($seq) eq 'BsmlSequence' ){
      return $seq->returnSeqData();}
  }

sub readSequenceDatImport
  {
    my $self = shift;
    my ($seq) = @_;

    if( ref($seq) eq 'BsmlSequence' ){
      return $seq->returnBsmlSeqDataImport();}
  }

sub readFeatures
  {
    my $self = shift;
    my ($input) = @_;

    my $feat_list = [];

    if( ref($input) eq 'BsmlSequence' )
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
    
    if( ref($input) eq 'BsmlFeatureTable' )
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
    
    if( ref($input) eq 'BsmlFeature' )
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

    if( ref($input) eq 'BsmlSequence' )
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
    
    if( ref($input) eq 'BsmlFeatureTable' )
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

    if( ref($input) eq 'BsmlReference' )
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
    my $bsmlhash = $elem->returnBsmlAttrHashR();

    foreach my $qual (keys(%{$bsmlhash}))
      {
	push( @{$bsmlattr}, { key => $qual, value => $bsmlhash->{$qual} } );
      }
		
    return $bsmlattr;
  }

sub returnAllFeatureTables
  {
    my $self = shift;
    my ($input) = @_;

    if( ref($input) eq 'BsmlSequence' )
      {
	return $input->returnBsmlFeatureTableListR();
      }
   
    if( ref($input) eq 'BsmlReader' )
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
	$runDat->{'percent_identity'} = $SeqPairRun->returnattr( 'percent_identity' );
	$runDat->{'percent_similarity'} = $SeqPairRun->returnattr( 'percent_similarity' );
	$runDat->{'chain_number'} = $SeqPairRun->returnattr( 'chain_number' );
	$runDat->{'segment_number'} = $SeqPairRun->returnattr( 'segment_number' );
	$runDat->{'p_value'} = $SeqPairRun->returnattr( 'p_value' );

	push( @{$rhash->{'seqPairRuns'}}, $runDat );	
      }
    
    return $rhash;
  }

sub readLinks
  {
    my $self = shift;
    my ($elem) = @_;

    return $elem->returnBsmlLinkListR();
  }

sub readFeatureGroup
  {
    my $self = shift;
    my ($FeatureGroup) = @_;

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

############################################################

sub returnAllFeatureGroupSetIds
  {
    my $self = shift;
    return BsmlDoc::BsmlReturnFeatureGroupLookupIds();
  }

sub returnAllGeneIDs
  {
    my $self = shift;
    return $self->returnAllFeatureGroupSetIds();
  }

sub geneIdtoAssemblyId
  {
    my $self = shift;
    my ($geneId) = @_;
    my $fgrouplist = BsmlDoc::BsmlReturnFeatureGroupLookup($geneId);

    if($fgrouplist)
      {
	return $fgrouplist->[0]->returnParentSequenceId();
      }
    else
      {
	return '';
      }
  }

sub geneIdtoAASeqList
  {
    my $self = shift;
    my ($geneId) = @_;

    my @returnAASequenceList;

    my $fgrouplist = BsmlDoc::BsmlReturnFeatureGroupLookup($geneId);
    
    foreach my $fgroup (@{$fgrouplist})
      {
	foreach my $fmember (@{$fgroup->returnFeatureGroupMemberListR()})
	  {
	    if( $fmember->{'feature-type'} eq 'CDS' )
	      {
		my $feat = BsmlDoc::BsmlReturnDocumentLookup( $fmember->{'feature'} );
		foreach my $link ( @{$feat->returnBsmlLinkListR()} )
		  {
		    if( $link->{'rel'} eq 'SEQ' )
		      {
			my $sref = $link->{'href'};
			$sref =~ s/#//;
			my $seq = BsmlDoc::BsmlReturnDocumentLookup( $sref );
			
			if( my $seqdat = $seq->returnSeqData() ){
			  push( @returnAASequenceList, $seqdat );}
			else
			  {
			    #handle sequence data import tags
			  }
		      }
		  }
	      }
	  }
      }
     
    return \@returnAASequenceList;
  }

#return all the protein sequences associated with an assembly
#returns a hash reference where the keys are sequence ids and
#the values are the sequences. Note for data containing multiple
#transcripts the ids will be set as genename_index where index
#is incremented as sequences are encountered. Should BsmlFGroup ids
#be used to store transcript identifiers???

sub get_all_protein_aa
  {
    my $self = shift;
    my ($assembly_id) = @_;

    my $returnhash = {};

    foreach my $gene( $self->returnAllGeneIDs() )
      {
	if( $self->geneIdtoAssemblyId($gene) eq $assembly_id )
	  {
	    my $aalist = $self->geneIdtoAASeqList($gene);
	    
	    my $i = 0;
	    foreach my $seq (@{$aalist})
	      {
		$key = $gene."_".$i;
		$returnhash->{$key} = $seq;
		$i++;
	      }
	  }
      }

    return $returnhash;
  }

#return a list of hash references containing...
#  ParentSeqID, TranscriptID, GeneSpan, CDS_START, CDS_END, Exon_Boundaries

sub geneIdtoGenomicCoords
  {
    my $self = shift;
    my ($geneID) = @_;

    my $returnlist = [];

    foreach my $fgroup( @{BsmlDoc::BsmlReturnFeatureGroupLookup($geneID)} )
      {
	my $coordRecord = {};
	$coordRecord->{'ParentSeq'} = $fgroup->returnParentSequenceId();

	foreach my $link ( @{$fgroup->returnBsmlLinkListR()} )
	  {
	    if( $link->{'rel'} eq 'GENE' )
	      {
	
		my $generef = $link->{'href'};
		$generef =~ s/#//;
		my $feat = BsmlDoc::BsmlReturnDocumentLookup($generef);

		if($feat)
		  {
		    my $intervals = $feat->returnBsmlIntervalLocListR();
		    $coordRecord->{'GeneSpan'} = { 'startpos' => $intervals->[0]->{'startpos'},
						   'endpos' => $intervals->[0]->{'endpos'},
						   'complement' => $intervals->[0]->{'endpos'}};
		  }
	      }
	  }

	$coordRecord->{'Transcripts'} = [];

	foreach my $fmember (@{$fgroup->returnFeatureGroupMemberListR()})
	  {
	    my $group = {};
	    my $featureRef = $fmember->{'feature'};
	    my $featureType = $fmember->{'feature-type'};
	    my $featureGroup = $fmember->{'group-type'};

	    if( $featureType eq 'CDS' )
	      {
		my $feat = BsmlDoc::BsmlReturnDocumentLookup($featureRef);

		if($feat)
		  {
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
		
	      }

	    if( $featureType eq 'TRANSCRIPT' )
	      {
		
	      }
	    
	    push( @{$coordRecord->{'Transcripts'}}, $group ); 
	  }
	push( @{$returnlist}, $coordRecord );
      }

    return $returnlist;
  }

sub geneIdtoNucSequence
  {

  }

sub seqIdtoSequence
  {

  }

sub seqIdtoSequenceRef
  {

  }

sub seqReftoGeneCoord
  {

  }

1
