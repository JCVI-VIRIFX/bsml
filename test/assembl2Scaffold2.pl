use lib "../src/";
use BSML::BsmlBuilder;
use BSML::BsmlReader;
use BSML::BsmlParserSerialSearch;

my $asmblId = '';
my $scafId = '';

my $parser = new BSML::BsmlParserSerialSearch( SequenceCallBack => \&sequenceHandler );
my $reader = new BSML::BsmlReader;

sub sequenceHandler
{
    my $seqref = shift;

    if( $seqref->returnattr( 'id' ) eq $asmblId )
    {
	my $length = $seqref->returnattr( 'length' );
	
	my $bsmlScaffold =  new BSML::BsmlBuilder;

	my $org = $bsmlScaffold->createAndAddOrganism( genome => $bsmlScaffold->createAndAddGenome(),
								       species => 'brucei',
								       genus => 'Trypanosoma' );
	
	$bsmlScaffold->createAndAddStrain( organism => $org,
					   database => 'tryp',
					   source_database => 'tba1' );

	
	my $scafseq = $bsmlScaffold->createAndAddExtendedSequenceN( id => $scafId,
										molecule => "dna",
										length => $length );

	$scafseq->addattr( "class",  "SUPERCONTIG" );

	
	my $seq = $bsmlScaffold->createAndAddExtendedSequenceN( id => $asmblId,
								molecule => "dna",
								length => $length );

	
	$seq->addattr( "class",  "CONTIG" );
	
	my $numbering = $bsmlScaffold->createAndAddNumbering( seq => $seq,
							      seqref => $scafId,
							      refnum => 0,
							      ascending => 1 );


	$bsmlScaffold->createAndAddSeqDataImportN( seq => $seq,
						   format => "BSML",
                                  source => "/usr/local/annotation/TRYP/BSML_repository/$asmblId.bsml",
                                  id => "_$asmblId");

         my $ss = $reader->readSequenceDatImport( $seqref )->{'seqdat'};

         $bsmlScaffold->createAndAddSeqData( $scafseq, $ss );

         $bsmlScaffold->write( "$scafId.bsml" );

    }
}


foreach my $file ( </usr/local/annotation/TRYP/BSML_repository/lma*.bsml> )
{
    $asmblId = $file;
    $asmblId =~ s/\/usr\/local\/annotation\/TRYP\/BSML_repository\///;
    $asmblId =~ s/\.bsml//;

    $scafId = $asmblId;
    $scafId =~ s/_assembly/_supercontig/;

    $parser->parse( $file );
    
}
