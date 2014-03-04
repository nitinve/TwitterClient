//
//  TweetModalViewController.m
//  TwitterClient
//
//  Created by Nitin Verma on 2/21/14.
//  Copyright (c) 2014 Nitin Verma. All rights reserved.
//

#import "TweetModalViewController.h"
#import "FHSTwitterEngine.h"

@interface TweetModalViewController ()
@property (weak, nonatomic) IBOutlet UIButton *cancelButton;
@property (weak, nonatomic) IBOutlet UITextView *editor;
@property (weak, nonatomic) IBOutlet UIButton *postTweetButton;

@end

@implementation TweetModalViewController

- (void)viewDidLoad {
  [super viewDidLoad];
	[self.cancelButton addTarget:self action:@selector(dismissTweetModal) forControlEvents:UIControlEventTouchDown];
  [self.postTweetButton addTarget:self action:@selector(postTweet) forControlEvents:UIControlEventTouchDown];
}

-(void)dismissTweetModal {
  [self.presentingViewController dismissViewControllerAnimated:YES completion:^{}];
}

-(void)postTweet {
  dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
    @autoreleasepool {
      NSString *tweet = self.editor.text;
      id returned = [[FHSTwitterEngine sharedEngine]postTweet:tweet];
      
      if ([returned isKindOfClass:[NSError class]]) {
        NSError *error = (NSError *)returned;
        NSLog(@"%@",[NSString stringWithFormat:@"Error %d",(int)error.code]);
      } else {
        NSLog(@"%@",returned);
      }
      dispatch_sync(dispatch_get_main_queue(), ^{
        [self dismissTweetModal];
      });
    }
  });
  
  
}

- (void)didReceiveMemoryWarning
{
  [super didReceiveMemoryWarning];
  // Dispose of any resources that can be recreated.
}

@end
