//
//  AZReflection.m
//  OSReflectionKitExample
//
//  Created by Alexandre on 18/02/14.
//  Copyright (c) 2014 iAOS Software. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "AZReflection.h"
#import "TestModel.h"

@interface AZReflectionTests : XCTestCase

@end

@implementation AZReflectionTests

- (void)setUp
{
    [super setUp];
    // Put setup code here; it will be run once, before the first test case.
}

- (void)tearDown
{
    // Put teardown code here; it will be run once, after the last test case.
    [super tearDown];
}

#pragma mark - Tests

- (void)testSharedReflectionMappe
{
    AZReflection *reflectionMapper = [AZReflection sharedReflectionMapper];
    
    XCTAssertNotNil(reflectionMapper, @"+[AZReflection sharedReflectionMapper] should not return nil");
    XCTAssertTrue([reflectionMapper isKindOfClass:[AZReflection class]], @"+[AZReflection sharedReflectionMapper] should return an AZReflection instance");
    XCTAssertTrue(reflectionMapper == [AZReflection sharedReflectionMapper], @"+[AZReflection sharedReflectionMapper] should return the same AZReflection instance");
}

- (void) testMapping
{
    AZReflection *reflectionMapper = [AZReflection sharedReflectionMapper];
    
    NSError *error = nil;
    TestModel *model = [[TestModel alloc] init];
    BOOL success = [reflectionMapper mapObject:model withDictionary:[TestModel mockDictionary] rootClass:[TestModel class] error:&error];
    XCTAssertTrue(success, @"Mapping should return true for success");
    
    XCTAssertNotNil(model, @"Mapping should return a new object instance");
    XCTAssertTrue([model isKindOfClass:[TestModel class]], @"Mapping should return a new object instance of the TestModel class");
    XCTAssertEqualObjects(model.string, @"Testing String...", @"model.string should be equal to 'Testing String...'");
    XCTAssertEqualObjects(model.number, @(10), @"model.number should be equal to '10'");
    NSArray *array = @[@(1), @(2), @(3), @(4), @(5)];
    XCTAssertEqualObjects(model.array, array, @"model.array should be equal to '[1, 2, 3, 4, 5]'");
    NSSet *set = [NSSet setWithArray:@[@(2), @(3), @(4)]];
    XCTAssertEqualObjects(model.set, set, @"model.set should be equal to '[2, 3, 4]'");
    NSDictionary *dictionary = @{@"stringTestKey":@"testValue", @"numberTestKey":@(5.3)};
    XCTAssertEqualObjects(model.dict, dictionary, @"model.dict should be equal to '{\"stringTestKey\":\"testValue\", \"numberTestKey\":5.3}'");
    
    XCTAssertEqual(model.integer, 20, @"model.integer should be equal to '20'");
    XCTAssertEqual(model.floating, 4.53, @"model.floating should be equal to '4.53'");
}

- (void) testObjectInstantiation
{
    AZReflection *reflectionMapper = [AZReflection sharedReflectionMapper];
    
    NSError *error = nil;
    TestModel *model = [reflectionMapper reflectionMapWithDictionary:[TestModel mockDictionary] rootClass:[TestModel class] error:&error];

    XCTAssertNotNil(model, @"Mapping should return a new object instance");
    XCTAssertTrue([model isKindOfClass:[TestModel class]], @"Mapping should return a new object instance of the TestModel class");
    XCTAssertEqualObjects(model.string, @"Testing String...", @"model.string should be equal to 'Testing String...'");
    XCTAssertEqualObjects(model.number, @(10), @"model.number should be equal to '10'");
    NSArray *array = @[@(1), @(2), @(3), @(4), @(5)];
    XCTAssertEqualObjects(model.array, array, @"model.array should be equal to '[1, 2, 3, 4, 5]'");
    NSSet *set = [NSSet setWithArray:@[@(2), @(3), @(4)]];
    XCTAssertEqualObjects(model.set, set, @"model.set should be equal to '[2, 3, 4]'");
    NSDictionary *dictionary = @{@"stringTestKey":@"testValue", @"numberTestKey":@(5.3)};
    XCTAssertEqualObjects(model.dict, dictionary, @"model.dict should be equal to '{\"stringTestKey\":\"testValue\", \"numberTestKey\":5.3}'");
    
    XCTAssertEqual(model.integer, 20, @"model.integer should be equal to '20'");
    XCTAssertEqual(model.floating, 4.53, @"model.floating should be equal to '4.53'");
}

@end
