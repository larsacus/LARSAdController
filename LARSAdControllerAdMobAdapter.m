//
//  LARSAdControllerAdMobAdapter.m
//  adcontrollerdemo
//
//  Created by Lars Anderson on 11/8/12.
//  Copyright (c) 2012 theonlylars. All rights reserved.
//

#import "LARSAdControllerAdMobAdapter.h"
#import "GADBannerView.h"

@implementation LARSAdControllerAdMobAdapter

#pragma mark - Required Adapted Implementation
- (BOOL)requiresPublisherId{
    return YES;
}

- (void)setParentViewController:(UIViewController *)viewController{
    self.bannerView.rootViewController = viewController;
}

- (GADBannerView *)bannerView{
    if (_bannerView == nil && _publisherId) {
        
        //start in portrait
        _bannerView = [[GADBannerView alloc] initWithAdSize:kGADAdSizeSmartBannerPortrait];
        
        self.bannerView.adUnitID = self.publisherId;
        self.bannerView.delegate = self;
        [self.bannerView loadRequest:[GADRequest request]];
    }
    else if(!_publisherId){
        TOLWLog(@"%@ WARNING: Google Ad Publisher ID not set. No ads will be served until you set one using setPublisherId:forClass: on %@!", NSStringFromClass(self.class), @"LARSAdController");
    }
    
    return _bannerView;
}

- (void)layoutBannerForInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation{
    if (UIInterfaceOrientationIsLandscape(interfaceOrientation)) {
        self.bannerView.adSize = kGADAdSizeSmartBannerLandscape;
    }
    else{
        self.bannerView.adSize = kGADAdSizeSmartBannerPortrait;
    }
}

- (void)dealloc{
    self.bannerView.delegate = nil;
    self.bannerView = nil;
    
    self.adManager = nil;
    self.publisherId = nil;
}

#pragma mark - Optional Adapter Implementation

- (void)setPublisherId:(NSString *)publisherId{
    _publisherId = [publisherId copy];
    
    if (_bannerView != nil) {
        self.bannerView.adUnitID = self.publisherId;
    }
}

- (NSString *)friendlyNetworkDescription{
    return @"Google Ads";
}

#pragma mark - AdMob Delegate Methods
- (void)adViewDidReceiveAd:(GADBannerView *)bannerView{
    
    if ([self.adManager respondsToSelector:@selector(adSucceededForNetworkAdapterClass:)]) {
        [self.adManager adSucceededForNetworkAdapterClass:[self class]];
    }
    
    TOLLog(@"%@: Google ad did receive ad", NSStringFromClass([self class]));
}
//
- (void)adView:(GADBannerView *)bannerView didFailToReceiveAdWithError:(GADRequestError *)error{
    
    if ([self.adManager respondsToSelector:@selector(adFailedForNetworkAdapterClass:)]) {
        [self.adManager adFailedForNetworkAdapterClass:[self class]];
    }
    
    TOLLog(@"%@: Google ad did fail to receive ad", NSStringFromClass([self class]));
}

// Unused Google Ad Delegate Methods
//
//- (void)adViewWillPresentScreen:(GADBannerView *)bannerView{
//
//}
//
//- (void)adViewDidDismissScreen:(GADBannerView *)bannerView{
//}
//
//
//- (void)adViewWillLeaveApplication:(GADBannerView *)bannerView{
//
//}

@end
