//
//  Event.h
//  OSReflectionKit+CoreDataExample
//
//  Created by Alexandre on 05/08/13.
//  Copyright (c) 2013 iAOS Software. All rights reserved.
//

#import <CoreData/CoreData.h>
#import "NSManagedObject+OSReflectionKit.h"

@interface Event : NSManagedObject

@property (nonatomic, strong) NSDate *timeStamp;

@end
