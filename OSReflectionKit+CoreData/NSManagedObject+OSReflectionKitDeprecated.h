//
//  NSManagedObject+OSReflectionKitDeprecated.h
//  OSReflectionKit+CoreData
//
//  Created by Alexandre on 04/05/14.
//  Copyright (c) 2014 iAOS Software. All rights reserved.
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

#import <CoreData/CoreData.h>
#import "NSObject+OSReflectionKit.h"

@interface NSManagedObject (OSReflectionKitDeprecated)

#pragma mark - Deprecated methods

/**
 Creates an instance from the type of the calling class.
 
 @return The instance of the created object
 @see -objectFromDictionary:
 */
+ (instancetype) objectWithController:(NSFetchedResultsController *) controller __deprecated;

/**
 Creates an instance from the type of the calling class and sets its properties from a `NSDictionay` object.
 
 @param dictionary The `NSDictionary` object containing the object data.
 @return The instance of the created object
 @discussion If you have a class that has a property: `NSString` *name, then you can call [CustomClassName objectFromDictionay:@{@"name" : @"Alexandre Santos"}] and it will return an object of the type 'CustomClassName' with the attribute 'name' containing the value 'Alexandre Santos'.
 @see -object
 */
+ (instancetype) objectFromDictionary:(NSDictionary *) dictionary withController:(NSFetchedResultsController *) controller __deprecated;

/**
 Creates a `NSArray` instance from the type of the calling class and sets its properties from an array of `NSDictionay` objects.
 
 @param dicts An array of `NSDictionary` objects containing the objects data.
 @return An array of objects from the calling class type.
 @deprecated Please use `objectsFromDicts:inManagedObjectContext` instead.
 @see -objectFromDictionary:
 */
+ (NSArray *) objectsFromDicts:(NSArray *) dicts withController:(NSFetchedResultsController *) controller __deprecated;

/**
 Creates an instance from the type of the calling class and sets its properties from a string containing a JSON object.
 This method converts the jsonString into a dictionary before calling the `-objectFromDictionary:` method.
 
 @param jsonString The string containing the json object data.
 @param controller The fetch results controller to be used.
 @param error The error variable to return an error object.
 @return The instance of the created object
 @discussion If you have a class that has a property: `NSString` *name, then you can call [CustomClassName objectFromJSON:@"{"name" : "Alexandre Santos"}"] and it will return an object of the type 'CustomClassName' with the attribute 'name' containing the value 'Alexandre Santos'.
 @see -objectFromDictionary:
 */
+ (instancetype) objectFromJSON:(NSString *) jsonString withController:(NSFetchedResultsController *) controller error:(NSError **) error __deprecated;

/**
 Creates an instance from the type of the calling class and sets its properties from a string containing a JSON object.
 This method converts the jsonString into a dictionary before calling the `-objectFromDictionary:` method.
 
 @param jsonString The string containing the json object data.
 @param controller The fetch results controller to be used.
 @return The instance of the created object
 @discussion If you have a class that has a property: `NSString` *name, then you can call [CustomClassName objectFromJSON:@"{"name" : "Alexandre Santos"}"] and it will return an object of the type 'CustomClassName' with the attribute 'name' containing the value 'Alexandre Santos'.
 @see -objectFromDictionary:
 */
+ (instancetype) objectFromJSON:(NSString *) jsonString withController:(NSFetchedResultsController *) controller __deprecated;

/**
 Creates a `NSArray` instance from the type of the calling class and sets its properties from an array of JSON objects.
 
 @param jsonArray An array of JSON objects containing the json objects data.
 @param controller The fetch results controller to be used.
 @param error The error variable to return an error object.
 @return An array of objects from the calling class type.
 @see -objectFromJSON:
 */
+ (NSArray *)objectsFromJSONArray:(NSString *)jsonArray withController:(NSFetchedResultsController *) controller error:(NSError **) error __deprecated;

/**
 Creates a `NSArray` instance from the type of the calling class and sets its properties from an array of JSON objects.
 
 @param jsonArray An array of JSON objects containing the json objects data.
 @param controller The fetch results controller to be used.
 @return An array of objects from the calling class type.
 @see -objectFromJSON:
 */
+ (NSArray *)objectsFromJSONArray:(NSString *)jsonArray withController:(NSFetchedResultsController *) controller __deprecated;

/**
 Creates an instance from the type of the calling class.
 
 @param context The context where to create the object
 @param entityName The name of an entity.
 @return The instance of the created object
 */
+ (instancetype) objectInManagedObjectContext:(NSManagedObjectContext *) context forEntityName:(NSString *) entityName __deprecated;

+ (instancetype) objectFromDictionary:(NSDictionary *) dictionary inManagedObjectContext:(NSManagedObjectContext *) context forEntityName:(NSString *) entityName __deprecated;

+ (NSArray *) objectsFromDicts:(NSArray *) dicts inManagedObjectContext:(NSManagedObjectContext *) context forEntityName:(NSString *) entityName __deprecated;

+ (instancetype) objectFromJSON:(NSString *) jsonString inManagedObjectContext:(NSManagedObjectContext *) context forEntityName:(NSString *) entityName error:(NSError **) error __deprecated;

+ (instancetype) objectFromJSON:(NSString *) jsonString inManagedObjectContext:(NSManagedObjectContext *) context forEntityName:(NSString *) entityName __deprecated;

+ (NSArray *)objectsFromJSONArray:(NSString *)jsonArray inManagedObjectContext:(NSManagedObjectContext *) context forEntityName:(NSString *) entityName error:(NSError **) error __deprecated;

+ (NSArray *)objectsFromJSONArray:(NSString *)jsonArray inManagedObjectContext:(NSManagedObjectContext *) context forEntityName:(NSString *) entityName __deprecated;

/**
 Count the number of objects stored for the calling class.
 
 @param context The given managed object context.
 @param entityName The given entity name.
 @param predicate The predicate used to filter the objects.
 @return The total number of objects stored for the class in the specified context.
 */
+ (NSUInteger) countInManagedObjectContext:(NSManagedObjectContext *) context forEntityName:(NSString *) entityName withPredicate:(NSPredicate *) predicate __deprecated;

/**
 Count the number of unique objects stored for the calling class.
 
 @param dictionary The dictionary to extract the unique fields values in order to filter objects.
 @param context The given managed object context.
 @param entityName The given entity name.
 @return The total number of unique objects stored for the class in the specified context.
 */
+ (NSUInteger) countUniqueObjectsWithDictionary:(NSDictionary * ) dictionary inManagedObjectContext:(NSManagedObjectContext *) context forEntityName:(NSString *) entityName __deprecated;

/**
 Finds the first object with the given unique values in the dictionary.
 
 @param dictionary The dictionary to extract the unique fields values in order to filter objects.
 @param context The given managed object context.
 @param entityName The given entity name.
 
 @return The found object or nil otherwise.
 */
+ (instancetype) firstWithDictionary:(NSDictionary * ) dictionary inManagedObjectContext:(NSManagedObjectContext *) context forEntityName:(NSString *) entityName __deprecated;

+ (NSArray *) fetchUniqueObjectsWithDictionary:(NSDictionary * ) dictionary inManagedObjectContext:(NSManagedObjectContext *) context forEntityName:(NSString *) entityName limit:(NSUInteger) limit __deprecated;

@end
