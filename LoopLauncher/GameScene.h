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

static const uint32_t edgeCategory = 0x1 << 0;
static const uint32_t ballCategory = 0x1 << 1;
static const uint32_t borderCategory = 0x1 << 4; // 00000000000000000000000000010000

@interface GameScene : SKScene <UIGestureRecognizerDelegate, SKPhysicsContactDelegate>


@property NSMutableArray *soundLoopers;
@property NSMutableArray *soundInteractors;
@property AKEvent *updateAnalysis;
@property AKSequence *analysisSequence;
@property double baseInteractorSize;
@property BOOL pinchActive;
@property UIPinchGestureRecognizer *pinchGestureRecognizer;
@property SoundInteractor *pinchingInteractor;
@property int loopCounter;
@property NSTimer *timer;

@end
