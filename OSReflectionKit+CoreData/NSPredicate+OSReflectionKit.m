//
//  NSPredicate+OSReflectionKit.m
//  OSReflectionKit+CoreDataExample
//
//  Created by Alexandre on 03/02/14.
//  Copyright (c) 2014 iAOS Software. All rights reserved.
//

#if  ! __has_feature(objc_arc)
#error This file must be compiled with ARC. Use -fobjc-arc flag (or convert project to ARC).
#endif

#import "NSPredicate+OSReflectionKit.h"
#import "NSManagedObject+OSReflectionKit.h"

@implementation NSPredicate (OSReflectionKit)

+ (instancetype) predicateForUniqueness:(Class) klazz withDictionary:(NSDictionary *) dictionary
{
    NSPredicate *predicate = nil;
    
    NSArray *uniqueFields = [klazz uniqueFields];
    
    if([uniqueFields count] > 0)
    {
        NSMutableString *predicateFormat = [[uniqueFields componentsJoinedByString:@" = %@ &&"] mutableCopy];
        [predicateFormat appendString:@" = %@"];
        NSArray *values = [dictionary valuesForPropertyNames:uniqueFields];
        
        if([values count] > 0)
            predicate = [NSPredicate predicateWithFormat:predicateFormat argumentArray:values];
    }
    
    return predicate;
}

@end
