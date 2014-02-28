//
//  UITweetCell.h
//  TwitterClient
//
//  Created by Nitin Verma on 2/19/14.
//  Copyright (c) 2014 Nitin Verma. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UITweetCell : UITableViewCell

@property (strong, nonatomic) IBOutlet UILabel *handle;
@property (strong, nonatomic) IBOutlet UILabel *tweetText;

@end
