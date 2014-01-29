//
//  NSManagedObject+OSReflectionKit.m
//  OSReflectionKit+CoreDataExample
//
//  Created by Alexandre on 05/08/13.
//  Copyright (c) 2013 iAOS Software. All rights reserved.
//

#import "NSManagedObject+OSReflectionKit.h"

@implementation NSManagedObject (OSReflectionKit)

#pragma mark - Class Properties

+ (NSString *)entityName
{
    return NSStringFromClass([self class]);
}

+ (NSArray *)uniqueFields
{
    return nil;
}

#pragma mark - Instanciation Methods

+ (instancetype) objectWithInManagedObjectContext:(NSManagedObjectContext *) context
{
    return [self objectWithInManagedObjectContext:context forEntityName:[self entityName]];
}

+ (instancetype) objectWithInManagedObjectContext:(NSManagedObjectContext *) context forEntityName:(NSString *) entityName
{
    return [self objectFromDictionary:nil inManagedObjectContext:context forEntityName:entityName];
}

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

#pragma mark - Fetcher Helpers

+ (instancetype) firstWithDictionary:(NSDictionary * ) dictionary inManagedObjectContext:(NSManagedObjectContext *) context forEntityName:(NSString *) entityName
{
    id object = nil;
    NSArray *objects = [self fetchUniqueObjectsWithDictionary:dictionary inManagedObjectContext:context forEntityName:entityName];
    if ([objects count] > 0)
    {
        object = [objects firstObject];
    }
    
    return object;
}

+ (NSArray *) fetchUniqueObjectsWithDictionary:(NSDictionary * ) dictionary inManagedObjectContext:(NSManagedObjectContext *) context forEntityName:(NSString *) entityName
{
    NSArray *uniqueFields = [self uniqueFields];
    
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:entityName];
    
    if([uniqueFields count] > 0)
    {
        NSMutableString *predicateFormat = [[uniqueFields componentsJoinedByString:@" = '%@' &&"] mutableCopy];
        [predicateFormat appendString:@" = '%@'"];
        NSArray *values = [dictionary valuesForPropertyNames:uniqueFields];
        
        request.predicate = [NSPredicate predicateWithFormat:predicateFormat argumentArray:values];
    }
    
    NSError *error = nil;
    NSArray *objects = [context executeFetchRequest:request error:&error];
    
    return objects;
}


#pragma mark - Deprecated methods

+ (instancetype) objectWithController:(NSFetchedResultsController *) controller
{
    return [self objectWithInManagedObjectContext:[controller managedObjectContext] forEntityName:[[[controller fetchRequest] entity] name]];
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
