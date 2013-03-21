//
//  WDWordTextView.h
//  Word Diary
//
//  Created by Fernando Rodríguez Martínez on 20/03/13.
//  Copyright (c) 2013 Fernando Rodríguez Martínez. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "WDWordTextViewDataSource.h"

@interface WDWordTextView : UIView

@property (nonatomic, weak) id<WDWordTextViewDataSource> dataSource;
@property (nonatomic, strong) NSString                   *familyFont;

@end
