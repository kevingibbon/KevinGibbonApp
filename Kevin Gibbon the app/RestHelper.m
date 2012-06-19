//
//  RestHelper.m
//  Shop Around
//
//  Created by Kevin Gibbon on 8/29/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "RestHelper.h"
#import "Smart_AislesAppDelegate.h"
#import "Store.h"
#import "FlurryAnalytics.h"
#import "JSONKit.h"
#import "StoresFindInRangeParameters.h"
#import "FileHelper.h"

@implementation RestHelper

//#define SERVER_URL @"http://smartaisles.elasticbeanstalk.com"
//#define SERVER_URL @"http://192.168.0.100:8081/WebServices"
//#define SERVER_URL @"http://64.46.30.180:8080/WebServices"
//#define SERVER_URL @"http://192.168.2.10:8081/WebServices"
//#define SERVER_URL @"http://192.168.2.30:8080/WebServices"
#define SERVER_URL @"http://server.smartaisles.com"

//#define SERVER_URL @"http://192.168.1.131:8080/WebServices"
//#define SERVER_URL @"http://shoparound.elasticbeanstalk.com"
//#define SERVER_URL @"http://smartaisles-public-2.elasticbeanstalk.com"

@synthesize delegate;
@synthesize queue;

static NSString *url;
+ (NSString *)url { 
    if (url == nil)
    {
        return SERVER_URL;
    }
    return url;
}
+ (void)setUrl:(NSString *)newUrl { url = newUrl; }

-(RestHelper*) init {
	 self = [super init];
	 queue = [NSOperationQueue new];
	 return self;
}

-(NSDictionary*) getJSONDataHttp: (HttpType) httpType :(NSString*) url :(NSString*) loginId :(NSString*) loginPw :(NSString*) jsonData :(BOOL) cacheData :(NSString*) messageType
{
	NSError* error = nil;
	NSURLResponse* response = nil;
	NSMutableURLRequest* request = [[NSMutableURLRequest alloc] init];
	if (httpType == kGet)
	{
		[request setHTTPMethod:@"GET"];
	}
	else if (httpType == kPost)
	{
		[request setHTTPMethod:@"POST"];
	}
	else if (httpType == kPut)
	{
		[request setHTTPMethod:@"PUT"];
	}
	else if (httpType == kDelete)
	{
		[request setHTTPMethod:@"DELETE"];
	}
	[request addValue:@"application/json;charset=UTF-8" forHTTPHeaderField:@"Content-Type"];
	[request addValue:@"application/json" forHTTPHeaderField:@"Accept"];
	[request addValue:loginId forHTTPHeaderField:@"Username"];
	[request addValue:loginPw forHTTPHeaderField:@"Password"];
    [request addValue:messageType forHTTPHeaderField:@"messageType"];
	
	NSString *deviceID = [RestHelper getUDID];
	[request addValue:deviceID forHTTPHeaderField:@"DeviceId"];
	
	
	NSLocale *currentUsersLocale = [NSLocale currentLocale];  
	NSString *currentLocaleID = [currentUsersLocale localeIdentifier];
	
	NSString *acceptLanguage = [currentLocaleID stringByReplacingOccurrencesOfString:@"_" withString:@"-"];
	
	[request addValue:acceptLanguage forHTTPHeaderField:@"Accept-Language"];
	
	
	NSDictionary* infoDict = [[NSBundle mainBundle] infoDictionary];
	NSString *versionNum = [@"/" stringByAppendingString:[infoDict objectForKey:@"CFBundleVersion"]];
	NSString *userAgent = [[@"iPhone " stringByAppendingString:[[UIDevice currentDevice] systemVersion]] stringByAppendingString:versionNum];
	
	
	[request addValue:userAgent forHTTPHeaderField:@"User-Agent"];
	
	
	
	NSURL* URL = [NSURL URLWithString:url];
	
	
	
	
	
	[request setURL:URL];
	if (cacheData)
	{
		NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
		NSDate *lastLoad = [defaults objectForKey:url];
		if (lastLoad == nil)
		{
			[request setCachePolicy:NSURLRequestReloadIgnoringLocalAndRemoteCacheData];
			NSDate *now = [[NSDate alloc] init];
			[defaults setObject:now forKey:url];
			[defaults synchronize];
		}
		else {
			NSTimeInterval timeInterval = [lastLoad timeIntervalSinceNow];
			if (timeInterval < -3600)
			{
				NSDate *now = [[NSDate alloc] init];
				[defaults setObject:now forKey:url];
				[defaults synchronize];
				[request setCachePolicy:NSURLRequestReloadIgnoringLocalAndRemoteCacheData];
			}
			else {
				[request setCachePolicy:NSURLRequestReturnCacheDataElseLoad];
			}
		}
	}
	else
	{
		[request setCachePolicy:NSURLRequestReloadIgnoringLocalAndRemoteCacheData];

	}
	if (jsonData)
	{
		NSData* requestData = [jsonData dataUsingEncoding:NSUTF8StringEncoding];
		[request setHTTPBody:requestData];
		NSString* requestDataLengthString = [[NSString alloc] initWithFormat:@"%d", [requestData length]];
		[request setValue:requestDataLengthString forHTTPHeaderField:@"Content-Length"];
	}



	[request setTimeoutInterval:1200];
	
	NSData* data = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&error];
	
	if (error)
	{
		//NSLog(@"Error performing request %@", url);
	}
	
	NSString *jsonString = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    //NSLog(@"This is the url we executed %@", url);
	NSLog(@"Here is what we sent %@ header : jsonData : %@", [request allHTTPHeaderFields], jsonData);
    NSLog(@"Here is what we got %@", jsonString);
	
	return [jsonString objectFromJSONString];
}



-(void) loginUserNewThread: (NSString*) user :(NSString*) password :(UserResponse*) userResponse{
    [FlurryAnalytics logEvent:@"loginUser"];
	
	NSArray  * myParams = [NSArray arrayWithObjects:user,password,userResponse,nil];
	
	NSInvocationOperation *operation = [[NSInvocationOperation alloc] initWithTarget:self
																			selector:@selector(loginUser:)
										
																			  object:myParams];
	
	[queue addOperation:operation];
	
}

-(void) loginUser: (NSArray*) array{
	
	NSString* user = [array objectAtIndex:0];
	NSString* password = [array objectAtIndex:1];
	UserResponse* userResponse = [array objectAtIndex:2];
    NSString* url = [NSString stringWithFormat:@"%@/rest/enduser/v1", [RestHelper url]];                 
            
	NSDictionary* loginUserDictionary = [self getJSONDataHttp:kPut :url :user :password :nil :FALSE :@"EndUserLoginRequest"];
	
	if (userResponse != nil && ![queue isSuspended])
	{
		__unused UserResponse *ur = [userResponse initWithDictonary:loginUserDictionary :user :password];
		if (delegate != nil)
		{
			[delegate restHelperDidLoad];
		}
        if ([ur.sucess boolValue] == YES)
        {
            FileHelper *fileHelper = [[FileHelper alloc] init];
            [fileHelper setCurrentUser:ur.user];
        }
	}
}

-(void) loginTempUserNewThread:(UserResponse*) userResponse{
    [FlurryAnalytics logEvent:@"loginTempUser"];
	
	NSArray  * myParams = [NSArray arrayWithObjects:userResponse,nil];
	
	NSInvocationOperation *operation = [[NSInvocationOperation alloc] initWithTarget:self
																			selector:@selector(loginTempUser:)
										
																			  object:myParams];
	[queue addOperation:operation];
	
}

-(void) loginTempUser: (NSArray*) array{
	
	UserResponse* userResponse = [array objectAtIndex:0];
	
	//NSString* url = [NSString stringWithFormat:@"%@/rest/enduser/eusers/me/login", [RestHelper url]];
	
    NSString* url = [NSString stringWithFormat:@"%@/rest/enduser/v1", [RestHelper url]];
	NSDictionary* loginUserDictionary = [self getJSONDataHttp:kPut :url :[RestHelper getUDID] :nil :nil :FALSE :@"EndUserLoginRequest"];
	
	if (userResponse != nil && ![queue isSuspended])
	{
		__unused UserResponse *ur = [userResponse initWithDictonary:loginUserDictionary :[RestHelper getUDID] :nil];
		if (delegate != nil)
		{
			[delegate restHelperDidLoad];
		}
        if ([ur.sucess boolValue] == YES)
        {
            FileHelper *fileHelper = [[FileHelper alloc] init];
            [fileHelper setCurrentUser:ur.user];
        }
	}
	
	
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

-(void) registerUserNewThread: (EndUser*) user :(UserResponse*) userResponse {
    [FlurryAnalytics logEvent:@"registerUser"];
	NSArray  * myParams = [NSArray arrayWithObjects:user,userResponse,nil];
	
	NSInvocationOperation *operation = [[NSInvocationOperation alloc] initWithTarget:self
																			selector:@selector(registerUser:)
										
																			  object:myParams];
	
	[queue addOperation:operation];
	
}
-(void) registerUser: (NSArray*) array {
    
	EndUser* user = [array objectAtIndex:0];
	UserResponse* userResponse = [array objectAtIndex:1];
	
	
	//NSString* url = [NSString stringWithFormat:@"%@/rest/enduser/eusers", [RestHelper url]];
	NSString* url = [NSString stringWithFormat:@"%@/rest/enduser/v1", [RestHelper url]];
    
    
	NSString* JSON = [user createJSONString :YES];
	NSDictionary* loginUserDictionary = [self getJSONDataHttp:kPut :url :nil :nil :JSON :FALSE :@"EndUserRegisterRequest"];
	
	if (userResponse != nil && ![queue isSuspended])
	{
		__unused UserResponse *ur = [userResponse initWithDictonary:loginUserDictionary :user.loginId :user.loginPw];
		if (delegate != nil)
		{
			[delegate restHelperDidLoad];
		}
	}
	
}

-(void) updateUserNewThread: (EndUser*) user :(UserResponse*) userResponse {
    NSArray  * myParams = [NSArray arrayWithObjects:user,userResponse,nil];
	
    NSInvocationOperation *operation = [[NSInvocationOperation alloc] initWithTarget:self
																			selector:@selector(updateUser:)
										
																			  object:myParams];
	
        [queue addOperation:operation];
	
}
-(void) updateUser: (NSArray*) array {
	EndUser* user = [array objectAtIndex:0];
	UserResponse* userResponse = [array objectAtIndex:1];
	
	
	//NSString* url = [NSString stringWithFormat:@"%@/rest/enduser/eusers", [RestHelper url]];
    NSString* url = [NSString stringWithFormat:@"%@/rest/enduser/v1", [RestHelper url]];
	
	NSString* JSON = [user createJSONString: NO];
	NSDictionary* loginUserDictionary = [self getJSONDataHttp:kPut :url :user.loginId :user.loginPw :JSON :FALSE :@"EndUserUpdateRequest"];
	
	if (userResponse != nil && ![queue isSuspended])
	{
		__unused UserResponse *ur = [userResponse initWithDictonary:loginUserDictionary :user.loginId :user.loginPw];
		if (delegate != nil)
		{
			[delegate restHelperDidLoad];
		}
	}
	
}

+ (void) addStringToArray :(NSMutableArray*) array :(NSString*) stringToAdd
{
    if (stringToAdd == nil)
    {
        [array addObject:[NSNull null]];
    }
    else
    {
        [array addObject:stringToAdd];
    }
    
}

+ (void) addKeyStringToArray :(NSMutableArray*) keyArray :(NSMutableArray*) array :(NSString*) keyToAdd :(NSString*) stringToAdd
{
    if (stringToAdd != nil)
    {
        [keyArray addObject:keyToAdd];
        [array addObject:stringToAdd];
    }
}

+ (void) addArrayToArray :(NSMutableArray*) array :(NSMutableArray*) arrayToAdd
{
    if (arrayToAdd == nil)
    {
        [array addObject:[NSNull null]];
    }
    else
    {
        [array addObject:arrayToAdd];
    }
    
}

+ (void) addNumberToArray :(NSMutableArray*) array :(NSNumber*) numberToAdd
{
    if (numberToAdd == nil)
    {
        [array addObject:[NSNull null]];
    }
    else
    {
        [array addObject:numberToAdd];
    }
    
}

-(void) retreivePromotions: (NSArray*) array{
	PromoSearchParameters* promoSearchParameters = [array objectAtIndex:0];
	SearchPromoResponse* searchPromoResponse = [array objectAtIndex:1];
	
	//NSString* url = [NSString stringWithFormat:@"%@/rest/enduser/promos/search", [RestHelper url]];
	NSString* url = [NSString stringWithFormat:@"%@/rest/enduser/v1", [RestHelper url]];
    
	EndUser* user = [EndUser sharedInstance];
	NSString* JSON = [promoSearchParameters createJSONString];
	NSDictionary* searchDictonary = [self getJSONDataHttp:kPut :url :user.loginId :user.loginPw :JSON :FALSE :@"EndUserPromoSearchRequest"];
	if (searchPromoResponse != nil && ![queue isSuspended])
	{
		__unused SearchPromoResponse *spr = [searchPromoResponse initWithDictonary:searchDictonary];
		if (delegate != nil)
		{
			[delegate restHelperDidLoad];
		}
	}
}


-(void) getPromotionsThreadSafe: (PromoSearchParameters*) promoSearchParameters :(SearchPromoResponse*) searchPromoResponse{
	NSArray  * myParams = [NSArray arrayWithObjects:promoSearchParameters,searchPromoResponse,nil];
    
    NSString *searchKeyword = @"SearchFirstPage";
    NSLog(@"%@", [promoSearchParameters.pageNumber stringValue]);
    if ([promoSearchParameters.pageNumber integerValue] > 1)
    {
        searchKeyword = @"SearchGreater1Page";
        NSLog(@"SearchGreater1Page");
    }
    if (promoSearchParameters.generalValue != nil && [promoSearchParameters.generalValue length] > 0)
    {
        NSDictionary *searchParameters= [NSDictionary dictionaryWithObjectsAndKeys:promoSearchParameters.generalValue, @"Search Term", nil   ]; 
        [FlurryAnalytics logEvent:searchKeyword withParameters:searchParameters];
    }
    else
    {
        [FlurryAnalytics logEvent:[NSString stringWithFormat:@"%@%@",searchKeyword,@"NoSearchTerm"]];
    }
	NSInvocationOperation *operation = [[NSInvocationOperation alloc] initWithTarget:self
																			selector:@selector(retreivePromotions:)
										
																			  object:myParams];
	
	[queue addOperation:operation];
}

-(void) retreiveCategories: (NSArray*) array{
	NSMutableArray* storeIds = [array objectAtIndex:0];
	NSString* day = [array objectAtIndex:1];
    CategoriesResponse* categoryResponse = [array objectAtIndex:2];
	
	//NSString* url = [NSString stringWithFormat:@"%@/rest/enduser/promos/search", [RestHelper url]];
	NSString* url = [NSString stringWithFormat:@"%@/rest/enduser/v1", [RestHelper url]];
    
	EndUser* user = [EndUser sharedInstance];
    
    NSArray *keys = [NSArray arrayWithObjects:@"day", @"storeIds",nil];
    
    NSArray *objects = [NSArray arrayWithObjects:day, storeIds,nil];
    
    NSDictionary *dictionary = [NSDictionary dictionaryWithObjects:objects 
														   forKeys:keys];
    
	NSString *jsonData = (NSString*) [dictionary JSONString];
	NSDictionary* searchDictonary = [self getJSONDataHttp:kPut :url :user.loginId :user.loginPw :jsonData :FALSE :@"CategoriesFindByStoresRequest"];
	if (categoryResponse != nil && ![queue isSuspended])
	{
		__unused CategoriesResponse *spr = [categoryResponse initWithDictonary:searchDictonary];
		if (delegate != nil)
		{
			[delegate restHelperDidLoad];
		}
	}
}


-(void) getCategoriesThreadSafe: (NSMutableArray*) storeIds :(NSString*) day :(CategoriesResponse*) categoryResponse{
	NSArray  * myParams = [NSArray arrayWithObjects:storeIds,day,categoryResponse,nil];
    
	NSInvocationOperation *operation = [[NSInvocationOperation alloc] initWithTarget:self
																			selector:@selector(retreiveCategories:)
										
																			  object:myParams];
	
	[queue addOperation:operation];
}

-(CompanyResponse*) retrieveCompany: (NSString*) compId{

	Smart_AislesAppDelegate *appDelegate = (Smart_AislesAppDelegate *)[[UIApplication sharedApplication] delegate];
	NSMutableDictionary* companies = appDelegate.companies;

	Company* cacheCompany = [companies objectForKey:compId];
	if (cacheCompany)
	{
        return [[CompanyResponse alloc] initCompanyWithCompany:cacheCompany];
	}
	NSString* url = [NSString stringWithFormat:@"%@/rest/enduser/v1", [RestHelper url]];
    NSArray *keys = [NSArray arrayWithObjects:@"compId", nil];
	
    NSNumberFormatter * f = [[NSNumberFormatter alloc] init];
    [f setNumberStyle:NSNumberFormatterDecimalStyle];
    NSArray *objects = [NSArray arrayWithObjects:[f numberFromString:compId], nil];
    
    NSDictionary *dictionary = [NSDictionary dictionaryWithObjects:objects 
														   forKeys:keys];
    
	NSString *jsonData = (NSString*) [dictionary JSONString];
    
    
	EndUser* user = [EndUser sharedInstance];
	NSDictionary* companiesResponseDictionary = [self getJSONDataHttp:kPut :url :user.loginId :user.loginPw :jsonData :FALSE :@"CompanyFindRequest"];
	
	CompanyResponse *companyResponse = [[CompanyResponse alloc] initCompanyWithDictonary:companiesResponseDictionary];
	
	if ([companyResponse.sucess boolValue] == YES)
	{
		[companies setObject: companyResponse.company forKey: compId];
	}
	return companyResponse;
}


-(void) getCompaniesWithStoresNewThread: (NSString*) latitude :(NSString*) longitude :(NSString*) rangeKm :(CompaniesResponse*) companiesResponse{
	NSArray  * myParams = [NSArray arrayWithObjects:latitude,longitude,rangeKm,companiesResponse,nil];
	
	NSInvocationOperation *operation = [[NSInvocationOperation alloc] initWithTarget:self
																			selector:@selector(retrieveCompaniesWithStores:)
										
																			  object:myParams];
    [FlurryAnalytics logEvent:@"retrieveCompaniesWithStores"];
	[queue addOperation:operation];
}

-(void) retrieveCompaniesWithStores: (NSArray*) array {
	NSString* latitude = [array objectAtIndex:0];
	NSString* longitude = [array objectAtIndex:1];
	NSString* rangeKm = [array objectAtIndex:2];
	CompaniesResponse* companiesResponse = [array objectAtIndex:3];

	StoresFindInRangeParameters *parameters = [[StoresFindInRangeParameters alloc] init];
    [parameters setLatitude:latitude];
    [parameters setLongitude:longitude];
    NSNumberFormatter * f = [[NSNumberFormatter alloc] init];
    [f setNumberStyle:NSNumberFormatterDecimalStyle];
    [parameters setRangeInKm:[f numberFromString:rangeKm]];
    
	//NSString* url = [NSString stringWithFormat:@"%@/rest/enduser/companies/%@,%@,%@", [RestHelper url],latitude,longitude,rangeKm];
	NSString* url = [NSString stringWithFormat:@"%@/rest/enduser/v1", [RestHelper url]];
    
	EndUser* user = [EndUser sharedInstance];
	NSDictionary* companiesResponseDictionary = [self getJSONDataHttp:kPut :url :user.loginId :user.loginPw :[parameters createJSONString] :TRUE :@"StoresFindInRangeRequest"];
	
    Smart_AislesAppDelegate *appDelegate = (Smart_AislesAppDelegate *)[[UIApplication sharedApplication] delegate];
	NSMutableDictionary* companies = appDelegate.companies;
	if (companiesResponse != nil && ![queue isSuspended])
	{
		__unused CompaniesResponse *cr = [companiesResponse initWithDictonary:companiesResponseDictionary];
	
		Smart_AislesAppDelegate *appDelegate = (Smart_AislesAppDelegate *)[[UIApplication sharedApplication] delegate];
        [appDelegate.localStoreIds removeAllObjects];
		if ([companiesResponse.sucess boolValue] == YES)
		{
            for (id element in companiesResponse.companies)
			{
				Company *company = element;
                [companies setObject: company forKey: company.compId];
				[appDelegate.localStoreIds addObject:company.allStoresId];
//				NSEnumerator * storeEnumerator = [company.stores objectEnumerator];
//				id storeElement;
			
//				while(storeElement = [storeEnumerator nextObject])
//				{
//					Store *store = storeElement;
//					[appDelegate.localStoreIds addObject:store.storeId];
//				}
			}
		}
        //NSLog(@"%@", appDelegate.localStoreIds);
	
		if (delegate != nil)
		{
			[delegate restHelperDidLoad];
		}
	}
}

-(void) redeemPromotion: (NSArray*) array {
    [FlurryAnalytics logEvent:@"redeemPromotion"];
	NSString* promoItemId = [array objectAtIndex:0];
	BarcodeResponse* barcodeResponse = [array objectAtIndex:1];
	
	//NSString* url = [NSString stringWithFormat:@"%@/rest/enduser/eusers/me/pitems/%@/redeem", [RestHelper url], promoItemId];
    NSString* url = [NSString stringWithFormat:@"%@/rest/enduser/v1", [RestHelper url]];
	
    NSArray *keys = [NSArray arrayWithObjects:@"pitemId", nil];
	
    NSNumberFormatter * f = [[NSNumberFormatter alloc] init];
    [f setNumberStyle:NSNumberFormatterDecimalStyle];
    NSArray *objects = [NSArray arrayWithObjects:[f numberFromString:promoItemId], nil];
    
    NSDictionary *dictionary = [NSDictionary dictionaryWithObjects:objects 
														   forKeys:keys];
    
	NSString *jsonData = (NSString*) [dictionary JSONString];
    
	EndUser* user = [EndUser sharedInstance];
	NSDictionary* genericDictonary = [self getJSONDataHttp:kPut :url :user.loginId :user.loginPw :jsonData :FALSE :@"PromoItemRedeemRequest"];
	if (barcodeResponse != nil && ![queue isSuspended])
	{
		__unused BarcodeResponse *br = [barcodeResponse initWithDictonary:genericDictonary];
		if (delegate != nil)
		{
			[delegate restHelperDidLoad];
		}
	}
}


-(void) redeemPromotionThreadSafe: (NSString*) promoItemId:(BarcodeResponse*) barcodeResponse {
	NSArray  * myParams = [NSArray arrayWithObjects:promoItemId,barcodeResponse,nil];
	
	NSInvocationOperation *operation = [[NSInvocationOperation alloc] initWithTarget:self
																			selector:@selector(redeemPromotion:)
										
																			  object:myParams];
	
	[queue addOperation:operation];
}

-(void) facebookSharePromotion: (NSArray*) array {
    [FlurryAnalytics logEvent:@"facebookSharePromotion"];
	NSString* promoItemId = [array objectAtIndex:0];
	GenericResponse* genericResponse = [array objectAtIndex:1];
	
	//NSString* url = [NSString stringWithFormat:@"%@/rest/enduser/eusers/me/pitems/%@/facebook",[RestHelper url], promoItemId];
    NSString* url = [NSString stringWithFormat:@"%@/rest/enduser/v1", [RestHelper url]];
	
    NSArray *keys = [NSArray arrayWithObjects:@"pitemId", nil];
	
    NSNumberFormatter * f = [[NSNumberFormatter alloc] init];
    [f setNumberStyle:NSNumberFormatterDecimalStyle];
    NSArray *objects = [NSArray arrayWithObjects:[f numberFromString:promoItemId], nil];
    
    NSDictionary *dictionary = [NSDictionary dictionaryWithObjects:objects 
														   forKeys:keys];
    
	NSString *jsonData = (NSString*) [dictionary JSONString];
	
	EndUser* user = [EndUser sharedInstance];
	NSDictionary* genericDictonary = [self getJSONDataHttp:kPut :url :user.loginId :user.loginPw :jsonData :FALSE :@"PromoItemFacebookRequest"];
	if (genericResponse != nil && ![queue isSuspended])
	{
		__unused GenericResponse *gr = [genericResponse initGenericWithDictonary:genericDictonary];
		if (delegate != nil)
		{
			[delegate restHelperDidLoad];
		}
	}
}


-(void) facebookSharePromotionThreadSafe: (NSString*) promoItemId:(GenericResponse*) genericResponse {
	NSArray  * myParams = [NSArray arrayWithObjects:promoItemId,genericResponse,nil];
	
	NSInvocationOperation *operation = [[NSInvocationOperation alloc] initWithTarget:self
																			selector:@selector(facebookSharePromotion:)
										
																			  object:myParams];
	
	[queue addOperation:operation];
}

-(void) addPromoToListThreadSafe: (NSString*) promoItemId {
    NSArray  * myParams = [NSArray arrayWithObjects:promoItemId,nil];
	
	NSInvocationOperation *operation = [[NSInvocationOperation alloc] initWithTarget:self
																			selector:@selector(addPromoToList:)
										
																			  object:myParams];
	
	[queue addOperation:operation];
    
}
-(void) addPromoToList: (NSArray*) array {
    [FlurryAnalytics logEvent:@"addPromoToShoppingCart"];
	NSString* promoItemId = [array objectAtIndex:0];
    NSString* url = [NSString stringWithFormat:@"%@/rest/enduser/v1", [RestHelper url]];
	
    NSArray *keys = [NSArray arrayWithObjects:@"pitemId", nil];
	
    NSNumberFormatter * f = [[NSNumberFormatter alloc] init];
    [f setNumberStyle:NSNumberFormatterDecimalStyle];
    NSArray *objects = [NSArray arrayWithObjects:[f numberFromString:promoItemId], nil];
    
    NSDictionary *dictionary = [NSDictionary dictionaryWithObjects:objects 
														   forKeys:keys];
    
	NSString *jsonData = (NSString*) [dictionary JSONString];
	
	EndUser* user = [EndUser sharedInstance];
	__unused NSDictionary* genericDictonary = [self getJSONDataHttp:kPut :url :user.loginId :user.loginPw :jsonData :FALSE :@"LogPromoItemAddToCartRequest"];
}

-(void) promoDetailedViewThreadSafe: (NSString*) promoItemId {
    NSArray  * myParams = [NSArray arrayWithObjects:promoItemId,nil];
	
	NSInvocationOperation *operation = [[NSInvocationOperation alloc] initWithTarget:self
																			selector:@selector(promoDetailedView:)
										
																			  object:myParams];
	
	[queue addOperation:operation];
}
-(void) promoDetailedView: (NSArray*) array {
    [FlurryAnalytics logEvent:@"ViewDetailedPromoView"];
	NSString* promoItemId = [array objectAtIndex:0];
    NSString* url = [NSString stringWithFormat:@"%@/rest/enduser/v1", [RestHelper url]];
	
    NSArray *keys = [NSArray arrayWithObjects:@"pitemId", nil];
	
    NSNumberFormatter * f = [[NSNumberFormatter alloc] init];
    [f setNumberStyle:NSNumberFormatterDecimalStyle];
    NSArray *objects = [NSArray arrayWithObjects:[f numberFromString:promoItemId], nil];
    
    NSDictionary *dictionary = [NSDictionary dictionaryWithObjects:objects 
														   forKeys:keys];
    
	NSString *jsonData = (NSString*) [dictionary JSONString];
	
	EndUser* user = [EndUser sharedInstance];
	__unused NSDictionary* genericDictonary = [self getJSONDataHttp:kPut :url :user.loginId :user.loginPw :jsonData :FALSE :@"LogPromoItemViewRequest"];
	
}

-(void) likePromoThreadSafe: (NSString*) promoItemId {
    NSArray  * myParams = [NSArray arrayWithObjects:promoItemId,nil];
	
	NSInvocationOperation *operation = [[NSInvocationOperation alloc] initWithTarget:self
																			selector:@selector(likePromo:)
										
																			  object:myParams];
	
	[queue addOperation:operation];
}
-(void) likePromo: (NSArray*) array {
    [FlurryAnalytics logEvent:@"ViewDetailedPromoView"];
	NSString* promoItemId = [array objectAtIndex:0];
    NSString* url = [NSString stringWithFormat:@"%@/rest/enduser/v1", [RestHelper url]];
	
    NSArray *keys = [NSArray arrayWithObjects:@"pitemId", nil];
	
    NSNumberFormatter * f = [[NSNumberFormatter alloc] init];
    [f setNumberStyle:NSNumberFormatterDecimalStyle];
    NSArray *objects = [NSArray arrayWithObjects:[f numberFromString:promoItemId], nil];
    
    NSDictionary *dictionary = [NSDictionary dictionaryWithObjects:objects 
														   forKeys:keys];
    
	NSString *jsonData = (NSString*) [dictionary JSONString];
	
	EndUser* user = [EndUser sharedInstance];
	__unused NSDictionary* genericDictonary = [self getJSONDataHttp:kPut :url :user.loginId :user.loginPw :jsonData :FALSE :@"PromoItemLikeRequest"];

}

-(void) changePasswordNewThread: (EndUser*) user :(GenericResponse*) genericResponse {
	NSArray  * myParams = [NSArray arrayWithObjects:user,genericResponse,nil];
	
	NSInvocationOperation *operation = [[NSInvocationOperation alloc] initWithTarget:self
																			selector:@selector(changePassword:)
										
																			  object:myParams];
	
	[queue addOperation:operation];
}

-(void) changePassword: (NSArray*) array {
	EndUser* user = [array objectAtIndex:0];
	GenericResponse* genericResponse = [array objectAtIndex:1];
	
    NSString* url = [NSString stringWithFormat:@"%@/rest/enduser/v1", [RestHelper url]];
	//NSString* url = [NSString stringWithFormat:@"%@/rest/enduser/eusers/changepw", [RestHelper url]];
	
	NSString* JSON = [user createUserPasswordString];
    NSLog(@"%@", JSON);
	NSDictionary* loginUserDictionary = [self getJSONDataHttp:kPut :url :nil :nil :JSON :FALSE :@"ChangeLoginPwRequest"];
	if (genericResponse != nil && ![queue isSuspended])
	{
		__unused GenericResponse *gr = [genericResponse initGenericWithDictonary:loginUserDictionary];
		if (delegate != nil)
		{
			[delegate restHelperDidLoad];
		}
	}
}

-(void) retrieveLoyaltyCompaniesNewThread: (CompaniesResponse*) companiesResponse{
    
	NSArray  * myParams = [NSArray arrayWithObjects:companiesResponse,nil];
	
	NSInvocationOperation *operation = [[NSInvocationOperation alloc] initWithTarget:self
																			selector:@selector(retrieveLoyaltyCompanies:)
										
																			  object:myParams];
	
	[queue addOperation:operation];
}

-(void) retrieveLoyaltyCompanies: (NSArray*) array {
	CompaniesResponse* companiesResponse = [array objectAtIndex:0];
	
	//NSString* url = [NSString stringWithFormat:@"%@/rest/enduser/companies/uca", [RestHelper url]];
	NSString* url = [NSString stringWithFormat:@"%@/rest/enduser/v1", [RestHelper url]];
	EndUser* user = [EndUser sharedInstance];
	NSDictionary* companiesResponseDictionary = [self getJSONDataHttp:kPut :url :user.loginId :user.loginPw :nil :FALSE :@"CompaniesFindWithUcaRequest"];
	
	if (companiesResponse != nil && ![queue isSuspended])
	{
		__unused CompaniesResponse *cr = [companiesResponse initWithDictonary:companiesResponseDictionary];
		
		if (delegate != nil)
		{
			[delegate restHelperDidLoad];
		}
	}
}

-(void) retrieveUcasForUserNewThread: (UserCompanyAccountsResponse*) ucasResponse{
    [FlurryAnalytics logEvent:@"retrieveUcasForUserNewThread"];
	NSArray  * myParams = [NSArray arrayWithObjects:ucasResponse,nil];
	
	NSInvocationOperation *operation = [[NSInvocationOperation alloc] initWithTarget:self
																			selector:@selector(retrieveUcasForUser:)
										
																			  object:myParams];
	
	[queue addOperation:operation];
}

-(void) retrieveUcasForUser: (NSArray*) array {
	UserCompanyAccountsResponse* ucasResponse = [array objectAtIndex:0];
	
	//NSString* url = [NSString stringWithFormat:@"%@/rest/enduser/eusers/me/ucas", [RestHelper url]];
	 NSString* url = [NSString stringWithFormat:@"%@/rest/enduser/v1", [RestHelper url]];
    
	EndUser* user = [EndUser sharedInstance];
	NSDictionary* companiesResponseDictionary = [self getJSONDataHttp:kPut :url :user.loginId :user.loginPw :nil :FALSE :@"UcasFindRequest"];
	
	if (ucasResponse != nil && ![queue isSuspended])
	{
		__unused UserCompanyAccountsResponse *ucar = [ucasResponse initUcaWithDictonary:companiesResponseDictionary];
		
		if (delegate != nil)
		{
			[delegate restHelperDidLoad];
		}
	}
}

-(void) updateUcaNewThread: (UserCompanyAccount*) uca: (GenericResponse*) ucaResponse{
	NSArray  * myParams = [NSArray arrayWithObjects:uca,ucaResponse,nil];
	
	NSInvocationOperation *operation = [[NSInvocationOperation alloc] initWithTarget:self
																			selector:@selector(updateUca:)
										
																			  object:myParams];
	
	[queue addOperation:operation];
}
-(void) updateUca: (NSArray*) array{
    [FlurryAnalytics logEvent:@"updateUca"];
	UserCompanyAccount* uca = [array objectAtIndex:0];
	GenericResponse* ucaResponse = [array objectAtIndex:1];
	
	
	//NSString* url = [NSString stringWithFormat:@"%@/rest/enduser/eusers/me/ucas", [RestHelper url]];
    NSString* url = [NSString stringWithFormat:@"%@/rest/enduser/v1", [RestHelper url]];
    
	NSString* JSON = [uca createJSONString];
	EndUser* user = [EndUser sharedInstance];
	NSDictionary* dictionary = [self getJSONDataHttp:kPut :url :user.loginId :user.loginPw :JSON :FALSE :@"UserCompanyAccountUpdateRequest"];
	
	if (ucaResponse != nil && ![queue isSuspended])
	{
		__unused GenericResponse *gr = [ucaResponse initGenericWithDictonary:dictionary];
		if (delegate != nil)
		{
			[delegate restHelperDidLoad];
		}
	}
}

-(void) registerUcaNewThread: (UserCompanyAccount*) uca: (GenericResponse*) ucaResponse{
	NSArray  * myParams = [NSArray arrayWithObjects:uca,ucaResponse,nil];
	
	NSInvocationOperation *operation = [[NSInvocationOperation alloc] initWithTarget:self
																			selector:@selector(registerUca:)
										
																			  object:myParams];
	
	[queue addOperation:operation];
}
-(void) registerUca: (NSArray*) array{
    [FlurryAnalytics logEvent:@"registerUca"];
	UserCompanyAccount* uca = [array objectAtIndex:0];
	GenericResponse* ucaResponse = [array objectAtIndex:1];
	
    NSString* url = [NSString stringWithFormat:@"%@/rest/enduser/v1", [RestHelper url]];
	//NSString* url = [NSString stringWithFormat:@"%@/rest/enduser/eusers/me/ucas", [RestHelper url]];
	
	NSString* JSON = [uca createJSONString];
	EndUser* user = [EndUser sharedInstance];
	NSDictionary* dictionary = [self getJSONDataHttp:kPut :url :user.loginId :user.loginPw :JSON :FALSE :@"UserCompanyAccountCreateRequest"];
	
	if (ucaResponse != nil && ![queue isSuspended])
	{
		__unused GenericResponse *gr = [ucaResponse initGenericWithDictonary:dictionary];
		if (delegate != nil)
		{
			[delegate restHelperDidLoad];
		}
	}
}

-(void) deleteUcaNewThread: (NSString*) compId: (GenericResponse*) ucaResponse{
	NSArray  * myParams = [NSArray arrayWithObjects:compId,ucaResponse,nil];
	
	NSInvocationOperation *operation = [[NSInvocationOperation alloc] initWithTarget:self
																			selector:@selector(deleteUca:)
										
																			  object:myParams];
	
	[queue addOperation:operation];
}
-(void) deleteUca: (NSArray*) array{
    [FlurryAnalytics logEvent:@"deleteUca"];
	NSString* compId = [array objectAtIndex:0];
	GenericResponse* ucaResponse = [array objectAtIndex:1];
	
	 NSString* url = [NSString stringWithFormat:@"%@/rest/enduser/v1", [RestHelper url]];
	//NSString* url = [NSString stringWithFormat:@"%@/rest/enduser/eusers/me/ucas/%@", [RestHelper url], compId];
	
    NSArray *keys = [NSArray arrayWithObjects:@"compId", nil];
	
    NSNumberFormatter * f = [[NSNumberFormatter alloc] init];
    [f setNumberStyle:NSNumberFormatterDecimalStyle];
    NSArray *objects = [NSArray arrayWithObjects:[f numberFromString:compId], nil];
    
    NSDictionary *jsondictionary = [NSDictionary dictionaryWithObjects:objects 
														   forKeys:keys];
    
	NSString *jsonData = (NSString*) [jsondictionary JSONString];
	EndUser* user = [EndUser sharedInstance];
	NSDictionary* dictionary = [self getJSONDataHttp:kPut :url :user.loginId :user.loginPw :jsonData :FALSE :@"UserCompanyAccountDeleteRequest"];
	
	if (ucaResponse != nil && ![queue isSuspended])
	{
		__unused GenericResponse *gr = [ucaResponse initGenericWithDictonary:dictionary];
		if (delegate != nil)
		{
			[delegate restHelperDidLoad];
		}
	}
}



-(void) dealloc {
	delegate = nil;
}



@end
