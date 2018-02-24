//
//  BBAudioConfig.m
//  PCMHardEncodeToAAC
//
//  Created by ibabyblue on 2018/2/24.
//  Copyright © 2018年 ibabyblue. All rights reserved.
//

#import "BBAudioConfig.h"

@implementation BBAudioConfig

+(instancetype)defaultConfig{
    BBAudioConfig *config = [[self alloc] init];
    config.channels = 2;
    config.bitRate = BBAudioBitRate_Default;
    config.sampleRate = BBAudioSampleRate_44100Hz;
    return config;
}

@end
