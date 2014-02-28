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
@property (strong, nonatomic) IBOutlet UIImageView *avatar;
@property (strong, nonatomic) UIImage *image;

@end

@implementation TweetViewController

+(NSString *)htmlEntityDecode:(NSString *)string
{
    string = [string stringByReplacingOccurrencesOfString:@"&quot;" withString:@"\""];
    string = [string stringByReplacingOccurrencesOfString:@"&apos;" withString:@"'"];
    string = [string stringByReplacingOccurrencesOfString:@"&amp;" withString:@"&"];
    string = [string stringByReplacingOccurrencesOfString:@"&lt;" withString:@"<"];
    string = [string stringByReplacingOccurrencesOfString:@"&gt;" withString:@">"];
    
    return string;
}

-(UIImageView *)avatar {
    if(!_avatar) _avatar = [[UIImageView alloc] init];
    return _avatar;
}

-(UIImage *)image {
    return self.avatar.image;
}

-(void)setImage:(UIImage *)image {
    self.avatar.image = image;
}

-(void) viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self updateUI:self.tweetDetails];
}

- (void) setTweetDetails:(NSDictionary *)tweetDetails {
    _tweetDetails = tweetDetails;
    [self fetchImage];
    if (self.view.window) [self updateUI:tweetDetails];
    
}

- (void)updateUI : (NSDictionary *)tweetDetails {
    self.twitterHandle.text = [NSString stringWithFormat:@"%@",[[tweetDetails valueForKeyPath:@"user"] valueForKeyPath:@"screen_name"]];
    self.tweetText.text = [TweetViewController htmlEntityDecode:[NSString stringWithFormat:@"%@",[tweetDetails valueForKeyPath:@"text"]]];
    if (self.image) self.avatar.image = self.image;
}

- (void)fetchImage {
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:[[self.tweetDetails valueForKeyPath:@"user"] valueForKeyPath:@"profile_image_url"]]];
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

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
}


@end
