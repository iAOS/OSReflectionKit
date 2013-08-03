//
//  MainViewController.h
//  OSReflectionKitExample
//
//  Created by Alexandre on 02/08/13.
//  Copyright (c) 2013 iAOS Software. All rights reserved.
//

#import "FlipsideViewController.h"

@interface MainViewController : UIViewController <FlipsideViewControllerDelegate, UIPopoverControllerDelegate, UITextViewDelegate>

@property (strong, nonatomic) UIPopoverController *flipsidePopoverController;
@property (weak, nonatomic) IBOutlet UITextView *textView;
@property (strong, nonatomic) IBOutlet UIBarButtonItem *btDismissKeyboard;
@property (weak, nonatomic) IBOutlet UINavigationBar *navBar;

- (IBAction)btLoadProfileTouched:(id)sender;
- (IBAction)dismissKeyboard:(id)sender;

@end
