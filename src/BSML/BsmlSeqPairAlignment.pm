package BSML::BsmlSeqPairAlignment;
@ISA = qw( BSML::BsmlElement );

BEGIN {
    require '/usr/local/devel/ANNOTATION/cas/lib/site_perl/5.8.5/BSML/BsmlSeqPairRun.pm';
    import BSML::BsmlSeqPairRun;
    require '/usr/local/devel/ANNOTATION/cas/lib/site_perl/5.8.5/BSML/BsmlCrossReference.pm';
    import BSML::BsmlCrossReference;
    require '/usr/local/devel/ANNOTATION/cas/lib/site_perl/5.8.5/BSML/BsmlElement.pm';
    import BSML::BsmlElement;
}
use XML::Writer;
use strict;
use warnings;
use Log::Log4perl qw(get_logger :levels);

sub new 
  {
    my $class = shift;
    my ($logger_conf) = @_;
    my $self = {};
    bless $self, $class;
    
    $self->init( $logger_conf );
    return $self;
  }

sub init
  {
    my $self = shift;

    $self->{ 'attr' } = {};
    $self->{ 'BsmlAttr' } = {};
    $self->{ 'BsmlSeqPairRuns' } = [];
    $self->{ 'BsmlLink' } = [];
    $self->{ 'BsmlCrossReference ' } = undef;
  }

sub addBsmlSeqPairRun
  {
    my $self = shift;
    push( @{$self->{'BsmlSeqPairRuns'}}, new BSML::BsmlSeqPairRun );

    my $index = @{$self->{'BsmlSeqPairRuns'}} - 1;
    return $index;
  }

sub dropBsmlSeqPairRun
  {
    my $self = shift;
    my ($index) = @_;

    my @newlist;

    for( my $i=0; $i<length(@{$self->{'BsmlSeqPairRuns'}}); $i++ )
      {
	if( $i != $index )
	  {
	    push( @newlist, $self->{'BsmlSeqPairRuns'}[$i] );
	  }
      }

    $self->{'BsmlSeqPairRuns'} = \@newlist;    
  }

sub returnBsmlSeqPairRunListR
  {
    my $self = shift;
    return $self->{'BsmlSeqPairRuns'};
  }

sub returnBsmlSeqPairRunR
  {
    my $self = shift;
    my ($index) = @_;

    return $self->{'BsmlSeqPairRuns'}[$index];
  }

sub write
  {
    my $self = shift;
    my $writer = shift;

    $writer->startTag( "Seq-pair-alignment", %{$self->{'attr'}} );

    foreach my $bsmlattr (sort (keys( %{$self->{ 'BsmlAttr'}})))
      {
	$writer->startTag( "Attribute", 'name' => $bsmlattr, 'content' => $self->{'BsmlAttr'}->{$bsmlattr} );
	$writer->endTag( "Attribute" );
      }

    if( my $runcount = @{$self->{'BsmlSeqPairRuns'}} > 0 )
      {
	foreach my $run (@{$self->{'BsmlSeqPairRuns'}})
	  {
	    $run->write( $writer );
	  }
      }

    if ( my $xref = $self->{'BsmlCrossReference'})
    {
	$xref->write( $writer );
    }

    foreach my $link (@{$self->{'BsmlLink'}})
       {
	   $writer->startTag( "Link", %{$link} );
	   $writer->endTag( "Link" );
       }
    

    $writer->endTag( "Seq-pair-alignment" );
  }

1
