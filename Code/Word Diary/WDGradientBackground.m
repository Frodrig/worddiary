//
//  WDGradientBackground.m
//  Word Diary
//
//  Created by Fernando Rodríguez Martínez on 25/03/13.
//  Copyright (c) 2013 Fernando Rodríguez Martínez. All rights reserved.
//

#import "WDGradientBackground.h"
#import <QuartzCore/QuartzCore.h>

@interface WDGradientBackground()

@property(nonatomic, strong) CAGradientLayer *gradientLayer;

- (void)configureLayerWithColorIndex:(NSUInteger)index;

@end

@implementation WDGradientBackground

#pragma mark - Synthesize

@synthesize gradientLayer      = gradientLayer_;
@synthesize gradientColorIndex = gradientColorIndex_;

#pragma mark - Static

+(NSArray *)gradientColors
{
    NSArray *pickerColorArray = [NSArray arrayWithObjects:
                                 [UIColor colorWithRed:251.0/255.0 green:235.0/255.0 blue:0 alpha:1.0],
                                 [UIColor colorWithRed:222.0/255.0 green:255.0/255.0 blue:0 alpha:1.0],
                                 [UIColor colorWithRed:21/255.0 green:249.0/255.0 blue:2.0/255.0 alpha:1.0],
                                 [UIColor colorWithRed:0/255.0 green:160.0/255.0 blue:140.0/255.0 alpha:1.0],
                                 [UIColor colorWithRed:0/255.0 green:74.0/255.0 blue:255.0/255.0 alpha:1.0],
                                 [UIColor colorWithRed:132.0/255.0 green:8.0/255.0 blue:255.0/255.0 alpha:1.0],
                                 [UIColor colorWithRed:148.0/255.0 green:0/255.0 blue:156.0/255.0 alpha:1.0],
                                 [UIColor colorWithRed:191.0/255.0 green:2.0/255.0 blue:96.0/255.0 alpha:1.0],
                                 [UIColor colorWithRed:255.0/255.0 green:16.0/255.0 blue:0/255.0 alpha:1.0],
                                 [UIColor colorWithRed:255.0/255.0 green:90.0/255.0 blue:4.0/255.0 alpha:1.0],
                                 [UIColor colorWithRed:255.0/255.0 green:156.0/255.0 blue:0/255.0 alpha:1.0],
                                 [UIColor colorWithRed:255.0/255.0 green:198.0/255.0 blue:0/255.0 alpha:1.0],
                                 nil];
    
    return pickerColorArray;
}

#pragma mark - Init

- (id)initWithFrame:(CGRect)frame andGradientColorIndex:(NSUInteger)index
{
    self = [super initWithFrame:frame];
    if (self) {
        self.userInteractionEnabled = NO;
        [self configureLayerWithColorIndex:index];
    }
    
    return self;
}

// NOTA: FUNDAMENTAL sin este metodo nada funciona. Cuando al view ajusta su tamaño hay que tomar los layers y ajustar el frame
-(void)layoutSubviews
{
    // Llamado cuando el frame de la view cambia de tamaño o cuando se invoca setNeedsLayout
    // Aprovechamos para coger el layer donde esta el gradiente (el primero) y le cambiamos los bounds.
    CALayer *gradientLayer = [self.layer.sublayers objectAtIndex:0];
    gradientLayer.frame = self.bounds;
}

#pragma mark - Auxiliary

- (void)configureLayerWithColorIndex:(NSUInteger)index
{
    NSAssert([WDGradientBackground gradientColors].count > index, @"Indice a color incorrecto");
    NSAssert(index != NSNotFound, @"Indice a color incorrecto");

    NSArray *gradientColors = [WDGradientBackground gradientColors];
    UIColor *colorOne = (UIColor *)[gradientColors objectAtIndex:index];
    UIColor *colorTwo = [UIColor colorWithWhite:0.9 alpha:1.0];
    
    gradientLayer_ = [[CAGradientLayer alloc] init];
    gradientLayer_.colors = [NSArray arrayWithObjects:(id)colorOne.CGColor, (id)colorTwo.CGColor, nil];
    gradientLayer_.locations = [NSArray arrayWithObjects:[NSNumber numberWithFloat:0.0], [NSNumber numberWithFloat:1.0], nil];
    gradientLayer_.startPoint = CGPointMake(0.0, 0.0);
    gradientLayer_.endPoint = CGPointMake(1.0, 1.0);
    gradientLayer_.cornerRadius = 10.0;
    gradientLayer_.masksToBounds = YES;
    [self.layer addSublayer:gradientLayer_];
    
    CABasicAnimation *gradientAnimationColors = [CABasicAnimation animationWithKeyPath:@"colors"];
    gradientAnimationColors.fromValue = [NSArray arrayWithObjects:colorOne, colorTwo, nil];
    gradientAnimationColors.toValue = [NSArray arrayWithObjects:(id)colorTwo, (id)colorOne, nil];
    gradientAnimationColors.duration = 5;
    gradientAnimationColors.removedOnCompletion = NO;
    gradientAnimationColors.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionLinear];
    gradientAnimationColors.repeatCount = HUGE_VALF;
    gradientAnimationColors.autoreverses = YES;
    [gradientLayer_ addAnimation:gradientAnimationColors forKey:@"animateGradientChangeColors"];
    
    CAKeyframeAnimation *gradientAnimationStartPoint = [CAKeyframeAnimation animationWithKeyPath:@"startPoint"];
    [gradientAnimationStartPoint setValues:[NSArray arrayWithObjects:
                                            [NSValue valueWithCGPoint:CGPointMake(1.0, 0.0)],
                                            [NSValue valueWithCGPoint:CGPointMake(0.0, 0.0)],
                                            nil]];
    gradientAnimationStartPoint.duration = 5;
    gradientAnimationStartPoint.removedOnCompletion = NO;
    gradientAnimationStartPoint.calculationMode = kCAAnimationPaced;
    gradientAnimationStartPoint.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseOut];
    gradientAnimationStartPoint.repeatCount = HUGE_VALF;
    gradientAnimationStartPoint.autoreverses = YES;
    [gradientLayer_ addAnimation:gradientAnimationStartPoint forKey:@"animateGradientChangeStartPoints"];
    
    CAKeyframeAnimation *gradientAnimationEndPoint = [CAKeyframeAnimation animationWithKeyPath:@"endPoint"];
    [gradientAnimationEndPoint setValues:[NSArray arrayWithObjects:
                                          [NSValue valueWithCGPoint:CGPointMake(0.0, 1.0)],
                                          [NSValue valueWithCGPoint:CGPointMake(1.0, 1.0)],
                                          nil]];
    gradientAnimationEndPoint.duration = 5;
    gradientAnimationEndPoint.removedOnCompletion = NO;
    gradientAnimationEndPoint.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseOut];
    gradientAnimationEndPoint.calculationMode = kCAAnimationPaced;
    gradientAnimationEndPoint.repeatCount = HUGE_VALF;
    gradientAnimationEndPoint.autoreverses = YES;
    [gradientLayer_ addAnimation:gradientAnimationEndPoint forKey:@"animateGradientChangeEndPoints"];
}


@end
