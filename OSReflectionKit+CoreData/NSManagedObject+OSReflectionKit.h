//
//  NSManagedObject+OSReflectionKit.h
//  OSReflectionKit+CoreDataExample
//
//  Created by Alexandre on 05/08/13.
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

@interface NSManagedObject (OSReflectionKit)

#pragma mark - Properties

///-----------------------------
/// @name Class Properties
///-----------------------------

+ (void) registerDefaultManagedObjectContext:(NSManagedObjectContext *) context;
+ (NSManagedObjectContext *) defaultManagedObjectContext;

/**
 @discussion Override these methods in order to customize your managed object.
*/

/**
 @return The name of the entity. By the default it returns the Class name.
*/
+ (NSString *) entityName;

/**
 @return An array of unique field names that will be used by the instanciation methods to ensure uniqueness.
         By default it returns nil.
 */
+ (NSArray *) uniqueFields;

/**
 @return An array of field names that will be auto incremented by the instantiation methods if not present in the dictionary.
 By default it returns nil.
 */
+ (NSArray *) autoincrementFields;

+ (NSEntityDescription *) entityDescription;

///-----------------------------
/// @name Instance Properties
///-----------------------------

- (BOOL) isSaved;
- (BOOL) isNew;
- (BOOL) hasBeenDeleted;

#pragma mark - Instantiation Methods

///-----------------------------
/// @name Instantiation Methods
///-----------------------------

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
 Creates a `NSArray` instance from the type of the calling class and sets its properties from an array of `NSDictionay` objects.
 
 @param dicts An array of `NSDictionary` objects containing the objects data.
 @return An array of objects from the calling class type.
 @discussion Please use `+objectsFromDicts:`
 @see -objectFromDictionary:
 */
+ (NSArray *) objectsFromDicts:(NSArray *) dicts inManagedObjectContext:(NSManagedObjectContext *) context forEntityName:(NSString *) entityName;
+ (NSArray *) objectsFromDicts:(NSArray *) dicts inManagedObjectContext:(NSManagedObjectContext *) context;

/**
 Creates an instance from the type of the calling class.
 
 @param context The context where to create the object
 @return The instance of the created object
 @discussion This method does the same thing as `objectWithInManagedObjectContext:forEntityName:` using the method `entityName`.
 @see -objectFromDictionary:
 */
+ (instancetype) objectFromDictionary:(NSDictionary *) dictionary inManagedObjectContext:(NSManagedObjectContext *) context;

/**
 Creates an instance from the type of the calling class.
 
 @param context The context where to create the object
 @return The instance of the created object
 @discussion This method does the same thing as `objectWithInManagedObjectContext:forEntityName:` using the method `entityName`.
 @see -objectFromDictionary:
 */
+ (instancetype) objectFromDictionary:(NSDictionary *) dictionary inManagedObjectContext:(NSManagedObjectContext *) context forEntityName:(NSString *) entityName;

/**
 Creates an instance from the type of the calling class.
 
 @param context The context where to create the object
 @return The instance of the created object
 @discussion This method does the same thing as `objectWithInManagedObjectContext:forEntityName:` using the `+entityName` method.
 @see -objectFromDictionary:
 */
+ (instancetype) objectInManagedObjectContext:(NSManagedObjectContext *) context;

/**
 Creates an instance from the type of the calling class.
 
 @param context The context where to create the object
 @param entityName The name of an entity.
 @return The instance of the created object
 @see -objectFromDictionary:
 */
+ (instancetype) objectInManagedObjectContext:(NSManagedObjectContext *) context forEntityName:(NSString *) entityName;

/**
 Creates an instance from the type of the calling class and sets its properties from a string containing a JSON object.
 This method converts the jsonString into a dictionary before calling the `-objectFromDictionary:` method.
 
 @param jsonString The string containing the json object data.
 @param error The error variable to return an error object.
 @return The instance of the created object
 @discussion If you have a class that has a property: `NSString` *name, then you can call [CustomClassName objectFromJSON:@"{"name" : "Alexandre Santos"}"] and it will return an object of the type 'CustomClassName' with the attribute 'name' containing the value 'Alexandre Santos'.
 @see -objectFromDictionary:
 */
+ (instancetype) objectFromJSON:(NSString *) jsonString withController:(NSFetchedResultsController *) controller error:(NSError **) error __deprecated;
+ (instancetype) objectFromJSON:(NSString *) jsonString withController:(NSFetchedResultsController *) controller __deprecated;

+ (instancetype) objectFromJSON:(NSString *) jsonString inManagedObjectContext:(NSManagedObjectContext *) context forEntityName:(NSString *) entityName error:(NSError **) error;
+ (instancetype) objectFromJSON:(NSString *) jsonString inManagedObjectContext:(NSManagedObjectContext *) context forEntityName:(NSString *) entityName;
+ (instancetype) objectFromJSON:(NSString *) jsonString inManagedObjectContext:(NSManagedObjectContext *) context;

/**
 Creates a `NSArray` instance from the type of the calling class and sets its properties from an array of JSON objects.
 
 @param jsonArray An array of JSON objects containing the json objects data.
 @param error The error variable to return an error object.
 @return An array of objects from the calling class type.
 @see -objectFromJSON:
 */
+ (NSArray *)objectsFromJSONArray:(NSString *)jsonArray withController:(NSFetchedResultsController *) controller error:(NSError **) error __deprecated;
+ (NSArray *)objectsFromJSONArray:(NSString *)jsonArray withController:(NSFetchedResultsController *) controller __deprecated;

+ (NSArray *)objectsFromJSONArray:(NSString *)jsonArray inManagedObjectContext:(NSManagedObjectContext *) context forEntityName:(NSString *) entityName error:(NSError **) error;
+ (NSArray *)objectsFromJSONArray:(NSString *)jsonArray inManagedObjectContext:(NSManagedObjectContext *) context forEntityName:(NSString *) entityName ;
+ (NSArray *)objectsFromJSONArray:(NSString *)jsonArray inManagedObjectContext:(NSManagedObjectContext *) context;

#pragma mark - Fetcher Helpers

///-----------------------------
/// @name Fetcher Methods
///-----------------------------

+ (NSUInteger) count;
+ (NSUInteger) countInManagedObjectContext:(NSManagedObjectContext *) context;

+ (NSUInteger) countInManagedObjectContext:(NSManagedObjectContext *) context forEntityName:(NSString *) entityName withPredicate:(NSPredicate *) predicate;

+ (NSUInteger) countUniqueObjectsWithDictionary:(NSDictionary * ) dictionary inManagedObjectContext:(NSManagedObjectContext *) context forEntityName:(NSString *) entityName limit:(NSUInteger) limit;

+ (instancetype) firstWithDictionary:(NSDictionary * ) dictionary inManagedObjectContext:(NSManagedObjectContext *) context forEntityName:(NSString *) entityName;

+ (NSArray *) fetchUniqueObjectsWithDictionary:(NSDictionary * ) dictionary inManagedObjectContext:(NSManagedObjectContext *) context forEntityName:(NSString *) entityName limit:(NSUInteger) limit;

+ (NSArray *) fetchWithPredicate:(NSPredicate *) predicate sortDescriptors:(NSArray *) sortDescriptors limit:(NSUInteger) limit;
+ (NSArray *) fetchWithPredicate:(NSPredicate *) predicate limit:(NSUInteger) limit;

#pragma mark - Persistence Methods

///-----------------------------
/// @name Persistence Methods
///-----------------------------

/**
 Save the current object to its managed object context.
 
 @return `YES` in case of success.
 */
- (BOOL) save;

/**
 Save the current object to the specified managed object context.
 
 @param context The managed object context to save the object.
 @return `YES` in case of success.
 @see -save
 */
- (BOOL) saveWithContext:(NSManagedObjectContext *) context;

/**
 Save the current object to the specified managed object context.

 @param error The reference to be filled in case of an unsuccessful operation.
 @return `YES` in case of success.
 @see -save
 */
- (BOOL) saveWithError:(NSError **) error;

/**
 @param context The managed object context to save the object.
 @param error The reference to be filled in case of an unsuccessful operation.
 @return `YES` in case of success.
 @see -save
 @see -saveWithContext:
 */
- (BOOL) saveWithContext:(NSManagedObjectContext *) context error:(NSError **) error;

@end
