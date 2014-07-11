//
//  NSObject+OSReflectionKit.h
//  OSReflectionKit
//
//  Created by Alexandre on 04/02/13.
//

/*
 Copyright (c) 2013 iAOS Software. All rights reserved.
 
 Permission is hereby granted, free of charge, to any person obtaining a copy of
 this software and associated documentation files (the "Software"), to deal in
 the Software without restriction, including without limitation the rights to
 use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies
 of the Software, and to permit persons to whom the Software is furnished to do
 so, subject to the following conditions:
 
 The above copyright notice and this permission notice shall be included in all
 copies or substantial portions of the Software.
 
 If you happen to meet one of the copyright holders in a bar you are obligated
 to buy them one pint of beer.
 
 THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
 SOFTWARE.
 */

#import <Foundation/Foundation.h>
#import "AZReflection.h"

// This category allows any NSObject to be instantiated using an NSDictiony object. Also adds some reflection methods to the NSObject, like listing properties and getting the property type

// The following macros are quite useful for building the +[reflectionMapping] dictionary and to verify the incoming property name in -[reflectionTranformsValue:forKey:].

/**
 Builds an NSString to express a key path.
 
 @param OBJ  Root object or object type. Used as a template only.
 @param PATH A chain of properties
 
 @return NSString expressing a key path reachable from some instance of the same type of the root object

 @example OSRKeyPath(self, view.superview)
 @example OSRKeyPath(UIViewController *, view.superview)
 */
#define OSRKeyPath(OBJ, PATH) ((void)(0 && ((void)({__typeof(OBJ) OSR_ghost_obj; OSR_ghost_obj.PATH;}), 0)), @#PATH)

/**
 Marks a key path as needing to be transformed with -[reflectionTransformsValue:forKey:] when creating from a dictionary. It is suggested to be used in tandem with the OSRKeyPath macro.
 
 @param KEYPATH A key path
 
 @return A string flagging the key path as needing transformation
 
 @example OSRTransform(OSRKeyPath(TYSUser*, picture))
 */
#define OSRTransform(KEYPATH) ([(KEYPATH) stringByAppendingString:@",*"])

/**
 Marks a key path as needing instantiation with -[objectFromDictionary:] when the parent ovject is created from a dictionary. It is suggested to be used in tandem with the OSRKeyPath macro.
 
 @param KEYPATH           A key path
 @param TARGET_CLASS_NAME The target class name
 
 @return A string flagging the key path as needing to be instantiated with -[objectFromDictionary:]
 
 @example OSRAdapt(OSRKeyPath(TYSUser*, xp), TYSXP)
 */
#define OSRAdapt(KEYPATH, TARGET_CLASS_NAME) ((void)(0 && ((void)({__typeof(TARGET_CLASS_NAME) *OSR_ghost_obj __attribute__((unused));}), 0)), [(KEYPATH) stringByAppendingString:@",<"#TARGET_CLASS_NAME">"])


@interface NSObject (OSReflectionKit)
#ifdef TROUBLE
<NSCopying, NSCoding>
#endif

///-----------------------------
/// @name Instantiation Methods
///-----------------------------

/**
 Creates an instance from the type of the calling class.
 
 @return The instance of the created object
 @see -objectFromDictionary:
 */
+ (instancetype) object;

/**
 Creates an instance from the type of the calling class and sets its properties from a `NSDictionay` object.

 @param dictionary The `NSDictionary` object containing the object data.
 @return The instance of the created object
 @discussion If you have a class that has a property: `NSString` *name, then you can call [CustomClassName objectFromDictionay:@{@"name" : @"Alexandre Santos"}] and it will return an object of the type 'CustomClassName' with the attribute 'name' containing the value 'Alexandre Santos'.
 @see -object
 */
+ (instancetype) objectFromDictionary:(NSDictionary *) dictionary;

/**
 Creates a `NSArray` instance from the type of the calling class and sets its properties from an array of `NSDictionay` objects.

 @param dicts An array of `NSDictionary` objects containing the objects data.
 @return An array of objects from the calling class type.
 @see -objectFromDictionary:
 */
+ (NSArray *) objectsFromDicts:(NSArray *) dicts;

/**
 Creates an instance from the type of the calling class and sets its properties from a string containing a JSON object.
 This method converts the jsonString into a dictionary before calling the `-objectFromDictionary:` method.
 
 @param jsonString The string containing the json object data.
 @param error The error variable to return an error object.
 @return The instance of the created object
 @discussion If you have a class that has a property: `NSString` *name, then you can call [CustomClassName objectFromJSON:@"{"name" : "Alexandre Santos"}"] and it will return an object of the type 'CustomClassName' with the attribute 'name' containing the value 'Alexandre Santos'.
 @see -objectFromDictionary:
 */
+ (instancetype) objectFromJSON:(NSString *) jsonString error:(NSError **) error;
+ (instancetype) objectFromJSON:(NSString *) jsonString;

/**
 Creates a `NSArray` instance from the type of the calling class and sets its properties from an array of JSON objects.
 
 @param jsonArray An array of JSON objects containing the json objects data.
 @param error The error variable to return an error object.
 @return An array of objects from the calling class type.
 @see -objectFromJSON:
 */
+ (NSArray *)objectsFromJSONArray:(NSString *)jsonArray error:(NSError **) error;;
+ (NSArray *)objectsFromJSONArray:(NSString *)jsonArray;

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
+ (NSArray*) propertyNamesOfType:(Class) klass;

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
 Converts the current instance object into a JSON String.
 
 @discussion If a property is `nil`, an NSNull object will be created for it in the JSON string returned.
 @param error The error variable to return an error object.
 @return A `NSString` object formatted as JSON, with the values for the properties of the instance.
 @see -dictionary
 */
- (NSString *) JSONString:(NSError **) error;
- (NSString *) JSONString;

/**
 Converts the current instance object into a JSON String using the mapping dictionary for the object.
 
 @discussion If a property is `nil`, an NSNull object will be created for it in the JSON string returned.
 @param error The error variable to return an error object.
 @return A `NSString` object formatted as JSON, with the values for the properties of the instance.
 @see -dictionary
 */
- (NSString *) reverseJSONString:(NSError **) error;
- (NSString *) reverseJSONString;

/**
 Converts the current instance object into a JSON String.
 
 @param error The error variable to return an error object.
 @return A `NSString` object formatted as JSON, with the values for the properties of the instance, excluding NSNull objects.
 @see -JSONString
 */
- (NSString *) JSONStringForNonNilProperties:(NSError **) error;
- (NSString *) JSONStringForNonNilProperties;

/**
 A more readable description of an object, like an `NSDictionary` description.
 
 @return A string containing the description of the calling object.
 @see -dictionary
 */
- (NSString *) fullDescription;

@end
