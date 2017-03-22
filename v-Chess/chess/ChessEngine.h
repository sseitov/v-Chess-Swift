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

NSString* const YouWinNotification = @"YouWinNotification";
NSString* const MyTurnNotification = @"MyTurnNotification";

@class EatController;

@interface ChessEngine : NSObject

- (instancetype)initWithView:(UIView*)view timerView:(UISegmentedControl*)timerView;
- (void)rotateDesk:(bool)rotate;
- (void)startGame:(bool)white forDepth:(Depth)depth;
- (void)startOnlineGame:(bool)white;
- (void)makeOnlineMove:(NSString*)move;
- (void)stopGame;
- (bool)gameStarted;

- (instancetype)initWithView:(UIView*)view;
- (bool)setupGame:(ChessGame*)game;
- (NSInteger)turnsCount;
- (NSString*)turnTextForRow:(NSInteger)row white:(bool)isWhite;
- (void)turnForward:(void (^)(bool))next;
- (void)turnBack:(void (^)(bool))next;
- (void)playToIndex:(NSInteger)index;
- (NSInteger)currentIndex;

@property (readwrite) Depth	depth;
@property (readwrite) bool soundEnable;
@property (weak, nonatomic) UICollectionViewController *whiteEat;
@property (weak, nonatomic) UICollectionViewController *blackEat;

@end
