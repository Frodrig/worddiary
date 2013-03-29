//
//  WDTodayWordMenuView.h
//  Word Diary
//
//  Created by Fernando Rodríguez Martínez on 08/03/13.
//  Copyright (c) 2013 Fernando Rodríguez Martínez. All rights reserved.
//

#import <UIKit/UIKit.h>

@class WDTodayWordMenuViewPage1;
@class WDWordMenuAuxiliaryViewPage2;
@class WDPreviousDayWordMenuViewPage1;

@interface WDWordMenuView : UIView

@property (nonatomic, strong)        WDTodayWordMenuViewPage1        *page1TodayWord;
@property (nonatomic, strong)        WDPreviousDayWordMenuViewPage1  *page1PreviousDayWord;
@property (nonatomic, strong)        WDWordMenuAuxiliaryViewPage2    *page2;
@property (weak, nonatomic) IBOutlet UIScrollView                    *scrollView;
@property (weak, nonatomic) IBOutlet UIPageControl                   *pageView;

@end
