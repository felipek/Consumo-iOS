//
//  AboutViewController.m
//  Consumo-iOS
//
//  Created by Felipe Kellermann on 1/6/11.
//  Copyright 2011 Nyvra Software. All rights reserved.
//

#import "AboutViewController.h"

@implementation AboutViewController

- (void)viewDidLoad
{
	[self setTitle:NSLocalizedString(@"About", @"")];
	
	UIBarButtonItem *buttonClose = [[[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Close", @"")
																	 style:UIBarButtonItemStyleDone
																	target:self
																	action:@selector(buttonCloseTouched)] autorelease];
	[self.navigationItem setLeftBarButtonItem:buttonClose];
	
	UIBarButtonItem *buttonContact = [[[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Contact", @"")
																	   style:UIBarButtonItemStyleBordered
																	  target:self
																	  action:@selector(buttonContactTouched)] autorelease];
	[self.navigationItem setRightBarButtonItem:buttonContact];
	
	NSString *path = [[NSBundle mainBundle] pathForResource:@"Thanks" ofType:@"plist"];
	thanks = [[NSArray arrayWithContentsOfFile:path] retain];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)table
{
	return 2;
}

- (NSInteger)tableView:(UITableView *)table numberOfRowsInSection:(NSInteger)section
{
	if (section == 0)
		return 3;
	else
		return [thanks count];
}

- (UITableViewCell *)tableView:(UITableView *)table cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	UITableViewCell *cell = nil;
	NSDictionary *friend = [thanks objectAtIndex:indexPath.row];
	
	cell = [table dequeueReusableCellWithIdentifier:@"cell"];
	if (cell == nil) {
		cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:@"cell"] autorelease];
		[cell setSelectionStyle:UITableViewCellSelectionStyleNone];
		[cell.detailTextLabel setAdjustsFontSizeToFitWidth:YES];
	}
	
	switch (indexPath.section) {
		case 0:
			switch (indexPath.row) {
				case 0:
					[cell.textLabel setText:[[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleDisplayName"]];
					[cell.detailTextLabel setText:[[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleVersion"]];
					break;

				case 1:
					[cell.textLabel setText:@"Nyvra Software"];
					[cell.detailTextLabel setText:@"Copyright - 2011"];
					break;
					
				case 2:
					[cell.textLabel setText:@"Felipe Kellermann"];
					[cell.detailTextLabel setText:@"@felipek"];
					break;
			}
			break;
			
		case 1:
			[cell.textLabel setText:[friend objectForKey:@"Name"]];
			[cell.detailTextLabel setText:[friend objectForKey:@"Twitter"]];
			break;
	}
	
	return cell;
}

- (NSString *)tableView:(UITableView *)table titleForHeaderInSection:(NSInteger)section
{
	if (section == 0)
		return NSLocalizedString(@"Software", @"");
	else
		return NSLocalizedString(@"Collaborators", @"");
}

- (NSString *)tableView:(UITableView *)table titleForFooterInSection:(NSInteger)section
{
	if (section == 0)
		return nil;
	else
		return NSLocalizedString(@"Code, design, accounts, tests, etc.", @"");
}

- (void)buttonCloseTouched
{
	[self dismissModalViewControllerAnimated:YES];
}

- (void)buttonContactTouched
{
	MFMailComposeViewController *mailView = [[MFMailComposeViewController alloc] init];
	[mailView.navigationBar setTintColor:self.navigationController.navigationBar.tintColor];
	[mailView setMailComposeDelegate:self];
	
	[mailView setSubject:[NSString stringWithFormat:@"%@ %@",
						  [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleDisplayName"],
						  [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleVersion"]]];
	[mailView setToRecipients:[NSArray arrayWithObject:[[NSBundle mainBundle] objectForInfoDictionaryKey:@"SoftwareOwnerEmail"]]];
	
	[self.navigationController presentModalViewController:mailView animated:YES];
	[mailView release];
}

- (void)mailComposeController:(MFMailComposeViewController *)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error
{
	[controller dismissModalViewControllerAnimated:YES];
}

- (void)dealloc
{
	[thanks release];
	[super dealloc];
}

@end
