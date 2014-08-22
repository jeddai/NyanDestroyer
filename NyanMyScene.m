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

@implementation NyanMyScene
@synthesize cat, title, startLabel, pauseLabel, pause, quit, laser, score, points, song, pew;

-(id)initWithSize:(CGSize)size {    
    if (self = [super initWithSize:size]) {
        /* Setup your scene here */
        
        self.backgroundColor = [SKColor colorWithRed:27/255.0 green:78/255.0 blue:130/255.0 alpha:1.0];
        
        [self initialSetup];
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
                //SKAction *shoot = [SKAction ]
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
        [self explosion:&location];
        if (started == (Boolean *) true && gamePaused == (Boolean *)false)
        {
            //if touch location is halfway across screen in x
            if (location.x > CGRectGetMidX(self.frame))
            {
                if(![node.name isEqualToString:@"paused"])
                {
                    [self fireLaser];
                }
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

-(void)update:(CFTimeInterval)currentTime {
    /* Called before each frame is rendered */
}

-(void)initialSetup
{
    //title init
    title = [SKLabelNode labelNodeWithFontNamed:@"Minecraftia"];
    title.text = @"Nyan Destroyer";
    title.fontSize = 15;
    title.position = CGPointMake(CGRectGetMidX(self.frame),CGRectGetMaxY(self.frame)-220);
    [self addChild:title];
    
    [self initCat];
    
    //start label init
    startLabel = [SKLabelNode labelNodeWithFontNamed:@"Minecraftia"];
    startLabel.zPosition = 6;
    startLabel.name = @"start";
    startLabel.text = @"Start Game";
    startLabel.fontSize = 30;
    startLabel.position = CGPointMake(CGRectGetMidX(self.frame),CGRectGetMidY(self.frame));
    [self addChild:startLabel];
    
    //pause button init
    pause = [SKLabelNode labelNodeWithFontNamed:@"Minecraftia"];
    pause.name = @"paused";
    pause.text = @"Pause";
    pause.fontSize = 10;
    pause.position = CGPointMake(CGRectGetMaxX(self.frame)-22,CGRectGetMaxY(self.frame)-220);
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
        [song play];
        if(song.currentTime == song.duration)
        {
            [song play];
        }
    }
}

-(void)startGame
{
    if (started == false)
    {
        stars = (Boolean *)true;
        [self initStars];
        SKAction *startMoveX = [SKAction moveToX:35 duration:2];
        SKAction *startMoveY = [SKAction moveToY:CGRectGetMidY(self.frame) duration:2];
        SKAction *startSize = [SKAction scaleBy:.25 duration:2];
        SKAction *group = [SKAction group:@[startMoveX,startMoveY,startSize]];
        [cat runAction:group];
        [startLabel removeFromParent];
        started = (Boolean *) true;
        [self playSound:(int *) 1];
        pause.hidden = false;
        score.hidden = false;
        title.hidden = true;
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
            else if ([selectedNode.name isEqualToString:@"restart"])
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
    NSArray *nodes = self.scene.children;
    if ([reason isEqualToString: @"quit"])
    {
        stars = false;
        gamePaused = (Boolean *) false;
        for (SKNode *selectedNode in nodes)
        {
            [selectedNode removeFromParent];
        }
        points = 0;
        [self updateScore];
        [self initialSetup];
    }
}

-(void)fireLaser
{
    if (cat.position.x == 35)
    {
        laser = [SKSpriteNode spriteNodeWithImageNamed:@"RainbowLaser.png"];
        laser.name = @"laser";
        laser.position = CGPointMake(65, cat.position.y-2);
        laser.size = CGSizeMake(20, 2);
        [self addChild:laser];
        SKAction *move = [SKAction moveToX:CGRectGetMaxX(self.frame)+20 duration:1];
        [laser runAction:move];
        [self playSound:(int *) 0];
        points += 5;
        [self updateScore];
    }
}

-(void)initScore
{
    score = [SKLabelNode labelNodeWithFontNamed:@"Minecraftia"];
    score.name = @"score";
    [self updateScore];
    score.fontSize = 10;
    score.position = CGPointMake(CGRectGetMinX(self.frame)+3,CGRectGetMaxY(self.frame)-220);
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
    cat = [SKSpriteNode spriteNodeWithImageNamed:@"nyancat.gif"];
    cat.zPosition = 5;
    cat.position = CGPointMake(CGRectGetMidX(self.frame), CGRectGetMidY(self.frame));
    cat.size = CGSizeMake(301, 119);
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
    if(laser.position.x >= CGRectGetMaxX(self.frame))
        [laser removeFromParent];
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
        for (int i = 0; i < 20; i++)
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
        for (int i = 0; i < 20; i++)
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

-(void)explosion:(CGPoint *)location
{
    SKSpriteNode *boom = [SKSpriteNode spriteNodeWithImageNamed:@"explosion_1.png"];
    boom.name = @"star";
    boom.zPosition = 4;
    boom.position = *(location);
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
    [boom runAction:animate];
    if (!boom.hasActions)
        [boom removeFromParent];
}

@end
