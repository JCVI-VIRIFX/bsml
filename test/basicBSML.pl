#! /local/perl/bin/perl

# This program demonstrates usage of the BSML Object layer to read BSML
# data from a file and add and alter annotations. It is essentially a
# basic functionality test for the library, but could be useful to demonstrate
# function calls.  

use lib "../src/";

use strict;
use BsmlDoc;
use BsmlParserTwig;
use Getopt::Long;

# $inputfile - BSML input
# $outputfile - BSML output
# $dtdfile - Local path to a BSML DTD, if ommitted a default, url based dtd will be provided

my $dtdfile = '';
my $logconf = '';

GetOptions( 'dtd=s' => \$dtdfile, 'logconf=s' => \$logconf );

my ( $inputfile, $outputfile ) = @ARGV;

if( !( $inputfile ) || !( $outputfile ) )
  {
    die "Usage basicBSML.pl [inputfile.xml] [outputfile.xml] --dtd [local BSML dtd] --logconf [Log4Perl config file]\n";
  }

# Create a new BsmlDocument object and Twig Parser
# if a path to a Log4Perl configuration file is given to the BsmlDoc constructor, default logging will be overidden by the
# user specified config

my $doc = new BsmlDoc( $logconf );

# This BSML parser uses the XML::Twig library
my $parser = new BsmlParserTwig;

print "\nParsing Bsml Document: $inputfile\n";

# Use the Twig Parser to populate the BsmlDocument with data from the source file
$parser->parse( \$doc, $inputfile );

# Get a reference to a list of sequence references from the BsmlDocument

my $seqList = $doc->returnBsmlSequenceListR();
my $seqcount = @{$seqList};

print "Finished Parsing Bsml Document: $inputfile. ($seqcount sequences found)\n\n";

# loop over all sequences in the document

foreach my $seq ( @{ $seqList } )
{

  print "\n";

  # retrieve a reference to a hash containing the key / value pairs for the Sequence element's attributes

  my $attr = $seq->returnattrHashR();

  # check to see if there's an external database accession number

  print "Sequence - ";

  if( $attr->{'ic-acckey'} )
    {
      print "Accession: $attr->{'ic-acckey'}\n";
    }
  else
    {
      print "Accession: Not Defined\n";
    }

  # reset the 'ic-acckey attribute to 99999 or add the attribute if not already there
  # note $attr->{ 'ic-acckey' } = '99999'; would have the same result

  $seq->addattr( 'ic-acckey', '99999' );

  # retrieve raw sequence data if available and print the first 30 characters it

  my $seqdat = $seq->returnSeqData();

  if( $seqdat )
    {
      print "  Seq-dat: ";

      my $s = substr( $seqdat, 0, 30 );
      $s =~ s/\n//;

      print "$s...\n";
    }
  else
    {
      print "  Seq-dat: Not defined\n";
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

  my $FTableList = $seq->returnBsmlFeatureTableListR();
  my $FTableCount = @{$FTableList};

  print "  Feature Tables: $FTableCount Defined\n";
  

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
	  print "    Feature Table: $FeatureTableName ($count features)\n";
	}
      else{
	  print "    Feature Table: ID not defined ($count features)\n";
      }  

      my $feature;

      # Print the Feature ID for each feature

      foreach $feature ( @{$FeaturesList} )
	{
	  my $id = $feature->returnattr( 'id' );

	  if( $id ){
	    print "      Feature: $id\n";
	  }
	  else{
	    print "      Feature: ID Not Defined\n";
	  } 
	}
      
      # add a new feature and qualifier

      $feature = $Ftable->returnBsmlFeatureR( $Ftable->addBsmlFeature() );

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

  # Take a look for feature groups

  my $FGroupList = $seq->returnBsmlFeatureGroupListR();
  my $FGroupCount = @{$FGroupList};

  print "  Feature Groups: $FGroupCount Defined\n";
  
  foreach my $FGroup ( @{$FGroupList} )
    {
      my $id = $FGroup->returnattr( 'id' );
      my $FGroupMembers = $FGroup->returnFeatureGroupMemberListR();
      my $membercount = @{$FGroupMembers};
  
      if( $id ){
	print "    Feature Group: $id ($membercount features)\n";
      }
      else{
	print "    Feature Group: ID not defined ($membercount features)\n";
      }

      foreach my $FGroupMember ( @{$FGroupMembers} )
	{
	  print "      Feature: ".$FGroupMember->{'feature'}." - ".$FGroupMember->{'feature-type'}."\n";
	}
    }
}

 # write the altered Bsml Document to a file

  $doc->write( $outputfile );

  print "\nWrote Bsml Document: $outputfile\n";


