//
//  WDSelectedWordScreenViewController.m
//  Word Diary
//
//  Created by Fernando Rodríguez Martínez on 26/02/13.
//  Copyright (c) 2013 Fernando Rodríguez Martínez. All rights reserved.
//

#import "WDSelectedWordScreenViewController.h"
#import <QuartzCore/QuartzCore.h>
#import "WDSelectedWordEditMenuViewController.h"
#import "WDWord.h"
#import "WDFont.h"
#import "WDWordDiary.h"
#import "WDUtils.h"
#import "WDBackgroundStore.h"
#import "WDBackground.h"
#import "WDWordRepresentationView.h"
#import "UIView+UIViewNibLoad.h"

const static CGFloat ANIMATION_TIME_CURSOR = 0.75;

@interface WDSelectedWordScreenViewController ()

@property (nonatomic, weak)          WDWord                               *selectedWord;
@property (nonatomic, strong)        WDSelectedWordEditMenuViewController *editMenuViewController;
@property (weak, nonatomic) IBOutlet UILabel                              *yearDateTopInfoLabel;
@property (weak, nonatomic) IBOutlet UILabel                              *dayMonthDateTopInfoLabel;
@property (nonatomic, strong)        UITapGestureRecognizer               *tapGestureRecognizer;
@property (nonatomic, strong)        UISwipeGestureRecognizer             *leftSwipeGesture;
@property (nonatomic, strong)        UISwipeGestureRecognizer             *rightSwipeGesture;
@property (nonatomic)                CGPoint                              originalCenterPositionOfSelectedWord;
@property (nonatomic, strong)        NSTimer                              *animateStartEndPointOfGradientTimer;
@property (nonatomic, weak)          NSNumber                             *idBackground;
@property (nonatomic)                BOOL                                 keyboardActive;
@property (nonatomic, strong)        WDWordRepresentationView             *wordDiaryRepresentation;
@property (nonatomic, strong)        NSTimer                              *cursorUpdateTimer;

- (void)       tapHandle:(UIGestureRecognizer *)gestureRecognizer;
- (void)       swipeHandle:(UIGestureRecognizer *)gestureRecognizer;

- (void)       keyboardWillShowNotification:(NSNotification *)notification;
- (void)       keyboardWillHideNotification:(NSNotification *)notification;

- (void)       animateStartEndPointOfGradient:(NSTimer *)timer;
- (CGPoint)    incGradientLayerPoint:(CGPoint)point;

- (NSString *) stringTopNavigationInfoMenuDateOfSelectedWord;

- (void)       configureColorScheme:(WDColorScheme)scheme;

- (void)       updateColorScheme:(WDColorScheme)scheme;

- (void)       wordDiaryRepresentationAnimateUpWithDuration:(CGFloat)duration;
- (void)       wordDiaryRepresentationAnimateDownWithDuration:(CGFloat)duration;

- (void)       setDateInfo;

- (void)       configureViewForSelectedWord;

- (void)       updateCursorAnimation:(NSTimer *)timer;

@end

@implementation WDSelectedWordScreenViewController

#pragma mark Synthesize

@synthesize selectedWord                         = selectedWord_;
@synthesize editMenuViewController               = editMenuViewController_;
@synthesize yearDateTopInfoLabel                 = yearDateTopInfoLabel_;
@synthesize dayMonthDateTopInfoLabel             = dayMonthDateTopInfoLabel_;
@synthesize tapGestureRecognizer                 = tapGestureRecognizer_;
@synthesize leftSwipeGesture                     = leftSwipeGesture_;
@synthesize rightSwipeGesture                    = rightSwipeGesture_;
@synthesize animateStartEndPointOfGradientTimer  = animateStartEndPointOfGradientTimer_;
@synthesize idBackground                         = idBackground_;
@synthesize delegate                             = delegate_;
@synthesize keyboardActive                       = keyboardActive_;
@synthesize wordDiaryRepresentation              = wordDiaryRepresentation_;
@synthesize cursorUpdateTimer                    = cursorUpdateTimer_;

#pragma mark Init

- (id)initWithSelectedWord:(WDWord *)selectedWord
{
    self = [super initWithNibName:nil bundle:nil];
    if (self) {
        // Selected word
        selectedWord_ = selectedWord;
        keyboardActive_ = NO;
        
        // Views fuera del xib propio
        wordDiaryRepresentation_ = (WDWordRepresentationView *)[WDWordRepresentationView createFromNib];

        // Gesture Recognizer
        tapGestureRecognizer_ = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapHandle:)];
        tapGestureRecognizer_.numberOfTapsRequired = 1;
        tapGestureRecognizer_.numberOfTouchesRequired = 1;
        tapGestureRecognizer_.delegate = self;
        [self.view addGestureRecognizer:tapGestureRecognizer_];
    
        rightSwipeGesture_ = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(swipeHandle:)];
        rightSwipeGesture_.direction = UISwipeGestureRecognizerDirectionRight;
        rightSwipeGesture_.numberOfTouchesRequired = 1;
        rightSwipeGesture_.delegate = self;
        [self.view addGestureRecognizer:rightSwipeGesture_];
        
        leftSwipeGesture_ = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(swipeHandle:)];
        leftSwipeGesture_.direction = UISwipeGestureRecognizerDirectionLeft;
        leftSwipeGesture_.numberOfTouchesRequired = 1;
        leftSwipeGesture_.delegate = self;
        [self.view addGestureRecognizer:leftSwipeGesture_];
        
        // Notificaciones keyboard
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShowNotification:) name:UIKeyboardWillShowNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHideNotification:) name:UIKeyboardWillHideNotification object:nil];
    }
    
    return self;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    return nil;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // Palabra
    self.wordDiaryRepresentation.center = CGPointMake(self.view.bounds.size.width / 2.0, self.view.bounds.size.height / 2.50);
    self.wordDiaryRepresentation.delegate = self;
    self.wordDiaryRepresentation.dataSource = self;
    [self.view addSubview:self.wordDiaryRepresentation];
    
    // Menu de edicion
    self.editMenuViewController = [[WDSelectedWordEditMenuViewController alloc] initWithSelectedWord:self.selectedWord];
    const CGFloat menusMargin = (self.view.frame.size.width - self.editMenuViewController.view.frame.size.width) / 2.0;
    [self.view addSubview:self.editMenuViewController.view];
    self.editMenuViewController.view.frame = CGRectMake(menusMargin,
                                                        self.view.frame.origin.y + self.view.frame.size.height - self.editMenuViewController.view.frame.size.height - menusMargin,
                                                        self.editMenuViewController.view.frame.size.width,
                                                        self.editMenuViewController.view.frame.size.height);
    self.editMenuViewController.view.hidden = YES;
    self.editMenuViewController.delegate = self;
    
    self.view.contentMode = UIViewContentModeCenter;
    
    [self configureViewForSelectedWord];
    
    self.cursorUpdateTimer = [NSTimer scheduledTimerWithTimeInterval:ANIMATION_TIME_CURSOR target:self selector:@selector(updateCursorAnimation:) userInfo:nil repeats:YES];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    self.originalCenterPositionOfSelectedWord = self.wordDiaryRepresentation.center;
}

- (void)viewDidAppear:(BOOL)animated
{
   // self.animateStartEndPointOfGradientTimer = [NSTimer scheduledTimerWithTimeInterval:0.3 target:self selector:@selector(animateStartEndPointOfGradient:) userInfo:nil repeats:YES];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [[WDBackgroundStore sharedStore] releaseBackgroundWithID:self.idBackground];
}

#pragma mark - Auxiliary

- (void)configureViewForSelectedWord
{
    
    // Gradiente
    [[WDBackgroundStore sharedStore] releaseBackgroundWithID:self.idBackground];
    self.idBackground = [[WDBackgroundStore sharedStore] createBackgroundOfCategory:self.selectedWord.backgroundCategory forView:self.view];    
    self.editMenuViewController.selectedWord = self.selectedWord;
    WDBackground *background = [[WDBackgroundStore sharedStore] findBackgroundWithID:self.idBackground];
    self.editMenuViewController.backgroundColorScheme = background.uiOverlayColorScheme;
    
    // Fecha
    [self setDateInfo];
    
    // Palabra
    self.wordDiaryRepresentation.dayDiaryLabel.text = [NSString stringWithFormat:NSLocalizedString(@"TAG_DIARYDAY_LABEL", @""), [[WDWordDiary sharedWordDiary] findIndexPositionForWord:self.selectedWord]];
    [self.wordDiaryRepresentation setNeedsDisplay];
    
    
    /*
     CAGradientLayer *gradient = [CAGradientLayer layer];
     gradient.frame = self.view.frame;
     UIColor *colorOne = [UIColor colorWithRed:1.0 green:1.0 blue:0.05 alpha:1.0];
     UIColor *colorTwo = [UIColor colorWithRed:0.0 green:102.0/255.0 blue:1.0 alpha:1.0];
     gradient.colors = [NSArray arrayWithObjects:(id)colorOne.CGColor, (id)colorTwo.CGColor, nil];
     gradient.locations = [NSArray arrayWithObjects:[NSNumber numberWithFloat:0.0], [NSNumber numberWithFloat:1.0], nil];
     gradient.startPoint = CGPointMake(0.5, 0.0);
     gradient.endPoint = CGPointMake(0.0, 1.0);
     [self.view.layer insertSublayer:gradient atIndex:0];
     */
    
    /*+++
     CABasicAnimation *gradientAnimation = [CABasicAnimation animationWithKeyPath:@"colors"];
     NSArray *animateGradientColors = [NSArray arrayWithObjects:(id)[UIColor colorWithRed:0.8 green:0.2 blue:0.2 alpha:1.0].CGColor, (id)[UIColor colorWithRed:0.3 green:0.5 blue:0.2 alpha:1.0].CGColor, nil];
     gradientAnimation.fromValue = gradient.colors;
     gradientAnimation.toValue = animateGradientColors;
     gradientAnimation.duration = 10.0;
     gradientAnimation.removedOnCompletion = NO;
     gradientAnimation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionLinear];
     [gradient addAnimation:gradientAnimation forKey:@"animateGradient"];
     gradient.colors = animateGradientColors;
     */
    
    /*
     CABasicAnimation *gradientAnimationStartPoint = [CABasicAnimation animationWithKeyPath:@"endPoint"];
     gradientAnimationStartPoint.fromValue = [NSValue valueWithCGPoint:gradient.endPoint];
     gradientAnimationStartPoint.toValue = [NSValue valueWithCGPoint:CGPointMake(1.0, 1.0)];
     gradientAnimationStartPoint.duration = 30.0;
     gradientAnimationStartPoint.removedOnCompletion = NO;
     gradientAnimationStartPoint.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
     gradientAnimationStartPoint.repeatCount = HUGE_VALF;
     gradientAnimationStartPoint.autoreverses = YES;
     [gradient addAnimation:gradientAnimationStartPoint forKey:@"animateGradientEndPoint"];
     //    gradient.startPoint = CGPointMake(1.0, 0.0);
     */
    
    /*++++
     CABasicAnimation *gradientAnimationEndPoint = [CABasicAnimation animationWithKeyPath:@"endPoint"];
     gradientAnimationEndPoint.fromValue = [NSValue valueWithCGPoint:gradient.startPoint];
     gradientAnimationEndPoint.toValue = [NSValue valueWithCGPoint:CGPointMake(0.0, 0.0)];
     gradientAnimationEndPoint.duration = 20.0;
     gradientAnimationEndPoint.removedOnCompletion = NO;
     gradientAnimationEndPoint.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionLinear];
     [gradient addAnimation:gradientAnimationEndPoint forKey:@"animateGradientEndPoint"];
     gradient.endPoint = CGPointMake(0.0, 0.0);
     */

}

- (void)updateCursorAnimation:(NSTimer *)timer
{
    [self.wordDiaryRepresentation updateCursorAnimation];
    [self.wordDiaryRepresentation setNeedsDisplay];
}

- (void)setDateInfo
{
    self.yearDateTopInfoLabel.text = [NSNumber numberWithUnsignedInteger:self.selectedWord.dateComponents.year].stringValue;
    if ([self.selectedWord isTodayWord]) {
        self.dayMonthDateTopInfoLabel.text = [NSString stringWithFormat:@"%@", NSLocalizedString(@"TAG_TODAYSECTION", @"")];
    } else {
        if ([WDUtils englishIsTheCurrentAppLanguage]) {
            self.dayMonthDateTopInfoLabel.text = [NSString stringWithFormat:@"%@, %d", [WDUtils abreviateMonthString:self.selectedWord.dateComponents.month], self.selectedWord.dateComponents.day];
        } else {
            self.dayMonthDateTopInfoLabel.text = [NSString stringWithFormat:@"%d, %@", self.selectedWord.dateComponents.day, [WDUtils abreviateMonthString:self.selectedWord.dateComponents.month]];
        }
    }
}

- (void)updateColorScheme:(WDColorScheme)scheme
{
    [self configureColorScheme:scheme];
    [self.editMenuViewController updateColorScheme:scheme];
}

- (void)configureColorScheme:(WDColorScheme)scheme
{
}

- (NSString *)stringTopNavigationInfoMenuDateOfSelectedWord
{
    NSString *retString = nil;
    if ([self.selectedWord isTodayWord]) {
        retString = NSLocalizedString(@"TAG_TODAYSECTION", @"");
    } else {
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        dateFormatter.timeStyle = NSDateFormatterNoStyle;
        dateFormatter.dateStyle = NSDateFormatterMediumStyle;
        dateFormatter.calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
        dateFormatter.locale = [NSLocale currentLocale];
        
        retString = [dateFormatter stringFromDate:[NSDate dateWithTimeIntervalSince1970:self.selectedWord.timeInterval]];
    }
    
    return retString;
}

- (CGPoint)incGradientLayerPoint:(CGPoint)point
{
    // Nos desplazamos por los margenes del rectangulo de valores
    const CGFloat incValue = 0.05;
    CGPoint retPoint = point;
    if ([WDUtils is:retPoint.y equalsTo:0.0]) {
        if ([WDUtils is:retPoint.x equalsTo:1.0]) {
            retPoint.y += incValue;
        } else {
            retPoint.x += incValue;
        }
    } else if ([WDUtils is:retPoint.y equalsTo:1.0]) {
        if (retPoint.x == 1.0) {
            retPoint.x -= incValue;
        } else if ([WDUtils is:retPoint.x equalsTo:0.0]) {
            retPoint.y -= incValue;
        } else {
            retPoint.x -= incValue;
        }
    } else {
        if ([WDUtils is:retPoint.x equalsTo:0.0]) {
            retPoint.y -= incValue;
        } else if ([WDUtils is:retPoint.x equalsTo:1.0]) {
            retPoint.y += incValue;
        }
    }
    
    return retPoint;
}

- (void)animateStartEndPointOfGradient:(NSTimer *)timer
{
    CAGradientLayer *layer = [self.view.layer.sublayers objectAtIndex:0];
    layer.startPoint = [self incGradientLayerPoint:layer.startPoint];
    layer.endPoint = [self incGradientLayerPoint:layer.endPoint];
}

- (void)wordDiaryRepresentationAnimateUpWithDuration:(CGFloat)duration
{
    CGRect newArea = CGRectMake(0.0, 0.0, self.view.frame.size.width,  self.editMenuViewController.view.frame.origin.y);
    [UIView animateWithDuration:duration animations:^{
        self.wordDiaryRepresentation.center = CGPointMake(self.wordDiaryRepresentation.center.x, (newArea.origin.y + newArea.size.height / 2) * 0.90);
        self.wordDiaryRepresentation.dayDiaryLabel.alpha = 0.25;
    }];
}

- (void)wordDiaryRepresentationAnimateDownWithDuration:(CGFloat)duration
{
    [UIView animateWithDuration:duration animations:^{
        self.wordDiaryRepresentation.center = self.originalCenterPositionOfSelectedWord;
        self.wordDiaryRepresentation.dayDiaryLabel.alpha = 1.0;
    }];
}

#pragma mark - UIGestureRecognizer

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch
{
    BOOL shouldReceive = YES;
    if (touch.view == self.editMenuViewController.view) {
        shouldReceive = self.editMenuViewController.view.hidden;
    }
    
    return shouldReceive;
}

#pragma mark - Tap Gesture Recognizer

- (void)tapHandle:(UIGestureRecognizer *)gestureRecognizer
{
    if (!self.keyboardActive) {
        self.editMenuViewController.view.hidden = !self.editMenuViewController.view.hidden;
        //self.topInfoNavigationWordMenuView.hidden = self.editMenuViewController.view.hidden;
        if (!self.editMenuViewController.view.hidden) {
            if ([self.selectedWord isTodayWord]) {
                [self.editMenuViewController showTodayWordMenuWithClearButtonEnabled:![self.selectedWord.word isEqualToString:@""]];
            } else {
                [self.editMenuViewController showPreviousWordMenu];
            }
            [self wordDiaryRepresentationAnimateUpWithDuration:0.25];
           
        } else {
            [self wordDiaryRepresentationAnimateDownWithDuration:0.25];
        }
    }
}

#pragma mark - Swipe Gesture Recognizer

- (void)swipeHandle:(UIGestureRecognizer *)gestureRecognizer
{
    if (self.editMenuViewController.view.hidden && !self.keyboardActive) {
        WDWord *newSelectedWord = nil;
        if (gestureRecognizer == self.leftSwipeGesture) {
            newSelectedWord = [[WDWordDiary sharedWordDiary] findPreviousWordOf:self.selectedWord];
        } else if (gestureRecognizer == self.rightSwipeGesture) {
            newSelectedWord = [[WDWordDiary sharedWordDiary] findNextWordOf:self.selectedWord];
        }
        
        if (newSelectedWord) {
            self.selectedWord = newSelectedWord;
            [self configureViewForSelectedWord];
        }
    }
}

#pragma mark KeyboardNotification

- (void)keyboardWillShowNotification:(NSNotification *)notification
{
    self.keyboardActive = YES;
}

- (void)keyboardWillHideNotification:(NSNotification *)notification
{
    self.keyboardActive = NO;
    
    NSDictionary *userInfo = notification.userInfo;
    
    NSNumber *keyboardAnimationDuration = [userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey];
    [self wordDiaryRepresentationAnimateDownWithDuration:keyboardAnimationDuration.floatValue];
    [UIView animateWithDuration:keyboardAnimationDuration.doubleValue animations:^{
        self.wordDiaryRepresentation.center = self.originalCenterPositionOfSelectedWord;
    }];
}

#pragma mark - WDSelectedWordEditMenuDelegate

- (void)writeSelectedWordOption
{
    [self.wordDiaryRepresentation becomeFirstResponder];
    self.editMenuViewController.view.hidden = YES;
}

- (void)clearTodaySelectedWordOption
{
    self.selectedWord.word = @"";
    self.editMenuViewController.view.hidden = YES;
    
    //[self.delegate selectedWordChanged];
}

- (void)cancelDeleteWordFromConfirmationMenu
{
    self.editMenuViewController.view.hidden = YES;
}

- (void)acceptDeleteWordFromConfirmationMenu
{
    //[self.delegate selectedWordWillBeRemoved];
    
    self.editMenuViewController.view.hidden = YES;
   
   // [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)changeToFontWithIndex:(NSUInteger)indexFont
{
    self.selectedWord.font = [[WDWordDiary sharedWordDiary].fonts objectAtIndex:indexFont];
    
    [self.wordDiaryRepresentation setNeedsDisplay];
    
    /*
    NSLog(@"Family %@", self.selectedWord.font.family);
    NSLog(@"PointSize %f", self.wordDiaryRepresentation.wordTextField.font.pointSize);
    NSLog(@"Acender %f", self.wordDiaryRepresentation.wordTextField.font.ascender);
    NSLog(@"Descender %f", self.wordDiaryRepresentation.wordTextField.font.descender);
    NSLog(@"Cap Height %f", self.wordDiaryRepresentation.wordTextField.font.capHeight);
    NSLog(@"Line Height %f", self.wordDiaryRepresentation.wordTextField.font.lineHeight);
    NSLog(@"xHeight %f", self.wordDiaryRepresentation.wordTextField.font.xHeight);
    NSLog(@"Leading %f", self.wordDiaryRepresentation.wordTextField.font.leading);
    NSLog(@"\\\\\\\\\\\\\\\\\\\\\\");
     */
}

- (void)changeToBackgroundCategory:(WDBackgroundCategory)category
{
    self.selectedWord.backgroundCategory = category;

    [[WDBackgroundStore sharedStore] releaseBackgroundWithID:self.idBackground];
    self.idBackground = [[WDBackgroundStore sharedStore] createBackgroundOfCategory:category forView:self.view];
    
    WDBackground *backgroundObj = [[WDBackgroundStore sharedStore] findBackgroundWithID:self.idBackground];
    [self updateColorScheme:backgroundObj.uiOverlayColorScheme];
}

#pragma mark - WDWordRepresentationViewDelegate

- (void)deleteBackwardsOnWordRepresentationView:(WDWordRepresentationView *)wordRepresentationView
{
    NSAssert(wordRepresentationView == self.wordDiaryRepresentation, @"objeto invalido");
    
    if (self.selectedWord.word.length > 0) {
        self.selectedWord.word = [self.selectedWord.word substringWithRange:NSMakeRange(0, self.selectedWord.word.length - 1)];
    }
    
    [self.wordDiaryRepresentation setNeedsDisplay];
}

- (void)wordRepresentationView:(WDWordRepresentationView *)wordRepresentationView insertText:(NSString *)text
{
    NSAssert(wordRepresentationView == self.wordDiaryRepresentation, @"objeto invalido");
    
    static const NSUInteger MAX_LENGHT = 45;
    
    if ([text isEqualToString:@"\n"]) {
        [self.wordDiaryRepresentation resignFirstResponder];
    } else {
        // Se puede si:
        // - No sobrepasamos el limite de caracteres
        // - Estamos borrando
        // - No hemos generado un doble tap en el espacio que produce el valor ". "
        // - No es un espacio en blanco
        BOOL should = text.length < MAX_LENGHT;
        if (!should) {
            should = ![text isEqualToString:@""];
        }
    
        if (should) {
            should = ![text isEqualToString:@". "];
        }
    
        if (should) {
            should = ![text isEqualToString:@" "];
        }
    
        if (should) {
            self.selectedWord.word = [self.selectedWord.word stringByAppendingString:text];
        }
    
        [self.wordDiaryRepresentation setNeedsDisplay];
    }
}

#pragma mark - WDWordRepresentationViewDataSource

- (NSString *)actualTextValueForWordRepresentationView:(WDWordRepresentationView *)wordRepresentationView
{
    NSAssert(wordRepresentationView == self.wordDiaryRepresentation, @"objeto invalido");
    
    return self.selectedWord.word;
}

- (NSString *)actualFamilyFontForWordRepresentationView:(WDWordRepresentationView *)wordRepresentationView
{
    NSAssert(wordRepresentationView == self.wordDiaryRepresentation, @"objeto invalido");
    
    return self.selectedWord.font.family;
}

- (BOOL)isInWritingModeFoWordRepresentationView:(WDWordRepresentationView *)wordRepresentationView
{
    NSAssert(wordRepresentationView == self.wordDiaryRepresentation, @"objeto invalido");
    
    return self.keyboardActive;
}


@end
