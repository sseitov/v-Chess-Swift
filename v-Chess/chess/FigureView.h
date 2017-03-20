//
//  FigureView.h
//  vChess
//
//  Created by Sergey Seitov on 1/29/10.
//  Copyright 2010 V-Channel. All rights reserved.
//

#import <UIKit/UIKit.h>

#include "position.h"
#include "figure.h"
#include "move.h"

enum FigureLiveState {
	LIVING,
	KILLED,
	ALIVED
};

@interface DragRect : UIView

@end

@interface PossibleRect : UIView

@end

@interface FigureView : UIImageView

@property (readwrite, nonatomic) unsigned char model;
@property (readwrite, nonatomic) vchess::Position position;

- (id)initFigure:(unsigned char)theModel frame:(CGRect)frame;
- (void)promote:(BOOL)promote;
- (void)kill;
- (void)alive;
- (FigureLiveState)liveState;

@end
