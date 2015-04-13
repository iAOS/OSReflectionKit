//
//  TestModel.h
//  OSReflectionKitExample
//
//  Created by Alexandre on 18/02/14.
//  Copyright (c) 2014 iAOS Software. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TestNestedModel.h"

@interface TestModel : NSObject

// NSObjects
@property (nonatomic, strong) NSString *string;
@property (nonatomic, strong) NSNumber *number;
@property (nonatomic, strong) NSArray *array;
@property (nonatomic, strong) NSSet *set;
@property (nonatomic, strong) NSDictionary *dict;
@property (nonatomic, strong) NSDate *date;
@property (nonatomic, strong) NSDecimalNumber *decimalNumber;

// Custom Nested NSObjects

@property (nonatomic, strong) TestNestedModel *nestedModel;

// Primitives
@property (nonatomic) NSInteger integer;
@property (nonatomic) CGFloat floating;

// Custom value transformation
@property (nonatomic, strong) NSString *transformedFromNumber;

// Mock helpers
+ (NSDictionary *) mockDictionary;
+ (NSDictionary *) specialMockDictionary;

@end
