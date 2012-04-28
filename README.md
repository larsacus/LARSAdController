## Description
`LARSAdController` is a singleton class that manages iAds and Google Ads in a single container view.  All orientations and devices are supported (Pads and Pods).

## Usage
For single-orientation support for all devices, simply add the following line in your `UIViewController`:

``` objective-c
- (void)viewWillAppear:(BOOL)animated{
    [[LARSAdController sharedManager] addAdContainerToView:[self view] withViewController:self];
    [[LARSAdController sharedManager] setGoogleAdPublisherId:myPublisherId]; //change publisher id unless you want me to have your monies (only once per singleton, though)
}
```

## Framework Requirements
In order to compile, you need to include the following Apple frameworks:

  1. `iAd.framework`
  2. `AudioToolbox.framework`
  3. `MessageUI.framework`
  4. `SystemConfiguration.framework`

You will also need the `Google AdMob SDK` available from [Google](https://developers.google.com/mobile-ads-sdk/download#downloadios).

That's it.  Technically, this can be added to any `UIView` that is large enough and managed by a view controller.

If you would like to enable support for multiple orientations, add the following when you create add the container to the view, as well as in `willAnimateRotationToInterfaceOrientation:toInterfaceOrientation:duration:`:

``` objective-c
- (void)viewWillAppear:(BOOL)animated{
    [[LARSAdController sharedManager] addAdContainerToView:self.view withParentViewController:self];
    [[LARSAdController sharedManager] setGoogleAdPublisherId:myPublisherId]; //this only needs to be called the first time LARSAdController is called
    [[LARSAdController sharedManager] setShouldHandleOrientationChanges:YES];
}
```

## Limitations (Maybe this is where you come in?)

  2. Support to add ad container to the top of a UIView (so that it slides up instead of down)
  3. Support for other animation transitions out of the box
  5. Modular support for more ad networks

##License (MIT)
I would love attribution and a link to this page on GitHub [here](https://github.com/larsacus/LARSAdController), but it is not required.

Copyright (c) 2011 Lars Anderson, drink&apple

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

*THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.*

## Changelog
###2.1
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