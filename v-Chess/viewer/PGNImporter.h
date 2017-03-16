//
//  PGNImporter.h
//  vChess
//
//  Created by Sergey Seitov on 13.03.13.
//  Copyright (c) 2013 V-Channel. All rights reserved.
//
#import <Foundation/Foundation.h>
#import "SynthesizeSingleton.h"

#include <vector>

typedef std::vector<std::string> TurnsArray;

BOOL parseTurns(NSString* pgn, TurnsArray* turns);

@interface PGNImporter : NSObject

+ (PGNImporter*)sharedPGNImporter;

- (int)fillImportCatalog:(NSMutableArray*)catalog fromURL:(NSURL*)url isZip:(bool)isZip;
- (BOOL)appendGame:(NSString*)package header:(NSString*)header pgn:(NSString*)pgn;

@end
