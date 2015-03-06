//
//  GameScene.h
//  LoopLauncher
//

//  Copyright (c) 2015 Henry Thiemann. All rights reserved.
//

#import <SpriteKit/SpriteKit.h>
#import "AKFoundation.h"
#import "SoundFilePlayer.h"
#import "SoundInteractor.h"

@interface GameScene : SKScene

@property NSMutableArray *soundLoopers;
@property AKAudioAnalyzer *analyzer;
@property AKEvent *updateAnalysis;
@property AKSequence *analysisSequence;

@end
