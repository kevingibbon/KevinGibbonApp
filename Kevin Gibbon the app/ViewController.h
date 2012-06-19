//
//  ViewController.h
//  Kevin Gibbon the app
//
//  Created by Kevin Gibbon on 12-06-18.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PhotoViewController.h"

@interface ViewController : UIViewController
@property (weak, nonatomic) IBOutlet UIButton *facebookButton;
@property (weak, nonatomic) IBOutlet UIButton *twitterButton;
@property (weak, nonatomic) IBOutlet UIButton *instagramButton;
- (IBAction)instagramButtonPressed:(id)sender;
- (IBAction)twitterButtonPressed:(id)sender;
- (IBAction)facebookButtonPressed:(id)sender;
@property (strong, nonatomic) IBOutlet PhotoViewController *facebookViewController;
@property (strong, nonatomic) IBOutlet PhotoViewController *twitterViewController;
@property (strong, nonatomic) IBOutlet PhotoViewController *instagramViewController;
@property (weak, nonatomic) IBOutlet UIView *viewContainer;

@end
