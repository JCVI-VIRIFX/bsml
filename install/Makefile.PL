use ExtUtils::MakeMaker;
require ExtUtils::Manifest;

if(stat "MANIFEST"){}
else{
    ExtUtils::Manifest::mkmanifest();
  }

WriteMakefile(
	      'NAME'=>'BSML'
	      );

package MY;

sub MY::postamble { 
    my $postamble = "WORKFLOW_DOCS_DIR=$workflowdocsdir";
    $postamble .= << 'END';

validation: Xerces-xsdValid validation_install

Xerces-xsdValid:  SAX2Print.cpp SAX2Print.hpp SAX2PrintHandlers.o
	$(CXX) $(CXXFLAGS) $(INCLUDE) $(LIBDIR) -o Xerces-xsdValid SAX2Print.cpp SAX2PrintHandlers.o $(LIBRARIES)

SAX2PrintHandlers.o: SAX2PrintHandlers.cpp SAX2PrintHandlers.hpp
	$(CXX) $(CXXFLAGS) $(INCLUDE) -c SAX2PrintHandlers.cpp

install : Xerces-xsdValid
	@mkdir -p $(SCHEMA_DIR)
	@mkdir -p $(BIN_DIR)
	@install Xerces-xsdValid $(BIN_DIR)
	@install xsdValid.pl $(BIN_DIR)
	@install dtdValid.pl $(BIN_DIR)
	@install ../*.xsd $(SCHEMA_DIR)
	@install ../*.dtd $(SCHEMA_DIR)

