//
//  NyanMyScene.m
//  NyanDestroyer
//
//  Created by Charles Humphreys on 8/18/14.
//  Copyright (c) 2014 jeddai. All rights reserved.
//

#import "NyanMyScene.h"
#import <AudioToolbox/AudioToolbox.h>
#import <AVFoundation/AVFoundation.h>

static const uint32_t projectileCategory     =  0x1 << 0;
static const uint32_t monsterCategory        =  0x1 << 1;
static const uint32_t playerCategory         =  0x1 << 2;
static const uint32_t claytonCategory        =  0x1 << 3;

@implementation NyanMyScene
@synthesize cat, title, startLabel, pauseLabel, pause, quit, laser, score, points, song, pew, boom, narwhal, deathNarwhal, highScorePts, cantina, claytonTheDestroyer, claytonHP, claytonNarwhal;

-(id)initWithSize:(CGSize)size {    
    if (self = [super initWithSize:size]) {
        
        self.backgroundColor = [SKColor colorWithRed:27/255.0 green:78/255.0 blue:130/255.0 alpha:1.0];
        
        [self initialSetup];
        [self initStars];
        self.physicsWorld.gravity = CGVectorMake(0,0);
        self.physicsWorld.contactDelegate = self;
    }
    return self;
}

-(void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
    for (UITouch *touch in touches)
    {
        CGPoint location = [touch locationInNode:self];
        if (started == (Boolean *) true && gamePaused == (Boolean *)false)
        {
            if (location.x > CGRectGetMidX(self.frame))
            {
                
            }
            else
            {
                if(cat.position.x == 35)
                {
                    SKAction *move = [SKAction moveToY:location.y duration:.075];
                    [cat runAction:move];
                }
            }
        }
    }
}

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    for (UITouch *touch in touches)
    {
        CGPoint location = [touch locationInNode:self];
        //finds out if the touch location has a node behind it
        SKNode *node = [self nodeAtPoint:location];
        //if started and not paused
        if (started == (Boolean *) true && gamePaused == (Boolean *)false)
        {
            //if touch location is halfway across screen in x
            if (location.x > CGRectGetMidX(self.frame))
            {
                if(![node.name isEqualToString:@"paused"] && started)
                    [self fireLaser];
            }
            else
            {
                //if cat has finished move animation
                if(cat.position.x == 35)
                {
                    SKAction *move = [SKAction moveToY:location.y duration:.075];
                
                    [cat runAction:move];
                }
            }
        }
        //if by node name to run functions
        if ([node.name isEqualToString:@"start"])
            [self startGame];
        else if ([node.name isEqualToString:@"paused"])
            [self pauseGame];
        else if ([node.name isEqualToString:@"quit"])
            [self endGame:@"quit"];
    }
}

-(void)update:(CFTimeInterval)currentTime
{
    frame += 1;
    NSArray *nodes = self.scene.children;
    for (SKNode *selectedNode in nodes)
    {
        if (([selectedNode.name isEqualToString: @"narwhal"] || [selectedNode.name isEqualToString: @"deathNarwhal"]) && selectedNode.position.x < -19)
        {
            [selectedNode removeFromParent];
        }
    }
    if((int)frame % 80 == 0)
        [self spawnNarwhals];
    [self updateScore];
    if(song.currentTime >= 30 && started && !HCM && !claytonMode)
    {
        [song stop];
        [self playSound:(int*)2];
        HCM = (Boolean *)true;
        self.backgroundColor = [SKColor colorWithRed:170/255.0 green:50/255.0 blue:50/255.0 alpha:1.0];
        [self FLAMES];
    }
    if(song.currentTime >= 45 && started && HCM && !claytonMode)
    {
        [song stop];
        HCM = (Boolean *)false;
        claytonMode = (Boolean*)true;
        self.backgroundColor = [SKColor colorWithRed:27/255.0 green:78/255.0 blue:130/255.0 alpha:1.0];
        for (SKNode *selectedNode in nodes)
        {
            if ([selectedNode.name isEqualToString: @"flame"])
            {
                [selectedNode removeFromParent];
            }
        }
        [self playSound:(int*)3];
        [self spawnClaytonTheDestroyer];
    }
}

-(void)initialSetup
{
    [cantina stop];
    NSArray *nodes = self.scene.children;
    for (SKNode *selectedNode in nodes)
    {
        if (![selectedNode.name isEqualToString:@"star"])
            [selectedNode removeFromParent];
        selectedNode.paused = false;
    }
    points = 0;
    HCM = false;
    claytonMode = false;
    //title init
    title = [SKLabelNode labelNodeWithFontNamed:@"Minecraftia"];
    title.text = @"Nyan The Destroyer";
    title.fontSize = 15;
    title.position = CGPointMake(CGRectGetMidX(self.frame),CGRectGetMaxY(self.frame)-40);
    [self addChild:title];
    
    [self initCat];
    
    //start label init
    startLabel = [SKLabelNode labelNodeWithFontNamed:@"Minecraftia"];
    startLabel.zPosition = 10;
    startLabel.name = @"start";
    startLabel.text = @"Start Game";
    startLabel.fontSize = 30;
    startLabel.position = CGPointMake(CGRectGetMidX(self.frame),CGRectGetMidY(self.frame));
    [self addChild:startLabel];
    
    //pause button init
    pause = [SKLabelNode labelNodeWithFontNamed:@"Minecraftia"];
    pause.name = @"paused";
    pause.text = @"Pause";
    pause.zPosition = 9;
    pause.fontSize = 10;
    pause.position = CGPointMake(CGRectGetMaxX(self.frame)-22,CGRectGetMaxY(self.frame)-30);
    pause.hidden = true;
    [self addChild:pause];
    
    [self initScore];
    
    //saying the game hasn't started
    started = false;
}

-(void)playSound:(int*)number
{
    if(number == 0)
    {
        NSURL *url = [NSURL fileURLWithPath:[[NSBundle mainBundle]
                                             pathForResource:@"pew"
                                             ofType:@"mp3"]];
        NSError *error;
        pew = [[AVAudioPlayer alloc] initWithContentsOfURL:url error:&error];
        [pew play];
    }
    else if(number == (int *) 1)
    {
        NSURL *url = [NSURL fileURLWithPath:[[NSBundle mainBundle]
                                             pathForResource:@"Song"
                                             ofType:@"mp3"]];
        NSError *error;
        song = [[AVAudioPlayer alloc] initWithContentsOfURL:url error:&error];
        song.currentTime = 0;
        [song play];
    }
    else if(number == (int*) 2)
    {
        NSURL *url = [NSURL fileURLWithPath:[[NSBundle mainBundle]
                                             pathForResource:@"Devastator"
                                             ofType:@"mp3"]];
        NSError *error;
        song = [[AVAudioPlayer alloc] initWithContentsOfURL:url error:&error];
        song.currentTime = 30;
        [song play];
    }
    else if(number == (int*) 3)
    {
        NSURL *url = [NSURL fileURLWithPath:[[NSBundle mainBundle]
                                             pathForResource:@"cantinaBand"
                                             ofType:@"mp3"]];
        NSError *error;
        cantina = [[AVAudioPlayer alloc] initWithContentsOfURL:url error:&error];
        cantina.currentTime = 0;
        [cantina play];
    }
}

-(void)startGame
{
    if (started == false)
    {
        started = (Boolean *) true;
        stars = (Boolean *)true;
        [self spawnNarwhals];
        SKAction *startMoveX = [SKAction moveToX:35 duration:2];
        SKAction *startMoveY = [SKAction moveToY:CGRectGetMidY(self.frame) duration:2];
        SKAction *startSize = [SKAction scaleBy:.25 duration:2];
        SKAction *group = [SKAction group:@[startMoveX,startMoveY,startSize]];
        [cat runAction:group];
        [startLabel removeFromParent];
        [self playSound:(int *) 1];
        pause.hidden = false;
        score.hidden = false;
        title.hidden = true;
        [self initNarwhals];
        points = 0;
    }
}

-(void)pauseGame
{
    NSArray *nodes = self.scene.children;
    if (gamePaused == (Boolean *) false && started == (Boolean *) true)
    {
        gamePaused = (Boolean *) true;
        pauseLabel = [SKLabelNode labelNodeWithFontNamed:@"Minecraftia"];
        pauseLabel.name = @"paused";
        pauseLabel.text = @"Paused...";
        pauseLabel.fontSize = 15;
        pauseLabel.position = CGPointMake(CGRectGetMidX(self.frame),CGRectGetMidY(self.frame));
        pauseLabel.zPosition = 7;
        [self addChild:pauseLabel];
        
        quit = [SKLabelNode labelNodeWithFontNamed:@"Minecraftia"];
        quit.name = @"quit";
        quit.text = @"Quit";
        quit.fontSize = 15;
        quit.position = CGPointMake(CGRectGetMidX(self.frame),CGRectGetMidY(self.frame)-30);
        quit.zPosition = 7;
        [self addChild:quit];
        
        [song pause];
        
        for (SKNode *selectedNode in nodes)
        {
            if ([selectedNode.name isEqualToString: @"paused"])
            {
                
            }
            else if ([selectedNode.name isEqualToString:@"quit"])
            {
                started = (Boolean *) false;
                pause = false;
                for (SKNode *selectedNode in nodes)
                {
                    [selectedNode removeFromParent];
                }
            }
            else
            {
                selectedNode.paused = true;
            }
        }
    }
    else if (gamePaused == (Boolean *) true && started == (Boolean *) true)
    {
        gamePaused = (Boolean *) false;
        
        [pauseLabel removeFromParent];
        [quit removeFromParent];
        
        [song play];
        
        for (SKNode *selectedNode in nodes)
        {
            if ([selectedNode.name isEqualToString: @"paused"])
            {
                
            }
            else
            {
                selectedNode.paused = false;
            }
        }
        [self initStars];
    }
}

-(void)endGame:(NSString *)reason
{
    HCM = false;
    started = false;
    NSArray *nodes = self.scene.children;
    for (SKNode *selectedNode in nodes)
    {
        if ([selectedNode.name isEqualToString:@"flame"])
            [selectedNode removeFromParent];
    }
    self.backgroundColor = [SKColor colorWithRed:27/255.0 green:78/255.0 blue:130/255.0 alpha:1.0];
    
    if ([reason isEqualToString: @"quit"])
    {
        NSArray *nodes = self.scene.children;
        [song stop];
        stars = false;
        gamePaused = (Boolean *) false;
        for (SKNode *selectedNode in nodes)
        {
            if (![selectedNode.name isEqualToString:@"star"])
                [selectedNode removeFromParent];
        }
        points = 0;
        [self initStars];
        [self updateScore];
        [self initialSetup];
    }
    if ([reason isEqualToString: @"fail"])
    {
        NSArray *nodes = self.scene.children;
        [song stop];
        stars = false;
        gamePaused = (Boolean *) false;
        for (SKNode *selectedNode in nodes)
        {
            if (![selectedNode.name isEqualToString:@"star"])
                [selectedNode removeFromParent];
        }
        [self gameover];
    }
}

-(void)gameover
{
    SKLabelNode *gameover = [SKLabelNode labelNodeWithFontNamed:@"Minecraftia"];
    gameover.zPosition = 10;
    gameover.name = @"gameover";
    gameover.text = @"Game Over";
    gameover.fontSize = 45;
    gameover.position = CGPointMake(CGRectGetMidX(self.frame),CGRectGetMidY(self.frame));
    [self addChild:gameover];
    
    SKLabelNode *finalScore = [SKLabelNode labelNodeWithFontNamed:@"Minecraftia"];
    finalScore.zPosition = 10;
    finalScore.name = @"finalScore";
    NSString *text = @"Final Score: ";
    text = [text stringByAppendingString: [NSString stringWithFormat:@"%d", (int) points]];
    finalScore.text = text;
    finalScore.fontSize = 30;
    finalScore.position = CGPointMake(CGRectGetMidX(self.frame),CGRectGetMidY(self.frame)-45);
    [self addChild:finalScore];
    
    SKLabelNode *highScore = [SKLabelNode labelNodeWithFontNamed:@"Minecraftia"];
    highScore.zPosition = 10;
    highScore.name = @"highestScore";
    NSString *highScoreText = @"High Score: ";
    if (points > highScorePts)
    {
        highScorePts = points;
        [self newHighScore];
    }
    highScoreText = [highScoreText stringByAppendingString: [NSString stringWithFormat:@"%d", (int)highScorePts]];
    highScore.text = highScoreText;
    finalScore.text = text;
    highScore.fontSize = 30;
    highScore.position = CGPointMake(CGRectGetMidX(self.frame),CGRectGetMidY(self.frame)-90);
    [self addChild:highScore];
    
    [NSTimer scheduledTimerWithTimeInterval:5 target:self selector:@selector(initialSetup) userInfo:nil repeats:NO];
}

-(void)newHighScore
{
    SKLabelNode *newHighScore = [SKLabelNode labelNodeWithFontNamed:@"Minecraftia"];
    newHighScore.zPosition = 10;
    newHighScore.name = @"newHighScore";
    newHighScore.text = @"NEW HIGH SCORE";
    newHighScore.fontSize = 45;
    newHighScore.position = CGPointMake(CGRectGetMidX(self.frame),CGRectGetMidY(self.frame)+45);
    [self addChild:newHighScore];
    
    SKAction *wait = [SKAction waitForDuration:.5];
    
    SKAction *hide = [SKAction runBlock:^{
        newHighScore.hidden = YES;}];
    SKAction *show = [SKAction runBlock:^{
        newHighScore.hidden = NO;}];
    
    SKAction *seq1 = [SKAction sequence:@[show, wait, hide, wait, show]];
    SKAction *repeat = [SKAction repeatActionForever:seq1];
    [newHighScore runAction:repeat];
}

-(void)fireLaser
{
    if (cat.position.x == 35)
    {
        laser = [SKSpriteNode spriteNodeWithImageNamed:@"RainbowLaser.png"];
        laser.name = @"laser";
        laser.position = CGPointMake(65, cat.position.y-2);
        laser.size = CGSizeMake(20, 2);
        
        laser.physicsBody = [SKPhysicsBody bodyWithCircleOfRadius:.5];
        laser.physicsBody.dynamic = YES;
        laser.physicsBody.categoryBitMask = projectileCategory;
        laser.physicsBody.contactTestBitMask = monsterCategory;
        laser.physicsBody.collisionBitMask = 0;
        laser.physicsBody.usesPreciseCollisionDetection = YES;
        
        [self addChild:laser];
        SKAction *move = [SKAction moveToX:CGRectGetMaxX(self.frame)+20 duration:1];
        [laser runAction:move];
        [self playSound:(int *) 0];
    }
}

-(void)initScore
{
    score = [SKLabelNode labelNodeWithFontNamed:@"Minecraftia"];
    score.name = @"score";
    [self updateScore];
    score.fontSize = 10;
    score.position = CGPointMake(CGRectGetMinX(self.frame)+3,CGRectGetMaxY(self.frame)-30);
    score.hidden = true;
    score.horizontalAlignmentMode = SKLabelHorizontalAlignmentModeLeft;
    score.zPosition = 7;
    [self addChild:score];
}

-(void)updateScore
{
    NSString *text = @"Score: ";
    text = [text stringByAppendingString: [NSString stringWithFormat:@"%d", (int) points]];
    score.text = text;
}

-(void)initCat
{
    //cat init
    cat = [SKSpriteNode spriteNodeWithImageNamed:@"nyan_01.png"];
    cat.zPosition = 6;
    cat.position = CGPointMake(CGRectGetMidX(self.frame), CGRectGetMidY(self.frame));
    cat.size = CGSizeMake(301, 119);
    
    cat.physicsBody = [SKPhysicsBody bodyWithRectangleOfSize:cat.size]; // 1
    cat.physicsBody.dynamic = NO; // 2
    cat.physicsBody.categoryBitMask = playerCategory; // 3
    cat.physicsBody.contactTestBitMask = monsterCategory; // 4
    cat.physicsBody.collisionBitMask = 0; // 5
    
    [self addChild:cat];
    
    //cat images init
    NSArray *textures = [NSArray arrayWithObjects:[SKTexture textureWithImageNamed:@"nyan_01.png"],
                         [SKTexture textureWithImageNamed:@"nyan_02.png"],
                         [SKTexture textureWithImageNamed:@"nyan_03.png"],
                         [SKTexture textureWithImageNamed:@"nyan_04.png"],
                         [SKTexture textureWithImageNamed:@"nyan_05.png"],
                         [SKTexture textureWithImageNamed:@"nyan_06.png"],
                         [SKTexture textureWithImageNamed:@"nyan_07.png"],
                         [SKTexture textureWithImageNamed:@"nyan_08.png"],
                         [SKTexture textureWithImageNamed:@"nyan_09.png"],
                         [SKTexture textureWithImageNamed:@"nyan_10.png"],
                         [SKTexture textureWithImageNamed:@"nyan_11.png"],
                         [SKTexture textureWithImageNamed:@"nyan_12.png"],
                         nil];
    //cat animation init
    SKAction *animate = [SKAction animateWithTextures:textures timePerFrame:.075];
    SKAction *repeatAnimate = [SKAction repeatActionForever:animate];
    [cat runAction:repeatAnimate];
}

-(void)initStars
{
    if (!gamePaused)
    {
        NSArray *nodes = self.scene.children;
        for (SKNode *selectedNode in nodes)
        {
            if ([selectedNode.name isEqualToString: @"star"])
            {
                [selectedNode removeFromParent];
            }
        }
        SKSpriteNode *forwardStars[20];
        for (int i = 0; i < 15; i++)
        {
            //star init
            SKSpriteNode *star = [SKSpriteNode spriteNodeWithImageNamed:@"star_01.png"];
            star.name = @"star";
            star.zPosition = 4;
            
            CGFloat x = (CGFloat) (arc4random() % (int) self.frame.size.width);
            CGFloat y = (CGFloat) (arc4random() % (int) self.frame.size.height);
            star.position = CGPointMake(x, y);
            
            star.size = CGSizeMake(10, 10);
            
            //star images init
            NSArray *forwardTextures = [NSArray arrayWithObjects:[SKTexture textureWithImageNamed:@"star_01.png"],
                                 [SKTexture textureWithImageNamed:@"star_02.png"],
                                 [SKTexture textureWithImageNamed:@"star_03.png"],
                                 [SKTexture textureWithImageNamed:@"star_04.png"],
                                 [SKTexture textureWithImageNamed:@"star_05.png"],
                                 [SKTexture textureWithImageNamed:@"star_06.png"],
                                 [SKTexture textureWithImageNamed:@"star_07.png"],
                                 nil];
            //star animation init
            SKAction *animate = [SKAction animateWithTextures:forwardTextures timePerFrame:.075];
            SKAction *moveX = [SKAction moveToX:star.position.x-20 duration:.45];
            SKAction *group = [SKAction group:@[moveX, animate]];
            [star runAction:group];
            
            forwardStars[i] = star;
            [self addChild:forwardStars[i]];
        }
        SKSpriteNode *backwardStars[20];
        for (int i = 0; i < 15; i++)
        {
            //star init
            SKSpriteNode *star = [SKSpriteNode spriteNodeWithImageNamed:@"star_01.png"];
            star.name = @"star";
            star.zPosition = 4;
            
            CGFloat x = (CGFloat) (arc4random() % (int) self.frame.size.width);
            CGFloat y = (CGFloat) (arc4random() % (int) self.frame.size.height);
            star.position = CGPointMake(x, y);
            
            star.size = CGSizeMake(10, 10);
            
            //star images init
            NSArray *backwardTextures = [NSArray arrayWithObjects:[SKTexture textureWithImageNamed:@"star_06.png"],
                                        [SKTexture textureWithImageNamed:@"star_05.png"],
                                        [SKTexture textureWithImageNamed:@"star_04.png"],
                                        [SKTexture textureWithImageNamed:@"star_03.png"],
                                        [SKTexture textureWithImageNamed:@"star_02.png"],
                                        [SKTexture textureWithImageNamed:@"star_01.png"],
                                        [SKTexture textureWithImageNamed:@"star_07.png"],
                                        nil];
            //star animation init
            SKAction *animate = [SKAction animateWithTextures:backwardTextures timePerFrame:.075];
            SKAction *moveX = [SKAction moveToX:star.position.x-20 duration:.45];
            SKAction *group = [SKAction group:@[moveX, animate]];
            [star runAction:group];
            
            backwardStars[i] = star;
            [self addChild:backwardStars[i]];
        }
        [NSTimer scheduledTimerWithTimeInterval:.45 target:self selector:@selector(initStars) userInfo:nil repeats:NO];
    }
}

-(void)spawnNarwhals
{
    if (!gamePaused && started && !claytonMode)
    {
        if (!HCM)
        {
            if((int)song.currentTime % 2 == 0)
                [self initNarwhals];
            if((int)song.currentTime % 3 == 0)
                [self initNarwhals];
            if((int)song.currentTime % 5 == 0)
                [self initNarwhals];
        }
        else if(HCM)
        {
            if((int)song.currentTime % 1 == 0)
                [self initDeathNarwhals];
            if((int)song.currentTime % 2 == 0)
                [self initDeathNarwhals];
            if((int)song.currentTime % 3 == 0)
                [self initDeathNarwhals];
            if((int)song.currentTime % 4 == 0)
                [self initDeathNarwhals];
            if((int)song.currentTime % 5 == 0)
                [self initDeathNarwhals];
            if((int)song.currentTime % 6 == 0)
                [self initDeathNarwhals];
            if((int)song.currentTime % 7 == 0)
                [self initDeathNarwhals];
        }
    }
}

-(void)spawnClaytonNarwhals
{
    if (!gamePaused && started && claytonMode)
    {
        if(claytonTheDestroyer.position.x == CGRectGetMaxX(self.frame)-100)
        {
            
        }
        
        [NSTimer scheduledTimerWithTimeInterval:.5 target:self selector:@selector(spawnNarwhals) userInfo:nil repeats:NO];
    }
}

-(void)initNarwhals
{
    narwhal = [SKSpriteNode spriteNodeWithImageNamed:@"narwhal_01.png"];
    narwhal.name = @"narwhal";
    narwhal.zPosition = 5;
    CGFloat y = (CGFloat) (arc4random() % (int) CGRectGetMaxY(self.frame)-40) + 20;
    narwhal.position = CGPointMake(CGRectGetMaxX(self.frame)+40, y);
    narwhal.size = CGSizeMake(64, 64);
    narwhal.hidden = false;
    
    narwhal.physicsBody = [SKPhysicsBody bodyWithCircleOfRadius:narwhal.size.width*.5]; // 1
    narwhal.physicsBody.dynamic = YES; // 2
    narwhal.physicsBody.categoryBitMask = monsterCategory; // 3
    narwhal.physicsBody.contactTestBitMask = projectileCategory; // 4
    narwhal.physicsBody.collisionBitMask = 0; // 5
    
    [self addChild:narwhal];
    
    NSArray *Textures = [NSArray arrayWithObjects:[SKTexture textureWithImageNamed:@"narwhal_01.png"],
                         [SKTexture textureWithImageNamed:@"narwhal_02.png"],
                         nil];
    SKAction *animate = [SKAction animateWithTextures:Textures timePerFrame:.05];
    SKAction *repeatAnimate = [SKAction repeatActionForever:animate];
    [narwhal runAction:repeatAnimate];
    SKAction *move = [SKAction moveToX:-20 duration:20];
    [narwhal runAction:move];
}

-(void)initDeathNarwhals
{
    deathNarwhal = [SKSpriteNode spriteNodeWithImageNamed:@"narwhal_01.png"];
    deathNarwhal.name = @"deathNarwhal";
    deathNarwhal.zPosition = 5;
    CGFloat y = (CGFloat) (arc4random() % (int) CGRectGetMaxY(self.frame));
    deathNarwhal.position = CGPointMake(CGRectGetMaxX(self.frame)+40, y);
    deathNarwhal.size = CGSizeMake(64, 64);
    deathNarwhal.hidden = false;
    
    deathNarwhal.physicsBody = [SKPhysicsBody bodyWithCircleOfRadius:deathNarwhal.size.width*.5]; // 1
    deathNarwhal.physicsBody.dynamic = YES; // 2
    deathNarwhal.physicsBody.categoryBitMask = monsterCategory; // 3
    deathNarwhal.physicsBody.contactTestBitMask = projectileCategory; // 4
    deathNarwhal.physicsBody.collisionBitMask = 0; // 5
    
    [self addChild:deathNarwhal];
    
    NSArray *Textures = [NSArray arrayWithObjects:[SKTexture textureWithImageNamed:@"narwhal_01.png"],
                         [SKTexture textureWithImageNamed:@"narwhal_02.png"],
                         nil];
    SKAction *animate = [SKAction animateWithTextures:Textures timePerFrame:.05];
    SKAction *repeatAnimate = [SKAction repeatActionForever:animate];
    [deathNarwhal runAction:repeatAnimate];
    SKAction *move = [SKAction moveToX:-20 duration:.75];
    [deathNarwhal runAction:move];
}

-(void)initClaytonNarwhals
{
    claytonNarwhal = [SKSpriteNode spriteNodeWithImageNamed:@"narwhal_01.png"];
    claytonNarwhal.name = @"claytonNarwhal";
    claytonNarwhal.zPosition = 5;
    CGFloat y = (CGFloat) (arc4random() % (int) CGRectGetMaxY(self.frame));
    claytonNarwhal.position = CGPointMake(claytonTheDestroyer.position.x, y);
    claytonNarwhal.size = CGSizeMake(64, 64);
    claytonNarwhal.hidden = false;
    
    claytonNarwhal.physicsBody = [SKPhysicsBody bodyWithCircleOfRadius:claytonNarwhal.size.width*.5]; // 1
    claytonNarwhal.physicsBody.dynamic = YES; // 2
    claytonNarwhal.physicsBody.categoryBitMask = monsterCategory; // 3
    claytonNarwhal.physicsBody.contactTestBitMask = projectileCategory; // 4
    claytonNarwhal.physicsBody.collisionBitMask = 0; // 5
    
    [self addChild:claytonNarwhal];
    
    NSArray *Textures = [NSArray arrayWithObjects:[SKTexture textureWithImageNamed:@"narwhal_01.png"],
                         [SKTexture textureWithImageNamed:@"narwhal_02.png"],
                         nil];
    SKAction *animate = [SKAction animateWithTextures:Textures timePerFrame:.05];
    SKAction *repeatAnimate = [SKAction repeatActionForever:animate];
    [claytonNarwhal runAction:repeatAnimate];
    SKAction *move = [SKAction moveToX:-20 duration:.75];
    [claytonNarwhal runAction:move];
}

-(void)explosion:(CGFloat)x :(CGFloat)y
{
    boom = [SKSpriteNode spriteNodeWithImageNamed:@"explosion_1.png"];
    boom.name = @"boom";
    boom.zPosition = 4;
    boom.position = CGPointMake(x, y);
    boom.size = CGSizeMake(64, 64);
    [self addChild:boom];
    
    //star images init
    NSArray *Textures = [NSArray arrayWithObjects:[SKTexture textureWithImageNamed:@"explosion_1.png"],
                                [SKTexture textureWithImageNamed:@"explosion_2.png"],
                                [SKTexture textureWithImageNamed:@"explosion_3.png"],
                                [SKTexture textureWithImageNamed:@"explosion_4.png"],
                                [SKTexture textureWithImageNamed:@"explosion_5.png"],
                                [SKTexture textureWithImageNamed:@"explosion_6.png"],
                                [SKTexture textureWithImageNamed:@"explosion_7.png"],
                                [SKTexture textureWithImageNamed:@"explosion_8.png"],
                                nil];
    //star animation init
    SKAction *animate = [SKAction animateWithTextures:Textures timePerFrame:.05];
    SKAction *fade = [SKAction fadeOutWithDuration:0];
    SKAction *sequence = [SKAction sequence:@[animate,fade]];
    [boom runAction:sequence];
    [NSTimer scheduledTimerWithTimeInterval:.4 target:self selector:@selector(removeExp) userInfo:nil repeats:NO];
}

-(void)FLAMES
{
    SKSpriteNode *fire[70];
    for (int i = 0; i < 70; i++)
    {
        fire[i] = [SKSpriteNode spriteNodeWithImageNamed:@"flames_1.png"];
        fire[i].name = @"flame";
        fire[i].zPosition = 4;
        fire[i].position = CGPointMake(0+i*15, CGRectGetMinY(self.frame)+5);
        fire[i].size = CGSizeMake(64, 64);
        [self addChild:fire[i]];
        
        //star images init
        NSArray *Textures = [NSArray arrayWithObjects:[SKTexture textureWithImageNamed:@"flames_1.png"],
                             [SKTexture textureWithImageNamed:@"flames_2.png"],
                             [SKTexture textureWithImageNamed:@"flames_3.png"],
                             [SKTexture textureWithImageNamed:@"flames_4.png"],
                             [SKTexture textureWithImageNamed:@"flames_5.png"],
                             [SKTexture textureWithImageNamed:@"flames_6.png"],
                             nil];
        //star animation init
        SKAction *animate = [SKAction animateWithTextures:Textures timePerFrame:.05];
        SKAction *repeat = [SKAction repeatActionForever:animate];
        [fire[i] runAction:repeat];
    }
}

-(void)removeExp
{
    [boom removeFromParent];
}

- (void)projectile:(SKSpriteNode *)projectile didCollideWithMonster:(SKSpriteNode *)monster
{
    if(projectile.position.x < CGRectGetMaxX(self.frame))
    {
        [self explosion:monster.position.x :monster.position.y];
        points += 5;
        [projectile removeAllActions];
        [projectile removeFromParent];
        [monster removeFromParent];
    }
    else
    {
        [projectile removeAllActions];
        [projectile removeFromParent];
    }
}

- (void)player:(SKSpriteNode *)player didCollideWithMonster:(SKSpriteNode *)monster
{
    [self explosion:monster.position.x :monster.position.y];
    [player removeFromParent];
    [monster removeFromParent];
    started = false;
    [NSTimer scheduledTimerWithTimeInterval:3 target:self selector:@selector(lose) userInfo:nil repeats:NO];
}

- (void)projectile:(SKSpriteNode *)projectile didCollideWithClayton:(SKSpriteNode *)clayton
{
    if(projectile.position.x < CGRectGetMaxX(self.frame))
    {
        points += 5;
        [projectile removeAllActions];
        [projectile removeFromParent];
    }
    else
    {
        [projectile removeAllActions];
        [projectile removeFromParent];
    }
    if(claytonHP > (int*)200)
    {
        [clayton removeFromParent];
        [self explosion:clayton.position.x :clayton.position.y];
        [NSTimer scheduledTimerWithTimeInterval:3 target:self selector:@selector(lose) userInfo:nil repeats:NO];
    }
    else
        claytonHP += 1;
}

-(void)lose
{
    [self endGame:@"fail"];
}

- (void)didBeginContact:(SKPhysicsContact *)contact
{
    // 1
    SKPhysicsBody *firstBody, *secondBody;
    
    if (contact.bodyA.categoryBitMask < contact.bodyB.categoryBitMask)
    {
        firstBody = contact.bodyA;
        secondBody = contact.bodyB;
    }
    else
    {
        firstBody = contact.bodyB;
        secondBody = contact.bodyA;
    }
    
    if(firstBody == nil || secondBody == nil)
    {
        return;
    }
    
    // 2
    if ((firstBody.categoryBitMask & projectileCategory) != 0 &&
        (secondBody.categoryBitMask & monsterCategory) != 0) [self projectile:(SKSpriteNode *) firstBody.node didCollideWithMonster:(SKSpriteNode *) secondBody.node];
    else if ((firstBody.categoryBitMask & monsterCategory) != 0 &&
        (secondBody.categoryBitMask & playerCategory) != 0) [self player:(SKSpriteNode *) firstBody.node didCollideWithMonster:(SKSpriteNode *) secondBody.node];
    else if ((firstBody.categoryBitMask & projectileCategory) != 0 &&
        (secondBody.categoryBitMask & claytonCategory) != 0) [self projectile:(SKSpriteNode *) firstBody.node didCollideWithClayton:(SKSpriteNode *) secondBody.node];
}

-(void)spawnClaytonTheDestroyer
{
    claytonHP = 0;
    claytonTheDestroyer = [SKSpriteNode spriteNodeWithImageNamed:@"claytonJabba.png"];
    claytonTheDestroyer.name = @"narwhal";
    claytonTheDestroyer.zPosition = 5;
    claytonTheDestroyer.position = CGPointMake(CGRectGetMaxX(self.frame)+40, CGRectGetMidY(self.frame));
    claytonTheDestroyer.size = CGSizeMake(128, 128);
    claytonTheDestroyer.hidden = false;
    
    claytonTheDestroyer.physicsBody = [SKPhysicsBody bodyWithCircleOfRadius:claytonTheDestroyer.size.width*.5]; // 1
    claytonTheDestroyer.physicsBody.dynamic = YES; // 2
    claytonTheDestroyer.physicsBody.categoryBitMask = claytonCategory; // 3
    claytonTheDestroyer.physicsBody.contactTestBitMask = projectileCategory; // 4
    claytonTheDestroyer.physicsBody.collisionBitMask = 0; // 5
    
    [self addChild:claytonTheDestroyer];

    SKAction *move = [SKAction moveToX:CGRectGetMaxX(self.frame)-100 duration:5];
    [claytonTheDestroyer runAction:move];
}

@end