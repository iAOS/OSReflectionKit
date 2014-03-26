//
//  AZReflectionHint.h
//  Reflections
//
//  Created by Alexander Zats on 5/4/12.
//  Copyright (c) 2012 Alexander Zats. All rights reserved.
//
//  Extended by Alexandre Santos
//

#import <Foundation/Foundation.h>

@protocol AZReflectionHint <NSObject>
@optional

/**
 Custom factory method, should return fully initialized instance of the class
 */
+ (id)reflectionNewInstanceWithDictionary:(NSDictionary *)dictionary;

/**
 Returns dictionary containing hints for the mapping process
 Example of the valid mapping:
 
 [NSDictionary dictionaryWithObjectsAndKeys:
	 @"contactID", @"id",
	 @"userObjects,<MyUserObject>", @"users",
	 @"email,<MyEmail>,*", @"email",
 nil];
 
 @discussion
 While the last value is completely valid, class can be avoided in this case, 
 since protocol method reflectionTranformsValue:forKey: will be called.
 
 Specifying custom <class> makes sence when you expect to get a nested object 
 or an array of object in the response. 
 For other usecases custom class will be ignored
 */
+ (NSDictionary *)reflectionMapping;

/**
 Method is being so instance can handle assigning on its own, e.g. when a custom 
 type mapping is needed.
 */
- (void)reflectionTranformsValue:(id)value forKey:(NSString *)propertyName;

/**
 If implemented this method will be called after all other assignment types 
 have failed
 */
- (void)reflectionValue:(id)value forUnkownKey:(NSString *)key;

/**
 If implemented, this method will be called when an error occurs during mapping.
 
 @param error        The `NSError` object containing the error data.
 @param value        The object/value to be assigned to the `key`.
 @param propertyName The property name to assign the object/value.
 */
- (void) reflectionMappingError:(NSError *) error withValue:(id) value forKey:(NSString *) propertyName;

@end
