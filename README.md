# `LARSAdController` 2.0

## Description
`LARSAdController` is a singleton class that manages iAds and Google Ads in a single container view.  All orientations and devices are supported (Pads and Pods).

## Usage
For single-orientation support for all devices, simply add the following line in your `UIViewController`:

``` objective-c
- (void)viewWillAppear:(BOOL)animated{
    [[LARSAdController sharedManager] addAdContainerToView:[self view] withViewController:self];
}
```

That's it.  Technically, this can be added to any `UIView` that is large enough.

If you would like to enable support for multiple orientations, add the following when you create add the container to the view, as well as in `willAnimateRotationToInterfaceOrientation:toInterfaceOrientation:duration:`:

``` objective-c
- (void)viewWillAppear:(BOOL)animated{
    [[LARSAdController sharedManager] addAdContainerToView:self.view withParentViewController:self];
    [[LARSAdController sharedManager] layoutBannerViewsForCurrentOrientation:self.interfaceOrientation];
}

-(void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration{
    [[LARSAdController sharedManager] layoutBannerViewsForCurrentOrientation:toInterfaceOrientation];
}
```

There is currently not any support for auto-listening for interface orientation changes without the `viewController` delegate callback methods (yet).

##License

Copyright (c) 2011 Lars Anderson, drink&apple

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

*THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.*