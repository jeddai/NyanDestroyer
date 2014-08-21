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
    SKLabelNode *startLabel;
    SKLabelNode *pause;
    SKLabelNode *pauseLabel;
    AVAudioPlayer *audioPlayer;
    Boolean *started;
    Boolean *gamePaused;
}
@property(nonatomic, retain) AVAudioPlayer *audioPlayer;
@property(nonatomic, retain) SKSpriteNode *cat;
@property(nonatomic, retain) SKLabelNode *startLabel;
@property(nonatomic, retain) SKLabelNode *pause;
@property(nonatomic, retain) SKLabelNode *pauseLabel;

@end
