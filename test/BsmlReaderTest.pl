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
$aahash = $reader->get_all_alignment_references();
print "Done.\n";

for( my $i=0; $i<$aahash->{'count'}; $i++ )
{
    my $href = $reader->readSeqPairAlignment( $aahash->{$i} );

    print Dumper( $href );
}

print "Program end...\n";
