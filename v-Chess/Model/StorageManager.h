//
//  StorageManager.h
//  Glucograph
//
//  Created by Sergey Seitov on 27.02.13.
//  Copyright (c) 2013 Sergey Seitov. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import "SynthesizeSingleton.h"

@interface StorageManager : NSObject

@property (readonly, strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (readonly, strong, nonatomic) NSManagedObjectModel *managedObjectModel;
@property (readonly, strong, nonatomic) NSPersistentStoreCoordinator *persistentStoreCoordinator;

+ (StorageManager *)sharedStorageManager;
- (void)initUserPackages;

- (BOOL)saveContext;
- (id)fetchObjectFromEntity:(NSString *)entity withPredicate:(NSPredicate *)predicate;

- (NSArray*)getUserPackages;
- (BOOL)insertGameWithHeader:(NSDictionary*)header turns:(NSString*)pgn intoPackage:(NSString*)package;
- (void)removePackage:(NSString*)package;
- (NSArray*)ecoInPackage:(NSString*)package;
- (NSArray*)gamesWithEco:(NSString*)eco inPackage:(NSString*)name;
- (NSArray*)gamesInPackage:(NSString*)name;

@end
