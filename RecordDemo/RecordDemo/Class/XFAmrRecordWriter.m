//
//  XFAmrRecordWriter.m
//  XFAudioRecorder
//
//  Created by 胡凯 on 2020/6/12.
//  Copyright © 2020 胡凯. All rights reserved.
//

#import "XFAmrRecordWriter.h"
//amr编码
#import "interf_enc.h"

@interface XFAmrRecordWriter()
{
    FILE *_file;
    void *_destate;
}

@property (nonatomic, assign) unsigned long recordedFileSize;
@property (nonatomic, assign) double recordedSecondCount;

@end

@implementation XFAmrRecordWriter

- (BOOL)createFileWithRecorder:(XFAudioRecorder *)recoder;
{
    _destate = 0;
    // amr 压缩句柄
    _destate = Encoder_Interface_init(0);
    
    if(_destate==0){
        return NO;
    }
    //建立amr文件
    _file = fopen((const char *)[self.filePath UTF8String], "wb+");
    if (_file==0) {
        return NO;
    }
    self.recordedFileSize = 0;
    self.recordedSecondCount = 0;

    //写入文件头
    static const char* amrHeader = "#!AMR\n";
    if(fwrite(amrHeader, 1, strlen(amrHeader), _file)==0){
        return NO;
    }
    self.recordedFileSize += strlen(amrHeader);
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
    const void *recordingData = data.bytes;
    NSUInteger pcmLen = data.length;
    
    if (pcmLen<=0){
        return YES;
    }
    if (pcmLen%2!=0){
        pcmLen--; //防止意外，如果不是偶数，情愿减去最后一个字节。
    }
    
    unsigned char buffer[320];
    for (int i =0; i < pcmLen ;i+=160*2) {
        short *pPacket = (short *)((unsigned char*)recordingData+i);
        if (pcmLen-i<160*2){
            continue; //不是一个完整的就拜拜
        }
        
        memset(buffer, 0, sizeof(buffer));
        //encode
        int recvLen = Encoder_Interface_Encode(_destate,MR515,pPacket,buffer,0);
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
                return NO;//只有写文件有可能出错。返回NO
            }
            self.recordedFileSize += recvLen;
        }
    }
    
    return YES;
}

- (BOOL)completeWriteWithRecorder:(XFAudioRecorder*)recoder withIsError:(BOOL)isError
{
    //关闭就关闭吧。管他关闭成功与否
    if(_file){
        fclose(_file);
        _file = 0;
    }
    if (_destate){
        Encoder_Interface_exit((void*)_destate);
        _destate = 0;
    }
    
    return YES;
}

- (void)dealloc
{
    if(_file){
        fclose(_file);
        _file = 0;
    }
    if (_destate){
        Encoder_Interface_exit((void*)_destate);
        _destate = 0;
    }
}

@end
