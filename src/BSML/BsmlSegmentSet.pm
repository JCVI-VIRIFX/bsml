package BSML::BsmlSegmentSet;
@ISA = qw( BSML::BsmlElement );

use XML::Writer;
use strict;
use warnings;
use Log::Log4perl qw(get_logger :easy);

BEGIN {
    require '/usr/local/devel/ANNOTATION/cas/lib/site_perl/5.8.5/BSML/BsmlSegment.pm';
    import BSML::BsmlSegment;
    require '/usr/local/devel/ANNOTATION/cas/lib/site_perl/5.8.5/BSML/BsmlElement.pm';
    import BSML::BsmlElement;
}

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
    $self->{'BsmlSegments'} = [];
}

sub addBsmlSegment
{
    my $self = shift;
    
    push( @{$self->{'BsmlSegments'}}, new BSML::BsmlSegment );
    
    my $index = @{$self->{'BsmlSegment'}} - 1;

    return $index;    
}

sub dropBsmlStrain
{
    my $self = shift;
    
    my ($index) = @_;
    
    my $newlist;
    
    for(  my $i=0;  $i< @{$self->{'BsmlSegments'}}; $i++ ) 
    {
	if( $i != $index )
	{
	    push( @{$newlist}, $self->{'BsmlSegments'}[$i] );
	}
    }
    
    $self->{'BsmlSegments'} = $newlist;
}

sub returnBsmlStrainListR
{
    my $self = shift;
    return $self->{'BsmlSegments'};
}

sub returnBsmlStrainR
{
    my $self = shift;
    my ($index) = @_;

    return $self->{'BsmlSegments'}[$index];
}

sub write
{
    my $self = shift;
    my $writer = shift;
    
    $writer->startTag( "Segment-set", %{$self->{'attr'}} );

    foreach my $segment (@{$self->{'BsmlSegments'}})
    {
	$segment->write( $writer );
    }

    foreach my $bsmlattr (keys( %{$self->{ 'BsmlAttr'}}))
      {
	$writer->startTag( "Attribute",  'name' => $bsmlattr, 'content' => $self->{'BsmlAttr'}->{$bsmlattr} );
	$writer->endTag( "Attribute" );
      }

    foreach my $link (@{$self->{'BsmlLink'}})
    {
        $writer->startTag( "Link", %{$link} );
        $writer->endTag( "Link" );
    }

    $writer->endTag( "Segment-set" );
}

1
