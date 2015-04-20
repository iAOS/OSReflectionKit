//
//  ChildTestModel+ReflectionKit.m
//  OSReflectionKit+CoreDataExample
//
//  Created by Alexandre on 04/05/14.
//  Copyright (c) 2014 iAOS Software. All rights reserved.
//

#import "ChildTestModel+ReflectionKit.h"

@implementation ChildTestModel (ReflectionKit)

+ (NSDictionary *)reflectionMapping
{
    return @{@"parent":@"parent,<TestModel>"};
}

@end
