//
//  NSManagedObject+OSReflectionKit.h
//  OSReflectionKit+CoreData
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

/**
Registers the default managed object context for the current class.

@param context The managed object context to be registered.
*/
+ (void) registerDefaultManagedObjectContext:(NSManagedObjectContext *) context;

/**
 @return The registered default managed object context.
 */
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

/**
 @return The entity description object for the entityName in the defaultManagedObjectContext.
 */
+ (NSEntityDescription *) entityDescription;

///-----------------------------
/// @name Instance Properties
///-----------------------------

/**
 @return YES case the current instance has been saved before.
 */
- (BOOL) isSaved;

/**
 @return YES case the current instance has not been saved before.
 */
- (BOOL) isNew;

/**
 @return YES case the current instance has been deleted.
 */
- (BOOL) hasBeenDeleted;

#pragma mark - Instantiation Methods

///-----------------------------
/// @name Instantiation Methods
///-----------------------------

#pragma mark From Dictionaries

/**
 Creates a `NSArray` instance from the type of the calling class and sets its properties from an array of `NSDictionay` objects.
 
 @param dicts An array of `NSDictionary` objects containing the objects data.
 @param context The managed object context to create/fetch instances.
 @return An array of objects from the calling class type.
 */
+ (NSArray *) objectsFromDicts:(NSArray *) dicts inManagedObjectContext:(NSManagedObjectContext *) context;

/**
 Creates or fetch an instance from the type of the calling class based on the unique fields specified for the class.
 
 @param dictionary The dictionary to be used to map to properties.
 @param context The context where to create the object
 @return The instance of the created object
 @see -objectFromDictionary:
 */
+ (instancetype) objectFromDictionary:(NSDictionary *) dictionary inManagedObjectContext:(NSManagedObjectContext *) context;

#pragma mark No Mapping

/**
 Creates an instance from the type of the calling class.
 
 @param context The context where to create the object
 @return The instance of the created object
 */
+ (instancetype) objectInManagedObjectContext:(NSManagedObjectContext *) context;

#pragma mark From JSON

/**
 Creates or finds an instance matching the jsonString with the unique fields.
 
 @param jsonString The JSON string to map the object.
 @param context    The managed object context to use.
 @param error      The error reference to return an error, case any.
 @return The instance of the created or found object.
 */
+ (instancetype) objectFromJSON:(NSString *) jsonString inManagedObjectContext:(NSManagedObjectContext *) context error:(NSError **) error;

/**
 Creates or finds an instance matching the jsonString with the unique fields.
 
 @param jsonString The JSON object to map the instance.
 @param context    The managed object context to use.
 @return The instance of the created or found object.
 */
+ (instancetype) objectFromJSON:(NSString *) jsonString inManagedObjectContext:(NSManagedObjectContext *) context;

/**
 Creates or finds instances matching each JSON object in the JSON array with the unique fields.
 
 @param jsonArray The JSON array containing JSON objects to map the instance.
 @param context    The managed object context to use.
 @param error      The error reference to return an error, case any.
 @return The array of instances of the created or found objects.
 */
+ (NSArray *)objectsFromJSONArray:(NSString *)jsonArray inManagedObjectContext:(NSManagedObjectContext *) context error:(NSError **) error;

/**
 Creates or finds instances matching each JSON object in the JSON array with the unique fields.
 
 @param jsonArray The JSON array containing JSON objects to map the instance.
 @param context    The managed object context to use.
 @return The array of instances of the created or found objects.
 */
+ (NSArray *)objectsFromJSONArray:(NSString *)jsonArray inManagedObjectContext:(NSManagedObjectContext *) context;

#pragma mark - Fetcher Helpers

///-----------------------------
/// @name Fetcher Methods
///-----------------------------

/**
 Count the number of objects stored for the calling class.
 
 @return The total number of objects stored for the class in the default context.
 */
+ (NSUInteger) count;

/**
 Count the number of objects stored for the calling class, filtered by the predicate.
 
 @param predicate The predicate used to filter the objects.
 @return The number of objects stored for the class in the default context, filtered by the predicate.
 */
+ (NSUInteger) countWithPredicate:(NSPredicate *) predicate;

/**
 Count the number of objects stored for the calling class.
 
 @param context The given managed object context.
 @return The total number of objects stored for the class in the specified context.
 */
+ (NSUInteger) countInManagedObjectContext:(NSManagedObjectContext *) context;

/**
 Count the number of objects stored for the calling class.
 
 @param context The given managed object context.
 @param entityName The given entity name.
 @param predicate The predicate used to filter the objects.
 @return The total number of objects stored for the class in the specified context.
 */
+ (NSUInteger) countInManagedObjectContext:(NSManagedObjectContext *) context withPredicate:(NSPredicate *) predicate;

/**
 Count the number of unique objects stored for the calling class.
 
 @param dictionary The dictionary to extract the unique fields values in order to filter objects.
 @param context The given managed object context.
 @return The total number of unique objects stored for the class in the specified context.
 */
+ (NSUInteger) countUniqueObjectsWithDictionary:(NSDictionary * ) dictionary inManagedObjectContext:(NSManagedObjectContext *) context;

/**
 Finds the first object with the given unique values in the dictionary.
 
 @param attributes The attributes dictionary to filter objects.
 @param context The given managed object context.
 @param entityName The given entity name.
 
 @return The found object or nil otherwise.
 */
+ (instancetype) firstWithAttributes:(NSDictionary * ) attributes inManagedObjectContext:(NSManagedObjectContext *) context;

/**
 Finds the first object with the given values in the dictionary.
 
 @param attributes The attributes dictionary to filter objects.
 
 @return The found object or nil otherwise.
 */
+ (instancetype) firstWithAttributes:(NSDictionary * ) attributes;

/**
 Finds all objects stored for the calling class.
 
 @return An array of objects that meet the criteria specified by request fetched from the receiver and from the persistent stores associated with the receiver’s persistent store coordinator. If an error occurs, returns nil. If no objects match the criteria specified by request, returns an empty array.
 */
+ (NSArray *) fetchAll;

/**
 Finds all objects stored for the calling class in the given context.
 
 @param context The given managed object context.

 @return An array of objects that meet the criteria specified by request fetched from the receiver and from the persistent stores associated with the receiver’s persistent store coordinator. If an error occurs, returns nil. If no objects match the criteria specified by request, returns an empty array.
 */
+ (NSArray *) fetchAllInManagedObjectContext:(NSManagedObjectContext *) context;

/**
 Uses the default context to execute the fetch request.
 
 @param request The fetch request to be executed.
 
 @return An array of objects that meet the criteria specified by request fetched from the receiver and from the persistent stores associated with the receiver’s persistent store coordinator. If an error occurs, returns nil. If no objects match the criteria specified by request, returns an empty array.
 */
+ (NSArray *) fetchWithRequest:(NSFetchRequest *) request;

/**
 Uses the default context to execute the fetch request.
 
 @param request The fetch request to be executed.
 @param error If there is a problem executing the fetch, upon return contains an instance of NSError that describes the problem.
 
 @return An array of objects that meet the criteria specified by request fetched from the receiver and from the persistent stores associated with the receiver’s persistent store coordinator. If an error occurs, returns nil. If no objects match the criteria specified by request, returns an empty array.
 */
+ (NSArray *) fetchWithRequest:(NSFetchRequest *) request error:(NSError **) error;

/**
 Uses the default context to execute the fetch request.
 
 @param request The fetch request to be executed.
 @param context The managed object context from where to fetch objects.
 @param error If there is a problem executing the fetch, upon return contains an instance of NSError that describes the problem.
 
 @return An array of objects that meet the criteria specified by request fetched from the receiver and from the persistent stores associated with the receiver’s persistent store coordinator. If an error occurs, returns nil. If no objects match the criteria specified by request, returns an empty array.
 */
+ (NSArray *) fetchWithRequest:(NSFetchRequest *)request inManagedObjectContext:(NSManagedObjectContext *) context error:(NSError **)error;

/**
 Creates a fetch request for the calling class.
 
 @param attributes The matching attributes to be included in the fetch request.
 
 @return The created fetch request.
 */
+ (NSFetchRequest *) fetchRequestForObjectsWithAttributes:(NSDictionary * ) attributes;

/**
 Creates a fetch request for the calling class including the unique attributes present in the attributes dictionary.
 
 @param attributes The matching attributes to be included in the fetch request.
 
 @return The created fetch request.
 */
+ (NSFetchRequest *) fetchRequestForUniqueObjectsWithAttributes:(NSDictionary * ) attributes;

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

/**
 Delete all stored objects of the current class.
 */
+ (void) deleteAll;

/**
 Delete all stored objects of the current class matching the predicate.
 @param predicate The predicate object to filter the objects. If nil, it will delete all.
 */
+ (void) deleteAllWithPredicate:(NSPredicate *) predicate;

/**
 Delete all stored objects of the current class matching the predicate.
 @param predicate The predicate object to filter the objects. If nil, it will delete all.
 @param context The managed object context.
 */
+ (void) deleteAllWithPredicate:(NSPredicate *) predicate inManagedObjectContext:(NSManagedObjectContext *) context;

@end
