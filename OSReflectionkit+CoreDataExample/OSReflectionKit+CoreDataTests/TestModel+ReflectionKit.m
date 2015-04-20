//
//  TestModel+ReflectionKit.m
//  OSReflectionKit+CoreDataExample
//
//  Created by Alexandre on 04/05/14.
//  Copyright (c) 2014 iAOS Software. All rights reserved.
//

#import "TestModel+ReflectionKit.h"

@implementation TestModel (ReflectionKit)

//+ (NSDictionary *)reflectionMapping
//{
//    return @{@"children":@"children,<ChildTestModel>"};
//}

+ (NSArray *)autoincrementFields
{
    return @[@"autoincrement"];
}

+ (NSArray *)uniqueFields
{
    return @[@"uniqueString"];
}

@end
