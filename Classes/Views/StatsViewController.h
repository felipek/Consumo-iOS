//
//  StatsViewController.h
//  Consumo-iOS
//
//  Created by Felipe Kellermann on 1/4/11.
//  Copyright 2011 Nyvra Software. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MessageUI/MessageUI.h>
#import "BaseViewController.h"
#import "Consumo.h"

@interface StatsViewController : BaseViewController <ConsumoDelegate, MFMailComposeViewControllerDelegate, UIAlertViewDelegate>
{
	NSString			*path;
	NSInteger			index;
	
	NSDictionary		*account;
	NSDictionary		*data;
	
	UIBarButtonItem		*buttonRefresh;
	UIBarButtonItem		*buttonEmail;
	UIBarButtonItem		*buttonReport;
	UIBarButtonItem		*buttonFlexible;
	UIBarButtonItem		*buttonStatus;
	
	Consumo				*request;
}

@end
