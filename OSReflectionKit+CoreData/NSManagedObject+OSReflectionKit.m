//
//  NSManagedObject+OSReflectionKit.m
//  OSReflectionKit+CoreDataExample
//
//  Created by Alexandre on 05/08/13.
//  Copyright (c) 2013 iAOS Software. All rights reserved.
//

#import "NSManagedObject+OSReflectionKit.h"
#import "NSPredicate+OSReflectionKit.h"

@implementation NSManagedObject (OSReflectionKit)

static NSManagedObjectContext *_defaultContext = nil;

#pragma mark - Class Properties

+ (NSString *)entityName
{
    return NSStringFromClass([self class]);
}

+ (NSArray *)uniqueFields
{
    return nil;
}

+ (NSArray *) autoincrementFields
{
    return nil;
}

+ (void) registerDefaultManagedObjectContext:(NSManagedObjectContext *) context
{
    @synchronized(self)
    {
        _defaultContext = context;
    }
}

+ (NSManagedObjectContext *) defaultManagedObjectContext
{
    @synchronized(self)
    {
        return _defaultContext;
    }
}

+ (NSEntityDescription *)entityDescription
{
    return [NSEntityDescription entityForName:[self entityName] inManagedObjectContext:[self defaultManagedObjectContext]];
}

#pragma mark - Instance Properties

- (BOOL) isSaved
{
    return ![self isNew];
}

- (BOOL) isNew
{
    NSDictionary *vals = [self committedValuesForKeys:nil];
    return [vals count] == 0;
}

- (BOOL) hasBeenDeleted
{
    NSManagedObject *managedObjectClone = [[self managedObjectContext] existingObjectWithID:[self objectID] error:nil];
    return (managedObjectClone == nil);
}

#pragma mark - Instanciation Methods

+ (instancetype)objectFromDictionary:(NSDictionary *)dictionary
{
    NSAssert([self defaultManagedObjectContext], @"Please register the default managed object context for class: '%@' before using '%s'.", NSStringFromClass([self class]), __PRETTY_FUNCTION__);
    
    return [self objectFromDictionary:dictionary inManagedObjectContext:[self defaultManagedObjectContext]];
}

+ (instancetype)objectFromJSON:(NSString *)jsonString
{
    NSAssert([self defaultManagedObjectContext], @"Please register the default managed object context for class: '%@' before using '%s'.", NSStringFromClass([self class]), __PRETTY_FUNCTION__);
    
    return [self objectFromJSON:jsonString inManagedObjectContext:[self defaultManagedObjectContext]];
}

+ (instancetype) objectInManagedObjectContext:(NSManagedObjectContext *) context
{
    return [self objectInManagedObjectContext:context forEntityName:[self entityName]];
}

+ (instancetype) objectInManagedObjectContext:(NSManagedObjectContext *) context forEntityName:(NSString *) entityName
{
    return [self objectFromDictionary:nil inManagedObjectContext:context forEntityName:entityName];
}

#pragma mark NSDictionary

+ (instancetype) objectFromDictionary:(NSDictionary *) dictionary inManagedObjectContext:(NSManagedObjectContext *) context
{
    return [self objectFromDictionary:dictionary inManagedObjectContext:context forEntityName:[self entityName]];
}

+ (instancetype) objectFromDictionary:(NSDictionary *) dictionary inManagedObjectContext:(NSManagedObjectContext *) context forEntityName:(NSString *) entityName
{
    // Check if the dictionary is not stored yet
    id object = [self firstWithDictionary:dictionary inManagedObjectContext:context forEntityName:entityName];

    if(object == nil)
    {
        // Create a new object since there is no one like
        object = [NSEntityDescription insertNewObjectForEntityForName:entityName inManagedObjectContext:context];
    }
    
    // Try to map the object if there is any dictionary data
    if([dictionary count] > 0)
    {
        NSError *error = nil;
        [object mapWithDictionary:dictionary error:&error];
        
        if(error)
            NSLog(@"Error mapping object: %@", error);
    }
    
    return object;
}

+ (NSArray *) objectsFromDicts:(NSArray *) dicts inManagedObjectContext:(NSManagedObjectContext *) context forEntityName:(NSString *) entityName
{
    NSMutableArray *objects = [NSMutableArray arrayWithCapacity:[dicts count]];
    for (NSDictionary *dict in dicts)
    {
        id obj = [self objectFromDictionary:dict inManagedObjectContext:context forEntityName:entityName];
        
        if(obj)
            [objects addObject:obj];
    }
    
    return [objects copy];
}

+ (NSArray *) objectsFromDicts:(NSArray *) dicts inManagedObjectContext:(NSManagedObjectContext *) context
{
    return [self objectsFromDicts:dicts inManagedObjectContext:context forEntityName:[self entityName]];
}

#pragma mark JSON

+ (instancetype) objectFromJSON:(NSString *) jsonString inManagedObjectContext:(NSManagedObjectContext *) context forEntityName:(NSString *) entityName error:(NSError **) error
{
    // Convert the JSON text into a dictionary object
    NSData *jsonData = [jsonString dataUsingEncoding:NSUTF8StringEncoding];
    NSDictionary *dictionary = [NSJSONSerialization JSONObjectWithData:jsonData options:kNilOptions error:error];
    if(dictionary == nil)
    {
        // Something is wrong with the JSON text
        NSLog(@"Invalid json data: %@", *error);
        return nil;
    }
    else if([dictionary isKindOfClass:[NSDictionary class]])
    {
        // Load the Profile object from the dictionary
        return [self objectFromDictionary:dictionary inManagedObjectContext:context forEntityName:entityName];
    }
    
    return nil;
}

+ (instancetype) objectFromJSON:(NSString *) jsonString inManagedObjectContext:(NSManagedObjectContext *) context forEntityName:(NSString *) entityName
{
    return [self objectFromJSON:jsonString inManagedObjectContext:context forEntityName:entityName error:nil];
}

+ (instancetype) objectFromJSON:(NSString *) jsonString inManagedObjectContext:(NSManagedObjectContext *) context
{
    return [self objectFromJSON:jsonString inManagedObjectContext:context forEntityName:[self entityName] error:nil];
}

+ (NSArray *)objectsFromJSONArray:(NSString *)jsonArray inManagedObjectContext:(NSManagedObjectContext *) context forEntityName:(NSString *) entityName error:(NSError **) error
{
    // Convert the JSON text into a dictionary object
    NSData *jsonData = [jsonArray dataUsingEncoding:NSUTF8StringEncoding];
    NSArray *arrayDicts = [NSJSONSerialization JSONObjectWithData:jsonData options:kNilOptions error:error];
    if(arrayDicts == nil)
    {
        // Something is wrong with the JSON text
        NSLog(@"Invalid json data: %@", *error);
        return nil;
    }
    else if([arrayDicts isKindOfClass:[NSArray class]])
    {
        // Load the Profile object from the dictionary
        return [self objectsFromDicts:arrayDicts inManagedObjectContext:context forEntityName:entityName];
    }
    
    return nil;
}

+ (NSArray *)objectsFromJSONArray:(NSString *)jsonArray inManagedObjectContext:(NSManagedObjectContext *) context forEntityName:(NSString *) entityName
{
    return [self objectsFromJSONArray:jsonArray inManagedObjectContext:context forEntityName:entityName error:nil];
}

+ (NSArray *)objectsFromJSONArray:(NSString *)jsonArray inManagedObjectContext:(NSManagedObjectContext *) context
{
    return [self objectsFromJSONArray:jsonArray inManagedObjectContext:context forEntityName:[self entityName] error:nil];
}

#pragma mark - Fetcher Helpers

+ (NSUInteger) count
{
    NSAssert([self defaultManagedObjectContext], @"Please register the default managed object context for class: '%@' before using '%s'.", NSStringFromClass([self class]), __PRETTY_FUNCTION__);
    return [self countInManagedObjectContext:[self defaultManagedObjectContext] forEntityName:[self entityName] withPredicate:nil];
}

+ (NSUInteger) countInManagedObjectContext:(NSManagedObjectContext *) context
{
    return [self countInManagedObjectContext:context forEntityName:[self entityName] withPredicate:nil];
}

+ (NSUInteger) countInManagedObjectContext:(NSManagedObjectContext *) context forEntityName:(NSString *) entityName withPredicate:(NSPredicate *) predicate
{
    NSFetchRequest *fetchRequest = [NSFetchRequest fetchRequestWithEntityName:entityName];

    if(predicate)
        fetchRequest.predicate = predicate;
    
    NSError *error = nil;
    
    NSUInteger count = [context countForFetchRequest:fetchRequest error:&error];
    
    if(error)
    {
        NSLog(@"%@", error);
    }
    
    return count;
}

+ (NSUInteger) countUniqueObjectsWithDictionary:(NSDictionary * ) dictionary inManagedObjectContext:(NSManagedObjectContext *) context forEntityName:(NSString *) entityName limit:(NSUInteger) limit
{
    NSPredicate *predicate = [NSPredicate predicateForUniqueness:[self class] withDictionary:dictionary];
    return [self countInManagedObjectContext:context forEntityName:entityName withPredicate:predicate];
}

+ (instancetype) firstWithDictionary:(NSDictionary * ) dictionary inManagedObjectContext:(NSManagedObjectContext *) context forEntityName:(NSString *) entityName
{
    id object = nil;
    NSArray *objects = [self fetchUniqueObjectsWithDictionary:dictionary inManagedObjectContext:context forEntityName:entityName limit:1];
    if ([objects count] > 0)
    {
        object = [objects firstObject];
    }
    
    return object;
}

+ (NSArray *) fetchUniqueObjectsWithDictionary:(NSDictionary * ) dictionary inManagedObjectContext:(NSManagedObjectContext *) context forEntityName:(NSString *) entityName limit:(NSUInteger) limit
{
    NSArray *objects = nil;

    if([dictionary count] > 0)
    {
        NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:entityName];
        
        if(limit > 0)
        {
            request.fetchLimit = limit;
        }
        
        NSPredicate *predicate = [NSPredicate predicateForUniqueness:[self class] withDictionary:dictionary];
        if(predicate)
        {
            request.predicate = predicate;
        }
        
        NSError *error = nil;
        objects = [context executeFetchRequest:request error:&error];
    }
    
    return objects;
}

+ (NSArray *) fetchWithPredicate:(NSPredicate *) predicate limit:(NSUInteger) limit
{
    NSAssert([self defaultManagedObjectContext], @"Please register the default managed object context for class: '%@' before using '%s'.", NSStringFromClass([self class]), __PRETTY_FUNCTION__);
    
    NSArray *objects = nil;
    
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:[self entityName]];
    
    if(limit > 0)
    {
        request.fetchLimit = limit;
    }

    if(predicate)
    {
        request.predicate = predicate;
    }
    
    NSError *error = nil;
    objects = [[self defaultManagedObjectContext] executeFetchRequest:request error:&error];
    
    return objects;
}


#pragma mark - Deprecated methods

+ (instancetype) objectWithController:(NSFetchedResultsController *) controller
{
    return [self objectInManagedObjectContext:[controller managedObjectContext] forEntityName:[[[controller fetchRequest] entity] name]];
}

+ (instancetype) objectFromDictionary:(NSDictionary *) dictionary withController:(NSFetchedResultsController *) controller
{
    id object = [self objectWithController:controller];
    
    NSError *error = nil;
    [object mapWithDictionary:dictionary error:&error];
    
    if(error)
        NSLog(@"Error mapping object: %@", error);
    
    return object;
}

+ (NSArray *) objectsFromDicts:(NSArray *) dicts withController:(NSFetchedResultsController *) controller
{
    NSMutableArray *objects = [NSMutableArray arrayWithCapacity:[dicts count]];
    for (NSDictionary *dict in dicts)
    {
        id obj = [self objectFromDictionary:dict withController:controller];
        
        if(obj)
            [objects addObject:obj];
    }
    
    return [objects copy];
}

+ (instancetype) objectFromJSON:(NSString *)jsonString withController:(NSFetchedResultsController *) controller
{
    return [self objectFromJSON:jsonString withController:controller error:nil];
}

+ (instancetype)objectFromJSON:(NSString *)jsonString withController:(NSFetchedResultsController *) controller error:(NSError **)error
{
    // Convert the JSON text into a dictionary object
    NSData *jsonData = [jsonString dataUsingEncoding:NSUTF8StringEncoding];
    NSDictionary *dictionary = [NSJSONSerialization JSONObjectWithData:jsonData options:kNilOptions error:error];
    if(dictionary == nil)
    {
        // Something is wrong with the JSON text
        NSLog(@"Invalid json data: %@", *error);
        return nil;
    }
    else if([dictionary isKindOfClass:[NSDictionary class]])
    {
        // Load the Profile object from the dictionary
        return [self objectFromDictionary:dictionary withController:controller];
    }
    
    return nil;
}

+ (NSArray *)objectsFromJSONArray:(NSString *)jsonArray withController:(NSFetchedResultsController *) controller
{
    return [self objectsFromJSONArray:jsonArray withController:controller error:nil];
}

+ (NSArray *)objectsFromJSONArray:(NSString *)jsonArray withController:(NSFetchedResultsController *) controller error:(NSError **)error
{
    // Convert the JSON text into a dictionary object
    NSData *jsonData = [jsonArray dataUsingEncoding:NSUTF8StringEncoding];
    NSArray *arrayDicts = [NSJSONSerialization JSONObjectWithData:jsonData options:kNilOptions error:error];
    if(arrayDicts == nil)
    {
        // Something is wrong with the JSON text
        NSLog(@"Invalid json data: %@", *error);
        return nil;
    }
    else if([arrayDicts isKindOfClass:[NSArray class]])
    {
        // Load the Profile object from the dictionary
        return [self objectsFromDicts:arrayDicts withController:controller];
    }
    
    return nil;
}

#pragma mark - Persistence Methods

- (BOOL)save
{
    return [self saveWithContext:self.managedObjectContext];
}

- (BOOL) saveWithContext:(NSManagedObjectContext *) context
{
    return [self saveWithContext:context error:nil];
}

- (BOOL)saveWithError:(NSError **)error
{
    return [self saveWithContext:self.managedObjectContext error:error];
}

- (BOOL) saveWithContext:(NSManagedObjectContext *) context error:(NSError **) error
{
    return [context save:error];
}

@end
