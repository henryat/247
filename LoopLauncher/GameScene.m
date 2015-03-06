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
    self.analyzer = ((SoundFilePlayer *)_soundLoopers[0]).audioAnalyzer;
    
    _analysisSequence = [AKSequence sequence];
    _updateAnalysis = [[AKEvent alloc] initWithBlock:^{
        [self performSelectorOnMainThread:@selector(updateUI) withObject:self waitUntilDone:NO];
        [_analysisSequence addEvent:_updateAnalysis afterDuration:0.1];
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
    
    // create sound file player for each file
    for (NSArray *soundFile in soundFiles) {
        SoundFilePlayer *player = [[SoundFilePlayer alloc] initWithInfoArray:soundFile];
        [_soundLoopers addObject:player];
        [AKOrchestra addInstrument:player];
    }
    
    CGFloat windowWidth = [UIScreen mainScreen].bounds.size.width;
    CGFloat windowHeight = [UIScreen mainScreen].bounds.size.height;
    
    CGFloat rectSize = (windowWidth * 0.75) / 4.0;
    CGFloat rectBufferSize = (windowWidth * 0.25) / 5.0;
    
    int arrayIndex = 0;
    for (int i = 0; i < 4; i++) {
        if (arrayIndex >= [_soundLoopers count]) { break; }
        for (int j = 0; j < 4; j++) {
            if (arrayIndex >= [_soundLoopers count]) { break; }
            
            CGFloat x = j * rectSize + (j + 1) * rectBufferSize;
            CGFloat y = windowHeight - (i + 1) * rectSize - (i + 1) * rectBufferSize - 100;
//            CGRect rect = CGRectMake(x, y, rectSize, rectSize);
            
            SoundInteractor *interactor = [SoundInteractor shapeNodeWithCircleOfRadius:rectSize/2];
            interactor.position = CGPointMake(x + rectSize/2, y);
            interactor.strokeColor = [SKColor grayColor];
            interactor.fillColor = [SKColor darkGrayColor];
            interactor.alpha = .4;
            interactor.lineWidth = 3;
            interactor.xScale = .6;
            interactor.yScale = .6;
            
            [self addChild:interactor];
            
            SoundFilePlayer *player = [_soundLoopers objectAtIndex:arrayIndex];
            interactor.player = player;
            interactor.state = NO;
            arrayIndex++;
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
    
// THIS IS WHERE WE WOULD WANT TRACKED AMPLITUDE TO FIRE
    if (self.analyzer.trackedAmplitude.value > 0.01) {
        NSLog(@"Hooray");
//        frequencyLabel.text = [NSString stringWithFormat:@"%0.1f", analyzer.trackedFrequency.value];
//        
//        float frequency = analyzer.trackedFrequency.value;
//        while (frequency > [noteFrequencies.lastObject floatValue]) {
//            frequency = frequency / 2.0;
//        }
//        while (frequency < [noteFrequencies.firstObject floatValue]) {
//            frequency = frequency * 2.0;
//        }
//        
//        float minDistance = 10000;
//        int index =  0;
//        for (int i = 0; i < noteFrequencies.count; i++) {
//            float distance = fabs([noteFrequencies[i] floatValue] - frequency);
//            if (distance < minDistance) {
//                index = i;
//                minDistance = distance;
//            }
//        }
//        int octave = (int)log2f(analyzer.trackedFrequency.value / frequency);
//        NSString *noteName = [NSString stringWithFormat:@"%@%d", noteNamesWithSharps[index], octave];
//        noteNameWithSharpsLabel.text = noteName;
//        noteName = [NSString stringWithFormat:@"%@%d", noteNamesWithFlats[index], octave];
//        noteNameWithFlatsLabel.text = noteName;
//        
//        [frequencyLabel setNeedsDisplay];
//        [amplitudeLabel setNeedsDisplay];
//        [noteNameWithSharpsLabel setNeedsDisplay];
//        [noteNameWithFlatsLabel setNeedsDisplay];
    }
//    amplitudeLabel.text = [NSString stringWithFormat:@"%0.2f", analyzer.trackedAmplitude.value];
    
}

-(void)update:(CFTimeInterval)currentTime {
    /* Called before each frame is rendered */
}

@end
