//
//  TOLAdAdapterHouseAds.m
//  adcontrollerdemo
//
//  Created by Lars Anderson on 12/16/12.
//  Copyright (c) 2012 theonlylars. All rights reserved.
//

#import "TOLAdAdapterHouseAds.h"

const NSString * const kTOLHouseAdCache = @"LARSAdControllerHouseAdsCache";
const NSString * const kTOLHouseLandscapePadAdURLKeyPath = @"landscape.padUrl";
const NSString * const kTOLHouseLandscapePodAdURLKeyPath = @"landscape.podUrl";
const NSString * const kTOLHousePortraitPadAdURLKeyPath = @"portrait.padUrl";
const NSString * const kTOLHousePortraitPodAdURLKeyPath = @"portrait.podUrl";
const NSString * const kTOLHouseAdTapDestinationURLKeyPath = @"destinationUrl";

@interface TOLAdAdapterHouseAds()

@property (strong, nonatomic) NSTimer *refreshTimer;
@property (nonatomic) NSInteger currentAdIndex;
@property (copy, nonatomic) NSArray *adInventory;

@end

@implementation TOLAdAdapterHouseAds

- (UIView *)bannerView{
    if (_bannerView == nil) {
        _bannerView = [[UIImageView alloc] init];
    }
    return _bannerView;
}

- (void)layoutBannerForInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation{
    
    CGFloat height;
    if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad){
        if (UIInterfaceOrientationIsLandscape(interfaceOrientation)) {
            //get landscape ad
        }
        else{//portrait
            //get portrait ad
        }
    }
    else{
        if (UIInterfaceOrientationIsLandscape(interfaceOrientation)) {
            //get landscape ad
        }
        else{//portrait
            //get portrait ad
        }
    }
}

//TODO: Requesting an ad resource
//1. Get plist with ad data for orientations and devices:
//{
//    [
//     {
//         @"landscape" : {
//             @"padUrl" : @"http://public.dropbox.com/padImageLandscape.png",
//             @"podUrl" : @"http://public.dropbox.com/podImageLandscape.png"
//         },
//         @"portrait" : {
//             @"padUrl" : @"http://public.dropbox.com/padImagePortrait.png",
//             @"podUrl" : @"http://public.dropbox.com/podImagePortrait.png"
//         },
//         @"destinationUrl" : @"https://ax.itunes.com/link/to/my/app"
//     },
//     {
//         ... second ad
//     }
//     ]
//}
//2. Store array of dictionaries for house ads
//3. If image URL is remote, check image cache
//4. If image not in cache, fetch image for type of device and orientation
//5. When image is received, set image on banner, cache image
//6. Size banner for image
//7. Call back to adManager to notify that ad is loaded
//8. Start timer for impression
//9. When timer fires, rotate through ad array, calling back to adManager

- (void)pauseAdRequests{
    
}

- (void)startAdRequests{
    
}

- (NSString *)friendlyNetworkDescription{
    return @"House Ads";
}

@end
