#! /local/perl/bin/perl

use lib "../src/";
use BSML::BsmlReader;
use BSML::BsmlParserTwig;
use Data::Dumper; 

my $reader = new BSML::BsmlReader;
my $parser = new BSML::BsmlParserTwig;

$parser->parse( \$reader, $ARGV[0] );

$aahash = $reader->returnAllIdentifiers();

print $aahash->{'gpa_1200_assembly'}->{'gpa_ORF01130_ORF'}->{'gpa_ORF01130_ORFtmp_transcript'}->{'featureGroupId'};
print "\nBsml21582\n";
