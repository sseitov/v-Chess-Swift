//
//  ChessEngine.h
//  v-Chess
//
//  Created by Сергей Сейтов on 14.03.17.
//  Copyright © 2017 V-Channel. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ChessGame.h"

typedef NS_ENUM(NSInteger, Depth) {
    Fast = 3,
    Strong = 4,
};

typedef NS_ENUM(NSInteger, PlayMode) {
    NOPLAY = 0,
    PLAY_STEP = 1,
    PLAY_FORWARD = 2,
    PLAY_BACKWARD = 3,
};

NSString* const YouWinNotification = @"YouWinNotification";

@class EatController;

@interface ChessEngine : NSObject

- (instancetype)initWithView:(UIView*)view timerView:(UISegmentedControl*)timerView;
- (void)rotateDesk:(bool)rotate;
- (void)startGame:(bool)white forDepth:(Depth)depth;
- (void)stopGame;
- (bool)gameStarted;

- (instancetype)initWithView:(UIView*)view;
- (bool)setupGame:(ChessGame*)game;
- (NSInteger)turnsCount;
- (NSString*)turnTextForRow:(NSInteger)row white:(bool)isWhite;
- (void)turnForward:(void (^)(bool))next;
- (void)turnBack:(void (^)(bool))next;

@property (readwrite) Depth	depth;
@property (readwrite) PlayMode	playMode;
@property (readwrite) bool soundEnable;
@property (weak, nonatomic) UICollectionViewController *whiteEat;
@property (weak, nonatomic) UICollectionViewController *blackEat;

@end
