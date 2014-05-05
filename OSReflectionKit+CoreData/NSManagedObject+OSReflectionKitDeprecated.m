//
//  NSManagedObject+OSReflectionKitDeprecated.m
//  OSReflectionKit+CoreData
//
//  Created by Alexandre on 04/05/14.
//  Copyright (c) 2014 iAOS Software. All rights reserved.
//

#import "NSManagedObject+OSReflectionKitDeprecated.h"
#import "NSManagedObject+OSReflectionKit.h"
#import "NSPredicate+OSReflectionKit.h"

@interface NSManagedObject ()

// Private Methods
- (NSDictionary *) autoincrementedFieldsDictWithError:(NSError **) error;

@end

@implementation NSManagedObject (OSReflectionKitDeprecated)

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
        if(![object mapWithDictionary:dictionary error:&error])
            NSLog(@"Error mapping object: %@", error);
    }
    
    // Auto-increment
    NSError *error = nil;
    NSDictionary *autoincrementedFields = [object autoincrementedFieldsDictWithError:&error];
    if (error)
        NSLog(@"Error auto-incrementing fields: %@", error);
    
    if(![object mapWithDictionary:autoincrementedFields error:&error])
        NSLog(@"Error mapping object for auto-increment fields: %@", error);
    
    return object;
}

+ (instancetype) objectInManagedObjectContext:(NSManagedObjectContext *) context forEntityName:(NSString *) entityName
{
    return [self objectFromDictionary:nil inManagedObjectContext:context forEntityName:entityName];
}

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

+ (NSUInteger) countUniqueObjectsWithDictionary:(NSDictionary * ) dictionary inManagedObjectContext:(NSManagedObjectContext *) context forEntityName:(NSString *) entityName
{
    NSPredicate *predicate = [NSPredicate predicateForUniqueness:[self class] withDictionary:dictionary];
    return [self countInManagedObjectContext:context forEntityName:entityName withPredicate:predicate];
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

@end
