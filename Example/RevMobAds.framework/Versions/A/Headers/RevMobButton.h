#import <Foundation/Foundation.h>
#import "RevMobAdvertisement.h"
#import "RevMobAdsDelegate.h"


typedef enum {
    RevMobButtonStatusUndefined = -1,
    RevMobButtonStatusNew = 0,
    RevMobButtonStatusLoading,
    RevMobButtonStatusLoaded,
    RevMobButtonStatusLoadError
} RevMobButtonStatus;


/**
 Subclass of UIButton, you can use in your app just as a regular UIButton.

 You should alter just the appearance of it.

 When the button is clicked a RevMobAdLink is used, so the behaviour is the same
 of the adLink. The intention is to facilitate the implementation of a "More games"
 button.
 */
@interface RevMobButton : UIButton <RevMobAdvertisement, RevMobAdsDelegate>

/**
 The delegate setted on this property is called when ad related events happend, see
 RevMobAdsDelegate for mode details.
 */
@property (nonatomic, assign) id<RevMobAdsDelegate> delegate;


/**
 This property can be use to check the status of the button.
 
 The status can be:
 
 *RevMobButtonStatusNew* - New button, ad not loaded yet;
 
 *RevMobButtonStatusLoading* - Ad is loading;
 
 *RevMobButtonStatusLoaded* - Ad loaded;
 
 *RevMobButtonStatusLoadError* - Error while loading the ad, this button
 can't be reused to show the store anymore, it's necessary to create a new
 button. This can happen when there is no internet connection.
 
 *RevMobButtonStatusUndefined* - There is an unknow error or an unexpected
 behaviour.
 */
@property (atomic, readonly) RevMobButtonStatus status;

@end
