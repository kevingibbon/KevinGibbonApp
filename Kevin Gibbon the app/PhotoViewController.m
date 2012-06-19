//
//  PhotoViewController.m
//  Kevin Gibbon the app
//
//  Created by Kevin Gibbon on 12-06-19.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "PhotoViewController.h"
#import "PhotoCustomCell.h"
#import <SDWebImage/UIImageView+WebCache.h>

@interface PhotoViewController ()

@end

@implementation PhotoViewController
@synthesize photoTableView;

@synthesize restHelper;
@synthesize photoResponse;
@synthesize images;
@synthesize socialType;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    restHelper = [[RestHelper alloc] init];
    restHelper.delegate = self;
    images = [[NSMutableArray alloc] init];
        
}

- (void)loadData 
{
    self.photoResponse = [PhotoResponse alloc];
    [images removeAllObjects];
    [photoTableView reloadData];
    [restHelper retrievePhotos:socialType :self.photoResponse];
}

- (void) viewWillDisappear:(BOOL)animated {	
	[restHelper.queue setSuspended:YES];
	[super viewWillDisappear:animated];
}

- (void)viewDidUnload
{
    [self setPhotoTableView:nil];
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (void)restHelperDidLoad {
    if (photoResponse != nil)
    {
        images = photoResponse.photos;
        [photoTableView performSelectorOnMainThread: @selector(reloadData)
                                    withObject: nil 
                                 waitUntilDone: FALSE];
    }
}

-(CGFloat)tableView:(UITableView*)tableView heightForRowAtIndexPath:(NSIndexPath*) indexPath 
{
    return 272.0;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [images count];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPat
{
	
	
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    PhotoCustomCell *cell = (PhotoCustomCell *) [tableView dequeueReusableCellWithIdentifier:@"PhotoCustomCell"];
    if(cell == nil)
    {
        NSArray *nibs = [[NSBundle mainBundle] loadNibNamed:@"PhotoCustomCell" owner:self options:nil];
        cell = (PhotoCustomCell *)[nibs objectAtIndex:0];
    }
    NSString *url = [images objectAtIndex:indexPath.row];
    [cell.imageView setClipsToBounds:YES];
    [cell.imageView setImageWithURL:[NSURL URLWithString:url]
                  placeholderImage:[UIImage imageNamed:@"loading.png"]];
    return cell;
}


@end
