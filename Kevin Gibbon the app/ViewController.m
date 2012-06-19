//
//  ViewController.m
//  Kevin Gibbon the app
//
//  Created by Kevin Gibbon on 12-06-18.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()

@end

@implementation ViewController
@synthesize facebookViewController;
@synthesize twitterViewController;
@synthesize instagramViewController;
@synthesize viewContainer;
@synthesize facebookButton;
@synthesize twitterButton;
@synthesize instagramButton;

- (void)viewDidLoad
{
    [super viewDidLoad];
	[twitterButton setSelected:YES];
    [self pushViewController:instagramViewController];
    [instagramViewController setSocialType:INSTAGRAM];
    [self pushViewController:facebookViewController];
    [facebookViewController setSocialType:FACEBOOK];
    [self pushViewController:twitterViewController];
    [twitterViewController setSocialType:TWITTER];
    [self changeTab:twitterViewController];
}

- (void)viewDidUnload
{
    [self setFacebookButton:nil];
    [self setTwitterButton:nil];
    [self setInstagramButton:nil];
    [self setFacebookViewController:nil];
    [self setTwitterViewController:nil];
    [self setInstagramViewController:nil];
    [self setViewContainer:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
        return (interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
    } else {
        return YES;
    }
}

- (void)pushViewController:(UIViewController*)viewController {
    CGRect storeFrame = viewController.view.frame;
    storeFrame.size.height = viewContainer.frame.size.height;
    storeFrame.size.width = viewContainer.frame.size.width;
    storeFrame.origin.x = 0;
    storeFrame.origin.y = 0;
    [viewController.view setFrame:storeFrame];
    [viewContainer addSubview:viewController.view];
}

- (void)changeTab:(PhotoViewController*)newTabViewController {
    [viewContainer bringSubviewToFront:newTabViewController.view];
    [newTabViewController removeAndLoadData];
}

- (IBAction)instagramButtonPressed:(id)sender {
    [self changeTab:instagramViewController];
    [instagramButton setSelected:YES];
    [twitterButton setSelected:NO];
    [facebookButton setSelected:NO];
}

- (IBAction)twitterButtonPressed:(id)sender {
    [self changeTab:twitterViewController];
    [twitterButton setSelected:YES];
    [instagramButton setSelected:NO];
    [facebookButton setSelected:NO];
}

- (IBAction)facebookButtonPressed:(id)sender {
    [self changeTab:facebookViewController];
    [facebookButton setSelected:YES];
    [twitterButton setSelected:NO];
    [instagramButton setSelected:NO];
}
@end
