//
//  UIView+UIViewNibLoad.h
//  Word Diary
//
//  Created by Fernando Rodríguez Martínez on 08/03/13.
//  Copyright (c) 2013 Fernando Rodríguez Martínez. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIView (UIViewNibLoad)

// ToDo: NO se lee la mascara de autoresize
+ (UIView *) createFromNib;

@end
