//
//  LARSExampleViewController.m
//  adcontrollerdemo
//
//  Created by Lars Anderson on 4/28/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "LARSExampleViewController.h"
#import "LARSAdController.h"
#import "LARSAdControlleriAdAdapter.h"

@interface LARSExampleViewController ()

@end

@implementation LARSExampleViewController

- (void)loadView{
    UIView *view = [[UIView alloc] initWithFrame:CGRectZero];
    view.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    [view setBackgroundColor:[UIColor orangeColor]];
    
    self.view = view;
}

- (void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    TOLLog(@"view did: %@", self.view);
    
    [[LARSAdController sharedManager] registerAdClass:[LARSAdControlleriAdAdapter class]];
    [[LARSAdController sharedManager] addAdContainerToViewInViewController:self];
}

//Deprecated
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation{
    return YES;
}

//New iOS 6 stuff
- (BOOL)shouldAutorotate{
    return YES;
}

- (NSUInteger)supportedInterfaceOrientations{
    return UIInterfaceOrientationMaskAllButUpsideDown;
}

//- (UIInterfaceOrientation)preferredInterfaceOrientationForPresentation{
////    [[UIApplication sharedApplication] delegate] application:<#(UIApplication *)#> supportedInterfaceOrientationsForWindow:<#(UIWindow *)#>
//    if([self respondsToSelector:@selector(supportedInterfaceOrientations)] == NO){
//       //pre-iOS 6
//    }
//    
//    //schema launch argument: UIApplicationSupportedInterfaceOrientationsEnabled?
//}

@end
