//
//  AppDelegate.m
//  AngelDiff
//
//  Created by Uli Kusterer on 02.08.08.
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

#import "AppDelegate.h"
#import "UKDiffParser.h"
#import "UKDiffView.h"
#import "UKHelperMacros.h"

#import "NSString+AutodetectTextEncoding.h"


@implementation AppDelegate

@synthesize currPath;

-(void)	dealloc
{
	DESTROY(currPath);
	
	[super dealloc];
}

- (BOOL)application:(NSApplication *)sender openFile:(NSString *)filename
{
#pragma unused(sender)
	NSError *error;
	NSStringEncoding enc;
	
	self.currPath = [[filename stringByDeletingPathExtension] stringByAppendingPathExtension: @"txt"];
	NSData*	dataOne = [NSData dataWithContentsOfFile:self.currPath options: 0 error: &error];
	if (!dataOne)
	{
		NSLog(@"%@", error);
		return NO;
	}	
	
	NSString*	stringOne = [[NSString alloc] initWithData:dataOne autodetectedEncoding:&enc];
	NSLog(@"txt Encoding: %@", [NSString localizedNameOfStringEncoding:enc]);
	
	NSString*	diffPath = [[filename stringByDeletingPathExtension] stringByAppendingPathExtension: @"udiff"];
	BOOL		uniDiff = YES;
	if( ![[NSFileManager defaultManager] fileExistsAtPath: diffPath] )
	{
		diffPath = [[filename stringByDeletingPathExtension] stringByAppendingPathExtension: @"diff"];
		uniDiff = NO;
	}
	
	NSData*	differencesData = [NSData dataWithContentsOfFile:diffPath options: 0 error: &error];
	if (!differencesData)
	{
		NSLog(@"%@", error);
		return NO;
	}	
	
	NSString*	differences = [[NSString alloc] initWithData:differencesData autodetectedEncoding:&enc];
	NSLog(@"(u)diff Encoding: %@", [NSString localizedNameOfStringEncoding:enc]);
	
	UKDiffParser*	dp = nil;
	if( uniDiff )
		dp = [[[UKDiffParser alloc] initWithUnifiedDiffText: differences] autorelease];
	else
		dp = [[[UKDiffParser alloc] initWithDiffText: differences] autorelease];
	[dp applyOriginalText: stringOne];
	
	[diffView setDiffParser: dp];
	NSRect	box = [diffView frame];
	box.size = [diffView bestSize];
	[diffView setFrame: box];
	[diffView setNeedsDisplay: YES];
	
	return YES;
}


-(void)	exportMerged: (id)sender
{
#pragma unused(sender)

	NSString*	merged = [[diffView diffParser] mergedString];
	[merged writeToFile: [[currPath stringByDeletingPathExtension] stringByAppendingPathExtension: @"merged.txt"] atomically: NO encoding: NSUTF8StringEncoding error: nil];
}

@end
