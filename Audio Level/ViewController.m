//
//  ViewController.m
//  Audio Level
//
//  Created by Johannes Wärn on 2017-05-03.
//  Copyright © 2017 Forza. All rights reserved.
//

@import AVFoundation;

#import "ViewController.h"

@interface ViewController ()

@property (weak, nonatomic) IBOutlet UILabel *audioLevelLabel;

@property (nonatomic) AVCaptureSession *captureSession;
@property (nonatomic) AVCaptureDeviceInput *micDeviceInput;
@property (nonatomic) AVCaptureAudioDataOutput *audioDataOutput;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.captureSession = [[AVCaptureSession alloc] init];
    [self.captureSession beginConfiguration];
    
    AVCaptureDevice *micDevice = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeAudio];
    self.micDeviceInput = [[AVCaptureDeviceInput alloc] initWithDevice:micDevice error:nil];
    [self.captureSession addInput:self.micDeviceInput];
    
    self.audioDataOutput = [[AVCaptureAudioDataOutput alloc] init];
    [self.captureSession addOutput:self.audioDataOutput];
    
    [self.captureSession commitConfiguration];
    [self.captureSession startRunning];
    
    [NSTimer scheduledTimerWithTimeInterval:0.2 target:self selector:@selector(updateAudioLevels:) userInfo:nil repeats:YES];
}

- (void)updateAudioLevels:(NSTimer *)timer
{
    NSInteger channelCount = 0;
    float decibels = 0.f;
    
    // Sum all of the average power levels and divide by the number of channels
    for (AVCaptureConnection *connection in [self.audioDataOutput connections]) {
        for (AVCaptureAudioChannel *audioChannel in [connection audioChannels]) {
            decibels += [audioChannel averagePowerLevel];
            channelCount += 1;
        }
    }
    
    decibels /= channelCount;
    
    if (decibels < -10) {
        self.view.backgroundColor = [UIColor blackColor];
    } else {
        self.view.backgroundColor = [UIColor redColor];
    }
    
    [self.audioLevelLabel setText:[NSString stringWithFormat:@"current audio level: %@", @(round(pow(10.f, 0.05f * decibels) * 20.0f * 10.0f) / 10.0f)]];
}

- (BOOL)prefersStatusBarHidden
{
    return YES;
}

@end
