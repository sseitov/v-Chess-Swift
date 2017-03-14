//
//  Figure.m
//  vChess
//
//  Created by Sergey Seitov on 1/29/10.
//  Copyright 2010 V-Channel. All rights reserved.
//

#import "FigureView.h"

using namespace vchess;

@implementation DragRect

- (id)initWithFrame:(CGRect)frame {
    
    self = [super initWithFrame:frame];
    if (self) {
        self.opaque = YES;
		self.backgroundColor = [UIColor clearColor];
        self.contentMode = UIViewContentModeScaleToFill;
    }
    return self;
}

- (void)drawRect:(CGRect)rect {
	
	CGContextRef context = UIGraphicsGetCurrentContext();
	CGContextSetStrokeColorWithColor(context, [UIColor colorWithRed:0 green:200.0/255.0 blue:0 alpha:1.0].CGColor);
	CGContextStrokeRectWithWidth(context, rect, 10);
}

@end

@implementation PossibleRect

- (id)initWithFrame:(CGRect)frame {
    
    self = [super initWithFrame:frame];
    if (self) {
        self.opaque = YES;
		self.backgroundColor = [UIColor clearColor];
    }
    return self;
}

- (void)drawRect:(CGRect)rect {
	
	CGContextRef context = UIGraphicsGetCurrentContext();
	CGContextSetFillColorWithColor(context, [UIColor colorWithRed:0 green:200.0/255.0 blue:0 alpha:1.0].CGColor);
	rect.origin.x = rect.size.width / 3;
	rect.origin.y = rect.size.height / 3;
	rect.size.width /= 3;
	rect.size.height /= 3;
	CGContextFillEllipseInRect(context, rect);
}

@end

@implementation FigureView

- (UIImage*)imageByType {
	
	switch (FIGURE(self.model)) {
		case KING:
			if (COLOR(self.model)) {
				return [UIImage imageNamed:@"bKing"];
			} else {
				return [UIImage imageNamed:@"wKing"];
			}
		case QUEEN:
			if (COLOR(self.model)) {
				return [UIImage imageNamed:@"bQueen"];
			} else {
				return [UIImage imageNamed:@"wQueen"];
			}
		case ROOK:
			if (COLOR(self.model)) {
				return [UIImage imageNamed:@"bRook"];
			} else {
				return [UIImage imageNamed:@"wRook"];
			}
		case BISHOP:
			if (COLOR(self.model)) {
				return [UIImage imageNamed:@"bBishop"];
			} else {
				return [UIImage imageNamed:@"wBishop"];
			}
		case KNIGHT:
			if (COLOR(self.model)) {
				return [UIImage imageNamed:@"bKnight"];
			} else {
				return [UIImage imageNamed:@"wKnight"];
			}
		case PAWN:
			if (COLOR(self.model)) {
				return [UIImage imageNamed:@"bPawn"];
			} else {
				return [UIImage imageNamed:@"wPawn"];
			}
		default:
			return nil;
	}
}

- (id)initFigure:(unsigned char)figure frame:(CGRect)frame {
	
	if (self = [super initWithFrame:frame]) {
		self.opaque = NO;
		self.userInteractionEnabled = YES;
		self.liveState = LIVING;
		self.model = figure;
		self.image = [self imageByType];
	}
	
	return self;
}

- (void)promote:(BOOL)promote {

	if (promote) {
		self.model = QUEEN | COLOR(self.model);
	} else {
		self.model = PAWN | COLOR(self.model);
	}
	self.image = [self imageByType];
}

@end
