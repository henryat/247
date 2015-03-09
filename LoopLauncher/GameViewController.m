//
//  GameViewController.m
//  LoopLauncher
//
//  Created by Henry Thiemann on 3/1/15.
//  Copyright (c) 2015 Henry Thiemann. All rights reserved.
//

#import "GameViewController.h"
#import "GameScene.h"

@implementation SKScene (Unarchive)

+ (instancetype)unarchiveFromFile:(NSString *)file {
    /* Retrieve scene file path from the application bundle */
    NSString *nodePath = [[NSBundle mainBundle] pathForResource:file ofType:@"sks"];
    /* Unarchive the file to an SKScene object */
    NSData *data = [NSData dataWithContentsOfFile:nodePath
                                          options:NSDataReadingMappedIfSafe
                                            error:nil];
    NSKeyedUnarchiver *arch = [[NSKeyedUnarchiver alloc] initForReadingWithData:data];
    [arch setClass:self forClassName:@"SKScene"];
    SKScene *scene = [arch decodeObjectForKey:NSKeyedArchiveRootObjectKey];
    [arch finishDecoding];
    
    return scene;
}

@end

@implementation GameViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(returnToMenu:) name:@"GoHome" object:nil];

    // Configure the view.
    SKView * skView = (SKView *)self.view;
    skView.showsFPS = NO;
    skView.showsNodeCount = NO;
    /* Sprite Kit applies additional optimizations to improve rendering performance */
    skView.ignoresSiblingOrder = YES;
    skView.backgroundColor = [UIColor colorWithRed:.9 green:.9 blue:.95 alpha:1];
    
    [self fillHomeView];
    _homeView = self.view;
    _blankView = [[UIView alloc] initWithFrame:self.view.frame];
    
    // Create and configure the scene.
//    GameScene *scene = [GameScene unarchiveFromFile:@"GameScene"];
//    scene.scaleMode = SKSceneScaleModeAspectFill;
//    scene.size = [UIScreen mainScreen].bounds.size;
//    
//    // Present the scene.
//    [skView presentScene:scene];
}

- (BOOL)shouldAutorotate
{
    return NO;
}

- (NSUInteger)supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskPortrait;
//    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
//        return UIInterfaceOrientationMaskPortrait;
//    } else {
//        return UIInterfaceOrientationMaskAll;
//    }
}

- (void)fillHomeView
{
    [self addTitleLabel];
    [self addFirstScapeButton];
    [self addSecondScapeButton];
    [self addGoalCounter];
}

- (void)addTitleLabel
{
    CGFloat windowWidth = [UIScreen mainScreen].bounds.size.width;
    CGFloat windowHeight = [UIScreen mainScreen].bounds.size.height;
    UILabel *titleLabel = [[UILabel alloc] init];
    titleLabel.text = @"Audio Auscape";
    titleLabel.textAlignment = NSTextAlignmentCenter;
    titleLabel.font = [UIFont fontWithName:@"Trebuchet MS" size:30];
    titleLabel.textColor = [UIColor darkGrayColor];
    [titleLabel sizeToFit];
    titleLabel.frame = CGRectMake((windowWidth - titleLabel.frame.size.width)/2, windowHeight/5 - titleLabel.frame.size.height, titleLabel.frame.size.width, titleLabel.frame.size.height);
    [self.view addSubview:titleLabel];
}

- (void)addFirstScapeButton
{
    CGFloat windowWidth = [UIScreen mainScreen].bounds.size.width;
    CGFloat windowHeight = [UIScreen mainScreen].bounds.size.height;
    CGFloat buttonWidth = windowWidth * 2 / 3;
    CGFloat buttonHeight = windowHeight / 8;
    UIButton *scapeButton = [[UIButton alloc] initWithFrame:CGRectMake((windowWidth - buttonWidth)/2, windowHeight/2 - buttonHeight - 20, buttonWidth, buttonHeight)];
    [scapeButton addTarget:self action:@selector(fireFirstScape) forControlEvents:UIControlEventTouchUpInside];
    [scapeButton setTitle:@"Ambeach" forState:UIControlStateNormal];
    scapeButton.backgroundColor = [UIColor colorWithRed:.3 green:.2 blue:.2 alpha:1];
    scapeButton.layer.cornerRadius = 10;
    scapeButton.layer.borderWidth = 2;
    scapeButton.layer.borderColor = [UIColor colorWithRed:.4 green:.4 blue:.4 alpha:.5].CGColor;
    [self.view addSubview:scapeButton];
}

- (void)addSecondScapeButton
{
    CGFloat windowWidth = [UIScreen mainScreen].bounds.size.width;
    CGFloat windowHeight = [UIScreen mainScreen].bounds.size.height;
    CGFloat buttonWidth = windowWidth * 2 / 3;
    CGFloat buttonHeight = windowHeight / 8;
    UIButton *scapeButton = [[UIButton alloc] initWithFrame:CGRectMake((windowWidth - buttonWidth)/2, windowHeight/2 + 20, buttonWidth, buttonHeight)];
    [scapeButton setTitle:@"Thing 2" forState:UIControlStateNormal];
    scapeButton.backgroundColor = [UIColor colorWithRed:.2 green:.2 blue:.3 alpha:1];
    scapeButton.layer.cornerRadius = 10;
    scapeButton.layer.borderWidth = 2;
    scapeButton.layer.borderColor = [UIColor colorWithRed:.4 green:.4 blue:.4 alpha:.5].CGColor;
    [self.view addSubview:scapeButton];
}

- (void)addGoalCounter
{
    CGFloat windowWidth = [UIScreen mainScreen].bounds.size.width;
    CGFloat windowHeight = [UIScreen mainScreen].bounds.size.height;
    _goalCounter = [[UIStepper alloc] init];
    _goalCounter.frame = CGRectMake((windowWidth - _goalCounter.frame.size.width)/2, windowHeight - _goalCounter.frame.size.height - 50, _goalCounter.frame.size.width, _goalCounter.frame.size.height);
    [self.view addSubview: _goalCounter];
    
    [_goalCounter addTarget:self action:@selector(changeCounter) forControlEvents:UIControlEventValueChanged];
    
    _goalCounter.minimumValue = 0;
    _goalCounter.maximumValue = 10;
    _goalCounter.stepValue = 1;
    _goalCounter.value = 3;
    
    
    _goalNumberLabel = [[UILabel alloc] init];
    _goalNumberLabel.text = [NSString stringWithFormat:@"Weekly Goal: %d", 10];
    _goalNumberLabel.textAlignment = NSTextAlignmentCenter;
    _goalNumberLabel.font = [UIFont fontWithName:@"Trebuchet MS" size:20];
    _goalNumberLabel.textColor = [UIColor darkGrayColor];
    [_goalNumberLabel sizeToFit];
    _goalNumberLabel.frame = CGRectMake((windowWidth - _goalNumberLabel.frame.size.width)/2, _goalCounter.frame.origin.y - _goalNumberLabel.frame.size.height - 40, _goalNumberLabel.frame.size.width ,_goalNumberLabel.frame.size.height);
    _goalNumberLabel.text = [NSString stringWithFormat:@"Weekly Goal: %d", (int)_goalCounter.value];
    [self.view addSubview:_goalNumberLabel];
    
    UILabel *descriptionLabel = [[UILabel alloc] init];
    descriptionLabel.text = [NSString stringWithFormat:@"determines frequency of push reminders"];
    descriptionLabel.textAlignment = NSTextAlignmentCenter;
    descriptionLabel.font = [UIFont fontWithName:@"TrebuchetMS-Italic" size:10];
    descriptionLabel.textColor = [UIColor darkGrayColor];
    [descriptionLabel sizeToFit];
    descriptionLabel.frame = CGRectMake((windowWidth - descriptionLabel.frame.size.width)/2, _goalCounter.frame.origin.y - descriptionLabel.frame.size.height - 5, descriptionLabel.frame.size.width, descriptionLabel.frame.size.height);
    [self.view addSubview:descriptionLabel];
    
    UILabel *completedLabel = [[UILabel alloc] init];
    completedLabel.text = [NSString stringWithFormat:@"Completed: 1"];
    completedLabel.textAlignment = NSTextAlignmentCenter;
    completedLabel.font = [UIFont fontWithName:@"Trebuchet MS" size:16];
    completedLabel.textColor = [UIColor darkGrayColor];
    [completedLabel sizeToFit];
    completedLabel.frame = CGRectMake((windowWidth - completedLabel.frame.size.width)/2, _goalCounter.frame.origin.y - completedLabel.frame.size.height - 20, completedLabel.frame.size.width, completedLabel.frame.size.height);
    [self.view addSubview:completedLabel];
}

- (void)fireFirstScape
{
//     Create and configure the scene.
    GameScene *scene = [GameScene unarchiveFromFile:@"GameScene"];
    scene.scaleMode = SKSceneScaleModeAspectFill;
    scene.size = [UIScreen mainScreen].bounds.size;
    SKTransition *transition = [SKTransition crossFadeWithDuration:2];
    [UIView animateWithDuration:1 animations:^{
        for(UIView *subView in [self.view subviews]){
            subView.alpha = 0;
        }
    }];
// Present the scene.
    [(SKView *)self.view presentScene:scene transition:transition];
}

- (void)changeCounter
{
    _goalNumberLabel.text = [NSString stringWithFormat:@"Weekly Goal: %d", (int)_goalCounter.value];
}

- (void)returnToMenu:(NSNotification *)notification
{
    [UIView animateWithDuration:1 animations:^{
        for(UIView *subView in [self.view subviews]){
            subView.alpha = 1;
        }
    }];
    SKScene *blankScene = [[SKScene alloc] initWithSize:self.view.frame.size];
    blankScene.backgroundColor = [SKColor whiteColor];
    SKTransition *transition = [SKTransition crossFadeWithDuration:1];
    [(SKView *)self.view presentScene:blankScene transition:transition];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Release any cached data, images, etc that aren't in use.
}

- (BOOL)prefersStatusBarHidden {
    return YES;
}

@end
