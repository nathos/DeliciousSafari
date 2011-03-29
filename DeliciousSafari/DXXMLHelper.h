//
//  DXXMLHelper.h
//  DeliciousSafari
//
//  Created by Doug on 12/6/09.
//  Copyright 2009 Douglas Richardson. All rights reserved.
//

#import <Foundation/Foundation.h>
#include <libxml/tree.h>
#include <libxml/xpath.h>

@interface DXXMLHelper : NSObject
{
	xmlDocPtr mDocument;
    xmlXPathContextPtr mXPathContext;
}

-(id)initWithXML:(NSData*)xmlDocData;
+(DXXMLHelper*)helperFromXMLDocData:(NSData*)xmlDocData;

-(xmlXPathObjectPtr)evaluateXPath:(NSString*)xPathQuery;
@end
