#! /local/perl/bin/perl

use Getopt::Long qw(:config no_ignore_case no_auto_abbrev);

my %options = ();
my $results = GetOptions( \%options, 'dtd|d=s' );

my $file = $ARGV[0];
my $dtd = $options{'dtd'};

my ($dir) = ($0 =~ /(.*)\/.*/);

if( $dtd )
{
    $dtd =~ s/\//\\\//g;
    system "sed -e \'s/<\\!DOCTYPE Bsml PUBLIC \"-\\/\\/EBI\\/\\/Labbook, Inc. BSML DTD\\/\\/EN\" \"http:\\/\\/www.labbook.com\\/dtd\\/bsml3_1.dtd\">/<\\!DOCTYPE Bsml SYSTEM \"$dtd\">/\' $file | $dir/Xerces-xsdValid";
}

else
{
    system "more $file | $dir/Xerces-xsdValid";
}

