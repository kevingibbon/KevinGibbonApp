//
//  RestHelper.h
//  Kevin Gibbon the app
//
//  Created by Kevin Gibbon on 6/19/12.
//  Copyright 2012 __MyCompanyName__. All rights reserved.
//

#import "RestHelper.h"

@implementation RestHelper

#define SERVER_URL @"https://api.singly.com/v0/types/photos?access_token="

@synthesize delegate;
@synthesize queue;

-(RestHelper*) init {
	 self = [super init];
	 queue = [NSOperationQueue new];
	 return self;
}

-(NSDictionary*) getJSONDataHttp: (NSString*) accessToken {
	NSError* error = nil;
	NSURLResponse* response = nil;
	NSMutableURLRequest* request = [[NSMutableURLRequest alloc] init];
    [request setHTTPMethod:@"GET"];
	NSURL* url = [NSURL URLWithString:[NSString stringWithFormat:@"%@%@", SERVER_URL, accessToken]];
	[request setURL:url];
	[request setTimeoutInterval:1200];
	
	NSData* data = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&error];
	NSString *jsonString = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
	NSLog(@"Here is what we sent %@", [request allHTTPHeaderFields]);
    NSLog(@"Here is what we got %@", jsonString);
	
    NSDictionary* json = [NSJSONSerialization 
                          JSONObjectWithData:data
                          options:kNilOptions 
                          error:&error];
    if (error)
    {
        NSLog(@"Error performing request %@", url);
    }                                    
	return json;
}

+(NSString*) getUDID {
    NSString* result;
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString* udidDefaults = [defaults objectForKey:@"UDID"];
    if (udidDefaults == nil)
    {
        CFUUIDRef theUUID = CFUUIDCreate(NULL);
        CFStringRef string = CFUUIDCreateString(NULL, theUUID);
        result = (__bridge NSString*) string;
        [defaults setObject:result forKey:@"UDID"];
    }
    else {
        
        result = udidDefaults;
    }
    return result;
}

-(void) retrievePhotos: (NSArray*) array {
	NSString *socialType = [array objectAtIndex:0];
	PhotoResponse *photoResponse = [array objectAtIndex:1];
    NSString *accessToken = @"";
    if ([socialType isEqualToString:FACEBOOK])
    {
        accessToken = @"SndQKvjQYlc4gsQ3J1s2ukFwYJI=dAn_RXJj0072c3a5062f9902aadec411a65b786fdaa940e5f915f3b41e8954fe0ac7281864eec492d598c334cecbc9d4b173004ac6f94537bc7b931bf88c57ab76791420616f173f2c8b990c4c239f0fc66f88bc7e216e98367e4eac9f9cd5551697889cb3f11478f1806f6e5a79b6f6574f2a88";
    }
    else if ([socialType isEqualToString:TWITTER])
    {
        accessToken = @"TcJ4hjitilb6w1TgFPRVGZwA8T4=2Tw8zaR2c7909fe7d2de31a88cb9956b9887a0d842083cd1a593a8ec1f76d127b8f93f5863b3e42881c8f2d6317cad685a312924362bf346d8e1212032c4eee59e753fee8c49564a508c24fde3b05a99c7844da9f20cfa57d6733b4c2c1b2f1b2bbd360b8b524aff85165ed28fac774f29a88077";
    }
    else if ([socialType isEqualToString:INSTAGRAM])
    {
        accessToken = @"vKhUIuVUPmBw5VVW4Gm9n9-Lfbc=P9m8G62Xcb4dbc938d68014bf85701b93bddcd7f3c7a9f90124f65250ad949357ae3b175c7c66ba4de91c549875868a398544d6a1407f5ffd8947803137fe556233d2ecfd6e8590170012d233c9244986936a06b28b8e43264322075c3ef9a904c11e5f9ccfaf8d9e6bde83055b11f9a36e735ab";
    }
	NSDictionary *dictonary =  [self getJSONDataHttp:accessToken];
	if (photoResponse != nil && ![queue isSuspended])
	{
        __unused PhotoResponse *spr = [photoResponse initWithDictonary:dictonary];
		
		if (delegate != nil)
		{
			[delegate restHelperDidLoad];
		}
	}
}


-(void) retrievePhotos: (NSString*) socialType :(PhotoResponse*) photoResponse{
	NSArray  *myParams = [NSArray arrayWithObjects:socialType,photoResponse,nil];
    
    NSInvocationOperation *operation = [[NSInvocationOperation alloc] initWithTarget:self
																			selector:@selector(retrievePhotos:)
										
																			  object:myParams];
	[queue addOperation:operation];
}



-(void) dealloc {
	delegate = nil;
}



@end
