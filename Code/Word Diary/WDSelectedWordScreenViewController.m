//
//  WDSelectedWordScreenViewController.m
//  Word Diary
//
//  Created by Fernando Rodríguez Martínez on 26/02/13.
//  Copyright (c) 2013 Fernando Rodríguez Martínez. All rights reserved.
//

#import "WDSelectedWordScreenViewController.h"
#import <QuartzCore/QuartzCore.h>
#import "WDEditingActualWordMenuViewController.h"
#import "WDFontMenuSelectorViewController.h"
#import "WDColorMenuSelectorViewController.h"
#import "WDWord.h"
#import "WDFont.h"
#import "WDWordDiary.h"
#import "WDUtils.h"
#import "WDBackgroundStore.h"

@interface WDSelectedWordScreenViewController ()

@property (nonatomic, weak)          WDWord                                     *selectedWord;
@property (weak, nonatomic) IBOutlet UITextField                                *selectedWordTextField;
@property (nonatomic, strong)        WDEditingActualWordMenuViewController      *editingActualWordViewController;
@property (nonatomic, strong)        WDFontMenuSelectorViewController           *fontMenuSelectorViewController;
@property (nonatomic, strong)        WDColorMenuSelectorViewController          *colorMenuSelectorViewController;
@property (nonatomic, strong)        UITapGestureRecognizer                     *tapGestureRecognizer;
@property (nonatomic, strong)        UISwipeGestureRecognizer                   *swipeGestureRecognizer;
@property (nonatomic)                CGPoint                                    originalCenterPositionOfSelectedWord;
@property (nonatomic, strong)        NSTimer                                    *animateStartEndPointOfGradientTimer;

- (void)      tapHandle:(UIGestureRecognizer *)gestureRecognizer;
- (void)      swipeHandle:(UIGestureRecognizer *)gestureRecognizer;

- (void)      keyboardWillShowNotification:(NSNotification *)notification;
- (void)      keyboardWillHideNotification:(NSNotification *)notification;

- (NSArray *) actualVisiblesViewMenus;

- (NSArray *) allBottomMenuViews;

- (void)      animateStartEndPointOfGradient:(NSTimer *)timer;
- (CGPoint)   incGradientLayerPoint:(CGPoint)point;

@end

@implementation WDSelectedWordScreenViewController

#pragma mark Synthesize

@synthesize selectedWord                         = selectedWord_;
@synthesize selectedWordTextField                = selectedWordTextField_;
@synthesize editingActualWordViewController      = editingActualWordViewController_;
@synthesize fontMenuSelectorViewController       = fontMenuSelectorViewController_;
@synthesize colorMenuSelectorViewController      = colorMenuSelectorViewController_;
@synthesize tapGestureRecognizer                 = tapGestureRecognizer_;
@synthesize swipeGestureRecognizer               = swipeGestureRecognizer_;
@synthesize animateStartEndPointOfGradientTimer  = animateStartEndPointOfGradientTimer_;

#pragma mark Init

- (id)initWithSelectedWord:(WDWord *)selectedWord
{
    self = [super initWithNibName:nil bundle:nil];
    if (self) {
        // Selected word
        selectedWord_ = selectedWord;
        
        // Otros controllers
        editingActualWordViewController_ = [[WDEditingActualWordMenuViewController alloc] initWithNibName:nil bundle:nil];
        fontMenuSelectorViewController_ = [[WDFontMenuSelectorViewController alloc] initWithNibName:nil bundle:nil];
        colorMenuSelectorViewController_ = [[WDColorMenuSelectorViewController alloc] initWithNibName:nil bundle:nil];
        
        // Gesture Recognizer
        tapGestureRecognizer_ = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapHandle:)];
        tapGestureRecognizer_.numberOfTapsRequired = 1;
        tapGestureRecognizer_.numberOfTouchesRequired = 1;
        [self.view addGestureRecognizer:tapGestureRecognizer_];
        
        swipeGestureRecognizer_ = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(swipeHandle:)];
        swipeGestureRecognizer_.direction = UISwipeGestureRecognizerDirectionRight;
        swipeGestureRecognizer_.numberOfTouchesRequired = 1;
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
    
    // Titulo
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    dateFormatter.timeStyle = NSDateFormatterNoStyle;
    dateFormatter.dateStyle = NSDateFormatterMediumStyle;
    dateFormatter.calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
    dateFormatter.locale = [NSLocale currentLocale];
    self.navigationItem.title = [dateFormatter stringFromDate:[NSDate dateWithTimeIntervalSince1970:self.selectedWord.timeInterval]];
    
    // Palabra seleccionada
    self.selectedWordTextField.text = self.selectedWord.word;
    self.selectedWordTextField.font = [UIFont fontWithName:self.selectedWord.font.family size:[WDUtils sizeOfWordForUI:UI_ALLWORDSSCREEN_TODAYWORD andFont:self.selectedWord.font]];
    
    // Gradiente
    CAGradientLayer *gradient = [CAGradientLayer layer];
    gradient.frame = self.view.frame;
    UIColor *colorOne = [UIColor colorWithRed:1.0 green:1.0 blue:0.05 alpha:1.0];
    UIColor *colorTwo = [UIColor colorWithRed:0.0 green:102.0/255.0 blue:1.0 alpha:1.0];
    gradient.colors = [NSArray arrayWithObjects:(id)colorOne.CGColor, (id)colorTwo.CGColor, nil];
    gradient.locations = [NSArray arrayWithObjects:[NSNumber numberWithFloat:0.0], [NSNumber numberWithFloat:1.0], nil];
    gradient.startPoint = CGPointMake(0.5, 0.0);
    gradient.endPoint = CGPointMake(0.0, 1.0);
    [self.view.layer insertSublayer:gradient atIndex:0];
    
    
    /*
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
    
    /*
    CABasicAnimation *gradientAnimationEndPoint = [CABasicAnimation animationWithKeyPath:@"endPoint"];
    gradientAnimationEndPoint.fromValue = [NSValue valueWithCGPoint:gradient.startPoint];
    gradientAnimationEndPoint.toValue = [NSValue valueWithCGPoint:CGPointMake(0.0, 0.0)];
    gradientAnimationEndPoint.duration = 20.0;
    gradientAnimationEndPoint.removedOnCompletion = NO;
    gradientAnimationEndPoint.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionLinear];
    [gradient addAnimation:gradientAnimationEndPoint forKey:@"animateGradientEndPoint"];
    gradient.endPoint = CGPointMake(0.0, 0.0);
    */
    
    // Vinculacion delegados
    self.editingActualWordViewController.delegate = self;
    self.fontMenuSelectorViewController.delegate = self;
    self.colorMenuSelectorViewController.delegate = self;
    self.selectedWordTextField.delegate = self;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    // Colocacion otros controllers
    // Nota: Esto no funciona en viewDidLoad hay que ponerlo aqui, en viewWillAppear
    NSArray *viewsOfControllers = [self allBottomMenuViews];
    for (UIView *viewIt in viewsOfControllers) {
        [self.view addSubview:viewIt];
        viewIt.frame = CGRectMake(0,
                                  self.view.frame.origin.y + self.view.frame.size.height - viewIt.frame.size.height,
                                  viewIt.frame.size.width,
                                  viewIt.frame.size.height);
        viewIt.hidden = YES;
    }
    
    // Otros
    self.originalCenterPositionOfSelectedWord = self.selectedWordTextField.center;
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
}

#pragma mark - Auxiliary

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
   // NSLog(@"point %f, %f", layer.startPoint.x, layer.startPoint.y);
    layer.endPoint = [self incGradientLayerPoint:layer.endPoint];
}


- (NSArray *)allBottomMenuViews
{
    NSArray *allViews = [NSArray arrayWithObjects:self.editingActualWordViewController.view, self.fontMenuSelectorViewController.view, self.colorMenuSelectorViewController.view, nil];
    
    return allViews;
}

- (NSArray *)actualVisiblesViewMenus
{
    NSMutableArray *actualVisiblesMenus = [NSMutableArray arrayWithCapacity:2];
    
    NSArray *allViews = [self allBottomMenuViews];
    for (UIView *viewIt in allViews) {
        if (!viewIt.hidden) {
            [actualVisiblesMenus addObject:viewIt];
        }
    }
    
    return actualVisiblesMenus.count > 0 ? [NSArray arrayWithArray:actualVisiblesMenus] : nil;
}

#pragma mark - Tap Gesture Recognizer

- (void)tapHandle:(UIGestureRecognizer *)gestureRecognizer
{
    NSArray *actualVisiblesMenus = [self actualVisiblesViewMenus];
    if (actualVisiblesMenus) {
        [actualVisiblesMenus enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            UIView *viewIt = obj;
            viewIt.hidden = YES;
        }];
    } else {
        //if ([self.selectedWord isTodayWord]) {
            self.editingActualWordViewController.view.hidden = !self.editingActualWordViewController.view.hidden;
        //}
    }
}

#pragma mark - Swipe Gesture Recognizer

- (void) swipeHandle:(UIGestureRecognizer *)gestureRecognizer
{
    [self dismissViewControllerAnimated:YES completion:nil];    
}

#pragma mark - UITextFieldDelegate

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    static const NSUInteger MAX_LENGHT = 45;
    
    // Se puede si:
    // - No sobrepasamos el limite de caracteres
    // - Estamos borrando
    // - No hemos generado un doble tap en el espacio que produce el valor ". "
    // - No es un espacio en blanco
    BOOL should = textField.text.length < MAX_LENGHT;
    if (!should) {
        should = range.length > 0 && [string isEqualToString:@""];
    }
    
    if (should) {
        should = ![string isEqualToString:@". "];
    }
    
    if (should) {
        should = ![string isEqualToString:@" "];
    }
    
    if (should) {
       // NSString *word = [textField.text stringByReplacingCharactersInRange:range withString:string];
    }
    
    return should;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [self.selectedWordTextField resignFirstResponder];
    self.selectedWordTextField.userInteractionEnabled = NO;
    
    self.selectedWord.word = self.selectedWordTextField.text;
        
    return YES;
}

#pragma mark KeyboardNotification

- (void) keyboardWillShowNotification:(NSNotification *)notification
{
    NSDictionary *userInfo = notification.userInfo;
    
    CGRect keyboardEndFrame;
    [[userInfo objectForKey:UIKeyboardFrameEndUserInfoKey] getValue:&keyboardEndFrame];
    
    CGRect transformedKeyboardEndFrame = [self.view convertRect:keyboardEndFrame toView:nil];
    CGRect rectToMoveSelectedWord = CGRectMake(self.view.frame.origin.x, self.view.frame.origin.y, self.view.frame.size.width, self.view.frame.origin.y + self.view.frame.size.height - transformedKeyboardEndFrame.size.height);
    
    NSNumber *keyboardAnimationDuration = [userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey];
    [UIView animateWithDuration:keyboardAnimationDuration.doubleValue animations:^{
        self.selectedWordTextField.center = CGPointMake(rectToMoveSelectedWord.size.width / 2, rectToMoveSelectedWord.size.height / 2);
    }];
}

- (void) keyboardWillHideNotification:(NSNotification *)notification
{
    NSDictionary *userInfo = notification.userInfo;
    
    NSNumber *keyboardAnimationDuration = [userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey];
    [UIView animateWithDuration:keyboardAnimationDuration.doubleValue animations:^{
        self.selectedWordTextField.center = self.originalCenterPositionOfSelectedWord;        
    }];
}

#pragma mark - WDEditingWorldMenuDelegate

- (void)keyboardOptionSelectedFromMenu:(id)menu
{
    self.selectedWordTextField.userInteractionEnabled = YES;
    [self.selectedWordTextField becomeFirstResponder];
    
    self.editingActualWordViewController.view.hidden = YES;
}

- (void)changeFontOptionSelectedFromMenu:(id)menu
{
    self.fontMenuSelectorViewController.view.hidden = NO;
    
    self.editingActualWordViewController.view.hidden = YES;
}

- (void)changeColorOptionSelectedFromMenu:(id)menu
{
    self.colorMenuSelectorViewController.view.hidden = NO;
    
    self.editingActualWordViewController.view.hidden = YES;
}

- (void)removeWordsOptionSelectedFromMenu:(id)menu
{
    self.editingActualWordViewController.view.hidden = YES;
    
    if ([self.selectedWord isTodayWord]) {
        self.selectedWord.word = @"";
        self.selectedWordTextField.text = self.selectedWord.word;
    } else {
        self.selectedWordTextField.text = @"";
        [[WDWordDiary sharedWordDiary] removeWord:self.selectedWord];
        [self dismissViewControllerAnimated:YES completion:nil];
    }
}

#pragma mark - WDFontMenuSelectorViewController

- (void)fontMenuSelector:(id)fontMenuObject selectedFont:(WDFont *)font
{
    self.selectedWord.font = font;
    self.selectedWordTextField.font = [UIFont fontWithName:self.selectedWord.font.family size:[WDUtils sizeOfWordForUI:UI_SELECTEDWORDSCREEN_WORD andFont:font]];
    
    self.fontMenuSelectorViewController.view.hidden = YES;
}

#pragma mark - WDColorMenuSelectorViewController

- (void)colorMenuSelector:(id)colorMenuObject selectedColor:(WDColor *)color
{
    
    self.colorMenuSelectorViewController.view.hidden = YES;
}


@end
