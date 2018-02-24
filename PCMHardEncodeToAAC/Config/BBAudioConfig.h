//
//  BBAudioConfig.h
//  PCMHardEncodeToAAC
//
//  Created by ibabyblue on 2018/2/24.
//  Copyright © 2018年 ibabyblue. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 *  采样率
 */
typedef NS_ENUM(NSUInteger, BBAudioSampleRate) {
    BBAudioSampleRate_22050Hz = 22050,//效果较差，现阶段将淘汰
    BBAudioSampleRate_44100Hz = 44100,
    BBAudioSampleRate_48000Hz = 48000,
    BBAudioSampleRate_Defalut = 44100//默认44100
};

@interface BBAudioConfig : NSObject
/**
 *  声道数
 */
@property (nonatomic,assign) NSUInteger channels;
/**
 *  采样率
 */
@property (nonatomic,assign) BBAudioSampleRate sampleRate;
/**
 *  默认配置
 */
+ (instancetype)defaultConfig;
@end
