package BSML::BsmlOrganism;
@ISA = qw( BSML::BsmlElement );

BEGIN {
    require '/usr/local/devel/ANNOTATION/cas/lib/site_perl/5.8.5/BSML/BsmlStrain.pm';
    import BSML::BsmlStrain;
    require '/usr/local/devel/ANNOTATION/cas/lib/site_perl/5.8.5/BSML/BsmlCrossReference.pm';
    import BSML::BsmlCrossReference;
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
    $self->{'BsmlStrain'} = [];
    $self->{'BsmlCrossReference'} = undef;
}

sub addBsmlStrain
{
    my $self = shift;
    
    push( @{$self->{'BsmlStrain'}}, new BSML::BsmlStrain );
    
    my $index = @{$self->{'BsmlStrain'}} - 1;

    return $index;    
}

sub dropBsmlStrain
{
    my $self = shift;
    
    my ($index) = @_;
    
    my $newlist;
    
    for(  my $i=0;  $i< @{$self->{'BsmlStrain'}}; $i++ ) 
    {
	if( $i != $index )
	{
	    push( @{$newlist}, $self->{'BsmlStrain'}[$i] );
	}
    }
    
    $self->{'BsmlStrain'} = $newlist;
}

sub returnBsmlStrainListR
{
    my $self = shift;
    return $self->{'BsmlStrain'};
}

sub returnBsmlStrainR
{
    my $self = shift;
    my ($index) = @_;

    return $self->{'BsmlStrain'}[$index];
}

sub write
{
    my $self = shift;
    my $writer = shift;

    $writer->startTag( "Organism", %{$self->{'attr'}} );

    foreach my $strain (@{$self->{'BsmlStrain'}})
    {
	$strain->write( $writer );
    }

    foreach my $bsmlattr (keys( %{$self->{ 'BsmlAttr'}}))
      {
	$writer->startTag( "Attribute",  'name' => $bsmlattr, 'content' => $self->{'BsmlAttr'}->{$bsmlattr} );
	$writer->endTag( "Attribute" );
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

    $writer->endTag( "Organism" );
}

1
