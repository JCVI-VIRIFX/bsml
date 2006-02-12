INCLUDE = -I/usr/include
LIBDIR = -L/usr/lib

CXX = g++
LINK = g++
CXXFLAGS = -O2
LIBRARIES = -lxerces-c

SCHEMA_DIR = /usr/local/devel/ANNOTATION/shared/doc/schema
BIN_DIR =/usr/local/devel/ANNOTATION/shared/bin

Xerces-xsdValid:  SAX2Print.cpp SAX2Print.hpp SAX2PrintHandlers.o
	$(CXX) $(CXXFLAGS) $(INCLUDE) $(LIBDIR) -o Xerces-xsdValid SAX2Print.cpp SAX2PrintHandlers.o $(LIBRARIES)

SAX2PrintHandlers.o: SAX2PrintHandlers.cpp SAX2PrintHandlers.hpp
	$(CXX) $(CXXFLAGS) $(INCLUDE) -c SAX2PrintHandlers.cpp

clean:
	rm -f *.o Xerces-xsdValid *.hpp~ *.cpp~ Makefile~

install : Xerces-xsdValid
	@mkdir -p $(SCHEMA_DIR)
	@mkdir -p $(BIN_DIR)
	@install Xerces-xsdValid $(BIN_DIR)
	@install xsdValid.pl $(BIN_DIR)
	@install dtdValid.pl $(BIN_DIR)
	@install ../*.xsd $(SCHEMA_DIR)
	@install ../*.dtd $(SCHEMA_DIR)
