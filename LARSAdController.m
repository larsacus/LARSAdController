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

@synthesize googleAdBannerView          = _googleAdBannerView;
@synthesize iAdBannerView               = _iAdBannerView;
@synthesize parentView                  = _parentView;
@synthesize containerView               = _containerView;
@synthesize googleAdVisible             = _googleAdVisible;
@synthesize iAdVisible                  = _iAdVisible;
@synthesize parentViewController        = _parentViewController;

//replace with your own google id
#define kGoogleAdId @"a14c8986cea46d3"

static LARSAdController *sharedController = nil;

#pragma mark -
#pragma mark Class Methods

+ (LARSAdController *)sharedManager{
    if (sharedController == nil) {
        sharedController = [[super allocWithZone:NULL] init];
        [sharedController setGoogleAdVisible:NO];
        [sharedController setIAdVisible:NO];
        [sharedController setParentViewController:nil];
    }
    return sharedController;
}

+ (id)allocWithZone:(NSZone *)zone{
    return [[self sharedManager] retain];
}

#pragma mark -
#pragma mark Singleton Implementation Methods

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
#pragma mark Public Methods
- (void)addAdContainerToView:(UIView *)view withParentViewController:(UIViewController *)viewController{
    //remove container from superview
    //ad container to new view as subview at bottom
    [self createContainerView];
    
    if (![[view subviews] containsObject:[self containerView]]) {
        [self createIAds];
        [[self containerView] removeFromSuperview];
        [view addSubview:[self containerView]];
        [[self containerView] setFrame:CGRectMake(0, 
                                                  view.frame.size.height-self.containerView.frame.size.height, 
                                                  self.containerView.frame.size.width, 
                                                  self.containerView.frame.size.height)];
    }
    if (_googleAdBannerView) {
        [[self googleAdBannerView] setRootViewController:viewController];
    }
    [self setParentViewController:viewController];
}

- (void)createContainerView{
    if (!_containerView) {
        _containerView = [[UIView alloc] initWithFrame:CGRectZero];
        [[self containerView] setAutoresizingMask:
                                        UIViewAutoresizingFlexibleTopMargin |
                                        UIViewAutoresizingFlexibleWidth
        ];
    }
}

#pragma mark -
#pragma mark iAd Delegate Methods
- (void)bannerViewDidLoadAd:(ADBannerView *)banner{
    // if google ad is active
    //     release ad instance
    [self destroyGoogleAdsAnimated:YES];
}

- (BOOL)bannerViewActionShouldBegin:(ADBannerView *)banner willLeaveApplication:(BOOL)willLeave{
    return YES;
}

- (void)bannerViewActionDidFinish:(ADBannerView *)banner{
    
}

- (void)bannerView:(ADBannerView *)banner didFailToReceiveAdWithError:(NSError *)error{
    //if google ad instance is nil
    //  create new instance of google ad
    if (!_googleAdBannerView) {
        [self createGoogleAds];
    }
    
    //if ad container is not a subview of the parent view
    //  add ad container as subview of parent
    if ([[[self parentView] subviews] indexOfObject:[self containerView]] == -1) {
        [[self parentView] addSubview:[self containerView]];
        [[self parentView] bringSubviewToFront:[self containerView]];
        [[self containerView] bringSubviewToFront:[self iAdBannerView]];
    }
}

#pragma mark -
#pragma mark iAd Methods
- (void)createIAds{
    //create offscreen
    _iAdBannerView = [[ADBannerView alloc] initWithFrame:CGRectMake(0.0f, -50.0f, 480.0f, 50.0f)];
    
    if (ADBannerContentSizeIdentifierPortrait) {
        [[self iAdBannerView] setCurrentContentSizeIdentifier:ADBannerContentSizeIdentifierPortrait];
    }
    else{
        [[self iAdBannerView] setCurrentContentSizeIdentifier:ADBannerContentSizeIdentifier320x50];
    }
    
    [[self iAdBannerView] setDelegate:self];
    [[self containerView] addSubview:[self iAdBannerView]];
}

- (void)destroyIAds{
    [[self iAdBannerView] removeFromSuperview];
    [[self iAdBannerView] setDelegate:nil];
    [_iAdBannerView release];
    _iAdBannerView = nil;
}

#pragma mark -
#pragma mark AdMob/Google Methods
- (void)createGoogleAds{
    if (!_googleAdBannerView) {
        _googleAdBannerView = [[GADBannerView alloc] initWithFrame:CGRectMake(0.0f,
                                                                              self.containerView.frame.size.height-
                                                                              GAD_SIZE_320x50.height,
                                                                              GAD_SIZE_320x50.width,
                                                                              GAD_SIZE_320x50.height)];
        [[self googleAdBannerView] setAdUnitID:kGoogleAdId];
        [[self googleAdBannerView] setRootViewController:[self parentViewController]];
        [[self googleAdBannerView] setDelegate:self];
        [[self googleAdBannerView] loadRequest:[GADRequest request]];
        
        [[self containerView] addSubview:[self googleAdBannerView]];
        [[self containerView] sendSubviewToBack:[self googleAdBannerView]];
    }
}

- (void)destroyGoogleAdsAnimated:(BOOL)animated{
    if (_googleAdBannerView) {
        if (animated) {
            [UIView animateWithDuration:0.250
                                  delay:0.0
                                options:UIViewAnimationOptionCurveEaseInOut
                             animations:^{
                                 [[self googleAdBannerView] setFrame:
                                      CGRectOffset(self.googleAdBannerView.frame, 
                                                   0.0, 
                                                   -self.googleAdBannerView.frame.size.height)];
                             }
                             completion:^(BOOL finished){
                                 dispatch_async(dispatch_get_main_queue(), ^{
                                     [self destroyGoogleAdsAnimated:NO];
                                 });
                             }
             ];
        }
        else{
            [[self googleAdBannerView] removeFromSuperview];
            [[self googleAdBannerView] setDelegate:nil];
            [[self googleAdBannerView] setRootViewController:nil];
            [_googleAdBannerView release];
            _googleAdBannerView = nil;
        }
        
    }
}

#pragma mark -
#pragma mark AdMob/Google Delegate Methods
- (void)adViewDidReceiveAd:(GADBannerView *)bannerView{
    if (![self isIAdVisible]) {
        [UIView animateWithDuration:0.250 
                              delay:0.0 
                            options:UIViewAnimationOptionCurveEaseInOut
                         animations:^{
                             [bannerView setFrame:CGRectOffset(bannerView.frame, 0.0, bannerView.frame.size.height)];
                         }
                         completion:^(BOOL finished){
                             [self setIAdVisible:YES];
                         }
         ];
    }
}

- (void)adView:(GADBannerView *)bannerView didFailToReceiveAdWithError:(GADRequestError *)error{
    if ([self isIAdVisible]) {
        [UIView animateWithDuration:0.250 
                              delay:0.0 
                            options:UIViewAnimationOptionCurveEaseInOut
                         animations:^{
                             [bannerView setFrame:CGRectOffset(bannerView.frame, 0.0, -bannerView.frame.size.height)];
                         }
                         completion:^(BOOL finished){
                             [self setIAdVisible:NO];
                         }
         ];
    }
}
//
//- (void)adViewWillPresentScreen:(GADBannerView *)bannerView{
//    
//}
//
//- (void)adViewDidDismissScreen:(GADBannerView *)bannerView{
//    
//}
//
//- (void)adViewWillLeaveApplication:(GADBannerView *)bannerView{
//    
//}

@end
