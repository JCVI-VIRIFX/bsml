#! /local/perl/bin/perl

# client script to build a basic Bsml Document representing a PBlast Search Encoding

#specify the location of the Bsml Object Layer installation
use lib "../src/";

use BSML::BsmlBuilder;

# Create a Bsml document object
my $doc = new BSML::BsmlBuilder;

# Add a sequence alignment object to the document. This function adds sequences to the document
# if the sequences are not already there. 

my $alignment = $doc->createAndAddSequencePairAlignment( 'refseq' => 'gbs_ORF00003_23193_protein',           #the BSML id of the query sequence  
						   'reflength' => '447',                               #the length of the query sequence
						   'refstart' => '0',                                  #start position on query sequence actually searched
						   'refend' => '446',                                  #end position on the query sequence actually searched
						   'compseq' => 'gbs18rs21_ORF00032_35101_protein' );   #the BSML id of the subject sequence

# using the object reference additional attributes and/or BSML Attributes may be added. Here database accession
# and search method attributes are appended using the lower API. 

$alignment->addattr( 'compxref', '/usr/local/annotation/PNEUMO/blastp/gbs_799/PNEUMO.pep:gbs18rs21_ORF00032_35101_protein' );
$alignment->addattr( 'method', 'blastp 2.0mp-washu' );

# To add additional attributes to the Sequence objects created with the Builder function above, references
# to the sequences must be obtained by querying the object layer. All Bsml Elements containing IDREFs are
# accesible through lookup tables in the lower api. To return a Bsml element given its id use the following 
# function.

my $query_seqR = BSML::BsmlDoc::BsmlReturnDocumentLookup( 'gbs_ORF00003_23193_protein' );
my $subject_seqR = BSML::BsmlDoc::BsmlReturnDocumentLookup( 'gbs18rs21_ORF00032_35101_protein' );

# Bsml Attributes are added to the sequences specifying their assembly id.

$query_seqR->addBsmlAttr( 'ASSEMBLY', 'gbs_799_assembly' );
$subject_seqR->addBsmlAttr( 'ASSEMBLY', 'gbs18rs21_797_assembly' );

# and standard attributes specifying the molecule type.

$query_seqR->addattr( 'molecule', 'aa' );
$subject_seqR->addattr( 'molecule', 'aa' );

# Getting back to the search encoding, HSPs are encoded as child elements of SeqPairAlignments called
# SeqPairRuns. A SeqPairRun can be appended to an alignment object using the following Builder
# function. 

my $run = $doc->createAndAddSequencePairRun( 'alignment_pair' => $alignment,    #a reference to the parent alignment object
				   'runscore' => '2182',              #the HSP score
				   'runprob' =>  '447',               #the HSP prob
				   'runlength' => '447',              #the length of match
				   'refpos' => '1',                   #start position of the match relative to the query sequence
				   'refcomplement' => '0',            
				   'comppos' => '1',
				   'comprunlength' => '447',
				   'compcomplement' => '0' );

# Client specific search results can be encoded using Bsml Attributes

$run->addBsmlAttr( 'segment_number', '43069' );
$run->addBsmlAttr( 'chain_number', '41323' );
$run->addBsmlAttr( 'percent_bit_score', '1.000' );
$run->addBsmlAttr( 'percent_identity', '100.000000' );
$run->addBsmlAttr( 'percent_similarity', '100.000000' );
$run->addBsmlAttr( 'p_value', '3.9e-227' );

# The document object can be serialized to XML using the method write which accepts
# a filename string or 'STDOUT'  

$doc->write( 'STDOUT' );

# to validate this document against the pblast.xsd schema
# xsdValid -s pblast.xsd file.bsml

# to validate this document against the Labbook dtd
# dtdValid file.bsml
