#! /local/perl/bin/perl

use Getopt::Long qw(:config no_ignore_case no_auto_abbrev);

my %options = ();

my $results = GetOptions( \%options, 'schema|s=s', 'help|h' );

if( $options{'help'} )
{
    
    print "\nxsdValid.pl validates xml documents using a user specified schema.\n\n";
    print "Usage:    ./xsdValid.pl -s schema.xsd file.xml\n\n";
    print "Options:\n    --schema | -s   : the file path to the schema\n";
    print "    --help | -h   : this message\n\n";
    print "Output:\n    Nothing if validation is successful\n";
    print "    XML Schema errors if validation is unsuccessful\n\n\n";

    exit(4);
}

my $file = $ARGV[0];

my $schema = $options{'schema'};

$schema =~ s/\//\\\//g;

my ($dir) = ($0 =~ /(.*)\/.*/);

system "sed -e \'s/<\\!DOCTYPE Bsml PUBLIC \"-\\/\\/EBI\\/\\/Labbook, Inc. BSML DTD\\/\\/EN\" \"http:\\/\\/www.labbook.com\\/dtd\\/bsml3_1.dtd\">//\' -e \'s/<Bsml>/<Bsml xmlns:xsi=\"http:\\/\\/www.w3.org\\/2001\\/XMLSchema-instance\" xsi:noNamespaceSchemaLocation=\"$schema\">/\' $file | $dir/Xerces-xsdValid";

