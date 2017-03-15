//
//  GameCell.h
//  v-Chess
//
//  Created by Сергей Сейтов on 15.03.17.
//  Copyright © 2017 V-Channel. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface GameCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *black;
@property (weak, nonatomic) IBOutlet UILabel *result;

@property (weak, nonatomic) IBOutlet UILabel *white;
@end
