package BSML::BsmlParserIds;

use strict;
use warnings;
use XML::Twig;

my $rhash;

sub new
  {
    my $class = shift;
    my $self = {};
    bless $self, $class;
    
    return $self;
  }

sub parse
  {
    my $self = shift;
    my ( $input_hash_ref, $fileOrHandle ) = @_;

    $rhash = ${$input_hash_ref}; 

    # Set a Twig Handler on the BSML Sequence Object. The handler is called
    # each time an XML subtree rooted at a Sequence element is completely
    # parsed

    my $twig = new XML::Twig( TwigHandlers => 
			  { Sequence => \&sequenceHandler }
			  );
    
    if (ref($fileOrHandle) && ($fileOrHandle->isa("IO::Handle") || $fileOrHandle->isa("GLOB"))) {
	$twig->parse( $fileOrHandle );
    } else {
	$twig->parsefile( $fileOrHandle );
    }
  }

# This is a private method implemented as an XML::Twig handler object. It is 
# called each time XML::Twig successfully and completely parses the subtree
# rooted at a Sequence element. The primary parse tree should be purged each time this
# method completes to handle memory efficiently. This method will need to be extended 
# to add support for additional BSML elements as they are chosen to be incorporated into
# the api.

sub sequenceHandler
  {
    my ($twig, $seq) = @_;

    my $attr = $seq->atts();
    my $seqId = $attr->{'id'};

    # add Feature Tables with Feature, Reference, and Feature-group Elements

    my $BsmlFTables = $seq->first_child( 'Feature-tables' );

    if( $BsmlFTables )
      {
	  my $cds2protId = {};

	  foreach my $BsmlFTable ( $BsmlFTables->children( 'Feature-table' ) )
	  {
	      foreach my $BsmlFeature ($BsmlFTable->children( 'Feature' ))
	      {
		  my $attr = $BsmlFeature->atts();
		  if( $attr->{'class'} eq 'CDS' )
		  {
		      my $CDSid = $attr->{'id'};
		      my $ProteinId = '';

		      foreach my $Link ($BsmlFeature->children( 'Link' ))
		      {
			  my $link_attr = $Link->atts();
			  $ProteinId = $link_attr->{'href'};

			  $ProteinId =~ s/#//;
		      }
		      
		      $cds2protId->{'CDSid'} = $ProteinId;
		  }
	      }
	  }

	foreach my $BsmlFGroup  ($BsmlFTables->children( 'Feature-group' )) 
	  { 
	      my $attr = $BsmlFGroup->atts();
	      my $geneId = $attr->{'group-set'};

	      my $transcriptId = '';
	      my $exonIds = [];
	      my $cdsId = '';
	      my $featureGroupId = $attr->{'id'};
	      my $proteinId = '';

	      foreach my $BsmlFGroupMember ( $BsmlFGroup->children( 'Feature-group-member' ))
	      {
		  my $featmember = $BsmlFGroupMember->atts();

		  if( $featmember->{'feature-type'} eq 'CDS' )
		  {
		      $cdsId = $featmember->{'featref'};
		      $proteinId = $cds2protId->{$cdsId};
		  }

		if( $featmember->{'feature-type'} eq 'TRANSCRIPT' )
		{
		    $transcriptId = $featmember->{'featref'};
		}

		if( $featmember->{'feature-type'} eq 'EXON' )
		{
		    push( @{$exonIds}, $featmember->{'featref'} );
		}
	    }
	      
	      $rhash->{$seqId}->{$geneId}->{$transcriptId}->{'exonIds'} = $exonIds;
	      $rhash->{$seqId}->{$geneId}->{$transcriptId}->{'cdsId'} = $cdsId;
	      $rhash->{$seqId}->{$geneId}->{$transcriptId}->{'featureGroupId'} = $featureGroupId;
	      $rhash->{$seqId}->{$geneId}->{$transcriptId}->{'proteinId'} = $proteinId; 
	  }
    }

            
    $twig->purge_up_to( $seq );
  }


1
