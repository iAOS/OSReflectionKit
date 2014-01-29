//
//  Event.h
//  OSReflectionKit+CoreDataExample
//
//  Created by Alexandre on 29/01/14.
//  Copyright (c) 2014 iAOS Software. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import "NSManagedObject+OSReflectionKit.h"

@interface Event : NSManagedObject

@property (nonatomic, retain) NSDate * timeStamp;
@property (nonatomic, retain) NSNumber * eventId;

@end
