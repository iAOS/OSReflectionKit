//
//  DetailViewController.h
//  OSReflectionKit+CoreDataExample
//
//  Created by Alexandre on 05/08/13.
//  Copyright (c) 2013 iAOS Software. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Event.h"

@interface DetailViewController : UIViewController

@property (strong, nonatomic) Event *detailItem;

@property (weak, nonatomic) IBOutlet UILabel *detailDescriptionLabel;
@end
