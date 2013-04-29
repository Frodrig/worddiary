//
//  WDWordScreenCollectionViewController.h
//  Word Diary
//
//  Created by Fernando Rodríguez Martínez on 15/04/13.
//  Copyright (c) 2013 Fernando Rodríguez Martínez. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "WDWordRepresentationViewDataSource.h"
#import "WDWordCharacterCounterViewDataSource.h"
#import "WDWordCharacterCounterViewDelegate.h"
#import "WDAddWordDayViewControllerDelegate.h"
#import "WDDashBoardViewControllerDelegate.h"
#import "WDDashBoardViewControllerDataSource.h"

@interface WDWordScreenCollectionViewController : UICollectionViewController<WDWordRepresentationViewDataSource,
                                                                             WDWordCharacterCounterViewDataSource,
                                                                             WDWordCharacterCounterViewDelegate,
                                                                             WDAddWordDayViewControllerDelegate,
                                                                             WDDashBoardViewControllerDelegate,
                                                                             WDDashBoardViewControllerDataSource,
                                                                             UIKeyInput>

@end
