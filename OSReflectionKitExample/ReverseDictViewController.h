//
//  ReverseDictViewController.h
//  OSReflectionKitExample
//
//  Created by Alexandre on 25/08/13.
//  Copyright (c) 2013 iAOS Software. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ReverseDictViewController : UIViewController

@property (weak, nonatomic) IBOutlet UITextView *textView;

@property (nonatomic, strong) id object;

- (IBAction)segmentedReverseTypeChanged:(id)sender;
@end
