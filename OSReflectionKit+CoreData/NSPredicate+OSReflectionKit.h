//
//  NSPredicate+OSReflectionKit.h
//  OSReflectionKit+CoreDataExample
//
//  Created by Alexandre on 03/02/14.
//  Copyright (c) 2014 iAOS Software. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSPredicate (OSReflectionKit)

+ (NSString *)predicateStringForUniquenessForClass:(Class)klazz withDictionary:(NSDictionary *)dictionary;
+ (instancetype)predicateForUniquenessForClass:(Class)klazz withDictionary:(NSDictionary *)dictionary;

@end
