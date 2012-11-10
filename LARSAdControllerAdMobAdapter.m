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
+ (BOOL)requiresPublisherId{
    return YES;
}

- (void)setParentViewController:(UIViewController *)viewController{
    self.bannerView.rootViewController = viewController;
}

- (GADBannerView *)bannerView{
    if (_bannerView == nil && _publisherId) {
        
        CGFloat height;
        if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
            height = GAD_SIZE_728x90.height;
        }
        else{
            height = GAD_SIZE_320x50.height;
        }
        
        //start in portrait
        _bannerView = [[GADBannerView alloc] initWithAdSize:GADAdSizeFullWidthPortraitWithHeight(height)];
        _bannerView.autoresizingMask = UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleWidth;
//        [self recenterbannerView];
        
        self.bannerView.adUnitID = self.publisherId;
        self.bannerView.delegate = self;
        [self.bannerView loadRequest:[GADRequest request]];
        
//        [self.clippingContainer insertSubview:self.bannerView
//                                 belowSubview:self.iAdBannerView];
    }
    else if(!_publisherId){
        NSLog(@"%@ WARNING: Google Ad Publisher ID not set. No ads will be served until you set one using setPublisherId:forClass: on %@!", NSStringFromClass(self.class), @"LARSAdController");
    }
    
    return _bannerView;
}

- (void)layoutBannerForInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation{
    //TODO: see if more sizes are needed here
    if (UIInterfaceOrientationIsLandscape(interfaceOrientation)) {
        self.bannerView.adSize = kGADAdSizeSmartBannerLandscape;
    }
    else{
        self.bannerView.adSize = kGADAdSizeSmartBannerPortrait;
    }
}

//- (void)recenterbannerView{
//    if (_bannerView) {
//        self.bannerView.center = CGPointMake(self.containerView.frame.size.width/2, self.bannerView.center.y);
//    }
//}

//- (void)destroyGoogleAdsAnimated:(BOOL)animated{
//    if (_bannerView) {
//        if (animated && self.googleAdVisible) {
//            [UIView animateWithDuration:0.25f
//                                  delay:0.f
//                                options:UIViewAnimationOptionCurveEaseInOut
//                             animations:^{
//                                 CGRect frame;
//                                 frame.origin = CGPointMake(self.bannerView.frame.origin.x,
//                                                            CGRectGetHeight(self.containerView.frame));
//                                 frame.size = self.bannerView.frame.size;
//                                 
//                                 self.bannerView.frame = frame;
//                             }
//                             completion:^(BOOL finished){
//                                 dispatch_async(dispatch_get_main_queue(), ^{
//                                     [self destroyGoogleAdsAnimated:NO];
//                                 });
//                             }
//             ];
//        }
//        else{
//            [self.bannerView removeFromSuperview];
//            self.bannerView.delegate = nil;
//            self.bannerView.rootViewController = nil;
//            
//            [_bannerView release], _bannerView = nil;
//            self.googleAdVisible = NO;
//            self.anyAdsVisible = (self.isIAdVisible || self.isGoogleAdVisible);
//        }
//    }
//}

#pragma mark - Optional Adapter Implementation

- (void)setPublisherId:(NSString *)publisherId{
    _publisherId = [publisherId copy];
    
    if (_bannerView != nil) {
        self.bannerView.adUnitID = self.publisherId;
    }
}

#pragma mark - AdMob Delegate Methods
- (void)adViewDidReceiveAd:(GADBannerView *)bannerView{
    
    if ([self.adManager respondsToSelector:@selector(adSucceededForNetworkAdapterClass:)]) {
        [self.adManager adSucceededForNetworkAdapterClass:[self class]];
    }
    
//    CGRect newFrame;
//    newFrame.origin = CGPointMake(self.iAdBannerView.frame.origin.x,
//                                  CGRectGetHeight(self.containerView.frame) - CGRectGetHeight(self.iAdBannerView.frame));
//    newFrame.size = self.iAdBannerView.frame.size;
    
//    [UIView animateWithDuration:0.25f
//                          delay:0.f
//                        options:UIViewAnimationOptionCurveEaseInOut
//                     animations:^{
//                         self.googleAdBannerView.frame = newFrame;
//                     }
//                     completion:^(BOOL finished){
//                         self.googleAdVisible = YES;
//                         self.anyAdsVisible = (self.isIAdVisible || self.isGoogleAdVisible);
//                         self.containerView.userInteractionEnabled = YES;
//                         self.googleAdBannerView.userInteractionEnabled = YES;
//                     }
//     ];
    
#ifdef LARSADCONTROLLER_DEBUG
    NSLog(@"%@: Google ad did receive ad", NSStringFromClass([self class]));
#endif
}
//
- (void)adView:(GADBannerView *)bannerView didFailToReceiveAdWithError:(GADRequestError *)error{
//    CGRect newFrame;
//    newFrame.origin = CGPointMake(CGRectGetMinX(self.googleAdBannerView.frame),
//                                  CGRectGetHeight(self.containerView.frame));
//    newFrame.size = self.googleAdBannerView.frame.size;
    
//    [UIView animateWithDuration:0.25f
//                          delay:0.f
//                        options:UIViewAnimationOptionCurveEaseInOut
//                     animations:^{
//                         self.googleAdBannerView.frame = newFrame;
//                     }
//                     completion:^(BOOL finished){
//                         self.googleAdVisible = NO;
//                         self.anyAdsVisible = (self.isIAdVisible || self.isGoogleAdVisible);
//                         self.containerView.userInteractionEnabled = NO;//assuming if a google ad fails to appear, there are no ads at all
//                     }
//     ];
    
    if ([self.adManager respondsToSelector:@selector(adFailedForNetworkAdapterClass:)]) {
        [self.adManager adFailedForNetworkAdapterClass:[self class]];
    }
    
#ifdef LARSADCONTROLLER_DEBUG
    NSLog(@"%@: Google ad did fail to receive ad", NSStringFromClass([self class]));
#endif
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
