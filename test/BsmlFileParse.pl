#! /local/perl/bin/perl

# Simple demonstration of loading the BSML object layer from a BSML
# document and printing it back out through the API. Current support
# approximated the annotation complexity of a GenBank file.

# Usage is... 
# BsmlFileParse.pl [inputfile.xml] [outputfile.xml] [inputfile.dtd]
# if the dtd is ommitted, a default is provided through the API.

use lib "../src/";

use strict;
use BsmlDoc;
use BsmlParserTwig;

my ( $inputfile, $outputfile, $dtdfile ) = @ARGV;

if( !( $inputfile ) || !( $outputfile ) )
  {
    die "Usage BsmlFileParse.pl [inputfile.xml] [outputfile.xml] [inputfile.dtd]\n";
  }

# Create a new BsmlDocument object and a Twig Parser

my $doc = new BsmlDoc;
my $parser = new BsmlParserTwig;

# Use the Twig Parser to fill the object with data from a BSML file

$parser->parse( \$doc, $inputfile );

# Do something with the data


# Write the altered data to a new bsml file

if( $dtdfile )
  { $doc->write( $outputfile, $dtdfile );}
else
  { $doc->write( $outputfile ); }
