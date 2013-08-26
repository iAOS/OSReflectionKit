//
//  ReverseDictViewController.m
//  OSReflectionKitExample
//
//  Created by Alexandre on 25/08/13.
//  Copyright (c) 2013 iAOS Software. All rights reserved.
//

#import "ReverseDictViewController.h"
#import "NSObject+OSReflectionKit.h"

@interface ReverseDictViewController ()

@end

@implementation ReverseDictViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    
    self.textView.text = [[self.object reverseDictionary] description];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidUnload
{
    [self setTextView:nil];
    [super viewDidUnload];
}

#pragma mark - UI Actions

- (IBAction)segmentedReverseTypeChanged:(id)sender
{
    UISegmentedControl *segControl = sender;
    
    if(segControl.selectedSegmentIndex == 0)
        self.textView.text = [[self.object reverseDictionary] description];
    else
        self.textView.text = [self.object reverseJSONString];
}
@end
