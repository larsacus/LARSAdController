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
#import "TOLAdAdapter.h"

NSString * const kLARSAdObserverKeyPathAdLoaded = @"adLoaded";
NSString * const kLARSAdObserverKeyPathIsAdVisible = @"adVisible";

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

@interface LARSAdController() <LARSAdControllerDelegate>

@property (nonatomic) BOOL lastOrientationWasPortrait;
@property (nonatomic) UIInterfaceOrientation currentOrientation;
@property (nonatomic, strong, readwrite) LARSAdContainer *containerView;
@property (nonatomic, weak, readwrite) UIView *parentView;
@property (nonatomic, weak, readwrite) UIViewController *parentViewController;
@property (nonatomic,
           getter = isRegisteredForOrientationChanges) BOOL registeredForOrientationChanges;
@property (nonatomic, strong) NSMutableSet *instancesToCleanUp;
@property (nonatomic, readwrite) BOOL adVisible;
@property (nonatomic) BOOL isSuspended;

/* Contains the ads so they will clip since the outer container does not clip subviews to retain shadows
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

@interface LARSAdController ()

@property (strong, nonatomic, readwrite) NSMutableArray *registeredClasses;
@property (strong, nonatomic, readwrite) NSMutableDictionary *adapterClassPublisherIds;
@property (strong, nonatomic, readwrite) NSMutableDictionary *adapterInstances;

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
        _sharedManager.isSuspended = false;
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
    self.parentViewController = viewController;
    self.parentView = view;
    
    if (![view.subviews containsObject:_containerView]) {
        self.currentOrientation = viewController.interfaceOrientation;
        
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
    //TODO: Modify height so that the container does not contain any whitespace above ad. This will enable others to add a background to the container (a la weather channel app).
    CGFloat width;
    CGFloat yOrigin = 0.f;
    
    CGFloat parentWidth = CGRectGetWidth(self.parentView.frame);
    CGFloat parentHeight = CGRectGetHeight(self.parentView.frame);
    
    if (UIInterfaceOrientationIsLandscape(orientation)) {
        TOLLog(@"View is landscape");
        
        if (pinningLocation == LARSAdControllerPinLocationBottom) {
            yOrigin = MIN(parentHeight, parentWidth);
        }
        width = MAX(parentHeight, parentWidth);
        self.lastOrientationWasPortrait = NO;
    }
    else{//portrait
        TOLLog(@"View is portrait");
        
        if (pinningLocation == LARSAdControllerPinLocationBottom) {
            yOrigin = MAX(parentHeight, parentWidth);
        }
        width = MIN(parentHeight, parentWidth);
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
    
    id <TOLAdAdapter> adapter = nil;
    
    NSArray *instances = [self.adapterInstances allValues];
    
    for (id <TOLAdAdapter> possibleInstance in instances) {
        if (possibleInstance.adVisible) {
            adapter = possibleInstance;
            break;
        }
    }
    
    if (!adapter) {
        return;
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
    
    adapter.bannerView.frame = [self onScreenBannerFrameForAdapter:adapter withPinningLocation:self.pinningLocation];
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

- (void)setParentViewController:(UIViewController *)parentViewController{
    _parentViewController = parentViewController;
    
    for (id<TOLAdAdapter> adAdapter in self.adapterInstances) {
        if ([adAdapter respondsToSelector:@selector(setParentViewController:)]) {
            [adAdapter setParentViewController:parentViewController];
        }
    }
}

#pragma mark - Ads Visible
- (BOOL)areAnyAdsVisible{
    NSArray *instances = [self.adapterInstances allValues];
    
    for (id <TOLAdAdapter> adapter in instances) {
        if (adapter.adVisible) {
            return YES;
        }
    }
    
    return NO;
}

#pragma mark - Ad Network Management
- (void)registerAdClass:(Class)klass withPublisherId:(NSString *)publisherId{
    
    if ([self.registeredClasses containsObject:klass]) {
        //If you need this functionality, open an issue on GitHub
        TOLWLog(@"Registered adapter classes already contains \"%@\" class. Registering the same adapter with multiple publisher IDs is currently unsupported.", NSStringFromClass(klass));
    }
    
    [self registerAdClass:klass];
    [self.adapterClassPublisherIds setObject:publisherId forKey:NSStringFromClass(klass)];
}

- (void)registerAdClass:(Class)class{
    
    NSAssert1(class_conformsToProtocol(class, @protocol(TOLAdAdapter)), @"Registered class does not conform to %@ protocol", NSStringFromProtocol(@protocol(TOLAdAdapter)));
    
    [self.registeredClasses addObject:class];
}

#pragma mark - Ad Adapter Delegate
- (void)adFailedForNetworkAdapterClass:(Class)klass{
    //get index of adapter class
    NSInteger failedNetworkIndex = [self.registeredClasses indexOfObject:klass];
    id <TOLAdAdapter> adapter = [self.adapterInstances objectForKey:NSStringFromClass(klass)];
    
    [self animateBannerForAdapterHidden:adapter withCompletion:nil];
    
    if (failedNetworkIndex < self.registeredClasses.count-1) {
        //trigger next ad network in line
        [self startAdNetworkAdapterClassAtIndex:failedNetworkIndex+1];
    }
}

- (void)adSucceededForNetworkAdapterClass:(Class)klass{
    //get index of adapter class
    NSInteger succeededNetworkIndex = [self.registeredClasses indexOfObject:klass];
    
    //Halt all networks with lower priority than succeeded network
    for (int i = succeededNetworkIndex+1; i < self.registeredClasses.count; i++) {
        [self haltAdNetworkAdapterClass:self.registeredClasses[i]];
    }
    
    id <TOLAdAdapter> adapter = [self.adapterInstances objectForKey:NSStringFromClass(klass)];
    
    if (adapter.adVisible == NO && !self.isSuspended) {
        [self animateBannerForAdapterVisible:adapter withCompletion:nil];
    }
}

- (void)adInstanceNowAvailableForDeallocation:(id <TOLAdAdapter>)adapter{
    if ([self.instancesToCleanUp containsObject:adapter]) {
        [self animateBannerForAdapterHidden:adapter withCompletion:^{
            [self cleanUpAdAdapter:adapter];
        }];
    }
}

#pragma mark - Cleanup
- (void)cleanUpAdAdapter:(NSObject<TOLAdAdapter> *)adapter{
    [adapter removeObserver:self forKeyPath:kLARSAdObserverKeyPathIsAdVisible];
    
    if ([adapter respondsToSelector:@selector(adLoaded)]) {
        [adapter removeObserver:self forKeyPath:kLARSAdObserverKeyPathAdLoaded];
    }
    
    [adapter.bannerView removeFromSuperview];
    [self.adapterInstances removeObjectForKey:NSStringFromClass(adapter.class)];
    
    if ([self.instancesToCleanUp containsObject:adapter]) {
        [self.instancesToCleanUp removeObject:adapter];
    }
}

#pragma mark - Banner Frames
- (void)animateBannerForAdapterVisible:(id <TOLAdAdapter>)adapter withCompletion:(void(^)(void))completion{
    
    [adapter layoutBannerForInterfaceOrientation:self.currentOrientation];
    
    if ([self.clippingContainer.subviews containsObject:adapter.bannerView] == NO) {
        //configure initial state for banner view off-screen
        adapter.bannerView.frame = [self offScreenBannerFrameForAdapter:adapter
                                              presentationAnimationType:self.presentationType];
    }
    
    CGRect finalFrame = [self onScreenBannerFrameForAdapter:adapter
                                        withPinningLocation:self.pinningLocation];
    
    adapter.adVisible = YES;
    
    [self animateAdapterBannerView:adapter
                           toFrame:finalFrame
                    withCompletion:^(BOOL finished) {
                        if (finished) {
                            BOOL anyAdsVisible = [self areAnyAdsVisible];
                            if (self.isAdVisible != anyAdsVisible) {
                                self.adVisible = anyAdsVisible;
                            }
                            
                            if (completion) {
                                completion();
                            }
                        }
                    }];
}

- (void)animateBannerForAdapterHidden:(id <TOLAdAdapter>)adapter withCompletion:(void(^)(void))completion{
    
    CGRect finalFrame = [self offScreenBannerFrameForAdapter:adapter
                                   presentationAnimationType:self.presentationType];
    
    adapter.adVisible = NO;
    
    [self animateAdapterBannerView:adapter
                           toFrame:finalFrame
                    withCompletion:^(BOOL finished) {
                        if (finished) {
                            BOOL anyAdsVisible = [self areAnyAdsVisible];
                            if (self.isAdVisible != anyAdsVisible) {
                                self.adVisible = anyAdsVisible;
                            }
                            
                            if (completion) {
                                completion();
                            }
                        }
                    }];
}

- (void)animateAdapterBannerView:(id <TOLAdAdapter>)adapter toFrame:(CGRect)newFrame withCompletion:(void(^)(BOOL finished))completion{
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

- (CGRect)offScreenBannerFrameForAdapter:(id<TOLAdAdapter>)adapter presentationAnimationType:(LARSAdControllerPresentationType)presentationType{
    
    CGRect beginFrame;
    CGSize bannerViewSize = adapter.bannerView.frame.size;
    
    switch (presentationType) {
        case LARSAdControllerPresentationTypeBottom:
            beginFrame.origin = CGPointMake((CGRectGetWidth(self.clippingContainer.frame) - bannerViewSize.width)/2,
                                            CGRectGetHeight(self.clippingContainer.frame));
            break;
        case LARSAdControllerPresentationTypeLeft:{
            CGRect finalBannerFrame = [self onScreenBannerFrameForAdapter:adapter
                                                      withPinningLocation:self.pinningLocation];
            beginFrame.origin = CGPointMake(-bannerViewSize.width,
                                            finalBannerFrame.origin.y);
        }
            break;
        case LARSAdControllerPresentationTypeRight:{
            CGRect finalBannerFrame = [self onScreenBannerFrameForAdapter:adapter
                                                      withPinningLocation:self.pinningLocation];
            
            beginFrame.origin = CGPointMake(CGRectGetWidth(self.clippingContainer.frame),
                                            finalBannerFrame.origin.y);
        }
            break;
case LARSAdControllerPresentationTypeTop:{
    CGRect finalBannerFrame = [self onScreenBannerFrameForAdapter:adapter
                                              withPinningLocation:self.pinningLocation];

            beginFrame.origin = CGPointMake(finalBannerFrame.origin.x,
                                            -bannerViewSize.height);
}
            break;
    }
    
    beginFrame.size = bannerViewSize;
    
    NSString * __unused adapterName = [self friendlyNameForAdAdapter:adapter];
    
    TOLLog(@"Initial banner frame <%@>: %@", adapterName, NSStringFromCGRect(beginFrame));
    
    return beginFrame;
}

- (CGRect)onScreenBannerFrameForAdapter:(id<TOLAdAdapter>)adapter withPinningLocation:(LARSAdControllerPinLocation)pinningLocation{

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
    
    NSString * __unused adapterName = [self friendlyNameForAdAdapter:adapter];
    
    TOLLog(@"Final banner frame <%@>: %@", adapterName, NSStringFromCGRect(finalFrame));
    
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

- (BOOL)startAdNetworkAdapterClass:(Class)klass{
    NSObject <TOLAdAdapter> *adapter = [self.adapterInstances objectForKey:NSStringFromClass(klass)];
    
    if (!adapter) {
        TOLLog(@"Creating new instance of adapter class \"%@\"", NSStringFromClass(klass));
        
        adapter = [[klass alloc] init];
        adapter.adManager = self;
        
        if ([adapter respondsToSelector:@selector(pauseAdRequests)] &&
            ([adapter respondsToSelector:@selector(startAdRequests)] == NO)) {
            NSAssert2(NO, @"You should probably implement %@ in addition to %@ to be consistent. Otherwise, the ad controller has no means to restart the ads requests.", NSStringFromSelector(@selector(startAdRequests)), NSStringFromSelector(@selector(pauseAdRequests)));
        }
        
        Method requiresPublisherId = class_getClassMethod(klass, @selector(requiresPublisherId));

//Let clang know I know what I'm doing
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
        if(requiresPublisherId &&
           [[klass class] performSelector:method_getName(requiresPublisherId)]){
            NSString *publisherId = [self.adapterClassPublisherIds objectForKey:NSStringFromClass(klass)];
            
            if (publisherId) {
                [adapter setPublisherId:publisherId];
            }
            else{
                TOLWLog(@"Ad network adapter %@ requires a publisher ID, but none was specified when instance was initialized! Please set a publisher ID from your ad network vendor and set during adapter registration using %@", NSStringFromClass(klass), NSStringFromSelector(@selector(registerAdClass:withPublisherId:)));
                return NO;
            }
        }
        
        Method requiresParentViewControllerClassMethod = nil;
        if ( (requiresParentViewControllerClassMethod = class_getClassMethod(klass, @selector(requiresParentViewController))) ) {
            if ([[klass class] performSelector:method_getName(requiresParentViewControllerClassMethod)]) {
                [adapter setParentViewController:self.parentViewController];
            }
        }
#pragma clang diagnostic pop
        
        if([adapter respondsToSelector:@selector(startAdRequests)]){
            [adapter startAdRequests];
        }
        
        TOLLog(@"Successfully created instance of \"%@\"", NSStringFromClass(klass));
        
        [self.adapterInstances setObject:adapter forKey:NSStringFromClass(klass)];
        
        if (adapter.adVisible) {
            adapter.bannerView.frame = [self onScreenBannerFrameForAdapter:adapter withPinningLocation:self.pinningLocation];
        }
        else{
            adapter.bannerView.frame = [self offScreenBannerFrameForAdapter:adapter presentationAnimationType:self.presentationType];
        }
        adapter.bannerView.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin;
        
        switch (self.pinningLocation) {
            case LARSAdControllerPinLocationBottom:
                adapter.bannerView.autoresizingMask |= UIViewAutoresizingFlexibleTopMargin;
                break;
            case LARSAdControllerPinLocationTop:
                adapter.bannerView.autoresizingMask |= UIViewAutoresizingFlexibleBottomMargin;
                break;
        }
        
        [adapter addObserver:self
                  forKeyPath:kLARSAdObserverKeyPathIsAdVisible
                     options:NSKeyValueObservingOptionNew
                     context:nil];
      
        [self.clippingContainer addSubview:adapter.bannerView];
      
        if ([adapter respondsToSelector:@selector(adLoaded)]) {
          [adapter addObserver:self
                    forKeyPath:kLARSAdObserverKeyPathAdLoaded
                       options:NSKeyValueObservingOptionNew
                       context:nil];
        }
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
    
    //Since we just allocated an instance of this class, the ad banner might
    //  not actually have an ad loaded to display. check if ad
    //  is loaded before actually displaying it if the ad adapter
    //  supports it. makes for a much cleaner visual experience
    if ([adapter respondsToSelector:@selector(adLoaded)]) {
        if (adapter.adLoaded && !self.isSuspended) {
            [self animateBannerForAdapterVisible:adapter
                                  withCompletion:nil];
        }
    }
    else if (adapter.adVisible == NO && !self.isSuspended) {
        [self animateBannerForAdapterVisible:adapter
                              withCompletion:nil];
    }
    
    return YES;
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context{
    if ([keyPath isEqualToString:kLARSAdObserverKeyPathAdLoaded]) {
        
        BOOL newAdLoadedValue = [[change objectForKey:NSKeyValueChangeNewKey] boolValue];
        NSString * __unused friendlyNetworkDescription = [self friendlyNameForAdAdapter:object];
        
        if (newAdLoadedValue) {
            TOLLog(@"Ad loaded for %@!", friendlyNetworkDescription);
            if ([object adVisible] == NO) {
                [self animateBannerForAdapterVisible:object withCompletion:nil];
            }
        }
        else{
            TOLLog(@"Ad not loaded for %@!", friendlyNetworkDescription);
            if ([object adVisible]) {
                [self animateBannerForAdapterHidden:object withCompletion:nil];
            }
        }
    }
    else if([keyPath isEqualToString:kLARSAdObserverKeyPathIsAdVisible]){
        self.adVisible = [self areAnyAdsVisible];
    }
}

- (void)haltAdNetworkAdapterClass:(Class)klass{
    
    
    id <TOLAdAdapter> adapter = [self.adapterInstances objectForKey:NSStringFromClass(klass)];
    
    if (adapter == nil) {
        return;
    }
    
    NSString * __unused friendlyNetworkDescription = [self friendlyNameForAdAdapter:adapter];
    
    TOLLog(@"Attempting to halt %@ ad network", friendlyNetworkDescription);
    
    if (adapter.adVisible) {
        TOLLog(@"Hiding %@ ad network", friendlyNetworkDescription);
        
        [self animateBannerForAdapterHidden:adapter withCompletion:^{
            if ([adapter respondsToSelector:@selector(pauseAdRequests)]) {
                [adapter pauseAdRequests];
            }
            else{
                BOOL destroyed = NO;
                
                if ([adapter respondsToSelector:@selector(canDestroyAdBanner)]) {
                    if ([adapter canDestroyAdBanner]) {
                        TOLLog(@"Destroying %@ ad network instance", friendlyNetworkDescription);
                        [self cleanUpAdAdapter:adapter];
                        
                        destroyed = YES;
                    }
                }
                else{
                    //assume yes
                    TOLLog(@"Destroying %@ ad network instance", friendlyNetworkDescription);
                    [self cleanUpAdAdapter:adapter];
                    
                    destroyed = YES;
                }
                
                if (destroyed == NO) {
                    [self.instancesToCleanUp addObject:adapter];
                }
            }
        }];
    }
    else if(adapter != nil){
        TOLLog(@"%@ ad network allocated, but not visible (no ad loaded)", friendlyNetworkDescription);
    }
    else if(adapter == nil){
        TOLLog(@"%@ ad network not yet allocated, no need to destroy...", friendlyNetworkDescription);
    }
}

#pragma mark - Orientation Handlers
- (void)registerForDeviceRotationNotifications{
    if (!self.isRegisteredForOrientationChanges) {
        TOLLog(@"Registering for orientation notifications");
        
        self.registeredForOrientationChanges = YES;
        
        [[UIDevice currentDevice] beginGeneratingDeviceOrientationNotifications];
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(handleOrientationNotification:)
                                                     name:UIDeviceOrientationDidChangeNotification
                                                   object:nil];
    }
}

- (void)unRegisterFromDeviceRotationNotifications{
    if (self.isRegisteredForOrientationChanges == YES) {
        TOLLog(@"Unregistering for orientation notifications");
        
        [[UIDevice currentDevice] endGeneratingDeviceOrientationNotifications];
        [[NSNotificationCenter defaultCenter] removeObserver:self
                                                        name:UIDeviceOrientationDidChangeNotification
                                                      object:nil];
        
        self.registeredForOrientationChanges = NO;
    }
}

- (void)handleOrientationNotification:(NSNotification *)orientationNotification{
    TOLLog(@"Handling orientation change");
    
    double delayInSeconds = 0.001f;
    
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
    
    for (id <TOLAdAdapter> adapterInstance in instances) {
        if (adapterInstance.adVisible) {
            [self animateBannerForAdapterHidden:adapterInstance withCompletion:^{
                [self cleanUpAdAdapter:adapterInstance];
            }];
        }
        else{
            [self cleanUpAdAdapter:adapterInstance];
        }
    }
}

- (void)suspend {
    self.isSuspended = true;
    NSArray *instances = [self.adapterInstances allValues];
    
    for (id <TOLAdAdapter> adapterInstance in instances) {
        if (adapterInstance.adVisible) {
            [self animateBannerForAdapterHidden:adapterInstance withCompletion:nil];
        }
    }
}

- (void)resume {
    self.isSuspended = false;
    NSArray *instances = [self.adapterInstances allValues];
    
    for (id <TOLAdAdapter> adapterInstance in instances) {
        if (!adapterInstance.adVisible) {
            [self animateBannerForAdapterVisible:adapterInstance withCompletion:nil];
        }
    }
}

#pragma mark - Misc Helpers
- (NSString *)friendlyNameForAdAdapter:(NSObject <TOLAdAdapter>*)adapter{
    if ([adapter respondsToSelector:@selector(friendlyNetworkDescription)]) {
        NSString *friendlyDescription = [adapter friendlyNetworkDescription];
        if (friendlyDescription != nil) {
            return friendlyDescription;
        }
    }
    
    return NSStringFromClass(adapter.class);
}


@end
