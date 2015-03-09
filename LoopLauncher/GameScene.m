//
//  GameScene.m
//  LoopLauncher
//
//  Created by Henry Thiemann on 3/1/15.
//  Copyright (c) 2015 Henry Thiemann. All rights reserved.
//

#import "GameScene.h"

@implementation GameScene

-(void)introduceLoops{
    //SoundInteractor *interactor = [SoundInteractor shapeNodeWithCircleOfRadius:_baseInteractorSize/2];
    if (_loopCounter > _soundInteractors.count - 1) {
        [_timer invalidate];
        return;
    }
    [self addChild:_soundInteractors[_loopCounter]];
 
    
    _loopCounter ++;
}

-(void)didMoveToView:(SKView *)view {
    
    /* Setup your scene here */
    self.backgroundColor = [SKColor orangeColor];
    self.scaleMode = SKSceneScaleModeAspectFit;
    self.physicsBody = [SKPhysicsBody bodyWithEdgeLoopFromRect:self.frame];
    self.physicsBody.categoryBitMask = edgeCategory;
    self.physicsWorld.contactDelegate = self;
    
    
//    // create all the loopers
    
    
    
    [self addSoundLoopers];
    _timer = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(introduceLoops) userInfo:nil repeats:YES];
    [_timer fire];
    [AKOrchestra start];
    for (SoundFilePlayer *player in _soundLoopers) {
        [player play];
        [player.audioAnalyzer play];
    }
    
//    [self startAnalysisSequence];
    
//    _pinchGestureRecognizer = [[UIPinchGestureRecognizer alloc] initWithTarget:self action:@selector(pinchInteractor:)];
//    _pinchGestureRecognizer.delegate = self;
//    [view addGestureRecognizer:_pinchGestureRecognizer];
}

-(void)willMoveFromView:(SKView *)view{
//    [view removeGestureRecognizer:_pinchGestureRecognizer];
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
            
          /*  if (_loopCounter < 1) {
            [self addChild:interactor];
            }*/
            
            [interactor setPhysicsBody:[SKPhysicsBody bodyWithCircleOfRadius:interactor.frame.size.width/2]];
            interactor.physicsBody.affectedByGravity = NO;
            interactor.physicsBody.dynamic = YES;
            interactor.physicsBody.restitution = 1.0;
            interactor.physicsBody.friction = 0.0f;
            interactor.physicsBody.linearDamping = 0.0f;
            interactor.physicsBody.angularDamping = 0.0f;
            interactor.physicsBody.allowsRotation = NO;
            
            interactor.physicsBody.categoryBitMask = ballCategory;
            interactor.physicsBody.collisionBitMask = ballCategory | edgeCategory;
            interactor.physicsBody.contactTestBitMask = edgeCategory | ballCategory;
            CGVector impulseVec = CGVectorMake((CGFloat) random()/(CGFloat) RAND_MAX * 5, (CGFloat) random()/(CGFloat) RAND_MAX * 5);
            if(rand() > RAND_MAX/2) impulseVec.dx = -impulseVec.dx;
            if(rand() > RAND_MAX/2) impulseVec.dy = -impulseVec.dy;
            [interactor.physicsBody applyImpulse:impulseVec];
            SoundFilePlayer *player = [_soundLoopers objectAtIndex:arrayIndex];
            interactor.player = player;
            arrayIndex++;
            [_soundInteractors addObject:interactor];
        }
    }
}




- (void)didBeginContact:(SKPhysicsContact *)contact
{
    // THIS IS NECESSARY TO DEAL WITH LAME BUG IN APPLE CODE THAT IGNORES IMPULSES LESS THAN 20 OR SOME BS LIKE THAT
    SKPhysicsBody *bodyA = contact.bodyA;
    SKPhysicsBody *bodyB = contact.bodyB;
    CGVector contactNormal = contact.contactNormal;
    CGFloat contactImpulse = contact.collisionImpulse;
    
    if((bodyA.categoryBitMask == edgeCategory && bodyB.categoryBitMask == ballCategory)){
        if(contactImpulse < 15 && contactImpulse > 0){
            if(contactNormal.dx == -1 && contactNormal.dy == 0){ // right wall
//                NSLog(@"rightWall");

                [bodyB applyImpulse:CGVectorMake(-contactImpulse, 0)];
                if(abs(bodyB.velocity.dx) + abs(bodyB.velocity.dy) < 25){
                    bodyB.velocity = CGVectorMake(bodyB.velocity.dx * 1.5, bodyB.velocity.dy * 1.5);
                }
                if(abs(bodyB.velocity.dx) + abs(bodyB.velocity.dy) < 15){
                    bodyB.velocity = CGVectorMake(bodyB.velocity.dx * 3, bodyB.velocity.dy * 3);
                }
            } else if(contactNormal.dx == 1 && contactNormal.dy == 0){ // left wall
//                NSLog(@"leftWall");
                [bodyB applyImpulse:CGVectorMake(contactImpulse, 0)];
            } else if(contactNormal.dx == 0 && contactNormal.dy == -1){ // top wall
                [bodyB applyImpulse:CGVectorMake(0, -contactImpulse)];
//                NSLog(@"topWall");
            } else if(contactNormal.dx == 0 && contactNormal.dy == 1){ // bottom wall
//                NSLog(@"bottomWall");
                [bodyB applyImpulse:CGVectorMake(0, contactImpulse)];
            }
        }
    } else if((bodyA.categoryBitMask == ballCategory && bodyB.categoryBitMask == ballCategory)){
        if(contactImpulse < 15){
            bodyB.velocity = CGVectorMake(bodyB.velocity.dx * 1.05, bodyB.velocity.dy * 1.05);
            bodyA.velocity = CGVectorMake(bodyA.velocity.dx * 1.05, bodyA.velocity.dy * 1.05);
        }
    }
}

//-(void)startAnalysisSequence
//{
//    _analysisSequence = [AKSequence sequence];
//    _updateAnalysis = [[AKEvent alloc] initWithBlock:^{
//        [self performSelectorOnMainThread:@selector(updateUI) withObject:self waitUntilDone:NO];
//        [_analysisSequence addEvent:_updateAnalysis afterDuration:0.05];
//    }];
//    [_analysisSequence addEvent:_updateAnalysis];
//    
//    _averagedAmplitudes = [[NSMutableArray alloc] init];
//    _smoothedAmplitudes = [[NSMutableArray alloc] init];
//    for (int i = 0; i < _soundLoopers.count; i++) {
//        [_averagedAmplitudes addObject:[NSNumber numberWithDouble:0.0]];
//        [_averagedAmplitudes addObject:[NSNumber numberWithDouble:0.0]];
//    }
//    
//    [_analysisSequence play];
//}

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    /* Called when a touch begins */
    
    for (UITouch *touch in touches) {
        CGPoint location = [touch locationInNode:self];
        SKNode *touchedNode = [self nodeAtPoint:location];
        
        if ([touchedNode isKindOfClass:[SoundInteractor class]]) {
            SoundInteractor *interactor = (SoundInteractor *)touchedNode;
            if (interactor.state == NO) {
                [interactor turnOn];
            } else {
                [interactor turnOff];
            }
        } else if([touchedNode.name isEqualToString:@"impulseButton"]) {
            [self applyImpulses];
        } else if([touchedNode.name isEqualToString:@"homeButton"]) {
            [self goHome];
        } else if([touchedNode.name isEqualToString:@"resetButton"]) {
            [self resetNodes];
        }
    }
}

- (void)applyImpulses {
    for(SoundInteractor *interactor in _soundInteractors){
        CGVector impulseVec = CGVectorMake((CGFloat) random()/(CGFloat) RAND_MAX * 5, (CGFloat) random()/(CGFloat) RAND_MAX * 5);
        if(rand() > RAND_MAX/2) impulseVec.dx = -impulseVec.dx;
        if(rand() > RAND_MAX/2) impulseVec.dy = -impulseVec.dy;
        [interactor.physicsBody applyImpulse:impulseVec];
    }
}

- (void)resetNodes
{
    CGFloat windowWidth = [UIScreen mainScreen].bounds.size.width;
    CGFloat windowHeight = [UIScreen mainScreen].bounds.size.height;
    
    CGFloat rectSize = (windowWidth * 0.75) / 4.0;
    CGFloat rectBufferSize = (windowWidth * 0.25) / 5.0;
    
    int arrayIndex = 0;
    for (int i = 0; i < 4; i++) {
        if (arrayIndex >= [_soundInteractors count]) { break; }
        for (int j = 0; j < 4; j++) {
            if (arrayIndex >= [_soundInteractors count]) { break; }
            
            SoundInteractor *interactor = _soundInteractors[arrayIndex];
            
            CGFloat x = j * rectSize + (j + 1) * rectBufferSize;
            CGFloat y = windowHeight - (i + 1) * rectSize - (i + 1) * rectBufferSize - 100;
            
            interactor.position = CGPointMake(x + rectSize/2, y);
            
            CGVector impulseVec = CGVectorMake((CGFloat) random()/(CGFloat) RAND_MAX * 5, (CGFloat) random()/(CGFloat) RAND_MAX * 5);
            if(rand() > RAND_MAX/2) impulseVec.dx = -impulseVec.dx;
            if(rand() > RAND_MAX/2) impulseVec.dy = -impulseVec.dy;
            [interactor.physicsBody applyImpulse:impulseVec];
            arrayIndex++;
        }
    }
}

- (void)goHome
{
    [[NSNotificationCenter defaultCenter] postNotificationName:@"GoHome" object:nil];
//    [(SKView *)self.view presentScene:nil];
}

//- (void) pinchInteractor:(UIPinchGestureRecognizer *)recognizer {
//    self.pinchActive = YES;
//    
//    CGPoint pinchCenter = [recognizer locationInView:self.view];
//    
//    if(recognizer.state == UIGestureRecognizerStateBegan){
////        UIView *marker = [[UIView alloc] initWithFrame:CGRectMake(pinchCenter.x, pinchCenter.y, 5, 5)];
////        [marker setBackgroundColor:[UIColor redColor]];
////        [self.view addSubview:marker];
//        CGPoint convertedPoint = [self.view convertPoint:pinchCenter toScene:self.scene];
//        [self setPinchedInteractor:convertedPoint];
//        if (_pinchingInteractor) {
//            _pinchingInteractor.fillColor = [SKColor blueColor];
//        }
//    } else if(recognizer.state == UIGestureRecognizerStateEnded || recognizer.state == UIGestureRecognizerStateCancelled) {
//        if(!_pinchingInteractor) return;
//        if(_pinchingInteractor.state == YES)
//            _pinchingInteractor.fillColor = [SKColor greenColor];
//        else
//            _pinchingInteractor.fillColor = [SKColor darkGrayColor];
//        _pinchingInteractor = nil;
//    }
//}
//
//- (void)setPinchedInteractor:(CGPoint)pinchPoint
//{
//    for(SoundInteractor *interactor in _soundInteractors){
//        if(pinchPoint.x > interactor.position.x - interactor.frame.size.width/2 && pinchPoint.x < interactor.position.x + interactor.frame.size.width/2 && pinchPoint.y > interactor.position.y - interactor.frame.size.height/2 && pinchPoint.y < interactor.position.y + interactor.frame.size.height/2){
//            NSLog(@"Pinch point(%f,%f)   interactorFrame:(%f,%f)(%f,%f)", pinchPoint.x, pinchPoint.y, interactor.position.x - interactor.frame.size.width/2, interactor.position.y - interactor.frame.size.height/2, interactor.position.x + interactor.frame.size.width/2, interactor.position.y + interactor.frame.size.height/2);
//            _pinchingInteractor = interactor;
//            break;
//        }
//    }
//}

//- (void)updateUI {
//    for (SoundInteractor *interactor in _soundInteractors) {
//        double val = 0.87;
//        double soundAmplitude = interactor.player.audioAnalyzer.trackedAmplitude.value;
//        interactor.averagedAmplitude = val * interactor.averagedAmplitude + (1 - val) * soundAmplitude;
//        double scaleFactor = 1 + (interactor.averagedAmplitude * 5);
//        interactor.xScale = scaleFactor;
//        interactor.yScale = scaleFactor;
//    }
//}

-(void)update:(CFTimeInterval)currentTime {
    /* Called before each frame is rendered */
    
    for (SoundInteractor *interactor in _soundInteractors) {
        [interactor updateAppearance];
    }
}

@end
