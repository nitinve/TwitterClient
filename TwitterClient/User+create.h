//
//  User+create.h
//  TwitterClient
//
//  Created by Nitin Verma on 2/28/14.
//  Copyright (c) 2014 Nitin Verma. All rights reserved.
//

#import "User.h"

@interface User (create)

+ (User *)userWithUserInfo:(NSDictionary *)userInfo
       inManagedObjectContext:(NSManagedObjectContext *)context;

+ (void)loadUsersFromUsersArray:(NSArray *)users // of userInfo NSDictionary
           inManagedObjectContext:(NSManagedObjectContext *)context;

@end
