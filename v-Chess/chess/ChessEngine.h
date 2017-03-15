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

NSString* const YouWinNotification = @"YouWinNotification";

@interface ChessEngine : NSObject

- (instancetype)initWithView:(UIView*)view forDepth:(Depth)depth timerView:(UISegmentedControl*)timerView;
- (instancetype)initWithView:(UIView*)view forGame:(ChessGame*)game controlView:(UISegmentedControl*)controlView;

- (void)rotateDesk:(bool)rotate;
- (void)startGame:(bool)white;
- (void)stopGame;
- (bool)gameStarted;

@end
