//
//  XFAudioRecorder.h
//  AIPen
//
//  Created by hock on 2018/9/20.
//  Copyright © 2018年 IFly. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AudioToolbox/AudioToolbox.h>
@class XFAudioRecorder;

//录音停止事件的block回调，作用参考MLAudioRecorderDelegate的recordStopped和recordError:
typedef void (^XFAudioRecorderReceiveStoppedBlock)(void);
typedef void (^XFAudioRecorderReceiveErrorBlock)(NSError *error);

//错误标识
typedef NS_OPTIONS(NSUInteger, XFAudioRecorderErrorCode) {
    XFAudioRecorderErrorCodeAboutFile = 0, //关于文件操作的错误
    XFAudioRecorderErrorCodeAboutQueue, //关于音频输入队列的错误
    XFAudioRecorderErrorCodeAboutSession, //关于audio session的错误
    XFAudioRecorderErrorCodeAboutOther, //关于其他的错误
};

/**
 *  处理写文件操作的，实际是转码的操作在其中进行。算作可扩展自定义的转码器
 *  当然如果是实时语音的需求的话，就可以在此处理编码后发送语音数据到对方
 *  三个方法是在后台线程中处理的
 */
@protocol XFAudioRecorderFileWriter <NSObject>

@optional
//设置格式
- (AudioStreamBasicDescription)customAudioFormatBeforeCreateFile;
@required
//在录音开始时候建立文件和写入文件头信息等操作
- (BOOL)createFileWithRecorder:(XFAudioRecorder*)recoder;
//写入文件方法
- (BOOL)writeIntoFileWithData:(NSData*)data withRecorder:(XFAudioRecorder*)recoder inAQ:(AudioQueueRef)inAQ inStartTime:(const AudioTimeStamp *)inStartTime inNumPackets:(UInt32)inNumPackets inPacketDesc:(const AudioStreamPacketDescription*)inPacketDesc;
//文件写入完成之后的操作 IsError:否是因为错误才调用
- (BOOL)completeWriteWithRecorder:(XFAudioRecorder*)recoder withIsError:(BOOL)isError;

@end

@protocol XFAudioRecorderDelegate <NSObject>

@optional
//录音被停止 一般是在writer delegate中因为一些状况意外停止录音获得此事件时候使用
- (void)recordStopped;
//录音遇到了错误，例如创建文件失败啊。写入失败啊。关闭文件失败啊，等等。
- (void)recordError:(NSError *)error;
//录音数据回调
- (void)onReturnBuffer:(XFAudioRecorder *)recorder buffer:(Byte *)buffer bufferSize:(int)size;

@end

@interface XFAudioRecorder : NSObject
{
@public
    //音频输入队列
    AudioQueueRef                _audioQueue;
    //音频输入数据format
    AudioStreamBasicDescription    _recordFormat;
}

/**
 *  是否正在录音
 */
@property (atomic, assign,readonly) BOOL isRecording;

@property (nonatomic, assign, getter=isPause) BOOL pause;

/**
 *  这俩是当前的采样率和缓冲区采集秒数，根据情况可以设置(对其设置必须在startRecording之前才有效)，随意设置可能有意外发生。
 *  这俩属性被标识为原子性的，读取写入是线程安全的。
 */
@property (atomic, assign) NSUInteger sampleRate;
@property (atomic, assign) double bufferDurationSeconds;

/**
 *  处理写文件操作的，实际是转码的操作在其中进行。算作可扩展自定义的转码器
 */
@property (nonatomic, weak) id<XFAudioRecorderFileWriter> fileWriterDelegate;

/**
 *  参考MLAudioRecorderReceiveStoppedBlock和MLAudioRecorderReceiveErrorBlock
 */
@property (nonatomic, copy) XFAudioRecorderReceiveStoppedBlock receiveStoppedBlock;
@property (nonatomic, copy) XFAudioRecorderReceiveErrorBlock receiveErrorBlock;

/**
 *  参考MLAudioRecorderDelegate
 */
@property (nonatomic, weak) id<XFAudioRecorderDelegate> delegate;
/**
 * 开始录音
 */
- (void)startRecording;
/**
 * 结束录音
 */
- (void)stopRecording;
/**
 * 暂停录音
 */
- (void)pauseRecording;
/**
 * 继续录音
 */
- (void)resumeRecording;

@end
