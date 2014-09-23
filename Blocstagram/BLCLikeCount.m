//
//  BLCComment.m
//  Blocstagram
//
//  Created by Trevor Ahlert on 8/27/14.
//  Copyright (c) 2014 Trevor Ahlert. All rights reserved.
//

#import "BLCLikeCount.h"
#import "BLCUser.h"

@implementation BLCLikeCount

- (instancetype) initWithDictionary:(NSDictionary *)likeDictionary {
    self = [super init];
    
    if (self) {
        self.idNumber = likeDictionary[@"id"];
        self.count = likeDictionary[@"count"];
        
    }
    
    return self;
}

#pragma mark - NSCoding

- (instancetype) initWithCoder:(NSCoder *)aDecoder {
    self = [super init];
    
    if (self) {
        self.idNumber = [aDecoder decodeObjectForKey:NSStringFromSelector(@selector(idNumber))];
        self.count = [aDecoder decodeObjectForKey:NSStringFromSelector(@selector(count))];
    }
    
    return self;
}

- (void) encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodeObject:self.idNumber forKey:NSStringFromSelector(@selector(idNumber))];
    [aCoder encodeObject:self.count forKey:NSStringFromSelector(@selector(count))];
}

@end
