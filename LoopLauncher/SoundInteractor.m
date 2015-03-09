//
//  SoundInteractor.m
//  LoopLauncher
//
//  Created by Henry Thiemann on 3/2/15.
//  Copyright (c) 2015 Henry Thiemann. All rights reserved.
//

#import "SoundInteractor.h"

@interface SoundInteractor ()

@property(nonatomic) SoundFilePlayer *player;
@property BOOL state;
@property double averagedAmplitude;
@property float fillGrayScaleValue;

@property(nonatomic) AKSequence *volumeUpSequence;
@property(nonatomic) AKSequence *volumeDownSequence;
@property(nonatomic) AKEvent *volumeDownEvent;
@property(nonatomic) AKEvent *volumeUpEvent;

@end


@implementation SoundInteractor

float grayScaleValueOff = 0.3;
float grayScaleValueOn = 1.0;
float fadeTimeInSeconds = 1.0;

- (instancetype)init {
    self = [super init];
    
    if (self) {
        self.fillGrayScaleValue = grayScaleValueOff;
        self.strokeColor = [SKColor grayColor];
        self.alpha = .4;
        self.lineWidth = 3;
        self.blendMode = SKBlendModeAdd;
        self.glowWidth = 5;
    }
    
    return self;
}

- (void)setPlayer:(SoundFilePlayer *)player {
    _player = player;
    _state = NO;
    _averagedAmplitude = 0.0;
    
    float volumeStepSize = _player.amplitude.maximum / (fadeTimeInSeconds / 0.01);
    float grayScaleStepSize = (grayScaleValueOn - grayScaleValueOff) / (fadeTimeInSeconds / 0.01);
        
    _volumeUpSequence = [AKSequence sequence];
    _volumeUpEvent = [[AKEvent alloc] initWithBlock:^{
        if (_player.amplitude.value < _player.amplitude.maximum) {
            _fillGrayScaleValue += grayScaleStepSize;
            _player.amplitude.value += volumeStepSize;
            if (_player.amplitude.value > _player.amplitude.maximum)
                _player.amplitude.value = _player.amplitude.maximum;
            [_volumeUpSequence addEvent:_volumeUpEvent afterDuration:0.01];
        }
    }];
    [_volumeUpSequence addEvent:_volumeUpEvent];
    
    _volumeDownSequence = [AKSequence sequence];
    _volumeDownEvent = [[AKEvent alloc] initWithBlock:^{
        if (_player.amplitude.value > _player.amplitude.minimum) {
            _fillGrayScaleValue -= grayScaleStepSize;
            _player.amplitude.value -= volumeStepSize;
            if (_player.amplitude.value < _player.amplitude.minimum)
                _player.amplitude.value = _player.amplitude.minimum;
            [_volumeDownSequence addEvent:_volumeDownEvent afterDuration:0.01];
        }
    }];
    [_volumeDownSequence addEvent:_volumeDownEvent];
}

- (BOOL)getState {
    return _state;
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
    
    self.fillColor = [SKColor colorWithWhite:_fillGrayScaleValue alpha:1.0];
}

@end
