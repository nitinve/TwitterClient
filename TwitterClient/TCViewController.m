//
//  TCViewController.m
//  TwitterClient
//
//  Created by Nitin Verma on 2/17/14.
//  Copyright (c) 2014 Nitin Verma. All rights reserved.
//

// consumer key : kP9U1BZZxTgWk7hNHXavgw
// secret : S7qaZpgycMPKMARdo6nTQpnq4LbeEQnpBzGnM2mrIMQ

#import "TCViewController.h"
#import "FHSTwitterEngine.h"
#import "TTBViewController.h"

@interface TCViewController () <UIAlertViewDelegate>
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *spinner;
@property (weak, nonatomic) IBOutlet UIButton *signInButton;

@end

@implementation TCViewController

- (void)viewDidLoad
{
  [super viewDidLoad];
  self.signInButton.hidden = true;
  [self.spinner startAnimating];
}

- (void)viewDidAppear:(BOOL)animated
{
  if (![[FHSTwitterEngine sharedEngine] isAuthorized]) {
    self.signInButton.hidden = false;
    [self.signInButton addTarget:self action:@selector(loginOAuth) forControlEvents:UIControlEventTouchUpInside];
    [self.spinner stopAnimating];
    
  } else {
    [self presentTTBViewController];
    [self.spinner stopAnimating];
    
  }
}
- (void)loginOAuth {
  UIViewController *loginController = [[FHSTwitterEngine sharedEngine]loginControllerWithCompletionHandler:^(BOOL success) {
    NSMutableDictionary *profile = [[FHSTwitterEngine sharedEngine]getProfileImageAndNameForUserID:[[FHSTwitterEngine sharedEngine]authenticatedID] andSize:FHSTwitterEngineImageSizeBigger];
    [[NSUserDefaults standardUserDefaults] setValuesForKeysWithDictionary:profile];
    self.signInButton.hidden = true;
  }];
  [self presentViewController:loginController animated:YES completion:nil];
}

- (IBAction)presentTTBViewController{
  UIStoryboard *storyboard = self.storyboard;
  TTBViewController *twitterTabBar = [storyboard instantiateViewControllerWithIdentifier:@"TTBViewController"];
  [self presentViewController:twitterTabBar animated:NO completion:nil];
}

@end
