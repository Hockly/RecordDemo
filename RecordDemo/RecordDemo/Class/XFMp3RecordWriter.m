//
//  XFMp3RecordWriter.m
//  XFAudioRecorder
//
//  Created by 胡凯 on 2020/6/12.
//  Copyright © 2020 胡凯. All rights reserved.
//

#import "XFMp3RecordWriter.h"
#import "lame.h"

@interface XFMp3RecordWriter()
{
    FILE *_file;
    lame_t _lame;
}

@property (nonatomic, assign) unsigned long recordedFileSize;
@property (nonatomic, assign) double recordedSecondCount;

@end

@implementation XFMp3RecordWriter

- (BOOL)createFileWithRecorder:(XFAudioRecorder*)recoder;
{
    // mp3压缩参数
    _lame = lame_init();
    lame_set_num_channels(_lame, 1);
    lame_set_in_samplerate(_lame, 8000);
    lame_set_out_samplerate(_lame, 8000);
    lame_set_brate(_lame, 128);
    lame_set_mode(_lame, 1);
    lame_set_quality(_lame, 2);
    lame_init_params(_lame);
    
    //建立mp3文件
    _file = fopen((const char *)[self.filePath UTF8String], "wb+");
    if (_file==0) {
        return NO;
    }

    self.recordedFileSize = 0;
    self.recordedSecondCount = 0;

    return YES;

}

- (BOOL)writeIntoFileWithData:(NSData*)data withRecorder:(XFAudioRecorder*)recoder inAQ:(AudioQueueRef)                        inAQ inStartTime:(const AudioTimeStamp *)inStartTime inNumPackets:(UInt32)inNumPackets inPacketDesc:(const AudioStreamPacketDescription*)inPacketDesc
{
    if (self.maxSecondCount>0){
        if (self.recordedSecondCount+recoder.bufferDurationSeconds>self.maxSecondCount){
            //            DLOG(@"录音超时");
            dispatch_async(dispatch_get_main_queue(), ^{
                [recoder stopRecording];
            });
            return YES;
        }
        self.recordedSecondCount += recoder.bufferDurationSeconds;
    }

    //编码
    short *recordingData = (short*)data.bytes;
    int pcmLen = (int)data.length;

    if (pcmLen<2){
        return YES;
    }

    int nsamples = pcmLen / 2;

    unsigned char buffer[pcmLen];
    // mp3 encode
    int recvLen = lame_encode_buffer(_lame, recordingData, recordingData, nsamples, buffer, pcmLen);
    // add NSMutable
    if (recvLen>0) {
        if (self.maxFileSize>0){
            if(self.recordedFileSize+recvLen>self.maxFileSize){
                //                    DLOG(@"录音文件过大");
                dispatch_async(dispatch_get_main_queue(), ^{
                    [recoder stopRecording];
                });
                return YES;//超过了最大文件大小就直接返回
            }
        }

        if(fwrite(buffer,1,recvLen,_file)==0){
            return NO;
        }
        self.recordedFileSize += recvLen;
    }

    return YES;
}

- (BOOL)completeWriteWithRecorder:(XFAudioRecorder*)recoder withIsError:(BOOL)isError
{
    if(_file){
        fclose(_file);
        _file = 0;
    }

    if(_lame){
        lame_close(_lame);
        _lame = 0;
    }

    return YES;
}

- (void)dealloc
{
    if(_file){
        fclose(_file);
        _file = 0;
    }

    if(_lame){
        lame_close(_lame);
        _lame = 0;
    }
}

@end
