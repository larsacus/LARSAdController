//
//  LARSAdControlleriAdAdapter.h
//  adcontrollerdemo
//
//  Created by Lars Anderson on 11/9/12.
//  Copyright (c) 2012 theonlylars. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <iAd/iAd.h>
#import "LARSAdAdapter.h"
#import "LARSAdController.h"

@interface LARSAdControlleriAdAdapter : NSObject <LARSAdAdapter, ADBannerViewDelegate>

@property (strong, nonatomic) ADBannerView *bannerView;
@property (nonatomic) BOOL adVisible;
@property (weak, nonatomic) id <LARSAdControllerDelegate> adManager;

- (void)layoutBannerForInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation;

@end
