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

@interface TCViewController () <FHSTwitterEngineAccessTokenDelegate, UIAlertViewDelegate>
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *spinner;
@property (weak, nonatomic) IBOutlet UIButton *signInButton;

@end

@implementation TCViewController


- (void)viewDidLoad
{
    [super viewDidLoad];
    self.signInButton.hidden = true;
    [self.spinner startAnimating];
    
    [[FHSTwitterEngine sharedEngine]permanentlySetConsumerKey:@"kP9U1BZZxTgWk7hNHXavgw" andSecret:@"S7qaZpgycMPKMARdo6nTQpnq4LbeEQnpBzGnM2mrIMQ"];
    [[FHSTwitterEngine sharedEngine]setDelegate:self];
    [[FHSTwitterEngine sharedEngine]loadAccessToken];
	// Do any additional setup after loading the view, typically from a nib.
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

- (void)storeAccessToken:(NSString *)accessToken {
    [[NSUserDefaults standardUserDefaults]setObject:accessToken forKey:@"SavedAccessHTTPBody"];
}

- (NSString *)loadAccessToken {
    return [[NSUserDefaults standardUserDefaults]objectForKey:@"SavedAccessHTTPBody"];
}

- (void)loginOAuth {
    UIViewController *loginController = [[FHSTwitterEngine sharedEngine]loginControllerWithCompletionHandler:^(BOOL success) {
        NSLog(success?@"L0L success":@"O noes!!! Loggen faylur!!!");
        self.signInButton.hidden = true;
    }];
    [self presentViewController:loginController animated:YES completion:nil];
}

- (IBAction)presentTTBViewController{
    UIStoryboard *storyboard = self.storyboard;
    TTBViewController *twitterTabBar = [storyboard instantiateViewControllerWithIdentifier:@"TTBViewController"];
    
    // Configure the new view controller here.
    
    [self presentViewController:twitterTabBar animated:NO completion:nil];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
