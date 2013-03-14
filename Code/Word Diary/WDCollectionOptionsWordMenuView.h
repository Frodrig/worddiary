//
//  WDCollectionOptionsWordMenuView.h
//  Word Diary
//
//  Created by Fernando Rodríguez Martínez on 11/03/13.
//  Copyright (c) 2013 Fernando Rodríguez Martínez. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "WDCollectionOptionsWordMenuViewDelegate.h"

@interface WDCollectionOptionsWordMenuView : UIView

@property (nonatomic, weak) id<WDCollectionOptionsWordMenuViewDelegate> delegate;

@property (nonatomic, strong, readonly) NSArray  *buttonOptions;

- (id)initWithFrame:(CGRect)frame optionTitles:(NSArray *)titles fontsForTitles:(NSArray *)titlesFonts optionImages:(NSArray *)images visibleOptions:(CGFloat)numVisibleOptions andSelectedOption:(NSUInteger)selectedOption;
- (id)initWithFrame:(CGRect)frame notConfiguredOptions:(NSUInteger)numNotConfiguredOptions visibleOptions:(CGFloat)numVisibleOptions andSelectedOption:(NSUInteger)selectedOption;

@end
