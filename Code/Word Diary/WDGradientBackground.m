//
//  WDGradientBackground.m
//  Word Diary
//
//  Created by Fernando Rodríguez Martínez on 25/03/13.
//  Copyright (c) 2013 Fernando Rodríguez Martínez. All rights reserved.
//

#import "WDGradientBackground.h"
#import "UIColor+hexColorCreation.h"
#import <QuartzCore/QuartzCore.h>

typedef enum {
    //BAS_HUE_HIGH,
    BAS_BRIGHTNESS_HIGH,
    //BAS_SATURATION_HIGH,
    //BAS_HUE_LOW,
    BAS_BRIGHTNESS_LOW,
    //BAS_SATURATION_LOW,
    BAS_STABLE,
} BackgroundAnimationState;

//static NSUInteger     MAX_BACKGROUND_ANIMATION_STATES          = 2;
//static NSTimeInterval ANIMATION_TIMER_TIME_TO_STABLE           = 5;
static NSTimeInterval ANIMATION_TIMER_TIME_TO_COLOR_TRANSITION = 2;
//static NSTimeInterval ANIMATION_TRANSITION_TIME                = 8;
static CGFloat        MODULATION_COLOR_HIGH                    = 1.45;
static CGFloat        MODULATION_COLOR_LOW                     = 0.65;

@interface WDGradientBackground()

@property(nonatomic, strong) UIView                   *noiseBackground;
@property(nonatomic, strong) CAGradientLayer          *gradientLayer;
@property(nonatomic, strong) NSTimer                  *animationTimer;
@property(nonatomic)         BackgroundAnimationState animationState;
@property(nonatomic)         CGFloat                  hueComponent;
@property(nonatomic)         CGFloat                  saturationComponent;
@property(nonatomic)         CGFloat                  brightnessComponent;
@property(nonatomic)         CGFloat                  alphaComponent;

+ (UIColor *)createColorWithRed:(NSUInteger)r green:(NSUInteger)g andBlue:(NSUInteger)b;

- (void)configureLayerWithColorIndex:(NSUInteger)index;

- (void)timerUpdateAnimation:(NSTimer *)timer;

@end

@implementation WDGradientBackground

#pragma mark - Synthesize

@synthesize noiseBackground     = noiseBackground_;
@synthesize gradientLayer       = gradientLayer_;
@synthesize gradientColorIndex  = gradientColorIndex_;
@synthesize animationTimer      = animationTimer_;
@synthesize animationState      = animationState_;
@synthesize hueComponent        = hueComponent_;
@synthesize saturationComponent = saturationComponent_;
@synthesize brightnessComponent = brightnessComponent_;
@synthesize alphaComponent      = alphaComponent_;

#pragma mark - Static

+(UIColor *)createColorWithRed:(NSUInteger)r green:(NSUInteger)g andBlue:(NSUInteger)b
{
    return [UIColor colorWithRed:((CGFloat)r)/255.0 green:((CGFloat)g)/255.0 blue:((CGFloat)b)/255.0 alpha:1.0];
}

+(NSArray *)gradientColors
{
    /*
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
    */
    

    
    NSArray *pickerColorArray = [NSArray arrayWithObjects:
                                 [WDGradientBackground createColorWithRed:221 green:229 andBlue:254],
                                 [WDGradientBackground createColorWithRed:255 green:203 andBlue:207],
                                 [WDGradientBackground createColorWithRed:249 green:252 andBlue:157],
                                 [WDGradientBackground createColorWithRed:186 green:243 andBlue:195],
                                 [WDGradientBackground createColorWithRed:217 green:178 andBlue:255],
                                 [WDGradientBackground createColorWithRed:255 green:216 andBlue:118],
                                 [WDGradientBackground createColorWithRed:246 green:239 andBlue:205],
                                 [WDGradientBackground createColorWithRed:214 green:219 andBlue:137],
                                 [WDGradientBackground createColorWithRed:184 green:152 andBlue:121],
                                 [WDGradientBackground createColorWithRed:173 green:128 andBlue:150],
                                 [WDGradientBackground createColorWithRed:212 green:167 andBlue:235],
                                 [WDGradientBackground createColorWithRed:139 green:234 andBlue:175],
                                 [WDGradientBackground createColorWithRed:219 green:191 andBlue:152],
                                 

                                 nil];
    
    return pickerColorArray;
}

+ (NSArray *)coupleGradientColors
{
    NSArray *pickerColorArray = [NSArray arrayWithObjects:
                                 [WDGradientBackground createColorWithRed:221 green:229 andBlue:254],
                                 [WDGradientBackground createColorWithRed:255-50 green:203-50 andBlue:207-50],
                                 [WDGradientBackground createColorWithRed:249-50 green:252-50 andBlue:157-50],
                                 [WDGradientBackground createColorWithRed:186-50 green:243-50 andBlue:195-50],
                                 [WDGradientBackground createColorWithRed:217-50 green:178-50 andBlue:255-50],
                                 nil];
    
    return pickerColorArray;
}

#pragma mark - Init

- (id)initWithFrame:(CGRect)frame andHexColor:(NSString *)hexColor
{
    self = [super initWithFrame:frame];
    if (self) {
        self.userInteractionEnabled = NO;
        animationState_ = BAS_STABLE;
        
        self.backgroundColor = [UIColor colorWithHexadecimalValue:hexColor withAlphaComponent:NO skipInitialCharacter:NO];
        [self.backgroundColor getHue:&hueComponent_ saturation:&saturationComponent_ brightness:&brightnessComponent_ alpha:&alphaComponent_];
        self.layer.cornerRadius = 15.0;
        //self.layer.borderWidth = 1.0;
        //self.layer.borderColor = [UIColor colorWithHexadecimalValue:@"0x000000" withAlphaComponent:NO skipInitialCharacter:NO].CGColor;
        self.layer.masksToBounds = YES;
        
        self.noiseBackground = [[UIView alloc] initWithFrame:self.frame];
        self.noiseBackground.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"background_noise01"]];
        [self addSubview:self.noiseBackground];
    }
    
    return self;

}


- (id)initWithFrame:(CGRect)frame andGradientColorIndex:(NSUInteger)index
{
    self = [super initWithFrame:frame];
    if (self) {
        self.userInteractionEnabled = NO;
        //[self configureLayerWithColorIndex:index];
        
        //animationTimer_ = [NSTimer scheduledTimerWithTimeInterval:ANIMATION_TIMER_TIME_TO_COLOR_TRANSITION target:self selector:@selector(timerUpdateAnimation:) userInfo:nil repeats:NO];
        animationState_ = BAS_STABLE;
        
        NSArray *gradientColors = [WDGradientBackground gradientColors];
        UIColor *colorOne = (UIColor *)[gradientColors objectAtIndex:index];
        [colorOne getHue:&hueComponent_ saturation:&saturationComponent_ brightness:&brightnessComponent_ alpha:&alphaComponent_];
        
        self.backgroundColor = colorOne;
        self.layer.cornerRadius = 10.0;
        self.layer.masksToBounds = YES;
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

#pragma mark - Timer

- (void)timerUpdateAnimation:(NSTimer *)timer
{
    static NSUInteger lastState = BAS_BRIGHTNESS_HIGH;
    BackgroundAnimationState newAnimationState = BAS_STABLE;
    if (self.animationState == BAS_STABLE) {
        if (lastState == BAS_BRIGHTNESS_HIGH) {
            lastState = BAS_BRIGHTNESS_LOW;
        } else {
            lastState = BAS_BRIGHTNESS_HIGH;
        }
        newAnimationState = lastState;
    }
    self.animationState = newAnimationState;
    
    
    UIColor *colorTransition = nil;
    NSTimeInterval colorTransitionTime = 2;
    NSTimeInterval nextAnimationTimerTime = ANIMATION_TIMER_TIME_TO_COLOR_TRANSITION;
    switch (self.animationState) {
        case BAS_BRIGHTNESS_HIGH:
            colorTransition = [UIColor colorWithHue:self.hueComponent saturation:self.saturationComponent brightness:self.brightnessComponent * MODULATION_COLOR_HIGH alpha:self.alphaComponent];
            break;
        /*
        case BAS_SATURATION_HIGH:
            colorTransition = [UIColor colorWithHue:self.hueComponent saturation:self.saturationComponent * MODULATION_COLOR_HIGH brightness:self.brightnessComponent alpha:self.alphaComponent];
            break;
            
        case BAS_HUE_HIGH:
            colorTransition = [UIColor colorWithHue:self.hueComponent * MODULATION_COLOR_HIGH saturation:self.saturationComponent brightness:self.brightnessComponent alpha:self.alphaComponent];
            break;
             */
        case BAS_STABLE:
            colorTransition = [UIColor colorWithHue:self.hueComponent saturation:self.saturationComponent brightness:self.brightnessComponent alpha:self.alphaComponent];
            break;
        case BAS_BRIGHTNESS_LOW:
            colorTransition = [UIColor colorWithHue:self.hueComponent saturation:self.saturationComponent brightness:self.brightnessComponent * MODULATION_COLOR_LOW alpha:self.alphaComponent];
            break;
            /*
        case BAS_HUE_LOW:
            colorTransition = [UIColor colorWithHue:self.hueComponent * MODULATION_COLOR_LOW saturation:self.saturationComponent brightness:self.brightnessComponent alpha:self.alphaComponent];
            break;
        case BAS_SATURATION_LOW:
            colorTransition = [UIColor colorWithHue:self.hueComponent saturation:self.saturationComponent * MODULATION_COLOR_LOW brightness:self.brightnessComponent alpha:self.alphaComponent];
            break;
             */
             
            
        default:
            NSAssert(0, @"tipo de animacion de background desconocida");
            break;
    };
    
    [UIView animateWithDuration:colorTransitionTime animations:^{
        self.backgroundColor = colorTransition;
    } completion:^(BOOL finished) {
        self.animationTimer = [NSTimer scheduledTimerWithTimeInterval:nextAnimationTimerTime target:self selector:@selector(timerUpdateAnimation:) userInfo:nil repeats:NO];
    }];
}

#pragma mark - Auxiliary

- (void)configureLayerWithColorIndex:(NSUInteger)index
{
    NSAssert([WDGradientBackground gradientColors].count > index, @"Indice a color incorrecto");
    NSAssert(index != NSNotFound, @"Indice a color incorrecto");

    NSArray *gradientColors = [WDGradientBackground gradientColors];
    UIColor *colorOne = (UIColor *)[gradientColors objectAtIndex:index];
    CGFloat hueColorOne;
    CGFloat saturationColorOne;
    CGFloat brightnessColorOne;
    CGFloat alphaColorOne;
    [colorOne getHue:&hueColorOne saturation:&saturationColorOne brightness:&brightnessColorOne alpha:&alphaColorOne];
    //UIColor *colorTwo = [UIColor colorWithHue:hueColorOne * 1 saturation:saturationColorOne * 1 brightness:brightnessColorOne * 0.8 alpha:alphaColorOne];
    self.layer.cornerRadius = 10.0;
    self.layer.masksToBounds = YES;
    
    //UIColor *colorTwo = [[WDGradientBackground coupleGradientColors] objectAtIndex:index];
   
    /*
    gradientLayer_ = [[CAGradientLayer alloc] init];
    gradientLayer_.colors = [NSArray arrayWithObjects:(id)colorOne.CGColor, (id)colorTwo.CGColor, nil];
    gradientLayer_.locations = [NSArray arrayWithObjects:[NSNumber numberWithFloat:0.0], [NSNumber numberWithFloat:1.0], nil];
    gradientLayer_.startPoint = CGPointMake(0.0, 0.0);
    gradientLayer_.endPoint = CGPointMake(1.0, 1.0);
    gradientLayer_.cornerRadius = 10.0;
    gradientLayer_.masksToBounds = YES;
    [self.layer addSublayer:gradientLayer_];
    */
    
    //CABasicAnimation *gradientAnimationColors = [CABasicAnimation animationWithKeyPath:@"colors"];
    CABasicAnimation *brightAnimation = [CABasicAnimation animationWithKeyPath:@"backgroundColor"];
    brightAnimation.fromValue = (id)colorOne.CGColor;
    brightAnimation.toValue = (id)[UIColor colorWithHue:hueColorOne * 1 saturation:saturationColorOne * 1 brightness:brightnessColorOne * 0.65 alpha:alphaColorOne].CGColor;
    brightAnimation.duration = 4;
    brightAnimation.removedOnCompletion = YES;
    brightAnimation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionLinear];
    brightAnimation.repeatCount = HUGE_VALF;
    brightAnimation.autoreverses = YES;
    
    [self.layer addAnimation:brightAnimation forKey:@"animationGroup"];
    
    
    /*
    CAKeyframeAnimation *gradientAnimationStartPoint = [CAKeyframeAnimation animationWithKeyPath:@"startPoint"];
    [gradientAnimationStartPoint setValues:[NSArray arrayWithObjects:
                                            [NSValue valueWithCGPoint:CGPointMake(0.0, 0.0)],
                                            [NSValue valueWithCGPoint:CGPointMake(0.5, 0.0)],
                                            [NSValue valueWithCGPoint:CGPointMake(1.0, 0.0)],
                                            [NSValue valueWithCGPoint:CGPointMake(1.0, 0.5)],
                                            [NSValue valueWithCGPoint:CGPointMake(1.0, 1.0)],
                                            nil]];
    gradientAnimationStartPoint.duration = 8;
    gradientAnimationStartPoint.removedOnCompletion = NO;
    gradientAnimationStartPoint.calculationMode = kCAAnimationPaced;
    gradientAnimationStartPoint.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionLinear];
    gradientAnimationStartPoint.repeatCount = HUGE_VALF;
    gradientAnimationStartPoint.autoreverses = YES;
    [gradientLayer_ addAnimation:gradientAnimationStartPoint forKey:@"animateGradientChangeStartPoints"];
    
    
    CAKeyframeAnimation *gradientAnimationEndPoint = [CAKeyframeAnimation animationWithKeyPath:@"endPoint"];
    [gradientAnimationEndPoint setValues:[NSArray arrayWithObjects:
                                          [NSValue valueWithCGPoint:CGPointMake(1.0, 1.0)],
                                          [NSValue valueWithCGPoint:CGPointMake(0.5, 1.0)],
                                          [NSValue valueWithCGPoint:CGPointMake(0.0, 1.0)],
                                          [NSValue valueWithCGPoint:CGPointMake(0.0, 0.5)],
                                          [NSValue valueWithCGPoint:CGPointMake(0.0, 0.0)],
                                          nil]];
    gradientAnimationEndPoint.duration = 8;
    gradientAnimationEndPoint.removedOnCompletion = NO;
    gradientAnimationEndPoint.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionLinear];
    gradientAnimationEndPoint.calculationMode = kCAAnimationPaced;
    gradientAnimationEndPoint.repeatCount = HUGE_VALF;
    gradientAnimationEndPoint.autoreverses = YES;
    [gradientLayer_ addAnimation:gradientAnimationEndPoint forKey:@"animateGradientChangeEndPoints"];
     */
     
}


@end
