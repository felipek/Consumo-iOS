//
//  Accounts.m
//  Consumo-iOS
//
//  Created by Felipe Kellermann on 1/4/11.
//  Copyright 2011 Nyvra Software. All rights reserved.
//

#import "Accounts.h"

@implementation Accounts

@synthesize path;

- (id)init
{
	if (self = [super init]) {
		path = [[NSHomeDirectory() stringByAppendingPathComponent:@"Accounts.plist"] retain];

		if ([[NSFileManager defaultManager] fileExistsAtPath:path])
			accounts = [[NSArray arrayWithContentsOfFile:path] mutableCopy];
		else {
			accounts = [[NSMutableArray alloc] init];
			[self commit];
		}		
	}
	
	return self;
}

+ (Accounts *)singleton
{
	static Accounts *instance = nil;

	@synchronized (self) {
		if (instance == nil)
			instance = [[Accounts alloc] init];
	}
	
	return instance;
}

- (NSArray *)allAccounts
{
	return [[accounts copy] autorelease];
}

- (NSDictionary *)accountAtIndex:(NSInteger)index
{
	return [[self allAccounts] objectAtIndex:index];
}

- (NSDictionary *)createWithLabel:(NSString *)label carrier:(NSString *)carrier username:(NSString *)username andPassword:(NSString *)password
{
	
	NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
	
	NSMutableDictionary *account = [[[NSMutableDictionary alloc] init] autorelease];
	[account setObject:carrier forKey:@"Carrier"];
	[account setObject:username forKey:@"Username"];
	[account setObject:password forKey:@"Password"];
	if (label != nil)
		[account setObject:label forKey:@"Label"];
	else
		[account setObject:@"" forKey:@"Label"];
	
	
	[accounts addObject:account];
	
	[pool drain];
	
	return account;
}

- (void)removeAccount:(NSDictionary *)account
{
	[accounts removeObject:account];
}

- (void)commit
{
	[accounts writeToFile:path atomically:YES];
}
		 
- (void)dealloc
{
	[path release];
	[accounts release];
	[super dealloc];
}

@end