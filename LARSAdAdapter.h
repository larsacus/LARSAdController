//
//  LARSAdAdapter.h
//  adcontrollerdemo
//
//  Created by Lars Anderson on 11/8/12.
//
//  Copyright (c) 2011-2013 Lars Anderson, drink&apple, theonlylars
//
//Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
//
//The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
//
//THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

#import <Foundation/Foundation.h>
#import "LARSAdController.h"

@protocol LARSAdAdapter <NSObject>

@required
/* This is the actual banner view that will be displaying ads for the ad vendor.
 */
@property (strong, nonatomic) UIView *bannerView;

/* This is a BOOL value that is set whenever an ad for this adapter is visible on screen.
 */
@property (nonatomic) BOOL adVisible;

/* The adManager is the gateway to the LARSAdController that controls all registered instances of LARSAdAdapter.
 */
@property (weak, nonatomic) id <LARSAdControllerDelegate> adManager;

/* Lays out the banner view for a given orientation. Does not necessarily need to set the frame's origin correctly, just the banner's size. The banner's position is set by the ad controller.
 */
- (void)layoutBannerForInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation;

@optional
/* Class method that determines if an ad adapter requires a publisher id in order to begin serving ads.
 */
+ (BOOL)requiresPublisherId;

/* Class method that outlines if an ad adapter requires a parent view controller in order to be displayed.
 */
+ (BOOL)requiresParentViewController;

/* Starts ad requests. This method is optional because not all ad networks have a the concept of "start" or "pause". If they are allocated and alive, they are service ads indefinitely until deallocated.
 
 If you implement startAdRequests, then you must also implement pauseAdRequests and vice versa. There's no point in implementing either if you don't implement both.
 */
- (void)startAdRequests;

/* Pauses ad requests so that another ad network can begin displaying ads. This method is optional because not all ad networks have a concept of "pause". Ad networks that do not have this concept are simply deallocated and cleaned up when they are needed to be "paused".
 
 If you implement pauseAdRequests, then you must also implement startAdRequests and vice versa. There's no point in implementing either if you don't implement both.
 */
- (void)pauseAdRequests;

/* Returns a BOOL letting the ad controller know whether or not it can destroy an ad banner. This method is present in order to prevent an ad banner from being cleaned up before it is allowed (like when displaying an interstitial or the user is interacting with an ad). When this method is queried and returns NO, it is placed in a queue of ad adapters to be cleaned up at a later time.
 */
- (BOOL)canDestroyAdBanner;

/* A developer-friendly name to give your ad adapter class for easy debugging.
 */
- (NSString *)friendlyNetworkDescription;

/* This is the publisher id for the ad network. This is optional because not all ad network require a publisher id (iAds, for example).
 */
@property (copy, nonatomic) NSString *publisherId;

/* The parent view controller that is managing the view that the ad is currently living in.
 */
@property (weak, nonatomic) UIViewController *parentViewController;

/* A readonly property that indicates whether a banner's ad has been loaded. This is used by the ad controller to know when to display the ad when it is immediately instantiated.
 */
@property (nonatomic, readonly) BOOL adLoaded;

@end
