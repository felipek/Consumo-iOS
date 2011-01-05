    //
//  BaseViewController.m
//  Consumo-iOS
//
//  Created by Felipe Kellermann on 1/4/11.
//  Copyright 2011 Nyvra Software. All rights reserved.
//

#import "BaseViewController.h"

@implementation BaseViewController

#pragma mark View

- (void)loadView
{
	tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, 320, 480) style:UITableViewStyleGrouped];
	
	[tableView setDelegate:self];
	[tableView setDataSource:self];
	
	activityView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
	buttonActivity = [[UIBarButtonItem alloc] initWithCustomView:activityView];
	
	self.view = tableView;
}

- (void)viewDidAppear:(BOOL)animated
{
	if (indexPathLast != nil) {
		[tableView deselectRowAtIndexPath:indexPathLast animated:YES];
		[indexPathLast release];
		indexPathLast = nil;
	}
	
	[tableView flashScrollIndicators];
	
	[super viewDidAppear:animated];
}

#pragma mark Table view

- (NSInteger)tableView:(UITableView *)table numberOfRowsInSection:(NSInteger)section
{
	return 0;
}

- (UITableViewCell *)tableView:(UITableView *)table cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	return nil;
}

- (void)tableView:(UITableView *)table didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
	indexPathLast = [indexPath retain];
}

#pragma mark Handlers

- (void)startActivity
{
	[activityView startAnimating];
	[self.navigationItem setRightBarButtonItem:buttonActivity];
	[[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
}

- (void)stopActivity
{
	[activityView stopAnimating];
	[self.navigationItem setRightBarButtonItem:nil];
	[[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
	
	[tableView reloadData];
}

- (void)dealloc
{
	[indexPathLast release];
	[activityView release];
	[buttonActivity release];
	[super dealloc];
}

@end
