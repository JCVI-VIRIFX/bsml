#! /local/perl/bin/perl

# client script to test the functionality of the helper functions defined i
# BsmlBuilder.pm

# The BsmlBuilder class mirrors the Java API defined in the LabBook Bsml Documentation
# for building Bsml sequences.

use lib "../src/";
use BSML::BsmlBuilder;
use BSML::BsmlReader;
use BSML::BsmlParserTwig;

open( IDMAP, '/usr/local/annotation/ASP/aoa1.contig2asmbl_id' ) or die "Could not open /usr/local/annotation/ASP/aoa1.contig2asmbl_id";
open( CONTIGMAP, '/usr/local/annotation/AOA1/dataXchange/upload-20030811_1/contig-mapping.txt' ) or die "Could not open /usr/local/annotation/AOA1/dataXchange/upload-20030811_1/contig-mapping.txt";

my $idmap = {};

while( my $line = <IDMAP> )
{
    chomp( $line );
    my @list = split( " ", $line);
    $idmap->{$list[0]} = $list[1];
}

<CONTIGMAP>;

my $bsmlSuperSeqs = {};
my $bsmlSeqRef = {};
my $superSeqs = {};
my $superLengths = {};

while( my $line = <CONTIGMAP> )
{
    chomp( $line );
    my @list = split( " ", $line);

    my $AssembleId = $idmap->{$list[0]};

    my $ContigId = $list[0];
    my $length = $list[1];
    my $scaffoldId = $list[2];
    my $orientation = $list[3];

    if( !defined($AssembleId) || !defined($ContigId) || !defined($length) || !defined($scaffoldId) || !defined($orientation) )
    {
	next;
    }

    if( $orientation == -1 )
    {
	$orientation = 1;
    }
    else
    {
	$orientation = 0;
    }

    my $chrom_id = $list[4];
    my $order = $list[5];
    
    if( !( $bsmlSuperSeqs->{$scaffoldId} ) )
    {
	$bsmlSuperSeqs->{$scaffoldId} =  new BSML::BsmlBuilder;
	my $org = $bsmlSuperSeqs->{$scaffoldId}->createAndAddOrganism( genome => $bsmlSuperSeqs->{$scaffoldId}->createAndAddGenome(),
							     species => 'oryzae',
							     genus => 'Aspergillus' );

	$bsmlSuperSeqs->{$scaffoldId}->createAndAddStrain( organism => $org,
				  database => 'asp',
				  source_database => 'aoa1' );


	$bsmlSuperSeqs->{$scaffoldId}->makeCurrentDocument();

	$bsmlSeqRef->{$scaffoldId} = $bsmlSuperSeqs->{$scaffoldId}->createAndAddExtendedSequenceN( id => "aoa1_".$scaffoldId."_supercontig",
							  title => "AOA1 Super Contig",
							  length => -1 );

	$bsmlSeqRef->{$scaffoldId}->addBsmlAttr( 'TYPE', 'SUPERCONTIG' );

    }
    
    $bsmlSuperSeqs->{$scaffoldId}->makeCurrentDocument();

    my $seq = $bsmlSuperSeqs->{$scaffoldId}->createAndAddExtendedSequenceN( id => "aoa1_".$AssembleId."_assembly",
									    title => "$AssembleId ($ContigId)",
							  length => $length );

    $seq->addBsmlAttr( 'TYPE', 'CONTIG' );

    my $numbering = $bsmlSuperSeqs->{$scaffoldId}->createAndAddNumbering( seq => $seq,
			         seqref => "aoa1_".$scaffoldId."_supercontig",
				 refnum => (length(($superSeqs->{$scaffoldId}))),
			         ascending => $orientation );

    $numbering->addattr( 'a', $order-1 );

    $bsmlSuperSeqs->{$scaffoldId}->createAndAddSeqDataImportN( seq => $seq,
				      format => "BSML",
                                  source => "/usr/local/annotation/ASP/BSML_repository/aoa1_".$AssembleId."_assembly.bsml",
                                  id => "_aoa1_".$AssembleId."_assembly");


    my $reader = new BSML::BsmlReader;
    my $parser = new BSML::BsmlParserTwig;

    $reader->makeCurrentDocument();
    $parser->parse( \$reader, "/usr/local/annotation/ASP/BSML_repository/aoa1_".$AssembleId."_assembly.bsml" );
    my $seq = BSML::BsmlDoc::BsmlReturnDocumentLookup( "aoa1_".$AssembleId."_assembly" );
    my $ss = $reader->readSequenceDatImport( $seq )->{'seqdat'};

if( $orientation == 1 )
{
    $ss = reverse_complement( $ss );
}

for( my $i=0; $i<5; $i++ )
{
    $ss .= 'NNNNNNNNNN';
}

$superSeqs->{$scaffoldId} .= $ss;

print "$AssembleId\n";
}


my $count = 0;
foreach my $key (keys(%{$bsmlSuperSeqs}))
{
    $bsmlSuperSeqs->{$key}->createAndAddSeqData( $bsmlSeqRef->{$key}, $superSeqs->{$key} );
    $bsmlSeqRef->{$key}->addattr( 'length', length( ($superSeqs->{$key}) ));

    $bsmlSuperSeqs->{$key}->write( "$key.bsml" );
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








