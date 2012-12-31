//
//  LARSAdController.h
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

#import <Foundation/Foundation.h>

//Debug logging
#ifdef LARSADCONTROLLER_DEBUG
#define TOLLog(fmt, ...) NSLog((@"%@ [line %u]: " fmt), NSStringFromClass(self.class), __LINE__, ##__VA_ARGS__)
#else
#define TOLLog(...) /* */
#endif

#define TOLWLog(fmt, ...) NSLog((@"%@ WARNING [line %u]: " fmt), NSStringFromClass(self.class), __LINE__, ##__VA_ARGS__)

typedef NS_ENUM(NSInteger, LARSAdControllerPresentationType){
    LARSAdControllerPresentationTypeBottom = 0,
    LARSAdControllerPresentationTypeTop,
    LARSAdControllerPresentationTypeLeft,
    LARSAdControllerPresentationTypeRight
};

typedef NS_ENUM(NSInteger, LARSAdControllerPinLocation){
    LARSAdControllerPinLocationBottom =  0,
    LARSAdControllerPinLocationTop
};

@protocol TOLAdAdapter;

@interface LARSAdContainer : UIView

@end

@protocol LARSAdControllerDelegate <NSObject>

@required
- (void)adFailedForNetworkAdapterClass:(Class)class;
- (void)adSucceededForNetworkAdapterClass:(Class)class;
- (void)adInstanceNowAvailableForDeallocation:(id <TOLAdAdapter>)adInstance;

@end

@interface LARSAdController : NSObject

/** A secondary method to register an ad adapter class for network requests that accepts or requires a publisher ID.
 
 @discussion Ad network priority is assigned based on the order in which each ad network was added using this method or registerAdClass:.
 
 @param class An ad network adapter class that will be used to present an ad banner for a particular ad network
 @param publisherId A string that identifies you as a publisher to your ad network provider to server you ad inventory
 */
- (void)registerAdClass:(Class)class withPublisherId:(NSString *)publisherId;

/** The primary method to register an ad adapter class for network requests.
 
 @discussion Ad network priority is assigned based on the order in which each ad network was added using this method or registerAdClass:withPublisherId:.
 
 @param class An ad network adapter class that will be used to present an ad banner for a particular ad network
 */
- (void)registerAdClass:(Class)class;

/** The registered ad adapters that will be executed in order to request ads.
 */
@property (strong, nonatomic, readonly) NSMutableArray *registeredClasses;

/** The publisher IDs for each adapter class that requires a publisher id.
 */
@property (strong, nonatomic, readonly) NSMutableDictionary *adapterClassPublisherIds;

/** The instances for each ad adapter that are currently instantiated. Not all registered ad adapters will be instantiated at any given time. Only the active ad adapters currently waiting on ad network requests will be included in this dictionary.
 */
@property (strong, nonatomic, readonly) NSMutableDictionary *adapterInstances;

/** The presentation type for the ad banner to use when it presents and hides itself. You can think of this as the location that ad banner will be at before it animates on screen.
 */
@property (nonatomic) LARSAdControllerPresentationType presentationType;

/** The location that the ad banner container will pin itself to.
 */
@property (nonatomic) LARSAdControllerPinLocation pinningLocation;


/** The parent view that the shared instance is currently hosted in.
 */
@property (nonatomic, readonly, weak) UIView *parentView;

/** The parent view controller that the shared instance is currently hosted in. Typically, this is the same view controller that is managing parentView.
 */
@property (nonatomic, readonly, weak) UIViewController *parentViewController;

/** A boolean flag that indicates if _any_ ads are currently being displayed.
 */
@property (nonatomic,
           getter = isAdVisible, readonly) BOOL adVisible;

/** The container view that the ads are contained in. Exposed so you can do anything you would want with it.
 */
@property (nonatomic, readonly, strong) LARSAdContainer *containerView;

/** Class method that gives access to the shared instance.
 */
+ (LARSAdController *)sharedManager;

/** The simplified primary method of adding your ads to a view and view controller. For most, this will be the only method that is ever called besides registering your ad networks. Call this method in every view controller's viewWillAppear: method in order to add the shared ad instance to your view heirarchy.
 
 @discussion This method will call addAdContainerToView:withParentViewController: with viewController.view as the view parameter.
 
 @param viewController The view controller that will be managing the ad.
 */
- (void)addAdContainerToViewInViewController:(UIViewController *)viewController;

/** The primary method of adding your ads to a view and view controller. For most, this will be the only method that is ever called besides registering your ad networks. Call this method in every view controller's viewWillAppear method in order to add the shared ad instance to your view heirarchy.
 
 @param view The view you would like the ad container added to.
 @param viewController The view controller that will be managing the ad.
 */
- (void)addAdContainerToView:(UIView *)view withParentViewController:(UIViewController *)viewController;

/** Destroys all ad banners that are currently requesting ads from their ad network.
 
 @discussion Call this when a user has purchased an in-app purchase to remove ads.  This will go through each ad network class you have registered, remove it from the view heirarchy, then clean it up appropriately. As long as you don't call addAdContainerToView:withParentViewController: or addAdContainerToViewInViewController: again, no ads will be served.
 
 @warning Some ads may not clean up if there is a full-screen ad being interacted with.
 */
- (void)destroyAllAdBanners;
@end
