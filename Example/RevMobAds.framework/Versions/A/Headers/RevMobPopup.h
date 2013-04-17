#import <Foundation/Foundation.h>
#import "RevMobAdvertisement.h"
#import "RevMobAdsDelegate.h"


/**
 Class responsable for handle the Popoup ad unit.
 */
@interface RevMobPopup : NSObject <RevMobAdvertisement,RevMobAdsDelegate,UIAlertViewDelegate>

/**
 The delegate setted on this property is called when ad related events happend, see
 RevMobAdsDelegate for mode details.
 */
@property(nonatomic, assign) id<RevMobAdsDelegate> delegate;

/**
 Use this method to show the ad.
 */
- (void)showAd;

@end
