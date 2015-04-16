//
//  NSManagedObject+OSReflectionKit.m
//  OSReflectionKit+CoreDataExample
//
//  Created by Alexandre on 05/08/13.
//  Copyright (c) 2013 iAOS Software. All rights reserved.
//

#import <Availability.h>

#if  ! __has_feature(objc_arc)
#error This file must be compiled with ARC. Use -fobjc-arc flag (or convert project to ARC).
#endif

#import "NSManagedObject+OSReflectionKit.h"
#import "NSPredicate+OSReflectionKit.h"

static NSString * const OSReflectionKitCoreDataExtensionsErrorDomain = @"OSReflectionKitCoreDataExtensionsErrorDomain";

static NSCache *OSRManagedObjectCacheForContext = nil;

@implementation NSManagedObject (OSReflectionKit)

+ (NSCache *)OSRManagedObjectCacheForContext:(NSManagedObjectContext *)context
{
	NSCache *OSRManagedObjectCache = [OSRManagedObjectCacheForContext objectForKey:context];

	if (!OSRManagedObjectCache) {
		OSRManagedObjectCache = [[NSCache alloc] init];
		OSRManagedObjectCache.countLimit = 1024;
		[OSRManagedObjectCacheForContext setObject:OSRManagedObjectCache forKey:context];
	}

	return OSRManagedObjectCache;
}

+ (void)load
{
	static dispatch_once_t onceToken;
	dispatch_once(&onceToken, ^{
		OSRManagedObjectCacheForContext = [[NSCache alloc] init];
		[OSRManagedObjectCacheForContext setName:@"OSRManagedObjectCacheForContext"];
	});
}

static NSManagedObjectContext *_defaultContext = nil;

#pragma mark - Class Properties

+ (NSDictionary *)reflectionMapping
{
    return @{};
}

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
	NSEntityDescription * __block entityDescription = nil;
	[[self defaultManagedObjectContext] performBlockAndWait:^{
		entityDescription = [NSEntityDescription entityForName:[self entityName] inManagedObjectContext:[self defaultManagedObjectContext]];
	}];
    return entityDescription;
}

#pragma mark - Reflection exceptions

- (void)reflectionValue:(id)value forUnkownKey:(NSString *)key
{
	@try {
		@throw [NSException exceptionWithName:@"OSRValueAssignmentException" reason:@"Could not assign" userInfo:@{@"Key" : key, @"Value" : value ?: [NSNull null]}];
	}
	@catch (...) {}
}

- (void)reflectionMappingError:(NSError *)error withValue:(id)value forKey:(NSString *)propertyName
{
	@try {
		@throw [NSException exceptionWithName:@"OSRMappingException" reason:@"Could not map" userInfo:@{@"Key" : propertyName, @"Value" : value ?: [NSNull null], NSUnderlyingErrorKey : error}];
	}
	@catch (...) {}
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
    NSManagedObject * __block managedObjectClone = nil;

	[[self managedObjectContext] performBlockAndWait:^{
		managedObjectClone = [[self managedObjectContext] existingObjectWithID:[self objectID] error:nil];
	}];

    return (managedObjectClone == nil);
}

#pragma mark - Instanciation Methods

+ (instancetype)reflectionNewInstanceWithDictionary:(NSDictionary *)dictionary
{
	return [self objectFromDictionary:dictionary];
}

+ (instancetype)objectFromDictionary:(NSDictionary *)dictionary
{
    NSAssert([self defaultManagedObjectContext], @"Please register the default managed object context for class: '%@' before using '%s'.", NSStringFromClass([self class]), __PRETTY_FUNCTION__);
	NSManagedObject * __block managedObject = nil;
    [[self defaultManagedObjectContext] performBlockAndWait:^{
		managedObject = [self objectFromDictionary:dictionary inManagedObjectContext:[self defaultManagedObjectContext]];
	}];
    return managedObject;
}

+ (instancetype)objectFromJSON:(NSString *)jsonString
{
    NSAssert([self defaultManagedObjectContext], @"Please register the default managed object context for class: '%@' before using '%s'.", NSStringFromClass([self class]), __PRETTY_FUNCTION__);

	NSManagedObject * __block managedObject = nil;
	[[self defaultManagedObjectContext] performBlockAndWait:^{
		managedObject = [self objectFromJSON:jsonString inManagedObjectContext:[self defaultManagedObjectContext]];
	}];
	return managedObject;
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
    id __block object = [self firstWithDictionary:dictionary inManagedObjectContext:context forEntityName:entityName];

    if(object == nil)
    {
        // Create a new object since there is no one like
		[context performBlockAndWait:^{
			object = [NSEntityDescription insertNewObjectForEntityForName:entityName inManagedObjectContext:context];
		}];
    }

    // Try to map the object if there is any dictionary data
    if([dictionary count] > 0)
    {
		[context performBlockAndWait:^{
			NSError *error = nil;
			if(![object mapWithDictionary:dictionary error:&error]) {
#if defined(DEBUG)
				NSLog(@"Error mapping object: %@", error);
#endif
			}
		}];
    }

	[context performBlockAndWait:^{
		// Auto-increment
		NSError *error = nil;
		NSDictionary *autoincrementedFields = [object autoincrementedFieldsDictWithError:&error];
		if (error) {
#if defined(DEBUG)
			NSLog(@"Error auto-incrementing fields: %@", error);
#endif
		}

		if(![object mapWithDictionary:autoincrementedFields error:&error]) {
#if defined(DEBUG)
			NSLog(@"Error mapping object for auto-increment fields: %@", error);
#endif
		}
	}];

    return object;
}

+ (NSArray *) objectsFromDicts:(NSArray *) dicts inManagedObjectContext:(NSManagedObjectContext *) context forEntityName:(NSString *) entityName
{
    NSMutableArray *objects = [NSMutableArray arrayWithCapacity:[dicts count]];
    for (NSDictionary *dict in dicts)
    {
        id obj = [self objectFromDictionary:dict inManagedObjectContext:context forEntityName:entityName];
        
        if(obj) {
            [objects addObject:obj];
		}
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

    if(predicate) {
        fetchRequest.predicate = predicate;
	}
    
    NSError * __block error = nil;
    
    NSUInteger __block count = 0;

	[context performBlockAndWait:^{
		count = [context countForFetchRequest:fetchRequest error:&error];
	}];

    if(error)
    {
        NSLog(@"%@", error);
    }
    
    return count;
}

+ (NSUInteger) countUniqueObjectsWithDictionary:(NSDictionary * ) dictionary inManagedObjectContext:(NSManagedObjectContext *) context forEntityName:(NSString *) entityName limit:(NSUInteger) limit
{
    NSPredicate *predicate = [NSPredicate predicateForUniquenessForClass:[self class] withDictionary:dictionary];
    return [self countInManagedObjectContext:context forEntityName:entityName withPredicate:predicate];
}

+ (instancetype) firstWithDictionary:(NSDictionary * ) dictionary inManagedObjectContext:(NSManagedObjectContext *) context forEntityName:(NSString *) entityName
{
    NSManagedObject *object = nil;
	NSString *predicateForUniquenessFormat = [NSPredicate predicateStringForUniquenessForClass:[self class] withDictionary:dictionary];
	NSString *keyWithPredicateFormat = [NSString stringWithFormat:@"%@ %@", entityName, predicateForUniquenessFormat];

#ifdef DEBUG
	static NSUInteger cacheHits = 0;
	static NSUInteger cacheMisses = 0;
	static float cacheHitRatio = 0;
#endif

	NSCache *OSRManagedObjectCache = [self OSRManagedObjectCacheForContext:context];

	object = [OSRManagedObjectCache objectForKey:keyWithPredicateFormat];

	if ([object isDeleted]) {
		[OSRManagedObjectCache removeObjectForKey:keyWithPredicateFormat];
		object = nil;
	}

	if (object) {
#ifdef DEBUG
		cacheHits++;
		if (0 == cacheHits % 50) {
			cacheHitRatio = (float)cacheHits / ((float)cacheHits + (float)cacheMisses);
		}
#endif
		return object;
	}

    NSArray *objects = [self fetchUniqueObjectsWithDictionary:dictionary inManagedObjectContext:context forEntityName:entityName limit:1 predicate:[NSPredicate predicateWithFormat:predicateForUniquenessFormat]];

    if ([objects count] > 0)
    {
        object = [objects firstObject];

		if ([object isDeleted]) {
			[OSRManagedObjectCache removeObjectForKey:keyWithPredicateFormat];
			object = nil;
			[context performBlockAndWait:^{
				[context save:nil];
			}];
		}
		else {
#ifdef DEBUG
			cacheMisses++;
#endif
			[OSRManagedObjectCache setObject:object forKey:keyWithPredicateFormat];
		}
    }
    
    return object;
}

+ (NSArray *) fetchUniqueObjectsWithDictionary:(NSDictionary * ) dictionary inManagedObjectContext:(NSManagedObjectContext *) context forEntityName:(NSString *) entityName limit:(NSUInteger) limit
{
	return [self fetchUniqueObjectsWithDictionary:dictionary inManagedObjectContext:context forEntityName:entityName limit:limit predicate:nil];
}

+ (NSArray *) fetchUniqueObjectsWithDictionary:(NSDictionary * ) dictionary inManagedObjectContext:(NSManagedObjectContext *) context forEntityName:(NSString *) entityName limit:(NSUInteger) limit predicate:(NSPredicate *)predicate
{
    NSArray * __block objects = nil;

    if([dictionary count] > 0)
    {
        NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:entityName];
        
        if(limit > 0)
        {
            request.fetchLimit = limit;
        }

		if (!predicate) {
			predicate = [NSPredicate predicateForUniquenessForClass:[self class] withDictionary:dictionary];
		}

        if(predicate)
        {
            request.predicate = predicate;

			NSError * __block error = nil;
			[context performBlockAndWait:^{
				objects = [context executeFetchRequest:request error:&error];
			}];
        }
    }
    
    return objects;
}

+ (NSArray *) fetchWithPredicate:(NSPredicate *) predicate sortDescriptors:(NSArray *) sortDescriptors limit:(NSUInteger) limit
{
    NSAssert([self defaultManagedObjectContext], @"Please register the default managed object context for class: '%@' before using '%s'.", NSStringFromClass([self class]), __PRETTY_FUNCTION__);
    
    NSArray * __block objects = nil;
    
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:[self entityName]];
    
    if(limit > 0) {
        request.fetchLimit = limit;
	}
    
    if(sortDescriptors) {
        request.sortDescriptors = sortDescriptors;
	}
    
    if(predicate) {
        request.predicate = predicate;
	}
    
    NSError * __block error = nil;

	[[self defaultManagedObjectContext] performBlockAndWait:^{
		objects = [[self defaultManagedObjectContext] executeFetchRequest:request error:&error];
	}];

    return objects;
}

+ (NSArray *) fetchWithPredicate:(NSPredicate *) predicate limit:(NSUInteger) limit
{
    return [self fetchWithPredicate:predicate sortDescriptors:nil limit:limit];
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
    if(autoincrementedFields) {
        [self mapWithDictionary:autoincrementedFields error:error];
	}

	BOOL __block didSave = NO;
	[context performBlockAndWait:^{
		didSave = [context save:error];
	}];

    return didSave;
}

#pragma mark - Private Methods

- (NSDictionary *) autoincrementedFieldsDictWithError:(NSError **) error
{
    BOOL success = YES;
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
            NSArray *items = [[self class] fetchWithPredicate:nil
                                              sortDescriptors:@[[NSSortDescriptor sortDescriptorWithKey:autoincrementField ascending:NO]]
                                                        limit:1];
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
    
    if(*error && [ignoredFields count] > 0)
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
