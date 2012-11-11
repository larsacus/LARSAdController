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
        
        if (self.adapterInstances.count == 0) {
            [self startAdNetworkAdapterClassAtIndex:0];
        }
        
        [self fixAdContainerFrame];
        [view addSubview:self.containerView];
    }
    else{
        //ad container exists, and bring to front
        [view bringSubviewToFront:self.containerView];
    }
    
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
        TOLLog(@"View is landscape");
        
        yOrigin = CGRectGetWidth(self.parentView.frame);
        width = CGRectGetHeight(self.parentView.frame);
        self.lastOrientationWasPortrait = NO;
    }
    else{//portrait
        TOLLog(@"View is portrait");
        
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

- (void)layoutBannerViewsForCurrentOrientation:(UIInterfaceOrientation)orientation{
    self.currentOrientation = orientation;
    [self fixAdContainerFrame];
    
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
    
    //TODO: Build layouts for container
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        if (CGRectGetWidth(self.containerView.frame) < 1024.f) {

        }
        else {

        }
    }
    else{
        if (CGRectGetWidth(self.containerView.frame) < 480.f) {

        }
        else{

        }
    }
    
#pragma clang diagnostic pop
}

- (void)fixAdContainerFrame{
    self.containerView.frame = [self containerFrameForInterfaceOrientation:self.currentOrientation];
}

#pragma mark - Ad Network Management
- (void)registerAdClass:(Class)class withPublisherId:(NSString *)publisherId{
    [self.registeredClasses addObject:class];
    [self.adapterClassPublisherIds setObject:publisherId forKey:NSStringFromClass(class)];
}

- (void)registerAdClass:(Class)class{
    [self.registeredClasses addObject:class];
}

#pragma mark - Ad Adapter Delegate
- (void)adFailedForNetworkAdapterClass:(Class)class{
    //get index of adapter class
    NSInteger failedNetworkIndex = [self.registeredClasses indexOfObject:class];
    
    [self haltAdNetworkAdapterClass:class];
    
    if (failedNetworkIndex < self.registeredClasses.count-1) {
        //trigger next ad network in line
        [self startAdNetworkAdapterClassAtIndex:failedNetworkIndex+1];
    }
}

- (void)adSucceededForNetworkAdapterClass:(Class)class{
    //get index of adapter class
    NSInteger succeededNetworkIndex = [self.registeredClasses indexOfObject:class];
    
    //Halt all networks with lower priority than succeeded network
    for (int i = succeededNetworkIndex; i < self.registeredClasses.count; i++) {
        [self haltAdNetworkAdapterClass:self.registeredClasses[i]];
    }
    
    id <LARSAdAdapter> adapter = [self.adapterInstances objectForKey:NSStringFromClass(class)];
    
    if (adapter.adVisible == NO) {
        [self animateBannerForAdapterVisible:adapter withCompletion:nil];
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
    
    [UIView animateWithDuration:0.25f
                          delay:0.f
                        options:UIViewAnimationOptionAllowAnimatedContent | UIViewAnimationOptionBeginFromCurrentState
                     animations:^{
                         adapter.bannerView.frame = finalFrame;
                     }
                     completion:^(BOOL finished) {
                         adapter.adVisible = YES;
                         self.clippingContainer.userInteractionEnabled = YES;
                         
                         if (completion) {
                             completion();
                         }
                     }];
}

- (void)animateBannerForAdapterHidden:(id <LARSAdAdapter>)adapter withCompletion:(void(^)(void))completion{
//    [adapter layoutBannerForInterfaceOrientation:self.currentOrientation];x
    
    CGRect finalFrame = [self initialBannerFrameForAdapter:adapter presentationAnimationType:self.presentationType];
    
    [UIView animateWithDuration:0.25f
                          delay:0.f
                        options:UIViewAnimationOptionAllowAnimatedContent | UIViewAnimationOptionBeginFromCurrentState
                     animations:^{
                         adapter.bannerView.frame = finalFrame;
                     }
                     completion:^(BOOL finished) {
                         adapter.adVisible = NO;
                         
                         if (completion) {
                             completion();
                         }
                     }];
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
        
        NSString *publisherId = [self.adapterClassPublisherIds objectForKey:NSStringFromClass(class)];
        if (publisherId) {
            [adapter setPublisherId:publisherId];
        }
        else if([adapter respondsToSelector:@selector(requiresPublisherId)]){
            if ([adapter requiresPublisherId]) {
                TOLWLog(@"Ad network adapter %@ requires a publisher ID, but none was specified when instance was initialized! Please set a publisher ID from your ad network vendor and set during adapter registration using %@", NSStringFromClass(class), NSStringFromSelector(@selector(registerAdClass:withPublisherId:)));
                return NO;
            }
        }
        
        TOLLog(@"Successfully created \"%@\" instance", NSStringFromClass(class));
        
        [self.adapterInstances setObject:adapter forKey:NSStringFromClass(class)];
        
        adapter.bannerView.frame = [self initialBannerFrameForAdapter:adapter presentationAnimationType:self.presentationType];
        
        [self.clippingContainer addSubview:adapter.bannerView];
    }
    
    if (adapter.adVisible = NO) {
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
                    //TODO: add adapter class to list of banners to wait on and destroy when available (like when banner view action completes)
                }
            }
        }];
    }
}

#pragma mark - Orientation Handlers
//TODO: add iOS 6 rotation support
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
    
    double delayInSeconds = 0.01f;
    
    //interface orientation wasn't always guaranteed without dispatch_after
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC);
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        [self layoutBannerViewsForCurrentOrientation:self.parentViewController.interfaceOrientation];
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
    //TODO: implement destroyAllAdBanners
}

@end
