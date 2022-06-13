//
//  GaussianWrapper.h
//  MacOSGaussianBlur
//
//  Created by Danylo Litvinchuk on 11.06.2022.
//

#import <Foundation/Foundation.h>
#import <AppKit/AppKit.h>

@interface GaussianWrapper : NSObject
- (void) setPath: (NSString*) path;
- (void) setBlurLevel: (NSInteger) level;
- (NSImage*) blurredOutput;
@end
