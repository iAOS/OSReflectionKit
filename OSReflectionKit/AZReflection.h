//
//  AZReflectionMapper.h
//  Reflections
//
//  Created by Alexander Zats on 5/9/12.
//
//  Modified by Alexandre Santos
//  Copyright (c) 2012 iAOS Software. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AZReflectionHint.h"

@interface AZReflection : NSObject
extern NSString *const AZReflectionMapperErrorDomain;
+ (AZReflection *)sharedReflectionMapper;
- (id)reflectionMapWithDictionary:(NSDictionary *)dictionary rootClass:(Class)classReference error:(NSError **)error;

- (void) mapObject:(id) object withDictionary:(NSDictionary *)dictionary rootClass:(Class)classReference error:(NSError **)error;

@end

@interface NSObject (AZReflectionMapper) <AZReflectionHint>

// Instantiation Methods
+ (id)reflectionMapWithDictionary:(NSDictionary *)dictionary error:(NSError **)error;

// Mapping Methods
- (void) mapWithDictionary:(NSDictionary *)dictionary;
- (void) mapWithDictionary:(NSDictionary *)dictionary error:(NSError **)error;

// Properties Methods
+ (NSDictionary *) classProperties;
+ (Class) classForProperty:(NSString *) propertyName;
- (BOOL) setValue:(id) value forProperty:(NSString *) propertyName;
- (BOOL) setValue:(id) value forProperty:(NSString *) propertyName error:(NSError **) error;
@end