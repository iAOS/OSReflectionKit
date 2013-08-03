//
//  NSObject+ACReflectionKit.h
//  Karmalot
//
//  Created by Alexandre on 04/02/13.
//  Copyright (c) 2013 iAOS Software. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AZReflection.h"

// This category allows any NSObject to be instantiated using an NSDictiony object. Also adds some reflection methods to the NSObject, like listing properties and getting the property type

@interface NSObject (OSReflectionKit) <NSCopying, NSCoding>

///-----------------------------
/// @name Instantiation Methods
///-----------------------------

/**
 Creates an instance from the type of the calling class.
 
 @return The instance of the created object
 @see -objectFromDictionary:
 */
+ (id) object;

/**
 Creates an instance from the type of the calling class and sets its properties from a `NSDictionay` object.

 @param dictionary The `NSDictionary` object containing the object data.
 @return The instance of the created object
 @discussion If you have a class that has a property: `NSString` *name, then you can call [CustomClassName objectFromDictionay:@{@"name" : @"Alexandre Santos"}] and it will return an object of the type 'CustomClassName' with the attribute 'name' containing the value 'Alexandre Santos'.
 @see -object
 */
+ (id) objectFromDictionary:(NSDictionary *) dictionary;

/**
 Creates a `NSArray` instance from the type of the calling class and sets its properties from an array of `NSDictionay` objects.

 @param dicts An array of `NSDictionary` objects containing the objects data.
 @return An array of objects from the calling class type.
 @see -objectFromDictionary:
 */
+ (NSArray *) objectsFromDicts:(NSArray *) dicts;

///-----------------------------
/// @name Class Reflection
///-----------------------------

/**
 Array of property names of the calling class.
 
 @return An array of property names of the calling class.
 */
+ (NSArray *) propertyNames;

/**
 Array of simple property names of the calling class, excluding custom classes properties.
 
 @return An array of simple property names of the calling class.
 @see -propertyNames
 */
+ (NSArray *) simpleTypesPropertyNames;

/**
 @return Number of total properties of the class.
 */
+ (NSUInteger) propertyCount;

/**
 @param klass The desired filter class
 @return An array of property names that are of the type `klass`
 */
+ (NSArray*) arrayPropertiesOfType:(Class) klass;

///-----------------------------
/// @name Instance Reflection
///-----------------------------

/**
 @param propertyNames An array of the desired properties values.
 @return An array with the values for the properties contained in `propertyNames`.
 */
- (NSArray *) valuesForPropertyNames:(NSArray *) propertyNames;

/**
 Converts the current instance object into a dicitionary.

 @discussion If a property is `nil`, an NSNull object will be created for it in the `NSDictionary` returned.
 @return A `NSDictionary` with the values for the properties of the instance.
 @see -valuesForPropertyNames:
 */
- (NSDictionary *) dictionary;

/**
 Converts the current instance object into a dicitionary.
 
 @return A `NSDictionary` with the values for the properties of the instance, excluding NSNull objects.
 @see -dictionary
 */
- (NSDictionary *) dictionaryForNonNilProperties;

/**
 A more readable description of an object, like an `NSDictionary` description.
 
 @return A string containing the description of the calling object.
 @see -dictionary
 */
- (NSString *) fullDescription;

@end