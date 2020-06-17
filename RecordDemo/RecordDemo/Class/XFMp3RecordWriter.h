//
//  XFMp3RecordWriter.h
//  XFAudioRecorder
//
//  Created by 胡凯 on 2020/6/12.
//  Copyright © 2020 胡凯. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "XFAudioRecorder.h"

NS_ASSUME_NONNULL_BEGIN

@interface XFMp3RecordWriter : NSObject<XFAudioRecorderFileWriter>

@property (nonatomic, copy) NSString *filePath;
@property (nonatomic, assign) unsigned long maxFileSize;
@property (nonatomic, assign) double maxSecondCount;

@end

NS_ASSUME_NONNULL_END
