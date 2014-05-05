//
//  OSCoreDataManager.h
//  OSReflectionKit+CoreData
//
//  Created by Alexandre on 03/02/14.
//  Copyright (c) 2014 iAOS Software. All rights reserved.
//

/*
 Copyright (c) 2013 iAOS Software. All rights reserved.
 
 Permission is hereby granted, free of charge, to any person obtaining a copy of
 this software and associated documentation files (the "Software"), to deal in
 the Software without restriction, including without limitation the rights to
 use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies
 of the Software, and to permit persons to whom the Software is furnished to do
 so, subject to the following conditions:
 
 The above copyright notice and this permission notice shall be included in all
 copies or substantial portions of the Software.
 
 If you happen to meet one of the copyright holders in a bar you are obligated
 to buy them one pint of beer.
 
 THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
 SOFTWARE.
 */

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@interface OSCoreDataManager : NSObject

/**
 The current Core Data's persitence store coordinator.
 If the coordinator doesn't already exist, it is created and the managed store added to it.
 */
@property (nonatomic, strong, readonly) NSPersistentStoreCoordinator *persistentStoreCoordinator;
/**
 The current Core Data's managed object context.
 If the context doesn't already exist, it is created and bound to the current persistent store coordinator.
 */
@property (nonatomic, strong, readonly) NSManagedObjectContext *managedObjectContext;

/**
 The current Core Data's managed object model.
 If the model doesn't already exist, it is created from the registered model file name.
 */
@property (nonatomic, strong, readonly) NSManagedObjectModel *managedObjectModel;

/**
 Registers a model file name to be managed by this manager instances.
 
 @param modelFileName The name of the model file.
 */
+ (void) registerModelFileName:(NSString *) modelFileName;

/**
 @return The current model file name registered.
 */
+ (NSString *) modelFileName;

/**
 @return The singleton instance of the manager.
 */
+ (instancetype) sharedManager;

/**
 Saves the current context.
 
 @return YES in case of success.
 */
- (BOOL) saveContext;

/**
 Saves the current context.
 
 @param error The error reference to be filled in case of failure.
 
 @return YES in case of success. Case an error occurs, it returns NO and an NSError object with the error info in its error parameter.
 */
- (BOOL) saveContextWithError:(NSError **) error;

@end
