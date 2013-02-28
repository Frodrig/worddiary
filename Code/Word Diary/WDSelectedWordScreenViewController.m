//
//  WDSelectedWordScreenViewController.m
//  Word Diary
//
//  Created by Fernando Rodríguez Martínez on 26/02/13.
//  Copyright (c) 2013 Fernando Rodríguez Martínez. All rights reserved.
//

#import "WDSelectedWordScreenViewController.h"
#import "WDEditingActualWordMenuViewController.h"
#import "WDWord.h"
#import "WDFont.h"
#import "WDColor.h"
#import "WDWordDiary.h"

@interface WDSelectedWordScreenViewController ()

@property (nonatomic, weak) WDWord                                  *selectedWord;
@property (weak, nonatomic) IBOutlet UITextField                    *selectedWordTextField;
@property (nonatomic, strong) WDEditingActualWordMenuViewController *editingActualWordViewController;
@property (nonatomic, strong) UITapGestureRecognizer                *tapGestureRecognizer;
@property (nonatomic) CGPoint                                       originalCenterPositionOfSelectedWord;

- (void)    tapHandle:(UIGestureRecognizer *)gestureRecognizer;

- (void)    keyboardWillShowNotification:(NSNotification *)notification;
- (void)    keyboardWillHideNotification:(NSNotification *)notification;

- (CGFloat) sizeInWordSelectedCellOfFamilyFont:(NSString *)familyFont;

@end

@implementation WDSelectedWordScreenViewController

#pragma mark Synthesize

@synthesize selectedWord                    = selectedWord_;
@synthesize selectedWordTextField           = selectedWordTextField_;
@synthesize editingActualWordViewController = editingActualWordViewController_;
@synthesize tapGestureRecognizer            = tapGestureRecognizer_;

#pragma mark Init

- (id)initWithSelectedWord:(WDWord *)selectedWord
{
    self = [super initWithNibName:nil bundle:nil];
    if (self) {
        // Selected word
        selectedWord_ = selectedWord;
        
        // Otros controllers
        editingActualWordViewController_ = [[WDEditingActualWordMenuViewController alloc] initWithNibName:nil bundle:nil];
        
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
    self.selectedWordTextField.font = [UIFont fontWithName:self.selectedWord.font.family size:[self sizeInWordSelectedCellOfFamilyFont:self.selectedWord.font.family]];
    
    // Vinculacion delegados
    self.editingActualWordViewController.delegate = self;
    self.selectedWordTextField.delegate = self;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    // Colocacion otros controllers
    // Nota: Esto no funciona en viewDidLoad hay que ponerlo aqui, en viewWillAppear
    [self.view addSubview:self.editingActualWordViewController.view];
    self.editingActualWordViewController.view.frame = CGRectMake(0,
                                                                 self.view.frame.origin.y + self.view.frame.size.height - self.editingActualWordViewController.view.frame.size.height - 0,
                                                                 self.editingActualWordViewController.view.frame.size.width,
                                                                 self.editingActualWordViewController.view.frame.size.height);
    self.editingActualWordViewController.view.hidden = YES;
    
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

- (CGFloat)sizeInWordSelectedCellOfFamilyFont:(NSString *)familyFont
{
    CGFloat sizeReturn = 0.0;
    if ([familyFont compare:@"AppleColorEmoji"] == NSOrderedSame) {
        sizeReturn = 82.0;
    } else if ([familyFont compare:@"Baskerville"] == NSOrderedSame) {
        sizeReturn = 82.0;
    } else if ([familyFont compare:@"BrandleyHandITCTT-Bold"] == NSOrderedSame) {
        sizeReturn = 82.0;
    } else if ([familyFont compare:@"Zapfino"] == NSOrderedSame) {
        sizeReturn = 82.0;
    } else if ([familyFont compare:@"HelveticaNue"] == NSOrderedSame) {
        sizeReturn = 82.0;
    }
    
    return sizeReturn;
}

#pragma mark - Tap Gesture Recognizer

- (void)tapHandle:(UIGestureRecognizer *)gestureRecognizer
{
    // ¿Palabra asociada al dia actual?
    if ([self.selectedWord isTodayWord]) {
        self.editingActualWordViewController.view.hidden = !self.editingActualWordViewController.view.hidden;
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
}

- (void)changeFontOptionSelectedFromMenu:(id)menu
{
    self.editingActualWordViewController.view.hidden = YES;
}

- (void)changeColorOptionSelectedFromMenu:(id)menu
{
    self.editingActualWordViewController.view.hidden = YES;
}

- (void)removeWordSOptionelectedFromMenu:(id)menu
{
    self.editingActualWordViewController.view.hidden = YES;    
}

@end
