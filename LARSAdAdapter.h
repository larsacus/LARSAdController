//
//  LARSAdAdapter.h
//  adcontrollerdemo
//
//  Created by Lars Anderson on 11/8/12.
//  Copyright (c) 2012 theonlylars. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "LARSAdController.h"

@protocol LARSAdAdapter <NSObject>

@required
@property (strong, nonatomic) UIView *bannerView;
@property (nonatomic) BOOL adVisible;
@property (weak, nonatomic) id <LARSAdControllerDelegate> adManager;

- (BOOL)requiresPublisherId;
- (void)layoutBannerForInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation;

@optional
- (void)startAdRequests;
- (void)pauseAdRequests;
- (BOOL)canDestroyAdBanner;

- (NSString *)friendlyNetworkDescription;

@property (copy, nonatomic) NSString *publisherId;

@end
