//
//  BLCComment.h
//  Blocstagram
//
//  Created by Trevor Ahlert on 8/27/14.
//  Copyright (c) 2014 Trevor Ahlert. All rights reserved.
//

#import <Foundation/Foundation.h>

@class BLCUser;

@interface BLCLikeCount : NSObject <NSCoding>

@property (nonatomic, strong) NSString *idNumber;
@property (nonatomic, strong) NSString *count;


- (instancetype) initWithDictionary:(NSDictionary *)likeDictionary;

@end
