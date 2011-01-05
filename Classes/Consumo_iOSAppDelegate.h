//
//  Consumo_iOSAppDelegate.h
//  Consumo-iOS
//
//  Created by Felipe Kellermann on 1/4/11.
//  Copyright 2011 Nyvra Software. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface Consumo_iOSAppDelegate : NSObject <UIApplicationDelegate>
{
    UIWindow *window;
	UINavigationController *navigation;
}

@property (nonatomic, retain) IBOutlet UIWindow *window;

@end