#import <Foundation/Foundation.h>
#import "RevMobAdvertisement.h"
#import "RevMobAdsDelegate.h"

/**
 Class responsable for handle the AdLink ad unit.
 
 If you want a button alread configured with an adLink use the RevMobButton.
 */
@interface RevMobAdLink : NSObject <RevMobAdvertisement, RevMobAdsDelegate> {
}

/**
 The delegate setted on this property is called when ad related events happend, see
 RevMobAdsDelegate for mode details.
 */
@property(nonatomic, assign) id<RevMobAdsDelegate> delegate;

/**
 Use this method to load the ad.
 */
- (void)loadAd;

/**
 Open the ad link.

 Use this method to open the iTunes with the advertised app.

 */
- (void)openLink;


@end
