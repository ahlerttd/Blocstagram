//
//  BLCComposeCommentViewTests.m
//  Blocstagram
//
//  Created by Trevor Ahlert on 10/4/14.
//  Copyright (c) 2014 Trevor Ahlert. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <XCTest/XCTest.h>
#import "BLCComposeCommentView.h"


@interface BLCComposeCommentViewTests : XCTestCase

@end

@implementation BLCComposeCommentViewTests

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

- (void)testThatSetYesTextWorks
{
    BLCComposeCommentView *testComment = [[BLCComposeCommentView alloc] init];
    testComment.text = @"comment";
    XCTAssertTrue(testComment.isWritingComment == YES, @"Error in SetText Comment");
}


- (void)testThatSetNoTextWorks
{
    BLCComposeCommentView *testNoComment = [[BLCComposeCommentView alloc] init];
    testNoComment.text = @"";
    XCTAssertFalse(testNoComment.isWritingComment == YES, @"Error in SetText No Comment");
}

@end
