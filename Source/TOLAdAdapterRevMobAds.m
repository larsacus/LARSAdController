//
//  TOLAdAdapterRevMobAds.m
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

#import "TOLAdAdapterRevMobAds.h"
#import <AdSupport/AdSupport.h>

@implementation TOLAdAdapterRevMobAds

#pragma mark - Required Adapted Implementation

- (RevMobBannerView *)bannerView{
    if (_bannerView == nil && _publisherId) {
        
        [RevMobAds startSessionWithAppID:_publisherId];

//        [RevMobAds session].testingMode = RevMobAdsTestingModeWithoutAds;  //Choose this testing mode to simulate ad loading error
        [[RevMobAds session] setTestingMode:RevMobAdsTestingModeWithAds];
        
        _bannerView = [[RevMobAds session] bannerViewWithPlacementId:nil];
        _bannerView.delegate = self;
        [_bannerView loadAd];
        
        [self.bannerView setNeedsLayout];
    }
    else if(!_publisherId){
        TOLWLog(@"RevMob Publisher ID not set. No ads will be served until you set one using %@ on %@!", NSStringFromSelector(@selector(registerAdClass:withPublisherId:)),NSStringFromClass([LARSAdController class]));
    }
    
    return _bannerView;
}

- (void)layoutBannerForInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation{
    //Simply sets the banner view to inherit the same bounds as the container
    self.bannerView.frame = self.bannerView.superview.bounds;
}

#pragma mark - Required RevMob methods


-(void)revmobAdDidFailWithError:(NSError *)error {
    TOLLog(@"Ad failed with error: %@", error);
    
    [self.adManager adFailedForNetworkAdapterClass:[self class]];
}

-(void)revmobAdDidReceive {
    TOLLog(@"Ad loaded successfullly");
    if ([self.adManager respondsToSelector:@selector(adSucceededForNetworkAdapterClass:)]) {
        [self.adManager adSucceededForNetworkAdapterClass:[self class]];
    }
}

-(void)revmobAdDisplayed {
    TOLLog(@"Ad displayed");
    [self.adManager adSucceededForNetworkAdapterClass:self.class];
}

-(void)revmobUserClickedInTheAd {
    TOLLog(@"User clicked in the ad");
}

-(void)revmobUserClosedTheAd {
    TOLLog(@"User closed the ad");
}

- (void)dealloc{
    _bannerView.delegate = nil;
    _bannerView = nil;
    
    self.adManager = nil;
    self.publisherId = nil;
    
    TOLLog(@"Dealloc");
}

#pragma mark - Optional Adapter Implementation
+ (BOOL)requiresPublisherId{
    return YES;
}

+ (BOOL)requiresParentViewController{
    return NO;
}

- (NSString *)friendlyNetworkDescription{
    return @"RevMob Ads";
}

@end
