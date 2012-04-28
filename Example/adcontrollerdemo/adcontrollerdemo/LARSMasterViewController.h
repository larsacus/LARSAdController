//
//  LARSMasterViewController.h
//  adcontrollerdemo
//
//  Created by Lars on 10/9/11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@class LARSDetailViewController;

@interface LARSMasterViewController : UITableViewController

@property (strong, nonatomic) LARSDetailViewController *detailViewController;

@end
