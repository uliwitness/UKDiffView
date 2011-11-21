//
//  UKObjectLogger.m
//  AngelDiff
//
//  Created by Uli Kusterer on 05.08.08.
//  Copyright 2008 The Void Software. All rights reserved.
//
//	This software is provided 'as-is', without any express or implied
//	warranty. In no event will the authors be held liable for any damages
//	arising from the use of this software.
//
//	Permission is granted to anyone to use this software for any purpose,
//	including commercial applications, and to alter it and redistribute it
//	freely, subject to the following restrictions:
//
//	   1. The origin of this software must not be misrepresented; you must not
//	   claim that you wrote the original software. If you use this software
//	   in a product, an acknowledgment in the product documentation would be
//	   appreciated but is not required.
//
//	   2. Altered source versions must be plainly marked as such, and must not be
//	   misrepresented as being the original software.
//
//	   3. This notice may not be removed or altered from any source
//	   distribution.
//

#import "UKObjectLogger.h"

#import "JRSwizzle.h"

@implementation UKObjectLogger

+(void)installUKObjectLogger
{
	NSError *error = nil;
	
	[NSObject jr_swizzleMethod:@selector(init) withMethod:@selector(init) error:&error];
	if (error != nil) {
		NSLog(@"installUKObjectLogger swizzle init error: %@", error);
	}
	
	[NSObject jr_swizzleMethod:@selector(dealloc) withMethod:@selector(dealloc) error:&error];
	if (error != nil) {
		NSLog(@"installUKObjectLogger swizzle init error: %@", error);
	}
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
