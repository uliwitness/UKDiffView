//
//  NSString+AutodetectTextEncoding.m
//  AngelDiff
//
//  Created by Jan on 21.11.11.
//

#import "NSString+AutodetectTextEncoding.h"

@implementation NSString (AutodetectTextEncoding)

- (id)initWithData:(NSData *)data autodetectedEncoding:(NSStringEncoding *)enc;
{
	CFStringEncoding encoding = kCFStringEncodingUTF8;
	
	// If the file contents is longer than zero bytes, we try to determine what 
	//	text-encoding the file uses, by looking at the BOM bytes for common encodings.
	// This heuristic should work for most text files on a developer's system,
	//	but is by no means complete.
	
	NSUInteger length = [data length];
	if (length > 0) {
		// We get a pointer to the actual bytes here, in order to look at the first ones.
		UInt8* bytes = (UInt8*)[data bytes];
		encoding = CFStringGetSystemEncoding();
		Boolean bom = TRUE;
		switch (bytes[0]) {
			case 0x00:
				if (length>3 && bytes[1]==0x00 && bytes[2]==0xFE && bytes[3]==0xFF) {
					encoding = kCFStringEncodingUTF32BE;
				}
				break;
			case 0xEF:
				if (length>2 && bytes[1]==0xBB && bytes[2]==0xBF) {
					encoding = kCFStringEncodingUTF8;
				}
				break;
			case 0xFE:
				if (length>1 && bytes[1]==0xFF) {
					encoding = kCFStringEncodingUTF16BE;
				}
				break;
			case 0xFF:
				if (length>1 && bytes[1]==0xFE) {
					if (length>3 && bytes[2]==0x00 && bytes[3]==0x00) {
						encoding = kCFStringEncodingUTF32LE;
					} else {
						encoding = kCFStringEncodingUTF16LE;
					}
				}
				break;
			default:
				bom = FALSE;
				encoding = kCFStringEncodingUTF8; // fall back on UTF8
				break;
		}
		
		// Try to create an NSString with the encoding we determined.
		NSString* string = (NSString*)CFStringCreateWithBytes(kCFAllocatorDefault, bytes, length, 
															  encoding, bom);
		
		if (!string && !bom && (encoding == kCFStringEncodingUTF8)) {
			// If we failed, try creating an NSString with the system encoding instead;
			//	this will normally be MacRoman.
			encoding = CFStringGetSystemEncoding();
			string = (NSString*)CFStringCreateWithBytes(kCFAllocatorDefault, bytes, length, 
														encoding, FALSE);
		}
		
		if (string) {
			self = string;
		}
	}
	
	NSStringEncoding detectedEncoding = CFStringConvertEncodingToNSStringEncoding(encoding);
	
	if (self != nil) {
		self = [[[NSString alloc] initWithData:data encoding:detectedEncoding] autorelease];
	}
	
	if (enc != NULL) {
		*enc = detectedEncoding;
	}
	
	return self;
}

@end
