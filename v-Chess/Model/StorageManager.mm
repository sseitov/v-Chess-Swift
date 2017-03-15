//
//  StorageManager.m
//  Glucograph
//
//  Created by Sergey Seitov on 27.02.13.
//  Copyright (c) 2013 Sergey Seitov. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "StorageManager.h"
#import "ChessGame.h"
#include <string>
#include <vector>

typedef std::vector<std::string> TurnsArray;

@implementation StorageManager

SYNTHESIZE_SINGLETON_FOR_CLASS(StorageManager);

@synthesize managedObjectContext = _managedObjectContext;
@synthesize managedObjectModel = _managedObjectModel;
@synthesize persistentStoreCoordinator = _persistentStoreCoordinator;
@synthesize userPackages = _userPackages;

#pragma mark - Core Data stack

+ (BOOL)parseTurns:(NSString*)pgn into:(TurnsArray*)turns {
	
	NSError *err = nil;
	NSString *pattern = @"(?:(\\d+)(\\.)\\s*((?:[PNBRQK]?[a-h]?[1-8]?x?[a-h][1-8](?:\\=[PNBRQK])?|O(-?O){1,2})[\\+#]?(\\s*[\\!\\?]+)?)(?:\\s*((?:[PNBRQK]?[a-h]?[1-8]?x?[a-h][1-8](?:\\=[PNBRQK])?|O(-?O){1,2})[\\+#]?(\\s*[\\!\\?]+)?))?\\s*)";
	NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:pattern options:NSRegularExpressionCaseInsensitive error:&err];
	if (err) {
		NSLog(@"ERROR: %@", err.localizedDescription);
		return NO;
	}
	NSArray *matches = [regex matchesInString:pgn options:0 range:NSMakeRange(0, [pgn length])];
	for (NSTextCheckingResult *match in matches) {
		if (match.numberOfRanges > 6) {
			NSRange w = [match rangeAtIndex:3];
			if (w.length > 0) {
				(*turns).push_back([pgn substringWithRange:w].UTF8String);
			} else {
				return NO;
			}
			NSRange b = [match rangeAtIndex:6];
			if (b.length > 0) {
				(*turns).push_back([pgn substringWithRange:b].UTF8String);
			} else {
				break;
			}
		} else {
			return NO;
		}
	}
	return YES;
}

- (void)initUserPackages {
	
    NSSortDescriptor *firstDescriptor = [[NSSortDescriptor alloc] initWithKey:@"package" ascending:YES];
	NSArray *sortDescriptors = [[NSArray alloc] initWithObjects:firstDescriptor, nil];
	NSArray *packageArray = [self fetchObjectsFromEntity:@"ChessGame" withPredicate:nil withSortDescriptors:sortDescriptors];
	NSCountedSet *allPackages = [NSCountedSet setWithArray:[packageArray valueForKeyPath:@"@distinctUnionOfObjects.package"]];
	NSArray *vchessPackages = [NSArray arrayWithContentsOfURL:[[NSBundle mainBundle] URLForResource:@"packages" withExtension:@"plist"] ];
	for (NSString *package in vchessPackages) {
		[allPackages removeObject:package];
	}
	_userPackages = [[NSMutableArray alloc] initWithArray:[allPackages allObjects]];
}

// Core Data error handling.
// This is one a generic method to handle and display Core Data validation errors to the user.
// https://developer.apple.com/library/mac/#documentation/Cocoa/Reference/CoreDataFramework/Miscellaneous/CoreData_Constants/Reference/reference.html
- (void)displayValidationError:(NSError *)anError {
    if (anError && [[anError domain] isEqualToString:@"NSCocoaErrorDomain"]) {
        NSArray *errors = nil;
		
        // if multiple errors
        if ([anError code] == NSValidationMultipleErrorsError) {
            errors = [[anError userInfo] objectForKey:NSDetailedErrorsKey];
        } else {
            errors = [NSArray arrayWithObject:anError];
        }
		
        if (errors && [errors count] > 0) {
            NSString *messages = @"Reason(s):\n";
			
            for (NSError * error in errors) {
                NSString *entityName = [[[[error userInfo] objectForKey:@"NSValidationErrorObject"] entity] name];
                NSString *attributeName = [[error userInfo] objectForKey:@"NSValidationErrorKey"];
                NSString *msg;
                switch ([error code]) {
                    case NSManagedObjectValidationError:
                        msg = @"Generic validation error.";
                        break;
                    case NSValidationMissingMandatoryPropertyError:
                        msg = [NSString stringWithFormat:@"The attribute '%@' mustn't be empty.", attributeName];
                        break;
                    case NSValidationRelationshipLacksMinimumCountError:
                        msg = [NSString stringWithFormat:@"The relationship '%@' doesn't have enough entries.", attributeName];
                        break;
                    case NSValidationRelationshipExceedsMaximumCountError:
                        msg = [NSString stringWithFormat:@"The relationship '%@' has too many entries.", attributeName];
                        break;
                    case NSValidationRelationshipDeniedDeleteError:
                        msg = [NSString stringWithFormat:@"To delete, the relationship '%@' must be empty.", attributeName];
                        break;
                    case NSValidationNumberTooLargeError:
                        msg = [NSString stringWithFormat:@"The number of the attribute '%@' is too large.", attributeName];
                        break;
                    case NSValidationNumberTooSmallError:
                        msg = [NSString stringWithFormat:@"The number of the attribute '%@' is too small.", attributeName];
                        break;
                    case NSValidationDateTooLateError:
                        msg = [NSString stringWithFormat:@"The date of the attribute '%@' is too late.", attributeName];
                        break;
                    case NSValidationDateTooSoonError:
                        msg = [NSString stringWithFormat:@"The date of the attribute '%@' is too soon.", attributeName];
                        break;
                    case NSValidationInvalidDateError:
                        msg = [NSString stringWithFormat:@"The date of the attribute '%@' is invalid.", attributeName];
                        break;
                    case NSValidationStringTooLongError:
                        msg = [NSString stringWithFormat:@"The text of the attribute '%@' is too long.", attributeName];
                        break;
                    case NSValidationStringTooShortError:
                        msg = [NSString stringWithFormat:@"The text of the attribute '%@' is too short.", attributeName];
                        break;
                    case NSValidationStringPatternMatchingError:
                        msg = [NSString stringWithFormat:@"The text of the attribute '%@' doesn't match the required pattern.", attributeName];
                        break;
                    default:
                        msg = [NSString stringWithFormat:@"Unknown error (code %d).", (int)[error code]];
                        break;
                }
				
                messages = [messages stringByAppendingFormat:@"%@%@%@\n", (entityName?:@""),(entityName?@": ":@""),msg];
            }
            NSLog(@"Validation Error: %@", messages);
        }
    }
}

// Returns the managed object context for the application.
// If the context doesn't already exist, it is created and bound to the persistent store coordinator for the application.
- (NSManagedObjectContext *)managedObjectContext
{
    if (_managedObjectContext != nil) {
        return _managedObjectContext;
    }
    
    NSPersistentStoreCoordinator *coordinator = [self persistentStoreCoordinator];
    if (coordinator != nil) {
        _managedObjectContext = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSMainQueueConcurrencyType];
        [_managedObjectContext setPersistentStoreCoordinator:coordinator];
    }
    return _managedObjectContext;
}

// Returns the managed object model for the application.
// If the model doesn't already exist, it is created from the application's model.
- (NSManagedObjectModel *)managedObjectModel
{
    if (_managedObjectModel != nil) {
        return _managedObjectModel;
    }
    NSURL *modelURL = [[NSBundle mainBundle] URLForResource:@"vChessModel" withExtension:@"momd"];
    _managedObjectModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];
    return _managedObjectModel;
}

// Returns the persistent store coordinator for the application.
// If the coordinator doesn't already exist, it is created and the application's store added to it.
- (NSPersistentStoreCoordinator *)persistentStoreCoordinator
{
    if (_persistentStoreCoordinator != nil) {
        return _persistentStoreCoordinator;
    }
    
	NSURL *docDir = [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
	NSURL *storeURL = [docDir URLByAppendingPathComponent:@"vChess.sqlite"];
	NSDictionary *options = [NSDictionary dictionaryWithObjectsAndKeys:
                             [NSNumber numberWithBool:YES], NSMigratePersistentStoresAutomaticallyOption,
                             [NSNumber numberWithBool:YES], NSInferMappingModelAutomaticallyOption, nil];

    NSError *error = nil;
    _persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:[self managedObjectModel]];
    if (![_persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeURL options:options error:&error]) {
		[self displayValidationError:error];
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        abort();
	}

	NSURL *bundleURL = [[NSBundle mainBundle] URLForResource:@"Masters" withExtension:@"sqlite"];
	NSDictionary *bundleOptions = [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithBool:YES], NSReadOnlyPersistentStoreOption, nil];
    if (![_persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:bundleURL options:bundleOptions error:&error]) {
		[self displayValidationError:error];
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        abort();
	}
    
	return _persistentStoreCoordinator;
}

#pragma mark - Common methods

- (BOOL)saveContext
{
    NSError *error = nil;
    NSManagedObjectContext *managedObjectContext = self.managedObjectContext;
    if (managedObjectContext != nil) {
        if ([managedObjectContext hasChanges] && ![managedObjectContext save:&error]) {
			[self displayValidationError:error];
            NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
			return NO;
        }
    }
	return YES;
}

- (id)fetchObjectFromEntity:(NSString *)entity withPredicate:(NSPredicate *)predicate {
	
	NSError *error = nil;
	id object;
	
	//Set up to get the object you want to fetch
	NSFetchRequest * request = [[NSFetchRequest alloc] init];
	[request setEntity:[NSEntityDescription entityForName:entity
								   inManagedObjectContext:_managedObjectContext]];
	[request setPredicate:predicate];
	object = [[_managedObjectContext executeFetchRequest:request error:&error] lastObject];
	
	if (error) {
		[self displayValidationError:error];
	}
	
	return object;
}

- (NSUInteger)fetchNumberOfObjectsFromEntity:(NSString *)entity withPredicate:(NSPredicate *)predicate {
	
	NSError *error = nil;
	
	if (!_managedObjectContext) {
		_managedObjectContext = [self managedObjectContext];
	}
	
	//Set up to get the object you want to fetch
	NSFetchRequest * request = [[NSFetchRequest alloc] init];
	[request setEntity:[NSEntityDescription entityForName:entity
								   inManagedObjectContext:_managedObjectContext]];
	
	//Omit subentities. Default is YES (i.e. include subentities)
	[request setIncludesSubentities:NO];
	
	[request setPredicate:predicate];
	
	NSUInteger count = [_managedObjectContext countForFetchRequest:request error:&error];
	
	if (count == NSNotFound) {
		//Handle error
	}
	
	return count;
}

- (id)fetchObjectsFromEntity:(NSString *)entity withPredicate:(NSPredicate *)predicate withSortDescriptors:(NSArray *)sortDescriptors{
	
	NSError *error = nil;
	id objects;
	
	if (!_managedObjectContext) {
		_managedObjectContext = [self managedObjectContext];
	}
	
	//Set up to get the object you want to fetch
	NSFetchRequest * request = [[NSFetchRequest alloc] init];
	[request setEntity:[NSEntityDescription entityForName:entity
								   inManagedObjectContext:_managedObjectContext]];
	[request setPredicate:predicate];
	[request setSortDescriptors:sortDescriptors];
	
	objects = [_managedObjectContext executeFetchRequest:request error:&error];
	
	if (error) {
		[self displayValidationError:error];
	}
	
	return objects;
}

#pragma mark - vChess methods

- (BOOL)insertGameWithHeader:(NSDictionary*)header turns:(NSString*)pgn intoPackage:(NSString*)package {

	ChessGame *game = (ChessGame*)[NSEntityDescription insertNewObjectForEntityForName: @"ChessGame"
														 inManagedObjectContext: _managedObjectContext];
	game.package = package;
	game.event = [header valueForKey:@"Event"];
	game.site = [header valueForKey:@"Site"];
	game.date = [header valueForKey:@"Date"];
	game.round = [header valueForKey:@"Round"];
	game.white = [header valueForKey:@"White"];
	game.black = [header valueForKey:@"Black"];
	game.result = [header valueForKey:@"Result"];
	game.eco = [header valueForKey:@"ECO"];
	game.turns = pgn;
	
	if (![self.userPackages containsObject:package]) {
		[self.userPackages addObject:package];
	}
	return [self saveContext];
}

- (void)removePackage:(NSString*)package {
	
	NSString *stringForPredicate = @"(package == %@)";
	NSPredicate *predicate = [NSPredicate predicateWithFormat:stringForPredicate, package];
	NSArray *objects = [self fetchObjectsFromEntity:@"ChessGame" withPredicate:predicate withSortDescriptors:nil];
	for (NSManagedObject * object in objects) {
		[_managedObjectContext deleteObject:object];
	}
	[self saveContext];
	[self.userPackages removeObject:package];
}

- (NSArray*)ecoInPackage:(NSString*)package {
	
	NSString *stringForPredicate = @"(package == %@)";
	NSPredicate *predicate = [NSPredicate predicateWithFormat:stringForPredicate, package];
	NSArray *packageArray = [self fetchObjectsFromEntity:@"ChessGame" withPredicate:predicate withSortDescriptors:nil];
	NSArray *ecoArray = [packageArray valueForKeyPath:@"@distinctUnionOfObjects.eco"];
	return [ecoArray sortedArrayUsingSelector:@selector(localizedCaseInsensitiveCompare:)];
}

- (NSArray*)gamesWithEco:(NSString*)eco inPackage:(NSString*)package {
	
    NSSortDescriptor *firstDescriptor = [[NSSortDescriptor alloc] initWithKey:@"date" ascending:YES];
	NSArray *sortDescriptors = [[NSArray alloc] initWithObjects:firstDescriptor, nil];
	NSString *stringForPredicate = @"(package == %@ AND eco == %@)";
	NSPredicate *predicate = [NSPredicate predicateWithFormat:stringForPredicate, package, eco];
	return [self fetchObjectsFromEntity:@"ChessGame" withPredicate:predicate withSortDescriptors:sortDescriptors];
}

- (NSArray*)gamesInPackage:(NSString*)package {
	
    NSSortDescriptor *firstDescriptor = [[NSSortDescriptor alloc] initWithKey:@"date" ascending:YES];
	NSArray *sortDescriptors = [[NSArray alloc] initWithObjects:firstDescriptor, nil];
	NSString *stringForPredicate = @"(package == %@)";
	NSPredicate *predicate = [NSPredicate predicateWithFormat:stringForPredicate, package];
	return [self fetchObjectsFromEntity:@"ChessGame" withPredicate:predicate withSortDescriptors:sortDescriptors];
}

@end
