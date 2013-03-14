//
//  WDWordRepresentationView.h
//  Word Diary
//
//  Created by Fernando Rodríguez Martínez on 13/03/13.
//  Copyright (c) 2013 Fernando Rodríguez Martínez. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface WDWordRepresentationView : UIView

@property (weak, nonatomic) IBOutlet UITextField *wordTextField;
@property (weak, nonatomic) IBOutlet UILabel     *dayDiaryLabel;

@end
