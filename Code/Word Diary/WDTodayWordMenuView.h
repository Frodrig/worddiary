//
//  WDTodayWordMenuView.h
//  Word Diary
//
//  Created by Fernando Rodríguez Martínez on 08/03/13.
//  Copyright (c) 2013 Fernando Rodríguez Martínez. All rights reserved.
//

#import <UIKit/UIKit.h>

@class WDTodayWordMenuViewPage1;
@class WDTodayWordMenuViewPage2;

@interface WDTodayWordMenuView : UIView

@property (nonatomic, strong)        WDTodayWordMenuViewPage1 *page1;
@property (nonatomic, strong)        WDTodayWordMenuViewPage2 *page2;
@property (weak, nonatomic) IBOutlet UIScrollView             *scrollView;
@property (weak, nonatomic) IBOutlet UIPageControl            *pageView;

@end
