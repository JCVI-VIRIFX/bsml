#!/local/perl/bin/perl -w

# ------------------------------------------------------------------
# createBsmlScaffolds.pl
#
# Creates a set of BSML scaffold documents based on the scaffold
# information in a file produced (presumably) by the Celera 
# assembler.
# 
# Example usage:
# ./createBsmlScaffolds.pl --chado_db=tryp2 --bsml_repository=/usr/local/annotation/TRYP2/BSML_repository --scaffold_file=/usr/local/projects/TCRG/CA_10_31_2003/scaff.info.plus.new.myco.free --using_contig_ids --annot_db=tca1 --annot_server=SYBTIGR --organism_name='Trypanosoma cruzi' --username=username --password=password
#
# Jonathan Crabtree <crabtree@tigr.org>
#
# Created: Thu Aug 12 14:09:40 EDT 2004
# ------------------------------------------------------------------

# TO DO - make some use of gap_mean and gap_std

use strict;

use DBI;
use FileHandle;
use Getopt::Long;
use Pod::Usage;

use BsmlScaffolds;
use lib "../"; # assumes the script is run from within the "test/" subdirectory
use BSML::BsmlBuilder;
use BSML::BsmlReader;
use BSML::BsmlParserTwig;

# ------------------------------------------------------------------
# Input
# ------------------------------------------------------------------

my($bsmlRepository, $workflowId, $scaffoldFile, $usingContigIds, $chadoDb, $annotDb, 
   $annotServer, $orgName, $parseGaps, $username, $password, $parseOnly, $help, $man);

&GetOptions("chado_db=s" => \$chadoDb, 
	    "bsml_repository=s" => \$bsmlRepository,
	    "workflow_id=s" => \$workflowId,
	    "scaffold_file=s" => \$scaffoldFile,
	    "using_contig_ids!" => \$usingContigIds,
	    "annot_db=s" => \$annotDb,
	    "annot_server=s" => \$annotServer,
	    "organism_name=s" => \$orgName,
	    "parse_gaps!" => \$parseGaps,
	    "username=s" => \$username,
	    "password=s" => \$password,
	    "parse_only!" => \$parseOnly,
	    "help" => \$help,
	    "man" => \$man,
	    );

pod2usage(1) if $help;
pod2usage({-verbose => 2}) if $man;

if (!$bsmlRepository || !(-d $bsmlRepository) || !(-r $bsmlRepository)) {
    pod2usage({-message => "Error:\n     --bsml_repository is not valid\n", -exitstatus => 0, -verbose => 0});
}
if (!$scaffoldFile || !(-e $scaffoldFile) || !(-r $scaffoldFile)) {
    pod2usage({-message => "Error:\n     --scaffold_file is not valid\n", -exitstatus => 0, -verbose => 0});
}
pod2usage({-message => "Error:\n     --chado_db must be specified\n", -exitstatus => 0, -verbose => 0}) if (!$chadoDb);
pod2usage({-message => "Error:\n     --annot_db must be specified\n", -exitstatus => 0, -verbose => 0}) if (!$annotDb);
pod2usage({-message => "Error:\n     --annot_server must be specified\n", -exitstatus => 0, -verbose => 0}) if (!$annotServer);
pod2usage({-message => "Error:\n     --organism_name must be specified\n", -exitstatus => 0, -verbose => 0}) if (!$orgName);

# only need database login to convert contig_ids to asmbl_ids
if ($usingContigIds) {
    pod2usage({-message => "Error:\n     --username must be specified\n", -exitstatus => 0, -verbose => 0}) if (!$username);
    pod2usage({-message => "Error:\n     --password must be specified\n", -exitstatus => 0, -verbose => 0}) if (!$password);
}

my($genus, $species);
if ($orgName =~ /^\s*(\S+) (\S+)\s*$/) {
    $genus = $1;
    $species = $2;
} else {
    pod2usage({-message => "Error:\n     --organism_name must be specified as 'Genus species'\n", -exitstatus => 0, -verbose => 0});
}

# ------------------------------------------------------------------
# Main program
# ------------------------------------------------------------------

$| = 1;

# read scaffolds from flat file
my $scaffolds = &readScaffoldsFromFlatFile($scaffoldFile);
my $nContigs = 0;
my $chash = {};
map { $nContigs += scalar(@{$_->{'data'}}); } @$scaffolds;
print "Read ", scalar(@$scaffolds), " scaffold(s) and $nContigs contig(s) from $scaffoldFile\n";

# using contig ids: read contig_id -> asmbl_id mapping from --annot_db
if ($usingContigIds) {
    my $dbiDsn = "DBI:Sybase:server=$annotServer;packetSize=8192";
    my $contig2Asmbl = &readContigToAsmblMapping($dbiDsn, $username, $password, $annotDb);
    print "Read ", scalar(keys(%$contig2Asmbl)), " asmbl_ids from $annotDb database\n";

    # map contig_ids to asmbl_ids
    foreach my $s (@$scaffolds) {
	foreach my $c (@{$s->{'data'}}) {
	    my $asmblId = $contig2Asmbl->{$c->{'contig_id'}};
	    if (!defined($asmblId)) {
		die "unable to map contig_id $c->{'contig_id'} to asmbl_id";
	    } else {
		$c->{'asmbl_id'} = $asmblId;
	    }
	}
    }
} 
# otherwise the contig_id is the same as the asmbl_id
else {
    foreach my $s (@$scaffolds) {
	foreach my $c (@{$s->{'data'}}) {
	    $c->{'asmbl_id'} = $c->{'contig_id'};
	}
    }
}

# write BSML files
&BsmlScaffolds::writeBsmlScaffoldFiles($scaffolds, $annotDb, $chadoDb, $bsmlRepository, $workflowId, $genus, $species, 1, $parseGaps, $parseOnly);

# all done
exit(0);

# ------------------------------------------------------------------
# Subroutines
# ------------------------------------------------------------------

# Returns a listref of scaffolds read from the tab-delimited flat file.
#
sub readScaffoldsFromFlatFile {
    my($filename) = @_;
    my $scaffIdToContigs = {};
    my $contigIds = {}; # used to check that contig ids are unique

    my $fh = FileHandle->new();
    $fh->open($filename, 'r') || return undef;
    my $lnum = 0;
    while (my $line = <$fh>) {
	++$lnum; chomp($line);
	# skip whitespace
	next if ($line =~ /^\s*$/);
	# could just split on /\s+/, but this adds some error-checking
	if ($line =~ /^SCF\s+(\d+)\s+(\S+)\s+(\d+)\s+(F|R)\s+(-?\d+)\s+(\d+)\s+(\d+)\s+(\d+)\s+(\d+)$/) {
	    my $data = {
		'contig_id' => $1,
		'scaff_id' => $2,
		'scaff_order' => $3,
		'direction' => $4,
		'gap_mean' => $5,
		'gap_std' => $6,
		'contig_len' => $7,
		'contig_start' => $8,
		'contig_end' => $9,
	    };
	    my $scaffId = $2;  # scaff_id = clone_info..gb_acc
	    my $contigId = $1; # contig_id = clone_info..clone_name

	    my $list = $scaffIdToContigs->{$scaffId};
	    if (!defined($list)) { $list = $scaffIdToContigs->{$scaffId} = []; }
	    push(@$list, $data);
	    if (defined($contigIds->{$contigId})) {
		die "contig_id $contigId is duplicated at line $lnum";
	    } else {
		$contigIds->{$contigId} = 1;
	    }
	} else {
	    die "unable to parse line $lnum of $filename: $line";
	}
    }
    $fh->close();
    print "Read $lnum lines from $filename\n";

    # process scaffolds
    my $scaffolds = [];

    foreach my $scaffId (keys %$scaffIdToContigs) {
	my $contigs = $scaffIdToContigs->{$scaffId};
	my @sorted = sort { $a->{'scaff_order'} <=> $b->{'scaff_order'}} @$contigs;
	push(@$scaffolds, { 'scaff_id' => $scaffId, 'data' => \@sorted });
    }
    
    return $scaffolds;
}

# Read contig_id -> asmbl_id mapping from annot_db.
#
sub readContigToAsmblMapping {
    my($dbiDsn, $username, $password, $annotDb) = @_;
    my $mapping = {};
    my $sql = "select distinct clone_name, asmbl_id from ${annotDb}..clone_info where asmbl_id is not null";

    my $dbh = DBI->connect($dbiDsn, $username, $password);
    my $sth = $dbh->prepare($sql);
    $sth->execute();
    while(my($contigId, $asmblId) = $sth->fetchrow_array()) {
	my $currVal = $mapping->{$contigId};
	if (defined($currVal) && ($currVal ne $asmblId)) {
	    die "clone_name $contigId maps to multiple distinct asmbl_ids in $annotDb";
	} else {
	    $mapping->{$contigId} = $asmblId;
	}
    }
    $sth->finish();
    $dbh->disconnect();

    return $mapping;
}

__END__

=head1 NAME
    
    createBsmlScaffolds.pl
    
=head1 SYNOPSIS
    
  createBsmlScaffolds.pl [options]
    
  Options:
    --chado_db                  name of target chado database (into which the scaffolds will be imported)
    --bsml_repository           location of the BSML_repository that corresponds to --chado_db
    --scaffold_file             tab-delimited file that contains the scaffold information
    --using_contig_ids          use this option if --scaffold_file uses contig_ids instead of asmbl_ids
    --annot_db                  euk/prok annotation database from which the scaffolded contigs are drawn
    --organism_name             organism name that corresponds to --annot_db, in the form "Genus species"
    --annot_server              logical name of the Sybase server that hosts --annot_db
    --username                  Sybase login
    --password                  Sybase password
    --parse_only                Read/check BSML files but do not generate target scaffold BSML files.
    --help                      print help/usage
    --man                       print manual page
    
=head1 OPTIONS
    
=over 8

=item B<--chado_db>
    
    Name of the chado database into which the scaffolds will be loaded.

=item B<--bsml_repository>

    Root BSML_repository directory that corresponds to --chado_db.

=item B<--scaffold_file>

    Tab-delimited file that contains the scaffold information.

=item B<--using_contig_ids>

    Specify this option if --scaffold_file uses contig_ids instead of asmbl_ids.

=item B<--annot_db>

    Name of the TIGR euk/prok annotation database where the scaffolded contigs can be found.

=item B<--annot_server>

    Name of the Sybase server where --annot_db resides.

=item B<--organism_name>

    Organism name that corresponds to --annot_db, in the form "Genus species"

=item B<--username>

    Sybase login for --annot_server.

=item B<--password>

    Password that corresponds to --username.

=item B<--parse_only>

    Read/check BSML files but do not generate target scaffold BSML files.

=item B<--help>
    
    Print a brief help message and exit.

=item B<--man>
    
    Print a manual page and exit.
     
=back

=head1 DESCRIPTION
    
    

=cut
