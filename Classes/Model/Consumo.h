//
//  Consumo.h
//  Consumo-iOS
//
//  Created by Felipe Kellermann on 1/4/11.
//  Copyright 2011 Nyvra Software. All rights reserved.
//

#import <Foundation/Foundation.h>

@class Consumo;

@protocol ConsumoDelegate

@required

- (void)consumo:(Consumo *)consumo didFinishWithData:(NSDictionary *)data;

@end

@interface Consumo : NSObject
{
	NSDictionary		*account;
	id<ConsumoDelegate>	delegate;
}

- (id)initWithAccount:(NSDictionary *)anAccount;
- (void)start;

@property (nonatomic, retain) NSDictionary			*account;
@property (nonatomic, retain) id<ConsumoDelegate>	delegate;

@end