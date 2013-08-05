//
//  NSManagedObject+OSReflectionKit.h
//  OSReflectionKit+CoreDataExample
//
//  Created by Alexandre on 05/08/13.
//  Copyright (c) 2013 iAOS Software. All rights reserved.
//

#import <CoreData/CoreData.h>
#import "NSObject+OSReflectionKit.h"

@interface NSManagedObject (OSReflectionKit)

///-----------------------------
/// @name Instantiation Methods
///-----------------------------

/**
 Creates an instance from the type of the calling class.
 
 @return The instance of the created object
 @see -objectFromDictionary:
 */
+ (id) objectWithController:(NSFetchedResultsController *) controller;

/**
 Creates an instance from the type of the calling class and sets its properties from a `NSDictionay` object.
 
 @param dictionary The `NSDictionary` object containing the object data.
 @return The instance of the created object
 @discussion If you have a class that has a property: `NSString` *name, then you can call [CustomClassName objectFromDictionay:@{@"name" : @"Alexandre Santos"}] and it will return an object of the type 'CustomClassName' with the attribute 'name' containing the value 'Alexandre Santos'.
 @see -object
 */
+ (id) objectFromDictionary:(NSDictionary *) dictionary withController:(NSFetchedResultsController *) controller;

/**
 Creates a `NSArray` instance from the type of the calling class and sets its properties from an array of `NSDictionay` objects.
 
 @param dicts An array of `NSDictionary` objects containing the objects data.
 @return An array of objects from the calling class type.
 @see -objectFromDictionary:
 */
+ (NSArray *) objectsFromDicts:(NSArray *) dicts withController:(NSFetchedResultsController *) controller;

/**
 Creates an instance from the type of the calling class and sets its properties from a string containing a JSON object.
 This method converts the jsonString into a dictionary before calling the `-objectFromDictionary:` method.
 
 @param jsonString The string containing the json object data.
 @param error The error variable to return an error object.
 @return The instance of the created object
 @discussion If you have a class that has a property: `NSString` *name, then you can call [CustomClassName objectFromJSON:@"{"name" : "Alexandre Santos"}"] and it will return an object of the type 'CustomClassName' with the attribute 'name' containing the value 'Alexandre Santos'.
 @see -objectFromDictionary:
 */
+ (id) objectFromJSON:(NSString *) jsonString withController:(NSFetchedResultsController *) controller error:(NSError **) error;
+ (id) objectFromJSON:(NSString *) jsonString withController:(NSFetchedResultsController *) controller;

/**
 Creates a `NSArray` instance from the type of the calling class and sets its properties from an array of JSON objects.
 
 @param jsonArray An array of JSON objects containing the json objects data.
 @param error The error variable to return an error object.
 @return An array of objects from the calling class type.
 @see -objectFromJSON:
 */
+ (NSArray *)objectsFromJSONArray:(NSString *)jsonArray withController:(NSFetchedResultsController *) controller error:(NSError **) error;;
+ (NSArray *)objectsFromJSONArray:(NSString *)jsonArray withController:(NSFetchedResultsController *) controller;

///-----------------------------
/// @name Persistence Methods
///-----------------------------

- (BOOL) saveWithContext:(NSManagedObjectContext *) context;
- (BOOL) saveWithContext:(NSManagedObjectContext *) context error:(NSError **) error;

@end
