//
//  WDAuxiliaryScreenHelpPanelView.h
//  Word Diary
//
//  Created by Fernando Rodríguez Martínez on 28/03/13.
//  Copyright (c) 2013 Fernando Rodríguez Martínez. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface WDAuxiliaryScreenHelpPanelView : UIView

@property (weak, nonatomic) IBOutlet UIScrollView *helpContainerScrollView;
@property (weak, nonatomic) IBOutlet UIPageControl *pageController;

@end
