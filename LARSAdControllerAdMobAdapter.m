//
//  LARSAdControllerAdMobAdapter.m
//  adcontrollerdemo
//
//  Created by Lars Anderson on 11/8/12.
//
//  Copyright (c) 2011-2013 Lars Anderson, drink&apple, theonlylars
//
//Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
//
//The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
//
//THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

#import "LARSAdControllerAdMobAdapter.h"
#import "GADBannerView.h"
#import <AdSupport/AdSupport.h>

@implementation LARSAdControllerAdMobAdapter

#pragma mark - Required Adapted Implementation
- (GADBannerView *)bannerView{
    if (_bannerView == nil && _publisherId) {
        
        //start in portrait
        _bannerView = [[GADBannerView alloc] initWithAdSize:kGADAdSizeBanner];
        
        self.bannerView.adUnitID = self.publisherId;
        self.bannerView.delegate = self;
    }
    else if(!_publisherId){
        TOLWLog(@"Google Ad Publisher ID not set. No ads will be served until you set one using setPublisherId:forClass: on %@!", @"LARSAdController");
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
    
    [self.bannerView setNeedsLayout];
}

- (void)dealloc{
    self.bannerView.delegate = nil;
    self.bannerView = nil;
    
    self.adManager = nil;
    self.publisherId = nil;
    
    TOLLog(@"Dealloc");
}

#pragma mark - Optional Adapter Implementation
+ (BOOL)requiresPublisherId{
    return YES;
}

+ (BOOL)requiresParentViewController{
    return YES;
}

- (void)setParentViewController:(UIViewController *)viewController{
    _parentViewController = viewController;
    
    self.bannerView.rootViewController = viewController;
    
    [self layoutBannerForInterfaceOrientation:viewController.interfaceOrientation];
}

- (void)setPublisherId:(NSString *)publisherId{
    _publisherId = [publisherId copy];
    
    if (_bannerView != nil) {
        self.bannerView.adUnitID = self.publisherId;
    }
}

- (NSString *)friendlyNetworkDescription{
    return @"Google Ads";
}

- (void)startAdRequests{
    GADRequest *request = [GADRequest request];
    
#if DEBUG
    request.testing = YES;
#endif
    
    [self.bannerView loadRequest:request];
}

#pragma mark - AdMob Delegate Methods
- (void)adViewDidReceiveAd:(GADBannerView *)bannerView{
    
    if ([self.adManager respondsToSelector:@selector(adSucceededForNetworkAdapterClass:)]) {
        [self.adManager adSucceededForNetworkAdapterClass:[self class]];
    }
    
    TOLLog(@"Google ad did receive ad");
}

- (void)adView:(GADBannerView *)bannerView didFailToReceiveAdWithError:(GADRequestError *)error{
    
    if ([self.adManager respondsToSelector:@selector(adFailedForNetworkAdapterClass:)]) {
        [self.adManager adFailedForNetworkAdapterClass:[self class]];
    }
    
    TOLLog(@"Google ad did fail to receive ad");
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
