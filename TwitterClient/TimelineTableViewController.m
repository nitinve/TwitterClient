
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
#import "Tweet+create.h"
#import "TCAppDelegate.h"
#import "Tweet.h"
#import "User.h"
#import "UITweetCell.h"

@interface TimelineTableViewController ()

@property (nonatomic) NSInteger previousRowIndex;
@property (nonatomic) NSString *maxTweetId;
@property (nonatomic) NSString *minTweetId;
@property (nonatomic) NSManagedObjectContext *twitterDatabaseContext;



@end

@implementation TimelineTableViewController

- (void)awakeFromNib {
  
  TCAppDelegate *appDelegate = (TCAppDelegate *) [[UIApplication sharedApplication] delegate];
  if (appDelegate.twitterDatabaseContext != nil) {
    self.twitterDatabaseContext = appDelegate.twitterDatabaseContext;
  }
  
  [[NSNotificationCenter defaultCenter] addObserverForName:TwitterDatabaseAvailabilityNotification
                                                    object:nil
                                                     queue:nil
                                                usingBlock:^(NSNotification *notification) {
                                                  self.twitterDatabaseContext = notification.userInfo[TwitterDatabaseAvailabilityContext];
                                                }];
  
}

- (void)setTwitterDatabaseContext:(NSManagedObjectContext *)twitterDatabaseContext {
  
  _twitterDatabaseContext = twitterDatabaseContext;
  
  NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Tweet"];
  request.predicate = [NSPredicate predicateWithFormat:@"(NOT tweetOwner.screenName LIKE[c] 'nitinverma2510')"];
  request.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"tweetId"
                                                            ascending:NO
                                                             selector:@selector(localizedStandardCompare:)]];
  
  
  
  self.fetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:request
                                                                      managedObjectContext:twitterDatabaseContext
                                                                        sectionNameKeyPath:nil
                                                                                 cacheName:nil];
  [self startFetchingTweets];
  
}

- (void)viewDidLoad {
  [super viewDidLoad];
  UIRefreshControl *refreshControl = [[UIRefreshControl alloc] init];
  [refreshControl addTarget:self action:@selector(startFetchingNewTweets) forControlEvents:UIControlEventValueChanged];
  self.refreshControl = refreshControl;
}

-(void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
  if (!self.previousRowIndex) self.previousRowIndex = indexPath.row;
  else if (self.previousRowIndex < indexPath.row && indexPath.row == [self.tableView numberOfRowsInSection:0]-10) {
    self.previousRowIndex = indexPath.row;
    [self startFetchingOldTweets];
  }
  
}

#pragma mark - Table view delegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
  Tweet *tweet = [self.fetchedResultsController objectAtIndexPath:indexPath];
  NSString *tweetText = tweet.text;
  CGRect r = [tweetText boundingRectWithSize:CGSizeMake(250, 0)
                                     options:NSStringDrawingUsesLineFragmentOrigin
                                  attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:14]}
                                     context:nil];
  return r.size.height + 50;
}

#pragma mark - Table view data source

//- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
//  // Return the number of rows in the section.
//  return [self.tweets count];
//}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
  static NSString *CellIdentifier = @"Tweet Cell";
  UITweetCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
  
  // Configure the cell...
  Tweet *tweet = [self.fetchedResultsController objectAtIndexPath:indexPath];
  
  cell.handle.text = tweet.tweetOwner.screenName ? tweet.tweetOwner.screenName : @"";
  cell.tweetText.text = [TwitterTableViewController htmlEntityDecode:tweet.text];
  return cell;
}


- (IBAction)fetchTweets {
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

#pragma mark - TwitterFetching

- (void)startFetchingTweets
{
  [self.refreshControl beginRefreshing];
  dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
    @autoreleasepool {
      NSArray *timelineTweets = nil;
      timelineTweets = [[FHSTwitterEngine sharedEngine]getHomeTimelineSinceID:@"" count:50];
      self.maxTweetId = (NSString *)((NSDictionary *)[timelineTweets firstObject])[@"id_str"];
      self.minTweetId = (NSString *)((NSDictionary *)[timelineTweets lastObject])[@"id_str"];
//      NSLog(@"Timeline results : %@", timelineTweets);
      [self loadTweetsFromArray:timelineTweets intoContext:self.twitterDatabaseContext];
      dispatch_async(dispatch_get_main_queue(), ^{
        [self.refreshControl endRefreshing];
      });
    }
  });
}

- (IBAction)startFetchingOldTweets {
  [self.refreshControl beginRefreshing];
  dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
    @autoreleasepool {
      NSMutableArray *timelineTweets = nil;
      timelineTweets = [[FHSTwitterEngine sharedEngine]getHomeTimelineWithMaxID:self.minTweetId count:50];
      [timelineTweets removeObjectAtIndex:0];
      NSLog(@"Timeline results : %@", timelineTweets);
      if ([timelineTweets lastObject]) {
        self.minTweetId = (NSString *)((NSDictionary *)[timelineTweets lastObject])[@"id_str"];
      }
      [self loadTweetsFromArray:timelineTweets intoContext:self.twitterDatabaseContext];
      dispatch_async(dispatch_get_main_queue(), ^{
        [self.refreshControl endRefreshing];
      });
    }
  });
}

- (IBAction)startFetchingNewTweets {
  [self.refreshControl beginRefreshing];
  dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
    @autoreleasepool {
      NSMutableArray *timelineTweets = nil;
      timelineTweets = [[FHSTwitterEngine sharedEngine]getHomeTimelineSinceID:self.maxTweetId count:50];
      if ([timelineTweets firstObject]) {
        self.maxTweetId = (NSString *)((NSDictionary *)[timelineTweets firstObject])[@"id_str"];
      }
      [self loadTweetsFromArray:timelineTweets intoContext:self.twitterDatabaseContext];
      dispatch_async(dispatch_get_main_queue(), ^{
        [self.refreshControl endRefreshing];
      });
    }
  });
}


- (void)startFetchingTweets:(NSTimer *)timer {
  [self startFetchingTweets];
}

- (void)loadTweetsFromArray:(NSArray *)tweets
                intoContext:(NSManagedObjectContext *)context {
  if (context) {
    [context performBlock:^{
      [Tweet loadTweetsFromTweetsArray:tweets
                inManagedObjectContext:context];
    }];
  }
}

@end
