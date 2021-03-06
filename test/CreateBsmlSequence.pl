#! /local/perl/bin/perl

# This is an extremely simple example of creating a BSML document
# of the complexity of a FASTA file through the BSML API

use lib "../src/";

use strict;
use BsmlDoc;
use BsmlParserTwig;
use Getopt::Long;

my $dtdfile = '';
my $logconf = '';

GetOptions( 'dtd=s' => \$dtdfile, 'logconf=s' => \$logconf );

my ( $outputfile ) = @ARGV;

if( !($outputfile) ){ $outputfile = 'TestBsmlSequence.bsml'; }

# Create the Bsml Document Instance

my $doc = new BsmlDoc( $logconf );

# Add a sequence to the document. Note that addBsmlSequence returns an internal
# index to the newly created sequence object. ReturnBsmlSequenceR returns the 
# reference to that sequence given its index.

my $seq = $doc->returnBsmlSequenceR( $doc->addBsmlSequence() );

# Set the sequence attributes, all Bsml object attributes may be set in this manner. 
# Note, at this level the API requires the user to have a basic understanding of the
# BSML schema. Helper functions will be developed to make this easier. 

$seq->setattrh( { 'id' => 'G2656021', 'title' => 'AB003468', 'molecule' => 'dna', 'ic-acckey' => 'AB003468', length => '5350'  }  );

# Add a Bsml Element Attribute to the sequence object. The BSML specification
# allows an Attribute Element to be assigned to any other BSML element.

$seq->addBsmlAttr( 'version', 'GI:2656021' );

# Append sequence data
$seq->addBsmlSeqData( 
  'ggtaccttctgaggcggaaagaaccagccggatccctcgagggatccaga
   catgataagatacattgatgagtttggacaaaccacaactagaatgcagt
   gaaaaaaatgctttatttgtgaaatttgtgatgctattgctttatttgta
   accattataagctgcaataaacaagttaacaacaacaattgcattcattt
   tatgtttcaggttcagggggaggtgtgggaggttttttaaagcaagtaaa
   acctctacaaatgtggtatggctgattatgatccggctgcctcgcgcgtt
   tcggtgatgacggtgaaaacctctgacacatgcagctcccggagacggtc
   acagcttgtctgtaagcggatgccgggagcagacaagcccgtcagggcgc
   gtcagcgggtgttggcgggtgtcggggcgcagccatgacccagtcacgta
   gcgatagcggagtgtatactggcttaactatgcggcatcagagcagattg
   tactgagagtgcaccatatgcggtgtgaaataccgcacagatgcgtaagg
   agaaaataccgcatcaggcgctcttccgcttcctcgctcactgactcgct
   gcgctcggtcgttcggctgcggcgagcggtatcagctcactcaaaggcgg
   taatacggttatccacagaatcaggggataacgcaggaaagaacatgtga
   gcaaaaggccagcaaaaggccaggaaccgtaaaaaggccgcgttgctggc
   gtttttccataggctccgcccccctgacgagcatcacaaaaatcgacgct
   caagtcagaggtggcgaaacccgacaggactataaagataccaggcgttt
   ccccctggaagctccctcgtgcgctctcctgttccgaccctgccgcttac
   cggatacctgtccgcctttctcccttcgggaagcgtggcgctttctcata
   gctcacgctgtaggtatctcagttcggtgtaggtcgttcgctccaagctg
   ggctgtgtgcacgaaccccccgttcagcccgaccgctgcgccttatccgg
   taactatcgtcttgagtccaacccggtaagacacgacttatcgccactgg
   cagcagccactggtaacaggattagcagagcgaggtatgtaggcggtgct
   acagagttcttgaagtggtggcctaactacggctacactagaagaacagt
   atttggtatctgcgctctgctgaagccagttaccttcggaaaaagagttg
   gtagctcttgatccggcaaacaaaccaccgctggtagcggtggttttttt
   gtttgcaagcagcagattacgcgcagaaaaaaaggatctcaagaagatcc
   tttgatcttttctacggggtctgacgctcagtggaacgaaaactcacgtt
   aagggattttggtcatgagattatcaaaaaggatcttcacctagatcctt
   ttaaattaaaaatgaagttttaaatcaatctaaagtatatatgagtaaac
   ttggtctgacagttaccaatgcttaatcagtgaggcacctatctcagcga
   tctgtctatttcgttcatccatagttgcctgactccccgtcgtgtagata
   actacgatacgggagggcttaccatctggccccagtgctgcaatgatacc
   gcgagacccacgctcaccggctccagatttatcagcaataaaccagccag
   ccggaagggccgagcgcagaagtggtcctgcaactttatccgcctccatc
   cagtctattaattgttgccgggaagctagagtaagtagttcgccagttaa
   tagtttgcgcaacgttgttgccattgctacaggcatcgtggtgtcacgct
   cgtcgtttggtatggcttcattcagctccggttcccaacgatcaaggcga
   gttacatgatcccccatgttgtgcaaaaaagcggttagctccttcggtcc
   tccgatcgttgtcagaagtaagttggccgcagtgttatcactcatggtta
   tggcagcactgcataattctcttactgtcatgccatccgtaagatgcttt
   tctgtgactggtgagtactcaaccaagtcattctgagaatagtgtatgcg
   gcgaccgagttgctcttgcccggcgtcaatacgggataataccgcgccac
   atagcagaactttaaaagtgctcatcattggaaaacgttcttcggggcga
   aaactctcaaggatcttaccgctgttgagatccagttcgatgtaacccac
   tcgtgcacccaactgatcttcagcatcttttactttcaccagcgtttctg
   ggtgagcaaaaacaggaaggcaaaatgccgcaaaaaagggaataagggcg
   acacggaaatgttgaatactcatactcttcctttttcaatattattgaag
   catttatcagggttattgtctcatgagcggatacatatttgaatgtattt
   agaaaaataaacaaataggggttccgcgcacatttccccgaaaagtgcca
   cctaaattgtaagcgttaatattttgttaaaattcgcgttaaatttttgt
   taaatcagctcattttttaaccaataggccgaaatcggcaaaatccctta
   taaatcaaaagaatagaccgagatagggttgagtgttgttccagtttgga
   acaagagtccactattaaagaacgtggactccaacgtcaaagggcgaaaa
   accgtctatcagggcgatggcccactacgtgaaccatcaccctaatcaag
   ttttttggggtcgaggtgccgtaaagcactaaatcggaaccctaaaggga
   gcccccgatttagagcttgacggggaaagccggcgaacgtggcgagaaag
   gaagggaagaaagcgaaaggagcgggcgctagggcgctggcaagtgtagc
   ggtcacgctgcgcgtaaccaccacacccgccgcgcttaatgcgccgctac
   agggcgcgtcccattcgccattcaggctgcgcaactgttgggaagggcga
   tcggtgcgggcctcttcgctattacgccagctggcgaaagggggatgtgc
   tgcaaggcgattaagttgggtaacgccagggttttcccagtcacgacgtt
   gtaaaacgacggccagtgagcgcgtcgacggtatcgataagcttggctgt
   ggaatgtgtgtcagttagggtgtggaaagtccccaggctccccagcaggc
   agaagtatgcaaagcatgcatctcaattagtcagcaaccaggtgtggaaa
   gtccccaggctccccagcaggcagaagtatgcaaagcatgcatctcaatt
   agtcagcaaccatagtcccgcccctaactccgcccatcccgcccctaact
   ccgcccagttccgcccattctccgccccatggctgactaattttttttat
   ttatgcagaggccgaggccgcctcggcctctgagctattccagaagtagt
   gaggaggcttttttggaggcctaggcttttgcaaaaagctcctcgaggaa
   ctgaaaaaccagaaagttaactggtaagtttagtctttttgtcttttatt
   tcaggtcccggatctgatcaagagacaggatgaggatcgtttcgcatgat
   tgaacaagatggattgcacgcaggttctccggccgcttgggtggagaggc
   tattcggctatgactgggcacaacagacaatcggctgctctgatgccgcc
   gtgttccggctgtcagcgcaggggcgcccggttctttttgtcaagaccga
   cctgtccggtgccctgaatgaactgcaggacgaggcagcgcggctatcgt
   ggctggccacgacgggcgttccttgcgcagctgtgctcgacgttgtcact
   gaagcgggaagggactggctgctattgggcgaagtgccggggcaggatct
   cctgtcatctcaccttgctcctgccgagaaagtatccatcatggctgatg
   caatgcggcggctgcatacgcttgatccggctacctgcccattcgaccac
   caagcgaaacatcgcatcgagcgagcacgtactcggatggaagccggtct
   tgtcgatcaggatgatctggacgaagagcatcaggggctcgcgccagccg
   aactgttcgccaggctcaaggcgcgcatgcccgacggcgaggatctcgtc
   gtgacccatggcgatgcctgcttgccgaatatcatggtggaaaatggccg
   cttttctggattcatcgactgtggccggctgggtgtggcggaccgctatc
   aggacatagcgttggctacccgtgatattgctgaagagcttggcggcgaa
   tgggctgaccgcttcctcgtgctttacggtatcgccgctcccgattcgca
   gcgcatcgccttctatcgccttcttgacgagttcttctgagcgggactct
   ggggttcgaaatgaccgaccaagcgacgcccaacctgccgggatccagac
   atgataagatacattgatgagtttggacaaaccacaactagaatgcagtg
   aaaaaaatgctttatttgtgaaatttgtgatgctattgctttatttgtaa
   ccattataagctgcaataaacaagttaacaacaacaattgcattcatttt
   atgtttcaggttcagggggaggtgtgggaggttttttagcttggctgtgg
   aatgtgtgtcagttagggtgtggaaagtccccaggctccccagcaggcag
   aagtatgcaaagcatgcatctcaattagtcagcaaccaggtgtggaaagt
   ccccaggctccccagcaggcagaagtatgcaaagcatgcatctcaattag
   tcagcaaccatagtcccgcccctaactccgcccatcccgcccctaactcc
   gcccagttccgcccattctccgccccatggctgactaattttttttattt
   atgcagaggccgaggccgcctcggcctctgagctattccagaagtagtga
   ggaggcttttttggaggcctaggcttttgcaaaaagctcctcgaggaact
   gaaaaaccagaaagttaactggtaagtttagtctttttgtcttttatttc
   aggtcccggatccggtggtggtgcaaatcaaagaactgctcctcagtgga
   tgttgcctttacttctaggcctgtacggaagtgttacttctgctctaaaa
   gctgctgcaggagctcggaccgggcccttaggacgcgtaatacgactcac
   tatagggaattcgacgtctagatcttaaggcgcgccaaggggttggccac
   gtggtaaccacggggtggctagctagggataacagggtaatatagcggcc
   gccctttagtgagggttaatttaaatcgtacgtcgcgattaattaaccgc');


$doc->write( $outputfile );
