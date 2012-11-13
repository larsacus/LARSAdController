## Description
`LARSAdController` 3.0 is a singleton ad management class that manages ad classes that conform to the `LARSAdAdapter` protocol. Currently there are two adapters available (iAd and Google Ads). The adapters can be extended to any ad framework wanted.

## Usage
Back in the days of yore, `LARSAdController` 2.0 forced you opt-in to rotation-handling.  This is no longer necessary as the ad management class will auto-detect your current orientation given that your current view controller that the ad container lives in is correctly setup.

The first step is to register your ad classes that the ad manager will use. The ad networks take priority in the order they were added in, so the first network registered is the highest priority, the second is below that, and so on:

In app delegate (or somewhere else convenient):

``` objective-c
- (BOOL)application:(UIApplication *)application willFinishLaunchingWithOptions:(NSDictionary *)launchOptions{
    [[LARSAdController sharedManager] registerAdClass:[LARSAdControlleriAdAdapter class]];
    [[LARSAdController sharedManager] registerAdClass:[LARSAdControllerAdMobAdapter class] withPublisherId:publisherId];
}
```

Then the only line of code you need in your view controller is to add the container to your view using either:

``` objective-c
- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    
    [[LARSAdController sharedManager] addAdContainerToView:[self view] withViewController:self];
}
```

or the simpler version:

``` objective-c
- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    
    [[LARSAdController sharedManager] addAdContainerToViewInViewController:self];
}
```

Once the current highest-priority ad network fails to obtain an ad, it will continue to wait for an ad while the next-highest priority ad network is allocated and sends a request.  Once the ad network in priority above this network obtains an ad again, it will hide the lower-priority ad banner and display the higher-priority network banner.

###Ultra-Lazy Implementation
To make your life even _easier_, all you need to do is have each of your view controllers that you would like to have an ad pinned to the top or bottom of your view controller's view is to have your view controller subclasses inherit from `TOLAdViewController`. This will automatigically add an ad view container to your view controller's view when it is supposed to.

``` objective-c
@interface MYBestViewController : TOLAdViewController
//BOOM - Ads
@end
```

##Ad Placement
In the past, you were only able to add a banner view to the bottom of a view and have it animate in from the bottom.  Now, you are able to not only control whether it resides at the top or bottom of your view, but control how it animates in and out of the screen.

Two new properties are available on `LARSAdController`:

``` objective-c
@property (nonatomic) LARSAdControllerPresentationType presentationType;
@property (nonatomic) LARSAdControllerPinLocation pinningLocation;
```

The options for `presentationType` are as follows. These options will slide the ad banner in and out from the direction indicated in the enum:

``` objective-c
typedef NS_ENUM(NSInteger, LARSAdControllerPresentationType){
    LARSAdControllerPresentationTypeBottom = 0,
    LARSAdControllerPresentationTypeTop,
    LARSAdControllerPresentationTypeLeft,
    LARSAdControllerPresentationTypeRight
};
```

These options will pin the ad view container to the bottom (default) or top of the view you specify and layout the banner inside the container accordingly:

``` objective-c
typedef NS_ENUM(NSInteger, LARSAdControllerPinLocation){
    LARSAdControllerPinLocationBottom =  0,
    LARSAdControllerPinLocationTop
};
```

##Currently Available Ad Network Adapters
1. iAd - `LARSAdControlleriAdAdapter`
2. Google Ads - `LARSAdControllerAdMobAdapter`

###Planned Ad Network Adapters (Not Yet Implemented)
1. House Ads - Display your own image with an action for a banner

## Framework Requirements
In order to compile, you will need to include the following Apple frameworks:

iAds:

  1. `iAd.framework`
  
Google Ads:

  1. `StoreKit.framework`
  2. `AudioToolbox.framework`
  3. `MessageUI.framework`
  4. `SystemConfiguration.framework`
  5. `CoreGraphics.framework`
  6. `AdSupport.framework` (weak-link for iOS 6)

You will also need the `Google AdMob SDK` available from [Google](https://developers.google.com/mobile-ads-sdk/download#downloadios).

That's it.  Technically, this can be added to any `UIView` that is large enough and managed by a view controller.

##Other Requirements
1. iOS 5.0+
2. Xcode 4.3+ - LLVM 4.0 support. Objective-C container literals are used.

## Detailed Integration Instructions (UPDATE THIS)
- Click here a more detailed [iAd integration tutorial](http://theonlylars.com/blog/2012/04/27/integrating-google-ads-with-iad/) blog post using LARSAdController.

##Creating a New Ad Network Adapter

*FILL THIS OUT*

##License (MIT)
I would love attribution and a link to this page on GitHub [here](https://github.com/larsacus/LARSAdController), but it is not required.

Copyright (c) 2011 Lars Anderson, theonlylars

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

*THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.*

##Changelog
###3.0
-----
- Refactored to add support for modular networks
- Added modular network protocol for network adapters to conform to
- Added modular ad network handling
- Removed option to opt-in to orientation-handling. Now automatically queries view controller's orientation.
- Now ARC-ready!
- Added Google Ad test-ad support - will now serve test ads when running in debug mode (#def DEBUG=1)

###2.1
-----
- Added orientation auto-listening without use of view controller delegate callbacks
- Added ability for ads to try and fit themselves into any view they are placed in.  Sizing is now done based on superview size vs just the orientation
- Fixed Issue 3 - "Container frame is incorrect when returning from clicked ad"
- Fixed issue where ad would not display again when returning from clicked ad
- Moved some method signatures from .h to private interface in .m file
- Updated example project

###2.0.1
-----
- Added demo project to make up for my instructions' shortfall

###2.0
-----
- Now with more rotation-ness support!
- Pad support as well as pod support for all of your support needs

###1.x
---
- Only pods are supported
- Only portrait orientation is supported