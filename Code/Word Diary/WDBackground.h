//
//  WDBackground.h
//  Word Diary
//
//  Created by Fernando Rodríguez Martínez on 06/03/13.
//  Copyright (c) 2013 Fernando Rodríguez Martínez. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "WDBackgroundDefs.h"

@class CAGradientLayer;

@interface WDBackground : NSObject

@property (nonatomic)         WDBackgroundCategory category;
@property (nonatomic, strong) NSNumber             *idBackground;
@property (nonatomic, strong) UIView               *view;
@property (nonatomic, strong) CAGradientLayer      *gradientLayer;
@property (nonatomic, strong) UIImageView          *imageView;

@end
