//
//  WDCollectionOptionsWordMenuViewDelegate.h
//  Word Diary
//
//  Created by Fernando Rodríguez Martínez on 11/03/13.
//  Copyright (c) 2013 Fernando Rodríguez Martínez. All rights reserved.
//

#import <Foundation/Foundation.h>

@class WDCollectionOptionsWordMenuView;

@protocol WDCollectionOptionsWordMenuViewDelegate <NSObject>

- (void)collectionOptionsMenuBackOptionSelected:(WDCollectionOptionsWordMenuView *)menu;
- (void)collectionOptionsMenu:(WDCollectionOptionsWordMenuView *)menu optionSelected:(NSUInteger)indexOption;

@end
