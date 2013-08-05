//
//  MasterViewController.h
//  OSReflectionKit+CoreDataExample
//
//  Created by Alexandre on 05/08/13.
//  Copyright (c) 2013 iAOS Software. All rights reserved.
//

#import <UIKit/UIKit.h>

#import <CoreData/CoreData.h>

@interface MasterViewController : UITableViewController <NSFetchedResultsControllerDelegate>

@property (strong, nonatomic) NSFetchedResultsController *fetchedResultsController;
@property (strong, nonatomic) NSManagedObjectContext *managedObjectContext;

@end
