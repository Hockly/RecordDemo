//
//  XFWavRecordWriter.m
//  XFAudioRecorderPlugin
//
//  Created by hock on 2019/3/27.
//  Copyright © 2019 hock. All rights reserved.
//

#import "XFWavRecordWriter.h"
#include "wavwriter.h"

@interface XFWavRecordWriter ()
{
    void* _writer;
}

@end

@implementation XFWavRecordWriter

- (AudioStreamBasicDescription)customAudioFormatBeforeCreateFile {
    AudioStreamBasicDescription asbd;
    memset(&asbd, 0, sizeof(asbd));
    asbd.mSampleRate = 16000;            //采样率
    asbd.mFormatID = kAudioFormatLinearPCM;
    asbd.mFormatFlags = kLinearPCMFormatFlagIsSignedInteger | kAudioFormatFlagIsPacked;
    asbd.mChannelsPerFrame = 1;         //单声道
    asbd.mFramesPerPacket = 1;          //每一个packet一侦数据
    asbd.mBitsPerChannel = 16;          //每个采样点16bit量化
    asbd.mBytesPerFrame = (asbd.mBitsPerChannel / 8) * asbd.mChannelsPerFrame;
    asbd.mBytesPerPacket = asbd.mBytesPerFrame ;
    asbd.mReserved = 0;
    return asbd;
}

- (BOOL)createFileWithRecorder:(XFAudioRecorder*)recoder {
    if (_filePath.length==0) {
        return NO;
    }
    NSFileManager *fileManager = [NSFileManager defaultManager];
    if ([fileManager fileExistsAtPath:_filePath]) {
        return YES;
    }
    NSError *error;
    NSString *dirPath = [_filePath stringByDeletingLastPathComponent];
    BOOL isSuccess = [fileManager createDirectoryAtPath:dirPath withIntermediateDirectories:YES attributes:nil error:&error];
    if (error) {
        NSLog(@"creat File Failed:%@",[error localizedDescription]);
    }
    if (!isSuccess) {
        return isSuccess;
    }
    isSuccess = [fileManager createFileAtPath:_filePath contents:nil attributes:nil];
    
    const char *cPath = [_filePath UTF8String];
    _writer = wav_write_open(cPath, 16000, 16, 1);
    if (_writer) {
        NSLog(@"打开录音文件成功！");
    }
    return isSuccess;
}

- (BOOL)writeIntoFileWithData:(NSData*)data withRecorder:(XFAudioRecorder*)recoder inAQ:(AudioQueueRef)                        inAQ inStartTime:(const AudioTimeStamp *)inStartTime inNumPackets:(UInt32)inNumPackets inPacketDesc:(const AudioStreamPacketDescription*)inPacketDesc {
    int pcmLen = (int)data.length;
    if (pcmLen <= 0) {
        return YES;
    }
    unsigned char *byteArray = (unsigned char *)[data bytes];
    NSLog(@"--字节数%lu", sizeof(byteArray));
    wav_write_data(_writer, byteArray, pcmLen);
    return YES;
}

- (BOOL)completeWriteWithRecorder:(XFAudioRecorder*)recoder withIsError:(BOOL)isError
{
    if (_writer) {
        wav_write_close(_writer);
    }
    return YES;
}

- (void)dealloc
{
    if (_writer) {
        wav_write_close(_writer);
    }
}

@end
