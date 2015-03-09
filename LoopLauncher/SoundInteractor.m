//
//  SoundInteractor.m
//  LoopLauncher
//
//  Created by Henry Thiemann on 3/2/15.
//  Copyright (c) 2015 Henry Thiemann. All rights reserved.
//

#import "SoundInteractor.h"

@implementation SoundInteractor

- (instancetype)init {
    self = [super init];
    
    if (self) {
        _state = NO;
        _averagedAmplitude = 0.0;
        
        _volumeUpSequence = [AKSequence sequence];
        _volumeUpEvent = [[AKEvent alloc] initWithBlock:^{
            if (_player.amplitude.value < _player.amplitude.maximum) {
                _player.amplitude.value += 0.005;
                [_volumeUpSequence addEvent:_volumeUpEvent afterDuration:0.01];
            }
        }];
        [_volumeUpSequence addEvent:_volumeUpEvent];
        
        _volumeDownSequence = [AKSequence sequence];
        _volumeDownEvent = [[AKEvent alloc] initWithBlock:^{
            if (_player.amplitude.value > _player.amplitude.minimum) {
                _player.amplitude.value -= 0.005;
                [_volumeDownSequence addEvent:_volumeDownEvent afterDuration:0.01];
            }
        }];
        [_volumeDownSequence addEvent:_volumeDownEvent];
        
        self.strokeColor = [SKColor grayColor];
        self.fillColor = [SKColor darkGrayColor];
        self.alpha = .4;
        self.lineWidth = 3;
        self.blendMode = SKBlendModeAdd;
        self.glowWidth = 5;
}
    
    return self;
}

- (void)turnOn {
    [_volumeDownSequence stop];
    [_volumeUpSequence play];
    self.fillColor = [SKColor whiteColor];
    _state = YES;
}

- (void)turnOff {
    [_volumeUpSequence stop];
    [_volumeDownSequence play];
    self.fillColor = [SKColor darkGrayColor];
    _state = NO;
}

- (void)updateAppearance {
    double bias = 0.84;
    double soundAmplitude = _player.audioAnalyzer.trackedAmplitude.value;
    _averagedAmplitude = bias * _averagedAmplitude + (1 - bias) * soundAmplitude;
    double scaleFactor = 1 + (_averagedAmplitude * 5);
    self.xScale = scaleFactor;
    self.yScale = scaleFactor;
}

@end
