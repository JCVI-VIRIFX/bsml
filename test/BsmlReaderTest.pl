#! /local/perl/bin/perl

use lib "../src/";
use BSML::BsmlReader;
use BSML::BsmlParserTwig;
use Data::Dumper; 

print "Program begin...\n";

my $reader = new BSML::BsmlReader;
my $parser = new BSML::BsmlParserTwig;

print "Started Parsing...\n";
$parser->parse( \$reader, $ARGV[0] );
print "Done.\n";

# print "Program end...\n";
