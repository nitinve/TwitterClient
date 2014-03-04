//
//  TwitterTableViewController.h
//  TwitterClient
//
//  Created by Nitin Verma on 2/19/14.
//  Copyright (c) 2014 Nitin Verma. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreText/CoreText.h>
#import "CoreDataTableViewController.h"
#import "FHSTwitterEngine.h"
#import "TwitterDatabaseAvailability.h"
#import "Tweet+create.h"
#import "TCAppDelegate.h"
#import "Tweet.h"
#import "User.h"
#import "UITweetCell.h"

@interface TwitterTableViewController : CoreDataTableViewController

+ (NSString *)htmlEntityDecode:(NSString *)string;

@end
