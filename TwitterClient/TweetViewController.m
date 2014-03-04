//
//  TweetViewController.m
//  TwitterClient
//
//  Created by Nitin Verma on 2/19/14.
//  Copyright (c) 2014 Nitin Verma. All rights reserved.
//

#import "TweetViewController.h"
#import "FHSTwitterEngine.h"

@interface TweetViewController ()
@property (weak, nonatomic) IBOutlet UILabel *twitterHandle;
@property (weak, nonatomic) IBOutlet UITextView *tweetText;
@property (strong, nonatomic) IBOutlet UIImageView *imageView;
@property (strong, nonatomic) UIImage *image;

@end

@implementation TweetViewController

+ (NSString *)htmlEntityDecode:(NSString *)string
{
  string = [string stringByReplacingOccurrencesOfString:@"&quot;" withString:@"\""];
  string = [string stringByReplacingOccurrencesOfString:@"&apos;" withString:@"'"];
  string = [string stringByReplacingOccurrencesOfString:@"&amp;" withString:@"&"];
  string = [string stringByReplacingOccurrencesOfString:@"&lt;" withString:@"<"];
  string = [string stringByReplacingOccurrencesOfString:@"&gt;" withString:@">"];
  
  return string;
}

- (UIImageView *)imageView {
  if(!_imageView) _imageView = [[UIImageView alloc] init];
  return _imageView;
}

- (UIImage *)image {
  return self.imageView.image;
}

- (void)setImage:(UIImage *)image {
  self.imageView.image = image;
}

- (void)viewWillAppear:(BOOL)animated {
  [super viewWillAppear:animated];
  [self updateUI:self.tweetDetails];
}

- (void)setTweetDetails:(Tweet *)tweetDetails {
  _tweetDetails = tweetDetails;
  [self fetchImage];
  if (self.view.window) [self updateUI:tweetDetails];
}

- (void)updateUI:(Tweet *)tweetDetails {
  self.twitterHandle.text = [NSString stringWithFormat:@"%@",tweetDetails.tweetOwner.screenName];
  self.tweetText.text = [TweetViewController htmlEntityDecode:[NSString stringWithFormat:@"%@",tweetDetails.text]];
  if (self.image) self.imageView.image = self.image;
}

- (void)fetchImage {
  NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:self.tweetDetails.tweetOwner.profileImageUrl]];
  NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration ephemeralSessionConfiguration];
  NSURLSession *session = [NSURLSession sessionWithConfiguration:configuration];
  NSURLSessionTask *task = [session downloadTaskWithRequest:request
                                          completionHandler:^(NSURL *location, NSURLResponse *response, NSError *error) {
                                            if(!error) {
                                              UIImage *image = [UIImage imageWithData:[NSData dataWithContentsOfURL:location]];
                                              dispatch_async(dispatch_get_main_queue(), ^{self.image = image;});
                                            }
                                          }];
  [task resume];
}

- (void)viewDidLoad {
  [super viewDidLoad];
	// Do any additional setup after loading the view.
}


@end
