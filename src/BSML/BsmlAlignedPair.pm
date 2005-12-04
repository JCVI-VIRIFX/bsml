package BSML::BsmlAlignedPair;
@ISA = qw( BSML::BsmlElement );

BEGIN {
    require '/usr/local/devel/ANNOTATION/cas/lib/site_perl/5.8.5/BSML/BsmlElement.pm';
    import BSML::BsmlElement;
}
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
    $self->{'BsmlLink'} = [];
}

sub write
{
    my $self = shift;
    my $writer = shift;

    $writer->startTag( "Aligned-pair", %{$self->{'attr'}} );
     
    foreach my $bsmlattr (sort (keys( %{$self->{ 'BsmlAttr'}})))
    {
	$writer->startTag( "Attribute", 'name' => $bsmlattr, 'content' => $self->{'BsmlAttr'}->{$bsmlattr} );
	$writer->endTag( "Attribute" );
    }

    foreach my $link (@{$self->{'BsmlLink'}})
    {
        $writer->startTag( "Link", %{$link} );
        $writer->endTag( "Link" );
    }

    $writer->endTag( "Aligned-pair" );
}
    
1
