//
//  PartiallySupportedModel.m
//  OSReflectionKitExample
//
//  Created by Alexandre on 24/03/14.
//  Copyright (c) 2014 iAOS Software. All rights reserved.
//

#import "PartiallySupportedModel.h"
#import "NSObject+OSReflectionKit.h"

@implementation PartiallySupportedModel

#pragma mark - Reflection Kit Support

+ (NSDictionary *)reflectionMapping
{
    return @{@"name":@"string",
             @"list":@"array",
             @"numberToTransform":@"transformedFromNumber,*"};
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

- (void)reflectionMappingError:(NSError *)error withValue:(id)value forKey:(NSString *)propertyName
{
    NSLog(@"[MAPPING ERROR]: %@", [error localizedDescription]);
}

#pragma mark - NSKeyValueCoding

- (id)valueForUndefinedKey:(NSString *)key
{
    if([key isEqualToString:@"stringRef"])
        return (__bridge id)(_stringRef);
    
    return nil;
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
             @"date":@"2014-02-14"};
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
             @"point":@{@"x":@(10), @"y":@(20)},
             @"stringRef":@"testing CFStringRef type"};
}

@end
