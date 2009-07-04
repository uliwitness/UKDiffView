//
//  UKObjectLogger.m
//  AngelDiff
//
//  Created by Uli Kusterer on 05.08.08.
//  Copyright 2008 The Void Software. All rights reserved.
//

#import "UKObjectLogger.h"


@implementation UKObjectLogger

+(void)	installUKObjectLogger
{
	[[self class] poseAsClass: [NSObject class]];
}

-(id)	init
{
	if(( self = [super init] ))
	{
		NSLog(@"Instantiated %@", NSStringFromClass([self class]));
	}
	return self;
}

-(void)	dealloc
{
	NSLog(@"Dealloced %@", NSStringFromClass([self class]));
	[super dealloc];
}

@end
