#! /local/perl/bin/perl

use Getopt::Long qw(:config no_ignore_case no_auto_abbrev);
use Data::Dumper;
use BSML::BsmlParserSerialSearch;
use BSML::BsmlReader;

my $ref_parser = new BSML::BsmlParserSerialSearch( SequenceCallBack => \&sequenceCheck );

my %options = ();

my $results = GetOptions( \%options, 'directory|d=s', 'skip-syntax', 'skip-structure', 'skip-references', 'skip-checksums', 'skip-workflows', 'printconf', 'version|V=s', 'conf|c=s', 'verbose|v=s', 'help|h' );

my $project_dir = $options{'directory'};
$project_dir =~ s/\/$//;

# Configuration Defaults
my $version = "check_repository.pl v0.90\n";

my $xsdValid = '/export/CVS/bsml/schema/xsdValid-Xerces/xsdValid.pl';
my $dtdValid = '/export/CVS/bsml/schema/xsdValid-Xerces/dtdValid.pl';
my $bsmlDTD = '/export/CVS/bsml/schema/bsml3_1.dtd';
my $genSeqSchema = '/export/CVS/bsml/schema/genseq.xsd';
my $promerSchema = '/export/CVS/bsml/schema/promer.xsd';
my $blastpSchema = '/export/CVS/bsml/schema/pblast.xsd';
my $nucmerSchema = '/export/CVS/bsml/schema/nucmer.xsd';
my $allvsallSchema = '/export/CVS/bsml/schema/allvsall.xsd';
my $peffectSchema = '/export/CVS/bsml/schema/peffect.xsd';
my $regionsSchema = '/export/CVS/bsml/schema/regions.xsd';

# Read a configuration file if specified

if( $options{'conf'} )
{
    print "Reading configurations file. ($options{'conf'})\n";

    open( INFILE, $options{'conf'} ) or die "Could not open configuration file. ($options{'conf'})\n";

    while( my $line = <INFILE> )
    {
	my ($key, $value) = split( '=', $line );
	chomp $value;
	
	if( $key eq 'xsdValid' ) {$xsdValid=$value;}
	if( $key eq 'dtdValid' ) {$dtdValid=$value;}
	if( $key eq 'bsmlDTD' )  {$bsmlDTD=$value;}
	if( $key eq 'genSeqSchema' ) {$genSeqSchema=$value;}
	if( $key eq 'promerSchema' ) {$promerSchema=$value;}
	if( $key eq 'blastpSchema' ) {$blastpSchema=$value;}
	if( $key eq 'nucmerSchema' ) {$nucmerSchema=$value;}
	if( $key eq 'allvsallSchema' ) {$allvsallSchema=$value;}
	if( $key eq 'peffectSchema' ) {$peffectSchema=$value;}
	if( $key eq 'regionsSchema' ) {$regionsSchema=$value;}
    }
}

if( defined($options{'printconf'})){ print_conf(); }

sub print_conf
{
    
    print "\nConfiguration:\n";
    print "---------------------------------------------------------------------------\n";
    print "xsdValid=$xsdValid\n";
    print "dtdValid=$dtdValid\n";
    print "bsmlDTD=$bsmlDTD\n";
    print "genSeqSchema=$genSeqSchema\n";
    print "promerSchema=$promerSchema\n";
    print "blastpSchema=$blastpSchema\n";
    print "nucmerSchema=$nucmerSchema\n";
    print "allvsallSchema=$allvsallSchema\n";
    print "peffectSchema=$peffectSchema\n";
    print "regionsSchema=$regionsSchema\n";
}

# display version information if requested

if( defined( $options{'version'} ))
{
    print "$version\n";
    exit();
}

if( !defined( $options{'skip-structure'} )){
    check_repository_hierchy_and_permissions();}

if( !defined( $options{'skip-syntax'} )){
    run_document_validation();}

if( !defined( $options{'skip-checksums'})){
    check_checksums();}

if( !defined( $options{'skip-references'})){
    check_referencial_integrity();}

sub check_repository_hierchy_and_permissions
{
    print "\nTesting Repository Directory Hierchy and File Permissions\n";
    print "---------------------------------------------------------------------------\n";

    my $rhash = {};

    # Check the Repository Hierchy

    my $status = system( "ls $project_dir 1>/dev/null 2>/dev/null" );
    my @file_status = stat( $project_dir );
    my $mode = sprintf( "%o", $file_status[2] & 0777 );
    
    if( $status >> 8 )
    {
	$rhash->{'project_dir'}->{'present'} = 0;
	$rhash->{'project_dir'}->{'permissions'} = 0;
    }
    else
    {
	$rhash->{'project_dir'}->{'present'} = 1;
	if(  !($mode eq '777' || $mode eq '666') )
	{
	    $rhash->{'project_dir'}->{'permissions'} = 0;
	}
	else
	{
	    $rhash->{'project_dir'}->{'permissions'} = 1;
	}
    }
    
    $rhash->{'project_dir'}->{'required'} = 1;
    $rhash->{'bsml_dir'}->{'required'} = 1;
    
    $status = system( "ls $project_dir/BSML_repository 1>/dev/null 2>/dev/null" );
    @file_status = stat( "$project_dir/BSML_repository" );
    my $mode = sprintf( "%o", $file_status[2] & 0777 );
    
    if( $status >> 8 || !($mode eq '777' || $mode eq '666'))
    {
	$rhash->{'bsml_dir'}->{'present'} = 0;
	$rhash->{'bsml_dir'}->{'permissions'} = 0;
    }
    else
    {
	$rhash->{'bsml_dir'}->{'present'} = 1;
	if(  !($mode eq '777' || $mode eq '666') )
	{
	    $rhash->{'bsml_dir'}->{'permissions'} = 0;
	}
	else
	{
	    $rhash->{'bsml_dir'}->{'permissions'} = 1;
	}

	$rhash->{'geneSeq'}->{'required'} = 1;
	
	my @files = <$project_dir/BSML_repository/*.bsml>;
	
	if( !(my $count = @files))
	{
	    $rhash->{'geneSeq'}->{'present'} = 0;
	}
	else
	{
	    $rhash->{'geneSeq'}->{'present'} = 1;
	    $rhash->{'geneSeq'}->{'permissions'} = 1;

	    foreach my $file (@files)
	    {
		my @file_status = stat( $file );
		my $mode = sprintf( "%o", $file_status[2] & 0777 );
		
		if( !(($mode eq '777') || ($mode eq '666')) )
		{
		    $rhash->{'geneSeq'}->{'permissions'} = 0;
		}
	    }
	}
	

	$rhash->{'assembly_fasta'}->{'required'} = 1;
	
	@files = <$project_dir/FASTA_repository/*.fsa>;
	
	if( !(my $count = @files))
	{
	    $rhash->{'assembly_fasta'}->{'present'} = 0;
	}
	else
	{
	    $rhash->{'assembly_fasta'}->{'present'} = 1;
	    $rhash->{'assembly_fasta'}->{'permissions'} = 1;

	    foreach my $file (@files)
	    {
		my @file_status = stat( $file );
		my $mode = sprintf( "%o", $file_status[2] & 0777 );
		
		if( !(($mode eq '777') || ($mode eq '666')) )
		{
		    $rhash->{'assembly_fasta'}->{'permissions'} = 0;
		}
	    }
	}
	
	$rhash->{'protein_fasta'}->{'required'} = 1;

	@files = <$project_dir/BSML_repository/*.pep>;
	
	if( !(my $count = @files))
	{
	    $rhash->{'protein_fasta'}->{'present'} = 0;
	}
	else
	{
	    $rhash->{'protein_fasta'}->{'present'} = 1;
	    $rhash->{'protein_fasta'}->{'permissions'} = 1;

	    foreach my $file (@files)
	    {
		my @file_status = stat( $file );
		my $mode = sprintf( "%o", $file_status[2] & 0777 );
		
		if( !(($mode eq '777') || ($mode eq '666')) )
		{
		    $rhash->{'protein_fasta'}->{'permissions'} = 0;
		}
	    }
	}
    }

    my $dirlist = [ 'promer', 'blastp', 'nucmer', 'ber', 'PEffect', 'Region', 'snps', 'cogs' ];  
    
    foreach my $search ( @{$dirlist} )
    {
	$rhash->{$search."_dir"}->{'required'} = 0;

	$status = system( "ls $project_dir/BSML_repository/$search 1>/dev/null 2>/dev/null" );
	@file_status = stat( "$project_dir/BSML_repository/$search" );
    
	my $mode = sprintf( "%o", $file_status[2] & 0777 );
    
	if( $status >> 8 )
	{
	    $rhash->{$search."_dir"}->{'present'} = 0;
	}
	else
	{
	    $rhash->{$search."_dir"}->{'present'} = 1;
	    $rhash->{$search."_dir"}->{'permissions'} = 1;

	    if( !($mode eq '777' || $mode eq '666') )
	    {
		$rhash->{$search."_dir"}->{'permissions'} = 0;
	    }
	}
	
	my $search_bsml = $search."_bsml";
	$rhash->{"$search_bsml"}->{'required'} = 0;
	
	my @filelist = ();
	my @files = ();

	@files = <$project_dir/BSML_repository/$search/*.bsml>;

	foreach my $f (@files)
	{
	    if( !($f eq '.' || $f eq '..' ))
	    {
		push( @filelist, $f );
	    }
	}
	
	if( !(my $count = @filelist))
	{
	    $rhash->{"$search_bsml"}->{'present'} = 0;
	}
	else
	{
	    $rhash->{"$search_bsml"}->{'present'} = 1;
	    $rhash->{"$search_bsml"}->{'permissions'} = 1;
	    
	    foreach my $file (@filelist)
	    {
		my @file_status = stat( $file );
		my $mode = sprintf( "%o", $file_status[2] & 0777 );
		
		if( !(($mode eq '777') || ($mode eq '666')) )
		{
		    $rhash->{"$search_bsml"}->{'permissions'} = 0;
		}
	    }
	}
    }

    print "\nDetected Repository Structure:\n";

    if( $rhash->{'project_dir'}->{'present'} && $rhash->{'project_dir'}->{'present'} )
    {
	print "\t$project_dir/BSML_Repository/\n";

	my $dirlist = [ 'promer', 'blastp', 'nucmer', 'ber', 'PEffect', 'Region', 'snps', 'cogs' ];  

	foreach my $dir (@{$dirlist})
	{
	    my $search = $dir."_bsml";

	    if( $rhash->{$search}->{'present'} )
	    {
		print "\t$project_dir/BSML_Repository/$dir\n";
	    }
	}

    }
    else
    {
	print "Test_Bsml_Repository_Structure:\tnot_ok\t0/1 passed\n"; 
	print "\tBsml Repository Root not present\n";
	return;
    }

    print "\n\n";

    foreach my $k (sort(keys( %{$rhash})))
    {
	if( $rhash->{$k}->{'required'} )
	{
	    # verify that it is there
	    if( !( $rhash->{$k}->{'present'} ) )
	    {
		print "Test_ReqElem_".$k.":\tnot_ok\t0/2 passed\n";
		print "\t element not found\n";
	    }
	    else
	    {
		if( !( $rhash->{$k}->{'permissions'} ))
		{
		    print "Test_ReqElem_".$k.":\tnot_ok\t1/2 passed\n";
		    print "\t element permissions incorrectly set\n";
		}
		else
		{
		    print "Test_ReqElem_".$k.":\tok\t2/2 passed\n";
		}
	    }		
	}

	if( $rhash->{$k}->{'required'} == 0 && $rhash->{$k}->{'present'} == 1 )
	{
	    if( !( $rhash->{$k}->{'permissions'} ))
	    {
		print "Test_OptElem_".$k.":\tnot_ok\t0/1 passed\n";
		print "\t element permissions incorrectly set\n";
	    }
	    else
	    {
		print "Test_OptElm_".$k.":\tok\t1/1 passed\n";
	    }
	}		
    
	
    }
}



sub run_document_validation
{
    print "\nTesting Repository Directory File Syntax and Usage\n";
    print "---------------------------------------------------------------------------\n\n";
    check_geneSeq_Bsml();
    check_promer_Bsml();
    check_blastp_Bsml();
    check_nucmer_Bsml();
    check_all_vs_all_Bsml();
    check_peffect_Bsml();
    check_regions_Bsml();
    check_fasta();
    check_SNPS_Bsml();
    check_cogs_Bsml();
}

sub check_geneSeq_Bsml
{
    print "Gene Model Schema and DTD Validation ";
    my @error_list;
    my $count = 0;

    foreach my $file ( <$project_dir/BSML_repository/*.bsml> )
    {
	if( $count % 40 == 0 ){ print "." };
	my $status = system( "$xsdValid -s $genSeqSchema $file 1>/dev/null 2>/dev/null" );

	if( $status >> 8 )
	{
	    push( @error_list, "\t$file: not valid by Schema $genSeqSchema\n" );
	}
	else
	{
	    if( !defined( $options{'skip-references'})){ check_references( $file );}
	}

	$count++;

	$status = system( "$dtdValid -d $bsmlDTD $file 1>/dev/null 2>/dev/null" );

	if( $status >> 8 )
	{
	    push( @error_list, "\t$file: not valid by DTD $bsmlDTD\n" );
	}	

	$count++;
    }

    if( my $error_count = @error_list )
    {
	my $diff = $count - $error_count;
	print "\nTest_geneSeq_Bsml_Validation:\tnot_ok\t$diff/$count passed\n";
	foreach my $err (@error_list)
	{
	    print $err;
	}
    }
    else
    {
	print "\nTest_geneSeq_Bsml_Validation:\tok\t$count/$count passed\n";
    }

}

sub check_promer_Bsml
{  
    my @files = <$project_dir/BSML_repository/promer/*.bsml>;
    my $file_count = @files;
    my @error_list;
    my $count = 0;

    if( !($file_count))
    {
	return;
    }
    else
    {
	print "Promer Search Encoding Schema and DTD Validation ";

	foreach my $file (@files)
	{
	    if( $file_count > 5 )
	    {
		if( $count % (int($file_count/5)) == 0 )
		{
		    print ".";
		}
	    }
	    else
	    {
		print ".";
	    }

	    my $status = system( "$xsdValid -s $promerSchema $file 1>/dev/null 2>/dev/null" );
	    
	    if( $status >> 8 )
	    {
		push( @error_list, "\t$file: not valid by Schema $promerSchema\n" );
	    }
	    else
	    {
		if( !defined( $options{'skip-references'})){ check_references( $file );}
	    }
	    
	    $count++;

	    $status = system( "$dtdValid -d $bsmlDTD $file 1>/dev/null 2>/dev/null" );

	    if( $status >> 8 )
	    {
		push( @error_list, "\t$file: not valid by DTD $bsmlDTD\n" );
	    }

	    $count++;
	}

	if( my $error_count = @error_list )
	{
	    my $diff = $count - $error_count;
	    print "\nTest_promer_Bsml_Validation:\tnot_ok\t$diff/$count passed\n";
	    foreach my $err (@error_list)
	    {
		print $err;
	    }
	}
	else
	{
	    print "\nTest_promer_Bsml_Validation:\tok\t$count/$count passed\n";
	}    
    }
}

sub check_blastp_Bsml
{  
    my @files = <$project_dir/BSML_repository/blastp/*.bsml>;
    my $file_count = @files;
    my @error_list;
    my $count = 0;

    if( !($file_count))
    {
	return;
    }
    else
    {
	print "Blastp Search Encoding Schema and DTD Validation ";
	
	foreach my $file (@files)
	{
	    {
		print ".";
	    }
	    
	    my $status = system( "$xsdValid -s $blastpSchema $file 1>/dev/null 2>/dev/null" );

	    if( $status >> 8 )
	    {
		push( @error_list, "\t$file: not valid by Schema $blastpSchema\n" );
	    }
	    else
	    {
		if( !defined( $options{'skip-references'})){ check_references( $file );}
	    }

	    $count++;

	    $status = system( "$dtdValid -d $bsmlDTD $file 1>/dev/null 2>/dev/null" );

	    if( $status >> 8 )
	    {
		push( @error_list, "\t$file: not valid by DTD $bsmlDTD\n" );
	    }

	    $count++;
	}

	if( my $error_count = @error_list )
	{
	    my $diff = $count - $error_count;
	    print "\nTest_blastp_Bsml_Validation:\tnot_ok\t$diff/$count passed\n";
	    foreach my $err (@error_list)
	    {
		print $err;
	    }
	}
	else
	{
	    print "\nTest_blastp_Bsml_Validation:\tok\t$count/$count passed\n";
	}    
    }
}



sub check_nucmer_Bsml
{
    my @files = <$project_dir/BSML_repository/nucmer/*.bsml>;
    my $file_count = @files;
    my @error_list;
    my $count = 0;
    
    if( !($file_count))
    {
	return;
    }
    else
    {
	print "Nucmer Search Encoding Schema and DTD Validation ";
	
	foreach my $file (@files)
	{
	    if( $file_count > 5 )
	      {
		if( $count % (int($file_count/5)) == 0 )
		{
		    print ".";
		}
	    }
	      else
	    {
		print ".";
	    }

	    my $status = system( "$xsdValid -s $nucmerSchema $file 1>/dev/null 2>/dev/null" );

	    if( $status >> 8 )
	    {
		push(@error_list, "\t$file: not valid by Schema $nucmerSchema\n" );
	    }
	    else
	    {
		if( !defined( $options{'skip-references'})){ check_references( $file );}
	    }

	    $count++;

	    $status = system( "$dtdValid -d $bsmlDTD $file 1>/dev/null 2>/dev/null" );

	    if( $status >> 8 )
	    {
		push( @error_list, "\t$file: not valid by DTD $bsmlDTD\n" );
	    }	

	    $count++;
	}

	if( my $error_count = @error_list )
	{
	    my $diff = $count - $error_count;
	    print "\nTest_nucmer_Bsml_Validation:\tnot_ok\t$diff/$count passed\n";
	    foreach my $err (@error_list)
	    {
		print $err;
	    }
	}
	else
	{
	    print "\nTest_nucmer_Bsml_Validation:\tok\t$count/$count passed\n";
	}    

    }
}

sub check_all_vs_all_Bsml
{
    my @files = <$project_dir/BSML_repository/ber/*.bsml>;
    my $file_count = @files;
    my @error_list;
    my $count = 0;

    if( !($file_count))
    {
	return;
    }
    else
    {
	print "All_vs_All Search Encoding Schema and DTD Validation ";
	foreach my $file (@files)
	{
	    if( $file_count > 5 )
	    {
		if( $count % (int($file_count/5)) == 0 )
		{
		    print ".";
		}
	    }
	    else
	    {
		print ".";
	    }

	    my $status = system( "$xsdValid -s $allvsallSchema $file 1>/dev/null 2>/dev/null" );
	    
	    if( $status >> 8 )
	    {
		push( @error_list, "\t$file: not valid by Schema $allvsallSchema\n" );
	    }
	    else
	    {
		if( !defined( $options{'skip-references'})){ check_references( $file );}
	    }
	    
	    $count++;
	    
	    $status = system( "$dtdValid -d $bsmlDTD $file 1>/dev/null 2>/dev/null" );

	    if( $status >> 8 )
	    {
		push( @error_list, "\t$file: not valid by DTD $bsmlDTD\n" );
	    }	
	    
	    $count++;
	}

	if( my $error_count = @error_list )
	{
	    my $diff = $count - $error_count;
	    print "\nTest_all_vs_all_Bsml_Validation:\tnot_ok\t$diff/$count passed\n";
	    foreach my $err (@error_list)
	    {
		print $err;
	    }
	}
	else
	{
	    print "\nTest_all_vs_all_Bsml_Validation:\tok\t$count/$count passed\n";
	}    
    }
}

sub check_peffect_Bsml
{    
    my @files = <$project_dir/BSML_repository/PEffect/*.bsml>;
    my $file_count = @files;
    my @error_list;
    my $count = 0;

    if( !($file_count))
    {
	return;
    }
    else
    {
	print "PEffect Search Encoding Schema and DTD Validation ";

	foreach my $file (@files)
	{
	    if( $file_count > 5 )
	    {
		if( $count % (int($file_count/5)) == 0 )
		{
		    print ".";
		}
	    }
	    else
	    {
		print ".";
	    }

	    my $status = system( "$xsdValid -s $peffectSchema $file 1>/dev/null 2>/dev/null" );

	    if( $status >> 8 )
	    {
		push( @error_list, "\t$file: not valid by Schema $peffectSchema\n" );
	    }
	    else
	    {
		if( !defined( $options{'skip-references'})){ check_references( $file );}
	    }
	    
	    $count++;

	    $status = system( "$dtdValid -d $bsmlDTD $file 1>/dev/null 2>/dev/null" );

	    if( $status >> 8 )
	    {
		push( @error_list, "\t$file: not valid by DTD $bsmlDTD\n" );
	    }	

	    $count++;
	}

	if( my $error_count = @error_list )
	{
	    my $diff = $count - $error_count;
	    print "\nTest_PEffect_Bsml_Validation:\tnot_ok\t$diff/$count passed\n";
	    foreach my $err (@error_list)
	    {
		print $err;
	    }
	}
	else
	{
	    print "\nTest_PEffect_Bsml_Validation:\tok\t$count/$count passed\n";
	}    
    }
}

sub check_regions_Bsml
{
    my @files = <$project_dir/BSML_repository/Region/*.bsml>;
    my $file_count = @files;
    my @error_list;
    my $count = 0;

    if( !($file_count))
    {
	return;
    }
    else
    {
	print "Regions Search Encoding Schema and DTD Validation ";
	foreach my $file (@files)
	{
	    if( $file_count > 5 )
	    {
		if( $count % (int($file_count/5)) == 0 )
		{
		    print ".";
		}
	    }
	    else
	    {
		print ".";
	    }
	    
	    my $status = system( "$xsdValid -s $regionsSchema $file 1>/dev/null 2>/dev/null" );

	    if( $status >> 8 )
	    {
		push(@error_list,  "\t$file: not valid by Schema $regionsSchema\n");
	    }
	    else
	    {
		if( !defined( $options{'skip-references'})){ check_references( $file );}
	    }
	    
	    $count++;

	    $status = system( "$dtdValid -d $bsmlDTD $file 1>/dev/null 2>/dev/null" );

	    if( $status >> 8 )
	    {
		push(@error_list, "\t$file: not valid by DTD $bsmlDTD\n");
	    }	

	    $count++;
	}

	if( my $error_count = @error_list )
	{
	    my $diff = $count - $error_count;
	    print "\nTest_Regions_Bsml_Validation:\tnot_ok\t$diff/$count passed\n";
	    foreach my $err (@error_list)
	    {
		print $err;
	    }
	}
	else
	{
	    print "\nTest_Regions_Bsml_Validation:\tok\t$count/$count passed\n";
	}    
    }
}

sub check_fasta
{ 
    my @files = <$project_dir/FASTA_repository/*.fsa>;
    my $file_count = @files;
    my @error_list;
    my $count = 0;
    
    if( !($file_count))
    {
	return;
    }
    else
    {
	print "Assembly FASTA cleanFasta validation ";
	
	foreach my $file (@files)
	{
	    print ".";
	    
	    $status = system( "cleanFasta -check $file 1>/dev/null 2>/dev/null" );
	    
	    if( (my $err = $status >> 8) != 3 )
	    {
		push( @error_list, "\t$file: not valid by cleanFasta (ERROR Code: $err)\n" );
	    }	
	    
	    $count++;
	}
    }

    if( my $error_count = @error_list )
    {
	my $diff = $count - $error_count;
	print "\nTest_Fasta_FSA_Validation:\tnot_ok\t$diff/$count passed\n";
	foreach my $err (@error_list)
	{
	    print $err;
	}
    }
    else
    {
	print "\nTest_Fasta_FSA_Validation:\tok\t$count/$count passed\n";
    }    
	    
    my @files = <$project_dir/BSML_repository/*.pep>;
    my $file_count = @files;
    my @error_list = ();
    my $count = 0;

    if( !($file_count))
    {
	return;
    }
    else
    {
	print "Protein FASTA cleanFasta validation ";

	foreach my $file (@files)
	{
	    print ".";
	    
	    $status = system( "cleanFasta -check $file 1>/dev/null 2>/dev/null" );
	    
	    if( (my $err = $status >> 8) != 3 )
	    {
		push( @error_list, "\t$file: not valid by cleanFasta (ERROR Code: $err)\n" );
	    }

	    $count++;
	}

	  if( my $error_count = @error_list )
	  {
	      my $diff = $count - $error_count;
	      print "\nTest_Fasta_PEP_Validation:\tnot_ok\t$diff/$count passed\n";
	      foreach my $err (@error_list)
	      {
		  print $err;
	      }
	  }
	else
	{
	    print "\nTest_Fasta_PEP_Validation:\tok\t$count/$count passed\n";
	}    
    }
}

sub check_SNPS_Bsml
{    
    my @files = <$project_dir/BSML_repository/snps/*.bsml>;
    my $file_count = @files;
    my @error_list = ();
    my $count = 0;

    if( !($file_count))
    {
	return;
    }
    else
    {
	print "SNPS Search Encoding Schema and DTD Validation ";
	foreach my $file (@files)
	{
	    print ".";
	    
	    $status = system( "$dtdValid -d $bsmlDTD $file 1>/dev/null 2>/dev/null" );
	    
	    if( $status >> 8 )
	    {
		push(@error_list, "\t$file: not valid by DTD $bsmlDTD\n");
	    }	

	    $count++;
	}
	
	if( my $error_count = @error_list )
	{
	    my $diff = $count - $error_count;
	    print "\nTest_SNPS_Bsml_Validation:\tnot_ok\t$diff/$count passed\n";
	    foreach my $err (@error_list)
	    {
		print $err;
	    }
	}
	else
	{
	    print "\nTest_SNPS_Bsml_Validation:\tok\t$count/$count passed\n";
	}    
    }
}

sub check_cogs_Bsml
{ 
    my @files = <$project_dir/BSML_repository/cogs/*.bsml>;
    my $file_count = @files;
    my @error_list = ();
    my $count = 0;
    
    if( !($file_count))
    {
	return;
    }
    else
    {
	print "COGS Search Encoding Schema and DTD Validation ";

	foreach my $file (@files)
	{
	    print ".";
	    
	    $status = system( "$dtdValid -d $bsmlDTD $file 1>/dev/null 2>/dev/null" );
	    
	    if( $status >> 8 )
	    {
		push( @error_list, "\t$file: not valid by DTD $bsmlDTD\n" );
	    }	

	    $count++;
	}

	if( my $error_count = @error_list )
	{
	    my $diff = $count - $error_count;
	    print "\nTest_COGS_Bsml_Validation:\tnot_ok\t$diff/$count passed\n";
	    foreach my $err (@error_list)
	    {
		print $err;
	    }
	}
	else
	{
	    print "\nTest_COGS_Bsml_Validation:\tok\t$count/$count passed\n";
	}    
    }
}

sub check_checksums
{
    print "\nPerforming Checksum Validation\n";
    print "---------------------------------------------------------------------------\n";

    my $dirlist = [ '', 'promer/', 'blastp/', 'nucmer/', 'ber/', 'PEffect/', 'Region/', 'snps/', 'cogs/' ];  

    foreach my $dir (@{$dirlist})
    {
	my @error_list = ();
	my $count = 0;

	my $clean_name = $dir;
	$clean_name =~ s/\///;

	$status = system( "ls $project_dir/BSML_repository/".$dir."CHECKSUM.sum 1>/dev/null 2>/dev/null" );
	$count++;

	if( $status >> 8 )
	{
	    push( @error_list, "\t$project_dir/BSML_repository/".$dir."CHECKSUM.sum not available\n" );
	}	
	else
	{
	    my $status2 = system( "ls $project_dir/BSML_repository/".$dir."CHECKSUM 1>/dev/null 2>/dev/null" );
	    $count++;
	    if( $status2 >> 8 )
	    {
		push( @error_list, "\t$project_dir/BSML_repository/".$dir."CHECKSUM not available\n" );
	    }	
	    else
	    {
		open( INFILE, "$project_dir/BSML_repository/".$dir."CHECKSUM.sum" ) or die "Could not open $project_dir/BSML_repository/".$dir."CHECKSUM.sum\n";
		my ($filename, $checksum) = split( "\t", <INFILE> );
		close( INFILE );
		
		my $dyn_checksum = `/usr/local/bin/md5 $filename`;

		$count++;

		if( !($dyn_checksum eq $checksum) )
		{
		    push( @error_list, "\t Not OK: $project_dir/BSML_repository/".$dir."CHECKSUM has out of sync checksum\n" );
		}
		else
		{
		    my $ok = 1;
		    open( INFILE, "$project_dir/BSML_repository/".$dir."CHECKSUM" ) or die "Could not open $project_dir/BSML_repository/".$dir."CHECKSUM\n";
		    while( my ($filename, $checksum) = split( "\t", <INFILE> ))
		    {
			my $dyn_checksum = `/usr/local/bin/md5 $filename`;
			$count++;
			if( !($dyn_checksum eq $checksum) )
			{
			    push( @error_list,  "\t$filename has out of sync checksum\n" );
			    $ok = 0;
			}
		    }
		    close( INFILE );
		}
	    }
	}
	
	my $diff = $count - @error_list;
	
	if( !( $clean_name ) )
	{
	    $clean_name = 'geneSeq';
	}

	if( $diff < $count )  
	{ 
	    print "Test_".$clean_name."_checksum_validation\tnot_ok\tpassed $diff/$count\n";
	    foreach my $err ( @error_list )
	    {
		print $err;
	    }
	}
	else
	{ 
	    print "Test_".$clean_name."_checksum_validation\tok\tpassed $diff/$count\n";
	}
    }
}

my $ref_check_count = 0;
my $ref_error_count = 0;
my @ref_error_list = ();
my $ref_current_file = '';


sub check_references
{
    my $file = shift;
    $ref_current_file = $file;
    $ref_parser->parse( $file );    
}

sub check_referencial_integrity
{
    print "\nPerforming Referencial Integrity Checks\n";
    print "---------------------------------------------------------------------------\n";

    if( $ref_error_count )
    {
	my $passed = $ref_check_count - $ref_error_count;
	print "Test_Referencial_Integrity:\tnot ok\tpassed $passed/$ref_check_count\n";

	foreach my $err (@ref_error_list)
	{
	    print $err;
	}
    }
    else
    {
	my $passed = $ref_check_count - $ref_error_count;
	print "Test_Referencial_Integrity:\tok\tpassed $passed/$ref_check_count\n";
    }
}

sub sequenceCheck
{
    my $seqref = shift;
    my $reader = new BSML::BsmlReader;

    my $source = $seqref->{'BsmlSeqDataImport'}->{'source'};

    if( $source )
    {
	$ref_check_count++;

	my $status = system( "ls $source 1>/dev/null 2>/dev/null" );
	if( $status >> 8 )
	{
	    $ref_error_count++;
	    push( @ref_error_list, "$ref_current_file: Invalid SequenceImport Ref.  $seqref->{'BsmlSeqDataImport'}->{'source'}  $seqref->{'BsmlSeqDataImport'}->{'id'}\n");
	}
	
    }
    
}
    
