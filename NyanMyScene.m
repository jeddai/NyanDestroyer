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
@synthesize cat, startLabel, pauseLabel, pause, audioPlayer;

-(id)initWithSize:(CGSize)size {    
    if (self = [super initWithSize:size]) {
        /* Setup your scene here */
        
        self.backgroundColor = [SKColor colorWithRed:27/255.0 green:78/255.0 blue:130/255.0 alpha:1.0];
        
        SKLabelNode *myLabel = [SKLabelNode labelNodeWithFontNamed:@"Minecraftia"];
        myLabel.text = @"Nyan Destroyer";
        myLabel.fontSize = 15;
        myLabel.position = CGPointMake(CGRectGetMidX(self.frame),CGRectGetMaxY(self.frame)-220);
        [self addChild:myLabel];
        
        cat = [SKSpriteNode spriteNodeWithImageNamed:@"nyancat.gif"];
        cat.position = CGPointMake(CGRectGetMidX(self.frame), CGRectGetMidY(self.frame));
        cat.size = CGSizeMake(301, 119);
        [self addChild:cat];
        
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
        
        SKAction *animate = [SKAction animateWithTextures:textures timePerFrame:.075];
        SKAction *repeatAnimate = [SKAction repeatActionForever:animate];
        [cat runAction:repeatAnimate];
        //[self playSound: (int *) 1];
        
        startLabel = [SKLabelNode labelNodeWithFontNamed:@"Minecraftia"];
        startLabel.name = @"start";
        startLabel.text = @"Start Game";
        startLabel.fontSize = 30;
        startLabel.position = CGPointMake(CGRectGetMidX(self.frame),CGRectGetMidY(self.frame));
        [self addChild:startLabel];
        
        pause = [SKLabelNode labelNodeWithFontNamed:@"Minecraftia"];
        pause.name = @"paused";
        pause.text = @"| |";
        pause.fontSize = 15;
        pause.position = CGPointMake(CGRectGetMaxX(self.frame)-20,CGRectGetMaxY(self.frame)-220);
        pause.hidden = true;
        [self addChild:pause];
        
        started = false;
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
                cat.position = CGPointMake(35, location.y);
            }
        }
    }
}

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    for (UITouch *touch in touches) {
        CGPoint location = [touch locationInNode:self];
        if (started == (Boolean *) true && gamePaused == (Boolean *)false)
        {
            if (location.x > CGRectGetMidX(self.frame))
            {
                //SKAction *shoot = [SKAction ]
            }
            else
            {
                SKAction *move = [SKAction moveToY:location.y duration:.075];
            
                [cat runAction:move];
            }
        }
        SKNode *node = [self nodeAtPoint:location];
        //node.name = @"paused";
        
        if ([node.name isEqualToString:@"start"])
        {
            [self startGame];
        }
        else if ([node.name isEqualToString:@"paused"])
        {
            [self pauseGame];
        }
    }
}

-(void)update:(CFTimeInterval)currentTime {
    /* Called before each frame is rendered */
}

-(void)playSound:(int*)number
{
    if(number == 0)
    {
        
    }
    else if(number == (int *) 1)
    {
        NSURL *url = [NSURL fileURLWithPath:[[NSBundle mainBundle]
                                             pathForResource:@"Song"
                                             ofType:@"mp3"]];
        NSError *error;
        audioPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:url error:&error];
        [audioPlayer play];
    }
}

-(void)startGame
{
    if (started == false)
    {
        SKAction *startMoveX = [SKAction moveToX:35 duration:2];
        SKAction *startMoveY = [SKAction moveToY:CGRectGetMidY(self.frame) duration:2];
        SKAction *startSize = [SKAction scaleBy:.25 duration:2];
        SKAction *group = [SKAction group:@[startMoveX,startMoveY,startSize]];
        [cat runAction:group];
        SKAction *hideStart = [SKAction removeFromParent];
        [startLabel runAction:hideStart];
        started = (Boolean *) true;
        [self playSound:(int *) 1];
        pause.hidden = false;
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
        [self addChild:pauseLabel];
        
        [audioPlayer pause];
        
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
        
        [audioPlayer play];
        
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
    }
}

-(void)endGame:(NSString *)reason
{
    if ([reason isEqualToString: @"quit"])
    {
        
    }
}

@end
