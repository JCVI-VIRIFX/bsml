#! /local/perl/bin/perl

use Getopt::Long qw(:config no_ignore_case no_auto_abbrev);

my %options = ();
my $results = GetOptions( \%options, 'dtd|d=s', 'help|h' );

if( $options{'help'} || !($ARGV[0]) )
{
    print "\ndtdValid.pl validates xml documents using an inline or user specified dtd.\n\n";
    print "Usage:    ./dtdValid.pl -d file.dtd source.xml\n\n";
    print "Options:\n    --dtd | -d   : the file path to the user specified dtd (optional)\n";
    print "    --help | -h   : this message\n\n";
    print "Output:\n    Nothing if validation is successful\n";
    print "    XML Schema errors if validation is unsuccessful\n\n\n";

    exit(4);
}

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

