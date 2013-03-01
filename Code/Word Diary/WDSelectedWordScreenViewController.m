//
//  WDSelectedWordScreenViewController.m
//  Word Diary
//
//  Created by Fernando Rodríguez Martínez on 26/02/13.
//  Copyright (c) 2013 Fernando Rodríguez Martínez. All rights reserved.
//

#import "WDSelectedWordScreenViewController.h"
#import "WDEditingActualWordMenuViewController.h"
#import "WDFontMenuSelectorViewController.h"
#import "WDColorMenuSelectorViewController.h"
#import "WDReturnToAllWordsScreenMenuViewController.h"
#import "WDWord.h"
#import "WDFont.h"
#import "WDColor.h"
#import "WDWordDiary.h"
#import "WDUtils.h"

@interface WDSelectedWordScreenViewController ()

@property (nonatomic, weak) WDWord                                       *selectedWord;
@property (weak, nonatomic) IBOutlet UITextField                         *selectedWordTextField;
@property (nonatomic, strong) WDEditingActualWordMenuViewController      *editingActualWordViewController;
@property (nonatomic, strong) WDFontMenuSelectorViewController           *fontMenuSelectorViewController;
@property (nonatomic, strong) WDColorMenuSelectorViewController          *colorMenuSelectorViewController;
@property (nonatomic, strong) WDReturnToAllWordsScreenMenuViewController *returnMenuViewController;
@property (nonatomic, strong) UITapGestureRecognizer                     *tapGestureRecognizer;
@property (nonatomic) CGPoint                                            originalCenterPositionOfSelectedWord;

- (void)      tapHandle:(UIGestureRecognizer *)gestureRecognizer;

- (void)      keyboardWillShowNotification:(NSNotification *)notification;
- (void)      keyboardWillHideNotification:(NSNotification *)notification;

- (NSArray *) actualVisiblesViewMenus;

- (NSArray *) allBottomMenuViews;

@end

@implementation WDSelectedWordScreenViewController

#pragma mark Synthesize

@synthesize selectedWord                    = selectedWord_;
@synthesize selectedWordTextField           = selectedWordTextField_;
@synthesize editingActualWordViewController = editingActualWordViewController_;
@synthesize fontMenuSelectorViewController  = fontMenuSelectorViewController_;
@synthesize colorMenuSelectorViewController = colorMenuSelectorViewController_;
@synthesize tapGestureRecognizer            = tapGestureRecognizer_;
@synthesize returnMenuViewController        = returnMenuViewController_;

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
        returnMenuViewController_ = [[WDReturnToAllWordsScreenMenuViewController alloc] initWithNibName:nil bundle:nil];
        
        // Gesture Recognizer
        tapGestureRecognizer_ = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapHandle:)];
        tapGestureRecognizer_.numberOfTapsRequired = 1;
        tapGestureRecognizer_.numberOfTouchesRequired = 1;
        [self.view addGestureRecognizer:tapGestureRecognizer_];
        
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
    self.view.backgroundColor = self.selectedWord.backgroundColor.colorObject;
    
    // Vinculacion delegados
    self.editingActualWordViewController.delegate = self;
    self.fontMenuSelectorViewController.delegate = self;
    self.colorMenuSelectorViewController.delegate = self;
    self.returnMenuViewController.delegate = self;
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
    
    [self.view addSubview:self.returnMenuViewController.view];
    self.returnMenuViewController.view.frame = CGRectMake(0.0, 0.0, self.returnMenuViewController.view.frame.size.width, self.returnMenuViewController.view.frame.size.height);
    self.returnMenuViewController.view.hidden = YES;
    
    // Otros
    self.originalCenterPositionOfSelectedWord = self.selectedWordTextField.center;
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
        if ([self.selectedWord isTodayWord]) {
            self.editingActualWordViewController.view.hidden = !self.editingActualWordViewController.view.hidden;
            self.returnMenuViewController.view.hidden = self.editingActualWordViewController.view.hidden;
        }
    }
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
    self.returnMenuViewController.view.hidden = YES;
}

- (void)changeFontOptionSelectedFromMenu:(id)menu
{
    self.fontMenuSelectorViewController.view.hidden = NO;
    
    self.editingActualWordViewController.view.hidden = YES;
    self.returnMenuViewController.view.hidden = YES;
}

- (void)changeColorOptionSelectedFromMenu:(id)menu
{
    self.colorMenuSelectorViewController.view.hidden = NO;
    
    self.editingActualWordViewController.view.hidden = YES;
    self.returnMenuViewController.view.hidden = YES;
}

- (void)removeWordsOptionSelectedFromMenu:(id)menu
{
    self.editingActualWordViewController.view.hidden = YES;
    self.returnMenuViewController.view.hidden = YES;
    
    if ([self.selectedWord isTodayWord]) {
        self.selectedWord.word = @"";
        self.selectedWordTextField.text = self.selectedWord.word;
    } else {
        self.selectedWordTextField.text = @"";
        [[WDWordDiary sharedWordDiary] removeWord:self.selectedWord];
        [self dismissViewControllerAnimated:YES completion:nil];
    }
}

- (void) exitToAllWordsScreenOptionSelected:(id)menu
{
    [self dismissViewControllerAnimated:YES completion:nil];
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
    self.selectedWord.backgroundColor = color;
    self.view.backgroundColor = color.colorObject;
    
    self.colorMenuSelectorViewController.view.hidden = YES;
}


@end
