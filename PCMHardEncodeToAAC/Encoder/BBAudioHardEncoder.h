//
//  BBAudioHardEncoder.h
//  PCMHardEncodeToAAC
//
//  Created by ibabyblue on 2018/2/24.
//  Copyright © 2018年 ibabyblue. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AudioToolbox/AudioToolbox.h>

@class BBAudioConfig;

@interface BBAudioHardEncoder : NSObject

@property (nonatomic,strong) BBAudioConfig *config;

- (void)encodeWithBufferList:(AudioBufferList)bufferList completianBlock:(void (^)(NSData *encodedData, NSError *error))completionBlock;
@end
