#! /local/perl/bin/perl

my $file = $ARGV[0];
my $schema = $ARGV[1];

$schema =~ s/\//\\\//g;

system "sed -e \'s/<\\!DOCTYPE Bsml PUBLIC \"-\\/\\/EBI\\/\\/Labbook, Inc. BSML DTD\\/\\/EN\" \"http:\\/\\/www.labbook.com\\/dtd\\/bsml3_1.dtd\">//\' -e \'s/<Bsml>/<Bsml xmlns:xsi=\"http:\\/\\/www.w3.org\\/2001\\/XMLSchema-instance\" xsi:noNamespaceSchemaLocation=\"$schema\">/\' $file | ./Xerces-xsdValid";

