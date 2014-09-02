## Description
LARSAdController 3.0 is a singleton ad management class that manages ad classes that conform to the `LARSAdAdapter` protocol. Ads are managed in a way that most closely adheres to best practices for ad networks using a single instance for each ad network in order to provide the best publishing platform for advertisers to maximize ad inventory based on your particular needs.  Currently there are two adapters available (iAd and Google Ads). The adapters can be extended to any ad framework wanted.

##Linking
###Cocoapods
![LARSAdController Platform](https://cocoapod-badges.herokuapp.com/p/LARSAdController/badge.png) ![LARSAdController Version](https://cocoapod-badges.herokuapp.com/v/LARSAdController/badge.png)

The absolute easiest way to integrate the code into your project is to use [cocoapods](http://cocoapods.org/?q=LARSAdController) to include the source in your project.

To use cocoapods with `LARSAdController`, simply create your new `Podfile` and include the following dependency:

``` ruby
platform :ios, '5.0'

pod 'LARSAdController', '~> 3.0'
```

This will tell cocoapods to include all LARSAdController components of any version in v3.x. You will get the latest revision that cocoapods has in it's repository whose major revision is 3.x.

####Subspecs
If you are only interested in iAds _or_ GoogleAds, but not both, you can specify that you would only like to have one or the other using the following in your `Podfile`:

``` ruby
platform :ios, '5.0'

pod 'LARSAdController/iAds', '~> 3.0'
pod 'LARSAdController/GoogleAds', '~> 3.0'
```

If you only need the core files without any ad adapters, then your `Podfile` will look something like this:

``` ruby
platform :ios, '5.0'

pod 'LARSAdController/Core', '~> 3.0'
```

The appropriate files and frameworks will be included in your project depending on which component you would like.

Congratulations! You can now ignore the next section on doing all of this by hand.

###Ye Olde Method

If you're not using cocoapods, in order to use `LARSAdController`, you will need to clone this repo and add the `Source/` directory to your project, as well as add the required frameworks - all by hand.

...like a caveman

###Git Submodule
You can do this the old way by simply cloning the repository and adding the files to your project as a git submodule as shown below:

`git add submodule <third_party_folder> https://github.com/larsacus/LARSAdController.git --recursive`

Where `<third_party_folder>` is the folder where all of your third party code lives in your project file structure.

## Framework Requirements
In order to compile, you will need to include the following Apple frameworks:

###iAds

  1. `iAd.framework`
  2. `AdSupport.framework` (weak-link for iOS 6)
  
###Google Ads

  1. `StoreKit.framework`
  2. `AudioToolbox.framework`
  3. `MessageUI.framework`
  4. `SystemConfiguration.framework`
  5. `CoreGraphics.framework`
  6. `AdSupport.framework` (weak-link for iOS 6)

You will also need the `Google AdMob SDK` available from [Google](https://developers.google.com/mobile-ads-sdk/download#downloadios).

That's it.  Technically, this can be added to any `UIView` that is large enough and managed by a view controller.

###Other Requirements
1. iOS 5.0+
2. Xcode 4.3+ - LLVM 4.0 support. Objective-C container literals are used.

## Usage
_**Cocoapods users you can resume reading here**_

Back in the days of yore, `LARSAdController` 2.0 forced you opt-in to rotation-handling.  This is no longer necessary as the ad management class will auto-detect your current orientation given that the current view controller that the ad container lives in is correctly setup.

The first step is to register your ad classes that the ad manager will use. The ad networks take priority in the order they were added in, so the first network registered is the highest priority, the second is below that, and so on:

In app delegate or somewhere else convenient before first banner is needed to display:

``` objective-c
- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions{
    [[LARSAdController sharedManager] registerAdClass:[TOLAdAdapteriAds class]];
    [[LARSAdController sharedManager] registerAdClass:[TOLAdAdapterGoogleAds class] withPublisherId:publisherId];
}
```

Then the only line of code you need in your view controller is to add the container to your view using either:

``` objective-c
- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    
    [[LARSAdController sharedManager] addAdContainerToView:self.view withViewController:self];
}
```

or the simpler version:

``` objective-c
- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    
    [[LARSAdController sharedManager] addAdContainerToViewInViewController:self];
}
```

Once the current highest-priority ad network fails to obtain an ad, it will continue to wait for an ad while the next-highest priority ad network is allocated and sends a request.  Once the ad network in priority above this network obtains an ad again, it will hide the lower-priority ad banner, clean it up and display the higher-priority network banner.

###Ultra-Lazy Implementation
To make your life even _easier_, all you need to do is have each of your view controllers that you would like to have an ad pinned to the top or bottom of your view controller's view is to have your view controller subclasses inherit from `TOLAdViewController`. This will automagically add an ad view container to your view controller's view when it is supposed to. The only downside is less flexibility on ad placement in your view hierarchy.

``` objective-c
@interface MYBestViewController : TOLAdViewController
//BOOM - Ads
@end
```

####Conditionally Displaying Ads
If you'd only like the ads to be displayed under certain conditions (like when a user has purchased a certain in-app upgrade), then simply override `-shouldDisplayAds` in your `TOLAdViewController` subclass. Ads will not be loaded on `viewWillAppear:` if `shouldDisplayAds` returns `NO`:

``` objective-c
- (BOOL)shouldDisplayAds{
  return ([self.purchaseTracker hasPurchasedUpgrade] == NO);
}
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
1. iAd - `TOLAdAdapteriAds`
2. Google Ads - `TOLAdAdapterGoogleAds`

###Planned Ad Network Adapters (Not Yet Implemented)
1. House Ads - Display your own image with an action for a banner
2. [TOLDeveloperAds](https://github.com/larsacus/TOLDeveloperAds) - Display auto-generated banner ads for all of your apps with a single line of code

##Creating a New Ad Network Adapter
In order to create a new ad adapter for an ad vendor not already created, simply create a new `NSObject` subclass that conforms to the `LARSAdAdapter` protocol. There are a few required methods and properties that must be present in order for the adapter to function, as well as some optional ones that give some additional control/functionality of an ad banner. More detailed documentation can be found in the header file for `LARSAdAdapter.h`.

A good start would be to simply conform to the `LARSAdAdapter` protocol, compile, and let all of the warnings, errors, and runtime asserts help you complete the implementation:

``` objective-c
@interface LARSAdControllerHouseAdsAdapter : NSObject <LARSAdAdapter>
  //fill out the meaty part  
@end
```

##Installing Documentation
LARSAdController 3.0's headers are fully documented using appledoc. In order to install the docset in Xcode, you will need to install appledoc, then run a command similar to the below in the root directory of the `LARSAdController` repository in order to install the docset:

`appledoc -p "LARSAdController" -c "theonlylars" -d -n --company-id "com.theonlylars" --no-repeat-first-par -o ~/Docs Source`

In the above example, you will need to create the `Docs` directory in your home directory before running this. You can just as easily change that path to any path you find convenient. Appledoc will install the docset in Xcode on completion.

_Note: If you are using cocoapods, the documentation will be installed automatically._

##License (MIT)
I would love attribution and a link to this page on GitHub [here](https://github.com/larsacus/LARSAdController), but it is not required.

Copyright (c) 2011 Lars Anderson, theonlylars

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

*THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.*

##Change Log
###3.0
- Refactored to add support for modular networks
- Added modular network protocol for network adapters to conform to
- Added modular ad network handling
- Removed option to opt-in to orientation-handling. Now automatically queries view controller's orientation.
- Now ARC-ready!
- Added Google Ad test-ad support - will now serve test ads when running in debug mode (`#ifdef DEBUG`)

###2.1
- Added orientation auto-listening without use of view controller delegate callbacks
- Added ability for ads to try and fit themselves into any view they are placed in.  Sizing is now done based on superview size vs just the orientation
- Fixed Issue 3 - "Container frame is incorrect when returning from clicked ad"
- Fixed issue where ad would not display again when returning from clicked ad
- Moved some method signatures from .h to private interface in .m file
- Updated example project

###2.0.1
- Added demo project to make up for my lackluster instructions

###2.0
- Now with more rotation-ness support!
- Pad support as well as pod support for all of your support needs

###1.x
- Only pods are supported
- Only portrait orientation is supported

##Apps Using LARSAdController
If your app is using LARSAdController, and you'd like to be included in this list, please let me know either on twitter or by submitting a pull request with your app added.

- Droid Light
- MasjidNow
- Health Lottery Results Free


[![Bitdeli Badge](https://d2weczhvl823v0.cloudfront.net/larsacus/larsadcontroller/trend.png)](https://bitdeli.com/free "Bitdeli Badge")

