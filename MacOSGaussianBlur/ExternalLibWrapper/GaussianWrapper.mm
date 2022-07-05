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
#import "PencilLib.h"

#include "typeinfo"


@interface GaussianWrapper()
@property IFilter* gcb;
@end

@implementation GaussianWrapper

- (instancetype)init: (NSString*) name {
    self = [super init];
    
    if (self != nil) {
        _filterType = name;
        if ([_filterType isEqual: @"Blur"]) {
            _gcb = new GaussianCurveBlur();
        } else if ([_filterType isEqual: @"Sepia"]) {
            _gcb = new SepiaFilter();
        } else if ([_filterType isEqual: @"Duo tone"]) {
            NSUInteger r = arc4random_uniform(3);
            _gcb = new DuoToneFilter(Tone(r));
        } else if ([_filterType isEqual: @"Pencil"]) {
            _gcb = new PencilFilter();
        } else if ([_filterType isEqual: @"Cartoon"]) {
            _gcb = new CartoonFilter();
        }
    }
    
    return self;
}

- (void)setPath:(NSString *)path {
    _gcb->setPath([path UTF8String]);
}

- (void)setBlurLevel: (NSInteger)level {
    if (_gcb->_typeName == "gauss")
        ((GaussianCurveBlur *)_gcb)->setEffectLevel((int) level * 10, 0, 0);
    else if (_gcb->_typeName == "duo")
        _gcb->setFilterLevel((int) level / 10);
    else if (_gcb->_typeName == "pen")
        _gcb->setFilterLevel((int) level * 2);
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
