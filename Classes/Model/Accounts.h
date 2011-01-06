//
//  Accounts.h
//  Consumo-iOS
//
//  Created by Felipe Kellermann on 1/4/11.
//  Copyright 2011 Nyvra Software. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Accounts : NSObject
{
	NSString		*path;
	NSMutableArray	*accounts;
}

+ (Accounts *)singleton;
- (NSArray *)allAccounts;
- (NSDictionary *)accountAtIndex:(NSInteger)index;
- (NSDictionary *)newAccountWithLabel:(NSString *)label carrier:(NSString *)carrier username:(NSString *)username andPassword:(NSString *)password;
- (void)removeAccount:(NSDictionary *)account;
- (void)commit;

@property (nonatomic, retain) NSString *path;

@end