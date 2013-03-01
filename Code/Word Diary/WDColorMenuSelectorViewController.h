//
//  WDColorMenuSelectorViewController.h
//  Word Diary
//
//  Created by Fernando Rodríguez Martínez on 01/03/13.
//  Copyright (c) 2013 Fernando Rodríguez Martínez. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "WDColorMenuSelectorDelegate.h"

@interface WDColorMenuSelectorViewController : UIViewController

@property(nonatomic, weak) id<WDColorMenuSelectorDelegate> delegate;

@end
