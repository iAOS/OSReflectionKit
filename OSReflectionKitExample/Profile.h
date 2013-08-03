//
//  Category.h
//  OSReflectionKitExample
//
//  Created by Alexandre on 03/08/13.
//  Copyright (c) 2013 iAOS Software. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "NSObject+OSReflectionKit.h"
#import "Address.h"

@interface Profile : NSObject

@property (nonatomic, strong) NSNumber *profileId;
@property (nonatomic, strong) NSString *name;
@property (nonatomic, strong) NSString *firstName;
@property (nonatomic, strong) NSString *lastName;
@property (nonatomic) NSInteger points;
@property (nonatomic, strong) NSDate *birthday;
@property (nonatomic, strong) NSArray *hobbies;
@property (nonatomic, strong) Address *address;

@end
