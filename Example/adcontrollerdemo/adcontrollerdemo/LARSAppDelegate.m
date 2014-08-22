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

- (BOOL)application:(UIApplication *)application willFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    [self launch];
    
    return YES;
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions{
    [self launch];
    
    return YES;
}

- (void)launch{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
        
//        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(notified:) name:nil object:nil];
        
        //This publisher id is a test account setup to test google ads since there is no good way to only send test ads without one - ad request will simply fail
        [[LARSAdController sharedManager] registerAdClass:[TOLAdAdapterGoogleAds class]
                                          withPublisherId:@"a14e55c99c24b43"];
        [[LARSAdController sharedManager] registerAdClass:[TOLAdAdapteriAds class]];
        
        
        
        LARSExampleViewController *root = [[LARSExampleViewController alloc] init];
        [self.window setRootViewController:root];
        
        [self.window makeKeyAndVisible];
    });
}

- (void)notified:(NSNotification *)note{
    NSLog(@"Note: %@", note);
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    /*
     Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
     Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
     */
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    /*
     Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
     If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
     */
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    /*
     Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
     */
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    /*
     Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
     */
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    /*
     Called when the application is about to terminate.
     Save data if appropriate.
     See also applicationDidEnterBackground:.
     */
}

@end
