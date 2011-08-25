//
//  LARSAdController.m
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

#import "LARSAdController.h"

@implementation LARSAdController

@synthesize googleAdBannerView          = _googleAdBannerView;
@synthesize parentView                  = _parentView;
@synthesize googleAdVisible             = _googleAdVisible;
@synthesize iAdVisible                  = _iAdVisible;
@synthesize parentViewController        = _parentViewController;
@synthesize shouldAlertUserWhenLeaving  = _shouldAlertUserWhenLeaving;
@synthesize googleAdPublisherId         = _googleAdPublisherId;
@synthesize lastOrientationWasPortrait  = _lastOrientationWasPortrait;
@synthesize currentOrientation          =_currentOrientation;

//replace with your own google id
#define kGoogleAdId @"a14c8986cea46d3"
#define LARS_PAD_AD_CONTAINER_HEIGHT 90.0f
#define LARS_POD_AD_CONTAINER_HEIGHT 50.0f

static LARSAdController *sharedController = nil;

#pragma mark -
#pragma mark Class Methods

+ (LARSAdController *)sharedManager{
    if (sharedController == nil) {
        sharedController = [[super allocWithZone:NULL] init];
        [sharedController setGoogleAdVisible:NO];
        [sharedController setIAdVisible:NO];
        [sharedController setParentViewController:nil];
        [sharedController setShouldAlertUserWhenLeaving:NO];
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

- (oneway void)release{
    //empty implementation to prevent user releasing
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
        [self setCurrentOrientation:viewController.interfaceOrientation];
        [self setParentViewController:viewController];
        [self setParentView:view];
        
        [[self containerView] addSubview:[self iAdBannerView]];
        [self fixAdContainerFrame];
        [view addSubview:[self containerView]];
    }
    else{
        //ad container exists, and bring to front
        [view bringSubviewToFront:[self containerView]];
    }
    
    if (_googleAdBannerView) {
        [[self googleAdBannerView] setRootViewController:[self parentViewController]];
    }
}

- (UIView *)containerView{
    if (!_containerView) {
        CGFloat height = (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) ? LARS_PAD_AD_CONTAINER_HEIGHT : LARS_POD_AD_CONTAINER_HEIGHT;
        CGRect frame = CGRectMake(0.0f, self.parentView.frame.size.height-height, self.parentView.frame.size.width, height);
        
        _containerView                  = [[UIView alloc] initWithFrame:frame];
        _containerView.autoresizingMask = UIViewAutoresizingFlexibleWidth | 
                                            UIViewAutoresizingFlexibleHeight | 
                                            UIViewAutoresizingFlexibleTopMargin;
        _containerView.backgroundColor  = [UIColor clearColor];
    }
    return _containerView;
}

- (NSString *)containerSizeForDeviceOrientation:(UIInterfaceOrientation)orientation{
    CGFloat width = self.containerView.frame.size.width;
    CGFloat xOffset = (UIInterfaceOrientationIsLandscape(orientation)) ? self.parentView.frame.size.width : self.parentView.frame.size.height;
    
    if (UIInterfaceOrientationIsLandscape(orientation)) {
        if (self.lastOrientationWasPortrait)
            width = self.parentView.frame.size.height;
        
        self.lastOrientationWasPortrait = NO;
    }
    else{//portrait
        if (!self.lastOrientationWasPortrait)
            width = self.parentView.frame.size.width;
        
        self.lastOrientationWasPortrait = YES;
    }
    
    CGFloat height  = (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) ? LARS_PAD_AD_CONTAINER_HEIGHT :LARS_POD_AD_CONTAINER_HEIGHT;
    CGRect frame    = CGRectMake(0.0f, xOffset-height, width, height);
    
    return NSStringFromCGRect(frame);
}

- (void)layoutBannerViewsForCurrentOrientation:(UIInterfaceOrientation)orientation{
    [self setCurrentOrientation:orientation];
    [self fixAdContainerFrame];
    
    CGRect contentFrame     = self.containerView.bounds;
	CGPoint bannerOrigin    = CGPointMake(CGRectGetMinX(contentFrame), CGRectGetMaxY(contentFrame));
    
    //change iAd layout
    if(UIInterfaceOrientationIsLandscape(orientation))
		self.iAdBannerView.currentContentSizeIdentifier = (&ADBannerContentSizeIdentifierLandscape != nil) ? ADBannerContentSizeIdentifierLandscape : ADBannerContentSizeIdentifier480x32;
    else
        self.iAdBannerView.currentContentSizeIdentifier = (&ADBannerContentSizeIdentifierPortrait != nil) ? ADBannerContentSizeIdentifierPortrait : ADBannerContentSizeIdentifier320x50;
    
    if(self.iAdBannerView.bannerLoaded){
        //adjust banner view up by height if loaded
        bannerOrigin.y = CGRectGetMaxY(contentFrame)-self.iAdBannerView.frame.size.height;
    }
    
    [UIView animateWithDuration:0.2f
                     animations:^{
                         self.iAdBannerView.frame = CGRectMake(bannerOrigin.x, bannerOrigin.y, self.iAdBannerView.frame.size.width, self.iAdBannerView.frame.size.height);
                     }];
    
    [self recenterGoogleAdBannerView];
}

- (void)fixAdContainerFrame{
    [[self containerView] setFrame:CGRectFromString([self containerSizeForDeviceOrientation:self.currentOrientation])];
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
                         }
         ];
    }
}

- (BOOL)bannerViewActionShouldBegin:(ADBannerView *)banner willLeaveApplication:(BOOL)willLeave{
    return YES;
}

//- (void)bannerViewActionDidFinish:(ADBannerView *)banner{
//    
//}

- (void)bannerView:(ADBannerView *)banner didFailToReceiveAdWithError:(NSError *)error{
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
- (ADBannerView *)iAdBannerView{
    if (!_iAdBannerView) {
        NSString *contentSize;
        if (&ADBannerContentSizeIdentifierPortrait != nil)
        {
            contentSize = UIInterfaceOrientationIsPortrait(self.currentOrientation) ? ADBannerContentSizeIdentifierPortrait : ADBannerContentSizeIdentifierLandscape;
        }
        else
        {
            // user the older sizes 
            contentSize = UIInterfaceOrientationIsPortrait(self.currentOrientation) ? ADBannerContentSizeIdentifier320x50 : ADBannerContentSizeIdentifier480x32;
        }

        CGRect frame;
        frame.size = [ADBannerView sizeFromBannerContentSizeIdentifier:contentSize];
        
        //create offscreen
        frame.origin = CGPointMake(0.0f, CGRectGetMaxY(self.containerView.bounds));
        
        _iAdBannerView = [[ADBannerView alloc] initWithFrame:frame];
        _iAdBannerView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        _iAdBannerView.requiredContentSizeIdentifiers = (&ADBannerContentSizeIdentifierPortrait != nil) ?
        [NSSet setWithObjects:ADBannerContentSizeIdentifierPortrait, ADBannerContentSizeIdentifierLandscape, nil] : 
        [NSSet setWithObjects:ADBannerContentSizeIdentifier320x50, ADBannerContentSizeIdentifier480x32, nil];
         
        [_iAdBannerView setDelegate:self];
    }
    return _iAdBannerView;
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
        CGRect frame;

        //create size depending on device and orientation
        if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
            frame = CGRectMake(0.0f, self.containerView.frame.size.height-
                               GAD_SIZE_728x90.height+1.0, GAD_SIZE_728x90.width, GAD_SIZE_728x90.height);
        }
        else{
            frame = CGRectMake(0.0f, self.containerView.frame.size.height-
                               GAD_SIZE_320x50.height+1.0, GAD_SIZE_320x50.height, GAD_SIZE_320x50.width);
        }
        
        _googleAdBannerView = [[GADBannerView alloc] initWithFrame:frame];
        [self recenterGoogleAdBannerView];
        
        if(!_googleAdPublisherId)
            [[self googleAdBannerView] setAdUnitID:kGoogleAdId];
        else
            [self setGoogleAdPublisherId:[self googleAdPublisherId]];
        
        [[self googleAdBannerView] setRootViewController:[self parentViewController]];
        [[self googleAdBannerView] setDelegate:self];
        [[self googleAdBannerView] loadRequest:[GADRequest request]];
        
        [[self containerView] addSubview:[self googleAdBannerView]];
        [[self containerView] sendSubviewToBack:[self googleAdBannerView]];
    }
}

- (void)recenterGoogleAdBannerView{
    if (_googleAdBannerView) {
        [[self googleAdBannerView] setCenter:CGPointMake(self.containerView.frame.size.width/2, self.googleAdBannerView.center.y)];
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

- (void)setGoogleAdPublisherId:(NSString *)publisherId{
    [publisherId retain];
    
    if (_googleAdBannerView) {
        [[self googleAdBannerView] setAdUnitID:publisherId];
    }
    
    if(_googleAdPublisherId){
        [_googleAdPublisherId release];
    }
    _googleAdPublisherId = publisherId;
}

#pragma mark -
#pragma mark AdMob/Google Delegate Methods
//- (void)adViewDidReceiveAd:(GADBannerView *)bannerView{
//    NSLog(@"Google ad did receive ad");
//}
//
//- (void)adView:(GADBannerView *)bannerView didFailToReceiveAdWithError:(GADRequestError *)error{
//    NSLog(@"Google ad failed to receive ad");
//}

// Unused Google Ad Delegate Methods
//
//- (void)adViewWillPresentScreen:(GADBannerView *)bannerView{
//    
//}
//
//- (void)adViewDidDismissScreen:(GADBannerView *)bannerView{
//    
//}
//
//
//- (void)adViewWillLeaveApplication:(GADBannerView *)bannerView{
//
//}

@end
