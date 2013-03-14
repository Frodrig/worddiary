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
#import "WDTopInfoNavigationWordMenuView.h"
#import "WDWord.h"
#import "WDFont.h"
#import "WDWordDiary.h"
#import "WDUtils.h"
#import "WDBackgroundStore.h"
#import "WDBackground.h"
#import "WDWordRepresentationView.h"
#import "UIView+UIViewNibLoad.h"

@interface WDSelectedWordScreenViewController ()

@property (nonatomic, weak)          WDWord                               *selectedWord;
@property (nonatomic, strong)        WDSelectedWordEditMenuViewController *editMenuViewController;
@property (nonatomic, strong)        WDTopInfoNavigationWordMenuView      *topInfoNavigationWordMenuView;
//@property (weak, nonatomic) IBOutlet UITextField                          *selectedWordTextField;
@property (nonatomic, strong)        UITapGestureRecognizer               *tapGestureRecognizer;
@property (nonatomic, strong)        UISwipeGestureRecognizer             *swipeGestureRecognizer;
@property (nonatomic)                CGPoint                              originalCenterPositionOfSelectedWord;
@property (nonatomic, strong)        NSTimer                              *animateStartEndPointOfGradientTimer;
@property (nonatomic, weak)          NSNumber                             *idBackground;
@property (nonatomic)                BOOL                                 keyboardActive;
@property (nonatomic, strong)        WDWordRepresentationView             *wordDiaryRepresentation;

- (void)       tapHandle:(UIGestureRecognizer *)gestureRecognizer;
- (void)       swipeHandle:(UIGestureRecognizer *)gestureRecognizer;

- (void)       keyboardWillShowNotification:(NSNotification *)notification;
- (void)       keyboardWillHideNotification:(NSNotification *)notification;

- (void)       animateStartEndPointOfGradient:(NSTimer *)timer;
- (CGPoint)    incGradientLayerPoint:(CGPoint)point;

- (void)       backNavigationInfoButtonPressed:(UIButton *)sender;

- (NSString *) stringTopNavigationInfoMenuDateOfSelectedWord;

- (void)       configureColorScheme:(WDColorScheme)scheme;

- (void)       updateColorScheme:(WDColorScheme)scheme;

- (void)       wordDiaryRepresentationAnimateUpWithDuration:(CGFloat)duration;
- (void)       wordDiaryRepresentationAnimateDownWithDuration:(CGFloat)duration;

@end

@implementation WDSelectedWordScreenViewController

#pragma mark Synthesize

@synthesize selectedWord                         = selectedWord_;
@synthesize editMenuViewController               = editMenuViewController_;
//@synthesize selectedWordTextField                = selectedWordTextField_;
@synthesize tapGestureRecognizer                 = tapGestureRecognizer_;
@synthesize swipeGestureRecognizer               = swipeGestureRecognizer_;
@synthesize topInfoNavigationWordMenuView        = topInfoNavigationWordMenuView_;
@synthesize animateStartEndPointOfGradientTimer  = animateStartEndPointOfGradientTimer_;
@synthesize idBackground                         = idBackground_;
@synthesize delegate                             = delegate_;
@synthesize keyboardActive                       = keyboardActive_;
@synthesize wordDiaryRepresentation              = wordDiaryRepresentation_;

#pragma mark Init

- (id)initWithSelectedWord:(WDWord *)selectedWord
{
    self = [super initWithNibName:nil bundle:nil];
    if (self) {
        // Selected word
        selectedWord_ = selectedWord;
        
        // Views fuera del xib propio
        topInfoNavigationWordMenuView_ = (WDTopInfoNavigationWordMenuView *)[WDTopInfoNavigationWordMenuView createFromNib];
        wordDiaryRepresentation_ = (WDWordRepresentationView *)[WDWordRepresentationView createFromNib];

        // Gesture Recognizer
        tapGestureRecognizer_ = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapHandle:)];
        tapGestureRecognizer_.numberOfTapsRequired = 1;
        tapGestureRecognizer_.numberOfTouchesRequired = 1;
        tapGestureRecognizer_.delegate = self;
        [self.view addGestureRecognizer:tapGestureRecognizer_];
    
        swipeGestureRecognizer_ = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(swipeHandle:)];
        swipeGestureRecognizer_.direction = UISwipeGestureRecognizerDirectionRight;
        swipeGestureRecognizer_.numberOfTouchesRequired = 1;
        swipeGestureRecognizer_.delegate = self;
        [self.view addGestureRecognizer:swipeGestureRecognizer_];
        
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
    
    // Gradiente
    self.idBackground = [[WDBackgroundStore sharedStore] createBackgroundOfCategory:self.selectedWord.backgroundCategory forView:self.view];
    WDBackground *backgroundObj = [[WDBackgroundStore sharedStore] findBackgroundWithID:self.idBackground];
    
    // Otros controllers
    self.editMenuViewController = [[WDSelectedWordEditMenuViewController alloc] initWithSelectedWord:self.selectedWord andBackgroundColorScheme:backgroundObj.uiOverlayColorScheme];
    
    //  Constantes
    const CGFloat menusMargin = (self.view.frame.size.width - self.editMenuViewController.view.frame.size.width) / 2.0;

    // Menu de navegacion en el top
    // NOTA: Sera el unico menu que SIEMPRE estara visible
    self.topInfoNavigationWordMenuView.layer.cornerRadius = [WDUtils viewsCornerRadius];
    self.topInfoNavigationWordMenuView.infoNavigationLabel.text = [self stringTopNavigationInfoMenuDateOfSelectedWord];
    [self.topInfoNavigationWordMenuView.backNavigationButton addTarget:self action:@selector(backNavigationInfoButtonPressed:) forControlEvents:UIControlEventTouchDown];
    self.topInfoNavigationWordMenuView.frame = CGRectMake(menusMargin, menusMargin, self.topInfoNavigationWordMenuView.bounds.size.width, self.topInfoNavigationWordMenuView.bounds.size.height);
    [self configureColorScheme:backgroundObj.uiOverlayColorScheme];
    [self.view addSubview:self.topInfoNavigationWordMenuView];
    self.topInfoNavigationWordMenuView.hidden = YES;

    // Palabra
    self.wordDiaryRepresentation.dayDiaryLabel.text = [NSString stringWithFormat:NSLocalizedString(@"TAG_DIARYDAY_LABEL", @""), [[WDWordDiary sharedWordDiary] findIndexPositionForWord:self.selectedWord]];
    self.wordDiaryRepresentation.center = CGPointMake(self.view.bounds.size.width / 2.0, 140.0 + self.wordDiaryRepresentation.bounds.size.height / 2.0);
    self.wordDiaryRepresentation.delegate = self;
    self.wordDiaryRepresentation.dataSource = self;
    [self.view addSubview:self.wordDiaryRepresentation];
    
    /*
    self.selectedWordTextField.text = self.selectedWord.word;
    self.selectedWordTextField.font = [UIFont fontWithName:self.selectedWord.font.family size:[WDUtils sizeOfWordForUI:UI_SELECTEDWORDSCREEN_WORD andFont:self.selectedWord.font]];
    */
    
    // Menu de edicion
    [self.view addSubview:self.editMenuViewController.view];
    self.editMenuViewController.view.frame = CGRectMake(menusMargin,
                                                        self.view.frame.origin.y + self.view.frame.size.height - self.editMenuViewController.view.frame.size.height - menusMargin,
                                                        self.editMenuViewController.view.frame.size.width,
                                                        self.editMenuViewController.view.frame.size.height);
    self.editMenuViewController.view.hidden = YES;
    self.editMenuViewController.delegate = self;
    
    self.view.contentMode = UIViewContentModeCenter;
    //self.idBackground = [[WDBackgroundStore sharedStore] createBackgroundOfCategory:BC_BACKGROUNDIMAGE_TESTCREEN forView:self.view];

  
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

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    // Otros
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

- (void)updateColorScheme:(WDColorScheme)scheme
{
    [self configureColorScheme:scheme];
    [self.editMenuViewController updateColorScheme:scheme];
}

- (void)configureColorScheme:(WDColorScheme)scheme
{
    self.topInfoNavigationWordMenuView.backgroundColor = [WDUtils schemeBackgroundColor:scheme];
    [self.topInfoNavigationWordMenuView.backNavigationButton setImage:scheme == CS_LIGHT ? [UIImage imageNamed:@"39-back-light"] : [UIImage imageNamed:@"39-back-dark"] forState:UIControlStateNormal];
    [self.topInfoNavigationWordMenuView.backNavigationButton setImage:scheme == CS_DARK ? [UIImage imageNamed:@"39-back-light"] : [UIImage imageNamed:@"39-back-dark"] forState:UIControlStateHighlighted];
    self.topInfoNavigationWordMenuView.infoNavigationLabel.text = [self stringTopNavigationInfoMenuDateOfSelectedWord];
    self.topInfoNavigationWordMenuView.infoNavigationLabel.textColor = [WDUtils schemeTextColor:scheme];
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
        self.wordDiaryRepresentation.center = CGPointMake(self.wordDiaryRepresentation.center.x, newArea.origin.y + newArea.size.height / 2);
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
    if (touch.view == self.topInfoNavigationWordMenuView) {
        shouldReceive = self.topInfoNavigationWordMenuView.hidden;
    } else if (touch.view == self.editMenuViewController.view) {
        shouldReceive = self.editMenuViewController.view.hidden;
    }
    
    return shouldReceive;
}

#pragma mark - Tap Gesture Recognizer

- (void)tapHandle:(UIGestureRecognizer *)gestureRecognizer
{
    if (!self.keyboardActive) {
        self.editMenuViewController.view.hidden = !self.editMenuViewController.view.hidden;
        self.topInfoNavigationWordMenuView.hidden = self.editMenuViewController.view.hidden;
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
    //[self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark KeyboardNotification

- (void)keyboardWillShowNotification:(NSNotification *)notification
{
    self.keyboardActive = YES;
    //self.wordDiaryRepresentation.wordTextField.textAlignment = NSTextAlignmentLeft;
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

#pragma mark - TopInfoNavigationWordMenu Control Events
- (void)backNavigationInfoButtonPressed:(UIButton *)sender
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - WDSelectedWordEditMenuDelegate

- (void)writeSelectedWordOption
{   /*
    self.wordDiaryRepresentation.wordTextField.userInteractionEnabled = YES;
    [self.wordDiaryRepresentation.wordTextField becomeFirstResponder];
    */
    [self.wordDiaryRepresentation becomeFirstResponder];
    self.editMenuViewController.view.hidden = YES;
    self.topInfoNavigationWordMenuView.hidden = YES;
}

- (void)clearTodaySelectedWordOption
{
    self.selectedWord.word = @"";
    self.editMenuViewController.view.hidden = YES;
    self.topInfoNavigationWordMenuView.hidden = YES;
    
    [self.delegate selectedWordChanged];
}

- (void)cancelDeleteWordFromConfirmationMenu
{
    self.editMenuViewController.view.hidden = YES;
    self.topInfoNavigationWordMenuView.hidden = YES;
}

- (void)acceptDeleteWordFromConfirmationMenu
{
    [self.delegate selectedWordWillBeRemoved];
    
    self.editMenuViewController.view.hidden = YES;
    self.topInfoNavigationWordMenuView.hidden = YES;
   
    [self dismissViewControllerAnimated:YES completion:nil];
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

@end
