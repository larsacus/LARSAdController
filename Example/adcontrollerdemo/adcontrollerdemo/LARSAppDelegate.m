//
//  LARSAppDelegate.m
//  adcontrollerdemo
//
//  Created by Lars on 10/9/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "LARSAppDelegate.h"
#import "LARSExampleViewController.h"
#import <LARSAdController/LARSAdController.h>
#import <LARSAdController/TOLAdAdapterGoogleAds.h>
#import <LARSAdController/TOLAdAdapteriAds.h>

@implementation LARSAppDelegate

@synthesize window = _window;
@synthesize navigationController = _navigationController;
@synthesize splitViewController = _splitViewController;

- (BOOL)application:(UIApplication *)application willFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    [self launch];
    
    return YES;
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    [self launch];
    
    return YES;
}

- (void)launch {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
        
//        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(notified:) name:nil object:nil];
        
        /** This publisher id is a test account setup to test google ads since there is no good 
         way to only send test ads without one - ad request will simply fail
         */
        [[LARSAdController sharedManager] registerAdClass:[TOLAdAdapterGoogleAds class]
                                          withPublisherId:@"a14e55c99c24b43"];
        [[LARSAdController sharedManager] registerAdClass:[TOLAdAdapteriAds class]];
        
        
        
        LARSExampleViewController *root = [[LARSExampleViewController alloc] init];
        [self.window setRootViewController:root];
        
        [self.window makeKeyAndVisible];
    });
}

- (void)notified:(NSNotification *)note {
    NSLog(@"Note: %@", note);
}

@end
