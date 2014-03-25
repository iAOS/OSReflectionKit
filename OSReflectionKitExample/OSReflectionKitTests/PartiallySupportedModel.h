//
//  PartiallySupportedModel.h
//  OSReflectionKitExample
//
//  Created by Alexandre on 24/03/14.
//  Copyright (c) 2014 iAOS Software. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface PartiallySupportedModel : NSObject

// NSObjects
@property (nonatomic, strong) NSString *string;
@property (nonatomic, strong) NSNumber *number;
@property (nonatomic, strong) NSArray *array;
@property (nonatomic, strong) NSSet *set;
@property (nonatomic, strong) NSDictionary *dict;
@property (nonatomic, strong) NSDate *date;

// Primitives
@property (nonatomic) NSInteger integer;
@property (nonatomic) CGFloat floating;

// Custom value transformation
@property (nonatomic, strong) NSString *transformedFromNumber;

// Unsupported attributes: will not be serialized/deserialized
@property (nonatomic) CGPoint point;
@property (nonatomic) CFStringRef stringRef;

// Mock helpers
+ (NSDictionary *) mockDictionary;
+ (NSDictionary *) specialMockDictionary;

@end
