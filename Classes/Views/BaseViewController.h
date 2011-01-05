//
//  BaseViewController.h
//  Consumo-iOS
//
//  Created by Felipe Kellermann on 1/4/11.
//  Copyright 2011 Nyvra Software. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface BaseViewController : UIViewController <UITableViewDataSource, UITableViewDelegate>
{
	UITableView				*tableView;
	NSIndexPath				*indexPathLast;
	UIActivityIndicatorView	*activityView;
	UIBarButtonItem			*buttonActivity;
}

- (void)startActivity;
- (void)stopActivity;

@end
