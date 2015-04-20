//
//  OSReflectionKit_CoreDataTests.m
//  OSReflectionKit+CoreDataTests
//
//  Created by Alexandre on 04/05/14.
//  Copyright (c) 2014 iAOS Software. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "OSCoreDataManager.h"
#import "TestModel+ReflectionKit.h"

@interface NSManagedObject_OSReflectionKitTests : XCTestCase

@property (nonatomic) TestModel *testModel;

@end

@implementation NSManagedObject_OSReflectionKitTests

- (NSDictionary *) mockDictionaryForTestModel
{
    return @{@"string":@"Test String",
             @"uniqueString":@"Some unique string"};
}

+ (void)setUp
{
    // Setup the Core Data data model for the tests
    [OSCoreDataManager registerModelFileName:@"TestModel.momd"];
    
    // Register the managed object context
    [TestModel registerDefaultManagedObjectContext:[OSCoreDataManager sharedManager].managedObjectContext];
}

- (void)setUp
{
    self.testModel = [TestModel objectFromDictionary:[self mockDictionaryForTestModel]];

    [super setUp];
}

- (void)tearDown
{
    // Clear the stored objects
    [TestModel deleteAll];
    [ChildTestModel deleteAll];
    
    [super tearDown];
}

- (void)testInstantiation
{
    XCTAssertNotNil(self.testModel);
    
    // Test saving
    XCTAssertFalse([self.testModel isSaved]);
    NSError *error = nil;
    XCTAssertTrue([self.testModel saveWithError:&error]);
    XCTAssertTrue([self.testModel isSaved]);
}

@end
