//
//  BLCUser.m
//  Blocstagram
//
//  Created by Trevor Ahlert on 8/26/14.
//  Copyright (c) 2014 Trevor Ahlert. All rights reserved.
//

#import "BLCUser.h"

@implementation BLCUser


- (instancetype) initWithDictionary:(NSDictionary *)userDictionary {
    self = [super init];
    
    if (self) {
        self.idNumber = userDictionary[@"id"];
        self.userName = userDictionary[@"username"];
        self.fullName = userDictionary[@"full_name"];
        
        NSString *profileURLString = userDictionary[@"profile_picture"];
        NSURL *profileURL = [NSURL URLWithString:profileURLString];
        
        if (profileURL){
            self.profilePictureURL = profileURL;
        }
        
    }
    return self;
}

@end
