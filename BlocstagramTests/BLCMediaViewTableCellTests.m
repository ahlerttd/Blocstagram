//
//  BLCMediaViewTableCellTests.m
//  Blocstagram
//
//  Created by Trevor Ahlert on 10/4/14.
//  Copyright (c) 2014 Trevor Ahlert. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <XCTest/XCTest.h>
#import "BLCMediaTableViewCell.h"
#import "BLCMedia.h"
#import "BLCComment.h"
#import "BLCUser.h"
#import "BLCComposeCommentView.h"


@interface BLCMediaViewTableCellTests : XCTestCase

@end

@implementation BLCMediaViewTableCellTests

- (void)setUp {
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
}



- (void)testPerformanceExample {
    // This is an example of a performance test case.
    [self measureBlock:^{
        // Put the code you want to measure the time of here.
    }];
}

- (void)testThatInitializationWorks
{

    NSDictionary *testDictionary = @{@"id": @"8675309",
                                     @"url" : @"http://distillery.s3.amazonaws.com/profiles/profile_1242695_75sq_1293915800.jpg",
                                     @"user" :     @{
                                             @"bio" : @"",
                                             @"full_name" : @"Instagram",
                                             @"id" : @"25025320",
                                             @"profile_picture" : @"http://images.ak.instagram.com/profiles/profile_25025320_75sq_1340929272.jpg",
                                             @"username" : @"instagram",
                                         ///@"website"" : @"",
                                     },
                                     
                                     
                                     @"likes" : @{@"count" : @"10"}};
    
    BLCMedia *mediaImage = [[BLCMedia alloc] initWithDictionary:testDictionary];
    
    CGFloat imageSize = [BLCMediaTableViewCell heightForMediaItem:mediaImage width:320];
    NSLog(@"Height for Media Item %2f", imageSize);
    
    XCTAssertEqualObjects(mediaImage.idNumber, testDictionary[@"id"], @"The ID number should be equal");
    XCTAssertTrue(imageSize > 0, @"The height is incorrect");
}




@end
