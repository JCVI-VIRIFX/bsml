#! /local/perl/bin/perl

use lib "../src/";
use BsmlReader;
use BsmlParserTwig;
use Data::Dumper;

my $reader = new BsmlReader;
my $parser = new BsmlParserTwig;

$parser->parse( \$reader, $ARGV[0] );
foreach $gene (sort($reader->returnAllFeatureGroupSetIds()))
  {
    print "$gene\n";
  }
