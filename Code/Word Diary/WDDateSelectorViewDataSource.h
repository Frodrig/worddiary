//
//  WDDateSelectorViewDataSource.h
//  Word Diary
//
//  Created by Fernando Rodríguez Martínez on 28/04/13.
//  Copyright (c) 2013 Fernando Rodríguez Martínez. All rights reserved.
//

#import <Foundation/Foundation.h>

@class WDDateSelectorView;

@protocol WDDateSelectorViewDataSource <NSObject>

- (NSUInteger) numberOfYearsForSelectorView:(WDDateSelectorView *)selectorView;
- (NSUInteger) numberOfMonthsForSelectorView:(WDDateSelectorView *)selectorView;
- (NSUInteger) numberOfMonthsForYear:(NSUInteger)yearRow forSelectorView:(WDDateSelectorView *)selectorView;
- (BOOL) isMonth:(NSUInteger)monthRow inYear:(NSUInteger)yearRow availableForSelectionInfSelectorView:(WDDateSelectorView *)selectorView;

- (NSString *) yearTitleForRow:(NSUInteger)yearRow forSelectorView:(WDDateSelectorView *)selectorView;
- (NSString *) monthTitleForRow:(NSUInteger)monthRow forSelectorView:(WDDateSelectorView *)selectorView;

- (NSUInteger) actualMonthSelectedForSelectorView:(WDDateSelectorView *)selectorView;
- (NSUInteger) actualYearSelectedForSelectorView:(WDDateSelectorView *)selectorView;

@end
