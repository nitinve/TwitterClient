//
//  Tweet.h
//  TwitterClient
//
//  Created by Nitin Verma on 2/28/14.
//  Copyright (c) 2014 Nitin Verma. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class User;

@interface Tweet : NSManagedObject

@property (nonatomic, retain) NSString * text;
@property (nonatomic, retain) NSString * tweetId;
@property (nonatomic, retain) User *tweetOwner;

@end
