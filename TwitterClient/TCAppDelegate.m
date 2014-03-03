//
//  TCAppDelegate.m
//  TwitterClient
//
//  Created by Nitin Verma on 2/17/14.
//  Copyright (c) 2014 Nitin Verma. All rights reserved.
//

#import "TCAppDelegate.h"
#import "TwitterDatabaseAvailability.h"
#import "Tweet+create.h"
#import "User+create.h"
#import "FHSTwitterEngine.h"

@interface TCAppDelegate()<FHSTwitterEngineAccessTokenDelegate>
@property (strong, nonatomic) UIManagedDocument *managedDocument;
@end

@implementation TCAppDelegate

#pragma mark - UIApplicationDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
  [[FHSTwitterEngine sharedEngine]permanentlySetConsumerKey:@"kP9U1BZZxTgWk7hNHXavgw"
                                                  andSecret:@"S7qaZpgycMPKMARdo6nTQpnq4LbeEQnpBzGnM2mrIMQ"];
  [[FHSTwitterEngine sharedEngine]setDelegate:self];
  [[FHSTwitterEngine sharedEngine]loadAccessToken];
  
  [[UIApplication sharedApplication] setMinimumBackgroundFetchInterval:UIApplicationBackgroundFetchIntervalMinimum];
  
  self.managedDocument = [self createManagedDocument];
  
  //  [self startFetchingTweets];
  
  // Override point for customization after application launch.
  return YES;
}

#pragma mark - FHSTwitterDelegate

- (void)storeAccessToken:(NSString *)accessToken {
  [[NSUserDefaults standardUserDefaults]setObject:accessToken forKey:@"SavedAccessHTTPBody"];
}

- (NSString *)loadAccessToken {
  return [[NSUserDefaults standardUserDefaults]objectForKey:@"SavedAccessHTTPBody"];
}

#pragma mark - coreData

- (UIManagedDocument *) createManagedDocument {
  
  NSFileManager *fileManager = [NSFileManager defaultManager];
  NSURL *documentsDirectory = [[fileManager URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] firstObject];
  NSString *documentName = @"twitterDatabaseDocument";
  NSURL *url = [documentsDirectory URLByAppendingPathComponent:documentName];
  UIManagedDocument *managedDocument = [[UIManagedDocument alloc] initWithFileURL:url];
  
  BOOL fileExists = [[NSFileManager defaultManager] fileExistsAtPath:[url path]];
  
  if( fileExists) {
    [managedDocument openWithCompletionHandler:^(BOOL success){
      if (!success) {
        // Handle the error.
      } else {
        [self documentIsReady];
      }
    }];
  } else {
    [managedDocument saveToURL:url forSaveOperation:UIDocumentSaveForCreating completionHandler:^(BOOL success){
      if (!success) {
        // Handle the error.
      } else {
        [self documentIsReady];
      }
    }];
    
  }
  return managedDocument;
  
}

- (void) documentIsReady {
  if (self.managedDocument.documentState == UIDocumentStateNormal) {
    self.twitterDatabaseContext = self.managedDocument.managedObjectContext;
  }
}

#pragma mark - database context

- (void) setTwitterDatabaseContext:(NSManagedObjectContext *)twitterDatabaseContext {
  _twitterDatabaseContext = twitterDatabaseContext;
  
  if (self.twitterDatabaseContext)
  {
    NSDictionary *userInfo = self.twitterDatabaseContext ? @{ TwitterDatabaseAvailabilityContext : self.twitterDatabaseContext } : nil;
    [[NSNotificationCenter defaultCenter] postNotificationName:TwitterDatabaseAvailabilityNotification
                                                        object:self
                                                      userInfo:userInfo];
  }
}

@end
