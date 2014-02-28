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

@interface TwitterTableViewController : UITableViewController

@property (nonatomic, strong) NSMutableArray *tweets; //Tweets

@end
