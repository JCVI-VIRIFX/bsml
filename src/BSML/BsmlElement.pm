package BsmlElement;

sub addattr
  {
    my $self = shift;
    my ( $key, $value ) = @_;

    $self->{ 'attr' }->{ $key } = $value;
  }

sub setattr
  {
    my $self = shift;
    my ( $key, $value ) = @_;

    $self->addattr( $key, $value );
  }

sub dropattr
  {
    my $self = shift;
    my ( $key, $value ) = @_;

    delete($self->{'attr'}->{$key});
  }

sub returnattrHashR
  {
    #returns a hash reference to the key, value pairs
    
    my $self = shift;
    return $self->{'attr'};
  }

sub returnattr
  {
    #returns an attribute value given its key

    my $self = shift;
    my ($key) = @_;

    return $self->{'attr'}->{$key};
  }

sub addBsmlAttr
  {
    my $self = shift;
    my ( $key, $value ) = @_;

    $self->{ 'BsmlAttr' }->{ $key } = $value;
  }

sub setBsmlAttr
  {
    my $self = shift;
    my ( $key, $value ) = @_;
    
    $self->addBsmlAttr( $key, $value );
  }

sub dropBsmlAttr
  {
    my $self = shift;
    my ( $key, $value ) = @_;

    delete($self->{ 'BsmlAttr' }->{ $key });
  }

sub returnBsmlAttrHash
  {
    my $self = shift;
    return $self->{ 'BsmlAttr' };
  }

sub write()
  {
    
  }

1
