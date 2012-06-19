//
//  PhotoResponse.m
//  Kevin Gibbon the app
//
//  Created by Kevin Gibbon on 12-06-19.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "PhotoResponse.h"

@implementation PhotoResponse

@synthesize photos;

-(PhotoResponse*) initWithDictonary: (NSDictionary*) dictonary {
    self = [super init];
	photos = [[NSMutableArray alloc] init];
	if (dictonary != nil)
    {
        id nextObject;
        NSEnumerator *enumerator = [dictonary objectEnumerator];
        while ((nextObject = [enumerator nextObject]) != nil)
        {
            NSDictionary *dataDict = nextObject;
            NSDictionary *oembedDict = [dataDict objectForKey:@"oembed"];
            if (oembedDict != nil)
            {
                [photos addObject:[oembedDict objectForKey:@"url"]];
            }
        }
        
    }
    return self;
}


@end
