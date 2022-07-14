//
//  VideoEncoder.h
//  Encoder Demo
//
//  Created by Geraint Davies on 14/01/2013.
//  Copyright (c) 2013 GDCL http://www.gdcl.co.uk/license.htm
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>

@interface VideoEncoder : NSObject
{
    AVAssetWriter* _writer;
    AVAssetWriterInput* _videoInput;
    AVAssetWriterInput* _audioInput;
    NSString* _path;
}

@property NSString* path;

+ (VideoEncoder*) encoderForPath:(NSString*) path Height:(int) height andWidth:(int) width videoTrack:(CMFormatDescriptionRef)videoTrack audioTrack:(CMFormatDescriptionRef)audioTrack;

- (void) initPath:(NSString*)path Height:(int) height andWidth:(int) width videoTrack:(CMFormatDescriptionRef)videoTrack audioTrack:(CMFormatDescriptionRef)audioTrack;
- (void) finishWithCompletionHandler:(void (^)(void))handler;
- (BOOL) encodeFrame:(CMSampleBufferRef) sampleBuffer mediaType:(AVMediaType)mediaType;


@end
