#! /local/perl/bin/perl

# client script to test the functionality of the helper functions defined i
# BsmlBuilder.pm

# The BsmlBuilder class mirrors the Java API defined in the LabBook Bsml Documentation
# for building Bsml sequences.

use lib "../src/";
use BSML::BsmlBuilder;

my $doc = new BSML::BsmlBuilder;

open( INFILE, $ARGV[0] ) or die "Could not open input file\n";

while( my $line = <INFILE> )
  {
    chomp($line);
    $line =~ s/\|//;
    $doc->createAndAddBtabLine( split( /\t/, $line ) );
  }

$doc->write( 'output.xml' );
