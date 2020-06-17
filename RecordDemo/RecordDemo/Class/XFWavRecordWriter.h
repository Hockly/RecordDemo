//
//  XFWavRecordWriter.h
//  XFAudioRecorderPlugin
//
//  Created by hock on 2019/3/27.
//  Copyright © 2019 hock. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "XFAudioRecorder.h"

NS_ASSUME_NONNULL_BEGIN

@interface XFWavRecordWriter : NSObject<XFAudioRecorderFileWriter>

@property (nonatomic, copy) NSString *filePath;

@end

NS_ASSUME_NONNULL_END
