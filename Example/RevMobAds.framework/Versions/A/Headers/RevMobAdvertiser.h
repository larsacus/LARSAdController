#import <Foundation/Foundation.h>
#import "RevMobAdsDelegate.h"
#import <UIKit/UIKit.h>

@interface RevMobAdvertiser : NSObject

#pragma mark ADVERTISER METHODS

/**
 This will enable your app to be advertised in our network, should you want to do it in the 
 future. If you ever plan to advertise with us in the future, you should call this method. This 
 method only works in the background, which means the user won't be notified and nothing should 
 change in your app's interface if you call this method.
 
 You can call this on: Delegate, UIViewController or any other type of object.
 Performance: To increase the volume we'll deliver for your campaign, you can optimize the 
 following conditions.
 - the higher your bid, the higher the volume.
 - the higher your install/click rate, the higher the volume.
 - the higher your click/impression rate, the higher the volume.
 
 Deactivation: Not necessary.
 When: When app opens.
 
 @param appID: You can collect your App ID at http://revmob.com by looking up your apps. If you haven't registered the apps yet, simply add an app in your BCFAds account.
 @param delegate: Optional assignment of a delegate, otherwise simply return nil. Default is nil.
*/
+ (void)registerInstallWithAppID:(NSString *)appID withDelegate:(NSObject<RevMobAdsDelegate> *)delegate;

@end
