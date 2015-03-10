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
@property BOOL ready;
@property double averagedAmplitude;
@property float fillGrayScaleValue;

@property(nonatomic) AKSequence *volumeUpSequence;
@property(nonatomic) AKSequence *volumeDownSequence;
@property(nonatomic) AKEvent *volumeDownEvent;
@property(nonatomic) AKEvent *volumeUpEvent;

@property(nonatomic) NSTimer *increaseSizeTimer;

@end


@implementation SoundInteractor

double grayScaleValueOff = 0.2;
double grayScaleValueOn = 1.0;
double volumeFadeTimeInSeconds = 1.0;
double appearAnimationTimeInSeconds = 4.0;

- (instancetype)init {
    self = [super init];
    
    if (self) {
        self.fillGrayScaleValue = grayScaleValueOff;
        self.fillColor = [SKColor colorWithWhite:_fillGrayScaleValue alpha:1.0];
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
    self.name = _player.fileName;
    _state = NO;
    _ready = NO;
    _averagedAmplitude = 0.0;
    
    double volumeStepSize = _player.amplitude.maximum / (volumeFadeTimeInSeconds / 0.01);
    double grayScaleStepSize = (grayScaleValueOn - grayScaleValueOff) / (volumeFadeTimeInSeconds / 0.01);
        
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

- (void)increaseSize {
    double scaleStepSize = 1 / (appearAnimationTimeInSeconds / 0.01);
    self.fillGrayScaleValue = grayScaleValueOff;
    self.xScale += scaleStepSize;
    self.yScale += scaleStepSize;
    if (self.xScale >= 1) {
        _ready = YES;
        [_increaseSizeTimer invalidate];
    }
}

- (void)appearWithGrowAnimation {
    _increaseSizeTimer = [NSTimer scheduledTimerWithTimeInterval:0.01 target:self selector:@selector(increaseSize) userInfo:nil repeats:YES];
    [_increaseSizeTimer fire];
}

- (BOOL)isReady {
    return _ready;
}

- (BOOL)getState {
    return _state;
}

- (void)turnOn {
    if (_ready) {
        [_volumeDownSequence stop];
        [_volumeUpSequence play];
        _state = YES;
    }
}

- (void)turnOff {
    [_volumeUpSequence stop];
    [_volumeDownSequence play];
    _state = NO;
}

- (void)updateAppearance {
    double bias = 0.84;
    double soundAmplitude = _player.audioAnalyzer.trackedAmplitude.value;
    _averagedAmplitude = bias * _averagedAmplitude + (1 - bias) * soundAmplitude;
    double scaleFactor = 1 + (_averagedAmplitude * _player.scaleValue);
    self.xScale = scaleFactor;
    self.yScale = scaleFactor;
    
    self.fillColor = [SKColor colorWithWhite:_fillGrayScaleValue alpha:1.0];
}

@end
