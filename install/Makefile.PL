use ExtUtils::MakeMaker;
require ExtUtils::Manifest;

if(stat "MANIFEST"){}
else{
    ExtUtils::Manifest::mkmanifest();
  }

my $schemadocsdir = '';#/usr/local/devel/ANNOTATION/shared/doc/schema';
my $isschemadocsdir=0;
foreach my $arg (@ARGV){
	if($arg =~ /SCHEMA_DOCS_DIR/){
	    ($schemadocsdir) = ($arg =~ /SCHEMA_DOCS_DIR=(.*)/);
	    $isschemadocsdir=1;
	}
    }

if(!$isschemadocsdir){
    warn "You must specify a SCHEMA_DOCS_DIR if you want to install XML schemas and the BSML dtd.\n".
	"XML schema and DTD files will be stored in this directory\n".
	"Eg. \n\nperl Makefile.PL PREFIX=/usr/local/devel/ANNOTATION/shared SCHEMA_DOCS_DIR=/usr/local/devel/ANNOTATION/shared/docs\n\n";
}
else{
    print "Ignore the following warning: ";
}

WriteMakefile(
	      'NAME'=>'BSML'
	      );

package MY;

sub MY::postamble { 
    if($schemadocsdir eq ""){
	return;
    }
    my $postamble = "SCHEMA_DIR=$schemadocsdir";

    $postamble .= << 'END';

SCHEMA_SRC_DIR=schema
VALIDATOR_SRC_DIR=schema/xsdValid-Xerces
VALIDATOR_BIN_DIR=$(PREFIX)/bin

validation : 
	@mkdir -p $(SCHEMA_DIR)
	@mkdir -p $(VALIDATOR_BIN_DIR)
	@install $(VALIDATOR_SRC_DIR)/xsdValid.pl $(VALIDATOR_BIN_DIR)
	@install $(VALIDATOR_SRC_DIR)/dtdValid.pl $(VALIDATOR_BIN_DIR)
	@install $(SCHEMA_SRC_DIR)/*.xsd $(SCHEMA_DIR)
	@install $(SCHEMA_SRC_DIR)/*.dtd $(SCHEMA_DIR)

END

    $postamble;
}

sub install { 
    my $self = shift;
    if($schemadocsdir ne ""){
	my $installstr = $self->MM::install(@_);
	my $addltarget = 'validation';
	$installstr =~ s/(pure_install\s+::\s+)(.*)/$1 $2 $addltarget/;
	return $installstr;
    }
    else{
	return $self->MM::install(@_);
    }
}
