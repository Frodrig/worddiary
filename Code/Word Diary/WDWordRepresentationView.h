//
//  WDWordRepresentationView.h
//  Word Diary
//
//  Created by Fernando Rodríguez Martínez on 13/03/13.
//  Copyright (c) 2013 Fernando Rodríguez Martínez. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "WDWordRepresentationViewDataSource.h"
#import "WDWordRepresentationViewDelegate.h"

@interface WDWordRepresentationView : UIView<UIKeyInput>

@property (weak, nonatomic) IBOutlet UILabel                        *dayDiaryLabel;
@property (weak, nonatomic) IBOutlet UILabel                        *dayOfTheWeekLabel;
@property (weak, nonatomic) id<WDWordRepresentationViewDelegate>    delegate;
@property (weak, nonatomic) id<WDWordRepresentationViewDataSource>  dataSource;

- (void)updateCursorAnimation;

@end
