INCLUDE = -I/usr/local/packages/xerces-c++/include
LIBDIR = -L/usr/local/packages/xerces-c++/lib

CXX = g++
LINK = g++
CXXFLAGS = -O2
LIBRARIES = -lxerces-c

Xerces-xsdValid:  SAX2Print.cpp SAX2Print.hpp SAX2PrintHandlers.o
	$(CXX) $(CXXFLAGS) $(INCLUDE) $(LIBDIR) -o Xerces-xsdValid SAX2Print.cpp SAX2PrintHandlers.o $(LIBRARIES)

SAX2PrintHandlers.o: SAX2PrintHandlers.cpp SAX2PrintHandlers.hpp
	$(CXX) $(CXXFLAGS) $(INCLUDE) -c SAX2PrintHandlers.cpp

clean:
	rm -f *.o Xerces-xsdValid *.hpp~ *.cpp~ Makefile~
