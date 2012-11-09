//
//  LARSAdController.m
//  Droid Light
//
//  Created by Lars Anderson on 7/24/11.
//
//Copyright (c) 2011 Lars Anderson, drink&apple, theonlylars
//
//Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
//
//The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
//
//THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

#import <QuartzCore/QuartzCore.h>

#import "LARSAdController.h"
#import "GADBannerView.h"
#import "LARSAdAdapter.h"

@interface LARSAdController()

@property (nonatomic) BOOL lastOrientationWasPortrait;
@property (nonatomic) UIInterfaceOrientation currentOrientation;
@property (nonatomic, retain, readwrite) UIView *containerView;
@property (nonatomic,
           getter = isRegisteredForOrientationChanges) BOOL registeredForOrientationChanges;

/*
 Contains the ads so they will clip since the outer container does not clip subviews to retain shadows
 */
@property (strong, nonatomic) UIView *clippingContainer;

//orientation support
- (CGRect)containerFrameForInterfaceOrientation:(UIInterfaceOrientation)orientation;
- (void)fixAdContainerFrame;

- (void)registerForDeviceRotationNotifications;
- (void)unRegisterFromDeviceRotationNotifications;
- (void)handleOrientationNotification:(NSNotification *)orientationNotification;
@end

@implementation LARSAdController

CGFloat const kLARSAdContainerHeightPad = 90.0f;
CGFloat const kLARSAdContainerHeightPod = 50.0f;

#pragma mark -
#pragma mark Class Methods

+ (LARSAdController *)sharedManager{
    
    static LARSAdController *_sharedManager;
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedManager = [[super allocWithZone:NULL] init];
        
        _sharedManager.registeredClasses = [NSMutableArray array];
        _sharedManager.adapterClassPublisherIds = [NSMutableDictionary dictionary];
        _sharedManager.adapterInstances = [NSMutableDictionary dictionary];
    });
    
    return _sharedManager;
}

+ (id)allocWithZone:(NSZone *)zone{
    return [self sharedManager];
}

#pragma mark -
#pragma mark Singleton Implementation Methods

- (id)copyWithZone:(NSZone *)zone{
    return self;
}

- (void)dealloc{//this should never get called
    _containerView = nil;
    _clippingContainer = nil;
}

#pragma mark -
#pragma mark Public Methods
- (void)addAdContainerToView:(UIView *)view withParentViewController:(UIViewController *)viewController{
    //remove container from superview
    //  add ad container to new view as subview at bottom
    if (![view.subviews containsObject:self.containerView]) {
        self.currentOrientation = viewController.interfaceOrientation;
        self.parentViewController = viewController;
        self.parentView = view;
        
        //TODO: add ad network banner to clipping container
        
        [self fixAdContainerFrame];
        [view addSubview:self.containerView];
    }
    else{
        //ad container exists, and bring to front
        [view bringSubviewToFront:self.containerView];
    }
    
    //TODO: set view controller on ad banners that require it
    
    [self layoutBannerViewsForCurrentOrientation:viewController.interfaceOrientation];
}

- (UIView *)containerView{
    if (!_containerView) {
        CGFloat height = (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) ? kLARSAdContainerHeightPad : kLARSAdContainerHeightPod;
        CGRect frame = CGRectMake(0.0f,
                                  CGRectGetHeight(self.parentView.frame)-height,
                                  CGRectGetWidth(self.parentView.frame),
                                  height);
        
        _containerView = [[UIView alloc] initWithFrame:frame];
        _containerView.autoresizingMask = UIViewAutoresizingFlexibleWidth | 
        UIViewAutoresizingFlexibleTopMargin;
        _containerView.backgroundColor  = [UIColor clearColor];
        _containerView.clipsToBounds = NO;
        _containerView.userInteractionEnabled = NO;//off by default to ensure users can touch behind ad container
        
        _containerView.layer.shadowRadius = 10.f;
        _containerView.layer.shadowColor = [UIColor blackColor].CGColor;
        _containerView.layer.shadowOpacity = 0.6f;
        _containerView.layer.shadowOffset = CGSizeMake(0.f, 0.f);
        _containerView.layer.shouldRasterize = YES;
        _containerView.layer.rasterizationScale = [[UIScreen mainScreen] scale];
        
        _clippingContainer = [[UIView alloc] initWithFrame:_containerView.bounds];
        self.clippingContainer.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
        self.clippingContainer.backgroundColor = [UIColor clearColor];
        self.clippingContainer.clipsToBounds = YES;
        self.clippingContainer.userInteractionEnabled = YES;
        
        [_containerView addSubview:self.clippingContainer];
    }
    return _containerView;
}

- (CGRect)containerFrameForInterfaceOrientation:(UIInterfaceOrientation)orientation{
    CGFloat width;
    CGFloat yOrigin;
    
    if (UIInterfaceOrientationIsLandscape(orientation)) {
#ifdef LARSADCONTROLLER_DEBUG
            NSLog(@"View is landscape");
#endif
        
        yOrigin = CGRectGetWidth(self.parentView.frame);
        width = CGRectGetHeight(self.parentView.frame);
        self.lastOrientationWasPortrait = NO;
    }
    else{//portrait
#ifdef LARSADCONTROLLER_DEBUG
            NSLog(@"View is portrait");
#endif
        
        yOrigin = CGRectGetHeight(self.parentView.frame);
        width = CGRectGetWidth(self.parentView.frame);
        self.lastOrientationWasPortrait = YES;
    }
    
    CGFloat height;
    if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad){
        height = kLARSAdContainerHeightPad; 
    }
    else{
        height = kLARSAdContainerHeightPod;
    }
    
    yOrigin = yOrigin - height;
    
    CGRect newFrame = CGRectMake(0.f, yOrigin, width, height);
    
    return newFrame;
}

//- (void)layoutBannerViewsForCurrentOrientation:(UIInterfaceOrientation)orientation{
//    self.currentOrientation = orientation;
//    [self fixAdContainerFrame];
//    
//#pragma clang diagnostic push
//#pragma clang diagnostic ignored "-Wdeprecated-declarations"
//    
//    //change iAd layout
//    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
//        if (CGRectGetWidth(self.containerView.frame) < 1024.f) {
//            self.iAdBannerView.currentContentSizeIdentifier = (&ADBannerContentSizeIdentifierPortrait != nil) ? ADBannerContentSizeIdentifierPortrait : ADBannerContentSizeIdentifier320x50;
//        }
//        else {
//            self.iAdBannerView.currentContentSizeIdentifier = (&ADBannerContentSizeIdentifierLandscape != nil) ? ADBannerContentSizeIdentifierLandscape : ADBannerContentSizeIdentifier480x32;
//        }
//    }
//    else{
//        if (CGRectGetWidth(self.containerView.frame) < 480.f) {
//            self.iAdBannerView.currentContentSizeIdentifier = (&ADBannerContentSizeIdentifierPortrait != nil) ? ADBannerContentSizeIdentifierPortrait : ADBannerContentSizeIdentifier320x50;
//        }
//        else{
//            self.iAdBannerView.currentContentSizeIdentifier = (&ADBannerContentSizeIdentifierLandscape != nil) ? ADBannerContentSizeIdentifierLandscape : ADBannerContentSizeIdentifier480x32;
//        }
//    }
//    
//#pragma clang diagnostic pop
//    
//    [self recenterGoogleAdBannerView];
//}

- (void)fixAdContainerFrame{
    self.containerView.frame = [self containerFrameForInterfaceOrientation:self.currentOrientation];
}

- (void)setShouldHandleOrientationChanges:(BOOL)shouldHandleOrientationChanges{
    [self willChangeValueForKey:@"shouldHandleOrientationChanges"];
    _shouldHandleOrientationChanges = shouldHandleOrientationChanges;
    [self didChangeValueForKey:@"shouldHandleOrientationChanges"];
    
    if (shouldHandleOrientationChanges == YES) {
        [self registerForDeviceRotationNotifications];
    }
    else{
        [self unRegisterFromDeviceRotationNotifications];
    }
}

//#pragma mark -
//#pragma mark iAd Delegate Methods
//- (void)bannerViewDidLoadAd:(ADBannerView *)banner{
//    // if google ad is active
//    //     release ad instance
//    [self destroyGoogleAdsAnimated:YES];
//    
//    if (!self.isIAdVisible) {
//        CGRect newFrame;
//        newFrame.origin = CGPointMake(CGRectGetMinX(banner.frame), CGRectGetHeight(self.containerView.frame) - CGRectGetHeight(banner.frame));
//        newFrame.size = banner.frame.size;
//        
//        [UIView animateWithDuration:0.250 
//                              delay:0.0 
//                            options:UIViewAnimationOptionCurveEaseInOut
//                         animations:^{
//                             banner.frame = newFrame;
//                         }
//                         completion:^(BOOL finished){
//                             self.iAdVisible = YES;
//                             self.anyAdsVisible = (self.isIAdVisible || self.isGoogleAdVisible);
//                             self.containerView.userInteractionEnabled = YES;
//                         }
//         ];
//        
//#ifdef LARSADCONTROLLER_DEBUG
//        NSLog(@"%@: iAd frame after ad load: %@", NSStringFromClass([self class]), NSStringFromCGRect(newFrame));
//#endif
//    }
//    
//#ifdef LARSADCONTROLLER_DEBUG
//    NSLog(@"%@: iAd did load ad", NSStringFromClass([self class]));
//#endif
//}
//
//- (BOOL)bannerViewActionShouldBegin:(ADBannerView *)banner willLeaveApplication:(BOOL)willLeave{
//    return YES;
//}
//
//- (void)bannerViewActionDidFinish:(ADBannerView *)banner{
//    [self layoutBannerViewsForCurrentOrientation:self.parentViewController.interfaceOrientation];
//}
//
//- (void)bannerView:(ADBannerView *)banner didFailToReceiveAdWithError:(NSError *)error{
//    //if google ad instance is nil
//    //  create new instance of google ad
//    if (self.isIAdVisible) {
//        CGRect newFrame;
//        newFrame.origin = CGPointMake(CGRectGetMinX(banner.frame), CGRectGetHeight(self.containerView.frame));
//        newFrame.size = banner.frame.size;
//        
//        [UIView animateWithDuration:0.250 
//                              delay:0.0 
//                            options:UIViewAnimationOptionCurveEaseInOut
//                         animations:^{
//                             banner.frame = newFrame;
//                         }
//                         completion:^(BOOL finished){
//                             self.iAdVisible = NO;
//                             self.anyAdsVisible = (self.isIAdVisible || self.isGoogleAdVisible);
//                             self.containerView.userInteractionEnabled = NO;//google ad will re-enable userInteraction when necessary
//                         }
//         ];
//#ifdef LARSADCONTROLLER_DEBUG
//        NSLog(@"%@: iAd frame after ad fail: %@", NSStringFromClass([self class]), NSStringFromCGRect(newFrame));
//#endif
//    }
//    
//    //TODO: activate next ad network
//    
//    //if ad container is not a subview of the parent view
//    //  add ad container as subview of parent
//    if(self.containerView.superview != self.parentView){  
//        [self.parentView addSubview:self.containerView];
//        [self.parentView bringSubviewToFront:self.containerView];
//        [self.clippingContainer bringSubviewToFront:self.iAdBannerView];
//    }
//    
//#ifdef LARSADCONTROLLER_DEBUG
//    NSLog(@"%@: iAd frame after ad fail: %@", NSStringFromClass([self class]), NSStringFromCGRect(self.iAdBannerView.frame));
//#endif
//    
//#ifdef LARSADCONTROLLER_DEBUG
//    NSLog(@"%@: iAd did fail to receive ad", NSStringFromClass([self class]));
//#endif
//}

//#pragma mark -
//#pragma mark iAd Methods
//- (ADBannerView *)iAdBannerView{
//    if (!_iAdBannerView) {
//        NSString *contentSize;
//        
//#pragma clang diagnostic push
//#pragma clang diagnostic ignored "-Wdeprecated-declarations"
//        if ((&ADBannerContentSizeIdentifierLandscape != nil)) {
//            contentSize = UIInterfaceOrientationIsPortrait(self.currentOrientation) ? ADBannerContentSizeIdentifierPortrait : ADBannerContentSizeIdentifierLandscape;
//        }
//        else {
//            contentSize = UIInterfaceOrientationIsPortrait(self.currentOrientation) ? ADBannerContentSizeIdentifier320x50 : ADBannerContentSizeIdentifier480x32;
//        }
//#pragma clang diagnostic pop
//        
//        CGRect frame;
//        frame.size = [ADBannerView sizeFromBannerContentSizeIdentifier:contentSize];
//        
//        //create offscreen
//        frame.origin = CGPointMake(0.0f, CGRectGetMaxY(self.containerView.bounds));
//        
//        _iAdBannerView = [[ADBannerView alloc] initWithFrame:frame];
//        _iAdBannerView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleTopMargin;
//        
//#pragma clang diagnostic push
//#pragma clang diagnostic ignored "-Wdeprecated-declarations"
//        if ((&ADBannerContentSizeIdentifierLandscape != nil)) {
//            _iAdBannerView.requiredContentSizeIdentifiers = [NSSet setWithObjects:ADBannerContentSizeIdentifierPortrait, ADBannerContentSizeIdentifierLandscape, nil];
//        }
//        else{
//            _iAdBannerView.requiredContentSizeIdentifiers = [NSSet setWithObjects:ADBannerContentSizeIdentifier320x50, ADBannerContentSizeIdentifier480x32, nil];
//        }
//#pragma clang diagnostic pop
//        
//        _iAdBannerView.delegate = self;
//    }
//    return _iAdBannerView;
//}

//- (void)destroyIAds{
//    [self.iAdBannerView removeFromSuperview];
//    self.iAdBannerView.delegate = nil;
//    [_iAdBannerView release], _iAdBannerView = nil;
//}

#pragma mark - Ad Management
- (void)registerAdAdapter:(Class)class withPublisherId:(NSString *)publisherId{
    [self.registeredClasses addObject:class];
    [self.adapterClassPublisherIds setObject:publisherId forKey:NSStringFromClass(class)];
}

- (void)registerAdAdapter:(Class)class{
    [self.registeredClasses addObject:class];
}

#pragma mark - Ad Adapter Delegate
- (void)adFailedForNetworkAdapterClass:(Class)class{
    //get index of adapter class
    NSInteger failedNetworkIndex = [self.registeredClasses indexOfObject:class];
    
    if (failedNetworkIndex < self.registeredClasses.count-1) {
        //trigger next ad network in line
        Class currentClass = [self.registeredClasses objectAtIndex:failedNetworkIndex+1];
        
        if([self startAdNetworkAdapterClass:currentClass] == NO){
            [self adFailedForNetworkAdapterClass:currentClass];
        }
    }
}

- (void)adSucceededForNetworkAdapterClass:(Class)class{
    //get index of adapter class
    NSInteger succeededNetworkIndex = [self.registeredClasses indexOfObject:class];
    
    //Halt all networks with lower priority than succeeded network
    for (int i = succeededNetworkIndex; i < self.registeredClasses.count; i++) {
        [self haltAdNetworkAdapterClass:self.registeredClasses[i]];
    }
}

- (BOOL)startAdNetworkAdapterClass:(Class)class{
    id <LARSAdAdapter> adapter = [self.adapterInstances objectForKey:NSStringFromClass(class)];
    
    if (!adapter) {
        //TODO: Stard adapter and add banner to container
        adapter = [[class alloc] init];
        adapter.adManager = self;
        
        NSString *publisherId = [self.adapterClassPublisherIds objectForKey:NSStringFromClass(class)];
        if (publisherId) {
            [adapter setPublisherId:publisherId];
        }
        else if([class resolveClassMethod:@selector(requiresPublisherId)]){
            NSLog(@"%@ WARNING: Ad network adapter %@ requires a publisher ID, but none was specified when instance was allocated!", NSStringFromClass([self class]), NSStringFromClass(class));
            return NO;
        }
        
        [self.adapterInstances setObject:adapter forKey:NSStringFromClass(class)];
    }
    
    //TODO: add adapter banner view to container
    //TODO: animate on screen
    
    return YES;
}

- (void)haltAdNetworkAdapterClass:(Class)class{
    id <LARSAdAdapter> adapter = [self.adapterInstances objectForKey:NSStringFromClass(class)];
    
    if (adapter.adVisible) {
        //TODO: visually hide ad
        
        if ([adapter respondsToSelector:@selector(pauseAdRequests)]) {
            [adapter pauseAdRequests];
        }
        else{
            //TODO: deallocate adapter instance
        }
    }
}

#pragma mark - Orientation Handlers
//TODO: add iOS 6 rotation support
- (void)registerForDeviceRotationNotifications{
    if (!self.isRegisteredForOrientationChanges) {
#ifdef LARSADCONTROLLER_DEBUG
        NSLog(@"Registering for orientation notifications");
#endif
        
        self.registeredForOrientationChanges = YES;
        
        [[UIDevice currentDevice] beginGeneratingDeviceOrientationNotifications];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleOrientationNotification:) name:UIDeviceOrientationDidChangeNotification object:nil];
    }
}

- (void)unRegisterFromDeviceRotationNotifications{
    if (self.isRegisteredForOrientationChanges == YES) {
#ifdef LARSADCONTROLLER_DEBUG
        NSLog(@"Unregistering for orientation notifications");
#endif
        
        [[UIDevice currentDevice] endGeneratingDeviceOrientationNotifications];
        [[NSNotificationCenter defaultCenter] removeObserver:self name:UIDeviceOrientationDidChangeNotification object:nil];
        
        self.registeredForOrientationChanges = NO;
    }
}

- (void)handleOrientationNotification:(NSNotification *)orientationNotification{
#ifdef LARSADCONTROLLER_DEBUG
        NSLog(@"Handling orientation change");
#endif
    
    double delayInSeconds = 0.01f;
    
    //interface orientation wasn't always guaranteed without dispatch_after
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC);
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        [self layoutBannerViewsForCurrentOrientation:self.parentViewController.interfaceOrientation];
    });
}

@end
