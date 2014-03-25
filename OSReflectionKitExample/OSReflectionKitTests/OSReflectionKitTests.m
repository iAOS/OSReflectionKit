//
//  OSReflectionKitTests.m
//  OSReflectionKitTests
//
//  Created by Alexandre on 18/02/14.
//  Copyright (c) 2014 iAOS Software. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "NSObject+OSReflectionKit.h"
#import "TestModel.h"
#import "PartiallySupportedModel.h"

@interface OSReflectionKitTests : XCTestCase

@end

@implementation OSReflectionKitTests

- (void)setUp
{
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown
{
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

#pragma mark - Tests with NSDictionary

- (void)testObjectInstantiation
{
    TestModel *model = [TestModel object];
    
    XCTAssertNotNil(model, @"-[TestModel object] should return an instance of TestModel");
    XCTAssertTrue([model isKindOfClass:[TestModel class]], @"-[TestModel object] should return an instance of TestModel");
    
    model = [TestModel objectFromDictionary:[TestModel mockDictionary]];
    
    XCTAssertNotNil(model, @"-[TestModel objectFromDictionary:] should return an instance of TestModel");
    XCTAssertTrue([model isKindOfClass:[TestModel class]], @"-[TestModel objectFromDictionary:] should return an instance of TestModel");
    
    XCTAssertEqualObjects(model.string, @"Testing String...", @"model.string should be equal to 'Testing String...'");
    XCTAssertEqualObjects(model.number, @(10), @"model.number should be equal to '10'");
    NSArray *array = @[@(1), @(2), @(3), @(4), @(5)];
    XCTAssertEqualObjects(model.array, array, @"model.array should be equal to '[1, 2, 3, 4, 5]'");
    NSSet *set = [NSSet setWithArray:@[@(2), @(3), @(4)]];
    XCTAssertEqualObjects(model.set, set, @"model.set should be equal to '{2, 3, 4}'");
    NSDictionary *dictionary = @{@"stringTestKey":@"testValue", @"numberTestKey":@(5.3)};
    XCTAssertEqualObjects(model.dict, dictionary, @"model.dict should be equal to '{\"stringTestKey\":\"testValue\", \"numberTestKey\":5.3}'");
    
    XCTAssertEqual(model.integer, 20, @"model.integer should be equal to '20'");
    XCTAssertEqual(model.floating, 4.53, @"model.floating should be equal to '4.53'");
}

- (void)testObjectInstantiationWithReflectionMapping
{
    TestModel *model = [TestModel objectFromDictionary:[TestModel specialMockDictionary]];
    
    XCTAssertNotNil(model, @"-[TestModel objectFromDictionary:] should return an instance of TestModel");
    XCTAssertTrue([model isKindOfClass:[TestModel class]], @"-[TestModel objectFromDictionary:] should return an instance of TestModel");
    
    XCTAssertEqualObjects(model.string, @"Testing String...", @"model.string should be equal to 'Testing String...'");
    XCTAssertEqualObjects(model.number, @(10), @"model.number should be equal to '10'");
    NSArray *array = @[@(1), @(2), @(3), @(4), @(5)];
    XCTAssertEqualObjects(model.array, array, @"model.array should be equal to '[1, 2, 3, 4, 5]'");
    NSSet *set = [NSSet setWithArray:@[@(2), @(3), @(4)]];
    XCTAssertEqualObjects(model.set, set, @"model.set should be equal to '{2, 3, 4}'");
    NSDictionary *dictionary = @{@"stringTestKey":@"testValue", @"numberTestKey":@(5.3)};
    XCTAssertEqualObjects(model.dict, dictionary, @"model.dict should be equal to '{\"stringTestKey\":\"testValue\", \"numberTestKey\":5.3}'");
    
    XCTAssertEqual(model.integer, 20, @"model.integer should be equal to '20'");
    XCTAssertEqual(model.floating, 4.53, @"model.floating should be equal to '4.53'");
}

- (void)testObjectInstantiationWithCustomTransformation
{
    NSMutableDictionary *dictionary = [[TestModel mockDictionary] mutableCopy];
    [dictionary setObject:@(15) forKey:@"numberToTransform"];
    TestModel *model = [TestModel objectFromDictionary:dictionary];
    
    XCTAssertEqualObjects(model.transformedFromNumber, @"Number: 15", @"model.transformedFromNumber should be equal to 'Number: 15'");
}

- (void)testDictionaryFromObject
{
    NSDictionary *mockDictionary = [TestModel mockDictionary];
    TestModel *model = [TestModel objectFromDictionary:mockDictionary];
    NSDictionary *dict = [model dictionary];
    
    XCTAssertEqualObjects(dict[@"string"], @"Testing String...", @"string key should be equal to 'Testing String...'");
    XCTAssertEqualObjects(dict[@"number"], @(10), @"number key should be equal to '10'");
    NSArray *array = @[@(1), @(2), @(3), @(4), @(5)];
    XCTAssertEqualObjects(dict[@"array"], array, @"array key should be equal to '[1, 2, 3, 4, 5]'");
    NSSet *set = [NSSet setWithArray:@[@(2), @(3), @(4)]];
    XCTAssertEqualObjects(dict[@"set"], set, @"set key should be equal to '{2, 3, 4}'");
    NSDictionary *dictionary = @{@"stringTestKey":@"testValue", @"numberTestKey":@(5.3)};
    XCTAssertEqualObjects(dict[@"dict"], dictionary, @"dict key should be equal to '{\"stringTestKey\":\"testValue\", \"numberTestKey\":5.3}'");
    
    XCTAssertEqual([dict[@"integer"] integerValue], 20, @"integer key should be equal to '20'");
    XCTAssertEqual([dict[@"floating"] floatValue], 4.53f, @"floating key should be equal to '4.53'");
    XCTAssertEqualObjects(dict[@"transformedFromNumber"], [NSNull null], @"transformedFromNumber key should be equal to '[NSNull null]'");
    
    dict = [model dictionaryForNonNilProperties];
    
    NSArray *nullOjectKeys = [dict allKeysForObject:[NSNull null]];
    XCTAssertTrue([nullOjectKeys count] == 0, @"[model dictionaryForNonNilProperties] should return no entries");
}

- (void)testReverseDictionaryFromObject
{
    NSDictionary *mockDictionary = [TestModel mockDictionary];
    TestModel *model = [TestModel objectFromDictionary:mockDictionary];
    NSDictionary *dict = [model reverseDictionary];
    
    XCTAssertEqualObjects(dict[@"name"], @"Testing String...", @"name key should be equal to 'Testing String...'");
    XCTAssertEqualObjects(dict[@"number"], @(10), @"number key should be equal to '10'");
    NSArray *array = @[@(1), @(2), @(3), @(4), @(5)];
    XCTAssertEqualObjects(dict[@"list"], array, @"list key should be equal to '[1, 2, 3, 4, 5]'");
    NSSet *set = [NSSet setWithArray:@[@(2), @(3), @(4)]];
    XCTAssertEqualObjects(dict[@"set"], set, @"set key should be equal to '{2, 3, 4}'");
    NSDictionary *dictionary = @{@"stringTestKey":@"testValue", @"numberTestKey":@(5.3)};
    XCTAssertEqualObjects(dict[@"dict"], dictionary, @"dict key should be equal to '{\"stringTestKey\":\"testValue\", \"numberTestKey\":5.3}'");
    
    XCTAssertEqual([dict[@"integer"] integerValue], 20, @"integer key should be equal to '20'");
    XCTAssertEqual([dict[@"floating"] floatValue], 4.53f, @"floating key should be equal to '4.53'");
    XCTAssertEqualObjects(dict[@"numberToTransform"], [NSNull null], @"numberToTransform key should be equal to '[NSNull null]'");
}

#pragma mark - Tests with JSON strings

- (void) testJSONSerialization
{
    NSDictionary *mockDictionary = [TestModel mockDictionary];
    TestModel *model = [TestModel objectFromDictionary:mockDictionary];
    
    NSString *json = [model reverseJSONString];
    
    XCTAssertNotNil(json, @"JSON should not be nil");
    XCTAssertTrue([json length] > 10, @"JSON length should be > 10");
    
    NSData *jsonData = [json dataUsingEncoding:NSUTF8StringEncoding];
    NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:jsonData options:kNilOptions error:nil];
    
    XCTAssertNotNil(dict, @"dictionary should not be nil.");
    
    XCTAssertEqualObjects(dict[@"name"], @"Testing String...", @"name key should be equal to 'Testing String...'");
    XCTAssertEqualObjects(dict[@"number"], @(10), @"number key should be equal to '10'");
    NSArray *array = @[@(1), @(2), @(3), @(4), @(5)];
    XCTAssertEqualObjects(dict[@"list"], array, @"list key should be equal to '[1, 2, 3, 4, 5]'");
    NSSet *set = [NSSet setWithArray:@[@(2), @(3), @(4)]];
    NSSet *jsonSet = [NSSet setWithArray:dict[@"set"]];
    XCTAssertEqualObjects(jsonSet, set, @"set key should be equal to '{2, 3, 4}'");
    NSDictionary *dictionary = @{@"stringTestKey":@"testValue", @"numberTestKey":@(5.3)};
    XCTAssertEqualObjects(dict[@"dict"], dictionary, @"dict key should be equal to '{\"stringTestKey\":\"testValue\", \"numberTestKey\":5.3}'");
    
    XCTAssertEqual([dict[@"integer"] integerValue], 20, @"integer key should be equal to '20'");
    XCTAssertEqual([dict[@"floating"] floatValue], 4.53f, @"floating key should be equal to '4.53'");
    XCTAssertEqualObjects(dict[@"numberToTransform"], [NSNull null], @"numberToTransform key should be equal to '[NSNull null]'");
    
    XCTAssertNotNil(dict[@"nestedModel"], @"nestedModel should be in the serialized JSON string.");
    XCTAssertEqualObjects(dict[@"nestedModel"][@"nestedString"], @"testing nested string", @"nestedModel.nestedString should be in the serialized JSON string.");
    XCTAssertEqualObjects(dict[@"nestedModel"][@"nestedNumber"], @(39), @"nestedModel.nestedNumber should be in the serialized JSON string.");
}

- (void) testJSONDeserialization
{
    NSDictionary *mockDictionary = [TestModel mockDictionary];
    NSString *jsonString = [[TestModel objectFromDictionary:mockDictionary] reverseJSONString];
    
    TestModel *model = [TestModel objectFromJSON:jsonString];
    
    XCTAssertNotNil(model, @"-[TestModel objectFromDictionary:] should return an instance of TestModel");
    XCTAssertTrue([model isKindOfClass:[TestModel class]], @"-[TestModel objectFromDictionary:] should return an instance of TestModel");
    
    XCTAssertEqualObjects(model.string, @"Testing String...", @"model.string should be equal to 'Testing String...'");
    XCTAssertEqualObjects(model.number, @(10), @"model.number should be equal to '10'");
    NSArray *array = @[@(1), @(2), @(3), @(4), @(5)];
    XCTAssertEqualObjects(model.array, array, @"model.array should be equal to '[1, 2, 3, 4, 5]'");
    NSSet *set = [NSSet setWithArray:@[@(2), @(3), @(4)]];
    XCTAssertEqualObjects(model.set, set, @"model.set should be equal to '{2, 3, 4}'");
    NSDictionary *dictionary = @{@"stringTestKey":@"testValue", @"numberTestKey":@(5.3)};
    XCTAssertEqualObjects(model.dict, dictionary, @"model.dict should be equal to '{\"stringTestKey\":\"testValue\", \"numberTestKey\":5.3}'");
    
    // Nested objects
    XCTAssertEqualObjects(model.nestedModel.nestedString, @"testing nested string", @"model.nestedModel.nestedString should be equal to 'testing nested string'");
    XCTAssertEqualObjects(model.nestedModel.nestedNumber, @(39), @"model.nestedModel.nestedNumber should be equal to '39'");
}

#pragma mark - Tests with unsupported attributes

- (void)testPartiallySupportedModelObjectInstantiation
{
    PartiallySupportedModel *model = [PartiallySupportedModel object];
    
    XCTAssertNotNil(model, @"-[PartiallySupportedModel object] should return an instance of TestModel");
    XCTAssertTrue([model isKindOfClass:[PartiallySupportedModel class]], @"-[PartiallySupportedModel object] should return an instance of TestModel");
    
    model = [PartiallySupportedModel objectFromDictionary:[PartiallySupportedModel specialMockDictionary]];
    
    XCTAssertNotNil(model, @"-[PartiallySupportedModel objectFromDictionary:] should return an instance of TestModel");
    XCTAssertTrue([model isKindOfClass:[PartiallySupportedModel class]], @"-[PartiallySupportedModel objectFromDictionary:] should return an instance of TestModel");
    
    XCTAssertEqualObjects(model.string, @"Testing String...", @"model.string should be equal to 'Testing String...'");
    XCTAssertEqualObjects(model.number, @(10), @"model.number should be equal to '10'");
    NSArray *array = @[@(1), @(2), @(3), @(4), @(5)];
    XCTAssertEqualObjects(model.array, array, @"model.array should be equal to '[1, 2, 3, 4, 5]'");
    NSSet *set = [NSSet setWithArray:@[@(2), @(3), @(4)]];
    XCTAssertEqualObjects(model.set, set, @"model.set should be equal to '{2, 3, 4}'");
    NSDictionary *dictionary = @{@"stringTestKey":@"testValue", @"numberTestKey":@(5.3)};
    XCTAssertEqualObjects(model.dict, dictionary, @"model.dict should be equal to '{\"stringTestKey\":\"testValue\", \"numberTestKey\":5.3}'");
    
    XCTAssertEqual(model.integer, 20, @"model.integer should be equal to '20'");
    XCTAssertEqual(model.floating, 4.53, @"model.floating should be equal to '4.53'");
    
    XCTAssertTrue(CGPointEqualToPoint(model.point, CGPointZero), @"model.point should be equal to 'CGPointZero'");
}

- (void)testPartiallySupportedModelSerialization
{
    NSDictionary *mockDictionary = [PartiallySupportedModel mockDictionary];
    PartiallySupportedModel *model = [PartiallySupportedModel objectFromDictionary:mockDictionary];
    
    model.point = CGPointMake(10, 20);
    
    NSString *json = [model reverseJSONString];
    
    XCTAssertNotNil(json, @"JSON should not be nil");
    XCTAssertTrue([json length] > 10, @"JSON length should be > 10");
    
    NSData *jsonData = [json dataUsingEncoding:NSUTF8StringEncoding];
    NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:jsonData options:kNilOptions error:nil];
    
    XCTAssertNotNil(dict, @"dictionary should not be nil.");
    
    XCTAssertEqualObjects(dict[@"name"], @"Testing String...", @"name key should be equal to 'Testing String...'");
    XCTAssertEqualObjects(dict[@"number"], @(10), @"number key should be equal to '10'");
    NSArray *array = @[@(1), @(2), @(3), @(4), @(5)];
    XCTAssertEqualObjects(dict[@"list"], array, @"list key should be equal to '[1, 2, 3, 4, 5]'");
    NSSet *set = [NSSet setWithArray:@[@(2), @(3), @(4)]];
    NSSet *jsonSet = [NSSet setWithArray:dict[@"set"]];
    XCTAssertEqualObjects(jsonSet, set, @"set key should be equal to '{2, 3, 4}'");
    NSDictionary *dictionary = @{@"stringTestKey":@"testValue", @"numberTestKey":@(5.3)};
    XCTAssertEqualObjects(dict[@"dict"], dictionary, @"dict key should be equal to '{\"stringTestKey\":\"testValue\", \"numberTestKey\":5.3}'");
    
    XCTAssertEqual([dict[@"integer"] integerValue], 20, @"integer key should be equal to '20'");
    XCTAssertEqual([dict[@"floating"] floatValue], 4.53f, @"floating key should be equal to '4.53'");
    XCTAssertEqualObjects(dict[@"numberToTransform"], [NSNull null], @"numberToTransform key should be equal to '[NSNull null]'");
    
    XCTAssertEqualObjects(dict[@"point"], [NSNull null], @"point should be nil in the serialized JSON string.");
}

@end
