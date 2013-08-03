//
//  Address.h
//  OSReflectionKitExample
//
//  Created by Alexandre on 03/08/13.
//  Copyright (c) 2013 iAOS Software. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "NSObject+OSReflectionKit.h"

@interface Address : NSObject

@property (nonatomic, strong) NSString *street;
@property (nonatomic, strong) NSString *suite;
@property (nonatomic, strong) NSString *city;
@property (nonatomic, strong) NSString *state;
@property (nonatomic, strong) NSString *zipCode;

@end
