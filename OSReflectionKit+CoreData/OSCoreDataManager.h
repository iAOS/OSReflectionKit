//
//  OSCoreDataManager.h
//  OSReflectionKit+CoreDataExample
//
//  Created by Alexandre on 03/02/14.
//  Copyright (c) 2014 iAOS Software. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@interface OSCoreDataManager : NSObject

@property (nonatomic, strong, readonly) NSPersistentStoreCoordinator *persistentStoreCoordinator;
@property (nonatomic, strong, readonly) NSManagedObjectContext *managedObjectContext;
@property (nonatomic, strong, readonly) NSManagedObjectModel *managedObjectModel;

+ (void) registerModelFileName:(NSString *) modelFileName;
+ (NSString *) modelFileName;

+ (instancetype) sharedManager;

- (BOOL) saveContext;
- (BOOL) saveContextWithError:(NSError **) error;

@end
