//
//  ViewController.m
//  XFAudioRecorderDemo
//
//  Created by 胡凯 on 2020/6/12.
//  Copyright © 2020 胡凯. All rights reserved.
//

#import "ViewController.h"
#import "XFAudioRecorder.h"
#import "XFAudioMeterObserver.h"
#import "XFMp3RecordWriter.h"

@interface ViewController ()

@property (nonatomic, strong) XFAudioRecorder *recorder;
@property (nonatomic, strong) XFMp3RecordWriter *mp3Writer;
@property (nonatomic, strong) XFAudioMeterObserver *meterObserver;
@property (nonatomic, strong) UIButton *button;
@property (nonatomic, strong) UIButton *button2;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view..
    self.view.backgroundColor = [UIColor whiteColor];
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    button.frame = CGRectMake(100, 100, 100, 40);
    button.backgroundColor = [UIColor greenColor];
    [button setTitle:@"开始录音" forState:UIControlStateNormal];
    [button addTarget:self action:@selector(start) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:button];
    self.button = button;
    
    self.view.backgroundColor = [UIColor whiteColor];
    UIButton *button2 = [UIButton buttonWithType:UIButtonTypeCustom];
    button2.frame = CGRectMake(100, 160, 100, 40);
    button2.backgroundColor = [UIColor grayColor];
    [button2 setTitle:@"暂停" forState:UIControlStateNormal];
    [button2 addTarget:self action:@selector(pause) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:button2];
    self.button2 = button2;
    
    self.view.backgroundColor = [UIColor whiteColor];
    UIButton *button3 = [UIButton buttonWithType:UIButtonTypeCustom];
    button3.frame = CGRectMake(100, 220, 100, 40);
    button3.backgroundColor = [UIColor yellowColor];
    [button3 setTitle:@"继续" forState:UIControlStateNormal];
    [button3 addTarget:self action:@selector(resume) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:button3];
    
    self.view.backgroundColor = [UIColor whiteColor];
    UIButton *button4 = [UIButton buttonWithType:UIButtonTypeCustom];
    button4.frame = CGRectMake(100, 280, 100, 40);
    button4.backgroundColor = [UIColor redColor];
    [button4 setTitle:@"结束" forState:UIControlStateNormal];
    [button4 addTarget:self action:@selector(stop) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:button4];

    NSString *path = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];

    XFMp3RecordWriter *mp3Writer = [[XFMp3RecordWriter alloc]init];
    mp3Writer.filePath = [path stringByAppendingPathComponent:@"record.mp3"];
    self.mp3Writer = mp3Writer;

    XFAudioMeterObserver *meterObserver = [[XFAudioMeterObserver alloc]init];
    meterObserver.actionBlock = ^(NSArray *levelMeterStates,XFAudioMeterObserver *meterObserver){

    };
    meterObserver.errorBlock = ^(NSError *error,XFAudioMeterObserver *meterObserver){

    };
    self.meterObserver = meterObserver;

    XFAudioRecorder *recorder = [[XFAudioRecorder alloc]init];
    __weak __typeof(self)weakSelf = self;
    recorder.receiveStoppedBlock = ^{
        weakSelf.meterObserver.audioQueue = nil;
    };
    recorder.receiveErrorBlock = ^(NSError *error){
        weakSelf.meterObserver.audioQueue = nil;


    };

    recorder.bufferDurationSeconds = 0.5;
    recorder.fileWriterDelegate = self.mp3Writer;

    self.recorder = recorder;
}

//开始录音
- (void)start {
    [self.recorder startRecording];
}

//结束录音
- (void)stop {
    [self.recorder stopRecording];
}

//停止录音
- (void)pause {
    [self.recorder pauseRecording];
}

//继续录音
- (void)resume {
    [self.recorder resumeRecording];
}

//录音数据回调
- (void)onReturnBuffer:(XFAudioRecorder *)recorder buffer:(Byte *)buffer bufferSize:(int)size {

}


@end
