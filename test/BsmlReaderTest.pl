#! /local/perl/bin/perl

use lib "../src/";
use BsmlReader;
use BsmlParserTwig;
use Data::Dumper;

my $reader = new BsmlReader;
my $parser = new BsmlParserTwig;

$parser->parse( \$reader, $ARGV[0] );

my $seqs = $reader->returnAllSequences();

foreach my $seq ( @{$seqs} )
  {
    my $hr = $reader->readSequence( $seq );
    print Dumper($hr);

    my $fr = $reader->readFeatures( $seq );
    print Dumper($fr);

    my $lk = $reader->readLinks( $seq );
    print Dumper($lk);
  }
