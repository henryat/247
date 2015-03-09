//
//  SoundInteractor.h
//  LoopLauncher
//
//  Created by Henry Thiemann on 3/2/15.
//  Copyright (c) 2015 Henry Thiemann. All rights reserved.
//

#import <SpriteKit/SpriteKit.h>
#import "SoundFilePlayer.h"

@interface SoundInteractor : SKShapeNode

- (void)turnOn;
- (void)turnOff;
- (void)updateAppearance;

@property BOOL state;
@property SoundFilePlayer *player;
@property double averagedAmplitude;

@property AKSequence *volumeUpSequence;
@property AKSequence *volumeDownSequence;
@property AKEvent *volumeDownEvent;
@property AKEvent *volumeUpEvent;

@end
