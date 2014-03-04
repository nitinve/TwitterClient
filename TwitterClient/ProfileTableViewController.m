//
//  ProfileTableViewController.m
//  TwitterClient
//
//  Created by Nitin Verma on 2/21/14.
//  Copyright (c) 2014 Nitin Verma. All rights reserved.
//

#import "ProfileTableViewController.h"

@interface ProfileTableViewController ()
@property (nonatomic) NSInteger *previousRowIndex;
@property (strong, nonatomic) IBOutlet UIView *profileHeader;
@property (strong, nonatomic) IBOutlet UIImageView *profileImage;
@property (strong, nonatomic) IBOutlet UILabel *handle;
@property (strong, nonatomic) NSManagedObjectContext *twitterDatabaseContext;
@property (strong, nonatomic) NSString *maxTweetId;
@property (strong, nonatomic) NSString *minTweetId;
@property (strong, nonatomic) NSTimer *profileForegroundFetchTimer;
@end

#define FOREGROUND_PROFILE_FETCH_INTERVAL (5*60)

@implementation ProfileTableViewController

- (UIImageView *)profileImage {
  if(!_profileImage) _profileImage = [[UIImageView alloc] init];
  return _profileImage;
}
- (UIView *)profileHeader {
  if(!_profileHeader) _profileHeader = [[UIView alloc] init];
  return _profileHeader;
}

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
  
  [[NSNotificationCenter defaultCenter] addObserverForName:UIApplicationWillEnterForegroundNotification
                                                    object:nil
                                                     queue:nil
                                                usingBlock:^(NSNotification *notification) {
                                                  [self startFetchingTweets];
                                                }];
  
}

- (void)setTwitterDatabaseContext:(NSManagedObjectContext *)twitterDatabaseContext {
  _twitterDatabaseContext = twitterDatabaseContext;
  
  NSString *screenName = [[NSUserDefaults standardUserDefaults] valueForKeyPath:@"screen_name"];
  NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Tweet"];
  request.predicate = [NSPredicate predicateWithFormat:@"(tweetOwner.screenName LIKE[c] %@)", screenName];
  request.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"tweetId"
                                                            ascending:NO
                                                             selector:@selector(localizedStandardCompare:)]];
  
  
  
  self.fetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:request
                                                                      managedObjectContext:twitterDatabaseContext
                                                                        sectionNameKeyPath:nil
                                                                                 cacheName:nil];
  
  if (self.twitterDatabaseContext) {
    self.profileForegroundFetchTimer = [NSTimer scheduledTimerWithTimeInterval:FOREGROUND_PROFILE_FETCH_INTERVAL
                                                                        target:self
                                                                      selector:@selector(startFetchingNewTweets:)
                                                                      userInfo:nil
                                                                       repeats:YES];
  }
  [self startFetchingTweets];
}

- (void)viewDidLoad {
  [super viewDidLoad];
  UIRefreshControl *refreshControl = [[UIRefreshControl alloc] init];
  [refreshControl addTarget:self
                     action:@selector(startFetchingNewTweets)
           forControlEvents:UIControlEventValueChanged];
  self.refreshControl = refreshControl;
  self.profileImage.image = [UIImage imageWithData:[[NSUserDefaults standardUserDefaults] valueForKeyPath:@"profile_image"]];
  self.handle.text = [[NSUserDefaults standardUserDefaults] valueForKeyPath:@"name"];
  [self fetchProfileImage];
}

#pragma mark - Table view delegate

-(void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
  if (!self.previousRowIndex) self.previousRowIndex = (NSInteger *)indexPath.row;
  else if ((int)self.previousRowIndex < indexPath.row && indexPath.row == [self.tableView numberOfRowsInSection:0]-10) {
    self.previousRowIndex = (NSInteger *)indexPath.row;
    [self startFetchingOldTweets];
  }
}

#pragma mark - TwitterFetching

- (void)startFetchingNewTweets:(NSTimer *)timer {
  [self startFetchingNewTweets];
}

- (void)startFetchingTweets
{
  [self.refreshControl beginRefreshing];
  dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
    @autoreleasepool {
      NSArray *timelineTweets = nil;
      timelineTweets = [[FHSTwitterEngine sharedEngine]getTimelineForUser:
                        [[FHSTwitterEngine sharedEngine]authenticatedID] isID:YES count:50];
      self.maxTweetId = (NSString *)((NSDictionary *)[timelineTweets firstObject])[@"id_str"];
      self.minTweetId = (NSString *)((NSDictionary *)[timelineTweets lastObject])[@"id_str"];
      NSLog(@"Profile tweet results : %@", timelineTweets);
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
      timelineTweets = [[FHSTwitterEngine sharedEngine]getTimelineForUser:[[FHSTwitterEngine sharedEngine]authenticatedID]
                                                                     isID:YES
                                                                    count:50
                                                                  sinceID:@""
                                                                    maxID:self.minTweetId];
      [timelineTweets removeObjectAtIndex:0];
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
      timelineTweets = [[FHSTwitterEngine sharedEngine]getTimelineForUser:[[FHSTwitterEngine sharedEngine]authenticatedID]
                                                                     isID:YES
                                                                    count:50
                                                                  sinceID:self.maxTweetId
                                                                    maxID:@""];
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

- (void)loadTweetsFromArray:(NSArray *)tweets
                intoContext:(NSManagedObjectContext *)context {
  if (context) {
    [context performBlock:^{
      [Tweet loadTweetsFromTweetsArray:tweets
                inManagedObjectContext:context];
    }];
  }
}

- (void)fetchProfileImage {
  dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
    @autoreleasepool {
      NSMutableDictionary *store = [[FHSTwitterEngine sharedEngine]getProfileImageAndNameForUserID:[[FHSTwitterEngine sharedEngine]authenticatedID] andSize:FHSTwitterEngineImageSizeBigger];
      [[NSUserDefaults standardUserDefaults] setValuesForKeysWithDictionary:store];
      dispatch_async(dispatch_get_main_queue(), ^{
        self.profileImage.image = [UIImage imageWithData:[store valueForKeyPath:@"profile_image"]];
        self.handle.text = [store valueForKeyPath:@"name"];
      });
    }
  });
}


@end
