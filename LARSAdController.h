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
#import <iAd/iAd.h>

#import "GADBannerViewDelegate.h"


//Debug logging
#ifdef LARSADCONTROLLER_DEBUG
#define TOLLog(fmt, ...) NSLog((@"%@: " fmt), NSStringFromClass(self.class), ##__VA_ARGS__)
#else
#define TOLLog(...) /* */
#endif

#define TOLWLog(fmt, ...) NSLog((@"%@ WARNING: " fmt), NSStringFromClass(self.class), ##__VA_ARGS__)

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

@class GADBannerView;
@class ADBannerView;
@protocol LARSAdAdapter;

@interface LARSAdContainer : UIView

@end

@protocol LARSAdControllerDelegate <NSObject>

@required
- (void)adFailedForNetworkAdapterClass:(Class)class;
- (void)adSucceededForNetworkAdapterClass:(Class)class;
- (void)adInstanceNowAvailableForDeallocation:(id <LARSAdAdapter>)adInstance;

@end

@interface LARSAdController : NSObject <GADBannerViewDelegate, ADBannerViewDelegate, LARSAdControllerDelegate>

- (void)registerAdClass:(Class)class withPublisherId:(NSString *)publisherId;
- (void)registerAdClass:(Class)class;

@property (strong, nonatomic) NSMutableArray *registeredClasses;
@property (strong, nonatomic) NSMutableDictionary *adapterClassPublisherIds;
@property (strong, nonatomic) NSMutableDictionary *adapterInstances;
@property (nonatomic) LARSAdControllerPresentationType presentationType;
@property (nonatomic) LARSAdControllerPinLocation pinningLocation;


/** The parent view that the shared instance is currently hosted in. */
@property (nonatomic, readonly, weak) UIView *parentView;

/** The parent view controller that the shared instance is currently hosted in. Typically, this is the same view controller that is managing parentView. */
@property (nonatomic, readonly, weak) UIViewController *parentViewController;

/** A boolean flag that indicates if _any_ ads are currently being displayed. */
@property (nonatomic,
           getter = isAdVisible, readonly) BOOL adVisible;

/** The container view that the ads are contained in. Exposed so you can do anything you would want with it. */
@property (nonatomic, strong, readonly) LARSAdContainer *containerView;

/** Class method that gives access to the shared instance. */
+ (LARSAdController *)sharedManager;

/** The primary method of adding your ads to a view and view controller. For some, this will be the only method that is ever called besides setting googleAdPublisherId. Call this method in every view controller's viewWillAppear method in order to add the shared ad instance to your view heirarchy.
 
 This method will call addAdContainerToView:withParentViewController: with viewController.view as the view parameter.
 
 @param viewController The view controller that will be managing the ad.
 */
- (void)addAdContainerToViewInViewController:(UIViewController *)viewController;

/** The primary method of adding your ads to a view and view controller. For some, this will be the only method that is ever called besides setting googleAdPublisherId. Call this method in every view controller's viewWillAppear method in order to add the shared ad instance to your view heirarchy.
 
 @param view The view you would like the ad container added to.
 @param viewController The view controller that will be managing the ad.
 */
- (void)addAdContainerToView:(UIView *)view withParentViewController:(UIViewController *)viewController;

/** Destroys all ad banners that are currently requesting ads from their ad network.
 
 Call this when a user has purchased an in-app purchase to remove ads.  This will go through each ad network class you have registered, remove it from the view heirarchy, then clean it up appropriately.
 
 @warning Some ads may not clean up if there is a full-screen ad being interacted with.
 */
- (void)destroyAllAdBanners;
@end
