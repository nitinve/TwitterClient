//
//  User+create.m
//  TwitterClient
//
//  Created by Nitin Verma on 2/28/14.
//  Copyright (c) 2014 Nitin Verma. All rights reserved.
//

#import "User+create.h"

@implementation User (create)

+(User *)userWithUserInfo:(NSDictionary *)userInfo
   inManagedObjectContext:(NSManagedObjectContext *)context {
  
  NSString *twitterHandle = [userInfo valueForKeyPath:@"screen_name"];
  NSString *twitterName = [userInfo valueForKeyPath:@"name"];
  NSString *profileImageUrl = [userInfo valueForKeyPath:@"profile_image_url"];
  NSString *description = [userInfo valueForKeyPath:@"description"];
  
  User *user = nil;
  
  if ([userInfo count]) {
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"User"];
    request.predicate = [NSPredicate predicateWithFormat:@"screenName = %@", twitterHandle];
    
    NSError *error;
    NSArray *matches = [context executeFetchRequest:request error:&error];
    
    if (!matches || ([matches count] > 1)) {
      // handle error
    } else if (![matches count]) {
      user = [NSEntityDescription insertNewObjectForEntityForName:@"User"
                                           inManagedObjectContext:context];
      user.name = twitterName;
      user.screenName = twitterHandle;
      user.profileImageUrl = profileImageUrl;
      user.userDescription = description;
      
    } else {
      user = [matches lastObject];
    }
  }
  
  return user;
  
}

+ (void)loadUsersFromUsersArray:(NSArray *)users
         inManagedObjectContext:(NSManagedObjectContext *)context {
  for (NSDictionary *userInfo in users) {
    [self userWithUserInfo:userInfo inManagedObjectContext:context];
  }
}

@end
