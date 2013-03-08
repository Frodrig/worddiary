//
//  UIView+UIViewNibLoad.m
//  Word Diary
//
//  Created by Fernando Rodríguez Martínez on 08/03/13.
//  Copyright (c) 2013 Fernando Rodríguez Martínez. All rights reserved.
//

#import "UIView+UIViewNibLoad.h"

@implementation UIView (UIViewNibLoad)

+ (UIView *)createFromNib
{
    UIView *result = nil;
    
    NSArray *elements = [[NSBundle mainBundle] loadNibNamed:NSStringFromClass([self class]) owner:nil options:nil];
    for (id subviewIt in elements) {
        if ([subviewIt isKindOfClass:[self class]]) {
            result = subviewIt;
            break;
        }
    }
    
    return result;
}

@end
