//
//  RestHelper.h
//  Kevin Gibbon the app
//
//  Created by Kevin Gibbon on 6/19/12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//
#import <Foundation/Foundation.h>
#import "PhotoResponse.h"

#define FACEBOOK @"facebook"
#define TWITTER @"twitter"
#define INSTAGRAM @"instagram"

@protocol RestHelperDelegate;

@interface RestHelper : NSObject

@property (strong) id <RestHelperDelegate> delegate;
@property (strong) NSOperationQueue * queue;
-(NSDictionary*) getJSONDataHttp: (NSString*) accessToken : (NSNumber*) offset;
-(void) retrievePhotos: (NSString*) socialType :(PhotoResponse*) photoResponse :(NSNumber*)offset;
-(void) retrievePhotos: (NSArray*) array;

+(NSString*) getUDID;


@end

@protocol RestHelperDelegate 

- (void)restHelperDidLoad;
@end
