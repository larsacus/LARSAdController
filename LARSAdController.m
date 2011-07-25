//
//  LARSAdController.m
//  Droid Light
//
//  Created by Lars on 7/24/11.
//  Copyright 2011 Drink & Apple, Lars Anderson. All rights reserved.
//

//Copyright (c) 2011 Lars Anderson, drink&apple
//
//Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
//
//The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
//
//THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

#import "LARSAdController.h"

@implementation LARSAdController

@synthesize adMobBannerView             = _adMobBannerView;
@synthesize iAdBannerView               = _iAdBannerView;
@synthesize parentView                  = _parentView;

static LARSAdController *sharedController = nil;

#pragma mark -
#pragma mark Class Methods

+ (LARSAdController *)sharedManager{
    if (sharedController == nil) {
        sharedController = [[super allocWithZone:NULL] init];
    }
    return sharedController;
}

+ (id)allocWithZone:(NSZone *)zone{
    return [[self sharedManager] retain];
}

#pragma mark -
#pragma mark Singleton Implementation

- (id)copyWithZone:(NSZone *)zone{
    return self;
}

- (id)retain{
    return self;
}

- (NSUInteger)retainCount{
    return NSUIntegerMax;
}

- (id)autorelease{
    return self;
}

#pragma mark -
#pragma mark Common Methods

#pragma mark -
#pragma mark iAd Delegate Methods
- (void)bannerViewDidLoadAd:(ADBannerView *)banner{
    
}

- (BOOL)bannerViewActionShouldBegin:(ADBannerView *)banner willLeaveApplication:(BOOL)willLeave{
    return YES;
}

- (void)bannerViewActionDidFinish:(ADBannerView *)banner{
    
}

- (void)bannerView:(ADBannerView *)banner didFailToReceiveAdWithError:(NSError *)error{
    
}

#pragma mark -
#pragma mark AdMob/Google Methods
- (void)createAdMobAds{
    
}

- (void)destroyAdMobAds{
    
}

#pragma mark -
#pragma mark AdMob/Google Delegate Methods
- (void)adViewDidReceiveAd:(GADBannerView *)bannerView{
    
}

- (void)adView:(GADBannerView *)bannerView didFailToReceiveAdWithError:(GADRequestError *)error{
    
}

- (void)adViewWillPresentScreen:(GADBannerView *)bannerView{
    
}

- (void)adViewDidDismissScreen:(GADBannerView *)bannerView{
    
}

- (void)adViewWillLeaveApplication:(GADBannerView *)bannerView{
    
}

@end
