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

print "Cleaning up Parser...\n";
$parser = undef;
print "Done.\n";

print "Reading Alignments...\n";
my $analysis = $reader->readAnalysis( $reader->returnAllAnalysis->[0] );


print Dumper( %{$analysis} );

print "Program end...\n";
