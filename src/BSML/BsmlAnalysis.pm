package BSML::BsmlAnalysis;
@ISA = qw( BSML::BsmlElement );

use BSML::BsmlElement;
use BSML::BsmlCrossReference;
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
    $self->{ 'BsmlCrossReference' } = undef;

  }

sub write
  {
    my $self = shift;
    my $writer = shift;

    $writer->startTag( "Analysis", %{$self->{'attr'}} );
       
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

     if ( my $xref = $self->{'BsmlCrossReference'})
    {
	$xref->write( $writer );
    } 


    $writer->endTag( "Analysis" );
  }

1
