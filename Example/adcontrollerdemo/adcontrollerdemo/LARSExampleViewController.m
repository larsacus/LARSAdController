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

- (void)viewWillAppear:(BOOL)animated{
    [[LARSAdController sharedManager] registerAdClass:[LARSAdControlleriAdAdapter class]];
    [[LARSAdController sharedManager] addAdContainerToView:self.view withParentViewController:self];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation{
    return YES;
}

@end
