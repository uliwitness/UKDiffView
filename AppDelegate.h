//
//  AppDelegate.h
//  AngelDiff
//
//  Created by Uli Kusterer on 02.08.08.
//  Copyright 2008 The Void Software. All rights reserved.
//

#import <Cocoa/Cocoa.h>


@class UKDiffView;


@interface AppDelegate : NSObject
{
	IBOutlet UKDiffView*	diffView;
	NSString*				currPath;
}

@property (retain) NSString*	currPath;

-(void)	exportMerged: (id)sender;

@end
