//
//  WDWordCharacterCounterView.m
//  Word Diary
//
//  Created by Fernando Rodríguez Martínez on 18/04/13.
//  Copyright (c) 2013 Fernando Rodríguez Martínez. All rights reserved.
//

#import "WDWordCharacterCounterView.h"
#import "WDUtils.h"

@interface WDWordCharacterCounterView()

@property(nonatomic, strong) UILabel    *counterLabel;
@property(nonatomic, strong) UIColor    *counterDecoratorColor;

- (void)    updateCharactersCounter;

- (void)    WDSelectedWordInEditModeAddedNewCharacter:(NSNotification *)notification;
- (void)    WDSelectedWordInEditModeRemoveLastCharacter:(NSNotification *)notification;
- (void)    WDSelectedWordInEditModeRemoveAllCharacters:(NSNotification *)notification;
- (void)    WDSelectedWordWillEnterInEditMode:(NSNotification *)notification;

@end

@implementation WDWordCharacterCounterView

#pragma mark - Synthesize

@synthesize dataSource            = dataSource_;
@synthesize delegate              = delegate_;
@synthesize counterLabel          = counterLabel_;
@synthesize counterDecoratorColor = counterDecoratorColor_;

#pragma mark - Properties

-(UIColor *)counterDecoratorColor
{
    if (nil == counterDecoratorColor_) {
        counterDecoratorColor_ = [UIColor blackColor];
    }
    return counterDecoratorColor_;
}

#pragma mark - Init

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        self.opaque = NO;
        
        // Img de fondo
        
        // label
        counterLabel_ = [[UILabel alloc] initWithFrame:frame];
        NSString *strCounter = [WDUtils convertNumberToStringWithTwoDigitsMin:[NSNumber numberWithUnsignedInteger:[self.dataSource numberOfFreeCharactersOfEditWordForWordCharacterCounterView:self]]];
        NSDictionary *strParams = @{ NSFontAttributeName: [UIFont fontWithName:@"HelveticaNeue-UltraLight" size:52.0],
                                     NSForegroundColorAttributeName: [UIColor blackColor],
                                     NSKernAttributeName: [NSNumber numberWithInt:2.0]};
        counterLabel_.attributedText = [[NSAttributedString alloc] initWithString:strCounter attributes:strParams];
        counterLabel_.textAlignment = NSTextAlignmentCenter;
        counterLabel_.backgroundColor = [UIColor clearColor];
        [self addSubview:counterLabel_];
        
        // Notifications
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(WDSelectedWordWillEnterInEditMode:) name:@"WDSelectedWordWillEnterInEditMode" object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(WDSelectedWordInEditModeAddedNewCharacter:) name:@"WDSelectedWordInEditModeAddedNewCharacter" object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(WDSelectedWordInEditModeRemoveLastCharacter:) name:@"WDSelectedWordInEditModeRemoveLastCharacter" object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(WDSelectedWordInEditModerRemoveAllCharacters:) name:@"WDSelectedWordInEditModeRemoveAllCharacters" object:nil];
    }
    
    return self;
}

- (void) dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
    CGContextRef contextRef = UIGraphicsGetCurrentContext();
    
    CGContextSaveGState(contextRef);
    
    const CGFloat twoPiRadians = 6.28318531;
    const CGFloat decoratorRadius = 2.0;
    const CGFloat decoratorMargin = 20.0;
    CGContextSetAllowsAntialiasing(contextRef, true);
    CGContextSetLineWidth(contextRef, 1.0);
    CGFloat colorComponents[4] = {0.0, 0.0, 0.0, 1.0};
    [self.counterDecoratorColor getRed:&colorComponents[0] green:&colorComponents[1] blue:&colorComponents[2] alpha:&colorComponents[3]];
    CGContextSetFillColor(contextRef, colorComponents);
    CGContextAddArc(contextRef, decoratorMargin, self.bounds.size.height / 2, decoratorRadius, 0.0, twoPiRadians, 0);
    CGContextFillPath(contextRef);
    CGContextAddArc(contextRef, self.bounds.size.width - decoratorMargin, self.bounds.size.height / 2, decoratorRadius, 0.0, twoPiRadians, 0);
    CGContextFillPath(contextRef);
  
    CGContextRestoreGState(contextRef);
}

#pragma mark - Auxiliary

- (void) updateCharactersCounter
{
    NSUInteger freeCharacters = [self.dataSource numberOfFreeCharactersOfEditWordForWordCharacterCounterView:self];
    NSAttributedString *attributedString = [[NSMutableAttributedString alloc]
                                            initWithString:[WDUtils convertNumberToStringWithTwoDigitsMin:[NSNumber numberWithUnsignedInteger:freeCharacters]]
                                            attributes:[self.counterLabel.attributedText attributesAtIndex:0 effectiveRange:NULL]];
    self.counterLabel.attributedText = attributedString;
    
    if (freeCharacters == 0) {
        self.counterDecoratorColor = [UIColor redColor];
    } else {
        self.counterDecoratorColor = [UIColor blackColor];
    }
    
    [self.delegate redrawNeededForWordForWordCharacterCounterView:self];
}

#pragma mark - Notifications

- (void) WDSelectedWordWillEnterInEditMode:(NSNotification *)notification
{
    [self updateCharactersCounter];
}

- (void) WDSelectedWordInEditModeAddedNewCharacter:(NSNotification *)notification
{
    [self updateCharactersCounter];
}

- (void) WDSelectedWordInEditModeRemoveLastCharacter:(NSNotification *)notification
{
    [self updateCharactersCounter];
}

- (void) WDSelectedWordInEditModeRemoveAllCharacters:(NSNotification *)notification
{
    [self updateCharactersCounter];
}

@end
