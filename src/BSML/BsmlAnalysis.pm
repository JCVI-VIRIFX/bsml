package BsmlAnalysis;
@ISA = qw( BsmlElement );

use BsmlElement;
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

    $writer->endTag( "Analysis" );
  }

1
