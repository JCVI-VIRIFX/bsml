#!/local/perl/bin/perl

# ------------------------------------------------------------------
# bioperlSeqPng.cgi
#
# Generate a png image for any database entry that can be retrieved
# via the get_sequence method of Bio::Perl.
#
# Created: Fri Sep 26 13:19:13 EDT 2003
# ------------------------------------------------------------------

use strict;

use CGI;
use Bio::Perl;
use BioGraphicsUtil;

# ------------------------------------------------------------
# Input validation
# ------------------------------------------------------------

my $cgi = CGI->new();

my $seqid = $cgi->param('seqid');
$seqid =~ s/[^A-Z0-9\.\-\_]//gi;

my $db = lc($cgi->param('db'));
if (!($db =~ /genbank|genpept|swiss|embl|refseq/i)) {
    $db = 'genbank'; # default
}

# ------------------------------------------------------------
# Main program
# ------------------------------------------------------------

print "Content-type: image/png\n\n";

my $bpSeq = Bio::Perl::get_sequence($db, $seqid);

if ($bpSeq) {
    print BioGraphicsUtil::bioperlSeqToPng( { seq => $bpSeq } );
}
