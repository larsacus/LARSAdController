//
//  LARSAdController.h
//  Droid Light
//
//  Created by Lars on 7/24/11.
//  Copyright 2011 Drink & Apple, Lars Anderson. All rights reserved.
//

//Copyright (c) 2011 Lars Anderson, drink&apple
//
//Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
//
//The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
//
//THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

#import <Foundation/Foundation.h>
#import <iAd/iAd.h>
#import "GADBannerView.h"
#import "GADBannerViewDelegate.h"


@interface LARSAdController : NSObject <GADBannerViewDelegate, ADBannerViewDelegate> {
    

    GADBannerView       *_googleAdBannerView;
    ADBannerView        *_iAdBannerView;
@private
    UIView              *_parentView;
    UIView              *_containerView;
    UIViewController    *_parentViewController;
    BOOL                _googleAdVisible;
    BOOL                _iAdVisible;
}

@property (nonatomic, retain) GADBannerView     *googleAdBannerView;
@property (nonatomic, retain) ADBannerView      *iAdBannerView;
@property (nonatomic, assign) UIView            *parentView;
@property (nonatomic, retain) UIView            *containerView;
@property (nonatomic, assign) UIViewController  *parentViewController;
@property (nonatomic, 
           getter = isGoogleAdVisible)  BOOL    googleAdVisible;
@property (nonatomic,
           getter = isIAdVisible)       BOOL    iAdVisible;

- (void)createContainerView;
- (void)createGoogleAds;
- (void)destroyGoogleAdsAnimated:(BOOL)animated;
- (void)createIAds;
- (void)destroyIAds;

@end
