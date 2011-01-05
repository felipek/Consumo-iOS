    //
//  StatsViewController.m
//  Consumo-iOS
//
//  Created by Felipe Kellermann on 1/4/11.
//  Copyright 2011 Nyvra Software. All rights reserved.
//

#import "StatsViewController.h"
#import "Accounts.h"

@implementation StatsViewController

- (id)initWithIndex:(NSInteger)anIndex
{
	if (self = [super init]) {
		index = anIndex;
		account = [[Accounts singleton] accountAtIndex:index];
		NSString *ID = [NSString stringWithFormat:@"Cache-%@-%@.plist", [account objectForKey:@"Carrier"], [account objectForKey:@"Username"]];
		path = [[NSHomeDirectory() stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.plist", ID]] retain];		
	}
	
	return self;
}

#pragma mark View

- (void)loadView
{
	[super loadView];
	
	buttonRefresh = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemRefresh target:self action:@selector(buttonRefreshTouched)];
}

- (void)viewDidLoad
{
	// FIXME: No label?
	[self.navigationController.toolbar setTintColor:self.navigationController.navigationBar.tintColor];
	[self setTitle:[account objectForKey:@"Label"]];
	
	buttonEmail = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"E-mail", @"")
												   style:UIBarButtonItemStyleBordered
												  target:self
												  action:@selector(buttonEmailTouched)];
	buttonReport = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Help?", @"")
													style:UIBarButtonItemStyleBordered
												   target:self
												   action:@selector(buttonIncorrectTouched)];
	buttonFlexible = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace
																   target:nil
																   action:nil];
	buttonStatus = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Updating data...", @"")
													style:UIBarButtonItemStylePlain
												   target:nil
												   action:nil];
	
	[self refresh];
	
	[super viewDidLoad];
}

- (void)viewDidAppear:(BOOL)animated
{
	[self.navigationController setToolbarHidden:NO animated:YES];
	[super viewDidAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated
{
	[self.navigationController setToolbarHidden:YES animated:YES];
	[super viewWillDisappear:animated];
}

- (void)viewWillAppear:(BOOL)animated
{
	[self cacheLoad];
	
	if ([data count] > 0)
		[tableView reloadData];
	
	[super viewWillAppear:animated];
}

#pragma mark Tools and stuff

- (void)cacheLoad
{
	data = [[NSDictionary dictionaryWithContentsOfFile:path] retain];
}

- (void)cacheSave
{
	[data writeToFile:path atomically:YES];
}

- (void)buttonRefreshTouched
{
	[self refresh];
}

- (NSString *)formatData
{
	NSMutableString *str = [[NSMutableString alloc] initWithString:@"\n"];
	
	for (NSDictionary *dict in [data objectForKey:@"info"])
		[str appendFormat:@"%@: %@\n", [[dict objectForKey:@"name"] capitalizedString], [dict objectForKey:@"value"]];

	[str appendString:@"\n"];
	
	for (NSDictionary *dict in [data objectForKey:@"consume"])
		[str appendFormat:@"%@: %@\n", [[dict objectForKey:@"label"] capitalizedString], [dict objectForKey:@"value"]];

	return [str autorelease];
}

- (MFMailComposeViewController *)newMail
{
	MFMailComposeViewController *mailView = [[MFMailComposeViewController alloc] init];
	[mailView.navigationBar setTintColor:self.navigationController.navigationBar.tintColor];
	[mailView setMailComposeDelegate:self];

	return mailView;
}

- (void)buttonEmailTouched
{
	MFMailComposeViewController *mailView = [self newMail];
	
	// TODO FEK: Add account label.
	[mailView setSubject:[NSString stringWithFormat:@"%@ %@: %@",
						  [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleDisplayName"],
						  [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleVersion"],
						  [account objectForKey:@"Username"]]];
	[mailView setMessageBody:[self formatData] isHTML:NO];
	
	[self.navigationController presentModalViewController:mailView animated:YES];
	[mailView release];	
}

- (void)buttonIncorrectTouched
{
	MFMailComposeViewController *mailView = [self newMail];
	
	// TODO FEK: Add account label.
	[mailView setSubject:[NSString stringWithFormat:@"%@ %@: %@ - %@",
						  [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleDisplayName"],
						  [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleVersion"],
						  [account objectForKey:@"Username"],
						  NSLocalizedString(@"Problem", @"")]];

	NSString *message = NSLocalizedString(@"Help us improve the service. Describe the problem and your data as much as you can. Thanks!", @"");
	[mailView setToRecipients:[NSArray arrayWithObject:[[NSBundle mainBundle] objectForInfoDictionaryKey:@"SoftwareOwnerEmail"]]];
	[mailView setMessageBody:[NSString stringWithFormat:@"\n%@\n%@", message, [self formatData]] isHTML:NO];
	
	[self.navigationController presentModalViewController:mailView animated:YES];
	[mailView release];
}

- (void)refresh
{
	[self setToolbarItems:[NSArray arrayWithObjects:buttonFlexible, buttonStatus, buttonFlexible, nil] animated:YES];
	[self startActivity];
	
	request = [[Consumo alloc] initWithAccount:account];
	[request setDelegate:self];
	[request start];	
}

- (void)stopActivity
{
	[super stopActivity];
	
	if (data != nil)
		[self setToolbarItems:[NSArray arrayWithObjects:buttonEmail, buttonFlexible, buttonReport, nil] animated:YES];
	else {
		UIAlertView *alert = [[[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Warning", @"")
														 message:NSLocalizedString(@"Oops! We had problems interpreting your data. Please contact us to help improve the product.", @"")
														delegate:self
											   cancelButtonTitle:NSLocalizedString(@"Dismiss", @"")
											   otherButtonTitles:nil] autorelease];
		[alert show];
	}
	
	[self.navigationItem setRightBarButtonItem:buttonRefresh animated:YES];
}

#pragma mark Alert view

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
	[self.navigationController popViewControllerAnimated:YES];
}

#pragma mark Consumo delegate

- (void)consumo:(Consumo *)consumo didFinishWithData:(NSDictionary *)_data
{	
	if (data != nil) {
		[data release];
		data = nil;
	}
	
	data = [_data retain];
	
	[self cacheSave];
	
	[self performSelectorOnMainThread:@selector(stopActivity) withObject:nil waitUntilDone:YES];
	
	[request release];
	request = nil;
}

#pragma mark Message UI

- (void)mailComposeController:(MFMailComposeViewController *)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error
{
	[controller dismissModalViewControllerAnimated:YES];
}

#pragma mark Table view

- (NSInteger)numberOfSectionsInTableView:(UITableView *)table
{
	return [[data allKeys] count];
}

- (NSInteger)tableView:(UITableView *)table numberOfRowsInSection:(NSInteger)section
{
	if (section == 0) {
		return [[data objectForKey:@"info"] count];
	} else if (section == 1) {
		return [[data objectForKey:@"consume"] count];
	} else {
		return 0;
	}
}

- (id)objectForIndexPath:(NSIndexPath *)indexPath
{
	NSString *key;

	if (indexPath.section == 0)
		key = @"info";
	else if (indexPath.section == 1)
		key = @"consume";
	else
		return nil;
	
	NSArray *nodes = [data objectForKey:key];
	return [nodes objectAtIndex:indexPath.row];
}

- (UITableViewCell *)tableView:(UITableView *)table cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	UITableViewCell *cell = nil;
	NSDictionary	*dict = [self objectForIndexPath:indexPath];
	
	cell = [table dequeueReusableCellWithIdentifier:@"cell"];
	if (cell == nil) {
		cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:@"cell"] autorelease];
		[cell setSelectionStyle:UITableViewCellSelectionStyleNone];
	}
	
	if ([dict objectForKey:@"label"] != nil)
		[cell.textLabel setText:[dict objectForKey:@"label"]];
	else
		[cell.textLabel setText:[[dict objectForKey:@"name"] capitalizedString]];
	
	[cell.detailTextLabel setText:[dict objectForKey:@"value"]];
	
	return cell;
}

- (NSString *)tableView:(UITableView *)table titleForHeaderInSection:(NSInteger)section
{
	if (section == 0)
		return NSLocalizedString(@"Account", @"");
	else if (section == 1)
		return NSLocalizedString(@"Data traffic", @"");
	else
		return nil;
}

#pragma mark Memory management

- (void)dealloc
{
	[request setDelegate:nil];
	[request release];

	[data release];

	[buttonRefresh release];
	[buttonEmail release];
	[buttonReport release];
	[buttonFlexible release];
	[buttonStatus release];

	[super dealloc];
}

@end