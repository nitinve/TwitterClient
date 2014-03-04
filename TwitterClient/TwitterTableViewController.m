//
//  TwitterTableViewController.m
//  TwitterClient
//
//  Created by Nitin Verma on 2/19/14.
//  Copyright (c) 2014 Nitin Verma. All rights reserved.
//


#import "TwitterTableViewController.h"
#import "TweetViewController.h"

@interface TwitterTableViewController ()

@end

#define CELL_WIDTH 250
#define VERTICAL_CELL_MARGIN 50

@implementation TwitterTableViewController

+ (NSString *)htmlEntityDecode:(NSString *)string {
  string = [string stringByReplacingOccurrencesOfString:@"&quot;" withString:@"\""];
  string = [string stringByReplacingOccurrencesOfString:@"&apos;" withString:@"'"];
  string = [string stringByReplacingOccurrencesOfString:@"&amp;" withString:@"&"];
  string = [string stringByReplacingOccurrencesOfString:@"&lt;" withString:@"<"];
  string = [string stringByReplacingOccurrencesOfString:@"&gt;" withString:@">"];
  
  return string;
}

#pragma mark - Table view data source

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
  Tweet *tweet = [self.fetchedResultsController objectAtIndexPath:indexPath];
  NSString *tweetText = tweet.text;
  CGRect r = [tweetText boundingRectWithSize:CGSizeMake(CELL_WIDTH, 0)
                                     options:NSStringDrawingUsesLineFragmentOrigin
                                  attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:14]}
                                     context:nil];
  return r.size.height + VERTICAL_CELL_MARGIN;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
  static NSString *CellIdentifier = @"Tweet Cell";
  UITweetCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
  
  // Configure the cell...
  Tweet *tweet = [self.fetchedResultsController objectAtIndexPath:indexPath];
  
  cell.handle.text = tweet.tweetOwner.screenName ? tweet.tweetOwner.screenName : @"";
  cell.tweetText.text = [TwitterTableViewController htmlEntityDecode:tweet.text];
  return cell;
}

#pragma mark - Navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
  if ([segue.identifier isEqual:@"Display Tweet"]) {
    if ([sender isKindOfClass:[UITableViewCell class]]) {
      NSIndexPath *indexPath = [self.tableView indexPathForCell:sender];
      if (indexPath) {
        if ([segue.destinationViewController isKindOfClass:[TweetViewController class]]) {
          [self prepareTweetViewController:segue.destinationViewController
                            toDisplayTweet:[self.fetchedResultsController
                                            objectAtIndexPath:indexPath]];
        }
      }
    }
  }
}

- (void)prepareTweetViewController:(TweetViewController *)tvc toDisplayTweet:(Tweet *)tweet {
  tvc.tweetDetails = tweet;
}



@end
