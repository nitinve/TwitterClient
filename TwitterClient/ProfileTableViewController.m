//
//  ProfileTableViewController.m
//  TwitterClient
//
//  Created by Nitin Verma on 2/21/14.
//  Copyright (c) 2014 Nitin Verma. All rights reserved.
//

#import "ProfileTableViewController.h"
#import "FHSTwitterEngine.h"

@interface ProfileTableViewController ()
@property (strong, nonatomic) IBOutlet UIView *profileHeader;
@property (strong, nonatomic) IBOutlet UIImageView *profileImage;
@property (strong, nonatomic) IBOutlet UILabel *handle;
@end

@implementation ProfileTableViewController

-(void)scrollViewDidScroll:(UIScrollView *)scrollView {
  
  if (scrollView.contentOffset.y == roundf(scrollView.contentSize.height-scrollView.frame.size.height)) {
    NSLog(@"we are at the endddd");
    [self fetchOldTweets];
    
    //Call your function here...
    
  }
}

-(UIImageView *)profileImage {
  if(!_profileImage) _profileImage = [[UIImageView alloc] init];
  return _profileImage;
}
-(UIView *)profileHeader {
  if(!_profileHeader) _profileHeader = [[UIView alloc] init];
  return _profileHeader;
}

- (void)viewDidLoad
{
  [super viewDidLoad];
  UIRefreshControl *refreshControl = [[UIRefreshControl alloc] init];
  [refreshControl addTarget:self action:@selector(fetchNewTweets) forControlEvents:UIControlEventValueChanged];
  self.refreshControl = refreshControl;
  [self fetchTweets];
  [self fetchProfileImage];
}

-(IBAction)fetchTweets {
  [self.refreshControl beginRefreshing];
  dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
    @autoreleasepool {
      NSArray *timelineTweets = [[FHSTwitterEngine sharedEngine]getTimelineForUser:[[FHSTwitterEngine sharedEngine]authenticatedID] isID:YES count:50];
      
      NSLog(@"Timeline results : %@", timelineTweets);
      dispatch_async(dispatch_get_main_queue(), ^{
        [self.refreshControl endRefreshing];
        NSArray *tempArray = [self.tweets arrayByAddingObjectsFromArray:timelineTweets];
        self.tweets = [tempArray mutableCopy];
      });
    }
  });
}

-(IBAction)fetchNewTweets{
  [self.refreshControl beginRefreshing];
  dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
    @autoreleasepool {
      NSMutableArray *timelineTweets = nil;
      timelineTweets = [[FHSTwitterEngine sharedEngine]getTimelineForUser:[[FHSTwitterEngine sharedEngine]authenticatedID] isID:YES count:50 sinceID:[NSString stringWithFormat:@"%@",[[self.tweets firstObject] valueForKeyPath:@"id"]] maxID:@""];
      //            NSLog(@"Timeline results : %@", timelineTweets);
      dispatch_async(dispatch_get_main_queue(), ^{
        [self.refreshControl endRefreshing];
        NSArray *tempArray = [timelineTweets arrayByAddingObjectsFromArray:self.tweets];
        self.tweets = [tempArray mutableCopy];
      });
    }
  });
}

-(IBAction)fetchOldTweets {
  [self.refreshControl beginRefreshing];
  dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
    @autoreleasepool {
      NSMutableArray *timelineTweets = nil;
      timelineTweets = [[FHSTwitterEngine sharedEngine]getTimelineForUser:[[FHSTwitterEngine sharedEngine]authenticatedID] isID:YES count:50 sinceID:@"" maxID:[NSString stringWithFormat:@"%@",[[self.tweets lastObject] valueForKeyPath:@"id"]]];
      NSLog(@"Timeline results : %@", timelineTweets);
      [timelineTweets removeObjectAtIndex:0];
      dispatch_async(dispatch_get_main_queue(), ^{
        [self.refreshControl endRefreshing];
        NSArray *tempArray = [self.tweets arrayByAddingObjectsFromArray:timelineTweets];
        self.tweets = [tempArray mutableCopy];
      });
    }
  });
}

-(void)fetchProfileImage {
  dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
    @autoreleasepool {
      NSMutableDictionary *store = [[FHSTwitterEngine sharedEngine]getProfileImageAndNameForUserID:[[FHSTwitterEngine sharedEngine]authenticatedID] andSize:FHSTwitterEngineImageSizeBigger];
      dispatch_async(dispatch_get_main_queue(), ^{
        self.profileImage.image = [UIImage imageWithData:[store valueForKeyPath:@"profile_image"]];
        self.handle.text = [store valueForKeyPath:@"name"];
      });
    }
  });
}
@end
