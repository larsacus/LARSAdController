//
//  TOLAdViewController.m
//  adcontrollerdemo
//
//  Created by Lars Anderson on 11/12/12.
//  Copyright (c) 2012 theonlylars. All rights reserved.
//

#import "TOLAdViewController.h"
#import "LARSAdController.h"

@interface TOLAdViewController ()

@end

@implementation TOLAdViewController

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    
    [[LARSAdController sharedManager] addAdContainerToViewInViewController:self];
}

- (void)viewDidLayoutSubviews{
    [super viewDidLayoutSubviews];
    
    [self.view bringSubviewToFront:[LARSAdController sharedManager].containerView];
}

@end
