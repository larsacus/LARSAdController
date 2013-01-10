//
//  TOLAdAdapteriAds.m
//  adcontrollerdemo
//
//  Created by Lars Anderson on 11/9/12.
//
//  Copyright (c) 2011-2013 Lars Anderson, drink&apple, theonlylars
//
//Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
//
//The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
//
//THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

#import "TOLAdAdapteriAds.h"

NSString * const kTOLAdAdapterBannerLoadedObserverKeyPath = @"bannerLoaded";

@interface TOLAdAdapteriAds()

@property (nonatomic, readwrite) BOOL adLoaded;

@end

@implementation TOLAdAdapteriAds

- (void)dealloc{
    _bannerView.delegate = nil;
    _bannerView = nil;
    
    self.adManager = nil;
    
    [self.bannerView removeObserver:self
                         forKeyPath:kTOLAdAdapterBannerLoadedObserverKeyPath];
    
    TOLLog(@"Dealloc");
}

#pragma mark - Required Adapter Implementation 
- (BOOL)requiresPublisherId{
    return NO;
}

- (ADBannerView *)bannerView{
    if (!_bannerView) {
        
        if ([ADBannerView instancesRespondToSelector:@selector(initWithAdType:)]) {
            _bannerView = [[ADBannerView alloc] initWithAdType:ADAdTypeBanner];
        } else {
            _bannerView = [[ADBannerView alloc] init];
        }
        
        [_bannerView addObserver:self
                      forKeyPath:kTOLAdAdapterBannerLoadedObserverKeyPath
                         options:NSKeyValueObservingOptionNew
                         context:nil];
        
#if (__IPHONE_OS_VERSION_MIN_REQUIRED < __IPHONE_6_0)
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
        if ([_bannerView respondsToSelector:@selector(adType)] == NO) {
            if ((&ADBannerContentSizeIdentifierLandscape != nil)) {
                _bannerView.requiredContentSizeIdentifiers = [NSSet setWithObjects:ADBannerContentSizeIdentifierPortrait, ADBannerContentSizeIdentifierLandscape, nil];
            }
            else{
                _bannerView.requiredContentSizeIdentifiers = [NSSet setWithObjects:ADBannerContentSizeIdentifier320x50, ADBannerContentSizeIdentifier480x32, nil];
            }
        }
#pragma clang diagnostic pop
#endif
        
        _bannerView.delegate = self;
    }
    return _bannerView;
}

- (void)observeValueForKeyPath:(NSString *)keyPath
                      ofObject:(id)object
                        change:(NSDictionary *)change
                       context:(void *)context
{
    if ([keyPath isEqual:kTOLAdAdapterBannerLoadedObserverKeyPath]) {
        self.adLoaded = [[change objectForKey:NSKeyValueChangeNewKey] boolValue];
    }
    /*
     Be sure to call the superclass's implementation *if it implements it*.
     NSObject does not implement the method.
     */
    /*[super observeValueForKeyPath:keyPath
     ofObject:object
     change:change
     context:context];*/
}

#pragma mark - Optional Adapter Implementation
- (NSString *)friendlyNetworkDescription{
    return @"iAds";
}

#pragma mark -
#pragma mark iAd Delegate Methods
- (void)bannerViewDidLoadAd:(ADBannerView *)banner{
    
    if ([self.adManager respondsToSelector:@selector(adSucceededForNetworkAdapterClass:)]) {
        [self.adManager adSucceededForNetworkAdapterClass:self.class];
    }

    TOLLog(@"iAd did load ad");
}

- (BOOL)bannerViewActionShouldBegin:(ADBannerView *)banner willLeaveApplication:(BOOL)willLeave{
    return YES;
}

- (void)bannerViewActionDidFinish:(ADBannerView *)banner{
    if([self.adManager respondsToSelector:@selector(adInstanceNowAvailableForDeallocation:)]){
        [self.adManager adInstanceNowAvailableForDeallocation:self];
    }
}

- (void)bannerView:(ADBannerView *)banner didFailToReceiveAdWithError:(NSError *)error{
    
    if ([self.adManager respondsToSelector:@selector(adFailedForNetworkAdapterClass:)]) {
        [self.adManager adFailedForNetworkAdapterClass:self.class];
    }

    TOLLog(@"iAd did fail to receive ad");
}

- (BOOL)canDestroyAdBanner{
    return (self.bannerView.isBannerViewActionInProgress == NO);
}

- (void)layoutBannerForInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation{
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
    if ((&ADBannerContentSizeIdentifierLandscape != nil)) {
        self.bannerView.currentContentSizeIdentifier = UIInterfaceOrientationIsPortrait(interfaceOrientation) ? ADBannerContentSizeIdentifierPortrait : ADBannerContentSizeIdentifierLandscape;
    }
    else {
        self.bannerView.currentContentSizeIdentifier = UIInterfaceOrientationIsPortrait(interfaceOrientation) ? ADBannerContentSizeIdentifier320x50 : ADBannerContentSizeIdentifier480x32;
    }
#pragma clang diagnostic pop
}

@end
