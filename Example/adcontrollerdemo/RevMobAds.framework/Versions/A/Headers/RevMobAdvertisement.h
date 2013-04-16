#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@protocol RevMobAdvertisement <NSObject>

@required

- (void)update:(NSDictionary *)dict;

@optional

- (void)show;

@end