//
//  Address.m
//  OSReflectionKitExample
//
//  Created by Alexandre on 03/08/13.
//  Copyright (c) 2013 iAOS Software. All rights reserved.
//

#import "Address.h"

@implementation Address

/*
 Sample JSON for the Address:
 
 {
     "street"   : "1000 Market Street",
     "suite"    : null,
     "city"     : "San Francisco",
     "state"    : "CA",
     "zip_code" : "94102"
 }
 */

+ (NSDictionary *)reflectionMapping
{
    return @{@"zip_code" : @"zipCode"};
}

@end
