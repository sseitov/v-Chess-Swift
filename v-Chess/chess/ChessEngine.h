//
//  ChessEngine.h
//  v-Chess
//
//  Created by Сергей Сейтов on 14.03.17.
//  Copyright © 2017 V-Channel. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ChessGame.h"

typedef NS_ENUM(NSUInteger, Depth) {
    Fast = 3,
    Strong = 4,
};

typedef NS_ENUM(NSUInteger, PlayMode) {
    NOPLAY = 0,
    PLAY_STEP = 1,
    PLAY_FORWARD = 2,
    PLAY_BACKWARD = 3,
};

NSString* const YouWinNotification = @"YouWinNotification";

@interface ChessEngine : NSObject

- (instancetype)initWithView:(UIView*)view forDepth:(Depth)depth timerView:(UISegmentedControl*)timerView;
- (void)rotateDesk:(bool)rotate;
- (void)startGame:(bool)white;
- (void)stopGame;
- (bool)gameStarted;

- (instancetype)initWithView:(UIView*)view;
- (bool)setupGame:(ChessGame*)game;
- (NSInteger)turnsCount;
- (NSString*)turnTextForRow:(NSInteger)row white:(bool)isWhite;
- (void)turnForward:(void (^)(bool))next;
- (void)turnBack:(void (^)(bool))next;

@property (readwrite) PlayMode	playMode;

@end
