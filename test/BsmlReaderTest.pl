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
$aahash = $reader->get_all_alignments();
print "Done.\n";

print "Cleaning up Reader\n";
$reader = undef;
print "Done\n";

print "Data Dumper...\n";
print Dumper(%{$aahash}->{'1'});
print "Done\n";

print "Program end...\n";
exit(1);
