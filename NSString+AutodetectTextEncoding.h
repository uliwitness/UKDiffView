//
//  NSString+AutodetectTextEncoding.h
//  AngelDiff
//
//  Created by Jan on 21.11.11.
//

#import <Foundation/Foundation.h>

// This category to discover file encoding is based on code provided by Rainer Brockerhoff.
// http://brockerhoff.net/src/FolderSweep.zip

// The heuristic used should work for most text files on a developer's system, but is by no means complete. 
// If you want to to detect the encoding of text from the wild (internet), you will probably be better off using
// https://github.com/JanX2/UniversalDetector

@interface NSString (AutodetectTextEncoding)

- (id)initWithData:(NSData *)data autodetectedEncoding:(NSStringEncoding *)enc;

@end
