#!/local/perl/bin/perl -w

# ------------------------------------------------------------------
# createTrivialScaffoldFiles.pl
#
# Creates a set of scaffold files to be used as input to 
# createBsmlScaffolds.pl; one file will be created for each 
# organism in the input chado database, with an entry for each
# assembly for which a scaffold has not already been added to
# the BSML repository.
# 
# Example usage:
#
# ./createTrivialScaffoldFiles.pl --bsml_repository=/usr/local/annotation/TRYP2/BSML_repository --chado_db=tryp2 --chado_server=SYBTIGR --username=username --password=password
#
# Jonathan Crabtree <crabtree@tigr.org>
#
# Created: Fri Aug 13 10:46:17 EDT 2004
# ------------------------------------------------------------------

use strict;

use DBI;
use FileHandle;
use Getopt::Long;
use Pod::Usage;

# ------------------------------------------------------------------
# Input
# ------------------------------------------------------------------

my($bsmlRepository, $chadoDb, $chadoServer, $username, $password, $help, $man);

&GetOptions("chado_db=s" => \$chadoDb, 
	    "bsml_repository=s" => \$bsmlRepository,
	    "chado_server=s" => \$chadoServer,
	    "username=s" => \$username,
	    "password=s" => \$password,
	    "help" => \$help,
	    "man" => \$man,
	    );

pod2usage(1) if $help;
pod2usage({-verbose => 2}) if $man;

if (!$bsmlRepository || !(-d $bsmlRepository) || !(-r $bsmlRepository)) {
    pod2usage({-message => "Error:\n     --bsml_repository is not valid\n", -exitstatus => 0, -verbose => 0});
}

pod2usage({-message => "Error:\n     --chado_server must be specified\n", -exitstatus => 0, -verbose => 0}) if (!$chadoServer);
pod2usage({-message => "Error:\n     --chado_db must be specified\n", -exitstatus => 0, -verbose => 0}) if (!$chadoDb);
pod2usage({-message => "Error:\n     --username must be specified\n", -exitstatus => 0, -verbose => 0}) if (!$username);
pod2usage({-message => "Error:\n     --password must be specified\n", -exitstatus => 0, -verbose => 0}) if (!$password);

# ------------------------------------------------------------------
# Main program
# ------------------------------------------------------------------

$| = 1;

# read assembly names from the BSML_repository
my $bsmlScaffoldDir = $bsmlRepository . "/scaffolds";
my $fileNames = &readAssemblyNamesFromScaffoldFiles($bsmlScaffoldDir);
print "Read ", scalar(@$fileNames), " assemblies from $bsmlScaffoldDir\n";

# read assembly names and lengths from the database
my $dbiDsn = "DBI:Sybase:server=$chadoServer;packetSize=8192";
my $chadoAssems = &readAssembliesFromChadoDb($dbiDsn, $username, $password, $chadoDb);
print "Read ", scalar(@$chadoAssems), " assemblies from $chadoDb\n";

# get list of assemblies that are not already in a scaffold
my $fh = {};
map { $fh->{$_} = 1; } @$fileNames;
my $assemblies = [];
map { push(@$assemblies, $_) if (!defined($fh->{$_->{'name'}})); } @$chadoAssems;
print "Generating trivial scaffolds for ", scalar(@$assemblies), " assemblies\n";

# group by organism/database
my $assemsByDb = {};
foreach my $assem (@$assemblies) {
    my($db) = ($assem->{'name'} =~ /^([^_]+)\_/);
    my $list = $assemsByDb->{$db};
    $list = $assemsByDb->{$db} = [] if (!defined($list));
    push(@$list, $assem);
}

# create a scaffold file (in the cwd) for each organism that needs one
foreach my $db (keys %$assemsByDb) {
    my $assems = $assemsByDb->{$db};
    my $scaffoldFile = "${db}.trivial.scaffolds";
    print "Generating $scaffoldFile with ", scalar(@$assems), " $db assemblies\n";
    my $fh = FileHandle->new();
    $fh->open(">$scaffoldFile") || die "unable to write to $scaffoldFile";
    
    foreach my $assem (@$assems) {
	my($asmblId) = ($assem->{'name'} =~ /_(\d+)_assembly/);
	my $asmblLen = $assem->{'length'};
	$fh->printf("SCF %10s %10s %5s F     0     0 %10s %10s %10s\n", $asmblId, $asmblId, '1', $asmblLen, 0, $asmblLen);
    }

    $fh->close();
}

# all done
exit(0);

# ------------------------------------------------------------------
# Subroutines
# ------------------------------------------------------------------

# Returns a listref of those assemblies (by assembly name) already included in a scaffold.
#
sub readAssemblyNamesFromScaffoldFiles {
    my($bsmlScaffoldDir) = @_;
    my $names = [];

    my $cmd = "find $bsmlScaffoldDir -name '*.bsml' -exec grep '_assembly' '{}' ';' |";
    my $fh = FileHandle->new();
    $fh->open($cmd);
    while (my $line = <$fh>) {
	if ($line =~ /id=\"(\S+_assembly)\"/) {
	    push(@$names, $1);
	} else {
	    die "could not parse output of find command: '$line'";
	}
    }
    $fh->close();
    return $names;
}

# Returns a listref of assembly sequence names in $chadoDb.
#
sub readAssembliesFromChadoDb {
    my($dbiDsn, $username, $password, $chadoDb) = @_;
    my $sql = "select f.uniquename, f.seqlen " .
	"from ${chadoDb}..feature f, ${chadoDb}..cvterm cv " .
	"where f.type_id = cv.cvterm_id " .
	"and cv.name = 'assembly' ";

    my $assemblies = [];

    my $dbh = DBI->connect($dbiDsn, $username, $password);
    my $sth = $dbh->prepare($sql);
    $sth->execute();
    while(my($name, $seqlen) = $sth->fetchrow_array()) {
	push(@$assemblies, {'name' => $name, 'length' => $seqlen}); 
    }
    $sth->finish();
    $dbh->disconnect();

    return $assemblies;
}

__END__

=head1 NAME
    
    createTrivialScaffoldFiles.pl
    
=head1 SYNOPSIS
    
  createBsmlScaffolds.pl [options]
    
  Options:
    --chado_db                  name of target chado database (into which the scaffolds will be imported)
    --bsml_repository           location of the BSML_repository that corresponds to --chado_db
    --chado_server              logical name of the Sybase server that hosts --chado_db
    --username                  Sybase login
    --password                  Sybase password
    --help                      print help/usage
    --man                       print manual page
    
=head1 OPTIONS
    
=over 8

=item B<--chado_db>
    
    Name of the chado database into which the scaffolds will be loaded.

=item B<--bsml_repository>

    Root BSML_repository directory that corresponds to --chado_db.

=item B<--chado_server>

    Name of the Sybase server where --chado_db resides.

=item B<--username>

    Sybase login for --chado_server.

=item B<--password>

    Password that corresponds to --username.

=item B<--help>
    
    Print a brief help message and exit.

=item B<--man>
    
    Print a manual page and exit.
     
=back

=head1 DESCRIPTION
    
    

=cut
