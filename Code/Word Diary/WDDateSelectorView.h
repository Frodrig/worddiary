//
//  WDDateSelectorView.h
//  Word Diary
//
//  Created by Fernando Rodríguez Martínez on 28/04/13.
//  Copyright (c) 2013 Fernando Rodríguez Martínez. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "WDDateSelectorViewDataSource.h"
#import "WDDateSelectorViewDelegate.h"

@interface WDDateSelectorView : UIView

@property (nonatomic, weak) id<WDDateSelectorViewDataSource> dataSource;
@property (nonatomic, weak) id<WDDateSelectorViewDelegate>   delegate;

@end
