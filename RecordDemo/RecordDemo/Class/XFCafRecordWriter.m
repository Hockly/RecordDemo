//
//  XFCafRecordWriter.m
//  XFAudioRecorder
//
//  Created by 胡凯 on 2020/6/12.
//  Copyright © 2020 胡凯. All rights reserved.
//

#import "XFCafRecordWriter.h"

@interface XFCafRecordWriter()
{
    AudioFileID mRecordFile;
    SInt64 recordPacketCount;
}

@end

@implementation XFCafRecordWriter

- (BOOL)createFileWithRecorder:(XFAudioRecorder *)recoder
{
    //建立文件
    recordPacketCount = 0;
    
    CFURLRef url = CFURLCreateWithString(kCFAllocatorDefault, (CFStringRef)self.filePath, NULL);
    OSStatus err = AudioFileCreateWithURL(url, kAudioFileCAFType, (const AudioStreamBasicDescription    *)(&(recoder->_recordFormat)), kAudioFileFlags_EraseFile, &mRecordFile);
    CFRelease(url);
    
    return err==noErr;
}

- (BOOL)writeIntoFileWithData:(NSData*)data withRecorder:(XFAudioRecorder *)recoder inAQ:(AudioQueueRef)                        inAQ inStartTime:(const AudioTimeStamp *)inStartTime inNumPackets:(UInt32)inNumPackets inPacketDesc:(const AudioStreamPacketDescription*)inPacketDesc
{
    OSStatus err = AudioFileWritePackets(mRecordFile, FALSE, data.length,
                                         inPacketDesc, recordPacketCount, &inNumPackets, data.bytes);
    if (err!=noErr) {
        return NO;
    }
    recordPacketCount += inNumPackets;
    
    return YES;
}

- (BOOL)completeWriteWithRecorder:(XFAudioRecorder *)recoder withIsError:(BOOL)isError
{
    if (mRecordFile) {
        AudioFileClose(mRecordFile);
    }
    
    return YES;
}

-(void)dealloc
{
    if (mRecordFile) {
        AudioFileClose(mRecordFile);
    }
}

@end
