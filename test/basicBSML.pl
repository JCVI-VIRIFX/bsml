#! /local/perl/bin/perl

# This program demonstrates usage of the BSML Object layer to read BSML
# data from a file and add and alter annotations. It is essentially a
# basic functionality test for the library, but could be useful to demonstrate
# function calls.  

use lib "../src/";

use strict;
use BsmlDoc;
use BsmlParserTwig;

# $inputfile - BSML input
# $outputfile - BSML output
# $dtdfile - Local path to a BSML DTD, if ommitted a default, url based dtd will be provided

my ( $inputfile, $outputfile, $dtdfile ) = @ARGV;

if( !( $inputfile ) || !( $outputfile ) )
  {
    die "Usage appendSeqDat.pl [inputfile.xml] [outputfile.xml] [inputfile.dtd]\n";
  }

# Create a new BsmlDocument object and Twig Parser

my $doc = new BsmlDoc;
my $parser = new BsmlParserTwig;

# Use the Twig Parser to populate the BsmlDocument with data from the source file

$parser->parse( \$doc, $inputfile );

# Get a reference to a list of sequence references from the BsmlDocument

my $seqList = $doc->returnBsmlSequenceListR();

# loop over all sequences in the document

foreach my $seq ( @{ $seqList } )
{
  # retrieve a reference to a hash containing the key / value pairs for the Sequence elements attributes

  my $attr = $seq->returnattrHashR();

  # check to see if there's an external database accession number

  print "Sequence Name: ";

  if( $attr->{'ic-acckey'} )
    {
      print "$attr->{'ic-acckey'}\n";
    }
  else
    {
      print "No Accesssion Number Found...";
    }

  # reset the 'ic-acckey attribute to 99999 or add the attribute if not already there
  # note $attr->{ 'ic-acckey' } = '99999'; would have the same result

  $seq->addattr( 'ic-acckey', '99999' );

  # retrieve raw sequence data if available and print the first 30 characters it

  my $seqdat = $seq->returnSeqData();

  if( $seqdat )
    {
      print "Seq-dat: ";

      my $s = substr( $seqdat, 0, 30 );
      $s =~ s/\n//;

      print "$s\n";
    }

  # if $seqdat is present change its contents to all-caps else
  # annotate the sequence with poly-a.

  if( $seqdat )
    {
      $seq->setBsmlSeqData( uc( $seqdat ) );
    }
  else
    {
      $seq->addBsmlSeqData( 'AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA' );
    }

  # retrieve a list of references to the sequences feature tables

  my $FTableList = $seq->returnFeatureTableListR();

  # print the number of features in each feature table

  foreach my $Ftable ( @{ $FTableList } )
    {
      # retrieve a list of references to the features in the feature table 

      my $FeaturesList = $Ftable->returnBsmlFeatureListR();
      
      # retrieve the feature tables 'id' attribute if set

      my $FeatureTableName = $Ftable->returnattr( 'id' );

      # print the table id and the number of features it has

      my $count = @{ $FeaturesList };

      if( $FeatureTableName ){
	  print "$FeatureTableName - $count features\n";
	}
      else{
	print "Unnamed Feature Table - $count features\n";
      }  

      # add a new feature and qualifier

      my $feature = $Ftable->returnBsmlFeatureR( $Ftable->addBsmlFeature() );

      $feature->addBsmlQualifier( "product", "TIGR Bsml Object" );

      # drop the first feature in the table

      $Ftable->dropBsmlFeature( 0 );

      # add a new reference

      my $ref = $Ftable->returnBsmlReferenceR( $Ftable->addBsmlReference() );
      $ref->addBsmlRefAuthors( "Christopher R. Hauser" );
      $ref->addBsmlRefTitle( "Basic BSML Object Layer" );
      $ref->addBsmlRefJournal( "Internal TIGR Documents" );

      # drop the first reference in the table

      $Ftable->dropBsmlReference( 0 );
      
    }

  

 
}

 # write the altered Bsml Document to a file

  $doc->write( $outputfile );


