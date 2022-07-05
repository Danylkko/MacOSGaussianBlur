//
//  GaussianWrapper.h
//  MacOSGaussianBlur
//
//  Created by Danylo Litvinchuk on 11.06.2022.
//

#import <Foundation/Foundation.h>
#import <AppKit/AppKit.h>

@interface GaussianWrapper : NSObject

@property NSString* filterType;

- (instancetype) init: (NSString*) name;
- (void) setPath: (NSString*) path;
- (void) setBlurLevel: (NSInteger) level;
//- (void) setBlurLevel: (NSInteger) level sigmaX:(NSInteger)sigmaX sigmaY: (NSInteger)sigmaY;
- (NSImage*) blurredOutput;
@end
