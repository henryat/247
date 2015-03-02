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

@property BOOL state;
@property SoundFilePlayer *player;

@end
