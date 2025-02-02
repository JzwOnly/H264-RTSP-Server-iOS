//
//  AVEncoder.h
//  Encoder Demo
//
//  Created by Geraint Davies on 14/01/2013.
//  Copyright (c) 2013 GDCL http://www.gdcl.co.uk/license.htm
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>

typedef int (^encoder_handler_t)(NSArray* data, double pts);
typedef int (^param_handler_t)(NSData* params);

@interface AVEncoder : NSObject

+ (AVEncoder*) encoderForHeight:(int) height andWidth:(int) width videoTrack:(CMFormatDescriptionRef)videoTrack audioTrack:(CMFormatDescriptionRef)audioTrack;

- (void) encodeWithBlock:(encoder_handler_t) block onParams: (param_handler_t) paramsHandler;
- (void) encodeFrame:(CMSampleBufferRef) sampleBuffer mediaType:(AVMediaType)mediaType;
- (NSData*) getConfigData;
- (void) shutdown;


@property (readonly, atomic) int bitspersecond;

@end
