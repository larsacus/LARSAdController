//
//  LARSAdControllerAdMobAdapter.h
//  adcontrollerdemo
//
//  Created by Lars Anderson on 11/8/12.
//  Copyright (c) 2012 theonlylars. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "LARSAdAdapter.h"
#import "GADBannerViewDelegate.h"
#import "LARSAdController.h"

@class GADBannerView;

@interface LARSAdControllerAdMobAdapter : NSObject <LARSAdAdapter, GADBannerViewDelegate>

@property (weak, nonatomic) id<LARSAdControllerDelegate> adManager;
@property (nonatomic) BOOL adVisible;
@property (strong, nonatomic) GADBannerView *bannerView;
@property (copy, nonatomic) NSString *publisherId;

@end
