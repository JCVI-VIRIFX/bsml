#! /local/perl/bin/perl

use lib "../src/";
use BsmlReader;
use BsmlParserTwig;
use Data::Dumper;

my $reader = new BsmlReader;
my $parser = new BsmlParserTwig;

$parser->parse( \$reader, $ARGV[0] );

my $aa_seqs = $reader->get_all_protein_aa( 'PNEUMO_19' );

foreach my $id (keys %{$aa_seqs})
  {
    print ">$id\n".$aa_seqs->{$id}."\n";
  }
