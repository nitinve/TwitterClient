//
//  TwitterTableViewController.m
//  TwitterClient
//
//  Created by Nitin Verma on 2/19/14.
//  Copyright (c) 2014 Nitin Verma. All rights reserved.
//


#import "TwitterTableViewController.h"
#import "TweetViewController.h"
#import "UITweetCell.h"
#import "Tweet.h"
#import "User.h"

@interface TwitterTableViewController ()

@end

@implementation TwitterTableViewController

@synthesize tweets = _tweets;

- (void)setTweets:(NSMutableArray *)tweets {
  _tweets = tweets;
  [self.tableView reloadData];
}
- (NSMutableArray *)tweets {
  if (!_tweets) _tweets = [[NSMutableArray alloc] init];
  return _tweets;
}
+ (NSString *)htmlEntityDecode:(NSString *)string {
  string = [string stringByReplacingOccurrencesOfString:@"&quot;" withString:@"\""];
  string = [string stringByReplacingOccurrencesOfString:@"&apos;" withString:@"'"];
  string = [string stringByReplacingOccurrencesOfString:@"&amp;" withString:@"&"];
  string = [string stringByReplacingOccurrencesOfString:@"&lt;" withString:@"<"];
  string = [string stringByReplacingOccurrencesOfString:@"&gt;" withString:@">"];
  
  return string;
}


#pragma mark - Navigation

// In a story board-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
  if ([segue.identifier isEqual:@"Display Tweet"]) {
    if ([sender isKindOfClass:[UITableViewCell class]]) {
      NSIndexPath *indexPath = [self.tableView indexPathForCell:sender];
      if (indexPath) {
        if ([segue.destinationViewController isKindOfClass:[TweetViewController class]]) {
          [self prepareTweetViewController:segue.destinationViewController toDisplayTweet:[self.fetchedResultsController objectAtIndexPath:indexPath]];
        }
      }
    }
  }
}

- (void)prepareTweetViewController:(TweetViewController *)tvc toDisplayTweet:(Tweet *)tweet {
  tvc.tweetDetails = tweet;
}



@end
