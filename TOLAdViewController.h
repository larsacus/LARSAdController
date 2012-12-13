//
//  TOLAdViewController.h
//  adcontrollerdemo
//
//  Created by Lars Anderson on 11/12/12.
//  Copyright (c) 2012 theonlylars. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TOLAdViewController : UIViewController

/* Returns a bool indicating whether or not the view controller should load ads. Base implementation always returns YES. Override in subclasses for customized functionality.
 */
- (BOOL)shouldDisplayAds;

@end
