//
//  MasterLoader.mm
//  vChess
//
//  Created by Sergey Seitov on 10/2/10.
//  Copyright 2010 V-Channel. All rights reserved.
//

#import "MasterLoader.h"
#import "StorageManager.h"
#import "ChessGame.h"
#include <string>
#import "GameCell.h"

@interface MasterLoader () <UIPickerViewDelegate, UIPickerViewDataSource, UITextFieldDelegate, UITableViewDataSource, UITableViewDelegate>

@property (strong, nonatomic) NSDictionary	*mEcoCodes;
@property (strong, nonatomic) NSDictionary	*mInfo;
@property (strong, nonatomic) NSMutableArray *mGames;

@property (weak, nonatomic) IBOutlet UITableView *gameTable;
@property (weak, nonatomic) IBOutlet UIPickerView *pickerView;
@property (weak, nonatomic) IBOutlet UITextField *searchBar;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *verticalSpace;

@end

@implementation MasterLoader

- (void)viewDidLoad
{
	[super viewDidLoad];
    
    UILabel* label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 200, 44)];
    label.textAlignment = NSTextAlignmentCenter;
    label.font = [UIFont fontWithName:@"HelveticaNeue-CondensedBold" size:15];
    label.text = _mPackageName;
    label.textColor = [UIColor whiteColor];
    self.navigationItem.titleView = label;
    
	_mEcoCodes = [[NSDictionary alloc] initWithContentsOfURL:[[NSBundle mainBundle] URLForResource:@"ecoCodes" withExtension:@"plist"]];
	_mGames = [[NSMutableArray alloc] init];
	[_pickerView reloadAllComponents];

	if (_mMasterEco && [_mMasterEco count] > 0) {
		NSString *eco = [_mMasterEco objectAtIndex:0];
		[_mGames removeAllObjects];
		[_mGames addObjectsFromArray:[[StorageManager sharedStorageManager] gamesWithEco:eco inPackage:_mPackageName]];
		[_gameTable reloadData];
	}
}

- (void)viewWillAppear:(BOOL)animated {
	
	[super viewWillAppear:animated];
	[_mGames removeAllObjects];
	if (_mMasterEco.count > 0) {
		NSString *eco = [_mMasterEco objectAtIndex:[_pickerView selectedRowInComponent:0]];
		[_mGames addObjectsFromArray:[[StorageManager sharedStorageManager] gamesWithEco:eco inPackage:_mPackageName]];
	} else {
		_pickerView.hidden = YES;
		_gameTable.frame = self.view.bounds;
		[_mGames addObjectsFromArray:[[StorageManager sharedStorageManager] gamesInPackage:_mPackageName]];
	}
	[_gameTable reloadData];
}

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)thePickerView {
	
	return 1;
}

- (NSInteger)pickerView:(UIPickerView *)thePickerView numberOfRowsInComponent:(NSInteger)component {
	
	return [_mMasterEco count];
}

- (CGFloat)pickerView:(UIPickerView *)pickerView rowHeightForComponent:(NSInteger)component {
    return 40;
}

- (UIView *)pickerView:(UIPickerView *)thePickerView viewForRow:(NSInteger)row forComponent:(NSInteger)component reusingView:(UIView *)view {
	
	if (view == nil) {
		view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 280, 32)];
	}
	NSString *code = [_mMasterEco objectAtIndex:row];
	NSString *val = [_mEcoCodes valueForKey:code];
	
	UILabel *label1 = (UILabel*)[view viewWithTag:1];
	if (label1 == nil) {
		label1 = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 40, 32)];
		label1.backgroundColor = [UIColor clearColor];
		label1.textColor = [UIColor colorWithRed:207.0/255.0 green:43.0/255.0 blue:64.0/255.0 alpha:1];
		label1.adjustsFontSizeToFitWidth = true;
		label1.font = [UIFont fontWithName:@"HelveticaNeue-CondensedBold" size:17];
		label1.textAlignment = NSTextAlignmentLeft;
		label1.tag = 1;
		label1.text = code;
		[view addSubview:label1];
	} else {
		label1.text = code;
	}
	
	if (val) {
		UILabel *label2 = (UILabel*)[view viewWithTag:2];
		if (label2 == nil) {
			label2 = [[UILabel alloc] initWithFrame:CGRectMake(40, 0, 240, 32)];
			label2.backgroundColor = [UIColor clearColor];
			label2.textColor = [UIColor colorWithRed:0 green:113.0/255.0 blue:165.0/255.0 alpha:1];
			label2.adjustsFontSizeToFitWidth = true;
			label2.font = [UIFont fontWithName:@"HelveticaNeue-CondensedBold" size:15];
			label2.textAlignment = NSTextAlignmentCenter;
			label2.numberOfLines = 2;
			label2.tag = 2;
			label2.text = val;
			[view addSubview:label2];
		} else {
			label2.text = val;
		}
	} else {
		UILabel *label2 = (UILabel*)[view viewWithTag:2];
		if (label2) {
			[label2 removeFromSuperview];
		}
	}
	
	return view;
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component {
	
	NSString *eco = [_mMasterEco objectAtIndex:row];
	[_mGames removeAllObjects];
	[_mGames addObjectsFromArray:[[StorageManager sharedStorageManager] gamesWithEco:eco inPackage:_mPackageName]];
	[_gameTable reloadData];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
	
	[_searchBar resignFirstResponder];
	std::string searchText([[textField.text uppercaseString] UTF8String]);
	NSInteger index = [_mMasterEco indexOfObjectPassingTest:^BOOL(id obj, NSUInteger idx, BOOL *stop){
		NSString *str = (NSString*)obj;
		std::string text([str UTF8String]);
		if (idx >= [_mMasterEco count]) {
			*stop = YES;
		} else {
			if (text >= searchText) {
				*stop = YES;
				return YES;
			}
		}
		return NO;
	}];
	if (index != NSNotFound) {
		textField.text = [_mMasterEco objectAtIndex:index];
		[_pickerView selectRow:index inComponent:0 animated:YES];
		[self pickerView:_pickerView didSelectRow:index inComponent:0];
	} else {
		textField.text = @"";
		[_pickerView selectRow:([_mMasterEco count] - 1) inComponent:0 animated:YES];
	}
	
	return YES;
}

#pragma mark Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
	
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	
	return [_mGames count];
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    GameCell *cell = [tableView dequeueReusableCellWithIdentifier:@"game" forIndexPath:indexPath];
    NSDictionary *game = [_mGames objectAtIndex:indexPath.row];
    cell.white.text = [game valueForKey:@"White"];
    cell.black.text = [game valueForKey:@"Black"];
    cell.result.text = [game valueForKey:@"Result"];
	return cell;
}

#pragma mark Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	
	self.mSelectedGame = [_mGames objectAtIndex:[indexPath indexAtPosition:1]];
    [self.navigationController performSegueWithIdentifier:@"unwindToMenu" sender:self];
}

@end
