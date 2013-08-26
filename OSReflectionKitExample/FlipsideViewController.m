//
//  FlipsideViewController.m
//  OSReflectionKitExample
//
//  Created by Alexandre on 02/08/13.
//  Copyright (c) 2013 iAOS Software. All rights reserved.
//

#import "FlipsideViewController.h"
#import "ReverseDictViewController.h"

enum SECTIONS
{
    SECTION_PROFILE_DETAILS = 0,
    SECTION_PROFILE_ADDRESS,
    SECTION_PROFILE_HOBBIES,
    NUM_SECTIONS
};

@interface FlipsideViewController ()

@property (nonatomic, strong) NSArray *profilePropertyNames;
@property (nonatomic, strong) NSArray *addressPropertyNames;

@end

@implementation FlipsideViewController

- (void)awakeFromNib
{
    self.contentSizeForViewInPopover = CGSizeMake(320.0, 480.0);
    [super awakeFromNib];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    
    // Set the propertyNames fot the profile object, removing address and hobbies
    NSMutableArray *allProperties = [[Profile propertyNames] mutableCopy];
    [allProperties removeObjectsInArray:@[@"address", @"hobbies"]];
    self.profilePropertyNames = allProperties;
    self.addressPropertyNames = [Address propertyNames];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if([segue.identifier isEqualToString:@"VCReverseDictSegueID"])
    {
        ReverseDictViewController *vc = segue.destinationViewController;
        
        vc.object = self.profile;
    }
}

#pragma mark - Actions

- (IBAction)done:(id)sender
{
    [self.delegate flipsideViewControllerDidFinish:self];
}

- (IBAction)btReverseDictionaryTouched:(id)sender {
}

#pragma mark - TableView Data Source and Delegate

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return NUM_SECTIONS;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSInteger numberOfRows = 0;
    
    switch (section)
    {
        case SECTION_PROFILE_DETAILS:
            // All properties except hobbies and address
            numberOfRows = [self.profilePropertyNames count];
        break;

        case SECTION_PROFILE_ADDRESS:
            // All properties for the address
            numberOfRows = [self.addressPropertyNames count];
        break;
            
        case SECTION_PROFILE_HOBBIES:
            numberOfRows = [self.profile.hobbies count];
        break;
    }
    
    return numberOfRows;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    NSString *title = nil;
    
    switch (section)
    {
        case SECTION_PROFILE_DETAILS:
            title = [NSString stringWithFormat:@"Details for: %@", self.profile.name];
        break;
            
        case SECTION_PROFILE_ADDRESS:
            title = @"Address";
        break;
            
        case SECTION_PROFILE_HOBBIES:
            title = @"Hobbies";
        break;
    }
    
    return title;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = nil;
    
    if(indexPath.section == SECTION_PROFILE_DETAILS)
    {
        cell = [tableView dequeueReusableCellWithIdentifier:@"CellDetailID"];
        
        NSString *propertyName = [self.profilePropertyNames objectAtIndex:indexPath.row];
        
        cell.textLabel.text = [propertyName capitalizedString];
        id value = [self.profile valueForKey:propertyName];
        cell.detailTextLabel.text = [NSString stringWithFormat:@"%@", value];
    }
    else if(indexPath.section == SECTION_PROFILE_ADDRESS)
    {
        cell = [tableView dequeueReusableCellWithIdentifier:@"CellDetailID"];

        Address *address = self.profile.address;
        NSString *propertyName = [self.addressPropertyNames objectAtIndex:indexPath.row];
        cell.textLabel.text = [propertyName capitalizedString];
        cell.detailTextLabel.text = [address valueForKey:propertyName];
    }
    else if (indexPath.section == SECTION_PROFILE_HOBBIES)
    {
        cell = [tableView dequeueReusableCellWithIdentifier:@"CellHobbieID"];
        
        cell.textLabel.text = [self.profile.hobbies objectAtIndex:indexPath.row];
    }
    
    return cell;
}


@end
