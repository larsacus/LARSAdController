//
//  LARSExampleViewController.m
//  adcontrollerdemo
//
//  Created by Lars Anderson on 4/28/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "LARSExampleViewController.h"
#import <LARSAdController/LARSAdController.h>
#import <LARSAdController/TOLAdAdapter.h>

@interface LARSExampleViewController () <LARSBannerVisibilityDelegate>

@end

@implementation LARSExampleViewController

- (void)loadView {
    UIView *view = [[UIView alloc] initWithFrame:[UIScreen mainScreen].bounds];
    view.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    [view setBackgroundColor:[UIColor orangeColor]];
    
    self.adVisibleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0.f, 0.f, 200.f, 50.f)];
    self.adVisibleLabel.text = @"Ad not visible";
    
    [view addSubview:self.adVisibleLabel];
    
    
    float buttonHeight = 50.0f;
    float buttonWidth = view.frame.size.width - 20.0f;
    
    // create and configure the test button at the bottom of the screen
    self.bottomTestButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    self.bottomTestButton.center = CGPointMake(0.0, 0.0);
    self.bottomTestButton.frame = CGRectMake(10.0f, view.frame.size.height - (buttonHeight + 30.0f), buttonWidth, buttonHeight);
    [self.bottomTestButton setTitle:@"this button should move up and down when an ad is shown or hidden" forState:UIControlStateNormal];
    self.bottomTestButton.titleLabel.lineBreakMode = NSLineBreakByWordWrapping;
    self.bottomTestButton.titleLabel.textAlignment = NSTextAlignmentCenter;
    
    [view addSubview:self.bottomTestButton];
    
    self.view = view;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.adVisibleLabel.center = CGPointMake(CGRectGetWidth(self.view.frame)/2, CGRectGetHeight(self.view.frame)/2);
    self.adVisibleLabel.autoresizingMask = (UIViewAutoresizingFlexibleBottomMargin |
                                            UIViewAutoresizingFlexibleLeftMargin |
                                            UIViewAutoresizingFlexibleRightMargin |
                                            UIViewAutoresizingFlexibleHeight);
    
    [[LARSAdController sharedManager] addObserver:self
                                       forKeyPath:kLARSAdObserverKeyPathIsAdVisible
                                          options:NSKeyValueObservingOptionNew
                                          context:nil];
    
    [[LARSAdController sharedManager] setDelegate:self];
    
    self.bannerIsVisible = NO;
}

- (void)adController:(LARSAdController *)adController bannerChangedVisibility:(BOOL)anyBannerVisible {
    NSLog(@"Changing visibility: %@", anyBannerVisible ? @"visible" : @"hidden");
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    if ([keyPath isEqualToString:kLARSAdObserverKeyPathIsAdVisible]) {
        NSLog(@"Observing keypath \"%@\"", keyPath);
        
        
        BOOL anyAdsVisible = [change[NSKeyValueChangeNewKey] boolValue];
        
        // get a reference to the banner that is currently visible
        UIView *bannerView;
        
        NSArray *instances = [[[LARSAdController sharedManager] adapterInstances] allValues];
        for (id <TOLAdAdapter> adapterInstance in instances) {
            if (adapterInstance.adVisible) {
                bannerView = adapterInstance.bannerView;
            }
        }
        
        if (anyAdsVisible) {
            self.adVisibleLabel.text = @"Ad is visible";
            
            // an add either appeared for the first time or replaced an existing one.
            // either way, figure out how high to move the button, and move it
            float height = bannerView.frame.size.height;
            float padding = 0.0f;
            self.currentPushAmount = height + padding;
            
            self.bannerIsVisible = YES;
            [UIView animateWithDuration:0.25f animations:^(void) {
                CGRect screenRect = [[UIScreen mainScreen] bounds];
                
                [self.bottomTestButton setFrame:CGRectMake(self.bottomTestButton.frame.origin.x,
                                                           screenRect.size.height - (self.currentPushAmount + self.bottomTestButton.frame.size.height + 30.0f),
                                                           self.bottomTestButton.frame.size.width,
                                                           self.bottomTestButton.frame.size.height)];
            }];
            
        } else {
            self.adVisibleLabel.text = @"Ad not visible";
            
            // no ads are visible, but if the banner is still showing, so move it back down
            if (self.bannerIsVisible) {
                self.bannerIsVisible = NO;
                [UIView animateWithDuration:0.25f animations:^(void) {
                    [self.bottomTestButton setFrame:CGRectMake(self.bottomTestButton.frame.origin.x,
                                                               self.bottomTestButton.frame.origin.y + self.currentPushAmount,
                                                               self.bottomTestButton.frame.size.width,
                                                               self.bottomTestButton.frame.size.height)];
                }];
            }
        }
    }
}

- (void)dealloc {
    [[LARSAdController sharedManager] removeObserver:self forKeyPath:kLARSAdObserverKeyPathIsAdVisible];
}

/** If this view controller did not inherit from TOLAdViewController, then you would need to 
 uncomment the below method and implement adding the ad container to the view yourself. 
 You will also need to uncomment line 10 to import the class.
 */
/*
 - (void)viewWillAppear:(BOOL)animated {
 [super viewWillAppear:animated];
 
 [[LARSAdController sharedManager] addAdContainerToViewInViewController:self];
 }
*/

//Deprecated
#if __IPHONE_OS_VERSION_MIN_REQUIRED < __IPHONE_6_0
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation {
    return (toInterfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
}
#endif

//New iOS 6 stuff
- (BOOL)shouldAutorotate{
    return YES;
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations{
    return UIInterfaceOrientationMaskAllButUpsideDown;
}

@end
