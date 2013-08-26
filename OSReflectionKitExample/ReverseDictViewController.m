//
//  ReverseDictViewController.m
//  OSReflectionKitExample
//
//  Created by Alexandre on 25/08/13.
//  Copyright (c) 2013 iAOS Software. All rights reserved.
//

#import "ReverseDictViewController.h"

@interface ReverseDictViewController ()

@end

@implementation ReverseDictViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    
    self.textView.text = [self.dictionary description];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidUnload {
    [self setTextView:nil];
    [super viewDidUnload];
}
@end
