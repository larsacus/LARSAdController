//
//  LARSAdController.m
//  Droid Light
//
//  Created by Lars Anderson on 11/11/12.
//
//  Copyright (c) 2011-2013 Lars Anderson, drink&apple, theonlylars
//
//Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
//
//The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
//
//THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

#import <QuartzCore/QuartzCore.h>
#import "objc/runtime.h"

#import "LARSAdController.h"
#import "GADBannerView.h"
#import "LARSAdAdapter.h"

@implementation LARSAdContainer

- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event{
    
    for (UIView *subview in self.subviews) {
        if ([subview hitTest:point withEvent:event]) {
            return [super hitTest:point withEvent:event];
        }
    }
    
    return nil;
}

@end

@interface LARSAdController()

@property (nonatomic) BOOL lastOrientationWasPortrait;
@property (nonatomic) UIInterfaceOrientation currentOrientation;
@property (nonatomic, strong, readwrite) LARSAdContainer *containerView;
@property (nonatomic, weak, readwrite) UIView *parentView;
@property (nonatomic, weak, readwrite) UIViewController *parentViewController;
@property (nonatomic,
           getter = isRegisteredForOrientationChanges) BOOL registeredForOrientationChanges;
@property (nonatomic, strong) NSMutableSet *instancesToCleanUp;
@property (nonatomic, readwrite) BOOL adVisible;

/*
 Contains the ads so they will clip since the outer container does not clip subviews to retain shadows
 */
@property (strong, nonatomic) LARSAdContainer *clippingContainer;

//orientation support
- (CGRect)containerFrameForInterfaceOrientation:(UIInterfaceOrientation)orientation
                            withPinningLocation:(LARSAdControllerPinLocation)pinningLocation;
- (void)layoutContainerView;

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
        _sharedManager.instancesToCleanUp = [NSMutableSet set];
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
- (void)addAdContainerToViewInViewController:(UIViewController *)viewController{
    [self addAdContainerToView:viewController.view withParentViewController:viewController];
}

- (void)addAdContainerToView:(UIView *)view withParentViewController:(UIViewController *)viewController{
    //remove container from superview
    //  add ad container to new view as subview at bottom
    if (![view.subviews containsObject:_containerView]) {
        self.currentOrientation = viewController.interfaceOrientation;
        self.parentViewController = viewController;
        self.parentView = view;
        
        [self layoutContainerView];
        [view addSubview:self.containerView];
        
        if (self.adapterInstances.count == 0) {
            [self startAdNetworkAdapterClassAtIndex:0];
        }
    }
    else{
        //ad container exists, and bring to front
        [view bringSubviewToFront:self.containerView];
    }
    
    [self registerForDeviceRotationNotifications];
    
    [self layoutBannerViewsForCurrentOrientation:viewController.interfaceOrientation];
}

- (LARSAdContainer *)containerView{
    if (!_containerView) {
        _containerView = [[LARSAdContainer alloc] init];
        _containerView.backgroundColor = [UIColor clearColor];
        _containerView.clipsToBounds = NO;
        
        _containerView.layer.shadowRadius = 10.f;
        _containerView.layer.shadowColor = [UIColor blackColor].CGColor;
        _containerView.layer.shadowOpacity = 0.6f;
        _containerView.layer.shadowOffset = CGSizeMake(0.f, 0.f);
        _containerView.layer.shouldRasterize = YES;
        _containerView.layer.rasterizationScale = [[UIScreen mainScreen] scale];
        
        _clippingContainer = [[LARSAdContainer alloc] initWithFrame:_containerView.bounds];
        self.clippingContainer.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
        self.clippingContainer.backgroundColor = [UIColor clearColor];
        self.clippingContainer.clipsToBounds = YES;
        
        [_containerView addSubview:self.clippingContainer];
    }
    return _containerView;
}

- (CGRect)containerFrameForInterfaceOrientation:(UIInterfaceOrientation)orientation withPinningLocation:(LARSAdControllerPinLocation)pinningLocation{
    //TODO: Modify height so that the container does not contain any whitespace above ad. This will enable others to add a background to the container.
    CGFloat width;
    CGFloat yOrigin = 0.f;
    
    if (UIInterfaceOrientationIsLandscape(orientation)) {
        TOLLog(@"View is landscape");
        
        if (pinningLocation == LARSAdControllerPinLocationBottom) {
            yOrigin = CGRectGetWidth(self.parentView.frame);
        }
        width = CGRectGetHeight(self.parentView.frame);
        self.lastOrientationWasPortrait = NO;
    }
    else{//portrait
        TOLLog(@"View is portrait");
        
        if (pinningLocation == LARSAdControllerPinLocationBottom) {
            yOrigin = CGRectGetHeight(self.parentView.frame);
        }
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
    
    if (pinningLocation == LARSAdControllerPinLocationBottom) {
        yOrigin = yOrigin - height;
    }
    
    CGRect newFrame = CGRectMake(0.f, yOrigin, width, height);
    
    TOLLog(@"Container frame: %@", NSStringFromCGRect(newFrame));
    
    return newFrame;
}

- (void)layoutBannerViewsForCurrentOrientation:(UIInterfaceOrientation)orientation{
    self.currentOrientation = orientation;
    [self layoutContainerView];
    
    id <LARSAdAdapter> adapter = nil;
    
    NSArray *instances = [self.adapterInstances allValues];
    
    for (id <LARSAdAdapter> possibleInstance in instances) {
        if (possibleInstance.adVisible) {
            adapter = possibleInstance;
            break;
        }
    }
    
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        if (CGRectGetWidth(self.containerView.frame) < 1024.f) {
            [adapter layoutBannerForInterfaceOrientation:UIInterfaceOrientationPortrait];
        }
        else {
            [adapter layoutBannerForInterfaceOrientation:UIInterfaceOrientationLandscapeLeft];
        }
    }
    else{
        if (CGRectGetWidth(self.containerView.frame) < 480.f) {
            [adapter layoutBannerForInterfaceOrientation:UIInterfaceOrientationPortrait];
        }
        else{
            [adapter layoutBannerForInterfaceOrientation:UIInterfaceOrientationLandscapeLeft];
        }
    }
    
    adapter.bannerView.frame = [self finalBannerFrameForAdapter:adapter withPinningLocation:self.pinningLocation];
}

- (void)layoutContainerView{
    self.containerView.frame = [self containerFrameForInterfaceOrientation:self.currentOrientation withPinningLocation:self.pinningLocation];
    
    switch (self.pinningLocation) {
        case LARSAdControllerPinLocationBottom:
            self.containerView.autoresizingMask = UIViewAutoresizingFlexibleWidth |
            UIViewAutoresizingFlexibleTopMargin;
            break;
        case LARSAdControllerPinLocationTop:
            self.containerView.autoresizingMask = UIViewAutoresizingFlexibleWidth |
            UIViewAutoresizingFlexibleBottomMargin;
            break;
    }
}

#pragma mark - Ads Visible
- (BOOL)areAnyAdsVisible{
    NSArray *instances = [self.adapterInstances allValues];
    
    for (id <LARSAdAdapter> adapter in instances) {
        if (adapter.adVisible) {
            return YES;
        }
    }
    
    return NO;
}

#pragma mark - Ad Network Management
- (void)registerAdClass:(Class)class withPublisherId:(NSString *)publisherId{
    [self registerAdClass:class];
    [self.adapterClassPublisherIds setObject:publisherId forKey:NSStringFromClass(class)];
}

- (void)registerAdClass:(Class)class{
    
    NSAssert1(class_conformsToProtocol(class, @protocol(LARSAdAdapter)), @"Registered class does not conform to %@ protocol", NSStringFromProtocol(@protocol(LARSAdAdapter)));
    
    [self.registeredClasses addObject:class];
}

#pragma mark - Ad Adapter Delegate
- (void)adFailedForNetworkAdapterClass:(Class)class{
    //get index of adapter class
    NSInteger failedNetworkIndex = [self.registeredClasses indexOfObject:class];
    id <LARSAdAdapter> adapter = [self.adapterInstances objectForKey:NSStringFromClass(class)];
    
    [self animateBannerForAdapterHidden:adapter withCompletion:nil];
    
    if (failedNetworkIndex < self.registeredClasses.count-1) {
        //trigger next ad network in line
        [self startAdNetworkAdapterClassAtIndex:failedNetworkIndex+1];
    }
}

- (void)adSucceededForNetworkAdapterClass:(Class)class{
    //get index of adapter class
    NSInteger succeededNetworkIndex = [self.registeredClasses indexOfObject:class];
    
    //Halt all networks with lower priority than succeeded network
    for (int i = succeededNetworkIndex+1; i < self.registeredClasses.count; i++) {
        [self haltAdNetworkAdapterClass:self.registeredClasses[i]];
    }
    
    id <LARSAdAdapter> adapter = [self.adapterInstances objectForKey:NSStringFromClass(class)];
    
    if (adapter.adVisible == NO) {
        [self animateBannerForAdapterVisible:adapter withCompletion:nil];
    }
}

- (void)adInstanceNowAvailableForDeallocation:(id <LARSAdAdapter>)adapter{
    if ([self.instancesToCleanUp containsObject:adapter]) {
        [self animateBannerForAdapterHidden:adapter withCompletion:^{
            [adapter.bannerView removeFromSuperview];
            [self.adapterInstances removeObjectForKey:NSStringFromClass(adapter.class)];
            [self.instancesToCleanUp removeObject:adapter];
        }];
    }
}

#pragma mark - Banner Frames
- (void)animateBannerForAdapterVisible:(id <LARSAdAdapter>)adapter withCompletion:(void(^)(void))completion{
    
    [adapter layoutBannerForInterfaceOrientation:self.currentOrientation];
    
    if ([self.clippingContainer.subviews containsObject:adapter.bannerView] == NO) {
        //configure initial state for banner view off-screen
        adapter.bannerView.frame = [self initialBannerFrameForAdapter:adapter presentationAnimationType:self.presentationType];
    }
    
    CGRect finalFrame = [self finalBannerFrameForAdapter:adapter withPinningLocation:self.pinningLocation];
    
    [self animateAdapterBannerView:adapter
                           toFrame:finalFrame
                    withCompletion:^(BOOL finished) {
                        adapter.adVisible = YES;
                        
                        BOOL anyAdsVisible = [self areAnyAdsVisible];
                        if (self.isAdVisible != anyAdsVisible) {
                            self.adVisible = anyAdsVisible;
                        }
                        
                        if (completion) {
                            completion();
                        }
                    }];
}

- (void)animateBannerForAdapterHidden:(id <LARSAdAdapter>)adapter withCompletion:(void(^)(void))completion{
    
    CGRect finalFrame = [self initialBannerFrameForAdapter:adapter presentationAnimationType:self.presentationType];
    
    [self animateAdapterBannerView:adapter
                           toFrame:finalFrame
                    withCompletion:^(BOOL finished) {
                        adapter.adVisible = NO;
                        
                        BOOL anyAdsVisible = [self areAnyAdsVisible];
                        if (self.isAdVisible != anyAdsVisible) {
                            self.adVisible = anyAdsVisible;
                        }
                        
                        if (completion) {
                            completion();
                        }
                    }];
}

- (void)animateAdapterBannerView:(id <LARSAdAdapter>)adapter toFrame:(CGRect)newFrame withCompletion:(void(^)(BOOL finished))completion{
    UIViewAnimationOptions options =
    UIViewAnimationOptionAllowAnimatedContent |
    UIViewAnimationOptionBeginFromCurrentState |
    UIViewAnimationOptionCurveEaseInOut;
    
    [UIView animateWithDuration:0.25f
                          delay:0.f
                        options:options
                     animations:^{
                         adapter.bannerView.frame = newFrame;
                     }
                     completion:completion];
}

- (CGRect)initialBannerFrameForAdapter:(id<LARSAdAdapter>)adapter presentationAnimationType:(LARSAdControllerPresentationType)presentationType{
    
    CGRect beginFrame;
    CGSize bannerViewSize = adapter.bannerView.frame.size;
    CGRect finalBannerFrame = [self finalBannerFrameForAdapter:adapter withPinningLocation:self.pinningLocation];
    
    switch (presentationType) {
        case LARSAdControllerPresentationTypeBottom:
            beginFrame.origin = CGPointMake((CGRectGetWidth(self.clippingContainer.frame) - bannerViewSize.width)/2,
                                            CGRectGetHeight(self.clippingContainer.frame));
            break;
        case LARSAdControllerPresentationTypeLeft:
            beginFrame.origin = CGPointMake(-bannerViewSize.width,
                                            finalBannerFrame.origin.y);

            break;
        case LARSAdControllerPresentationTypeRight:
            beginFrame.origin = CGPointMake(CGRectGetWidth(self.clippingContainer.frame),
                                            finalBannerFrame.origin.y);
            break;
        case LARSAdControllerPresentationTypeTop:
            beginFrame.origin = CGPointMake(finalBannerFrame.origin.x,
                                            -bannerViewSize.height);
            break;
    }
    
    beginFrame.size = bannerViewSize;
    
    TOLLog(@"Initial banner frame: %@", NSStringFromCGRect(beginFrame));
    
    return beginFrame;
}

- (CGRect)finalBannerFrameForAdapter:(id<LARSAdAdapter>)adapter withPinningLocation:(LARSAdControllerPinLocation)pinningLocation{

    CGRect finalFrame;
    CGSize bannerViewSize = adapter.bannerView.frame.size;
    
    switch (pinningLocation) {
        case LARSAdControllerPinLocationBottom:
            finalFrame.origin = CGPointMake((CGRectGetWidth(self.clippingContainer.frame) - bannerViewSize.width)/2,
                                            CGRectGetHeight(self.clippingContainer.frame) - bannerViewSize.height);
            break;
        case LARSAdControllerPinLocationTop:
            finalFrame.origin = CGPointMake((CGRectGetWidth(self.clippingContainer.frame) - bannerViewSize.width)/2,
                                            0.f);
            break;
    }
    
    finalFrame.size = bannerViewSize;
    
    TOLLog(@"Final banner frame: %@", NSStringFromCGRect(finalFrame));
    
    return finalFrame;
}

#pragma mark - Starting/Stopping
- (void)startAdNetworkAdapterClassAtIndex:(NSInteger)index{
    if ((index == 0) &&
        (self.registeredClasses.count == 0)) {
        TOLWLog(@"There are no registered ad network adapter classes. Please register an ad network class using %@ before attempting to add ad container view into your view heirarchy.", NSStringFromSelector(@selector(registerAdClass:)));
    }
    else if (index < self.registeredClasses.count) {
        Class currentClass = [self.registeredClasses objectAtIndex:index];
        
        if([self startAdNetworkAdapterClass:currentClass] == NO){
            [self adFailedForNetworkAdapterClass:currentClass];
        }
    }
}

- (BOOL)startAdNetworkAdapterClass:(Class)class{
    id <LARSAdAdapter> adapter = [self.adapterInstances objectForKey:NSStringFromClass(class)];
    
    if (!adapter) {
        TOLLog(@"Creating new instance of adapter class \"%@\"", NSStringFromClass(class));
        
        adapter = [[class alloc] init];
        adapter.adManager = self;
        
        if ([adapter respondsToSelector:@selector(pauseAdRequests)] &&
            ([adapter respondsToSelector:@selector(startAdRequests)] == NO)) {
            NSAssert2(NO, @"You should probably implement %@ in addition to %@ to be consistent. Otherwise, the ad controller has no means to restart the ads requests.", NSStringFromSelector(@selector(startAdRequests)), NSStringFromSelector(@selector(pauseAdRequests)));
        }
        
        Method requiresPublisherId = class_getClassMethod(class, @selector(requiresPublisherId));

//Let clang know I know what I'm doing
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
        if(requiresPublisherId &&
           [[class class] performSelector:method_getName(requiresPublisherId)]){
            NSString *publisherId = [self.adapterClassPublisherIds objectForKey:NSStringFromClass(class)];
            
            if (publisherId) {
                [adapter setPublisherId:publisherId];
            }
            else{
                TOLWLog(@"Ad network adapter %@ requires a publisher ID, but none was specified when instance was initialized! Please set a publisher ID from your ad network vendor and set during adapter registration using %@", NSStringFromClass(class), NSStringFromSelector(@selector(registerAdClass:withPublisherId:)));
                return NO;
            }
        }
        
        Method requiresParentViewControllerClassMethod = nil;
        if ( (requiresParentViewControllerClassMethod = class_getClassMethod(class, @selector(requiresParentViewController))) ) {
            if ([[class class] performSelector:method_getName(requiresParentViewControllerClassMethod)]) {
                TOLLog(@"This class requires a parent view controller!");
                [adapter setParentViewController:self.parentViewController];
            }
        }
#pragma clang diagnostic pop
        
        if([adapter respondsToSelector:@selector(startAdRequests)]){
            [adapter startAdRequests];
        }
        
        TOLLog(@"Successfully created instance of \"%@\"", NSStringFromClass(class));
        
        [self.adapterInstances setObject:adapter forKey:NSStringFromClass(class)];
        
        adapter.bannerView.frame = [self initialBannerFrameForAdapter:adapter presentationAnimationType:self.presentationType];
        adapter.bannerView.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin;
        
        switch (self.pinningLocation) {
            case LARSAdControllerPinLocationBottom:
                adapter.bannerView.autoresizingMask |= UIViewAutoresizingFlexibleTopMargin;
                break;
            case LARSAdControllerPinLocationTop:
                adapter.bannerView.autoresizingMask |= UIViewAutoresizingFlexibleBottomMargin;
                break;
        }
        
        [self.clippingContainer addSubview:adapter.bannerView];
    }
    else if([adapter respondsToSelector:@selector(pauseAdRequests)] &&
            [adapter respondsToSelector:@selector(startAdRequests)]){
        //If adapter implements pauseAdRequests, then we'll need to
        // call startAdRequests here.  If it does not implement it,
        // then we know that we simply deallocated the instance and
        // don't need to call this since it was called above when
        // we created the new instance again.
        [adapter startAdRequests];
    }
    
    if (adapter.adVisible == NO) {
        [self animateBannerForAdapterVisible:adapter withCompletion:nil];
    }
    
    return YES;
}

- (void)haltAdNetworkAdapterClass:(Class)class{
    id <LARSAdAdapter> adapter = [self.adapterInstances objectForKey:NSStringFromClass(class)];
    
    if (adapter.adVisible) {
        [self animateBannerForAdapterHidden:adapter withCompletion:^{
            if ([adapter respondsToSelector:@selector(pauseAdRequests)]) {
                [adapter pauseAdRequests];
            }
            else{
                BOOL destroyed = NO;
                
                if ([adapter respondsToSelector:@selector(canDestroyAdBanner)]) {
                    if ([adapter canDestroyAdBanner]) {
                        [adapter.bannerView removeFromSuperview];
                        [self.adapterInstances removeObjectForKey:NSStringFromClass(class)];
                        
                        destroyed = YES;
                    }
                }
                
                if (destroyed == NO) {
                    [self.instancesToCleanUp addObject:adapter];
                }
            }
        }];
    }
}

#pragma mark - Orientation Handlers
- (void)registerForDeviceRotationNotifications{
    if (!self.isRegisteredForOrientationChanges) {
        TOLLog(@"Registering for orientation notifications");
        
        self.registeredForOrientationChanges = YES;
        
        [[UIDevice currentDevice] beginGeneratingDeviceOrientationNotifications];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleOrientationNotification:) name:UIDeviceOrientationDidChangeNotification object:nil];
    }
}

- (void)unRegisterFromDeviceRotationNotifications{
    if (self.isRegisteredForOrientationChanges == YES) {
        TOLLog(@"Unregistering for orientation notifications");
        
        [[UIDevice currentDevice] endGeneratingDeviceOrientationNotifications];
        [[NSNotificationCenter defaultCenter] removeObserver:self name:UIDeviceOrientationDidChangeNotification object:nil];
        
        self.registeredForOrientationChanges = NO;
    }
}

- (void)handleOrientationNotification:(NSNotification *)orientationNotification{
    TOLLog(@"Handling orientation change");
    
    double delayInSeconds = 0.f;
    
    //interface orientation wasn't always guaranteed without dispatch_after
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC);
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        UIViewAnimationOptions options =
        UIViewAnimationOptionBeginFromCurrentState |
        UIViewAnimationOptionAllowAnimatedContent |
        UIViewAnimationOptionCurveEaseInOut;
        
        [UIView
         animateWithDuration:0.3f
         delay:0.f
         options:options
         animations:^{
             [self layoutBannerViewsForCurrentOrientation:self.parentViewController.interfaceOrientation];
         }
         completion:nil];
    });
}

- (void)setShouldHandleOrientationChanges:(BOOL)shouldHandleOrientationChanges{
    if (shouldHandleOrientationChanges == YES) {
        [self registerForDeviceRotationNotifications];
    }
    else{
        [self unRegisterFromDeviceRotationNotifications];
    }
}

- (void)destroyAllAdBanners{
    NSArray *instances = [self.adapterInstances allValues];
    
    for (id <LARSAdAdapter> adapterInstance in instances) {
        if (adapterInstance.adVisible) {
            [self animateBannerForAdapterHidden:adapterInstance withCompletion:^{
                [adapterInstance.bannerView removeFromSuperview];
            }];
        }
    }
    
    [self.adapterInstances removeAllObjects];
}


@end
