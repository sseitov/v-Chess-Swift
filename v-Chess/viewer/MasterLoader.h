//
//  MasterLoader.h
//  vChess
//
//  Created by Sergey Seitov on 10/2/10.
//  Copyright 2010 V-Channel. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ChessGame.h"

@interface MasterLoader : UIViewController

@property (strong, nonatomic) NSArray	*mMasterEco;
@property (strong, nonatomic) NSString	*mPackageName;
@property (strong, nonatomic) ChessGame *mSelectedGame;

@end
