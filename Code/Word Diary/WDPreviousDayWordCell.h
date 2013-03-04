//
//  WDPreviousDayWordCell.h
//  Word Diary
//
//  Created by Fernando Rodríguez Martínez on 27/02/13.
//  Copyright (c) 2013 Fernando Rodríguez Martínez. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface WDPreviousDayWordCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UILabel *wordLabel;
@property (weak, nonatomic) IBOutlet UILabel *oneDateLabel;
@property (weak, nonatomic) IBOutlet UILabel *twoDateLabel;
@property (weak, nonatomic) IBOutlet UIView *dateViewContainer;

@end
