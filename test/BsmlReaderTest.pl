#! /local/perl/bin/perl

use lib "../src/";
use BsmlReader;
use BsmlParserTwig;
use Data::Dumper;

my $reader = new BsmlReader;
my $parser = new BsmlParserTwig;

$parser->parse( \$reader, $ARGV[0] );

my $rhash = $reader->get_all_protein_dna_extended( 'PNEUMO_19', 300 );

foreach $key (sort(keys(%{$rhash})) )
  {
    print ">$key\n".$rhash->{$key}."\n";
  }
