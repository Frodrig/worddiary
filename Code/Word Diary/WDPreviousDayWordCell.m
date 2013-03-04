//
//  WDPreviousDayWordCell.m
//  Word Diary
//
//  Created by Fernando Rodríguez Martínez on 27/02/13.
//  Copyright (c) 2013 Fernando Rodríguez Martínez. All rights reserved.
//

#import "WDPreviousDayWordCell.h"

@interface WDPreviousDayWordCell()

@end

@implementation WDPreviousDayWordCell

#pragma mark - Synthesize

@synthesize wordLabel         = wordLabel_;
@synthesize oneDateLabel      = oneDateLabel_;
@synthesize twoDateLabel      = twoDateLabel_;
@synthesize dateViewContainer = dateViewContainer_;

#pragma mark - Init

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
