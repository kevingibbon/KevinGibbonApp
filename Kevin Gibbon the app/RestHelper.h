//
//  RestHelper.h
//  Shop Around
//
//  Created by Kevin Gibbon on 8/29/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//
#import <Foundation/Foundation.h>
#import "UserResponse.h"
#import "CompaniesResponse.h"
#import "SearchPromoResponse.h"
#import "PromoSearchParameters.h"
#import "CompanyResponse.h"
#import "BarcodeResponse.h"
#import "UserCompanyAccountsResponse.h"
#import "CategoriesResponse.h"

typedef enum {
	kGet,
	kPost,
	kPut,
	kDelete
} HttpType;

@protocol RestHelperDelegate;
@protocol StoreViewDelegate;

@interface RestHelper : NSObject {
	NSOperationQueue *queue;
}

+ (NSString *)url;
+ (void)setUrl:(NSString *)newUrl;

@property (strong) id <RestHelperDelegate> delegate;
@property (nonatomic,strong) NSOperationQueue * queue;


-(void) retrieveCompaniesWithStores: (NSArray*) array;
-(void) getCompaniesWithStoresNewThread: (NSString*) latitude :(NSString*) longitude :(NSString*) rangeKm :(CompaniesResponse*) companiesResponse;
-(CompanyResponse*) retrieveCompany: (NSString*) compId;
-(void) loginUserNewThread: (NSString*) user :(NSString*) password :(UserResponse*) userResponse;
-(void) loginUser: (NSArray*) array;
-(NSDictionary*) getJSONDataHttp: (HttpType) httpType :(NSString*) url :(NSString*) loginId :(NSString*) loginPw :(NSString*) jsonData :(BOOL) cacheData :(NSString*) messageType;
-(void) getPromotionsThreadSafe: (PromoSearchParameters*) promoSearchParameters :(SearchPromoResponse*) searchPromoResponse;
-(void) retreivePromotions: (NSArray*) array;
-(void) redeemPromotion: (NSArray*) array;
-(void) redeemPromotionThreadSafe: (NSString*) promoItemId:(BarcodeResponse*) barcodeResponse;
-(void) registerUserNewThread: (EndUser*) user :(UserResponse*) userResponse;
-(void) registerUser: (NSArray*) array;
-(void) loginTempUserNewThread:(UserResponse*) userResponse;
-(void) loginTempUser: (NSArray*) array;

-(void) updateUserNewThread: (EndUser*) user :(UserResponse*) userResponse;
-(void) updateUser: (NSArray*) array;

-(void) facebookSharePromotionThreadSafe: (NSString*) promoItemId:(GenericResponse*) genericResponse;
-(void) facebookSharePromotion: (NSArray*) array;

-(void) addPromoToListThreadSafe: (NSString*) promoItemId;
-(void) addPromoToList: (NSArray*) array;

-(void) promoDetailedViewThreadSafe: (NSString*) promoItemId;
-(void) promoDetailedView: (NSArray*) array;

-(void) likePromoThreadSafe: (NSString*) promoItemId;
-(void) likePromo: (NSArray*) array;

-(void) changePasswordNewThread: (EndUser*) user :(GenericResponse*) userResponse;
-(void) changePassword: (NSArray*) array;

-(void) retrieveLoyaltyCompanies: (NSArray*) array;
-(void) retrieveLoyaltyCompaniesNewThread: (CompaniesResponse*) companiesResponse;

-(void) retrieveUcasForUser: (NSArray*) array;
-(void) retrieveUcasForUserNewThread: (UserCompanyAccountsResponse*) ucasResponse;

-(void) updateUcaNewThread: (UserCompanyAccount*) uca: (GenericResponse*) ucaResponse;
-(void) updateUca: (NSArray*) array;

-(void) registerUcaNewThread: (UserCompanyAccount*) uca: (GenericResponse*) ucaResponse;
-(void) registerUca: (NSArray*) array;

-(void) retreiveCategories: (NSArray*) array;
-(void) getCategoriesThreadSafe: (NSMutableArray*) storeIds :(NSString*) day :(CategoriesResponse*) categoryResponse;

+(NSString*) getUDID;

-(void) deleteUcaNewThread: (NSString*) compId: (GenericResponse*) ucaResponse;
-(void) deleteUca: (NSArray*) array;
+ (void) addStringToArray :(NSMutableArray*) array :(NSString*) stringToAdd;
+ (void) addNumberToArray :(NSMutableArray*) array :(NSNumber*) numberToAdd;
+ (void) addArrayToArray :(NSMutableArray*) array :(NSMutableArray*) arrayToAdd;
+ (void) addKeyStringToArray :(NSMutableArray*) keyArray :(NSMutableArray*) array :(NSString*) keyToAdd :(NSString*) stringToAdd;
@end

@protocol RestHelperDelegate 

- (void)restHelperDidLoad;
@end

@protocol StoreViewDelegate 

- (void)locationDidLoad;
- (void)errorLoadingLocation;
@end
