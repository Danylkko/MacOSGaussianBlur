//
//  GaussianWrapper.m
//  MacOSGaussianBlur
//
//  Created by Danylo Litvinchuk on 11.06.2022.
//

#import "GaussianWrapper.h"
#import "BlurLib.h"
#import "IFilter.h"
#import "CartoonLib.h"
#import "SepiaLib.h"
#import "DuoToneLib.h"


@interface GaussianWrapper()
@property IFilter* gcb;
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
    _gcb->setFilterLevel((int) level);
}

- (void)setBlurLevel:(NSInteger)level sigmaX:(NSInteger)sigmaX sigmaY:(NSInteger)sigmaY {
//    ((GaussianCurveBlur *)_gcb)->setEffectLevel((int)level, sigmaX, sigmaY);
}

- (NSImage *)blurredOutput {
    const unsigned char * blurredData = _gcb->processedOutput();
    const int bytesPerRow = _gcb->getImageCols() * GaussianCurveBlur::channels;
    
    NSBitmapImageRep *bitmap = [[NSBitmapImageRep alloc]
                                initWithBitmapDataPlanes:(unsigned char **)&blurredData
                                pixelsWide:_gcb->getImageCols()
                                pixelsHigh:_gcb->getImageRows()
                                bitsPerSample:8
                                samplesPerPixel:GaussianCurveBlur::channels
                                hasAlpha:NO
                                isPlanar:NO
                                colorSpaceName:NSDeviceRGBColorSpace
                                bytesPerRow:bytesPerRow
                                bitsPerPixel:8 * GaussianCurveBlur::channels];
    
    NSImage* image = [[NSImage alloc]init];
    [image addRepresentation:bitmap];
    
    return image;
}

@end
