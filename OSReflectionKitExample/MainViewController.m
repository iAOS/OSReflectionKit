//
//  MainViewController.m
//  OSReflectionKitExample
//
//  Created by Alexandre on 02/08/13.
//  Copyright (c) 2013 iAOS Software. All rights reserved.
//

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
        // Convert the JSON text into a dictionary object
        NSData *jsonData = [self.textView.text dataUsingEncoding:NSUTF8StringEncoding];
        NSError *error = nil;
        NSDictionary *dictionary = [NSJSONSerialization JSONObjectWithData:jsonData options:kNilOptions error:&error];
        if(error)
        {
            // Something is wrong with the JSON text
            [[[UIAlertView alloc] initWithTitle:@"Oops" message:[error localizedDescription] delegate:nil cancelButtonTitle:nil otherButtonTitles:@"OK", nil] show];
        }
        else
        {
            // Load the Profile object from the dictionary
            Profile *profile = [Profile objectFromDictionary:dictionary];
            
            [self performSegueWithIdentifier:@"VCProfileDetailsSegueID" sender:profile];
        }
    }
}

- (IBAction)dismissKeyboard:(id)sender
{
    [self.textView resignFirstResponder];
}

- (void)viewDidUnload {
    [self setTextView:nil];
    [self setBtDismissKeyboard:nil];
    [self setNavBar:nil];
    [super viewDidUnload];
}
@end
