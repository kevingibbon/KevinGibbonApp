//
//  PhotoViewController.h
//  Kevin Gibbon the app
//
//  Created by Kevin Gibbon on 12-06-19.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RestHelper.h"

@interface PhotoViewController : UIViewController <RestHelperDelegate>

@property (strong) PhotoResponse *photoResponse;
@property (strong) RestHelper *restHelper;
@property (strong) NSString *socialType;
@property (strong) NSMutableArray *images;
- (void)restHelperDidLoad;
@property (weak, nonatomic) IBOutlet UITableView *photoTableView;
-(void)loadData;

@end
