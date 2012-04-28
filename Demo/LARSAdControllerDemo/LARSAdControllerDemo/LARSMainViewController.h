//
//  LARSMainViewController.h
//  LARSAdControllerDemo
//
//  Created by Lars Anderson on 11/1/11.
//  Copyright (c) 2011 Mutual Mobile. All rights reserved.
//

#import "LARSFlipsideViewController.h"

@interface LARSMainViewController : UIViewController <LARSFlipsideViewControllerDelegate>

@property (strong, nonatomic) UIPopoverController *flipsidePopoverController;

- (IBAction)showInfo:(id)sender;

@end
