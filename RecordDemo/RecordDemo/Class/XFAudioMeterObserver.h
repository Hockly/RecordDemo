//
//  XFAudioMeterObserver.h
//  AIPen
//
//  Created by hock on 2018/9/20.
//  Copyright © 2018年 IFly. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AudioToolbox/AudioToolbox.h>
@class XFAudioMeterObserver;

typedef void (^XFAudioMeterObserverActionBlock)(NSArray *levelMeterStates,XFAudioMeterObserver *meterObserver);
typedef void (^XFAudioMeterObserverErrorBlock)(NSError *error,XFAudioMeterObserver *meterObserver);

/**
 *  错误标识
 */
typedef NS_OPTIONS(NSUInteger, XFAudioMeterObserverErrorCode) {
    XFAudioMeterObserverErrorCodeAboutQueue, //关于音频输入队列的错误
};

@interface XFLevelMeterState : NSObject

@property (nonatomic, assign) Float32 mAveragePower;
@property (nonatomic, assign) Float32 mPeakPower;

@end

@interface XFAudioMeterObserver : NSObject

{
    AudioQueueRef                _audioQueue;
    AudioQueueLevelMeterState    *_levelMeterStates;
}

@property AudioQueueRef audioQueue;

@property (nonatomic, copy) XFAudioMeterObserverActionBlock actionBlock;

@property (nonatomic, copy) XFAudioMeterObserverErrorBlock errorBlock;
/** 刷新间隔,默认0.1 */
@property (nonatomic, assign) NSTimeInterval refreshInterval;

/**
 *  根据meterStates计算出音量，音量为 0-1
 *
 */
+ (Float32)volumeForLevelMeterStates:(NSArray*)levelMeterStates;

@end
