use ExtUtils::MakeMaker;
require ExtUtils::Manifest;

if(stat "MANIFEST"){}
else{
    ExtUtils::Manifest::mkmanifest();
  }

my $schemadocsdir = '/usr/local/devel/ANNOTATION/shared/doc/schema';
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
	"Eg. \n\nperl Makefile.PL PREFIX=/usr/local/devel/ANNOTATION/shared SCHEMA_DOCS_DIR=/usr/local/devel/ANNOTATION/shared/docs\n\n".
	"The default is SCHEMA_DOCS_DIR $schemadocsdir\n";
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

    my  $postamble = << 'END';

SCHEMA_SRC_DIR=schema
VALIDATOR_SRC_DIR=schema/Xerces-xsdValid
VALIDATOR_BIN_DIR=$(PREFIX)/bin
INCLUDE = -I/usr/local/packages/xerces-c++/include
LIBDIR = -L/usr/local/packages/xerces-c++/lib
CXX = g++
LINK = g++
CXXFLAGS = -O2
LIBRARIES = -lxerces-c

validation: Xerces-xsdValid validation_install

Xerces-xsdValid:  SAX2Print.cpp SAX2Print.hpp SAX2PrintHandlers.o
	$(CXX) $(CXXFLAGS) $(INCLUDE) $(LIBDIR) -o Xerces-xsdValid SAX2Print.cpp SAX2PrintHandlers.o $(LIBRARIES)

SAX2PrintHandlers.o: SAX2PrintHandlers.cpp SAX2PrintHandlers.hpp
	$(CXX) $(CXXFLAGS) $(INCLUDE) -c SAX2PrintHandlers.cpp

validation install : Xerces-xsdValid
	@mkdir -p $(SCHEMA_DIR)
	@mkdir -p $(BIN_DIR)
	@install $(VALIDATOR_SRC_DIR)/Xerces-xsdValid $(VALIDATOR_BIN_DIR)
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
	my $addltarget = 'workflow_install';
	$installstr =~ s/(pure_install\s+::\s+)(.*)/$1 $2 $addltarget/;
	return $installstr;
    }
    else{
	return $self->MM::install(@_);
    }
}
