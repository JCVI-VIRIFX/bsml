#! /local/perl/bin/perl

# client script to test the functionality of the helper functions defined i
# BsmlBuilder.pm

# The BsmlBuilder class mirrors the Java API defined in the LabBook Bsml Documentation
# for building Bsml sequences.

use lib "lib/";

use BSML::BsmlBuilder;
use BSML::BsmlReader;
use BSML::BsmlDoc;
use BSML::BsmlParserTwig;
use Data::Dumper;

$outfile = 'tmp.bsml';

print '1..7',"\n";

my $doc = new BSML::BsmlBuilder;
$doc->makeCurrentDocument();

my $seq = $doc->createAndAddSequence( 'PF14_0392', 'pfa1 PF14_0392', '', 'dna' );
$doc->createAndAddSeqDataImport( $seq, 'fasta', 'chr001.fa', 'CT1234' );

open( FASTA, ">chr001.fa" );
print FASTA ">CT1234\n";

for( my $i=0; $i<800; $i++ ){
print FASTA "NNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNN\n";
}

close( FASTA );

$doc->createAndAddBsmlAttr( $seq, 'ASSEMBLY', 'asmbl001' );

my $FTable = $doc->createAndAddFeatureTable( $seq, '', ''); 
my $FGroup = $doc->createAndAddFeatureGroup( $seq, 'FGroup1', 'M1396-03861' );

my $Feat = $doc->createAndAddFeatureWithLoc( $FTable, 'M1396-03861','' , 'GENE', '', '', 1, 7366, 0 );
$doc->createAndAddQualifier( $Feat, 'name', 'PF14_0392' );
$doc->createAndAddLink( $FGroup, 'GENE', '#M1396-03861' );

$Feat = $doc->createAndAddFeatureWithLoc( $FTable, 'M1396-03861-TRANSCRIPT', '', 'TRANSCRIPT', '', '', 1, 7366, 0 );
$doc->createAndAddFeatureGroupMember( $FGroup, 'M1396-03861-TRANSCRIPT', 'TRANSCRIPT', '', '' );

$Feat = $doc->createAndAddFeature( $FTable, 'M1396-03861-CDS', '', 'CDS', '', '' );
$doc->createAndAddSiteLoc( $Feat, 70, 0, 'CDS_START' );
$doc->createAndAddSiteLoc( $Feat, 7366, 0, 'CDS_STOP' );
$doc->createAndAddLink( $Feat, 'SEQ', '#M1396-03861TranslatedSequence' );
$doc->createAndAddFeatureGroupMember( $FGroup, 'M1396-03861-CDS', 'CDS', '', '' );


$doc->createAndAddFeatureWithLoc( $FTable, 'M1396-03861-EXON1', '', 'EXON', '', '', 70, 110, 0 );
$doc->createAndAddFeatureGroupMember( $FGroup, 'M1396-03861-EXON1', 'EXON', '', '' );
$doc->createAndAddFeatureWithLoc( $FTable, 'M1396-03861-EXON2', '', 'EXON', '', '', 229, 289, 0 );
$doc->createAndAddFeatureGroupMember( $FGroup, 'M1396-03861-EXON2', 'EXON', '', '' );
$doc->createAndAddFeatureWithLoc( $FTable, 'M1396-03861-EXON3', '', 'EXON', '', '', 437, 660, 0 ); 
$doc->createAndAddFeatureGroupMember( $FGroup, 'M1396-03861-EXON3', 'EXON', '', '' );
$doc->createAndAddFeatureWithLoc( $FTable, 'M1396-03861-EXON4', '', 'EXON', '', '', 774, 982, 0 );
$doc->createAndAddFeatureGroupMember( $FGroup, 'M1396-03861-EXON4', 'EXON', '', '' );
$doc->createAndAddFeatureWithLoc( $FTable, 'M1396-03861-EXON5', '', 'EXON', '', '', 1256, 7366, 0 );
$doc->createAndAddFeatureGroupMember( $FGroup, 'M1396-03861-EXON5', 'EXON', '', '' );

my $aa_seq = 'MTTTDTWKVEWDNELRQLPNVESVTCFDLQLTENVFLIWQFLKLYLSTSPQVRSIIDFIAIKKAQSLQWGDHIDSVMSSGLRKGQELFHVFLSNGKKIQT
TYSKKKLCDRLEYYHIKNYIILEKINTGSVGQVHVALDKSTDTFVAAKAIDKSTVQGDIGLFEKLKDEIKISCMMNHPVVKTLNILETKDKIIQIMEYCDAGDLISYV
RNKLYLDEVSAQYFFRKIVEGLKYMHKNNIAHRDLKPENIFLCKIQISQKEKTLIRVGKLPSCIEYDLKIGDFGACCINEKNKLHHDIVGTLSYAAPEVLNCNNNNGY
NSEKADIWSLGIILYAMLFGLLPYDSEDKDVKEAYNEIIKKKIVFPKNRVNKFSTSVRSLLLAMLNINPQNRLSLDEVMKHEWLAGTAKNRLEMSNINKKINFPISST
VGYPIYSNKNIMDYNIYKRLALIKNDHNSSTNSLYSNGNSTTISNSNTTNMNNNVNNNVNSNVNNNVNNNVNNNVNNNMHNNIMNNVYNNMSNNISAILKVNNLRDKN
NIAENTYKLDSITNSLYGVHNNNVNSNNLKEVLYNHMKYYLKGDNKYNNTPGEHKNDYNLETLLKKKEDQVVGDLKVINKKVGHYLSSKNTKEININNKIANLVVGNK
NGNNNIIAKKNIMINNNNNDNNNISSDNIPNKMCKVDNNIVSYNKFNVEHYEYNNKGCMQSKCNQNKKDEEVVHMNKLHSICSSNDHKLYEMYMYQKNDNNMNEHVNF
INKSSNKEISRLENKYVEKIYYLKNNDMHINDDYIKDKAIKNVEKYNFINKDKNSSTYKIKDYINNNTLNRTKYNIRADKFNNIIALNNHIISNDTNRHLYINNKLSI
NKQKYNNTPYYNYYYYYYDDDDDRKKEYNKYVYKKNKKCGTNNSELISYNSSVYEKGSTPSSYNINNVPISYIKHDSIYNGSLSQYVNNSSYDKKILSSSYIKDNESH
VNKMNIEKSTIWYCSTNELPNDTIKKDSVHKKESLSQEFPVNNNDDVLDIKNDEQSKCAYNNSVVDEKENNNINVGEFKIISPNNLDSNNISSTKHITVRDTYNDNIN
KTKEAYILIKKDVNNAKCDNIFELSKMNEHSENGNNSKHTNSDIEINDRAKNLNDFVSMHEMNNFNKVDDTQLYKKKISELSNNNEKCCNINEDKNKENKNIHMHVIK
EDPNNNNNDNNNTNISADNNYSYKYVDGDIKRECVYSTDDINYVYVKPSVCSLNADGNENTEKIIKNMNFYGMDKIYSTIVQEKNEETKEDINMDHIKYNINGNIKED
IINSNNVFNTHNEQPFIDNKIMMSNINSKDNTKMYGNIFQNRNSNSIYEIKRKEKIYIINVDTPDECNEVKCDFSYNDHKIEANKDGDNKEHNNKDKDGENDEHNNKD
KDGDNDEHNNKDKYGDNNEHNYIDNNEDNYIDKDEYVNYYHDYNNPENIDHNKYEQISGLNIKEYDINEKGNYNNKKKKKQKNEHKKEANFTKHKMFILEDQKMLNTR
RGNNHMKLMDKDYINEYIKIETSNYFNKEHIKKYSSLYGKNEKKNDIINIRNFNDCISDYKNSICDGFQDIKNNSVKNIFNQDKKIYHDLSNNCVLYNNIFTQTNLEH
FSSNKLEYNKNCKYPYNNLMKNYSYSEYSFDIQNKTSTYTNKVDINKADLKEAYSDKKIKYKISNITKNEQINIYDDIKKCSSNNNNTFYIDDEASCLDITNLSDKEI
KNKKERAKKKNILNNKKCILSNGSNIFIGKEYKKNQHMDYMNKIKKNENDVLYLNNSVSLKRSFSMLHFNRNIKNHVNYYYDDHNKDRREKDILLVDHMNNYVIEHKN
KINIYNINLNNSNLNNINKNENNKIDSITSIAKKCHSSDIFLIRDNILNNLSNKEFKNIIARNVSLSHEFPLIHTNEELNKKTKKQIINNNIIYDKIGISNNKKCNIP
TKKYVNNMYNLKYKKCEPNQQFNDNVKNYKVDNVVSDFILTSEESLMTKKNNKNYKNDKNDKNYFDNSNIISYNEMKKKVTMENINMDCVVKNKTYDNMNKSNMKKIN
FNKLNISHNTQNNNNHIYNKINTYDNNLMNIKDTLGTYSVTEKHYCRQKNIMNEKEIFHYDLISSNNWDNHLRDYMLYSLSKNHYTFLRKNTLSKDIPMHSDINLFNN
KKEDTTSKNKNEKNFKINHNEKNISEYPNLSNNSISHISHTNIKSKKVKQNNDQDNHFHKKIINEQSNVFQPKLKWLNIFTRNFNKDQLGTKYK';

$seq = $doc->createAndAddSequence( 'M1396-03861TranslatedSequence', '', '', 'aa' );
$doc->createAndAddSeqData( $seq, $aa_seq  ); 

$doc->write( $outfile );

my $reader = new BSML::BsmlReader;
my $parser = new BSML::BsmlParserTwig;

$parser->parse( \$reader, $outfile );

my $rhash = $reader->readSequence( 'PF14_0392' );

if( ($rhash->{'id'} eq 'PF14_0392') &&
    ($rhash->{'title'} eq 'pfa1 PF14_0392') &&
    ($rhash->{'molecule'} eq 'dna'))
{
    #print "ASSEMBLY Sequence successfully written and read.\n";
    print 'ok 1',"\n";
}
else
{
    #print "ASSEMBLY Sequence unsuccessfully written and read.\n";
    print 'not ok 1',"\n";
}

my $rlist = $reader->returnAllSequences();

my $count = 0;
foreach my $seq ( @{$rlist} )
{
    my $rhash = $reader->readSequence( $seq );

    if( $rhash->{'id'} eq 'PF14_0392' )
    {
	my $seq = BSML::BsmlDoc::BsmlReturnDocumentLookup( 'PF14_0392' );
	my $seqdatImport = $reader->readSequenceDatImport( $seq, -1, 0, 0 );
	my $seqdat = $seqdatImport->{'seqdat'};
	
	if( $seqdat =~ /NNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNNN/ )
	{
	    #print "Successfully read ASSEMBLY sequence from FASTA file.\n";
	    print 'ok 2',"\n";
	}
	else
	{
	    #print "Unable to read ASSEMBLY sequence from FASTA file.\n";
	    print 'not ok 2',"\n";
	}

	if( $seq->returnBsmlAttr( 'ASSEMBLY' ) eq 'asmbl001' )
	{
	    #print "Successfully read BSML Attribute.\n";
	    print 'ok 3',"\n";
	}
	else
	{
	    print 'not ok 3',"\n";
	}

    }

    if( $rhash->{'id'} eq 'M1396-03861TranslatedSequence' )
    {
	my $seqdat = $reader->subSequence( 'M1396-03861TranslatedSequence', -1, 0, 0 );

	if( $seqdat eq  'MTTTDTWKVEWDNELRQLPNVESVTCFDLQLTENVFLIWQFLKLYLSTSPQVRSIIDFIAIKKAQSLQWGDHIDSVMSSGLRKGQELFHVFLSNGKKIQT
TYSKKKLCDRLEYYHIKNYIILEKINTGSVGQVHVALDKSTDTFVAAKAIDKSTVQGDIGLFEKLKDEIKISCMMNHPVVKTLNILETKDKIIQIMEYCDAGDLISYV
RNKLYLDEVSAQYFFRKIVEGLKYMHKNNIAHRDLKPENIFLCKIQISQKEKTLIRVGKLPSCIEYDLKIGDFGACCINEKNKLHHDIVGTLSYAAPEVLNCNNNNGY
NSEKADIWSLGIILYAMLFGLLPYDSEDKDVKEAYNEIIKKKIVFPKNRVNKFSTSVRSLLLAMLNINPQNRLSLDEVMKHEWLAGTAKNRLEMSNINKKINFPISST
VGYPIYSNKNIMDYNIYKRLALIKNDHNSSTNSLYSNGNSTTISNSNTTNMNNNVNNNVNSNVNNNVNNNVNNNVNNNMHNNIMNNVYNNMSNNISAILKVNNLRDKN
NIAENTYKLDSITNSLYGVHNNNVNSNNLKEVLYNHMKYYLKGDNKYNNTPGEHKNDYNLETLLKKKEDQVVGDLKVINKKVGHYLSSKNTKEININNKIANLVVGNK
NGNNNIIAKKNIMINNNNNDNNNISSDNIPNKMCKVDNNIVSYNKFNVEHYEYNNKGCMQSKCNQNKKDEEVVHMNKLHSICSSNDHKLYEMYMYQKNDNNMNEHVNF
INKSSNKEISRLENKYVEKIYYLKNNDMHINDDYIKDKAIKNVEKYNFINKDKNSSTYKIKDYINNNTLNRTKYNIRADKFNNIIALNNHIISNDTNRHLYINNKLSI
NKQKYNNTPYYNYYYYYYDDDDDRKKEYNKYVYKKNKKCGTNNSELISYNSSVYEKGSTPSSYNINNVPISYIKHDSIYNGSLSQYVNNSSYDKKILSSSYIKDNESH
VNKMNIEKSTIWYCSTNELPNDTIKKDSVHKKESLSQEFPVNNNDDVLDIKNDEQSKCAYNNSVVDEKENNNINVGEFKIISPNNLDSNNISSTKHITVRDTYNDNIN
KTKEAYILIKKDVNNAKCDNIFELSKMNEHSENGNNSKHTNSDIEINDRAKNLNDFVSMHEMNNFNKVDDTQLYKKKISELSNNNEKCCNINEDKNKENKNIHMHVIK
EDPNNNNNDNNNTNISADNNYSYKYVDGDIKRECVYSTDDINYVYVKPSVCSLNADGNENTEKIIKNMNFYGMDKIYSTIVQEKNEETKEDINMDHIKYNINGNIKED
IINSNNVFNTHNEQPFIDNKIMMSNINSKDNTKMYGNIFQNRNSNSIYEIKRKEKIYIINVDTPDECNEVKCDFSYNDHKIEANKDGDNKEHNNKDKDGENDEHNNKD
KDGDNDEHNNKDKYGDNNEHNYIDNNEDNYIDKDEYVNYYHDYNNPENIDHNKYEQISGLNIKEYDINEKGNYNNKKKKKQKNEHKKEANFTKHKMFILEDQKMLNTR
RGNNHMKLMDKDYINEYIKIETSNYFNKEHIKKYSSLYGKNEKKNDIINIRNFNDCISDYKNSICDGFQDIKNNSVKNIFNQDKKIYHDLSNNCVLYNNIFTQTNLEH
FSSNKLEYNKNCKYPYNNLMKNYSYSEYSFDIQNKTSTYTNKVDINKADLKEAYSDKKIKYKISNITKNEQINIYDDIKKCSSNNNNTFYIDDEASCLDITNLSDKEI
KNKKERAKKKNILNNKKCILSNGSNIFIGKEYKKNQHMDYMNKIKKNENDVLYLNNSVSLKRSFSMLHFNRNIKNHVNYYYDDHNKDRREKDILLVDHMNNYVIEHKN
KINIYNINLNNSNLNNINKNENNKIDSITSIAKKCHSSDIFLIRDNILNNLSNKEFKNIIARNVSLSHEFPLIHTNEELNKKTKKQIINNNIIYDKIGISNNKKCNIP
TKKYVNNMYNLKYKKCEPNQQFNDNVKNYKVDNVVSDFILTSEESLMTKKNNKNYKNDKNDKNYFDNSNIISYNEMKKKVTMENINMDCVVKNKTYDNMNKSNMKKIN
FNKLNISHNTQNNNNHIYNKINTYDNNLMNIKDTLGTYSVTEKHYCRQKNIMNEKEIFHYDLISSNNWDNHLRDYMLYSLSKNHYTFLRKNTLSKDIPMHSDINLFNN
KKEDTTSKNKNEKNFKINHNEKNISEYPNLSNNSISHISHTNIKSKKVKQNNDQDNHFHKKIINEQSNVFQPKLKWLNIFTRNFNKDQLGTKYK' )
	{
	    #print "Successfully read inline sequence data from protein sequence.\n";
	    print 'ok 4',"\n";
	}
	else
	{
	    #print "Unable to read inline sequence data from protein sequence.\n";
	    print 'not ok 4',"\n";
	}
    }
}

my $rlist = $reader->geneIdtoGenomicCoords( 'M1396-03861' );
{
    if( ($rlist->[0]->{'ParentSeq'} eq 'PF14_0392') &&
	($rlist->[0]->{'GeneSpan'}->{'endpos'} == 7366) &&
	($rlist->[0]->{'TranscriptDat'}->{'EXON_COORDS'}->[0]->{'endpos'} == 110))
    {
	#print "Successfully extracted gene coordinates using feature group (gene) lookups\n";
	print 'ok 5',"\n";
    }
    else
    {
	#print "Unable to extract gene coordinates using feature group (gene) lookups\n";
	print 'not ok 5',"\n";
    }
}

my $featureGroupList = $reader->geneIdtoFeatureGroupList( 'M1396-03861' );

FTEST: {foreach my $fgroup (@{$featureGroupList})
{
    my $rhash = $reader->readFeatureGroup( $fgroup );

    if( $rhash->{'id'} eq 'FGroup1' && $rhash->{'group-set'} eq 'M1396-03861' )
    {
	foreach $fgroupMember (@{$rhash->{'feature-members'}})
	{
	    if( $fgroupMember->{'feature-type'} eq 'CDS' )
	    {
		my $cdsFeat = BSML::BsmlDoc::BsmlReturnDocumentLookup( $fgroupMember->{'featref'} );
		foreach my $link (@{$cdsFeat->returnBsmlLinkListR()})
		{
		    if( $link->{'rel'} eq 'SEQ' )
		    {
			my $seqId = $link->{'href'};
			$seqId =~ s/#//;

			my $seq = BSML::BsmlDoc::BsmlReturnDocumentLookup( $seqId );
			
			if( $reader->readSequenceDat( $seq ) eq 'MTTTDTWKVEWDNELRQLPNVESVTCFDLQLTENVFLIWQFLKLYLSTSPQVRSIIDFIAIKKAQSLQWGDHIDSVMSSGLRKGQELFHVFLSNGKKIQT
TYSKKKLCDRLEYYHIKNYIILEKINTGSVGQVHVALDKSTDTFVAAKAIDKSTVQGDIGLFEKLKDEIKISCMMNHPVVKTLNILETKDKIIQIMEYCDAGDLISYV
RNKLYLDEVSAQYFFRKIVEGLKYMHKNNIAHRDLKPENIFLCKIQISQKEKTLIRVGKLPSCIEYDLKIGDFGACCINEKNKLHHDIVGTLSYAAPEVLNCNNNNGY
NSEKADIWSLGIILYAMLFGLLPYDSEDKDVKEAYNEIIKKKIVFPKNRVNKFSTSVRSLLLAMLNINPQNRLSLDEVMKHEWLAGTAKNRLEMSNINKKINFPISST
VGYPIYSNKNIMDYNIYKRLALIKNDHNSSTNSLYSNGNSTTISNSNTTNMNNNVNNNVNSNVNNNVNNNVNNNVNNNMHNNIMNNVYNNMSNNISAILKVNNLRDKN
NIAENTYKLDSITNSLYGVHNNNVNSNNLKEVLYNHMKYYLKGDNKYNNTPGEHKNDYNLETLLKKKEDQVVGDLKVINKKVGHYLSSKNTKEININNKIANLVVGNK
NGNNNIIAKKNIMINNNNNDNNNISSDNIPNKMCKVDNNIVSYNKFNVEHYEYNNKGCMQSKCNQNKKDEEVVHMNKLHSICSSNDHKLYEMYMYQKNDNNMNEHVNF
INKSSNKEISRLENKYVEKIYYLKNNDMHINDDYIKDKAIKNVEKYNFINKDKNSSTYKIKDYINNNTLNRTKYNIRADKFNNIIALNNHIISNDTNRHLYINNKLSI
NKQKYNNTPYYNYYYYYYDDDDDRKKEYNKYVYKKNKKCGTNNSELISYNSSVYEKGSTPSSYNINNVPISYIKHDSIYNGSLSQYVNNSSYDKKILSSSYIKDNESH
VNKMNIEKSTIWYCSTNELPNDTIKKDSVHKKESLSQEFPVNNNDDVLDIKNDEQSKCAYNNSVVDEKENNNINVGEFKIISPNNLDSNNISSTKHITVRDTYNDNIN
KTKEAYILIKKDVNNAKCDNIFELSKMNEHSENGNNSKHTNSDIEINDRAKNLNDFVSMHEMNNFNKVDDTQLYKKKISELSNNNEKCCNINEDKNKENKNIHMHVIK
EDPNNNNNDNNNTNISADNNYSYKYVDGDIKRECVYSTDDINYVYVKPSVCSLNADGNENTEKIIKNMNFYGMDKIYSTIVQEKNEETKEDINMDHIKYNINGNIKED
IINSNNVFNTHNEQPFIDNKIMMSNINSKDNTKMYGNIFQNRNSNSIYEIKRKEKIYIINVDTPDECNEVKCDFSYNDHKIEANKDGDNKEHNNKDKDGENDEHNNKD
KDGDNDEHNNKDKYGDNNEHNYIDNNEDNYIDKDEYVNYYHDYNNPENIDHNKYEQISGLNIKEYDINEKGNYNNKKKKKQKNEHKKEANFTKHKMFILEDQKMLNTR
RGNNHMKLMDKDYINEYIKIETSNYFNKEHIKKYSSLYGKNEKKNDIINIRNFNDCISDYKNSICDGFQDIKNNSVKNIFNQDKKIYHDLSNNCVLYNNIFTQTNLEH
FSSNKLEYNKNCKYPYNNLMKNYSYSEYSFDIQNKTSTYTNKVDINKADLKEAYSDKKIKYKISNITKNEQINIYDDIKKCSSNNNNTFYIDDEASCLDITNLSDKEI
KNKKERAKKKNILNNKKCILSNGSNIFIGKEYKKNQHMDYMNKIKKNENDVLYLNNSVSLKRSFSMLHFNRNIKNHVNYYYDDHNKDRREKDILLVDHMNNYVIEHKN
KINIYNINLNNSNLNNINKNENNKIDSITSIAKKCHSSDIFLIRDNILNNLSNKEFKNIIARNVSLSHEFPLIHTNEELNKKTKKQIINNNIIYDKIGISNNKKCNIP
TKKYVNNMYNLKYKKCEPNQQFNDNVKNYKVDNVVSDFILTSEESLMTKKNNKNYKNDKNDKNYFDNSNIISYNEMKKKVTMENINMDCVVKNKTYDNMNKSNMKKIN
FNKLNISHNTQNNNNHIYNKINTYDNNLMNIKDTLGTYSVTEKHYCRQKNIMNEKEIFHYDLISSNNWDNHLRDYMLYSLSKNHYTFLRKNTLSKDIPMHSDINLFNN
KKEDTTSKNKNEKNFKINHNEKNISEYPNLSNNSISHISHTNIKSKKVKQNNDQDNHFHKKIINEQSNVFQPKLKWLNIFTRNFNKDQLGTKYK' )
			{
			    print 'ok 6',"\n";
			    last FTEST;
			}
		    }
		}
	    }
	}
    }
    print 'not ok 6', "\n";
}}

my $rvalue = system( "/usr/local/annotation/PNEUMO/chauser_dir/xmlvalid-1-0-0-Linux-i586/xmlvalid -q $outfile" );

if( $rvalue == 0 )
{
    #print "Successfully validated temporary gene-sequence BSML document\n"; 
    print 'ok 7',"\n";
}
else
{
    print 'not ok 7',"\n";
}

unlink $outfile;