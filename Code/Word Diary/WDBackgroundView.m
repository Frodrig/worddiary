//
//  WDBackgroundView.m
//  Word Diary
//
//  Created by Fernando Rodríguez Martínez on 07/03/13.
//  Copyright (c) 2013 Fernando Rodríguez Martínez. All rights reserved.
//

#import "WDBackgroundView.h"
#import <QuartzCore/QuartzCore.h>

@implementation WDBackgroundView

-(void)layoutSubviews
{
    // Llamado cuando el frame de la view cambia de tamaño o cuando se invoca setNeedsLayout
    // Aprovechamos para coger el layer donde esta el gradiente (el primero) y le cambiamos los bounds.
    CALayer *gradientLayer = [self.layer.sublayers objectAtIndex:0];
    gradientLayer.frame = self.bounds;
}

@end
