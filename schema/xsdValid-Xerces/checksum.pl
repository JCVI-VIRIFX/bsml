#! /local/perl/bin/perl

use Getopt::Long qw(:config no_ignore_case no_auto_abbrev);

my %options = ();

my $results = GetOptions( \%options, 'filelist|f=s', 'outfile|o=s', 'help|h' );

open( OUTFILE, ">$options{'outfile'}" ) or die "Could not open $options{'outfile'}\n";

if( $options{'filelist'} )
{
    open( INFILE, $options{'filelist'} ) or die "Could not open $options{'filelist'}\n";

    while( my $line = <INFILE> )
    {
	chomp $line;

	my $checksum = `/usr/local/bin/md5 $line`;
	
	print OUTFILE "$line\t$checksum";
    }
}
else
{
    while( my $line = <STDIN> )
    {
	chomp $line;

	my $checksum = `/usr/local/bin/md5 $line`;
	
	print OUTFILE "$line\t$checksum";
    }
}

