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
#import "WDWordTextViewDataSource.h"

@interface WDWordRepresentationView : UIView<UIKeyInput, WDWordTextViewDataSource>

@property (weak, nonatomic) id<WDWordRepresentationViewDelegate>    delegate;
@property (weak, nonatomic) id<WDWordRepresentationViewDataSource>  dataSource;

- (void)familyFontOfSelectedWordChanged;

- (void)setWithCursor:(CGFloat)duration;
- (void)setWithoutCursor:(CGFloat)duration;

- (void)updateCursorAnimation;

@end
