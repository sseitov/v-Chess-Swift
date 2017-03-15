//
//  ChessGame.h
//  vChess
//
//  Created by Sergey Seitov on 09.05.13.
//  Copyright (c) 2013 V-Channel. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface ChessGame : NSManagedObject

@property (nonatomic, retain) NSString * black;
@property (nonatomic, retain) NSString * date;
@property (nonatomic, retain) NSString * eco;
@property (nonatomic, retain) NSString * event;
@property (nonatomic, retain) NSString * package;
@property (nonatomic, retain) NSString * result;
@property (nonatomic, retain) NSString * round;
@property (nonatomic, retain) NSString * site;
@property (nonatomic, retain) NSString * turns;
@property (nonatomic, retain) NSString * white;

@end
