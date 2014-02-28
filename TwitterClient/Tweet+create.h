//
//  Tweet+create.h
//  TwitterClient
//
//  Created by Nitin Verma on 2/28/14.
//  Copyright (c) 2014 Nitin Verma. All rights reserved.
//

#import "Tweet.h"

@interface Tweet (create)

+ (Tweet *)tweetWithTweetInfo:(NSDictionary *)tweetInfo
       inManagedObjectContext:(NSManagedObjectContext *)context;

+ (void)loadTweetsFromTweetsArray:(NSArray *)tweets // of tweetInfo NSDictionary
           inManagedObjectContext:(NSManagedObjectContext *)context;

@end
