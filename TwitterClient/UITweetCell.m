//
//  UITweetCell.m
//  TwitterClient
//
//  Created by Nitin Verma on 2/19/14.
//  Copyright (c) 2014 Nitin Verma. All rights reserved.
//

#import "UITweetCell.h"

@implementation UITweetCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
  self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
  return self;
}

-(UILabel *)tweetText {
  if (!_tweetText) _tweetText = [[UILabel alloc] init];
  return _tweetText;
}

-(UILabel *)handle {
  if (!_handle) _handle = [[UILabel alloc] init];
  return _handle;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
  [super setSelected:selected animated:animated];
  
  // Configure the view for the selected state
}

@end
