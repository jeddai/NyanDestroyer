//
//  NyanMyScene.h
//  NyanDestroyer
//

//  Copyright (c) 2014 jeddai. All rights reserved.
//

#import <SpriteKit/SpriteKit.h>
#import <AudioToolbox/AudioToolbox.h>
#import <AVFoundation/AVFoundation.h>

@interface NyanMyScene : SKScene <SKPhysicsContactDelegate>
{
    SKSpriteNode *cat;
    SKSpriteNode *laser;
    SKSpriteNode *narwhal;
    SKSpriteNode *deathNarwhal;
    SKSpriteNode *claytonNarwhal;
    SKSpriteNode *boom;
    SKSpriteNode *claytonTheDestroyer;
    SKLabelNode *title;
    SKLabelNode *startLabel;
    SKLabelNode *pause;
    SKLabelNode *pauseLabel;
    SKLabelNode *quit;
    SKLabelNode *score;
    int *points;
    int *highScorePts;
    int *claytonHP;
    int *frame;
    AVAudioPlayer *song;
    AVAudioPlayer *pew;
    AVAudioPlayer *cantina;
    Boolean *started;
    Boolean *gamePaused;
    Boolean *stars;
    Boolean *HCM;
    Boolean *claytonMode;
}
@property(nonatomic, retain) AVAudioPlayer *song;
@property(nonatomic, retain) AVAudioPlayer *pew;
@property(nonatomic, retain) AVAudioPlayer *cantina;
@property(nonatomic, retain) SKSpriteNode *cat;
@property(nonatomic, retain) SKSpriteNode *laser;
@property(nonatomic, retain) SKSpriteNode *narwhal;
@property(nonatomic, retain) SKSpriteNode *boom;
@property(nonatomic, retain) SKSpriteNode *deathNarwhal;
@property(nonatomic, retain) SKSpriteNode *claytonNarwhal;
@property(nonatomic, retain) SKSpriteNode *claytonTheDestroyer;
@property(nonatomic, retain) SKLabelNode *title;
@property(nonatomic, retain) SKLabelNode *startLabel;
@property(nonatomic, retain) SKLabelNode *pause;
@property(nonatomic, retain) SKLabelNode *pauseLabel;
@property(nonatomic, retain) SKLabelNode *quit;
@property(nonatomic, retain) SKLabelNode *score;
@property(nonatomic) int *points;
@property(nonatomic) int *highScorePts;
@property(nonatomic) int *claytonHP;

@end