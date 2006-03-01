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
# $bsmlRepository - BSML repository that corresponds to $chadoDb
# $workflowId - workflow id of the legacy2bsml task used to migrate assemblies into db
# $genus - genus of the organism to which the scaffolded sequences belong
# $species - species of the organism to which the scaffolded sequences belong
# $printSummary - whether to print a summary of the files created/skipped to STDOUT
# $parseGaps - whether to parse gap sizes from input file; default is to use fixed 100 BP gap size
# $parseOnly - parse input files and run error checks but don't create any target BSML scaffold files
#
sub writeBsmlScaffoldFiles {
    my($scaffolds, $annotDb, $chadoDb, $bsmlRepository, $workflowId, $genus, $species, $printSummary, $parseGaps, $parseOnly) = @_;
    
    my $scaffoldsSkipped = 0;
    my $scaffoldsCreated = 0;
    my $assembliesWritten = 0;
    
    # Create BSML for each scaffold, flagging those scaffolds that contain assemblies
    # not already in the target database/BSML_repository.
    foreach my $scaffold (@$scaffolds) {
	my $data = $scaffold->{'data'}; # sorted contigs
	
	# check that we have an assembly BSML document for each assembly
	my $numMissing = 0;
	my $numContigs = scalar(@$data);
	foreach my $datum (@$data) {
	    my $asmblId = $datum->{'asmbl_id'};
	    my $asmblBsmlFile = &findAssemblyBsmlFile($bsmlRepository, $workflowId, $annotDb, $asmblId);
	    ++$numMissing if (!defined($asmblBsmlFile));
	    $datum->{'assembly_bsml_file'} = $asmblBsmlFile;
	}
	
	if ($numMissing > 0) {
	    ++$scaffoldsSkipped;
	    print STDERR "WARNING - skipping scaffold with $numMissing/$numContigs contigs/assemblies missing\n";
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
		## See bug 2692
		$bsmlScaffoldSeq->addBsmlAttributeList([{name => 'SO', content=> 'supercontig'}]);
		## ^^^^^^^^^^^^
	    my $numContigs = scalar(@$data);

	    for (my $contigNum = 0;$contigNum < $numContigs;++$contigNum) {
		my $datum = $data->[$contigNum];
		my $asmblId = $datum->{'asmbl_id'};
		my $contigLen = $datum->{'contig_len'};
		my $contigStart = $datum->{'contig_start'};
		my $contigEnd = $datum->{'contig_end'};
		my $asmblBsmlId = "${annotDb}_${asmblId}_assembly";
		my $asmblBsmlFile = $datum->{'assembly_bsml_file'};

		print STDERR "contig: $contigStart - $contigEnd\n";

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
		## See bug 2692
		$asmblBsmlSeq->addBsmlAttributeList([{name => 'SO', content=> 'contig'}]);
		## ^^^^^^^^^^^^
		
		my $numbering = $builder->createAndAddNumbering( seq => $asmblBsmlSeq,
								 seqref => $scaffBsmlId,
								 refnum => $cstart,
								 ascending => $revcomp ? 0 : 1,
								 );
		
		# only add gap between adjacent sequences, not at the end (or beginning) of the scaffold
		my $contigFmax = ($contigStart >= $contigEnd) ? $contigStart : $contigEnd;
			    
		if ($contigNum < ($numContigs-1)) {
		    my $nc = $data->[$contigNum+1];
		    my $ncStart = $nc->{'contig_start'};
		    my $ncEnd = $nc->{'contig_end'};
		    my $ncFmin = ($ncStart <= $ncEnd) ? $ncStart : $ncEnd;

		    if ($parseGaps) {
			my $nGapChars = $ncFmin - $contigFmax;
			$ss .= &_makeGap($nGapChars);
			$scaffoldSeqLen += $nGapChars;
		    } else {
			$ss .= $GAP_CHARS;
			$scaffoldSeqLen += $NUM_GAP_CHARS;
		    }
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

# Locate the BSML file for a named asmbl_id, returning undef if the file cannot
# be found or it is not readable.
#
# $bsmlRepository - BSML repository that corresponds to $chadoDb
# $workflowId     - workflow id of the legacy2bsml task used to migrate assemblies into db
# $annotDb        - annotation database from which the scaffolds and/or assembly sequences were loaded
# $asmblId        - annotation database asmbl_id of the desired assembly
#
sub findAssemblyBsmlFile {
    my($bsmlRepository, $workflowId, $annotDb, $asmblId) = @_;
    my $bsmlFile = undef;

    if (defined($workflowId)) {
	my $asmblBsml = "${bsmlRepository}/legacy2bsml/${workflowId}/${annotDb}_${asmblId}_assembly.bsml";
#	print STDERR "checking for $asmblBsml\n";
	return $asmblBsml if ((-e $asmblBsml) && (-r $asmblBsml));
    }

    # check legacy2bsml/ subdir first; this is used in more recent projects
    my $asmblBsml1 = "${bsmlRepository}/legacy2bsml/${annotDb}_${asmblId}_assembly.bsml";
    # older projects store the assembly BSML files in the root of the BSML repository:
    my $asmblBsml2 = "${bsmlRepository}/${annotDb}_${asmblId}_assembly.bsml";
    
    if ((-e $asmblBsml1) && (-e $asmblBsml2)) {
	print STDERR "WARNING - multiple BSML files exist for asmbl_id=$asmblId in $bsmlRepository\n";
    }

    return $asmblBsml1 if ((-e $asmblBsml1) && (-r $asmblBsml1));
    return $asmblBsml2 if ((-e $asmblBsml2) && (-r $asmblBsml2));
    print STDERR "WARNING - could not find assembly BSML file for $annotDb.$asmblId in $bsmlRepository\n";
    return undef;
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

sub _makeGap {
    my($num_ns) = @_;
    my $gap_string = '';
    # not very efficient, but fine for small-medium sized gaps:
    for( my $i=0; $i<$num_ns; $i++ ) { $gap_string .= 'N'; }
    return $gap_string;
}

1;

