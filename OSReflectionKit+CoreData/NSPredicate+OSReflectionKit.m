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

+ (NSString *)predicateStringForUniquenessForClass:(Class)klazz withDictionary:(NSDictionary *)dictionary
{
	NSString *predicateString = nil;

	NSArray *uniqueFields = [klazz uniqueFields];

	if([uniqueFields count] > 0)
	{
		NSMutableArray *unmappedUniqueFields = [uniqueFields mutableCopy];

		if ([(id)klazz respondsToSelector:@selector(reflectionMapping)]) {
			Class<AZReflectionHint> reflectionMappingClass = klazz;
			NSDictionary *reflectionMapping = [reflectionMappingClass reflectionMapping];

			NSMutableArray *allUnmappedKeysMutable = [[reflectionMapping allValues] mutableCopy];

			for (NSUInteger index = 0; index < [allUnmappedKeysMutable count]; index++) {
				if ((id)[NSNull null] != allUnmappedKeysMutable[index]) {
					allUnmappedKeysMutable[index] = [[allUnmappedKeysMutable[index] componentsSeparatedByString:@","] firstObject];
				}
			}

			NSSet *allUnmappedKeysSet = [NSSet setWithArray:allUnmappedKeysMutable];

			for (NSUInteger index = 0; index < [uniqueFields count]; index++) {
				id key = uniqueFields[index];

				if ([allUnmappedKeysSet containsObject:key]) {
					id mappedKey = [[reflectionMapping allKeysForObject:uniqueFields[index]] firstObject];

					if (mappedKey) {
						unmappedUniqueFields[index] = mappedKey;
					}
				}
			}
		}

		NSMutableArray *values = [[dictionary valuesForPropertyNames:unmappedUniqueFields] mutableCopy];

		for (NSUInteger index = 0; index < [unmappedUniqueFields count]; index++) {
			id value = values[index];

			if ([NSObject propertyName:uniqueFields[index] isPrimitiveOrNumberPropertyOfClass:klazz] && [value isKindOfClass:[NSString class]]) {
				NSString *propertyName = uniqueFields[index];
				NSString *unconvertedValue = value;
				NSNumber *convertedValue = [NSObject numberFromNumericValueString:unconvertedValue targetPropertyName:propertyName ofClass:klazz];
				values[index] = convertedValue;
			}
		}

		NSUInteger valuesCount = [values count];

		if (valuesCount) {
			NSCAssert([uniqueFields count] == valuesCount, @"Count of unique fields (%tu) and values (%tu) don't match", [uniqueFields count], valuesCount);

			NSMutableArray *keyValuePairs = [[NSMutableArray alloc] initWithCapacity:valuesCount];

			for (NSUInteger index = 0; index < valuesCount; index++) {
				id value = values[index];

				if (value == [NSNull null]) {
					value = @"NIL";
				}
				else if ([value isKindOfClass:[NSString class]]) {
					value = [[NSString alloc] initWithFormat:@"'%@'", value];
				}

				[keyValuePairs addObject:[[NSString alloc] initWithFormat:@"%@ == %@", uniqueFields[index], value]];
			}

			predicateString = [keyValuePairs componentsJoinedByString:@" && "];
		}
	}

	return predicateString;
}


+ (instancetype)predicateForUniquenessForClass:(Class)klazz withDictionary:(NSDictionary *)dictionary
{
	NSPredicate *predicate = nil;

	NSString *predicateString = [self predicateStringForUniquenessForClass:klazz withDictionary:dictionary];

	if (predicateString) {
		predicate = [NSPredicate predicateWithFormat:predicateString];
	}

	return predicate;
}

@end
