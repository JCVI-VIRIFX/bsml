package BSML::BsmlRepository;

# $Id: BsmlRepository.pm,v 1.3 2004/01/19 15:33:04 angiuoli Exp $

# Copyright (c) 2002, The Institute for Genomic Research. All rights reserved.

=head1 NAME

BsmlRepository.pm - A module for managing a BSML repository

=head1 VERSION

This document refers to version $Name:  $ of frontend.cgi, $Revision: 1.3 $. 
Last modified on $Date: 2004/01/19 15:33:04 $

=head1 SYNOPSIS

=head1 DESCRIPTION

my $bsmlrepository = new BSML::BsmlRepository('PATH'=>$repositorypath);

=over 4

=cut


use strict;
use Data::Dumper;

=item new

B<Description:> The module constructor.

B<Parameters:> %arg, a hash containing attribute-value pairs to
initialize the object with. Initialization actually occurs in the
private _init method.

my $bsmlrepository = new BSML::BsmlRepository('PATH'=>$repositorypath);

B<Returns:> $self (A BSML::BsmlRepository object).

=cut

sub new {
    my ($class) = shift;
     my $self = bless {}, ref($class) || $class;
    return $self;
}


=item $obj->_init([%arg])

B<Description:> Initialize object variables

B<Parameters:> %arg, a hash containing attributes to initialize the testing
object with. Keys in %arg will create object attributes with the same name,
but with a prepended underscore.

B<Returns:> None.

=cut

sub _init {
    my $self = shift;
    #Each subflow mush have a unique name.  This name is stored in the configuration hash with the following key.
    
    $self->{_BSML_FILE_EXT} = ".bsml";
    $self->{_BSML_SUBDIR} = "BSML_repository";

    my %arg = @_;
    foreach my $key (keys %arg) {
        $self->{"_$key"} = $arg{$key}
    }
    if(!($self->{"_REPOSITORY_ROOT"})){
	die "Required parameter REPOSITORY_ROOT not passed to object constructor";
    }
    if(!($self->{"_NAME"})){
	die "Required parameter NAME not passed to object constructor";
    }
    $self->{"_PATH"} = $self->{"_REPOSITORY_ROOT"}."/".$self->{"_NAME"}."/".$self->{_BSML_SUBDIR};
}

#return the name of the BSML repository
sub get_dirname{
    my $self = shift;
    return $self->{"_PATH"};
}


#pull list of assemblies from a glob for now.
#This will work for now because bsml files are named consistently based 
#on the assembly name
sub list_assemblies{
    my $self = shift;
    my $glob = "$self->{_PATH}/*.$self->{_BSML_FILE_EXT}";
    my @asmblfiles = <$glob>;
    my @asmbllist;
    foreach my $asmbl (@asmbllist ){
	$asmbl =~ s/$self->{_PATH}\///;
	$asmbl =~ s/\.$self->{_BSML_FILE_EXT}//;
	push @asmbllist, $asmbl;
    }
    return \@asmbllist;    
}

1;
