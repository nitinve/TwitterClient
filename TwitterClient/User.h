//
//  User.h
//  TwitterClient
//
//  Created by Nitin Verma on 2/28/14.
//  Copyright (c) 2014 Nitin Verma. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Tweet, User;

@interface User : NSManagedObject

@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSString * screenName;
@property (nonatomic, retain) NSString * profileImageUrl;
@property (nonatomic, retain) NSString * userDescription;
@property (nonatomic, retain) NSSet *tweets;
@property (nonatomic, retain) NSSet *followers;
@property (nonatomic, retain) NSSet *following;
@end

@interface User (CoreDataGeneratedAccessors)

- (void)addTweetsObject:(Tweet *)value;
- (void)removeTweetsObject:(Tweet *)value;
- (void)addTweets:(NSSet *)values;
- (void)removeTweets:(NSSet *)values;

- (void)addFollowersObject:(User *)value;
- (void)removeFollowersObject:(User *)value;
- (void)addFollowers:(NSSet *)values;
- (void)removeFollowers:(NSSet *)values;

- (void)addFollowingObject:(User *)value;
- (void)removeFollowingObject:(User *)value;
- (void)addFollowing:(NSSet *)values;
- (void)removeFollowing:(NSSet *)values;

@end
