//
//  TestModel.h
//  OSReflectionKit+CoreDataExample
//
//  Created by Alexandre on 04/05/14.
//  Copyright (c) 2014 iAOS Software. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface TestModel : NSManagedObject

@property (nonatomic, retain) NSNumber * autoincrement;
@property (nonatomic, retain) NSString * string;
@property (nonatomic, retain) NSString * uniqueString;
@property (nonatomic, retain) NSSet *children;
@end

@interface TestModel (CoreDataGeneratedAccessors)

- (void)addChildrenObject:(NSManagedObject *)value;
- (void)removeChildrenObject:(NSManagedObject *)value;
- (void)addChildren:(NSSet *)values;
- (void)removeChildren:(NSSet *)values;

@end
