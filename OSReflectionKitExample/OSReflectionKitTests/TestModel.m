//
//  TestModel.m
//  OSReflectionKitExample
//
//  Created by Alexandre on 18/02/14.
//  Copyright (c) 2014 iAOS Software. All rights reserved.
//

#import "TestModel.h"
#import "NSObject+OSReflectionKit.h"

@implementation TestModel

#pragma mark - Reflection Kit Support

+ (NSDictionary *)reflectionMapping
{
    return @{@"name":@"string",
             @"list":@"array",
             @"numberToTransform":@"transformedFromNumber,*",
             @"nestedModel":@"nestedModel,<TestNestedModel>"};
}

- (void)reflectionTranformsValue:(id)value forKey:(NSString *)propertyName
{
    if([propertyName isEqualToString:@"transformedFromNumber"])
    {
        if([value isKindOfClass:[NSNumber class]])
        {
            self.transformedFromNumber = [NSString stringWithFormat:@"Number: %@", value];
        }
    }
}

#pragma mark - Mock Methods

+ (NSDictionary *) mockDictionary
{
    return @{@"string":@"Testing String...",
             @"number":@(10),
             @"array":@[@(1), @(2), @(3), @(4), @(5)],
             @"set":[NSSet setWithArray:@[@(2), @(3), @(4)]],
             @"dict":@{@"stringTestKey":@"testValue", @"numberTestKey":@(5.3)},
             @"integer":@(20),
             @"floating":@(4.53),
             @"date":@"2014-02-14",
             @"nestedModel":@{@"nestedString":@"testing nested string", @"nestedNumber":@(39)},
             @"decimalNumber":@"10.99"};
}

+ (NSDictionary *) specialMockDictionary
{
    return @{@"name":@"Testing String...",
             @"number":@(10),
             @"list":@[@(1), @(2), @(3), @(4), @(5)],
             @"set":[NSSet setWithArray:@[@(2), @(3), @(4)]],
             @"dict":@{@"stringTestKey":@"testValue", @"numberTestKey":@(5.3)},
             @"integer":@(20),
             @"floating":@(4.53),
             @"date":@"2014-02-14",
             @"nestedModel":@{@"nestedString":@"testing nested string", @"nestedNumber":@(39)},
             @"decimalNumber":@"10.99"};
}

@end
