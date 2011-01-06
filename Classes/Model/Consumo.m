//
//  Consumo.m
//  Consumo-iOS
//
//  Created by Felipe Kellermann on 1/4/11.
//  Copyright 2011 Nyvra Software. All rights reserved.
//

#import "Consumo.h"
#import "JSON.h"

@implementation Consumo

@synthesize account;
@synthesize delegate;

- (id)initWithAccount:(NSDictionary *)anAccount
{
	if (self = [super init]) {
		self.account = anAccount;
	}
	
	return self;
}

- (void)request
{
	NSAutoreleasePool	*pool = [[NSAutoreleasePool alloc] init];
	NSURLResponse		*response = nil;
	NSError				*error = nil;
	NSDictionary		*content = nil;
	
	NSString *url = [NSString stringWithFormat:@"http://nyvra.net/service/consumo/%@?username=%@&password=%@",
					 [account objectForKey:@"Carrier"], [account objectForKey:@"Username"], [account objectForKey:@"Password"]];

	NSURLRequest *request = [[NSURLRequest alloc] initWithURL:[NSURL URLWithString:url]];
	NSData *data = [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&error];
	[request release];
	
	NSString *stringData = [[[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding] autorelease];

	error = nil;
	SBJSON *parser = [[SBJSON alloc] init];
	id object = [parser objectWithString:stringData error:&error];

	[parser release];

	if ([object isKindOfClass:[NSDictionary class]])
		content = object;
	else {
		// TODO FEK: better report.
		NSLog(@"error = %@", error);
	}

	[delegate consumo:self didFinishWithData:content];
	
	[pool release];
}

- (void)start
{
	NSThread *thread = [[NSThread alloc] initWithTarget:self selector:@selector(request) object:nil];
	[thread start];
	[thread release];
}

- (void)dealloc
{
	self.account = nil;
	self.delegate = nil;
	[super dealloc];
}

@end