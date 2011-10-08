//
//  LARSAdController.h
//  Droid Light
//
//  Created by Lars Anderson on 7/24/11.
//
//Copyright (c) 2011 Lars Anderson, drink&apple
//
//Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
//
//The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
//
//THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

#import <Foundation/Foundation.h>
#import <iAd/iAd.h>
#import "GADBannerView.h"
#import "GADBannerViewDelegate.h"


@interface LARSAdController : NSObject <GADBannerViewDelegate, ADBannerViewDelegate> {
@private
    GADBannerView           *_googleAdBannerView;
    ADBannerView            *_iAdBannerView;
    UIView                  *_parentView;
    UIView                  *_containerView;
    UIViewController        *_parentViewController;
    BOOL                    _googleAdVisible;
    BOOL                    _iAdVisible;
    BOOL                    _shouldAlertUserWhenLeaving;
    NSString                *_googleAdPublisherId;
    BOOL                    _lastOrientationWasPortrait;
    UIInterfaceOrientation  _currentOrientation;
    BOOL                    _anyAdsVisible;
}

@property (nonatomic, retain)           GADBannerView     *googleAdBannerView;
@property (nonatomic, assign)           UIView            *parentView;
@property (nonatomic, assign)           UIViewController  *parentViewController;
@property (nonatomic, 
           getter = isGoogleAdVisible)  BOOL              googleAdVisible;
@property (nonatomic,
           getter = isIAdVisible)       BOOL              iAdVisible;
@property (nonatomic)                   BOOL              shouldAlertUserWhenLeaving;
@property (nonatomic, retain, readonly) NSString          *googleAdPublisherId;
@property (nonatomic)                   BOOL              lastOrientationWasPortrait;
@property (nonatomic)                   UIInterfaceOrientation currentOrientation;
@property (atomic, getter = areAnyAdsVisible) BOOL        anyAdsVisible;

+ (LARSAdController *)sharedManager;
- (void)addAdContainerToView:(UIView *)view withParentViewController:(UIViewController *)viewController;
- (void)setGoogleAdPublisherId:(NSString *)publisherId;

- (void)createGoogleAds;
- (ADBannerView *)iAdBannerView;
- (UIView *)containerView;

- (void)destroyIAds;
- (void)destroyGoogleAdsAnimated:(BOOL)animated;

//orientation support
- (NSString *)containerSizeForDeviceOrientation:(UIInterfaceOrientation)orientation;
- (void)layoutBannerViewsForCurrentOrientation:(UIInterfaceOrientation)orientation;
- (void)fixAdContainerFrame;
- (void)recenterGoogleAdBannerView;

@end
