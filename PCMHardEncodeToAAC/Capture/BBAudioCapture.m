
//
//  BBAudioCapture.m
//  PCMHardEncodeToAAC
//
//  Created by ibabyblue on 2018/2/24.
//  Copyright © 2018年 ibabyblue. All rights reserved.
//

#import "BBAudioCapture.h"
#import <AVFoundation/AVFoundation.h>
#import "BBAudioConfig.h"
#import "BBAudioHardEncoder.h"
#import "BBAudioHardEncoder.h"

@interface BBAudioCapture ()
{
     AudioComponentInstance _outInstance;
}
@property (nonatomic, assign) AudioComponent        component;
@property (nonatomic, strong) AVAudioSession        *session;
@property (nonatomic, strong) BBAudioHardEncoder    *encoder;
@property (nonatomic, strong) NSFileHandle          *handle;
@end

@implementation BBAudioCapture

#pragma mark -- 对象销毁方法
- (void)dealloc{
    AudioComponentInstanceDispose(_outInstance);
}

#pragma mark -- 对外API（控制是否捕捉音频数据）
- (void)startRunning{
    AudioOutputUnitStart(_outInstance);
}

-(void)stopRunning{
    AudioOutputUnitStop(_outInstance);
}

#pragma mark -- 对外API（设置捕获音频数据配置项）
- (void)setConfig:(BBAudioConfig *)config{
    _config = config;
    [self private_setupAudioSession];
}

#pragma mark -- 私有API（初始化音频会话）
- (void)private_setupAudioSession{
    
    //0.初始化编码器
    self.encoder = [[BBAudioHardEncoder alloc] init];
    self.encoder.config = self.config;
    
    //1.获取音频会话实例
    self.session = [AVAudioSession sharedInstance];
    
    NSError *error = nil;
    [self.session setCategory:AVAudioSessionCategoryPlayAndRecord withOptions:AVAudioSessionCategoryOptionMixWithOthers | AVAudioSessionCategoryOptionDefaultToSpeaker error:&error];
    
    if (error) {
        NSLog(@"AVAudioSession setupError");
        error = nil;
        return;
    }
    
    //2.激活会话
    [self.session setActive:YES error:&error];
    
    if (error) {
        NSLog(@"AVAudioSession setActiveError");
        error = nil;
        return;
    }
    
    //3.设置模式
    [self.session setMode:AVAudioSessionModeVideoRecording error:&error];
    
    if (error) {
        NSLog(@"AVAudioSession setModeError");
        error = nil;
        return;
    }
    
    //4.设置音频单元
    AudioComponentDescription acd = {
        .componentType = kAudioUnitType_Output,
        .componentSubType = kAudioUnitSubType_RemoteIO,
        .componentManufacturer = kAudioUnitManufacturer_Apple,
        .componentFlags = 0,
        .componentFlagsMask = 0,
    };
    
    //5.查找音频单元
    self.component = AudioComponentFindNext(NULL, &acd);
    
    //6.获取音频单元实例
    OSStatus status = AudioComponentInstanceNew(self.component, &_outInstance);
    
    if (status != noErr) {
        NSLog(@"AudioSource new AudioComponent error");
        status = noErr;
        return;
    }
    
    //7.设置音频单元属性-->可读写 0-->不可读写 1-->可读写
    UInt32 flagOne = 1;
    AudioUnitSetProperty(_outInstance, kAudioOutputUnitProperty_EnableIO, kAudioUnitScope_Input, 1, &flagOne, sizeof(flagOne));
    
    //8.设置音频单元属性-->音频流
    AudioStreamBasicDescription asbd = {0};
    asbd.mSampleRate = self.config.sampleRate;//采样率
    asbd.mFormatID = kAudioFormatLinearPCM;//原始数据为PCM格式
    asbd.mFormatFlags = kAudioFormatFlagIsSignedInteger | kAudioFormatFlagsNativeEndian | kAudioFormatFlagIsPacked;
    asbd.mChannelsPerFrame = (UInt32)self.config.channels;//每帧的声道数量
    asbd.mFramesPerPacket = 1;//每个数据包多少帧
    asbd.mBitsPerChannel = 16;//16位
    asbd.mBytesPerFrame = asbd.mChannelsPerFrame * asbd.mBitsPerChannel / 8;//每帧多少字节 bytes -> bit / 8
    asbd.mBytesPerPacket = asbd.mFramesPerPacket * asbd.mBytesPerFrame;//每个包多少字节
    
    status = AudioUnitSetProperty(_outInstance, kAudioUnitProperty_StreamFormat, kAudioUnitScope_Output, 1, &asbd, sizeof(asbd));
    
    if (status != noErr) {
        NSLog(@"AudioUnitSetProperty StreamFormat error");
        status = noErr;
        return;
    }
    
    //9.设置回调函数
    AURenderCallbackStruct cb;
    cb.inputProcRefCon = (__bridge void *)self;
    cb.inputProc = audioBufferCallBack;
    
    status = AudioUnitSetProperty(_outInstance, kAudioOutputUnitProperty_SetInputCallback, kAudioUnitScope_Global, 1, &cb, sizeof(cb));
    
    if(status != noErr){
        NSLog(@"AudioUnitSetProperty StreamFormat InputCallback error");
        status = noErr;
        return;
    }
    
    //10.初始化音频单元
    status = AudioUnitInitialize(_outInstance);
    
    if (status != noErr) {
        NSLog(@"AudioUnitInitialize error");
        status = noErr;
        return;
    }
    
    //11.设置优先采样率
    [self.session setPreferredSampleRate:self.config.sampleRate error:&error];
    
    if (error) {
        NSLog(@"AudioSource setPreferredSampleRate error");
        error = nil;
        return;
    }
    
    //12.aac文件夹地址
    NSString *audioPath = [[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject] stringByAppendingPathComponent:@"test.aac"];
    [[NSFileManager defaultManager] removeItemAtPath:audioPath error:nil];
    [[NSFileManager defaultManager] createFileAtPath:audioPath contents:nil attributes:nil];
    self.handle = [NSFileHandle fileHandleForWritingAtPath:audioPath];
    
}

#pragma mark -- 音频流回调函数
static OSStatus audioBufferCallBack(void *inRefCon,
                                    AudioUnitRenderActionFlags *ioActionFlags,
                                    const AudioTimeStamp *inTimeStamp,
                                    UInt32 inBusNumber,
                                    UInt32 inNumberFrames,
                                    AudioBufferList *ioData) {
    @autoreleasepool {
        BBAudioCapture *capture = (__bridge BBAudioCapture *)inRefCon;
        if(!capture) return -1;
        
        AudioBuffer buffer;
        buffer.mData = NULL;
        buffer.mDataByteSize = 0;
        buffer.mNumberChannels = 1;
        
        AudioBufferList buffers;
        buffers.mNumberBuffers = 1;
        buffers.mBuffers[0] = buffer;
        
        OSStatus status = AudioUnitRender(capture->_outInstance,
                                          ioActionFlags,
                                          inTimeStamp,
                                          inBusNumber,
                                          inNumberFrames,
                                          &buffers);
        
        if(status == noErr) {
            [capture.encoder encodeWithBufferList:buffers completianBlock:^(NSData *encodedData, NSError *error) {
                if (error) {
                    NSLog(@"error:%@",error);
                    return;
                }
                
                NSLog(@"write to file!");
                [capture.handle writeData:encodedData];
            }];
        }
        
        return status;
    }
}

@end
