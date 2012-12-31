//
//  LARSExampleViewController.m
//  adcontrollerdemo
//
//  Created by Lars Anderson on 4/28/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "LARSExampleViewController.h"
//#import "LARSAdController.h"

@interface LARSExampleViewController ()

@end

@implementation LARSExampleViewController

- (void)loadView{
    UIView *view = [[UIView alloc] initWithFrame:CGRectZero];
    view.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    [view setBackgroundColor:[UIColor orangeColor]];
    
    self.view = view;
}

/* If this view controller did not inherit from TOLAdViewController, then you would need to uncomment the below method and implement adding the ad container to the view yourself. You will also need to uncomment line 10 to import the class. 
 */
/*
- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    
    [[LARSAdController sharedManager] addAdContainerToViewInViewController:self];
}
 */

//Deprecated
#if __IPHONE_OS_VERSION_MIN_REQUIRED < __IPHONE_6_0
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation{
    return (toInterfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
}
#endif

//New iOS 6 stuff
- (BOOL)shouldAutorotate{
    return YES;
}

- (NSUInteger)supportedInterfaceOrientations{
    return UIInterfaceOrientationMaskAllButUpsideDown;
}

@end
