//
//  AccountsViewController.h
//  Consumo-iOS
//
//  Created by Felipe Kellermann on 1/4/11.
//  Copyright 2011 Nyvra Software. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BaseViewController.h"
#import "SetupAccountViewController.h"

@interface AccountsViewController : BaseViewController <SetupAccountDelegate>
{
	BOOL			autoSetup;
	BOOL			animateCreation;
	UIBarButtonItem	*buttonEdit;
	NSDictionary	*animateUpdateAccount;
}

- (id)objectForRowAtIndexPath:(NSIndexPath *)indexPath;
- (void)presentSetupViewWithAccount:(NSDictionary *)account;
- (void)buttonEditTouched;

@end