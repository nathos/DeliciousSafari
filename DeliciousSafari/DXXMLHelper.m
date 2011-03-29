//
//  DXXMLHelper.m
//  DeliciousSafari
//
//  Created by Doug on 12/6/09.
//  Copyright 2009 Douglas Richardson. All rights reserved.
//

#import "DXXMLHelper.h"

#include <libxml/parser.h>

@implementation DXXMLHelper

-(id)initWithXML:(NSData*)xmlDocData
{
	self = [super init];
	
	if(self)
	{
		if(xmlDocData == nil)
		{
			NSLog(@"[DXXMLHelper xmlDocData] - Got nil parameter for XML document data.");
			goto problem;
		}
		
		mDocument = xmlParseMemory([xmlDocData bytes], [xmlDocData length]);
		if (mDocument == NULL)
		{
			NSLog(@"[DXXMLHelper xmlDocData]: unable to parse XML document.");
			goto problem;
		}
	}
	
	return self;
	
problem:
	[self release];
	return nil;
}

-(void)dealloc
{
	//xmlXPathFreeObject(xpathObj);
	
	if(mXPathContext)
		xmlXPathFreeContext(mXPathContext);
	
	if(mDocument)
		xmlFreeDoc(mDocument); 
	
	[super dealloc];
}

+(DXXMLHelper*)helperFromXMLDocData:(NSData*)xmlDocData
{
	return [[[self alloc] initWithXML:xmlDocData] autorelease];
}

-(xmlXPathObjectPtr)evaluateXPath:(NSString*)xPathQuery
{
	if(mXPathContext != NULL)
		xmlXPathFreeContext(mXPathContext);
	
	if(xPathQuery == nil)
	{
		NSLog(@"[DXXMLHelper evaluateXPath] - Invalid (nil) XPath query parameter.");
		return NULL;
	}
	
    mXPathContext = xmlXPathNewContext(mDocument);
    if(mXPathContext == NULL)
	{
        NSLog(@"[DXXMLHelper evaluateXPath] - Could not create XPath context.");
        return NULL;
    }
	
	xmlXPathObjectPtr xpathObj = xmlXPathEvalExpression((xmlChar*)[xPathQuery UTF8String], mXPathContext);
    if(xpathObj == NULL)
	{
        NSLog(@"[DXXMLHelepr evaluateXPath] Unable to evaluate xpath expression \"%@\"\n", xPathQuery);
		return NULL;
    }
	
	return xpathObj;
}

@end
