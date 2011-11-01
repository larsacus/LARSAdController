//
//  LARSFlipsideViewController.h
//  LARSAdControllerDemo
//
//  Created by Lars Anderson on 11/1/11.
//  Copyright (c) 2011 Mutual Mobile. All rights reserved.
//

#import <UIKit/UIKit.h>

@class LARSFlipsideViewController;

@protocol LARSFlipsideViewControllerDelegate
- (void)flipsideViewControllerDidFinish:(LARSFlipsideViewController *)controller;
@end

@interface LARSFlipsideViewController : UIViewController

@property (assign, nonatomic) IBOutlet id <LARSFlipsideViewControllerDelegate> delegate;

- (IBAction)done:(id)sender;

@end
