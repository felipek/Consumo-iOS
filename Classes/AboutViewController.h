//
//  AboutViewController.h
//  Consumo-iOS
//
//  Created by Felipe Kellermann on 1/6/11.
//  Copyright 2011 Nyvra Software. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MessageUI/MessageUI.h>
#import "BaseViewController.h"

@interface AboutViewController : BaseViewController <MFMailComposeViewControllerDelegate>
{
	NSArray *thanks;
}

@end