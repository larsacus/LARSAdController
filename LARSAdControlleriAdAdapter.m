//
//  LARSAdControlleriAdAdapter.m
//  adcontrollerdemo
//
//  Created by Lars Anderson on 11/9/12.
//  Copyright (c) 2012 theonlylars. All rights reserved.
//

#import "LARSAdControlleriAdAdapter.h"

@implementation LARSAdControlleriAdAdapter

#pragma mark - Required Adapter Implementation 
+ (BOOL)requiresPublisherId{
    return NO;
}

#pragma mark -
#pragma mark iAd Delegate Methods
- (void)bannerViewDidLoadAd:(ADBannerView *)banner{
    
    if ([self.adManager respondsToSelector:@selector(adSucceededForNetworkAdapterClass:)]) {
        [self.adManager adSucceededForNetworkAdapterClass:self.class];
    }

#ifdef LARSADCONTROLLER_DEBUG
    NSLog(@"%@: iAd did load ad", NSStringFromClass([self class]));
#endif
}

- (BOOL)bannerViewActionShouldBegin:(ADBannerView *)banner willLeaveApplication:(BOOL)willLeave{
    return YES;
}

- (void)bannerViewActionDidFinish:(ADBannerView *)banner{
    //TODO: replace this
//    [self layoutBannerViewsForCurrentOrientation:self.parentViewController.interfaceOrientation];
}

- (void)bannerView:(ADBannerView *)banner didFailToReceiveAdWithError:(NSError *)error{
    
    if ([self.adManager respondsToSelector:@selector(adFailedForNetworkAdapterClass:)]) {
        [self.adManager adFailedForNetworkAdapterClass:self.class];
    }

#ifdef LARSADCONTROLLER_DEBUG
    NSLog(@"%@: iAd did fail to receive ad", NSStringFromClass([self class]));
#endif
}

#pragma mark -
#pragma mark iAd Methods
- (ADBannerView *)bannerView{
    if (!_bannerView) {

        if ([ADBannerView instancesRespondToSelector:@selector(initWithAdType:)]) {
            _bannerView = [[ADBannerView alloc] initWithAdType:ADAdTypeBanner];
        } else {
            _bannerView = [[ADBannerView alloc] init];
        }

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

- (BOOL)destroy{
    if (self.bannerView.isBannerViewActionInProgress) {
        return NO;
    }
    
    [self.bannerView removeFromSuperview];
    self.bannerView.delegate = nil;
    _bannerView = nil;
    
    return YES;
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
