package BioGraphicsUtil;
use strict;
use Bio::Graphics;
use Bio::SeqFeature::Generic;
use Log::Log4perl;

# Hard-coded globals

my $IMG_WIDTH = 600;
my $PAD = 10;

my $FEAT_COLOR_FN = sub {
    my $feat = shift;
    my $primTag = $feat->primary_tag();

    return 'blue' if ($primTag =~ /exon|cds|transcript|gene/i);
    return 'red' if ($primTag =~ /intron/i);

    return 'bisque';
};

my $LOG_CONF_FILE = "/home/crabtree/apache/conf/log4perl.conf";
Log::Log4perl::init($LOG_CONF_FILE);

=head1 NAME

BioGraphicsUtil - Utility methods for rendering Bioperl sequences and features with Bio::Graphics

=cut

=head2 bioperlSeqToPng

 Title   : bioperlSeqToPng
 Usage   : my $pngData = bioperlSeqToPng( { seq => $richSeq } );
 Function: Generates a PNG displaying the features of $richSeq.
 Returns : PNG data that can be returned to a CGI client.
 Args    : 

=cut

sub bioperlSeqToPng {
    my $args = shift;
    my $bpSeq = $args->{seq};
    my $bpSeqLen = $bpSeq->length();

    my $logger = Log::Log4perl->get_logger('BioGraphicsUtil');

    my @features = $bpSeq->all_SeqFeatures;

    # Group features by their primary_tag
    my $featsByTag = {};
    foreach my $feat (@features) {
	push (@{$featsByTag->{$feat->primary_tag()}}, $feat);
	my $locn = $feat->location();
	my $start = $locn->start();
	my $end = $locn->end();
	$logger->info("encountered feature with tag=" . $feat->primary_tag . " locn=$start-$end");
    }

    my $entireSeqFeat = Bio::SeqFeature::Generic->new(-start => 1, 
						      -end => $bpSeqLen,
						      -display_name => $bpSeq->display_name());

    my $panel = Bio::Graphics::Panel->new(-length     => $bpSeqLen,
					  -key_style  => 'between',
					  -width      => $IMG_WIDTH,
					  -pad_left   => $PAD,
					  -pad_right  => $PAD,
					  -pad_top    => $PAD,
					  -pad_bottom => $PAD,
					  );

    $panel->add_track($entireSeqFeat, -glyph  => 'generic', -bgcolor => 'blue', -label  => 1);
    $panel->add_track($entireSeqFeat, -glyph => 'arrow', -bump => 0, -double => 1, -tick => 2);

    foreach my $tag (keys %$featsByTag) {
	$logger->info("processing Bioperl SeqFeature primary_tag '$tag'");

	my $feats = $featsByTag->{$tag};
	$panel->add_track($feats, 
			  -glyph => 'transcript2',
			  -fgcolor => 'black',
			  -bgcolor => $FEAT_COLOR_FN,
			  -key => "${tag}",
			  -font2color => 'red',
			  -bump => +1,
			  -height => 10,
			  -label => 0,
			  -description => sub { my $feat = shift; return $feat->display_name(); },
			  );
    }

    return $panel->png;
}

1;
