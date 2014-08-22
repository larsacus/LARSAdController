//
//  LARSExampleViewController.h
//  adcontrollerdemo
//
//  Created by Lars Anderson on 4/28/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <LARSAdController/TOLAdViewController.h>

@interface LARSExampleViewController : TOLAdViewController

@property (nonatomic, retain) UILabel *adVisibleLabel;
@property (nonatomic, retain) UIButton *bottomTestButton;
@property (nonatomic) BOOL bannerIsVisible;                 // shows if an ad is visible on this view or not
@property (nonatomic) float currentPushAmount;              // the amount that the test button (or anything else) is being pushed up at the moment

@end
