//
//  GameScene.m
//  LoopLauncher
//
//  Created by Henry Thiemann on 3/1/15.
//  Copyright (c) 2015 Henry Thiemann. All rights reserved.
//

#import "GameScene.h"

@implementation GameScene

-(void)didMoveToView:(SKView *)view {
    /* Setup your scene here */
    
    // create all the loopers
    [self addSoundLoopers];
    [AKOrchestra start];
    for (SoundFilePlayer *player in _soundLoopers) {
        [player play];
        [player.audioAnalyzer play];
    }
    
    _analysisSequence = [AKSequence sequence];
    _updateAnalysis = [[AKEvent alloc] initWithBlock:^{
        [self performSelectorOnMainThread:@selector(updateUI) withObject:self waitUntilDone:NO];
        [_analysisSequence addEvent:_updateAnalysis afterDuration:0.01];
    }];
    [_analysisSequence addEvent:_updateAnalysis];
    [_analysisSequence play];
}

// create audio looper and interaction object for each sound file
-(void)addSoundLoopers {
    
    // load file names from plist into array
    NSString *pathToPlist = [[NSBundle mainBundle] pathForResource:@"relaxation" ofType:@"plist"];
    NSMutableArray *soundFiles = [[NSMutableArray alloc] initWithContentsOfFile:pathToPlist];
    
    _soundLoopers = [[NSMutableArray alloc] init];
    _soundInteractors = [[NSMutableArray alloc] init];
    
    // create sound file player for each file
    for (NSArray *soundFile in soundFiles) {
        SoundFilePlayer *player = [[SoundFilePlayer alloc] initWithInfoArray:soundFile];
        [_soundLoopers addObject:player];
        [AKOrchestra addInstrument:player];
        [AKOrchestra addInstrument:player.audioAnalyzer];
    }
    
    CGFloat windowWidth = [UIScreen mainScreen].bounds.size.width;
    CGFloat windowHeight = [UIScreen mainScreen].bounds.size.height;
    
    CGFloat rectSize = (windowWidth * 0.75) / 4.0;
    CGFloat rectBufferSize = (windowWidth * 0.25) / 5.0;
    
    _baseInteractorSize = rectSize * .7;
    
    int arrayIndex = 0;
    for (int i = 0; i < 4; i++) {
        if (arrayIndex >= [_soundLoopers count]) { break; }
        for (int j = 0; j < 4; j++) {
            if (arrayIndex >= [_soundLoopers count]) { break; }
            
            CGFloat x = j * rectSize + (j + 1) * rectBufferSize;
            CGFloat y = windowHeight - (i + 1) * rectSize - (i + 1) * rectBufferSize - 100;
            
            SoundInteractor *interactor = [SoundInteractor shapeNodeWithCircleOfRadius:_baseInteractorSize/2];
            interactor.position = CGPointMake(x + rectSize/2, y);
            interactor.strokeColor = [SKColor grayColor];
            interactor.fillColor = [SKColor darkGrayColor];
            interactor.alpha = .4;
            interactor.lineWidth = 3;
            
            [self addChild:interactor];
            
            SoundFilePlayer *player = [_soundLoopers objectAtIndex:arrayIndex];
            interactor.player = player;
            interactor.state = NO;
            arrayIndex++;
            [_soundInteractors addObject:interactor];
        }
    }
}

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    /* Called when a touch begins */
    
    for (UITouch *touch in touches) {
        CGPoint location = [touch locationInNode:self];
        SKNode *touchedNode = [self nodeAtPoint:location];
        
        if (touchedNode != self) {
            SoundInteractor *interactor = (SoundInteractor *)touchedNode;
            if (interactor.state == NO) {
                SoundFilePlayer *player = interactor.player;
                [player.amplitude setValue:player.playbackLevel];
                interactor.fillColor = [SKColor greenColor];
                interactor.state = YES;
                NSLog(@"analyzer audio level = %f", player.audioAnalyzer.trackedAmplitude.value);
            } else {
                SoundFilePlayer *player = interactor.player;
                NSLog(@"analyzer audio level = %f", player.audioAnalyzer.trackedAmplitude.value);
                [player.amplitude setValue:0.0];
                interactor.fillColor = [SKColor darkGrayColor];
                interactor.state = NO;
            }
        }
    }
}

- (void)updateUI {
    
    for (SoundInteractor *interactor in _soundInteractors) {
        double soundAmplitude = interactor.player.audioAnalyzer.trackedAmplitude.value;
        if(soundAmplitude >= .01){
            double scaleFactor = 1 + (soundAmplitude * 5);
            interactor.xScale = scaleFactor;
            interactor.yScale = scaleFactor;
        } else {
            interactor.xScale = 1;
            interactor.yScale = 1;
        }
    }
    
}

-(void)update:(CFTimeInterval)currentTime {
    /* Called before each frame is rendered */
}

@end
