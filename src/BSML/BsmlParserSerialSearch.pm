package BSML::BsmlParserSerialSearch;

# Directed parser for serial output of BSML search encodings. 

use strict;
use warnings;
use XML::Twig;
use Log::Log4perl qw(get_logger :levels);
use BSML::BsmlSeqPairAlignment;
use BSML::BsmlAnalysis;
use BSML::BsmlSequence;
use BSML::BsmlFeature;


# Clients must define callback routines which are called during parsing. Callbacks may be defined
# for Sequence, SeqPairAlignment, and Analysis objects. These functions are called with an object 
# reference during the parse as each element is encountered. The objects may be used directly or
# through the BsmlReader class. Twigs are rooted at Sequence, SeqPairAlignment, Feature, or Analysis elements
# for maximum efficiency. 

sub new
  {
    my $class = shift;
    my (%args) = @_; 
    my $self = {};
    bless $self, $class;
    
    if( $args{'AlignmentCallBack'} ){
	$self->{'AlignmentCallBack'} = $args{'AlignmentCallBack'};

	$self->{'Roots'}->{'Seq-pair-alignment'} = sub {my ($twig, $seq_aln ) = @_;
									  my $bsml_aln = seqPairAlignmentHandler($twig,$seq_aln);
									  $self->{'AlignmentCallBack'}( $bsml_aln );
						    };
    }

    if( $args{'AnalysisCallBack'} ){
	$self->{'AnalysisCallBack'} = $args{'AnalysisCallBack'};
	
	$self->{'Roots'}->{'Analysis'} = sub {my ($twig, $analysis) = @_;
					      my $bsml_analysis = analysisHandler( $twig, $analysis );
					      $self->{'AnalysisCallBack'}( $bsml_analysis );
					  };
    }

    if( $args{'SequenceCallBack'} ){
	$self->{'SequenceCallBack'} = $args{'SequenceCallBack'};
	
	if( defined( $args{'ReadFeatureTables'} ) ){
	    if( $args{'ReadFeatureTables'} == 1 ){
			$self->{'Roots'}->{'Sequence'} = sub {my ($twig, $sequence) = @_;
					      my $bsml_sequence = sequenceHandler( $twig, $sequence );
					      $self->{'SequenceCallBack'}( $bsml_sequence );
					  };
		    }
	    else{
			$self->{'Roots'}->{'Sequence'} = sub {my ($twig, $sequence) = @_;
					      my $bsml_sequence = minsequenceHandler( $twig, $sequence );
					      $self->{'SequenceCallBack'}( $bsml_sequence );
					  };
		    }
	}
	else{
	    $self->{'Roots'}->{'Sequence'} = sub {my ($twig, $sequence) = @_;
					      my $bsml_sequence = sequenceHandler( $twig, $sequence );
					      $self->{'SequenceCallBack'}( $bsml_sequence );
					  };
	}
    }

    if( $args{'FeatureCallBack'} ){
	$self->{'FeatureCallBack'} = $args{'FeatureCallBack'};
	
	$self->{'Roots'}->{'Feature'} = sub {my ($twig, $feature) = @_;
					     my $bsml_feature = featureHandler( $twig, $feature );
					     $self->{'FeatureCallBack'}( $bsml_feature );
					 };
    }
	
    return $self;
  }

sub parse
  {
    my $self = shift;
    my ( $filename ) = @_;
    my $bsml_logger = get_logger( "Bsml" );

    # Set "rooted" twig handlers on Sequence, SeqPairAlignment, and Analysis elements. 

    my $twig = new XML::Twig( TwigRoots => $self->{'Roots'} );

    # parse will die if an xml syntax error is encountered or if
    # there is an io problem

    if( $filename ){
	$twig->parsefile( $filename );}
    else{
	$twig->parse( \*STDIN );}

    $twig->dispose();  
  }

# handler for SeqPairAlignment elements. Returns a reference to a BSML::SeqPairAlignment object.

sub seqPairAlignmentHandler
  {
     my ($twig, $seq_aln ) = @_;

     # create a new BsmlSeqPairAlignment object

     my $bsmlaln = new BSML::BsmlSeqPairAlignment;
     
     # add the BsmlSeqPairAlignment element's attributes

     my $attr = $seq_aln->atts();

     foreach my $key ( keys( %{$attr} ) )
       {
	 $bsmlaln->addattr( $key, $attr->{$key} );
       }

     # add Bsml Attribute elements to the BsmlSeqPairAlignment 

     foreach my $BsmlAttr ( $seq_aln->children( 'Attribute' ) )
      {
	my $attr = $BsmlAttr->atts();
	$bsmlaln->addBsmlAttr( $attr->{'name'}, $attr->{'content'} );
      }

     foreach my $BsmlLink ( $seq_aln->children( 'Link' ) )
       {
	 my $attr = $BsmlLink->atts();
	 $bsmlaln->addBsmlLink( $attr->{'ref'}, $attr->{'href'} );
       }
     
     foreach my $seq_run ( $seq_aln->children('Seq-pair-run') )
       {
	 my $bsmlseqrun = $bsmlaln->returnBsmlSeqPairRunR( $bsmlaln->addBsmlSeqPairRun() ); 

	 my $attr = $seq_run->atts();
	 foreach my $key ( keys( %{$attr} ) ){
	   $bsmlseqrun->addattr( $key, $attr->{$key} );
	 }

	 foreach my $BsmlAttr ( $seq_run->children( 'Attribute' ) ){
	   my $attr = $BsmlAttr->atts();
	   $bsmlseqrun->addBsmlAttr( $attr->{'name'}, $attr->{'content'} );
	 }

	 foreach my $BsmlLink ( $seq_run->children( 'Link' ) )
	   {
	     my $attr = $BsmlLink->atts();
	     $bsmlseqrun->addBsmlLink( $attr->{'ref'}, $attr->{'href'} );
	   }
       }     
     
     $twig->purge();

     return $bsmlaln;

  }

# handler for analysis elements. Returns a reference to a BSML::Analysis object.

sub analysisHandler
  {
    my ($twig, $analysis) = @_;
    my $bsml_analysis = new BSML::BsmlAnalysis;
    my $attr = $analysis->atts();
    
    foreach my $key ( keys( %{$attr} ) )
      {
	$bsml_analysis->addattr( $key, $attr->{$key} );
      }

    foreach my $BsmlAttr ( $analysis->children( 'Attribute' ) )
      {
	my $attr = $BsmlAttr->atts();
	$bsml_analysis->addBsmlAttr( $attr->{'name'}, $attr->{'content'} );
      }

    foreach my $BsmlLink ( $analysis->children( 'Link' ) )
      {
	my $attr = $BsmlLink->atts();
	$bsml_analysis->addBsmlLink( $attr->{'rel'}, $attr->{'href'} );
      }

    $twig->purge();
    return $bsml_analysis;
  }

# handler for sequence elements. Returns a reference to a BSML::Sequence object.

sub sequenceHandler
  {
    my ($twig, $seq) = @_;

    # add a new Sequence object to the bsmlDoc

    my $bsmlseq = new BSML::BsmlSequence;
    
    # add the sequence element's attributes

    my $attr = $seq->atts();

    foreach my $key ( keys( %{$attr} ) )
      {
	$bsmlseq->addattr( $key, $attr->{$key} );
      }

    # add Sequence level Bsml Attribute elements 

    foreach my $BsmlAttr ( $seq->children( 'Attribute' ) )
      {
	my $attr = $BsmlAttr->atts();
	$bsmlseq->addBsmlAttr( $attr->{'name'}, $attr->{'content'} );
      }

    # add any Bsml Links

    foreach my $BsmlLink ( $seq->children( 'Link' ) )
      {
	my $attr = $BsmlLink->atts();
	$bsmlseq->addBsmlLink( $attr->{'title'}, $attr->{'href'} );
      }

    # add raw sequence data if found 

    my $seqDat = $seq->first_child( 'Seq-data' );
    
    if( $seqDat ){
      $bsmlseq->addBsmlSeqData( $seqDat->text() );
    }

    # add appended sequence data if found

    my $seqDatImport = $seq->first_child( 'Seq-data-import' );
    
    if( $seqDatImport )
      {
	my $attr = $seqDatImport->atts();
	$bsmlseq->addBsmlSeqDataImport( $attr->{'format'}, $attr->{'source'}, $attr->{'id'});
      }

    # add Feature Tables with Feature, Reference, and Feature-group Elements

    my $BsmlFTables = $seq->first_child( 'Feature-tables' );

    if( $BsmlFTables )
      {
	foreach my $BsmlFTable ( $BsmlFTables->children( 'Feature-table' ) )
	  {
	    my $table = $bsmlseq->{'BsmlFeatureTables'}[$bsmlseq->addBsmlFeatureTable()];

	    my $attr = $BsmlFTable->atts();

	    foreach my $key ( keys( %{$attr} ) )
	      {
		$table->addattr( $key, $attr->{$key} );
	      }

	    foreach my $BsmlLink ( $BsmlFTable->children( 'Link' ) )
	      {
		my $attr = $BsmlLink->atts();
		$table->addBsmlLink( $attr->{'title'}, $attr->{'href'} );
	      }

	    foreach my $BsmlRef ($BsmlFTable->children( 'Reference' ) )
	      {
		my $ref = $table->{'BsmlReferences'}[$table->addBsmlReference()];
		my $attr = $BsmlRef->atts();

		foreach my $key ( keys( %{$attr} ) )
		  {
		    $ref->addattr( $key, $attr->{$key} );
		  }

		foreach my $BsmlAuthor ($BsmlRef->children( 'RefAuthors' ))
		  {
		    $ref->addBsmlRefAuthors( $BsmlAuthor->text() );
		  }

		foreach my $BsmlRefTitle ($BsmlRef->children( 'RefTitle' ))
		  {
		    $ref->addBsmlRefTitle( $BsmlRefTitle->text() );
		  }

		foreach my $BsmlRefJournal ($BsmlRef->children( 'RefJournal' ))
		  {
		    $ref->addBsmlRefJournal( $BsmlRefJournal->text() );
		  }

		foreach my $BsmlLink ( $BsmlRef->children( 'Link' ) )
		  {
		    my $attr = $BsmlLink->atts();
		    $ref->addBsmlLink( $attr->{'title'}, $attr->{'href'} );
		  }
	      }
	  

	    foreach my $BsmlFeature ($BsmlFTable->children( 'Feature' ))
	      {
		my $feat = $table->{'BsmlFeatures'}[$table->addBsmlFeature()];
		my $attr = $BsmlFeature->atts();

		foreach my $key ( keys( %{$attr} ) )
		  {
		    $feat->addattr( $key, $attr->{$key} );
		  }

		foreach my $BsmlQualifier ($BsmlFeature->children( 'Qualifier' ))
		  {
		    my $attr = $BsmlQualifier->atts();
		    $feat->addBsmlQualifier( $attr->{'value-type'} , $attr->{'value'} ); 
		  }

		foreach my $BsmlIntervalLoc ($BsmlFeature->children( 'Interval-loc' ))
		  {
		    my $attr = $BsmlIntervalLoc->atts();
		    if( !( $attr->{'complement'} ) ){ $attr->{ 'complement' } = 0 };

		    $feat->addBsmlIntervalLoc( $attr->{'startpos'} , $attr->{'endpos'}, $attr->{'complement'} ); 
		  }

		foreach my $BsmlSiteLoc ($BsmlFeature->children( 'Site-loc' ))
		  {
		    my $attr = $BsmlSiteLoc->atts();

		    if( !( $attr->{'complement'} ) ){ $attr->{ 'complement' } = 0 };
		    $feat->addBsmlSiteLoc( $attr->{'sitepos'} , $attr->{'complement'}, $attr->{'class'} ); 
		  }

		foreach my $BsmlLink ( $BsmlFeature->children( 'Link' ) )
		  {
		    my $attr = $BsmlLink->atts();
		    $feat->addBsmlLink( $attr->{'rel'}, $attr->{'href'} );
		  }
	      }
	  }
	foreach my $BsmlFGroup  ($BsmlFTables->children( 'Feature-group' )) 
	  {
	    my $group = $bsmlseq->{'BsmlFeatureGroups'}[$bsmlseq->addBsmlFeatureGroup()];
	    
	    my $attr = $BsmlFGroup->atts();
	    
	    foreach my $key ( keys( %{$attr} ) )
	      {
		$group->addattr( $key, $attr->{$key} );
	      }

	    if( $BsmlFGroup->text() ){
	      $group->setText( $BsmlFGroup->text() ); 
	    }

	    foreach my $BsmlLink ( $BsmlFGroup->children( 'Link' ) )
	      {
		my $attr = $BsmlLink->atts();
		$group->addBsmlLink( $attr->{'rel'}, $attr->{'href'} );
	      }

	    foreach my $BsmlFGroupMember ( $BsmlFGroup->children( 'Feature-group-member' ))
	      {
		my $attr = $BsmlFGroupMember->atts();
		my $text = $BsmlFGroupMember->text();

		$group->addBsmlFeatureGroupMember( $attr->{'featref'}, $attr->{'feature-type'}, $attr->{'group-type'}, $text );
	      }
	    
	  }
	
      }
      
    $twig->purge;
    return $bsmlseq;
  }

# Feature tables and Feature groups are not parsed with the minisequenceHandler

sub minsequenceHandler
  {
    my ($twig, $seq) = @_;

    # add a new Sequence object to the bsmlDoc

    my $bsmlseq = new BSML::BsmlSequence;
    
    # add the sequence element's attributes

    my $attr = $seq->atts();

    foreach my $key ( keys( %{$attr} ) )
      {
	$bsmlseq->addattr( $key, $attr->{$key} );
      }

    # add Sequence level Bsml Attribute elements 

    foreach my $BsmlAttr ( $seq->children( 'Attribute' ) )
      {
	my $attr = $BsmlAttr->atts();
	$bsmlseq->addBsmlAttr( $attr->{'name'}, $attr->{'content'} );
      }

    # add any Bsml Links

    foreach my $BsmlLink ( $seq->children( 'Link' ) )
      {
	my $attr = $BsmlLink->atts();
	$bsmlseq->addBsmlLink( $attr->{'title'}, $attr->{'href'} );
      }

    # add raw sequence data if found 

    my $seqDat = $seq->first_child( 'Seq-data' );
    
    if( $seqDat ){
      $bsmlseq->addBsmlSeqData( $seqDat->text() );
    }

    # add appended sequence data if found

    my $seqDatImport = $seq->first_child( 'Seq-data-import' );
    
    if( $seqDatImport )
      {
	my $attr = $seqDatImport->atts();
	$bsmlseq->addBsmlSeqDataImport( $attr->{'format'}, $attr->{'source'}, $attr->{'id'});
      }
      
    $twig->purge;
    return $bsmlseq;
}


sub featureHandler
{
    my ($twig, $BsmlFeature) = @_;

    my $feat = new BSML::BsmlFeature;
    my $attr = $BsmlFeature->atts();

    foreach my $key ( keys( %{$attr} ) )
    {
	$feat->addattr( $key, $attr->{$key} );
    }

    foreach my $BsmlQualifier ($BsmlFeature->children( 'Qualifier' ))
    {
	my $attr = $BsmlQualifier->atts();
	$feat->addBsmlQualifier( $attr->{'value-type'} , $attr->{'value'} ); 
    }

    foreach my $BsmlIntervalLoc ($BsmlFeature->children( 'Interval-loc' ))
    {
	my $attr = $BsmlIntervalLoc->atts();
	if( !( $attr->{'complement'} ) ){ $attr->{ 'complement' } = 0 };
	
	$feat->addBsmlIntervalLoc( $attr->{'startpos'} , $attr->{'endpos'}, $attr->{'complement'} ); 
    }

    foreach my $BsmlSiteLoc ($BsmlFeature->children( 'Site-loc' ))
    {
	my $attr = $BsmlSiteLoc->atts();
	
	if( !( $attr->{'complement'} ) ){ $attr->{ 'complement' } = 0 };
	$feat->addBsmlSiteLoc( $attr->{'sitepos'} , $attr->{'complement'}, $attr->{'class'} ); 
    }
    
    foreach my $BsmlLink ( $BsmlFeature->children( 'Link' ) )
    {
	my $attr = $BsmlLink->atts();
	$feat->addBsmlLink( $attr->{'rel'}, $attr->{'href'} );
    }
    
    $twig->purge;

    return $feat;
}

1
