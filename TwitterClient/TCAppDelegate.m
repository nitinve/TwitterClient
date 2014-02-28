//
//  TCAppDelegate.m
//  TwitterClient
//
//  Created by Nitin Verma on 2/17/14.
//  Copyright (c) 2014 Nitin Verma. All rights reserved.
//

#import "TCAppDelegate.h"
#import "TwitterDatabaseAvailability.h"

@interface TCAppDelegate()

@property (copy, nonatomic) void (^twitterDownloadBackgroundURLSessionCompletionHandler)();
@property (strong, nonatomic) UIManagedDocument *managedDocument;
@property (strong, nonatomic) NSManagedObjectContext *twitterDatabaseContext;

@end

@implementation TCAppDelegate

#pragma mark - UIApplicationDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
  self.managedDocument = [self createManagedDocument];
  
  // Override point for customization after application launch.
  return YES;
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
  
  // every time the context changes, we'll restart our timer
  // so kill (invalidate) the current one
  // (we didn't get to this line of code in lecture, sorry!)
  
  if (self.twitterDatabaseContext)
  {
    // this timer will fire only when we are in the foreground
    
    
    // let everyone who might be interested know this context is available
    // this happens very early in the running of our application
    // it would make NO SENSE to listen to this radio station in a View Controller that was segued to, for example
    // (but that's okay because a segued-to View Controller would presumably be "prepared" by being given a context to work in)
    NSDictionary *userInfo = self.twitterDatabaseContext ? @{ TwitterDatabaseAvailabilityContext : self.twitterDatabaseContext } : nil;
    [[NSNotificationCenter defaultCenter] postNotificationName:TwitterDatabaseAvailabilityNotification
                                                        object:self
                                                      userInfo:userInfo];
  }
}


@end
