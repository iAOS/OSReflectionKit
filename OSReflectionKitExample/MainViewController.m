//
//  MainViewController.m
//  OSReflectionKitExample
//
//  Created by Alexandre on 02/08/13.
//  Copyright (c) 2013 iAOS Software. All rights reserved.
//

enum SEG_CONTROL_OPTIONS
{
    OPTION_JSON = 0,
    OPTION_DICTIONARY
};

#import "MainViewController.h"

@interface MainViewController ()

@end

@implementation MainViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    
    self.textView.text = [NSString stringWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"profile" ofType:@"json"] encoding:NSUTF8StringEncoding error:nil];
    
    self.navBar.topItem.rightBarButtonItem = nil;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Flipside View Controller

- (void)flipsideViewControllerDidFinish:(FlipsideViewController *)controller
{
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
        [self dismissViewControllerAnimated:YES completion:nil];
    } else {
        [self.flipsidePopoverController dismissPopoverAnimated:YES];
        self.flipsidePopoverController = nil;
    }
}

- (void)popoverControllerDidDismissPopover:(UIPopoverController *)popoverController
{
    self.flipsidePopoverController = nil;
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([[segue identifier] isEqualToString:@"VCProfileDetailsSegueID"])
    {
        [[segue destinationViewController] setDelegate:self];
        [[segue destinationViewController] setProfile:sender];
        
        if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad)
        {
            UIPopoverController *popoverController = [(UIStoryboardPopoverSegue *)segue popoverController];
            self.flipsidePopoverController = popoverController;
            popoverController.delegate = self;
        }
    }
}

#pragma mark - TextView Delegate

- (void)textViewDidBeginEditing:(UITextView *)textView
{
    self.navBar.topItem.rightBarButtonItem = self.btDismissKeyboard;
    
    [UIView animateWithDuration:0.3f animations:^{
        CGRect frame = self.textView.frame;
        frame.size.height -= 150;
        self.textView.frame = frame;
    }];
}

- (void)textViewDidEndEditing:(UITextView *)textView
{
    self.navBar.topItem.rightBarButtonItem = nil;
    
    [UIView animateWithDuration:0.3f animations:^{
        CGRect frame = self.textView.frame;
        frame.size.height += 150;
        self.textView.frame = frame;
    }];
}

#pragma mark - Actions

- (IBAction)btLoadProfileTouched:(id)sender
{
    if (self.flipsidePopoverController)
    {
        [self.flipsidePopoverController dismissPopoverAnimated:YES];
        self.flipsidePopoverController = nil;
    }
    else
    {
        NSError *error = nil;
        Profile *profile = nil;
        if(self.segControlFileType.selectedSegmentIndex == OPTION_JSON)
        {
            // Load the Profile object from the JSON string
            profile = [Profile objectFromJSON:self.textView.text error:&error];
        }
        else
        {
            NSDictionary *dictionary = [NSDictionary dictionaryWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"profile" ofType:@"plist"]];
            
            // Load the Profile object from the dictionary object
            profile = [Profile objectFromDictionary:dictionary];
        }
        
        if(error)
        {
            // Something is wrong with the JSON text
            [[[UIAlertView alloc] initWithTitle:@"Oops" message:[error localizedDescription] delegate:nil cancelButtonTitle:nil otherButtonTitles:@"OK", nil] show];
        }
        else
        {
            [self performSegueWithIdentifier:@"VCProfileDetailsSegueID" sender:profile];
        }
    }
}

- (IBAction)dismissKeyboard:(id)sender
{
    [self.textView resignFirstResponder];
}

- (IBAction)segControlValueChanged:(id)sender
{
    if(self.segControlFileType.selectedSegmentIndex == OPTION_JSON)
    {
        self.textView.text = [NSString stringWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"profile" ofType:@"json"] encoding:NSUTF8StringEncoding error:nil];
        self.textView.editable = YES;
    }
    else
    {
        NSDictionary *dictionary = [NSDictionary dictionaryWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"profile" ofType:@"plist"]];
        self.textView.editable = NO;
        [self.textView resignFirstResponder];
        self.textView.text = [dictionary description];
    }
}

- (void)viewDidUnload {
    [self setTextView:nil];
    [self setBtDismissKeyboard:nil];
    [self setNavBar:nil];
    [self setSegControlFileType:nil];
    [super viewDidUnload];
}
@end
