//
//  OSCoreDataManager.m
//  OSReflectionKit+CoreData
//
//  Created by Alexandre on 03/02/14.
//  Copyright (c) 2014 iAOS Software. All rights reserved.
//

#if  ! __has_feature(objc_arc)
#error This file must be compiled with ARC. Use -fobjc-arc flag (or convert project to ARC).
#endif

#import "OSCoreDataManager.h"

@interface OSCoreDataManager ()

@property (nonatomic, strong, readwrite) NSPersistentStoreCoordinator *persistentStoreCoordinator;
@property (nonatomic, strong, readwrite) NSManagedObjectContext *managedObjectContext;
@property (nonatomic, strong, readwrite) NSManagedObjectModel *managedObjectModel;

@end

@implementation OSCoreDataManager
static NSString *_modelFileName = nil;

+ (instancetype)sharedManager
{
    static OSCoreDataManager *_manager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _manager = [[self alloc] init];
    });
    
    return _manager;
}

+ (void) registerModelFileName:(NSString *) modelFileName
{
    @synchronized(self)
    {
        if(![_modelFileName isEqualToString:modelFileName])
        {
            _modelFileName = modelFileName;
            
            // Clear the current core data stack
            OSCoreDataManager *manager = [OSCoreDataManager sharedManager];
            manager.managedObjectContext = nil;
            manager.managedObjectModel = nil;
            manager.persistentStoreCoordinator = nil;
        }
    }
}

+ (NSString *) modelFileName
{
    @synchronized(self)
    {
        return _modelFileName;
    }
}

// Returns the managed object context for the application.
// If the context doesn't already exist, it is created and bound to the current persistent store coordinator.
- (NSManagedObjectContext *)managedObjectContext
{
    if (_managedObjectContext != nil) {
        return _managedObjectContext;
    }
    
    NSPersistentStoreCoordinator *coordinator = [self persistentStoreCoordinator];
    if (coordinator != nil) {
        _managedObjectContext = [[NSManagedObjectContext alloc] init];
        [_managedObjectContext setPersistentStoreCoordinator:coordinator];
    }
    return _managedObjectContext;
}

// Returns the managed object model for the application.
// If the model doesn't already exist, it is created from the registered model file name.
- (NSManagedObjectModel *)managedObjectModel
{
    if (_managedObjectModel != nil) {
        return _managedObjectModel;
    }
    NSAssert(_modelFileName, @"Please register the model file name for the OSCoreDataManager class before using it.");
    
    NSString *fullFileName = [[self class] modelFileName];
    NSString *fileNameWithoutExtension = [fullFileName stringByDeletingPathExtension];
    NSString *fileExt = [fullFileName pathExtension] ?: @"momd";
    
    NSURL *modelURL = [[NSBundle mainBundle] URLForResource:fileNameWithoutExtension withExtension:fileExt];
    _managedObjectModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];
    return _managedObjectModel;
}

// Returns the persistent store coordinator for the application.
// If the coordinator doesn't already exist, it is created and the managed store added to it.
- (NSPersistentStoreCoordinator *)persistentStoreCoordinator
{
    if (_persistentStoreCoordinator != nil) {
        return _persistentStoreCoordinator;
    }
    
    NSAssert(_modelFileName, @"Please register the model file name for the OSCoreDataManager class before using it.");
    
    NSString *fullFileName = [[self class] modelFileName];
    NSString *fileNameWithoutExtension = [fullFileName stringByDeletingPathExtension];
    NSString *fileExt = @"sqlite";
    
    NSURL *storeURL = [[self applicationDocumentsDirectory] URLByAppendingPathComponent:[fileNameWithoutExtension stringByAppendingPathExtension:fileExt]];
    
    NSError *error = nil;
    _persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:[self managedObjectModel]];
    if (![_persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeURL options:nil error:&error])
    {
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        abort();
    }
    
    return _persistentStoreCoordinator;
}

- (BOOL) saveContext
{
    return [self saveContextWithError:nil];
}

- (BOOL) saveContextWithError:(NSError **) error
{
    NSManagedObjectContext *managedObjectContext = self.managedObjectContext;
    if (managedObjectContext != nil)
    {
        return ([managedObjectContext hasChanges] && ![managedObjectContext save:error]);
    }
    
    return NO;
}

#pragma mark - Application's Documents directory

// Returns the URL to the application's Documents directory.
- (NSURL *)applicationDocumentsDirectory
{
    return [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
}

@end
