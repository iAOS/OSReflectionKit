//
//  FlipsideViewController.h
//  OSReflectionKitExample
//
//  Created by Alexandre on 02/08/13.
//  Copyright (c) 2013 iAOS Software. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Profile.h"

@class FlipsideViewController;

@protocol FlipsideViewControllerDelegate
- (void)flipsideViewControllerDidFinish:(FlipsideViewController *)controller;
@end

@interface FlipsideViewController : UIViewController <UITableViewDataSource, UITableViewDelegate>

@property (strong, nonatomic) Profile *profile;
@property (assign, nonatomic) id <FlipsideViewControllerDelegate> delegate;

- (IBAction)done:(id)sender;

@end
