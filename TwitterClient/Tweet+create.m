//
//  Tweet+create.m
//  TwitterClient
//
//  Created by Nitin Verma on 2/28/14.
//  Copyright (c) 2014 Nitin Verma. All rights reserved.
//

#import "Tweet+create.h"
#import "User+create.h"

@implementation Tweet (create)

+ (NSString *)htmlEntityDecode:(NSString *)string
{
  string = [string stringByReplacingOccurrencesOfString:@"&quot;" withString:@"\""];
  string = [string stringByReplacingOccurrencesOfString:@"&apos;" withString:@"'"];
  string = [string stringByReplacingOccurrencesOfString:@"&amp;" withString:@"&"];
  string = [string stringByReplacingOccurrencesOfString:@"&lt;" withString:@"<"];
  string = [string stringByReplacingOccurrencesOfString:@"&gt;" withString:@">"];
  
  return string;
}

+ (Tweet *)tweetWithTweetInfo:(NSDictionary *)tweetInfo
       inManagedObjectContext:(NSManagedObjectContext *)context {
  
  Tweet *tweet = nil;
  
  NSString *tweetId = tweetInfo[@"id_str"];
  NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"Tweet"];
  request.predicate = [NSPredicate predicateWithFormat:@"id = %@", tweetId];
  
  NSError *error;
  NSArray *matches = [context executeFetchRequest:request error:&error];
  
  if (!matches || error || ([matches count] > 1)) {
    // handle error
  } else if ([matches count]) {
    tweet = [matches firstObject];
  } else {
    tweet = [NSEntityDescription insertNewObjectForEntityForName:@"Tweet"
                                          inManagedObjectContext:context];
    tweet.tweetId = tweetId;
    tweet.text = [Tweet htmlEntityDecode:[tweet valueForKeyPath:@"text"]];
    
    NSDictionary *userInfo = [tweetInfo valueForKeyPath:@"user"];
    
    tweet.tweetOwner = [User userWithUserInfo:userInfo
                       inManagedObjectContext:context];
    
  }
  return tweet;
}

+ (void)loadTweetsFromTweetsArray:(NSArray *)tweets
           inManagedObjectContext:(NSManagedObjectContext *)context {
  for (NSDictionary *tweetInfo in tweets) {
    [self tweetWithTweetInfo:tweetInfo inManagedObjectContext:context];
  }
  
}

@end
