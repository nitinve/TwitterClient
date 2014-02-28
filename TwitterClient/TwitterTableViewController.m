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

@interface TwitterTableViewController ()

@end

@implementation TwitterTableViewController

@synthesize tweets = _tweets;

-(void)setTweets:(NSMutableArray *)tweets {
    _tweets = tweets;
    [self.tableView reloadData];
}
-(NSMutableArray *)tweets {
    if (!_tweets) _tweets = [[NSMutableArray alloc] init];
    return _tweets;
}

+(NSString *)htmlEntityDecode:(NSString *)string
{
    string = [string stringByReplacingOccurrencesOfString:@"&quot;" withString:@"\""];
    string = [string stringByReplacingOccurrencesOfString:@"&apos;" withString:@"'"];
    string = [string stringByReplacingOccurrencesOfString:@"&amp;" withString:@"&"];
    string = [string stringByReplacingOccurrencesOfString:@"&lt;" withString:@"<"];
    string = [string stringByReplacingOccurrencesOfString:@"&gt;" withString:@">"];
    
    return string;
}

#pragma mark - Table view delegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSDictionary *tweet = self.tweets[indexPath.row];
    NSString *tweetText = [tweet valueForKeyPath:@"text"];
    CGRect r = [tweetText boundingRectWithSize:CGSizeMake(250, 0)
                                  options:NSStringDrawingUsesLineFragmentOrigin
                               attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:14]}
                                  context:nil];
    return r.size.height + 50;
}

#pragma mark - Table view data source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return [self.tweets count];
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Tweet Cell";
    UITweetCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    
    // Configure the cell...
    NSDictionary *tweet = self.tweets[indexPath.row];
    
    cell.handle.text = [[tweet valueForKeyPath:@"user"] valueForKeyPath:@"screen_name"];
    cell.tweetText.text = [TwitterTableViewController htmlEntityDecode:[tweet valueForKeyPath:@"text"]];
    return cell;
}
-(void)prepareTweetViewController:(TweetViewController *)tvc toDisplayTweet:(NSDictionary *)tweet {
    tvc.tweetDetails = tweet;
}

#pragma mark - Navigation

// In a story board-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    //    // Pass the selected object to the new view controller.
    if ([segue.identifier isEqual:@"Display Tweet"]) {
        if ([sender isKindOfClass:[UITableViewCell class]]) {
            NSIndexPath *indexPath = [self.tableView indexPathForCell:sender];
            if (indexPath) {
                if ([segue.destinationViewController isKindOfClass:[TweetViewController class]]) {
                    [self prepareTweetViewController:segue.destinationViewController toDisplayTweet:self.tweets[indexPath.row]];
                }
            }
        }
    }
    
    
}


@end
