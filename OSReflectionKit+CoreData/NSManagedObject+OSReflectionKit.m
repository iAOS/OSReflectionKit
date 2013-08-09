//
//  NSManagedObject+OSReflectionKit.m
//  OSReflectionKit+CoreDataExample
//
//  Created by Alexandre on 05/08/13.
//  Copyright (c) 2013 iAOS Software. All rights reserved.
//

#import "NSManagedObject+OSReflectionKit.h"

@implementation NSManagedObject (OSReflectionKit)

#pragma mark - Instanciation Methods

+ (instancetype) objectWithController:(NSFetchedResultsController *) controller
{
    NSManagedObjectContext *context = [controller managedObjectContext];
    NSEntityDescription *entity = [[controller fetchRequest] entity];
    
    id newManagedObject = [NSEntityDescription insertNewObjectForEntityForName:[entity name] inManagedObjectContext:context];
    
    return newManagedObject;
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

- (BOOL) saveWithContext:(NSManagedObjectContext *) context
{
    return [self saveWithContext:context error:nil];
}

- (BOOL) saveWithContext:(NSManagedObjectContext *) context error:(NSError **) error
{
    return [context save:error];
}

@end
