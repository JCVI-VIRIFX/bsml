use lib "../src/";
use BSML::BsmlBuilder;
use BSML::BsmlReader;
use BSML::BsmlParserTwig;

open( CONFIG2ASMBL, '/usr/local/annotation/TRYP/scaffold_mappings/new_contig_map.txt' );

my $config2asmbl = {};

while( my $line = <CONFIG2ASMBL> )
{
    chomp( $line );
    my @list = split( " ", $line );

    $config2asmbl->{$list[0]} = $list[1]; 
}

open( CONTIGMAP, '/usr/local/annotation/TRYP/scaffold_mappings/scaff.info.plus.myco.free' );

my $bsmlSuperSeqs = {};
my $bsmlSeqRef = {};
my $superSeqs = {};
my $superLengths = {};

while( my $line = <CONTIGMAP> )
{
    chomp( $line );
    my @list = split( " ", $line);

    my $AssembleId = $config2asmbl->{$list[1]};

    my $ContigId = $list[1];
    my $length = $list[7];
    my $scaffoldId = $list[2];
    my $orientation = $list[4];

    if( !defined($AssembleId) || !defined($ContigId) || !defined($length) || !defined($scaffoldId) || !defined($orientation) )
    {
	next;
    }

    if( !(-e "/usr/local/annotation/TRYP/BSML_repository/tca1_".$AssembleId."_assembly.bsml") )
    {
	print "not found /usr/local/annotation/TRYP/BSML_repository/tca1_".$AssembleId."_assembly.bsml\n";
	next;
    }

    if( $orientation eq 'R' )
    {
	$orientation = 1;
    }
    else
    {
	$orientation = 0;
    }

    my $order = $list[3];
    
    if( !( $bsmlSuperSeqs->{$scaffoldId} ) )
    {
	$bsmlSuperSeqs->{$scaffoldId} =  new BSML::BsmlBuilder;
	my $org = $bsmlSuperSeqs->{$scaffoldId}->createAndAddOrganism( genome => $bsmlSuperSeqs->{$scaffoldId}->createAndAddGenome(),
							     species => 'cruzi',
							     genus => 'Trypanosoma' );

	$bsmlSuperSeqs->{$scaffoldId}->createAndAddStrain( organism => $org,
				  database => 'tryp',
				  source_database => 'tca1' );


	$bsmlSuperSeqs->{$scaffoldId}->makeCurrentDocument();

	$bsmlSeqRef->{$scaffoldId} = $bsmlSuperSeqs->{$scaffoldId}->createAndAddExtendedSequenceN( id => "tca1_".$scaffoldId."_supercontig",
												   class => "SUPERCONTIG",
												   molecule => "DNA",
												   length => -1 );

	$bsmlSeqRef->{$scaffoldId}->addattr( "class", "SUPERCONTIG" );
    }

    my $reader = new BSML::BsmlReader;
    my $parser = new BSML::BsmlParserTwig;
    
    $reader->makeCurrentDocument();
    $parser->parse( \$reader, "/usr/local/annotation/TRYP/BSML_repository/tca1_".$AssembleId."_assembly.bsml" );
    my $seq = BSML::BsmlDoc::BsmlReturnDocumentLookup( "tca1_".$AssembleId."_assembly" );
    my $ss = $reader->readSequenceDatImport( $seq )->{'seqdat'};

    $length = length( $ss );

    if( $orientation == 1 )
    {
	$ss = reverse_complement( $ss );
    }
    
    for( my $i=0; $i<10; $i++ )
    {
	$ss .= 'NNNNNNNNNN';
    }

    $bsmlSuperSeqs->{$scaffoldId}->makeCurrentDocument();

    my $seq = $bsmlSuperSeqs->{$scaffoldId}->createAndAddExtendedSequenceN( id => "tca1_".$AssembleId."_assembly",
									    class => "CONTIG",
									    length => $length );

    $seq->addattr( "class", "CONTIG" );

    if( $orientation == 0 )
    {
	my $numbering = $bsmlSuperSeqs->{$scaffoldId}->createAndAddNumbering( seq => $seq,
									      seqref => "tca1_".$scaffoldId."_supercontig",
									      refnum => (length(($superSeqs->{$scaffoldId}))),
									      ascending => 1 );
    }
    else
    {
	my $numbering = $bsmlSuperSeqs->{$scaffoldId}->createAndAddNumbering( seq => $seq,
									      seqref => "tca1_".$scaffoldId."_supercontig",
									      refnum => (length(($superSeqs->{$scaffoldId}))) + $length,
									      ascending => 0 );
    }


    $bsmlSuperSeqs->{$scaffoldId}->createAndAddSeqDataImportN( seq => $seq,
							       format => "BSML",
                                  source => "/usr/local/annotation/TRYP/BSML_repository/tca1_".$AssembleId."_assembly.bsml",
                                  id => "_tca1_".$AssembleId."_assembly");

 $superSeqs->{$scaffoldId} .= $ss;

print "$AssembleId\n";
}


my $count = 0;
foreach my $key (keys(%{$bsmlSuperSeqs}))
{
    $bsmlSuperSeqs->{$key}->createAndAddSeqData( $bsmlSeqRef->{$key}, $superSeqs->{$key} );
    $bsmlSeqRef->{$key}->addattr( 'length', length( ($superSeqs->{$key}) ));

    my $str = "tca1_".$key."_supercontig.bsml";

    $bsmlSuperSeqs->{$key}->write( $str );
    $count++;
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
