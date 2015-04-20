//
//  ChildTestModel.h
//  OSReflectionKit+CoreDataExample
//
//  Created by Alexandre on 04/05/14.
//  Copyright (c) 2014 iAOS Software. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class TestModel;

@interface ChildTestModel : NSManagedObject

@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSNumber * enabled;
@property (nonatomic, retain) TestModel *parent;

@end
