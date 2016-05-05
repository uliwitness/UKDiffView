//
//  NSView+ScrollToRect.h
//  AngelDiff
//
//  Created by Jan on 21.11.11.
//  Copyright 2011 geheimwerk.de. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface NSView (ScrollToRect)

- (void)scrollRectToTop:(NSRect)rect;
- (void)scrollRectToTop:(NSRect)rect withOffset:(CGFloat)percentageOfHeight;

@end
