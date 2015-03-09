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
    [_player.amplitude setValue:_player.amplitude.maximum];
    self.fillColor = [SKColor greenColor];
    _state = YES;
}

- (void)turnOff {
    [_player.amplitude setValue:_player.amplitude.minimum];
    self.fillColor = [SKColor darkGrayColor];
    _state = NO;
}

- (void)updateAppearance {
    double val = 0.84;
    double soundAmplitude = _player.audioAnalyzer.trackedAmplitude.value;
    _averagedAmplitude = val * _averagedAmplitude + (1 - val) * soundAmplitude;
    double scaleFactor = 1 + (_averagedAmplitude * 5);
    self.xScale = scaleFactor;
    self.yScale = scaleFactor;
}

@end
