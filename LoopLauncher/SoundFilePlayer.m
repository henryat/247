//
//  SoundFilePlayer.m
//  Prototype
//
//  Created by Henry Thiemann on 2/28/15.
//  Copyright (c) 2015 Henry Thiemann. All rights reserved.
//

#import "SoundFilePlayer.h"

@implementation SoundFilePlayer

- (instancetype)initWithInfoArray:(NSArray *)info
{
    self = [super init];
    if (self) {
        SoundFilePlayerNote *note = [[SoundFilePlayerNote alloc] init];
        [self addNoteProperty:note.speed];
        [self addNoteProperty:note.pan];
        NSString *fileName = info[0];
                
        NSString *pathToSoundFile;
        pathToSoundFile = [[NSBundle mainBundle] pathForResource:fileName ofType:@"aiff"];
        
        AKSoundFile *soundFile;
        soundFile = [[AKSoundFile alloc] initWithFilename: pathToSoundFile];
        [self addFunctionTable:soundFile];
        
        AKStereoSoundFileLooper *looper = [[AKStereoSoundFileLooper alloc] initWithSoundFile:soundFile];
        _amplitude = [[AKInstrumentProperty alloc] initWithValue:0.0 minimum:0.0 maximum:0.2];
        [self addProperty:_amplitude];
        looper.amplitude = _amplitude;
        [self connect:looper];
        self.playbackLevel = ((NSNumber *) info[1]).doubleValue;
        
        AKAudioOutput *audioOutput = [[AKAudioOutput alloc] initWithAudioSource:looper];
        [self connect:audioOutput];
        self.outputStream = audioOutput;
        
        // THIS IS WHERE WE WOULD HOOK UP AUDIOANALYZER TO SOURCE
        AKAudioAnalyzer *audioAnalyzer = [[AKAudioAnalyzer alloc] initWithAudioSource:audioOutput];
        self.audioAnalyzer = audioAnalyzer;
    }
    
    return self;
}

@end


// -----------------------------------------------------------------------------
#  pragma mark - Instrument Note
// -----------------------------------------------------------------------------

@implementation SoundFilePlayerNote

- (instancetype)init;
{
    self = [super init];
    if(self) {
        _speed = [[AKNoteProperty alloc] initWithValue:1.0
                                               minimum:1.0
                                               maximum:6.0];
        [self addProperty:_speed];
        
        _pan = [[AKNoteProperty alloc] initWithValue:0.0
                                             minimum:-1.0
                                             maximum:1.0];
        [self addProperty:_pan];
        
        
        self.duration.value = 4.0;
    }
    return self;
}


@end
