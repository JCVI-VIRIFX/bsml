#! /local/perl/bin/perl

use lib "../src/";
use BsmlReader;
use BsmlParserTwig;
use Data::Dumper;

my $reader = new BsmlReader;
my $parser = new BsmlParserTwig;

$parser->parse( \$reader, $ARGV[0] );

foreach my $seq (@{$reader->assemblyIdtoSeqList( 'PNEUMO_19' )})
  {
    print $seq->returnattr( 'id' );
    print " : ";
    print $reader->seqIdtoAssemblyId( $seq->returnattr( 'id' ));

    print "\n";
  }

foreach my $aln (@{$reader->fetch_all_alignmentPairs( 'ORFO01980_aa', 'ORFD01850_aa' )})
  {
    print Dumper( %{$aln} );
  }
