//
//  LARSExampleViewController.m
//  adcontrollerdemo
//
//  Created by Lars Anderson on 4/28/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "LARSExampleViewController.h"
#import "LARSAdController.h"

@interface LARSExampleViewController ()

@end

@implementation LARSExampleViewController

- (void)loadView{
    UIView *view = [[UIView alloc] initWithFrame:[UIScreen mainScreen].bounds];
    view.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    [view setBackgroundColor:[UIColor orangeColor]];
    
    self.adVisibleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0.f, 0.f, 200.f, 50.f)];
    self.adVisibleLabel.text = @"Ad not visible";
    
    [view addSubview:self.adVisibleLabel];
    
    self.view = view;
}

- (void)viewDidLoad{
    [super viewDidLoad];
    
    self.adVisibleLabel.center = CGPointMake(CGRectGetWidth(self.view.frame)/2, CGRectGetHeight(self.view.frame)/2);
    self.adVisibleLabel.autoresizingMask = UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleHeight;
    
    [[LARSAdController sharedManager] addObserver:self
                                       forKeyPath:kLARSAdObserverKeyPathIsAdVisible
                                          options:NSKeyValueObservingOptionNew
                                          context:nil];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context{
    if ([keyPath isEqualToString:kLARSAdObserverKeyPathIsAdVisible]) {
        NSLog(@"Observing keypath \"%@\"", keyPath);
        
        BOOL anyAdsVisible = [change[NSKeyValueChangeNewKey] boolValue];
        if (anyAdsVisible) {
            self.adVisibleLabel.text = @"Ad is visible";
        }
        else{
            self.adVisibleLabel.text = @"Ad not visible";
        }
    }
}

- (void)dealloc{
    [[LARSAdController sharedManager] removeObserver:self forKeyPath:kLARSAdObserverKeyPathIsAdVisible];
}

/* If this view controller did not inherit from TOLAdViewController, then you would need to uncomment the below method and implement adding the ad container to the view yourself. You will also need to uncomment line 10 to import the class. 
 */
/*
- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    
    [[LARSAdController sharedManager] addAdContainerToViewInViewController:self];
}
 */

//Deprecated
#if __IPHONE_OS_VERSION_MIN_REQUIRED < __IPHONE_6_0
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation{
    return (toInterfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
}
#endif

//New iOS 6 stuff
- (BOOL)shouldAutorotate{
    return YES;
}

- (NSUInteger)supportedInterfaceOrientations{
    return UIInterfaceOrientationMaskAllButUpsideDown;
}

@end
