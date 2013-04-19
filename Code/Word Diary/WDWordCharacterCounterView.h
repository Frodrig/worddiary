//
//  WDWordCharacterCounterView.h
//  Word Diary
//
//  Created by Fernando Rodríguez Martínez on 18/04/13.
//  Copyright (c) 2013 Fernando Rodríguez Martínez. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "WDWordCharacterCounterViewDataSource.h"
#import "WDWordCharacterCounterViewDelegate.h"

@interface WDWordCharacterCounterView : UIView

- (id) initWithFrame:(CGRect)frame andDataSource:(id<WDWordCharacterCounterViewDataSource>)dataSource;

@property(nonatomic, weak) id<WDWordCharacterCounterViewDataSource> dataSource;
@property(nonatomic, weak) id<WDWordCharacterCounterViewDelegate>   delegate;

@end
