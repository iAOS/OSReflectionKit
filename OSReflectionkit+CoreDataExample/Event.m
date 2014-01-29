//
//  Event.m
//  OSReflectionKit+CoreDataExample
//
//  Created by Alexandre on 29/01/14.
//  Copyright (c) 2014 iAOS Software. All rights reserved.
//

#import "Event.h"


@implementation Event

@dynamic timeStamp;
@dynamic eventId;

+ (NSArray *)uniqueFields
{
    return @[@"eventId"];
}

@end
