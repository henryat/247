//
//  SoundFilePlayer.h
//  Prototype
//
//  Created by Henry Thiemann on 2/28/15.
//  Copyright (c) 2015 Henry Thiemann. All rights reserved.
//

#import "AKFoundation.h"

@interface SoundFilePlayer : AKInstrument

- (instancetype)initWithFilename:(NSString *)filename;

@property AKInstrumentProperty *amplitude;

@end

@interface SoundFilePlayerNote : AKNote

@property AKNoteProperty *speed;
@property AKNoteProperty *pan;

@end