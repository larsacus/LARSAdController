//
//  TOLAdAdapterHouseAds.h
//  adcontrollerdemo
//
//  Created by Lars Anderson on 12/16/12.
//  Copyright (c) 2012 theonlylars. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TOLAdAdapter.h"

@interface TOLAdAdapterHouseAds : NSObject <TOLAdAdapter>

@property (strong, nonatomic) UIView *bannerView;
@property (nonatomic) BOOL adVisible;
@property (weak, nonatomic) id <LARSAdControllerDelegate> adManager;
@property (nonatomic, readonly) BOOL adLoaded;

- (void)pauseAdRequests;
- (void)startAdRequests;

- (void)layoutBannerForInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation;
- (NSString *)friendlyNetworkDescription;

@end
