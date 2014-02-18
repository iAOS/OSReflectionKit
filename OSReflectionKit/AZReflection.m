//
//  AZReflectionMapper.m
//  Reflections
//
//  Created by Alexander Zats on 5/9/12.
//
//  Extended on 22/08/2012
//  Alexandre O. Santos
//  Copyright (c) 2012 iAOS Software. All rights reserved.
//

#import "AZReflection.h"
#import <objc/runtime.h>
#import "AZReflectionHint.h"

@interface AZReflection ()

// Shortcut NSError factory
static inline NSError *ReflectionMapperError(NSString *errorMessage, ...);

// Method performs type strict assignment
- (BOOL)assignValue:(id)value instance:(id)instance key:(NSString *)key propertyClass:(Class)propertyClass error:(NSError **)error;

// Structure encapsulating all information about property class
// (can't use) just a Class since we can have primitive classes as well
struct property_attributes_t {
	BOOL valid;
	BOOL readonly;
	BOOL primitive;
	BOOL primitivePointer;
	// If not primitive, contains reference to the class
	Class classReference;
	// If primitive, contains selector that extracts primitive value
	SEL primitiveValueSelector;
};

// Functions extract information about the property / ivar, so we can be sure that value is the same type as property
static inline void GetPropertyClassWrapper(objc_property_t property, struct property_attributes_t *answer);
static inline void GetIvarClassWrapper(Ivar ivar, struct property_attributes_t *answer);
static inline void GetPropertyClassWrapperType(char *attributeCString, struct property_attributes_t *answer);

// ReflectionHintsMapper
static inline void ParseMappingHint(NSString *mappingString, NSString **key, BOOL *usesTransformer, NSString **customClass);
static inline void ParseReverseMappingHint(NSDictionary *mapping, NSString *propertyName, NSString **key, NSString **customClass, BOOL *usesTransformer);

@end

@implementation AZReflection

NSString *const AZReflectionMapperErrorDomain = @"AZReflectionMapperErrorDomain";

+ (AZReflection *)sharedReflectionMapper
{
	static AZReflection *instance;
	static dispatch_once_t onceToken;
	dispatch_once(&onceToken, ^{
		instance = [[AZReflection alloc] init];
	});
	return instance;
}

- (id)reflectionMapWithDictionary:(NSDictionary *)dictionary rootClass:(Class)classReference error:(NSError **)error
{
	if (!dictionary || ![dictionary isKindOfClass:[NSDictionary class]] || !classReference) {
        if(error)
            *error = ReflectionMapperError(@"Both map dictionary (%@) and root class (%@) must be not nil", dictionary, classReference);
		return nil;
	}

	id instance = nil;
	
	BOOL classHasProtocolFactoryMethod = class_conformsToProtocol(classReference, @protocol(AZReflectionHint)) && [(id)classReference respondsToSelector:@selector(reflectionNewInstanceWithDictionary:)];
	// Can we use class as instance factory?
	if (classHasProtocolFactoryMethod) {
		instance = [classReference reflectionNewInstanceWithDictionary:dictionary];
	} else {
		// Otherwise default to
		instance = [[classReference alloc] init];
	}
	
	if (!instance) {
		// Failed to create instance, quit
        if(error)
            *error = ReflectionMapperError(@"Failed to create an instance of class %@%@", classReference, classHasProtocolFactoryMethod ? @". Class has a custom hint factory reflectionNewInstanceWithDictionary:" : @"");
		return nil;
	}

    [self mapObject:instance withDictionary:dictionary rootClass:classReference error:error];
    
	return instance;
}

- (BOOL) mapObject:(id) instance withDictionary:(NSDictionary *)dictionary rootClass:(Class)classReference error:(NSError **)error
{
    __block BOOL success = YES;
    
	// Do we have any hints implemented?
	NSDictionary *mapping = nil;
	if ([(id)classReference respondsToSelector:@selector(reflectionMapping)])
    {
		mapping = [classReference reflectionMapping];
	}
	
	// Now iterate through all key/value pairs
	[dictionary enumerateKeysAndObjectsUsingBlock:^(NSString *key, id obj, BOOL *stop) {
        
        unichar c = [[key lowercaseString] characterAtIndex:0];
        key = [key stringByReplacingCharactersInRange:NSMakeRange(0, 1) withString:[NSString stringWithCharacters:&c length:1]];
        
		// Due to language limitations we can't store nil in the dictionary,
		// that's why obj-c uses artificial [NSNull null] to accomodate
		if (obj == [NSNull null])
        {
			obj = nil;
		}
		
		if (!mapping || ![mapping valueForKey:key])
        {
			// assign directly to the instance
			if(![self assignValue:obj instance:instance key:key propertyClass:nil error:error])
            {
                // TODO: Automatically lower camelize the key and try again
                //[self assignValue:obj instance:instance key:[key lowerCamelize] propertyClass:nil error:error];
                success = NO;
                
                *stop = YES;
            }
		}
        else
        {
			// we might have a mapping function
			NSString *mappingHint = [mapping valueForKey:key];
			BOOL usesTransformer = NO;
			NSString *customClassString = nil;
			ParseMappingHint(mappingHint, &key, &usesTransformer, &customClassString);
			if (usesTransformer && [instance respondsToSelector:@selector(reflectionTranformsValue:forKey:)])
            {
				[instance reflectionTranformsValue:obj forKey:key];
			}
            else
            {
				if(![self assignValue:obj instance:instance key:key propertyClass:NSClassFromString(customClassString) error:error])
                {
                    success = NO;
                    *stop = YES;
                }
			}
		}
	}];
    
    return success;
}

- (NSDictionary *) dictionaryForObject:(id) instance error:(NSError **)error
{
	// Do we have any hints implemented?
    Class classReference = [instance class];
	NSDictionary *mapping = nil;
	if ([(id)classReference respondsToSelector:@selector(reflectionMapping)])
    {
		mapping = [classReference reflectionMapping];
	}

    NSDictionary *classProperties = [classReference classProperties];
    NSMutableDictionary *dictionary = [NSMutableDictionary dictionaryWithCapacity:[classProperties count]];
	// Now iterate through all key/value pairs
	[classProperties enumerateKeysAndObjectsUsingBlock:^(NSString *propertyName, id propertyType, BOOL *stop) {
        
        id obj = [instance valueForKey:propertyName];
        
		// Due to language limitations we can't store nil in the dictionary,
		// that's why obj-c uses artificial [NSNull null] to accomodate
		if (obj == nil)
        {
			obj = [NSNull null];
		}

        // we might have a mapping function
        NSString *customClassString = nil;
        NSString *key = nil;
        BOOL usesTransformer = NO;
        ParseReverseMappingHint(mapping, propertyName, &key, &customClassString, &usesTransformer);
        
		if (key)
        {
            if(customClassString)
            {
                // Complex property
                NSError *error = nil;
                NSDictionary *subObject = [self dictionaryForObject:obj error:&error];
                
                if(subObject)
                    [dictionary setObject:subObject forKey:key];
                else
                    NSLog(@"Error while serializing object: %@ : Error: %@", obj, [error localizedDescription]);
            }
            else
            {        
                [dictionary setObject:obj forKey:key];
            }
		}
        else
        {
			// assign directly to the dictionary
            [dictionary setObject:obj forKey:propertyName];
		}
	}];
    
    return [dictionary copy];
}

- (BOOL)assignValue:(id)value instance:(id)instance key:(NSString *)key propertyClass:(Class)propertyClass error:(NSError **)error
{
	const char *keyChar = [key UTF8String];
	Class instanceClass = [instance class];

	BOOL instanceImplementsUnknownKey = [instance respondsToSelector:@selector(reflectionValue:forUnkownKey:)];
	
	void(^assignmentBlock)(struct property_attributes_t attributes) = ^(struct property_attributes_t attributes){
		// Actual value assigning happens here
		if ([value isKindOfClass:[NSDictionary class]]) {
			if (propertyClass) {
				// it's a custom class
				[instance setValue:[self reflectionMapWithDictionary:value rootClass:propertyClass error:error] forKey:key];				
			} else {
				[instance setValue:value forKey:key];								
			}
		} else if ([value isKindOfClass:[NSArray class]]) {
            
			if (propertyClass) {
				// it's an array of custom classes
				NSMutableArray *array = [NSMutableArray arrayWithCapacity:((NSArray *)value).count];
				for (id subvalue in value) {
					[array addObject:[self reflectionMapWithDictionary:subvalue rootClass:propertyClass error:error]];
				}
                
                id objValue = array;
                
                // Convert the NSArray into NSSet according to the property type
                if([[[instance class] classForProperty:key] isSubclassOfClass:[NSSet class]])
                {
                    objValue = [NSSet setWithArray:array];
                }
                
				[instance setValue:objValue forKey:key];
			} else {
                id objValue = value;
                
                // Convert the NSArray into NSSet according to the property type
                if([[[instance class] classForProperty:key] isSubclassOfClass:[NSSet class]])
                {
                    objValue = [NSSet setWithArray:value];
                }
                
				[instance setValue:objValue forKey:key];
			}
		} else {
			// check types 
			if (attributes.primitive && [value isKindOfClass:[NSValue class]]) {
				// primitive values are expected to be wrapped into NSNumber or NSValue
				[instance setValue:value forKey:key];
			} else if (!value && attributes.primitive) {
                // primitive values are expected to be wrapped into NSNumber or NSValue
				[instance setValue:@0 forKey:key];
			} else if (!value || [value isKindOfClass:attributes.classReference]) {
				[instance setValue:value forKey:key];
			} else if ([NSDate class] == attributes.classReference) {
                NSDateFormatter* formatter = [[NSDateFormatter alloc] init];
                
                if ([value isKindOfClass:[NSNumber class]])
                {
                    NSDate* date;
                    date = [NSDate dateWithTimeIntervalSince1970:[value doubleValue]];
                    
                    [instance setValue:date forKey:key];
                }
                else if ([value isKindOfClass:[NSString class]])
                {
                    NSString *dateString = value;
                    
                    if ([value length] == 10)
                        [formatter setDateFormat:@"yyyy-MM-dd"];
                    else if ([value length] <= 19)
                        [formatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
                    else
                    {
                        // Ruby on Rails compatibility for date formatted like: 2011-07-20T23:59:00-07:00
                        dateString = [value stringByReplacingOccurrencesOfString:@":" withString:@""];
                        [formatter setDateFormat:@"yyyy-MM-dd'T'HHmmssZZ"];
                    }
                    
                    [instance setValue:[formatter dateFromString:dateString] forKey:key];
                }
            
			}
			
		}
		
	};

	// Check for property
	objc_property_t property = class_getProperty(instanceClass, keyChar);
	struct property_attributes_t attributes;
	if (property) {
		GetPropertyClassWrapper(property, &attributes);
		
		if (attributes.valid && !attributes.readonly) {
			assignmentBlock(attributes);
			return YES;
		}		
	}
	
	// Check for ivar
	Ivar ivar = class_getInstanceVariable(instanceClass, keyChar);
	if (ivar) {
		GetIvarClassWrapper(ivar, &attributes);
		if (attributes.valid) {
			assignmentBlock(attributes);			
			return YES;
		}
	}
	
	if (instanceImplementsUnknownKey) {
		[instance reflectionValue:value forUnkownKey:key];
	}
	
	return NO;
}

static inline void GetPropertyClassWrapper(objc_property_t property, struct property_attributes_t *answer)
{
	// Some default values
	*answer = (struct property_attributes_t){
		.primitive = YES,
		.primitivePointer = NO,
		.valid = YES,
		.readonly = NO
	};	
	
	char *attributeCString = property_copyAttributeValue(property, "R");
	if (attributeCString) {
		(*answer).readonly = YES;
		return;
	}
	
	attributeCString = property_copyAttributeValue(property, "T");
	
	GetPropertyClassWrapperType(attributeCString, answer);
    free(attributeCString);
}

static inline void GetIvarClassWrapper(Ivar ivar, struct property_attributes_t *answer)
{
	// Some default values
	*answer = (struct property_attributes_t){
		.primitive = YES,
		.primitivePointer = NO,
		.valid = YES,
		.readonly = NO
	};
	
	const char *attributeCString = ivar_getTypeEncoding(ivar);	
	GetPropertyClassWrapperType((char *)attributeCString, answer);
}

static inline void GetPropertyClassWrapperType(char *attributeCString, struct property_attributes_t *answer)
{
	if (!attributeCString) {
		(*answer).valid = NO;
		return;
	}
	
	NSString *attributeString = [NSString stringWithUTF8String:attributeCString];
	
	if (attributeString.length < 1) {
		(*answer).valid = NO;
		return;
	}
	
	unichar character = [attributeString characterAtIndex:0];
	if (character == _C_PTR) {
		(*answer).primitivePointer = YES;
		if (attributeString.length < 3) {
			(*answer).valid = NO;
			return;
		}
		character = [attributeString characterAtIndex:1];
	} else if (character == _C_ID) {
		(*answer).primitive = NO;
		(*answer).primitivePointer = NO;
		if (attributeString.length == 1) {
			// just an id class
			return;
		}
		// T@"NSNumber"
		if (attributeString.length < 4) {
			(*answer).valid = NO;
			return;
		}
		Class classReference = NSClassFromString([attributeString substringWithRange:NSMakeRange(2, attributeString.length - 3)]);
		if (!classReference) {
			(*answer).valid = NO;
			return;
		} else {
			(*answer).classReference = classReference;
			return;
		}
		
	} else if (character == _C_STRUCT_B) {
		// TODO
		// @property struct YorkshireTeaStruct structDefault;
		// T{YorkshireTeaStruct="pot"i"lady"c},VstructDefault
	} else if (character == _C_UNION_B) {
		// TODO
		// @property union MoneyUnion unionDefault;
		// T(MoneyUnion="alone"f"down"d),VunionDefault
	} else if (character == _C_ARY_B) {
		// TODO
		// array?
	}
	
	switch (character) {
		case _C_CHR:
			(*answer).primitiveValueSelector = @selector(charValue);
			break;
		case _C_UCHR:
			(*answer).primitiveValueSelector = @selector(unsignedCharValue);
			break;
		case _C_INT:
			(*answer).primitiveValueSelector = @selector(intValue);
			break;
		case _C_UINT:
			(*answer).primitiveValueSelector = @selector(unsignedIntValue);
			break;
		case _C_FLT:
			(*answer).primitiveValueSelector = @selector(floatValue);
			break;
		case _C_LNG:
			(*answer).primitiveValueSelector = @selector(longValue);
			break;
		case _C_ULNG:
			(*answer).primitiveValueSelector = @selector(unsignedLongValue);
			break;
		case _C_SHT:
			(*answer).primitiveValueSelector = @selector(shortValue);
			break;
		case _C_USHT:
			(*answer).primitiveValueSelector = @selector(unsignedShortValue);
			break;
		case _C_LNG_LNG:
			(*answer).primitiveValueSelector = @selector(longLongValue);
			break;
		case _C_ULNG_LNG:
			(*answer).primitiveValueSelector = @selector(unsignedLongLongValue);
			break;
		case _C_DBL:
			(*answer).primitiveValueSelector = @selector(doubleValue);
			break;
		case _C_BOOL:
			(*answer).primitiveValueSelector = @selector(boolValue);
			break;
		default:
			(*answer).valid = NO;				
			return;
	}	
}

static inline void ParseMappingHint(NSString *mappingString, NSString **key, BOOL *usesTransformer, NSString **customClass)
{
	NSArray *mappingHintArray = [mappingString componentsSeparatedByString:@","];
	for (NSString *mappingHint in mappingHintArray) {
		if ([mappingHint isEqualToString:@"*"]) {
			*usesTransformer = YES;
		} else if ([mappingHint hasPrefix:@"<"]) {
			*customClass = [mappingHint substringWithRange:NSMakeRange(1, mappingHint.length-2)];
		} else {
			*key = mappingHint;
		}
	}
}

static inline void ParseReverseMappingHint(NSDictionary *mapping, NSString *propertyName, NSString **key, NSString **customClass, BOOL *usesTransformer)
{
    NSArray *keys = [mapping allKeys];
    
    for (NSString *mappingKey in keys)
    {
        NSString *mappingString = [mapping objectForKey:mappingKey];
        NSArray *mappingHintArray = [mappingString componentsSeparatedByString:@","];
        if([mappingHintArray containsObject:propertyName])
        {
            for (NSString *mappingHint in mappingHintArray)
            {
                if ([mappingHint isEqualToString:@"*"])
                {
                    *usesTransformer = YES;
                }
                else if ([mappingHint hasPrefix:@"<"])
                {
                    *customClass = [mappingHint substringWithRange:NSMakeRange(1, mappingHint.length-2)];
                }
                else if ([mappingHint isEqualToString:propertyName])
                {
                    *key = mappingKey;
                }
            }
            break;
        }

    }
}

static inline NSError *ReflectionMapperError(NSString *errorMessage, ...)
{
	va_list arguments;	
	va_start(arguments, errorMessage);
	NSString *errorString = [[NSString alloc] initWithFormat:NSLocalizedString(errorMessage, nil) arguments:arguments];
	va_end(arguments);
	return [NSError errorWithDomain:AZReflectionMapperErrorDomain code:NSUIntegerMax userInfo:[NSDictionary dictionaryWithObject:errorString forKey:NSLocalizedDescriptionKey]];
}

#pragma mark - Properties

static const char * getPropertyType(objc_property_t property) {
    const char *attributes = property_getAttributes(property);
//    printf("attributes=%s\n", attributes);
    char buffer[1 + strlen(attributes)];
    strcpy(buffer, attributes);
    char *state = buffer, *attribute;
    while ((attribute = strsep(&state, ",")) != NULL) {
        if (attribute[0] == 'T' && attribute[1] != '@') {
            // it's a C primitive type:
            /*
             if you want a list of what will be returned for these primitives, search online for
             "objective-c" "Property Attribute Description Examples"
             apple docs list plenty of examples of what you get for int "i", long "l", unsigned "I", struct, etc.
             */
            return (const char *)[[NSData dataWithBytes:(attribute + 1) length:strlen(attribute) - 1] bytes];
        }
        else if (attribute[0] == 'T' && attribute[1] == '@' && strlen(attribute) == 2) {
            // it's an ObjC id type:
            return "id";
        }
        else if (attribute[0] == 'T' && attribute[1] == '@') {
            // it's another ObjC object type:
            return (const char *)[[NSData dataWithBytes:(attribute + 3) length:strlen(attribute) - 4] bytes];
        }
    }
    return "";
}

@end

@implementation NSObject (AZReflectionMapper)

+ (NSDictionary *) classProperties
{
    Class klass = self;
    
    NSMutableDictionary *results = [[NSMutableDictionary alloc] init];
    
    unsigned int outCount, i;
    objc_property_t *properties = class_copyPropertyList(klass, &outCount);
    for (i = 0; i < outCount; i++) {
        objc_property_t property = properties[i];
        const char *propName = property_getName(property);
        if(propName)
        {
            const char *propType = getPropertyType(property);
            NSString *propertyName = [NSString stringWithUTF8String:propName];
            NSString *propertyType = [[NSString alloc] initWithCString:propType encoding:NSASCIIStringEncoding];
            if(propertyType)
                [results setObject:propertyType forKey:propertyName];
        }
    }
    free(properties);
    
    // returning a copy here to make sure the dictionary is immutable
    return [NSDictionary dictionaryWithDictionary:results];
}

+ (id)reflectionMapWithDictionary:(NSDictionary *)dictionary error:(NSError **)error
{
	return [[AZReflection sharedReflectionMapper] reflectionMapWithDictionary:dictionary rootClass:[self class] error:error];
}

- (BOOL) mapWithDictionary:(NSDictionary *)dictionary
{
    return [self mapWithDictionary:dictionary error:nil];
}

- (BOOL) mapWithDictionary:(NSDictionary *)dictionary error:(NSError **)error
{
    return [[AZReflection sharedReflectionMapper] mapObject:self withDictionary:dictionary rootClass:[self class] error:error];
}

- (NSDictionary *)reverseDictionary
{
    return [self reverseDictionaryWithError:nil];
}

- (NSDictionary *) reverseDictionaryWithError:(NSError **) error
{
    return [[AZReflection sharedReflectionMapper] dictionaryForObject:self error:error];
}

+ (Class) classForProperty:(NSString *) propertyName
{
    // Check for property
	objc_property_t property = class_getProperty([self class], [propertyName UTF8String]);
	struct property_attributes_t attributes;
	if (property)
    {
		GetPropertyClassWrapper(property, &attributes);
		
        return attributes.classReference;
	}
    
    return nil;
}

- (BOOL) setValue:(id) value forProperty:(NSString *) propertyName
{
    return [self setValue:value forProperty:propertyName error:nil];
}

- (BOOL) setValue:(id) value forProperty:(NSString *) propertyName error:(NSError **) error
{
    return [[AZReflection sharedReflectionMapper] assignValue:value instance:self key:propertyName propertyClass:[[self class] classForProperty:propertyName] error:error];
}

@end