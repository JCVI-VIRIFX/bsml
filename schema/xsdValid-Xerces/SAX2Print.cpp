/*
 * The Apache Software License, Version 1.1
 *
 * Copyright (c) 1999-2001 The Apache Software Foundation.  All rights
 * reserved.
 *
 * Redistribution and use in source and binary forms, with or without
 * modification, are permitted provided that the following conditions
 * are met:
 *
 * 1. Redistributions of source code must retain the above copyright
 *    notice, this list of conditions and the following disclaimer.
 *
 * 2. Redistributions in binary form must reproduce the above copyright
 *    notice, this list of conditions and the following disclaimer in
 *    the documentation and/or other materials provided with the
 *    distribution.
 *
 * 3. The end-user documentation included with the redistribution,
 *    if any, must include the following acknowledgment:
 *       "This product includes software developed by the
 *        Apache Software Foundation (http://www.apache.org/)."
 *    Alternately, this acknowledgment may appear in the software itself,
 *    if and wherever such third-party acknowledgments normally appear.
 *
 * 4. The names "Xerces" and "Apache Software Foundation" must
 *    not be used to endorse or promote products derived from this
 *    software without prior written permission. For written
 *    permission, please contact apache\@apache.org.
 *
 * 5. Products derived from this software may not be called "Apache",
 *    nor may "Apache" appear in their name, without prior written
 *    permission of the Apache Software Foundation.
 *
 * THIS SOFTWARE IS PROVIDED ``AS IS'' AND ANY EXPRESSED OR IMPLIED
 * WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES
 * OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
 * DISCLAIMED.  IN NO EVENT SHALL THE APACHE SOFTWARE FOUNDATION OR
 * ITS CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL,
 * SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT
 * LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF
 * USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
 * ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY,
 * OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT
 * OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF
 * SUCH DAMAGE.
 * ====================================================================
 *
 * This software consists of voluntary contributions made by many
 * individuals on behalf of the Apache Software Foundation, and was
 * originally based on software copyright (c) 1999, International
 * Business Machines, Inc., http://www.ibm.com .  For more information
 * on the Apache Software Foundation, please see
 * <http://www.apache.org/>.
 */

/*
 * $Log: SAX2Print.cpp,v $
 * Revision 1.2  2003/08/14 19:52:56  chauser
 * revised output of xsdValid and dtdValid for db2bsml, added usage statements
 *
 * Revision 1.1  2003/05/15 14:39:40  chauser
 * Xerces xsdValid added to schema directory
 *
 * Revision 1.12  2002/06/17 15:33:00  tng
 * Name Xerces features as XMLUni::fgXercesXXXX instead of XMLUni::fgSAX2XercesXXXX so that they can be shared with DOM parser.
 *
 * Revision 1.11  2002/05/28 20:20:26  tng
 * Add option '-n' to SAX2Print.
 *
 * Revision 1.10  2002/04/17 20:18:08  tng
 * [Bug 7493] The word "occured" is misspelled and it is a global error.
 *
 * Revision 1.9  2002/02/13 16:11:06  knoaman
 * Update samples to use SAX2 features/properties constants from XMLUni.
 *
 * Revision 1.8  2002/02/06 16:36:51  knoaman
 * Added a new flag '-p' to SAX2 samples to set the 'namespace-prefixes' feature.
 *
 * Revision 1.7  2002/02/01 22:40:44  peiyongz
 * sane_include
 *
 * Revision 1.6  2001/10/25 15:18:33  tng
 * delete the parser before XMLPlatformUtils::Terminate.
 *
 * Revision 1.5  2001/10/19 19:02:43  tng
 * [Bug 3909] return non-zero an exit code when error was encounted.
 * And other modification for consistent help display and return code across samples.
 *
 * Revision 1.4  2001/08/02 17:10:29  tng
 * Allow DOMCount/SAXCount/IDOMCount/SAX2Count to take a file that has a list of xml file as input.
 *
 * Revision 1.3  2001/08/01 19:11:01  tng
 * Add full schema constraint checking flag to the samples and the parser.
 *
 * Revision 1.2  2000/08/09 22:20:38  jpolast
 * updates for changes to sax2 core functionality.
 *
 * Revision 1.1  2000/08/02 19:16:14  jpolast
 * initial checkin of SAX2Print
 *
 *
 */


// ---------------------------------------------------------------------------
//  Includes
// ---------------------------------------------------------------------------
#include <xercesc/util/PlatformUtils.hpp>
#include <xercesc/util/TransService.hpp>
#include <xercesc/sax2/SAX2XMLReader.hpp>
#include <xercesc/sax2/XMLReaderFactory.hpp>
#include <xercesc/framework/StdInInputSource.hpp>
#include <stdio.h>
#include "SAX2Print.hpp"


// ---------------------------------------------------------------------------
//  Local data
//
//  encodingName
//      The encoding we are to output in. If not set on the command line,
//      then it is defaulted to LATIN1.
//
//  xmlFile
//      The path to the file to parser. Set via command line.
//
//  valScheme
//      Indicates what validation scheme to use. It defaults to 'auto', but
//      can be set via the -v= command.
//
//	expandNamespaces
//		Indicates if the output should expand the namespaces Alias with
//		their URI's, defaults to false, can be set via the command line -e
// ---------------------------------------------------------------------------
static const char*              encodingName    = "LATIN1";
static XMLFormatter::UnRepFlags unRepFlags      = XMLFormatter::UnRep_CharRef;
static char*                    xmlFile         = 0;
//char *xmlFile;
static SAX2XMLReader::ValSchemes valScheme      = SAX2XMLReader::Val_Auto;
static bool					        expandNamespaces= false ;
static bool                     doNamespaces    = true;
static bool                     doSchema        = true;
static bool                     schemaFullChecking = false;
static bool                     namespacePrefixes = false;


// ---------------------------------------------------------------------------
//  Local helper methods
// ---------------------------------------------------------------------------
static void usage()
{
  cout << "./Xerces-xsdValid << file.xml\n";
  cout << "Prints xml error codes if validation is not successful, nothing if it is.\n";

  exit(0);
}



// ---------------------------------------------------------------------------
//  Program entry point
// ---------------------------------------------------------------------------
int main(int argC, char* argV[])
{
  if( argC > 1)
    {
      usage();
    }

    // Initialize the XML4C2 system
    try
    {
         XMLPlatformUtils::Initialize();
    }

    catch (const XMLException& toCatch)
    {
         cerr << "Error during initialization! :\n"
              << StrX(toCatch.getMessage()) << endl;
         return 1;
    }

  
    //
    //  Create a SAX parser object. Then, according to what we were told on
    //  the command line, set it to validate or not.
    //
    SAX2XMLReader* parser = XMLReaderFactory::createXMLReader();

    //
    //  Then, according to what we were told on
    //  the command line, set it to validate or not.
    //
    if (valScheme == SAX2XMLReader::Val_Auto)
    {
        parser->setFeature(XMLUni::fgSAX2CoreValidation, true);
        parser->setFeature(XMLUni::fgXercesDynamic, true);
    }

    if (valScheme == SAX2XMLReader::Val_Never)
    {
        parser->setFeature(XMLUni::fgSAX2CoreValidation, false);
    }

    if (valScheme == SAX2XMLReader::Val_Always)
    {
        parser->setFeature(XMLUni::fgSAX2CoreValidation, true);
        parser->setFeature(XMLUni::fgXercesDynamic, false);
    }

    parser->setFeature(XMLUni::fgSAX2CoreNameSpaces, doNamespaces);
    parser->setFeature(XMLUni::fgXercesSchema, doSchema);
    parser->setFeature(XMLUni::fgXercesSchemaFullChecking, schemaFullChecking);
    parser->setFeature(XMLUni::fgSAX2CoreNameSpacePrefixes, namespacePrefixes);

    //
    //  Create the handler object and install it as the document and error
    //  handler for the parser. Then parse the file and catch any exceptions
    //  that propogate out
    //

    int errorCount = 0;
    try
    {
      SAX2PrintHandlers handler(encodingName, unRepFlags, expandNamespaces);
      parser->setErrorHandler(&handler);
    
      
	StdInInputSource::StdInInputSource *inputXML = new StdInInputSource::StdInInputSource();
	parser->parse(*inputXML);
        errorCount = parser->getErrorCount();
    }

    catch (const XMLException& toCatch)
    {
        cerr << "\nAn error occurred\n  Error: "
             << StrX(toCatch.getMessage())
             << "\n" << endl;
        XMLPlatformUtils::Terminate();
        return 4;
    }

    //
    //  Delete the parser itself.  Must be done prior to calling Terminate, below.
    //
    delete parser;

    // And call the termination method
    XMLPlatformUtils::Terminate();

    if (errorCount > 0)
      {
	cout << "Invalid XML document\n";
	return 4;
      }
    else
      {
	return 0;
      }
}

