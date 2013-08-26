//
//  NSObject+OSReflectionKit.m
//  OSReflectionKit
//
//  Created by Alexandre on 04/02/13.
//  Copyright (c) 2013 iAOS Software. All rights reserved.
//
// This class uses ARC

#import "NSObject+OSReflectionKit.h"
#import "AZReflection.h"

@implementation NSObject (OSReflectionKit)

#pragma mark - Instanciation Methods

+ (instancetype) object
{
    return [[self alloc] init];
}

+ (id) objectFromDictionary:(NSDictionary *) dictionary
{
    return [self reflectionMapWithDictionary:dictionary error:nil];
}

+ (NSArray *) objectsFromDicts:(NSArray *) dicts
{
    NSMutableArray *objects = [NSMutableArray arrayWithCapacity:[dicts count]];
    for (NSDictionary *dict in dicts)
    {
        id obj = [self objectFromDictionary:dict];
        
        if(obj)
            [objects addObject:obj];
    }
    
    return [objects copy];
}

+ (instancetype) objectFromJSON:(NSString *)jsonString
{
    return [self objectFromJSON:jsonString error:nil];
}

+ (instancetype)objectFromJSON:(NSString *)jsonString error:(NSError **)error
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
        return [self objectFromDictionary:dictionary];
    }
    
    return nil;
}

+ (NSArray *)objectsFromJSONArray:(NSString *)jsonArray
{
    return [self objectsFromJSONArray:jsonArray error:nil];
}

+ (NSArray *)objectsFromJSONArray:(NSString *)jsonArray error:(NSError **)error
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
        return [self objectsFromDicts:arrayDicts];
    }
    
    return nil;
}

#pragma mark - Class Reflection

+ (NSArray *) propertyNames
{
    NSDictionary *dic = [self classProperties];
    NSSortDescriptor *sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:nil ascending:YES selector:@selector(compare:)];
    NSArray *names = [[dic allKeys] sortedArrayUsingDescriptors:[NSArray arrayWithObject:sortDescriptor]];
    
    return names;
}

+ (NSArray *) simpleTypesPropertyNames
{
    NSArray *propertyNames = [self propertyNames];
    NSMutableArray *simpleTypesPropertyNames = [NSMutableArray arrayWithCapacity:[propertyNames count]];
    
    for (NSString *propertyName in propertyNames)
    {
        Class propertyClass = [self classForProperty:propertyName];
        if([propertyClass isSubclassOfClass:[NSArray class]] || [propertyClass isSubclassOfClass:[NSDictionary class]])
        {
            // Complex property... ignoring...
        }
        else
        {
            [simpleTypesPropertyNames addObject:propertyName];
        }
    }
    return [simpleTypesPropertyNames copy];
}

+ (NSUInteger) propertyCount
{
    return [[self propertyNames] count];
}

+ (NSArray*) propertyNamesOfType:(Class) klass
{
    NSArray* properties = [self propertyNames];
    NSMutableArray* arrayProperties = [NSMutableArray array];
    
    for (NSString* p in properties) {
        Class pClass = [self classForProperty:p];
        if ([pClass isSubclassOfClass:klass])
            [arrayProperties addObject:p];
    }
    
    return [arrayProperties copy];
}

#pragma mark - Instance Reflection

- (NSArray *) valuesForPropertyNames:(NSArray *) propertyNames
{
    NSMutableArray *values = [NSMutableArray arrayWithCapacity:[propertyNames count]];
    
    for(NSString *property in propertyNames)
    {
        NSObject *value = nil;

        value = [self valueForKey:property];
        
        // Sets a NSNull object case the value is nil in order to assure the same amount of items than found in the properties array
        if(value == nil)
            value = [NSNull null];
        
        [values addObject:value];
    }
    
    return [values copy];
}

- (NSDictionary *) dictionary
{
    NSArray *propertyNames = [[self class] propertyNames];
    NSDictionary *_dic = [NSDictionary dictionaryWithObjects:[self valuesForPropertyNames:propertyNames] forKeys:propertyNames];
    
    return _dic;
}

- (NSDictionary *) dictionaryForNonNilProperties
{
    NSArray *propertyNames = [[self class] propertyNames];
    NSMutableDictionary *_dic = [NSMutableDictionary dictionaryWithCapacity:[propertyNames count]];
    for (NSString *property in propertyNames)
    {
        id value = [self valueForKey:property];
        if(value)
        {
            [_dic setObject:value forKey:property];
        }
    }
    
    return [_dic copy];
}

- (NSDictionary *) dictionaryWithDatesAsStringsFromDict:(NSDictionary *) dict
{
    NSMutableDictionary *dictionary = [dict mutableCopy];
    
    // In some cases, like for JSON, which does not accept date objects, we need to convert all NSDate objects to strings first
    NSArray *dateProperties = [[self class] propertyNamesOfType:[NSDate class]];
    NSDateFormatter *df = [[NSDateFormatter alloc] init];

    // TODO: Allow to set the date format
    [df setDateFormat:@"yyyy-MM-dd HH:mm:ss Z"];
    for (NSString *property in dateProperties)
    {
        // Convert date to NSString
        NSDate *date = [self valueForKey:property];
        if([date isKindOfClass:[NSDate class]])
        {
            NSString *dateString = [df stringFromDate:date];
            [dictionary setObject:dateString forKey:property];
        }
    }
    
    return dictionary;
}

- (NSDictionary *) dictionaryForNonNilPropertiesAndDatesAsStrings
{
    NSMutableDictionary *dictionary = [[self dictionaryForNonNilProperties] mutableCopy];
    
    // In some cases, like for JSON, which does not accept date objects, we need to convert all NSDate objects to strings first
    NSArray *dateProperties = [[self class] propertyNamesOfType:[NSDate class]];
    NSDateFormatter *df = [[NSDateFormatter alloc] init];
    
    // TODO: Allow to set the date format
    [df setDateFormat:@"yyyy-MM-dd HH:mm:ss Z"];
    for (NSString *property in dateProperties)
    {
        // Convert date to NSString
        NSDate *date = [self valueForKey:property];
        if([date isKindOfClass:[NSDate class]])
        {
            NSString *dateString = [df stringFromDate:date];
            [dictionary setObject:dateString forKey:property];
        }
    }
    
    return dictionary;
}

- (NSString *)JSONString
{
    return [self JSONString:nil];
}

- (NSString *)JSONString:(NSError **)error
{
    NSDictionary *dictionary = [self dictionaryWithDatesAsStringsFromDict:[self dictionary]];
    
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:dictionary options:NSJSONWritingPrettyPrinted error:error];
    NSString *resultAsString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    
    return resultAsString;
}

- (NSString *)reverseJSONString
{
    return [self reverseJSONString:nil];
}

- (NSString *)reverseJSONString:(NSError **)error
{
    NSDictionary *dictionary = [self dictionaryWithDatesAsStringsFromDict:[self reverseDictionaryWithError:error]];
    
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:dictionary options:NSJSONWritingPrettyPrinted error:error];
    NSString *resultAsString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    
    return resultAsString;
}

- (NSString *)JSONStringForNonNilProperties
{
    return [self JSONStringForNonNilProperties:nil];
}

- (NSString *)JSONStringForNonNilProperties:(NSError **)error
{
    NSDictionary *dictionary = [self dictionaryForNonNilPropertiesAndDatesAsStrings];

    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:dictionary options:NSJSONWritingPrettyPrinted error:error];
    NSString *resultAsString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    
    return resultAsString;
}

- (NSString *) fullDescription
{
    return [[self dictionary] description];
}

#pragma mark - NSCopying implementation

- (id)copyWithZone:(NSZone *)zone
{
    id object = [[self class] objectFromDictionary:[self dictionary]];
    
    return object;
}

#pragma mark - NSCoding implementation

- (void)encodeWithCoder:(NSCoder *)coder
{
    NSDictionary *dictionary = [self dictionary];
    
    [dictionary enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
        [coder encodeObject:obj forKey:key];
    }];
}

- (id)initWithCoder:(NSCoder *)decoder
{
    self = [self init];
    if (self)
    {
        NSArray *properties = [[self class] propertyNames];
        
        for (NSString *property in properties)
        {
            id value = [decoder decodeObjectForKey:property];
            if(value)
            {
                [self setValue:value forKey:property];
            }
        }
    }
    
    return self;
}

@end