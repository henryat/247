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
@property NSMutableArray *soundInteractors;
@property AKEvent *updateAnalysis;
@property AKSequence *analysisSequence;
@property double baseInteractorSize;

@end
