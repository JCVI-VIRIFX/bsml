package BSML::BsmlSeqPairRun;
@ISA = qw( BSML::BsmlElement );

use BSML::BsmlElement;
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
    $self->{ 'BsmlLink' } = [];
  }

sub write
  {
    my $self = shift;
    my $writer = shift;

    $writer->startTag( "Seq-pair-run", %{$self->{'attr'}} );
       
    foreach my $bsmlattr (keys( %{$self->{ 'BsmlAttr'}}))
      {
	$writer->startTag( "Attribute", 'name' => $bsmlattr, 'content' => $self->{'BsmlAttr'}->{$bsmlattr} );
	$writer->endTag( "Attribute" );
      }

    foreach my $link (@{$self->{'BsmlLink'}})
      {
        $writer->startTag( "Link", %{$link} );
        $writer->endTag( "Link" );
      }
    
    $writer->endTag( "Seq-pair-run" );
  }

1
