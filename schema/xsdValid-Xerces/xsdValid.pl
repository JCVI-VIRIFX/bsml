#! /local/perl/bin/perl

use Getopt::Long qw(:config no_ignore_case no_auto_abbrev);

my %options = ();

my $results = GetOptions( \%options, 'schema|s=s' );

my $file = $ARGV[0];

my $schema = $options{'schema'};

$schema =~ s/\//\\\//g;

system "sed -e \'s/<\\!DOCTYPE Bsml PUBLIC \"-\\/\\/EBI\\/\\/Labbook, Inc. BSML DTD\\/\\/EN\" \"http:\\/\\/www.labbook.com\\/dtd\\/bsml3_1.dtd\">//\' -e \'s/<Bsml>/<Bsml xmlns:xsi=\"http:\\/\\/www.w3.org\\/2001\\/XMLSchema-instance\" xsi:noNamespaceSchemaLocation=\"$schema\">/\' $file | ./Xerces-xsdValid";

