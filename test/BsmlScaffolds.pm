#!/local/perl/bin/perl

# ------------------------------------------------------------------
# BsmlScaffolds.pm
#
# Jonathan Crabtree <crabtree@tigr.org>
#
# Created: Thu Aug 12 14:09:40 EDT 2004
# ------------------------------------------------------------------

package BsmlScaffolds;

use strict;

# ------------------------------------------------------------------
# Globals
# ------------------------------------------------------------------

my $NUM_GAP_CHARS = 100;
my $GAP_CHARS = '';
for( my $i=0; $i<$NUM_GAP_CHARS; $i++ ) { $GAP_CHARS .= 'N'; }

# ------------------------------------------------------------------
# Subroutines
# ------------------------------------------------------------------

# Write a set of BSML scaffold files.
#
# $scaffolds - listref of hashes of the following form:
#  { scaff_id => scaffold id
#    data => [ {
#     	'asmbl_id' => asmbl_id - used to retrieve assembly BSML document from BSML_repository,
#	'scaff_id' => scaffold id - used to name created BSML scaffold file,
#	'scaff_order' => ascending integer index indicating contig position in scaffold,
#	'direction' => either 'F' or 'R' for forward or reverse,
#	'gap_mean' => mean gap size (?),
#	'gap_std' => standard deviation of gap size (?),
#	'contig_len' => contig sequence length,
#	'contig_start' => contig start coordinate,
#	'contig_end' => contig end coordinate,
#    }] }
#
# $annotDb - annotation database from which the scaffolds and/or assembly sequences were loaded
# $chadoDb - target chado database
# $bsmlRepository - BSML repository that correspnods to $chadoDb
# $species - species of the organism to which the scaffolded sequences belong
# $genus - genus of the organism to which the scaffolded sequences belong
# $printSummary - whether to print a summary of the files created/skipped to STDOUT
# $parseOnly - parse input files and run error checks but don't create any target BSML scaffold files
#
sub writeBsmlScaffoldFiles {
    my($scaffolds, $annotDb, $chadoDb, $bsmlRepository, $genus, $species, $printSummary, $parseOnly) = @_;
    
    my $scaffoldsSkipped = 0;
    my $scaffoldsCreated = 0;
    my $assembliesWritten = 0;
    
    # Create BSML for each scaffold, flagging those scaffolds that contain assemblies
    # not already in the target database/BSML_repository.
    foreach my $scaffold (@$scaffolds) {
	my $data = $scaffold->{'data'}; # sorted contigs
	
	# check that we have an assembly BSML document for each assembly
	my $numMissing = 0;
	foreach my $datum (@$data) {
	    my $asmblId = $datum->{'asmbl_id'};
	    my $asmblBsml = "${bsmlRepository}/${annotDb}_${asmblId}_assembly.bsml";
	    if (!-e $asmblBsml || !-r $asmblBsml) {
		++$numMissing;
		die "unable to read $asmblBsml" if (-e $asmblBsml);
	    }
	}
	
	if ($numMissing > 0) {
	    ++$scaffoldsSkipped;
	} else {
	    my $scaffoldSeq = '';
	    my $scaffoldSeqLen = 0;
	    my $builder = new BSML::BsmlBuilder();
	    my $scaffoldId = $scaffold->{'scaff_id'};
	    my $scaffBsmlId = "${annotDb}_${scaffoldId}_supercontig";
	    my $scaffBsmlFile = "${bsmlRepository}/scaffolds/${annotDb}_${scaffoldId}_supercontig.bsml";

	    my $organism = $builder->createAndAddOrganism(genome => $builder->createAndAddGenome(), species => $species, genus => $genus );
	    $builder->createAndAddStrain(organism => $organism, database => $chadoDb, source_database => $annotDb );
	    $builder->makeCurrentDocument();
	    my $bsmlScaffoldSeq = $builder->createAndAddExtendedSequenceN(id => $scaffBsmlId, molecule => "DNA", length => -1 );
	    $bsmlScaffoldSeq->addattr("class", "supercontig");
	    my $numContigs = scalar(@$data);

	    for (my $contigNum = 0;$contigNum < $numContigs;++$contigNum) {
		my $datum = $data->[$contigNum];
		my $asmblId = $datum->{'asmbl_id'};
		my $contigLen = $datum->{'contig_len'};
		my $contigStart = $datum->{'contig_start'};
		my $contigEnd = $datum->{'contig_end'};
		my $asmblBsmlId = "${annotDb}_${asmblId}_assembly";
		my $asmblBsmlFile = "${bsmlRepository}/${annotDb}_${asmblId}_assembly.bsml";

		if ($datum->{'scaff_order'} != ($contigNum+1)) {
		    print STDERR "WARNING - gap in contig sequence number for $asmblId in $scaffoldId\n";
		}
		
		# read assembly document and add its sequence to the scaffold sequence
		my $reader = new BSML::BsmlReader;
		my $parser = new BSML::BsmlParserTwig;
		$reader->makeCurrentDocument();
		$parser->parse(\$reader, $asmblBsmlFile);

		my $bsmlSeq = BSML::BsmlDoc::BsmlReturnDocumentLookup($asmblBsmlId);
		my $revcomp = ($datum->{'direction'} eq 'R');
		my $ss = $reader->readSequenceDatImport($bsmlSeq)->{'seqdat'};
		my $sl = length($ss);

		print STDERR "WARNING - read 0-length sequence for $asmblBsmlId\n" if ($sl == 0);
		
		# compare assembly sequence length with contig length in scaffold file
		if ($contigLen != $sl) {
		    print STDERR "WARNING - actual assembly sequence length ($sl) and length from scaffold description ($contigLen) differ\n";
		}
		# check coordinates in scaffold file against those computed from sequences
		my $cstart = $revcomp ? $scaffoldSeqLen + $sl : $scaffoldSeqLen;
		my $cend = $revcomp ? $scaffoldSeqLen : $scaffoldSeqLen + $sl;

		if ($cstart != $contigStart) {
		    print STDERR "WARNING - actual contig start position ($cstart) and annotated start position ($contigStart) do not match\n";
		}
		if ($cend != $contigEnd) {
		    print STDERR "WARNING - actual contig end position ($cend) and annotated start position ($contigEnd) do not match\n";
		}

		# reverse complement assembly sequence if necessary, add gap characters
		$ss = &_revcomp($ss) if ($revcomp);
		
		$builder->makeCurrentDocument();
		my $asmblBsmlSeq = $builder->createAndAddExtendedSequenceN( id => $asmblBsmlId, length => $sl );
		$asmblBsmlSeq->addattr("class", "contig");
		
		my $numbering = $builder->createAndAddNumbering( seq => $asmblBsmlSeq,
								 seqref => $scaffBsmlId,
								 refnum => $cstart,
								 ascending => $revcomp ? 0 : 1,
								 );
		
		# only add gap between adjacent sequences, not at the end (or beginning) of the scaffold
		if ($contigNum < ($numContigs-1)) {
		    $ss .= $GAP_CHARS;
		    $scaffoldSeqLen += $NUM_GAP_CHARS;
		}

		$scaffoldSeq .= $ss;
		$scaffoldSeqLen += $sl;

		# NOTE - is the "_" prefix on the id meant to be there?
		$builder->createAndAddSeqDataImportN(seq => $ss, format => "BSML", source => $asmblBsmlFile, id => '_' . $asmblBsmlId);
	    }

	    if (!$parseOnly) {
		$builder->createAndAddSeqData( $bsmlScaffoldSeq, $scaffoldSeq );
		$bsmlScaffoldSeq->addattr('length', $scaffoldSeqLen);
		$builder->write($scaffBsmlFile);
	    }

	    ++$scaffoldsCreated;
	    $assembliesWritten += scalar(@$data);
	}
    }
    if ($printSummary) {
	print "Skipped $scaffoldsSkipped/", scalar(@$scaffolds), " scaffold(s) missing 1 or more assembly BSML files\n";
	print "Created $scaffoldsCreated BSML scaffold document(s) containing $assembliesWritten assemblies\n";
    }

    return 1;
}

# reverse complement a sequence
sub _revcomp {
    my($seq) = @_;
    my $compseq = $seq;
    $compseq =~ tr/acgtrymkswhbvdnxACGTRYMKSWHBVDNX/tgcayrkmswdvbhnxTGCAYRKMSWDVBHNX/;
    
    my $seqlen = length($compseq);
    my $revseq = '';
    
    for(my $i = $seqlen - 1;$i >= 0;--$i) {
	my $char = substr($compseq, $i, 1);
	$revseq .= $char;
    }
    return $revseq;
}

1;

