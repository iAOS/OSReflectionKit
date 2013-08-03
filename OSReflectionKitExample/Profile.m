//
//  Category.m
//  OSReflectionKitExample
//
//  Created by Alexandre on 03/08/13.
//  Copyright (c) 2013 iAOS Software. All rights reserved.
//

#import "Profile.h"

@implementation Profile

/*
 {
     "id":1,
     "name":"Alexandre Santos",
     "first_name":"Alexandre",
     "last_name":"Santos",
     "points":232323,
     "birthday" : "1983-01-31",
     "hobbies":[
         "reading",
         "cinema",
         "soccer",
         "snowboard",
         "programming"
     ],
     "address":{
         "street"   : "1000 Market Street",
         "suite"    : null,
         "city"     : "San Francisco",
         "state"    : "CA",
         "zip_code" : "94102"
     }
 }
 */

+ (NSDictionary *)reflectionMapping
{
    // You need to map only the keys that are different of the property name
    // or if you have a complex property, like for Address in this example
    return @{@"id" : @"profileId",
             @"first_name" : @"firstName",
             @"last_name" : @"lastName",
             @"address" : @"address,<Address>" // The <> indicates the class name of the complex property
             };
}

- (void)reflectionTranformsValue:(id)value forKey:(NSString *)propertyName
{
}

@end
