package BSML::BsmlSequenceData;
@ISA = qw( BSML::BsmlElement );

use BSML::BsmlElement;
use XML::Writer;

use strict;
use warnings;

sub new
{

    my $class = shift;
    my $self = {};
    bless $self, $class;

    $self->init();
    return $self;
}

sub init
{
    my $self = shift;
    
    $self->{'attr'} = {};
    $self->{'BsmlAttr'} = {};
    $self->{'seqAlignmentDat'} = '';
    $self->{'BsmlLink'} = [];
}

# Set the alignment sequence data
sub addSequenceAlignmentData
{
    my $self = shift;

    my ($seqDat) = @_;
    $self->{'seqAlignmentDat'} = $seqDat;
}

sub write
{
    my $self = shift;
    my $writer = shift;

    $writer->startTag( "Sequence-data", %{$self->{'attr'}} );
     
    foreach my $bsmlattr (keys( %{$self->{ 'BsmlAttr'}}))
    {
	$writer->startTag( "Attribute", 'name' => $bsmlattr, 'content' => $self->{'BsmlAttr'}->{$bsmlattr} );
	$writer->endTag( "Attribute" );
    }

    $writer->characters( $self->{'seqAlignmentDat'} );

    foreach my $link (@{$self->{'BsmlLink'}})
    {
        $writer->startTag( "Link", %{$link} );
        $writer->endTag( "Link" );
    }

    $writer->endTag( "Sequence-data" );
}
    
1
