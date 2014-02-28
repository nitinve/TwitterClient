
//
//  TimelineTableViewController.m
//  TwitterClient
//
//  Created by Nitin Verma on 2/19/14.
//  Copyright (c) 2014 Nitin Verma. All rights reserved.
//

#import "TimelineTableViewController.h"
#import "FHSTwitterEngine.h"
#import "TwitterDatabaseAvailability.h"

@interface TimelineTableViewController ()

@property (nonatomic) NSInteger previousRowIndex;
@property (nonatomic) NSManagedObjectContext *twitterDatabaseContext;



@end

@implementation TimelineTableViewController

- (void)awakeFromNib {
  [[NSNotificationCenter defaultCenter] addObserverForName:TwitterDatabaseAvailabilityNotification
                                                    object:nil
                                                     queue:nil
                                                usingBlock:^(NSNotification *notification) {
                                                  self.twitterDatabaseContext = notification.userInfo[TwitterDatabaseAvailabilityContext];
                                                }];
}

- (void)viewDidLoad
{
  [super viewDidLoad];
  UIRefreshControl *refreshControl = [[UIRefreshControl alloc] init];
  [refreshControl addTarget:self action:@selector(fetchNewTweets) forControlEvents:UIControlEventValueChanged];
  self.refreshControl = refreshControl;
  
  
	[self fetchTweets];
}

- (void) viewWillAppear: (BOOL) animated
{
  [super viewWillAppear: animated];
  
  //    self.tableView.contentOffset = CGPointMake(0, -self.refreshControl.frame.size.height);
  //    [self.refreshControl beginRefreshing];
  
  // kick off your async refresh!
  //    [self fetchTweets];
}

-(void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
  if (!self.previousRowIndex) self.previousRowIndex = indexPath.row;
  else if (self.previousRowIndex < indexPath.row && indexPath.row == [self.tweets count]-10) {
    self.previousRowIndex = indexPath.row;
    NSString *test = [NSString stringWithFormat:@"%@",[[self.tweets lastObject] valueForKeyPath:@"id"]];
    [self fetchOldTweets:test];
  }
  
}

-(IBAction)fetchNewTweets{
  [self.refreshControl beginRefreshing];
  dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
    @autoreleasepool {
      NSMutableArray *timelineTweets = nil;
      timelineTweets = [[FHSTwitterEngine sharedEngine]getHomeTimelineSinceID:[NSString stringWithFormat:@"%@",[[self.tweets firstObject] valueForKeyPath:@"id"]] count:50];
        dispatch_async(dispatch_get_main_queue(), ^{
        [self.refreshControl endRefreshing];
        NSArray *tempArray = [timelineTweets arrayByAddingObjectsFromArray:self.tweets];
        self.tweets = [tempArray mutableCopy];
      });
    }
  });
}

-(IBAction)fetchOldTweets:(NSString *)id {
  [self.refreshControl beginRefreshing];
  dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
    @autoreleasepool {
      NSMutableArray *timelineTweets = nil;
      timelineTweets = [[FHSTwitterEngine sharedEngine]getHomeTimelineWithMaxID:id count:50];
      [timelineTweets removeObjectAtIndex:0];
      dispatch_async(dispatch_get_main_queue(), ^{
        [self.refreshControl endRefreshing];
        NSArray *tempArray = [self.tweets arrayByAddingObjectsFromArray:timelineTweets];
        self.tweets = [tempArray mutableCopy];
      });
    }
  });
}

-(IBAction)fetchTweets {
  [self.refreshControl beginRefreshing];
  dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
    @autoreleasepool {
      NSArray *timelineTweets = nil;
      timelineTweets = [[FHSTwitterEngine sharedEngine]getHomeTimelineSinceID:@"" count:50];
      NSLog(@"Timeline results : %@", timelineTweets);
      dispatch_async(dispatch_get_main_queue(), ^{
        [self.refreshControl endRefreshing];
        NSArray *tempArray = [self.tweets arrayByAddingObjectsFromArray:timelineTweets];
        self.tweets = [tempArray mutableCopy];
      });
    }
  });
}
@end
