    //
//  AccountsViewController.m
//  Consumo-iOS
//
//  Created by Felipe Kellermann on 1/4/11.
//  Copyright 2011 Nyvra Software. All rights reserved.
//

#import "AccountsViewController.h"
#import "StatsViewController.h"
#import "SetupAccountViewController.h"
#import "AboutViewController.h"
#import "Accounts.h"

@implementation AccountsViewController

#pragma mark View

- (void)loadView
{
	[super loadView];
	
	[tableView setAllowsSelectionDuringEditing:YES];
	
	buttonEdit = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Edit", @"")
												  style:UIBarButtonItemStyleBordered
												 target:self
												 action:@selector(buttonEditTouched)];
	
	UIButton *button = [UIButton buttonWithType:UIButtonTypeInfoLight];
	[button addTarget:self action:@selector(buttonAboutTouched) forControlEvents:UIControlEventTouchUpInside];
	buttonAbout = [[UIBarButtonItem alloc] initWithCustomView:button];
}

- (void)viewDidLoad
{
	[self setTitle:NSLocalizedString(@"Accounts", @"")];
	[self.navigationItem setRightBarButtonItem:buttonEdit];
	[self.navigationItem setLeftBarButtonItem:buttonAbout];
}

- (void)viewDidAppear:(BOOL)animated
{	
	NSIndexPath *indexPath = [NSIndexPath indexPathForRow:0 inSection:0];
	
	if (autoSetup == NO && [[[Accounts singleton] allAccounts] count] == 0) {
		autoSetup = YES;
		
		[tableView selectRowAtIndexPath:indexPath animated:YES scrollPosition:UITableViewScrollPositionNone];
		
		[self presentSetupViewWithAccount:nil];
	} else
		indexPath = nil;
	
	[super viewDidAppear:animated];
	if (indexPath != nil)
		indexPathLast = [indexPath retain];
	
	if (animateCreation == YES) {
		animateCreation = NO;
		
		NSIndexPath *indexPath = [NSIndexPath indexPathForRow:[[[Accounts singleton] allAccounts] count] - 1 inSection:0];
		[tableView insertRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationNone];
	}
	
	if (animateUpdateAccount != nil) {
		NSInteger row = [[[Accounts singleton] allAccounts] indexOfObject:animateUpdateAccount];
		
		[tableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:[NSIndexPath indexPathForRow:row inSection:0]] withRowAnimation:UITableViewRowAnimationFade];
		
		animateUpdateAccount = nil;
	}
}

#pragma mark Tools and stuff

- (id)objectForRowAtIndexPath:(NSIndexPath *)indexPath
{
	id object = nil;
	
	if (indexPath.row < [[[Accounts singleton] allAccounts] count])
		object = [[Accounts singleton] accountAtIndex:indexPath.row];
	
	return object;
}

- (void)presentSetupViewWithAccount:(NSDictionary *)account
{
	SetupAccountViewController *setupView = [[[SetupAccountViewController alloc] initWithAccount:account] autorelease];
	UINavigationController *setupNavigation = [[[UINavigationController alloc] initWithRootViewController:setupView] autorelease];
	[setupNavigation.navigationBar setTintColor:self.navigationController.navigationBar.tintColor];
	[setupView setDelegate:self];
	[self presentModalViewController:setupNavigation animated:YES];	
}

- (void)buttonEditTouched
{
	if ([tableView isEditing]) {
		[tableView setEditing:NO animated:YES];
		[buttonEdit setTitle:NSLocalizedString(@"Editar", @"")];
		[buttonEdit setStyle:UIBarButtonItemStyleBordered];
	} else {
        if ([[[Accounts singleton] allAccounts] count] == 0)
            return;
            
		[tableView setEditing:YES animated:YES];
		[buttonEdit setTitle:NSLocalizedString(@"Done", @"")];
		[buttonEdit setStyle:UIBarButtonItemStyleDone];
	}
}

- (void)buttonAboutTouched
{
	AboutViewController *about = [[[AboutViewController alloc] init] autorelease];
	UINavigationController *navigation = [[[UINavigationController alloc] initWithRootViewController:about] autorelease];
	[navigation.navigationBar setTintColor:self.navigationController.navigationBar.tintColor];
	[about setModalTransitionStyle:UIModalTransitionStyleFlipHorizontal];
	[self presentModalViewController:navigation animated:YES];	
}

#pragma mark Account setup delegate


- (void)didCreateAccount:(NSDictionary *)account
{
	animateCreation = YES;
}

- (void)didChangeAccount:(NSDictionary *)account;
{
	animateUpdateAccount = account;
}

#pragma mark Table view

- (NSInteger)tableView:(UITableView *)table numberOfRowsInSection:(NSInteger)section
{
	return [[[Accounts singleton] allAccounts] count] + 1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
	return 56;
}

- (UITableViewCell *)tableView:(UITableView *)table cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	UITableViewCell *cell = nil;
	NSDictionary	*account = [self objectForRowAtIndexPath:indexPath];

	cell = [table dequeueReusableCellWithIdentifier:@"cell"];
	if (cell == nil) {
		cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"cell"] autorelease];
	}

	if (account != nil) {
		[cell setAccessoryType:UITableViewCellAccessoryDisclosureIndicator];
		if ([[account objectForKey:@"Label"] length] > 0)
			[cell.textLabel setText:[account objectForKey:@"Label"]];
		else
			[cell.textLabel setText:[account objectForKey:@"Username"]];
		
		[cell.detailTextLabel setText:[[account objectForKey:@"Carrier"] capitalizedString]];
	} else {
		if ([[[Accounts singleton] allAccounts] count] == 0)
			[cell.textLabel setText:NSLocalizedString(@"Create an account", @"")];
		else
			[cell.textLabel setText:NSLocalizedString(@"Create another account", @"")];
			
		[cell setAccessoryType:UITableViewCellAccessoryNone];
	}
	
	return cell;
}

- (UITableViewCellEditingStyle)tableView:(UITableView *)table editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath
{
	if (indexPath.row == [[[Accounts singleton] allAccounts] count])
		return UITableViewCellEditingStyleNone;
	else
		return UITableViewCellEditingStyleDelete;
}

- (void)tableView:(UITableView *)table commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
	if (editingStyle == UITableViewCellEditingStyleDelete) {
		NSDictionary *account;

		account = [[Accounts singleton] accountAtIndex:indexPath.row];
		[[Accounts singleton] removeAccount:account];
		[[Accounts singleton] commit];
		
		[tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
	}
    
    if ([[[Accounts singleton] allAccounts] count] == 0) {
        [tableView setEditing:NO animated:YES];
		[buttonEdit setTitle:NSLocalizedString(@"Editar", @"")];
		[buttonEdit setStyle:UIBarButtonItemStyleBordered];        
    }
}

- (void)tableView:(UITableView *)table didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
	NSDictionary *account = [self objectForRowAtIndexPath:indexPath];
	
	[super tableView:table didSelectRowAtIndexPath:indexPath];
	
	if (account != nil) {
		if ([tableView isEditing]) {
			[self presentSetupViewWithAccount:account];
		} else {
			StatsViewController *statsView = [[[StatsViewController alloc] initWithIndex:indexPath.row] autorelease];
			[self.navigationController pushViewController:statsView animated:YES];
		}
	} else {
		[self presentSetupViewWithAccount:nil];
	}
	
	if ([tableView isEditing])
		[self buttonEditTouched];
}

- (NSString *)tableView:(UITableView *)tableView titleForFooterInSection:(NSInteger)section
{
	return [NSString stringWithFormat:@"%@ - %@",
			[[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleDisplayName"],
			[[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleVersion"]];
}

#pragma mark Memory management

- (void)dealloc
{
	[buttonEdit release];
	[buttonAbout release];
    [super dealloc];
}

@end