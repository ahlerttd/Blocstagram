//
//  BLCMediaTests.m
//  Blocstagram
//
//  Created by Trevor Ahlert on 10/4/14.
//  Copyright (c) 2014 Trevor Ahlert. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <XCTest/XCTest.h>
#import "BLCMedia.h"

@interface BLCMediaTests : XCTestCase

@end

@implementation BLCMediaTests

- (void)setUp {
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)testPerformanceExample {
    // This is an example of a performance test case.
    [self measureBlock:^{
        // Put the code you want to measure the time of here.
    }];
}

- (void)testThatMediaInitializationWorks
{
    NSDictionary *testDictionary = @{@"id": @"8675309",
                                     @"url" : @"http://distillery.s3.amazonaws.com/profiles/profile_1242695_75sq_1293915800.jpg",
                                     @"likes" : @{@"count" : @"10"}};
    
    BLCMedia *testMedia = [[BLCMedia alloc] initWithDictionary:testDictionary];
    
    XCTAssertEqualObjects(testMedia.idNumber, testDictionary[@"id"], @"The ID number should be equal");
    XCTAssertEqualObjects(testMedia.mediaURL, testDictionary[@"images"][@"standard_resolution"][@"url"], @"The URL should be equal");
    XCTAssertEqualObjects(testMedia.likeCount, testDictionary[@"likes"][@"count"], @"The likes should be equal");
}


@end
