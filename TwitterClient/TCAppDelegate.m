//
//  TCAppDelegate.m
//  TwitterClient
//
//  Created by Nitin Verma on 2/17/14.
//  Copyright (c) 2014 Nitin Verma. All rights reserved.
//

#import "TCAppDelegate.h"
#import "TwitterDatabaseAvailability.h"

@interface TCAppDelegate()<NSURLSessionDownloadDelegate>

@property (copy, nonatomic) void (^tweetDownloadBackgroundURLSessionCompletionHandler)();
@property (strong, nonatomic) NSURLSession *twitterDownloadSession;
@property (strong, nonatomic) NSTimer *twitterForegroundFetchTimer;
@property (strong, nonatomic) UIManagedDocument *managedDocument;
@property (strong, nonatomic) NSManagedObjectContext *twitterDatabaseContext;


@end

// name of the Twitter fetching background download session
#define TWITTER_FETCH @"Twitter Just Uploaded Fetch"

// how often (in seconds) we fetch new photos if we are in the foreground
#define FOREGROUND_TWITTER_FETCH_INTERVAL (5*60)

// how long we'll wait for a Twitter fetch to return when we're in the background
#define BACKGROUND_TWITTER_FETCH_TIMEOUT (10)

@implementation TCAppDelegate

#pragma mark - UIApplicationDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
  [[UIApplication sharedApplication] setMinimumBackgroundFetchInterval:UIApplicationBackgroundFetchIntervalMinimum];
  
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

#pragma mark - NSURLSessionDownloadDelegate

// required by the protocol
- (void)URLSession:(NSURLSession *)session
      downloadTask:(NSURLSessionDownloadTask *)downloadTask
didFinishDownloadingToURL:(NSURL *)localFile
{
  // we shouldn't assume we're the only downloading going on ...
  if ([downloadTask.taskDescription isEqualToString:TWITTER_FETCH]) {
    // ... but if this is the Flickr fetching, then process the returned data
//    [self loadTweetsFromLocalURL:localFile
//                           intoContext:self.twitterDatabaseContext
//                   andThenExecuteBlock:^{
//                     [self tweetDownloadTasksMightBeComplete];
//                   }
//     ];
  }
}

// required by the protocol
- (void)URLSession:(NSURLSession *)session
      downloadTask:(NSURLSessionDownloadTask *)downloadTask
 didResumeAtOffset:(int64_t)fileOffset
expectedTotalBytes:(int64_t)expectedTotalBytes
{
  // we don't support resuming an interrupted download task
}

// required by the protocol
- (void)URLSession:(NSURLSession *)session
      downloadTask:(NSURLSessionDownloadTask *)downloadTask
      didWriteData:(int64_t)bytesWritten
 totalBytesWritten:(int64_t)totalBytesWritten
totalBytesExpectedToWrite:(int64_t)totalBytesExpectedToWrite
{
  // we don't report the progress of a download in our UI, but this is a cool method to do that with
}

// not required by the protocol, but we should definitely catch errors here
// so that we can avoid crashes
// and also so that we can detect that download tasks are (might be) complete
- (void)URLSession:(NSURLSession *)session task:(NSURLSessionTask *)task didCompleteWithError:(NSError *)error
{
  if (error && (session == self.twitterDownloadSession)) {
    NSLog(@"Twitter background download session failed: %@", error.localizedDescription);
    [self tweetDownloadTasksMightBeComplete];
  }
}

// this is "might" in case some day we have multiple downloads going on at once

- (void)tweetDownloadTasksMightBeComplete
{
  if (self.tweetDownloadBackgroundURLSessionCompletionHandler) {
    [self.twitterDownloadSession getTasksWithCompletionHandler:^(NSArray *dataTasks, NSArray *uploadTasks, NSArray *downloadTasks) {
      // we're doing this check for other downloads just to be theoretically "correct"
      //  but we don't actually need it (since we only ever fire off one download task at a time)
      // in addition, note that getTasksWithCompletionHandler: is ASYNCHRONOUS
      //  so we must check again when the block executes if the handler is still not nil
      //  (another thread might have sent it already in a multiple-tasks-at-once implementation)
      if (![downloadTasks count]) {  // any more Flickr downloads left?
        // nope, then invoke flickrDownloadBackgroundURLSessionCompletionHandler (if it's still not nil)
        void (^completionHandler)() = self.tweetDownloadBackgroundURLSessionCompletionHandler;
        self.tweetDownloadBackgroundURLSessionCompletionHandler = nil;
        if (completionHandler) {
          completionHandler();
        }
      } // else other downloads going, so let them call this method when they finish
    }];
  }
}



@end
