//
//  GaussianWrapper.m
//  MacOSGaussianBlur
//
//  Created by Danylo Litvinchuk on 11.06.2022.
//

#import "GaussianWrapper.h"
#import "BlurLib.h"

@interface GaussianWrapper()
@property GaussianCurveBlur* gcb;
@end

@implementation GaussianWrapper

- (instancetype)init {
    self = [super init];
    
    if (self != nil) {
        _gcb = new GaussianCurveBlur();
    }
    
    return self;
}

- (void)setPath:(NSString *)path {
    _gcb->setPath([path UTF8String]);
}

- (void)setBlurLevel: (NSInteger)level {
    _gcb->setBlurLevel((int) level);
}

- (NSImage *)blurredOutput {
    const unsigned char * blurredData = _gcb->blurredOutput();
    const int bytesPerRow = _gcb->blurredMatCols() * GaussianCurveBlur::channels;
    
    NSBitmapImageRep *bitmap = [[NSBitmapImageRep alloc]
                                initWithBitmapDataPlanes:(unsigned char **)&blurredData
                                pixelsWide:_gcb->blurredMatCols()
                                pixelsHigh:_gcb->blurredMatRows()
                                bitsPerSample:8
                                samplesPerPixel:GaussianCurveBlur::channels
                                hasAlpha:YES
                                isPlanar:NO
                                colorSpaceName:NSDeviceRGBColorSpace
                                bytesPerRow:bytesPerRow
                                bitsPerPixel:8 * GaussianCurveBlur::channels];
    
    NSImage* image = [[NSImage alloc]init];
    [image addRepresentation:bitmap];
    
    return image;
}

@end
