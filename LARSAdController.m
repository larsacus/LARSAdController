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
    //  add ad container to new view as subview at bottom
    
    if (![[view subviews] containsObject:[self containerView]]) {
        NSLog(@"Adding ad container to view");
        
        [[self containerView] removeFromSuperview];
        [self setParentViewController:viewController];
        [self setParentView:view];
        [self createContainerView];
        [self createIAds];
        
        [view addSubview:[self containerView]];
    }
    else{
        //ad container exists, and bring to front
        [view bringSubviewToFront:[self containerView]];
        NSLog(@"Ad container already in subview - bringing to front");
    }
    
    if (_googleAdBannerView) {
        [[self googleAdBannerView] setRootViewController:[self parentViewController]];
    }
}

- (void)createContainerView{
    if (!_containerView) {
        _containerView = [[UIView alloc] initWithFrame:CGRectMake(0.0, self.parentView.frame.size.height-50, 320.0, 50.0)];
        [[self containerView] setAutoresizingMask:
                                        UIViewAutoresizingFlexibleTopMargin |
                                        UIViewAutoresizingFlexibleWidth
        ];

        NSLog(@"Create container view");
    }
}

#pragma mark -
#pragma mark iAd Delegate Methods
- (void)bannerViewDidLoadAd:(ADBannerView *)banner{
    // if google ad is active
    //     release ad instance
    [self destroyGoogleAdsAnimated:YES];
    
    if (![self isIAdVisible]) {
        [UIView animateWithDuration:0.250 
                              delay:0.0 
                            options:UIViewAnimationOptionCurveEaseInOut
                         animations:^{
                             [banner setFrame:CGRectOffset(banner.frame, 0.0, -banner.frame.size.height)];
                         }
                         completion:^(BOOL finished){
                             [self setIAdVisible:YES];
                             NSLog(@"iAd Animation Finished");
                         }
         ];
    }
    NSLog(@"iAd Loaded");
}

- (BOOL)bannerViewActionShouldBegin:(ADBannerView *)banner willLeaveApplication:(BOOL)willLeave{
    return YES;
}

//- (void)bannerViewActionDidFinish:(ADBannerView *)banner{
//    
//}

- (void)bannerView:(ADBannerView *)banner didFailToReceiveAdWithError:(NSError *)error{
    NSLog(@"Failed to receive iAd");
    
    //if google ad instance is nil
    //  create new instance of google ad
    if ([self isIAdVisible]) {
        [UIView animateWithDuration:0.250 
                              delay:0.0 
                            options:UIViewAnimationOptionCurveEaseInOut
                         animations:^{
                             [banner setFrame:CGRectOffset(banner.frame, 0.0, banner.frame.size.height)];
                         }
                         completion:^(BOOL finished){
                             [self setIAdVisible:NO];
                         }
         ];
    }
    
    if (!_googleAdBannerView) {
        [self createGoogleAds];
    }
    
    //if ad container is not a subview of the parent view
    //  add ad container as subview of parent
    if (![[[self parentView] subviews] containsObject:[self containerView]]) {
        [[self parentView] addSubview:[self containerView]];
        [[self parentView] bringSubviewToFront:[self containerView]];
        [[self containerView] bringSubviewToFront:[self iAdBannerView]];
    }
}

#pragma mark -
#pragma mark iAd Methods
- (void)createIAds{
    NSLog(@"Creating iAds");
    
    //create offscreen
    if (!_iAdBannerView) {
        _iAdBannerView = [[ADBannerView alloc] initWithFrame:CGRectMake(0.0f, 50.0f, 320.0f, 50.0f)];
    }
    
    if (NSClassFromString(@"ADBannerContentSizeIdentifierPortrait")) {
        [[self iAdBannerView] setCurrentContentSizeIdentifier:ADBannerContentSizeIdentifierPortrait];
    }
    else{
        [[self iAdBannerView] setCurrentContentSizeIdentifier:ADBannerContentSizeIdentifier320x50];
    }
    
    [[self iAdBannerView] setDelegate:self];
    [[self containerView] addSubview:[self iAdBannerView]];
}

- (void)destroyIAds{
    NSLog(@"Destroying iAds");
    
    [[self iAdBannerView] removeFromSuperview];
    [[self iAdBannerView] setDelegate:nil];
    [_iAdBannerView release];
    _iAdBannerView = nil;
}

#pragma mark -
#pragma mark AdMob/Google Methods
- (void)createGoogleAds{
    if (!_googleAdBannerView) {
        NSLog(@"Creating google ads");
        
        _googleAdBannerView = [[GADBannerView alloc] initWithFrame:CGRectMake(0.0f,
                                                                              self.containerView.frame.size.height-
                                                                              GAD_SIZE_320x50.height+1.0,
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
        NSLog(@"Destroying google ads");
        
        if (animated) {
            [UIView animateWithDuration:0.250
                                  delay:0.0
                                options:UIViewAnimationOptionCurveEaseInOut
                             animations:^{
                                 [[self googleAdBannerView] setFrame:
                                      CGRectOffset(self.googleAdBannerView.frame, 
                                                   0.0, 
                                                   self.googleAdBannerView.frame.size.height)];
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
    NSLog(@"Google ad did receive ad");
}

- (void)adView:(GADBannerView *)bannerView didFailToReceiveAdWithError:(GADRequestError *)error{
    NSLog(@"Google ad failed to receive ad");
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
