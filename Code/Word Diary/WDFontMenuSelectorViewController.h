//
//  WDFontMenuSelectorViewController.h
//  Word Diary
//
//  Created by Fernando Rodríguez Martínez on 28/02/13.
//  Copyright (c) 2013 Fernando Rodríguez Martínez. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "WDFontMenuSelectorDelegate.h"

@interface WDFontMenuSelectorViewController : UIViewController

@property(nonatomic, weak) id<WDFontMenuSelectorDelegate> delegate;

@end
