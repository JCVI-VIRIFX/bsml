#! /local/perl/bin/perl

# Simple demonstration of loading the BSML object layer from a BSML
# document and printing it back out through the API. Current support
# approximates the annotation complexity of a GenBank file.

# Usage is... 
# BsmlFileParse.pl [inputfile.xml] [outputfile.xml] --dtd[dtd file] --logconf [logconf file]
# if the dtd or logconf are ommitted, defaults are provided through the API.

use lib "../src/";

use strict;
use Getopt::Long;
use BsmlDoc;
use BsmlParserTwig;

my $dtd = '';
my $logconf = '';

GetOptions( 'dtd=s' => \$dtd, 'logconf=s' => \$logconf );

my ( $inputfile, $outputfile ) = @ARGV;

if( !( $inputfile ) || !( $outputfile ) )
  {
    die "Usage BsmlFileParse.pl [inputfile.xml] [outputfile.xml] --dtd[dtd file] --logconf [logconf file]\n";
  }

# Create a new BsmlDocument object and a Twig Parser

my $doc = new BsmlDoc( $logconf );
my $parser = new BsmlParserTwig;

# Use the Twig Parser to fill the object with data from a BSML file

$parser->parse( \$doc, $inputfile );

# Do something with the data


# Write the altered data to a new bsml file

if( $dtd )
  { $doc->write( $outputfile, $dtd );}
else
  { $doc->write( $outputfile ); }
