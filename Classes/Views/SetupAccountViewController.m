    //
//  SetupAccountViewController.m
//  Consumo-iOS
//
//  Created by Felipe Kellermann on 1/4/11.
//  Copyright 2011 Nyvra Software. All rights reserved.
//

#import "SetupAccountViewController.h"
#import "Accounts.h"

@implementation SetupAccountViewController

@synthesize delegate;

- (id)initWithAccount:(NSDictionary *)anAccount
{
	if (self = [super init]) {
		account = [anAccount retain];
	}

	return self;
}

#pragma mark View

- (void)loadView
{
	[super loadView];

	buttonSave = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Save", @"")
												  style:UIBarButtonItemStyleDone
												 target:self
												 action:@selector(buttonSaveTouched)];
	
	buttonCancel = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Cancel", @"")
													style:UIBarButtonItemStyleBordered
												   target:self
												   action:@selector(buttonCancelTouched)];
	
	textUsername = [[UITextField alloc] initWithFrame:CGRectMake(100, 10, 185, 23)];
	[textUsername setTextAlignment:UITextAlignmentRight];
	[textUsername setKeyboardType:UIKeyboardTypePhonePad];
	[textUsername setPlaceholder:[NSLocalizedString(@"5198581234", @"") stringByAppendingString:@" "]];
	[textUsername setTag:50];

	textPassword = [[UITextField alloc] initWithFrame:CGRectMake(100, 10, 185, 23)];
	[textPassword setTextAlignment:UITextAlignmentRight];
	[textPassword setSecureTextEntry:YES];
	[textPassword setPlaceholder:[NSLocalizedString(@"1234", @"") stringByAppendingString:@" "]];
	[textPassword setReturnKeyType:UIReturnKeyDone];
	[textPassword setTag:50];
	
	textLabel = [[UITextField alloc] initWithFrame:CGRectMake(100, 10, 185, 23)];
	[textLabel setTextAlignment:UITextAlignmentRight];
	[textLabel setPlaceholder:[NSLocalizedString(@"Conta Pessoal", @"") stringByAppendingString:@" "]];
	[textLabel setReturnKeyType:UIReturnKeyDone];
	[textLabel setTag:50];
	
	[tableView setContentInset:UIEdgeInsetsMake(0, 0, 215, 0)];
	[tableView setScrollIndicatorInsets:tableView.contentInset];
	
	if (account != nil) {
		// TODO FEK: Provider (operadora)!
		[textUsername setText:[account objectForKey:@"Username"]];
		[textPassword setText:[account objectForKey:@"Password"]];
		[textLabel setText:[account objectForKey:@"Label"]];
	}
}

- (void)viewDidLoad
{
	[self setTitle:NSLocalizedString(@"Account", @"")];
	
	[self.navigationItem setLeftBarButtonItem:buttonCancel];
	[self.navigationItem setRightBarButtonItem:buttonSave];
	
	NSString *file = [[NSBundle mainBundle] pathForResource:@"Services" ofType:@"plist"];
	services = [[NSDictionary dictionaryWithContentsOfFile:file] retain];
	servicesList = [[services allKeys] retain];
	serviceCurrent = [servicesList objectAtIndex:0];
	
	[super viewDidLoad];
}

- (void)viewDidAppear:(BOOL)animated
{
	[textUsername becomeFirstResponder];
	[super viewDidAppear:animated];
}






- (BOOL)save
{
	if ([textUsername.text length] == 0) {
		[self.navigationItem setPrompt:NSLocalizedString(@"Username must be specified", @"")];
		return NO;
	} else if ([textPassword.text length] == 0) {
		[self.navigationItem setPrompt:NSLocalizedString(@"Password must be specified", @"")];
		return NO;
	}

	if (account == nil) {
		NSDictionary *newAccount = [[Accounts singleton] createWithLabel:textLabel.text
																 carrier:serviceCurrent
																username:textUsername.text
															 andPassword:textPassword.text];
		
		[delegate didCreateAccount:newAccount];
	} else {
		// TODO FEK: This looks ugly ;-)  Move account to an object.
		// TODO FEK: Provider.
		[account setValue:textUsername.text forKey:@"Username"];
		[account setValue:textPassword.text forKey:@"Password"];
		[account setValue:textLabel.text forKey:@"Label"];

		[delegate didChangeAccount:account];
	}

	[[Accounts singleton] commit];

	return YES;
}

- (void)buttonCancelTouched
{
	[self dismissModalViewControllerAnimated:YES];
}

- (void)buttonSaveTouched
{
	if ([self save] == YES)
		[self dismissModalViewControllerAnimated:YES];
}

- (NSDictionary *)serviceForName:(NSString *)service
{
	return [services objectForKey:service];
}

- (NSDictionary *)service
{
	return [services objectForKey:serviceCurrent];
}

#pragma mark Table view

- (NSInteger)numberOfSectionsInTableView:(UITableView *)table
{
	return 3;
}

- (NSInteger)tableView:(UITableView *)table numberOfRowsInSection:(NSInteger)section
{
	if (section == 0)
		return 1;
	else if (section == 1)
		return 2;
	else if (section == 2)
		return 1;
	else
		return 0;
}

- (UITableViewCell *)tableView:(UITableView *)table cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
	
	UITableViewCell *cell = nil;
	
	cell = [table dequeueReusableCellWithIdentifier:@"cell"];
	if (cell == nil)
		cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:@"cell"] autorelease];
	
	UIView *tempView = [cell.contentView viewWithTag:50];
	[tempView removeFromSuperview];
	
	[cell setSelectionStyle:UITableViewCellSelectionStyleNone];

	switch (indexPath.section) {
		case 0:
			[cell setSelectionStyle:UITableViewCellSelectionStyleBlue];
			[cell.textLabel setText:NSLocalizedString(@"Service", @"")];
			[cell.detailTextLabel setText:[[self service] objectForKey:@"Name"]];
			break;
			
		case 1:
			switch (indexPath.row) {
				case 0:
					[cell.textLabel setText:NSLocalizedString(@"Username", @"")];
					[cell.contentView addSubview:textUsername];
					break;
					
				case 1:
					[cell.textLabel setText:NSLocalizedString(@"Password", @"")];
					[cell.contentView addSubview:textPassword];
					break;
			}
			break;
			
		case 2:
			[cell.textLabel setText:NSLocalizedString(@"Label", @"")];
			[cell.contentView addSubview:textLabel];
			break;
	}
	
	// I feel bad :-)
	UITextField *field = (UITextField *) [cell.contentView viewWithTag:50];
	[field setTextColor:cell.detailTextLabel.textColor];

	[pool drain];
	
	return cell;
}

- (void)tableView:(UITableView *)table didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
	
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
	
	switch (indexPath.section) {
		case 0:
			[table deselectRowAtIndexPath:indexPath animated:YES];
			
			UIActionSheet *actionSheet = [[[UIActionSheet alloc] initWithTitle:NSLocalizedString(@"Select a service", @"")
																	 delegate:self
															cancelButtonTitle:nil
													   destructiveButtonTitle:nil
															otherButtonTitles:nil] autorelease];
			
			for (NSString *service in servicesList)
				[actionSheet addButtonWithTitle:[[self serviceForName:service] objectForKey:@"Name"]];
			
			[actionSheet addButtonWithTitle:NSLocalizedString(@"I Want Others!", @"")];
			[actionSheet addButtonWithTitle:NSLocalizedString(@"Cancel", @"")];
			[actionSheet setCancelButtonIndex:[servicesList count] + 1];
			
			[actionSheet showFromToolbar:self.navigationController.toolbar];
			
			[pool drain];
			
			// TODO.
			break;
		case 1:
			switch (indexPath.row) {
				case 0:
					[textUsername becomeFirstResponder];
					break;
				case 1:
					[textPassword becomeFirstResponder];
					break;
				case 2:
					[textLabel becomeFirstResponder];
					break;
			}
	}
}

- (NSString *)tableView:(UITableView *)table titleForHeaderInSection:(NSInteger)section
{
	if (section	 == 2)
		return NSLocalizedString(@"Optionals", @"");
	else
		return nil;
}

- (NSString *)tableView:(UITableView *)tableView titleForFooterInSection:(NSInteger)section
{
	if (section == 0)
		return NSLocalizedString(@"Make sure you already have an account for the service. Create an account otherwise.", @"");
	else
		return nil;
}

#pragma mark Action sheet

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
	// TODO FEK: others! ;-)
	if (buttonIndex == [servicesList count]) {
		UIAlertView *alert = [[[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Other services", @"")
														 message:NSLocalizedString(@"We are working to add other services. Please stay tuned or contact us if you can help with something.", @"")
														delegate:nil
											   cancelButtonTitle:NSLocalizedString(@"Dismiss", @"")
											   otherButtonTitles:nil] autorelease];
		[alert show];
	}
}

#pragma mark Memory management

- (void)dealloc
{
	self.delegate = nil;
	
	[textUsername release];
	[textPassword release];
	[textLabel release];
	[buttonSave release];
	[services release];
	[servicesList release];
	[account release];

	[super dealloc];
}

@end