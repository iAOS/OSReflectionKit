//
//  Event+CustomReflection.m
//  OSReflectionKit+CoreDataExample
//
//  Created by Alexandre on 03/02/14.
//  Copyright (c) 2014 iAOS Software. All rights reserved.
//

#import "Event+ReflectionKitOptions.h"

@implementation Event (ReflectionKitOptions)

+ (NSArray *)uniqueFields
{
    return @[@"eventId"];
}

+ (NSArray *)autoincrementFields
{
    return @[@"eventId"];
}

@end
