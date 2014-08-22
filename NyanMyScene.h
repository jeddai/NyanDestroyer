//
//  NyanMyScene.h
//  NyanDestroyer
//

//  Copyright (c) 2014 jeddai. All rights reserved.
//

#import <SpriteKit/SpriteKit.h>
#import <AudioToolbox/AudioToolbox.h>
#import <AVFoundation/AVFoundation.h>

@interface NyanMyScene : SKScene
{
    SKSpriteNode *cat;
    SKSpriteNode *laser;
    SKLabelNode *title;
    SKLabelNode *startLabel;
    SKLabelNode *pause;
    SKLabelNode *pauseLabel;
    SKLabelNode *quit;
    SKLabelNode *score;
    int *points;
    AVAudioPlayer *song;
    AVAudioPlayer *pew;
    Boolean *started;
    Boolean *gamePaused;
    Boolean *stars;
}
@property(nonatomic, retain) AVAudioPlayer *song;
@property(nonatomic, retain) AVAudioPlayer *pew;
@property(nonatomic, retain) SKSpriteNode *cat;
@property(nonatomic, retain) SKSpriteNode *laser;
@property(nonatomic, retain) SKLabelNode *title;
@property(nonatomic, retain) SKLabelNode *startLabel;
@property(nonatomic, retain) SKLabelNode *pause;
@property(nonatomic, retain) SKLabelNode *pauseLabel;
@property(nonatomic, retain) SKLabelNode *quit;
@property(nonatomic, retain) SKLabelNode *score;
@property(nonatomic) int *points;

@end
