//
//  NSManagedObject+OSReflectionKit.m
//  OSReflectionKit+CoreData
//
//  Created by Alexandre on 05/08/13.
//  Copyright (c) 2013 iAOS Software. All rights reserved.
//

#if  ! __has_feature(objc_arc)
#error This file must be compiled with ARC. Use -fobjc-arc flag (or convert project to ARC).
#endif

#define AssertDefaultManagedObjectContext() NSAssert([self defaultManagedObjectContext], @"Please register the default managed object context for class: '%@' before using '%s'.", NSStringFromClass([self class]), __PRETTY_FUNCTION__);

#import "NSManagedObject+OSReflectionKit.h"
#import "NSPredicate+OSReflectionKit.h"

static NSString * const OSReflectionKitCoreDataExtensionsErrorDomain = @"OSReflectionKitCoreDataExtensionsErrorDomain";

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

+ (id)reflectionNewInstanceWithDictionary:(NSDictionary *)dictionary
{
    return [self objectFromDictionary:dictionary];
}

+ (instancetype)object
{
    AssertDefaultManagedObjectContext();
    
    return [self objectInManagedObjectContext:[self defaultManagedObjectContext]];
}

+ (instancetype) objectInManagedObjectContext:(NSManagedObjectContext *) context
{
    return [self objectFromDictionary:nil inManagedObjectContext:context];
}

#pragma mark NSDictionary

+ (instancetype)objectFromDictionary:(NSDictionary *)dictionary
{
    AssertDefaultManagedObjectContext();
    
    return [self objectFromDictionary:dictionary inManagedObjectContext:[self defaultManagedObjectContext]];
}

+ (instancetype) objectFromDictionary:(NSDictionary *) dictionary inManagedObjectContext:(NSManagedObjectContext *) context
{
    // Check if the dictionary is not stored yet
    id object = [self firstWithAttributes:dictionary inManagedObjectContext:context];
    
    if(object == nil)
    {
        // Create a new object since there is no one like
        object = [NSEntityDescription insertNewObjectForEntityForName:[self entityName] inManagedObjectContext:context];
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

+ (NSArray *) objectsFromDicts:(NSArray *) dicts inManagedObjectContext:(NSManagedObjectContext *) context
{
    NSMutableArray *objects = [NSMutableArray arrayWithCapacity:[dicts count]];
    for (NSDictionary *dict in dicts)
    {
        id obj = [self objectFromDictionary:dict inManagedObjectContext:context];
        
        if(obj)
            [objects addObject:obj];
    }
    
    return [objects copy];
}

#pragma mark JSON

+ (instancetype)objectFromJSON:(NSString *)jsonString
{
    AssertDefaultManagedObjectContext();
    
    return [self objectFromJSON:jsonString inManagedObjectContext:[self defaultManagedObjectContext]];
}

+ (instancetype) objectFromJSON:(NSString *) jsonString inManagedObjectContext:(NSManagedObjectContext *) context
{
    return [self objectFromJSON:jsonString inManagedObjectContext:context error:nil];
}

+ (instancetype) objectFromJSON:(NSString *) jsonString inManagedObjectContext:(NSManagedObjectContext *) context error:(NSError **) error
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
        return [self objectFromDictionary:dictionary inManagedObjectContext:context];
    }
    
    return nil;
}

+ (NSArray *)objectsFromJSONArray:(NSString *)jsonArray inManagedObjectContext:(NSManagedObjectContext *) context
{
    return [self objectsFromJSONArray:jsonArray inManagedObjectContext:context error:nil];
}

+ (NSArray *)objectsFromJSONArray:(NSString *)jsonArray inManagedObjectContext:(NSManagedObjectContext *) context error:(NSError **)error
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
        return [self objectsFromDicts:arrayDicts inManagedObjectContext:context];
    }
    
    return nil;
}

#pragma mark - Fetcher Helpers

+ (NSUInteger) count
{
    return [self countWithPredicate:nil];
}

+ (NSUInteger) countWithPredicate:(NSPredicate *) predicate
{
    return [self countWithPredicate:predicate error:nil];
}

+ (NSUInteger) countWithPredicate:(NSPredicate *) predicate error:(NSError **) error
{
    AssertDefaultManagedObjectContext();
    return [self countInManagedObjectContext:[self defaultManagedObjectContext] withPredicate:nil error:error];
}

+ (NSUInteger) countInManagedObjectContext:(NSManagedObjectContext *) context
{
    return [self countInManagedObjectContext:context withPredicate:nil];
}

+ (NSUInteger) countInManagedObjectContext:(NSManagedObjectContext *) context withPredicate:(NSPredicate *) predicate
{
    return [self countInManagedObjectContext:context withPredicate:predicate error:nil];
}

+ (NSUInteger) countInManagedObjectContext:(NSManagedObjectContext *) context withPredicate:(NSPredicate *) predicate error:(NSError **) error
{
    NSFetchRequest *fetchRequest = [NSFetchRequest fetchRequestWithEntityName:[self entityName]];
    
    fetchRequest.predicate = predicate;
    
    NSUInteger count = [context countForFetchRequest:fetchRequest error:error];
    
    return count;

}

+ (NSUInteger) countUniqueObjectsWithDictionary:(NSDictionary * ) dictionary inManagedObjectContext:(NSManagedObjectContext *) context
{
    NSPredicate *predicate = [NSPredicate predicateForUniqueness:[self class] withDictionary:dictionary];
    return [self countInManagedObjectContext:context withPredicate:predicate];
}

+ (instancetype) firstWithAttributes:(NSDictionary * ) attributes inManagedObjectContext:(NSManagedObjectContext *) context
{
    NSArray *objects = [context executeFetchRequest:[self fetchRequestForUniqueObjectsWithAttributes:attributes] error:nil];
    
    return [objects firstObject];
}

+ (instancetype) firstWithAttributes:(NSDictionary * ) attributes
{
    return [self firstWithAttributes:attributes inManagedObjectContext:[self defaultManagedObjectContext]];
}

+ (NSArray *) fetchAll
{
    AssertDefaultManagedObjectContext();
    return [self fetchAllInManagedObjectContext:[self defaultManagedObjectContext]];
}

+ (NSArray *) fetchAllInManagedObjectContext:(NSManagedObjectContext *) context
{
    NSArray *objects = [context executeFetchRequest:[self fetchRequestForObjectsWithAttributes:nil] error:nil];
    
    return objects;
}

+ (NSArray *) fetchWithRequest:(NSFetchRequest *)request
{
    return [self fetchWithRequest:request error:nil];
}

+ (NSArray *) fetchWithRequest:(NSFetchRequest *)request error:(NSError **)error
{
    AssertDefaultManagedObjectContext();
    
    return [[self defaultManagedObjectContext] executeFetchRequest:request error:error];
}

+ (NSFetchRequest *) fetchRequestForObjectsWithAttributes:(NSDictionary * ) attributes
{
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:[self entityName]];
    
    NSPredicate *predicate = [NSPredicate predicateWithAttributes:attributes];
    if(predicate)
        request.predicate = predicate;
    
    return request;
}

+ (NSFetchRequest *) fetchRequestForUniqueObjectsWithAttributes:(NSDictionary * ) attributes
{
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:[self entityName]];
    
    NSPredicate *predicate = [NSPredicate predicateForUniqueness:[self class] withDictionary:attributes];
    if(predicate)
        request.predicate = predicate;
    
    return request;
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
    // Check whether it should auto-increment fields before saving
    NSDictionary *autoincrementedFields = [self autoincrementedFieldsDictWithError:error];
    if(autoincrementedFields)
        [self mapWithDictionary:autoincrementedFields error:error];
    
    return [context save:error];
}

+ (void) deleteAll
{
    [self deleteAllWithPredicate:nil];
}

+ (void) deleteAllWithPredicate:(NSPredicate *) predicate
{
    AssertDefaultManagedObjectContext();
    [self deleteAllWithPredicate:predicate inManagedObjectContext:[self defaultManagedObjectContext]];
}

+ (void) deleteAllWithPredicate:(NSPredicate *) predicate inManagedObjectContext:(NSManagedObjectContext *) context
{
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:[self entityName]];
    request.predicate = predicate;
    NSArray *allObjects = [self fetchWithRequest:request];
    for (NSManagedObject *object in allObjects) {
        [context deleteObject:object];
    }
}

#pragma mark - Private Methods

- (NSDictionary *) autoincrementedFieldsDictWithError:(NSError **) error
{
    __unused BOOL success = YES;
    NSArray *allAutoincrementFields = [[self class] autoincrementFields];
    NSMutableArray *ignoredFields = [NSMutableArray array];
    NSMutableDictionary *fieldsDictionary = [NSMutableDictionary dictionaryWithCapacity:[allAutoincrementFields count]];
    
    for (NSString *autoincrementField in allAutoincrementFields)
    {
        // Only auto-increment case the object is not set yet.
        id currentValue = [self valueForKey:autoincrementField];
        if(currentValue == nil ||
           [currentValue isKindOfClass:[NSNull class]])
        {
            // Generate the new field value
            NSFetchRequest *fetchRequest = [NSFetchRequest fetchRequestWithEntityName:[[self class] entityName]];
            fetchRequest.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:autoincrementField ascending:NO]];
            NSArray *items = [[self class] fetchWithRequest:fetchRequest];
            if([items count] > 0)
            {
                id item = items[0];
                NSNumber *maxValue = [item valueForKey:autoincrementField];
                if([maxValue isKindOfClass:[NSNumber class]])
                {
                    NSUInteger nextValue = [maxValue unsignedIntegerValue] < NSUIntegerMax ? [maxValue unsignedIntegerValue] + 1 : NSUIntegerMax;
                    [fieldsDictionary setValue:@(nextValue) forKey:autoincrementField];
                }
                else
                {
                    [ignoredFields addObject:[NSString stringWithFormat:@"'%@'", autoincrementField]];
                    success = NO;
                }
            }
        }
    }
    
    if(error && [ignoredFields count] > 0)
    {
        NSString *errorMessage = nil;
        NSString *fieldsString = [ignoredFields componentsJoinedByString:@", "];
        if([ignoredFields count] > 1)
            errorMessage = [NSString stringWithFormat:@"Properties %@ are being ignored because they are not numbers!", fieldsString];
        else
            errorMessage = [NSString stringWithFormat:@"Property %@ is being ignored because it's not a number!", fieldsString];
        
        *error = [NSError errorWithDomain:OSReflectionKitCoreDataExtensionsErrorDomain
                                     code:-1
                                 userInfo:@{NSLocalizedDescriptionKey: errorMessage}];
    }

    return [fieldsDictionary count] > 0 ? fieldsDictionary : nil;
}

@end
