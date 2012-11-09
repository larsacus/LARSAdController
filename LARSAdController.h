//
//  LARSAdController.h
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

#import <Foundation/Foundation.h>
#import <iAd/iAd.h>

#import "GADBannerViewDelegate.h"

@class GADBannerView;
@class ADBannerView;

@protocol LARSAdControllerDelegate <NSObject>

@required
- (void)adFailedForNetworkAdapterClass:(Class)class;
- (void)adSucceededForNetworkAdapterClass:(Class)class;

@end

@interface LARSAdController : NSObject <GADBannerViewDelegate, ADBannerViewDelegate, LARSAdControllerDelegate>

@property (strong, nonatomic) NSMutableArray *registeredClasses;
@property (strong, nonatomic) NSMutableDictionary *adapterClassPublisherIds;
@property (strong, nonatomic) NSMutableDictionary *adapterInstances;


/** The parent view that the shared instance is currently hosted in. */
@property (nonatomic, retain) UIView *parentView;

/** The parent view controller that the shared instance is currently hosted in. Typically, this is the same view controller that is managing parentView. */
@property (nonatomic, retain) UIViewController *parentViewController;

/** A boolean flag that indicates if _any_ ads are currently being displayed. */
@property (atomic,
           getter = areAnyAdsVisible) BOOL anyAdsVisible;

/** A boolean flag that indicates if the shared instance should be automatically listening for and handling rotation changes.
 
 Rotation changes will be listened for, but will only rotate if the view controller that the ads are being hosted in support the given orientation. For example, if your view controller only supports the portrait orientation, but the user changes to landscape, the ad controller will fire the code to ask your view controller if it should support the new device orientation. If your view controller returns YES, then the ad controller will layout the ad banner for that orientation.
 */
@property (nonatomic,
           getter = isHandlingOrientationChanges) BOOL shouldHandleOrientationChanges;

/** The container view that the ads are contained in. Exposed so you can do anything you would want with it. */
@property (nonatomic, retain, readonly) UIView *containerView;

/** Class method that gives access to the shared instance. */
+ (LARSAdController *)sharedManager;

/** The primary method of adding your ads to a view and view controller. For some, this will be the only method that is ever called besides setting googleAdPublisherId. Call this method in every view controller's viewWillAppear method in order to add the shared ad instance to your view heirarchy.
 
 @param view The view you would like the ad container added to.
 @param viewController The view controller that will be managing the ad.
 */
- (void)addAdContainerToView:(UIView *)view withParentViewController:(UIViewController *)viewController;

/** Lays out the currently displayed banner view for the given orientation.
 
 @warning Deprecated.  You may still use this method in your view controller's willAnimateRotationFromOrientation:toOrientation: method, but using the shouldHandleOrientationChanges property to tell singleton to automatically listen for orientation changes will automatically call this method without needing to place the call in your view controller manually.
 @param orientation The orientation that the ad container should layout for.
 */
- (void)layoutBannerViewsForCurrentOrientation:(UIInterfaceOrientation)orientation;

@end
