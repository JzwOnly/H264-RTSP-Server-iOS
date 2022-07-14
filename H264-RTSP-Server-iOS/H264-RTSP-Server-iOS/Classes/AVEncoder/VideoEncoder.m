//
//  VideoEncoder.m
//  Encoder Demo
//
//  Created by Geraint Davies on 14/01/2013.
//  Copyright (c) 2013 GDCL http://www.gdcl.co.uk/license.htm
//

#import "VideoEncoder.h"

@implementation VideoEncoder

@synthesize path = _path;

+ (VideoEncoder*) encoderForPath:(NSString*) path Height:(int) height andWidth:(int) width videoTrack:(CMFormatDescription)videoTrack audioTrack:(CMFormatDescription)audioTrack
{
    VideoEncoder* enc = [VideoEncoder alloc];
    [enc initPath:path Height:height andWidth:width videoTrack:videoTrack audioTrack:audioTrack];
    return enc;
}


- (void) initPath:(NSString*)path Height:(int) height andWidth:(int) width videoTrack:(CMFormatDescription)videoTrack audioTrack:(CMFormatDescription)audioTrack
{
    self.path = path;
    
    [[NSFileManager defaultManager] removeItemAtPath:self.path error:nil];
    NSURL* url = [NSURL fileURLWithPath:self.path];
    
    _writer = [AVAssetWriter assetWriterWithURL:url fileType:AVFileTypeQuickTimeMovie error:nil];
    
    int videoWidth;
    int videoHeight;
    if (videoTrack) {
        CMVideoDimensions dimensions = CMVideoFormatDescriptionGetDimensions(videoTrack);
        videoWidth = dimensions.width;
        videoHeight = dimensions.height;
    } else {
        videoWidth = width
        videoHeight = height;
    }
    
    // video inputs
    NSDictionary* videoSettings = [NSDictionary dictionaryWithObjectsAndKeys:
                              AVVideoCodecH264, AVVideoCodecKey,
                              [NSNumber numberWithInt:videoWidth], AVVideoWidthKey,
                              [NSNumber numberWithInt:videoHeight], AVVideoHeightKey,
                              [NSDictionary dictionaryWithObjectsAndKeys:
                                    @YES, AVVideoAllowFrameReorderingKey, nil],
                                    AVVideoCompressionPropertiesKey,
                              nil];
    if (videoTrack) {
        _videoInput = [AVAssetWriterInput assetWriterInputWithMediaType:AVMediaTypeVideo outputSettings:videoSettings sourceFormatHint:videoTrack];
    } else {
        _videoInput = [AVAssetWriterInput assetWriterInputWithMediaType:AVMediaTypeVideo outputSettings:videoSettings];
    }
    _videoInput.expectsMediaDataInRealTime = YES;
    if (_writer canAddInput:_videoInput) {
        [_writer addInput:_videoInput];
    }
    
    // audio inputs
    NSDictionary* audioSettings = [NSDictionary dictionaryWithObjectsAndKeys:
                              [NSNumber numberWithInt:kAudioFormatMPEG4AAC], AVFormatIDKey,
                              nil];
    if (audioTrack) {
        _audioInput = [AVAssetWriterInput assetWriterInputWithMediaType:AVMediaTypeAudio outputSettings:audioSettings sourceFormatHint:audioTrack];
    } else {
        _audioInput = [AVAssetWriterInput assetWriterInputWithMediaType:AVMediaTypeAudio outputSettings:audioSettings];
    }
    _audioInput.expectsMediaDataInRealTime = YES;
    if (_writer canAddInput:_audioInput) {
        [_writer addInput:_audioInput];
    }
}

- (void) finishWithCompletionHandler:(void (^)(void))handler
{
    [_writer finishWritingWithCompletionHandler: handler];
}

- (BOOL) encodeFrame:(CMSampleBufferRef) sampleBuffer mediaType:(AVMediaType)mediaType
{
    if (CMSampleBufferDataIsReady(sampleBuffer))
    {
        if (_writer.status == AVAssetWriterStatusUnknown)
        {
            CMTime startTime = CMSampleBufferGetPresentationTimeStamp(sampleBuffer);
            [_writer startWriting];
            [_writer startSessionAtSourceTime:startTime];
        }
        if (_writer.status == AVAssetWriterStatusFailed)
        {
            NSLog(@"writer error %@", _writer.error.localizedDescription);
            return NO;
        }
        AVAssetWriterInput * writerInput = (mediaType == AVMediaTypeVideo ? _videoInput : _audioInput;
        if (writerInput.readyForMoreMediaData == YES)
        {
            [writerInput appendSampleBuffer:sampleBuffer];
            return YES;
        }
    }
    return NO;
}

@end
