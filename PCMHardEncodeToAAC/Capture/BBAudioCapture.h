//
//  BBAudioCapture.h
//  PCMHardEncodeToAAC
//
//  Created by ibabyblue on 2018/2/24.
//  Copyright © 2018年 ibabyblue. All rights reserved.
//

#import <Foundation/Foundation.h>

@class BBAudioConfig;

@interface BBAudioCapture : NSObject
@property (nonatomic, strong) BBAudioConfig *config;

/**
 开始捕捉音频数据
 */
- (void)startRunning;

/**
 停止捕捉音频数据
 */
- (void)stopRunning;
@end
