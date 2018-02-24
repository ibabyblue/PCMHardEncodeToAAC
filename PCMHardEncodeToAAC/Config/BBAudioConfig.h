//
//  BBAudioConfig.h
//  PCMHardEncodeToAAC
//
//  Created by ibabyblue on 2018/2/24.
//  Copyright © 2018年 ibabyblue. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 *  音频码率
 */
typedef NS_ENUM(NSUInteger, BBAudioBitRate) {
    BBAudioBitRate_32Kbps  = 32000 ,
    BBAudioBitRate_64Kbps  = 64000 ,
    BBAudioBitRate_96Kbps  = 96000 ,
    BBAudioBitRate_128Kbps = 128000,
    BBAudioBitRate_Default = 64000//默认64Kbps
};

/**
 *  采样率
 */
typedef NS_ENUM(NSUInteger, BBAudioSampleRate) {
    BBAudioSampleRate_22050Hz = 22050,
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
 *  码率
 */
@property (nonatomic,assign) BBAudioBitRate bitRate;
/**
 *  采样率
 */
@property (nonatomic,assign) BBAudioSampleRate sampleRate;
/**
 *  默认配置
 */
+ (instancetype)defaultConfig;
@end
