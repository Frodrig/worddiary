//
//  WDSelectedWordEditMenuViewController.m
//  Word Diary
//
//  Created by Fernando Rodríguez Martínez on 08/03/13.
//  Copyright (c) 2013 Fernando Rodríguez Martínez. All rights reserved.
//

#import "WDSelectedWordEditMenuViewController.h"
#import <QuartzCore/QuartzCore.h>
#import "WDTodayWordMenuView.h"
#import "WDPreviousWordMenuView.h"
#import "WDConfirmWordActionMenuView.h"
#import "WDCollectionOptionsWordMenuView.h"
#import "UIView+UIViewNibLoad.h"
#import "WDWordDiary.h"
#import "WDFont.h"
#import "WDWord.h"
#import "WDUtils.h"
#import "WDGradientBackground.h"

static const NSUInteger TAG_CONTROL_TODAYWORDMENU_WRITE     = 10;
static const NSUInteger TAG_CONTROL_TODAYWORDMENU_FONT      = 15;
static const NSUInteger TAG_CONTROL_TODAYWORDMENU_COLOR     = 20;
static const NSUInteger TAG_CONTROL_TODAYWORDMENU_SETTINGS  = 25;
static const NSUInteger TAG_CONTROL_PREVIOUSWORDMENU_DELETE = 30;


@interface WDSelectedWordEditMenuViewController ()

@property (nonatomic, strong) WDTodayWordMenuView             *todayWordMenuView;
@property (nonatomic, strong) WDPreviousWordMenuView          *previousDayWordMenuView;
@property (nonatomic, strong) WDConfirmWordActionMenuView     *confirmWordActionMenuView;
@property (nonatomic, strong) WDCollectionOptionsWordMenuView *fontsMenuView;
@property (nonatomic, strong) WDCollectionOptionsWordMenuView *backgroundColorMenuView;

- (UIView *)  findActualMenuViewAdded;

- (void)      showMenuView:(UIView *)menuView inInmediateMode:(BOOL)inmediate;
- (void)      showDeletePreviousWordConfirmationMenu;
- (void)      showFontWordMenu;
- (void)      showBackgroundColorWordMenu;

- (NSArray *) createTitlesForFontMenu;
- (NSArray *) createFontFamiliesForFontMenu;

- (void)      backNavigationInfoButtonPressed:(UIButton *)sender;

- (void)      configureButton:(UIButton *)button withColorScheme:(WDColorScheme)scheme;

- (void)      configureColorSchemes;

@end

@implementation WDSelectedWordEditMenuViewController

#pragma mark - Synthesize

@synthesize todayWordMenuView            = todayWorldMenuView_;
@synthesize previousDayWordMenuView       = previousDayWordMenuView_;
@synthesize delegate                      = delegate_;
@synthesize confirmWordActionMenuView     = confirmWordActionMenuView_;
@synthesize fontsMenuView                 = fontsMenuView_;
@synthesize selectedWord                  = selectedWord_;
@synthesize backgroundColorScheme         = backgroundColorScheme_;
@synthesize backgroundColorMenuView       = backgroundColorMenuView_;

#pragma mark - 

#pragma mark - Init

- (id)initWithSelectedWord:(WDWord *)word
{
    self = [super initWithNibName:nil bundle:nil];
    if (self) {
        selectedWord_ = word;
        
        todayWorldMenuView_ = (WDTodayWordMenuView *)[WDTodayWordMenuView createFromNib];
        previousDayWordMenuView_ = (WDPreviousWordMenuView *)[WDPreviousWordMenuView createFromNib];
        confirmWordActionMenuView_ = (WDConfirmWordActionMenuView *)[WDConfirmWordActionMenuView createFromNib];
        fontsMenuView_ = [[WDCollectionOptionsWordMenuView alloc] initWithFrame:CGRectMake(0.0, 0.0, 300.0, 135.0) optionTitles:[self createTitlesForFontMenu] fontsForTitles:[self createFontFamiliesForFontMenu] optionImages:nil visibleOptions:3.5 andSelectedOption:[[WDWordDiary sharedWordDiary].fonts indexOfObject:selectedWord_.font]];
        backgroundColorMenuView_ = [[WDCollectionOptionsWordMenuView alloc] initWithFrame:fontsMenuView_.frame notConfiguredOptions:[WDGradientBackground gradientColors].count visibleOptions:3.5 andSelectedOption:0];
    }
    
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // Fondo
    self.view.layer.cornerRadius = [WDUtils viewsCornerRadius];
        
    // Menu principal para la palabra del dia de hoy
    self.todayWordMenuView.layer.cornerRadius = [WDUtils viewsCornerRadius];
    [self.todayWordMenuView.keyboardButton setTitle:NSLocalizedString(@"TAG_TODAYWORDMENU_WRITEOPTION", @"") forState:UIControlStateNormal];
    [self.todayWordMenuView.keyboardButton addTarget:self action:@selector(todayWordMenuOptionPressed:) forControlEvents:UIControlEventTouchUpInside];
    [self.todayWordMenuView.fontButton setTitle:NSLocalizedString(@"TAG_TODAYWORDMENU_FONTOPTION", @"") forState:UIControlStateNormal];
    [self.todayWordMenuView.fontButton addTarget:self action:@selector(todayWordMenuOptionPressed:) forControlEvents:UIControlEventTouchUpInside];
    [self.todayWordMenuView.backgroundColorButton setTitle:NSLocalizedString(@"TAG_TODAYWORDMENU_COLOROPTION", @"") forState:UIControlStateNormal];
    [self.todayWordMenuView.backgroundColorButton addTarget:self action:@selector(todayWordMenuOptionPressed:) forControlEvents:UIControlEventTouchUpInside];
    [self.todayWordMenuView.settingsButton setTitle:NSLocalizedString(@"TAG_TODAYWORDMENU_SETTINGSOPTION", @"") forState:UIControlStateNormal];
    [self.todayWordMenuView.settingsButton addTarget:self action:@selector(todayWordMenuOptionPressed:) forControlEvents:UIControlEventTouchUpInside];

    // Menu principal para palabras previas
    self.previousDayWordMenuView.layer.cornerRadius = [WDUtils viewsCornerRadius];
    [self.previousDayWordMenuView.deleteButton setTitle:NSLocalizedString(@"TAG_PREVIOUSWORDMENU_DELETEOPTION", @"") forState:UIControlStateNormal];
    [self configureButton:self.previousDayWordMenuView.deleteButton withColorScheme:self.backgroundColorScheme];
    [self.previousDayWordMenuView.deleteButton addTarget:self action:@selector(previousDayWordMenuOptionPressed:) forControlEvents:UIControlEventTouchUpInside];
    
    // Menu de confirmacion
    self.confirmWordActionMenuView.layer.cornerRadius = [WDUtils viewsCornerRadius];
    self.confirmWordActionMenuView.descriptionLabel.text = NSLocalizedString(@"TAG_CONFIRMACTIONMENU_DESCRIPTION", @"");
    [self.confirmWordActionMenuView.cancelButton setTitle:NSLocalizedString(@"TAG_CONFIRMACTIONMENU_CANCEL", @"") forState:UIControlStateNormal];
    [self.confirmWordActionMenuView.cancelButton addTarget:self action:@selector(confirmWordActionCancelPressed:) forControlEvents:UIControlEventTouchUpInside];
    [self.confirmWordActionMenuView.yesButton setTitle:NSLocalizedString(@"TAG_CONFIRMACTIONMENU_YES", @"") forState:UIControlStateNormal];
    [self.confirmWordActionMenuView.yesButton addTarget:self action:@selector(confirmWordActionAcceptPressed:) forControlEvents:UIControlEventTouchUpInside];
    
    // Menu de fuentes
    self.fontsMenuView.layer.cornerRadius = [WDUtils viewsCornerRadius];
    self.fontsMenuView.delegate = self;
    
    // Menu de colores
    NSArray *pickerColorArray = [WDGradientBackground gradientColors];
    NSArray *backgroundColorsOptions = self.backgroundColorMenuView.buttonOptions;
    for (NSUInteger optionIndex = 0; optionIndex < backgroundColorsOptions.count; ++optionIndex) {
        UIButton *buttonOption = [backgroundColorsOptions objectAtIndex:optionIndex];
        UIColor *colorValue = [pickerColorArray objectAtIndex:optionIndex];
        buttonOption.backgroundColor = colorValue;
    }
    self.backgroundColorMenuView.layer.cornerRadius = [WDUtils viewsCornerRadius];
    
    // Esquemas de color
    [self configureColorSchemes];
    
    self.backgroundColorMenuView.delegate = self;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Metodos auxiliares

- (void)configureColorSchemes
{    
    // Fondo
    self.view.backgroundColor = [WDUtils schemeBackgroundColor:self.backgroundColorScheme];
    
    // Menu principal para la palabra del dia de hoy
    self.todayWordMenuView.backgroundColor = [self.view.backgroundColor copy];
    
    [self configureButton:self.todayWordMenuView.keyboardButton withColorScheme:self.backgroundColorScheme];
    [self configureButton:self.todayWordMenuView.fontButton withColorScheme:self.backgroundColorScheme];
    [self configureButton:self.todayWordMenuView.backgroundColorButton withColorScheme:self.backgroundColorScheme];
    [self configureButton:self.todayWordMenuView.settingsButton withColorScheme:self.backgroundColorScheme];
    
    // Menu principal para palabras previas
    self.previousDayWordMenuView.backgroundColor = [self.view.backgroundColor copy];
    [self configureButton:self.previousDayWordMenuView.deleteButton withColorScheme:self.backgroundColorScheme];
    
    // Menu de confirmacion
    self.confirmWordActionMenuView.backgroundColor = [self.view.backgroundColor copy];
    self.confirmWordActionMenuView.descriptionLabel.textColor = [WDUtils schemeTextColor:self.backgroundColorScheme];
    [self configureButton:self.confirmWordActionMenuView.cancelButton withColorScheme:self.backgroundColorScheme];
    [self configureButton:self.confirmWordActionMenuView.yesButton withColorScheme:self.backgroundColorScheme];
    
    // Menu de fuentes
    self.fontsMenuView.backgroundColor = [self.view.backgroundColor copy];
    
    // Menu de colores
    self.backgroundColorMenuView.backgroundColor = [self.view.backgroundColor copy];
}

- (void)configureButton:(UIButton *)button withColorScheme:(WDColorScheme)scheme
{
    [button setTitleColor:[WDUtils schemeTextColor:scheme] forState:UIControlStateNormal];
    [button setTitleColor:[WDUtils schemeTextColor:scheme] forState:UIControlStateHighlighted];
}

- (UIView *)findActualMenuViewAdded
{
    UIView *menu = nil;
    NSSet *menus = [NSSet setWithObjects:self.todayWordMenuView, self.previousDayWordMenuView, self.fontsMenuView, self.backgroundColorMenuView, self.confirmWordActionMenuView, nil];
    for (UIView *viewIt in menus) {
        if (viewIt.superview == self.view) {
            menu = viewIt;
            break;
        }
    }
    
    return menu;
}

- (void)hideMenu
{
    [self showMenuView:nil inInmediateMode:NO];
}

- (void)hideMenuInmediate
{
    [self showMenuView:nil inInmediateMode:YES];
}

- (void)showMenuView:(UIView *)menuView inInmediateMode:(BOOL)inmediate
{
    UIView *menuToRemove = [self findActualMenuViewAdded];
    if (menuToRemove == menuView) {
        menuToRemove = nil;
    }
    
    if (nil == menuView) {
        [UIView animateWithDuration:inmediate ? 0.0 : 0.5 animations:^{
            self.view.alpha = 0.0;
        } completion:^(BOOL finished) {
            self.view.hidden = YES;
            self.view.alpha = 1.0;
            [menuToRemove removeFromSuperview];
            [self.delegate menuDidHide];
        }];
    } else {
        if (menuToRemove == nil && (menuView == self.todayWordMenuView || menuView == self.previousDayWordMenuView)) {
            [menuToRemove removeFromSuperview];
            self.view.alpha = 0.0;
            self.view.hidden = NO;
            [self.view addSubview:menuView];
            [UIView animateWithDuration:inmediate ? 0.0 : 0.5 animations:^{
                self.view.alpha = 1.0;
            }];
        } else {
            BOOL menuToShowIsNext = menuView != self.todayWordMenuView && menuView != self.previousDayWordMenuView;
            [self.view addSubview:menuView];
            CGPoint originalCenter = menuView.center;
            // TODO: Saber si menuView es un menu a la izquierda o derecha de que habia antes. Por ahora suponemos que esta a la derecha
            // Se podrían usar tags para ordenarlos.
            menuView.center = CGPointMake(menuToShowIsNext ? 3.0 * menuView.center.x : -1 * menuView.center.x, originalCenter.y);
            
            [UIView animateWithDuration:inmediate ? 0.0 : 0.75 animations:^{
                menuToRemove.alpha = 0.0;
                menuView.center = originalCenter;
            } completion:^(BOOL finished) {
                [menuToRemove removeFromSuperview];
                menuToRemove.alpha = 1.0;
            }];
        }
    }
}

- (NSArray *)createTitlesForFontMenu
{
    NSArray *fonts = [WDWordDiary sharedWordDiary].fonts;
    NSMutableArray *titles = [NSMutableArray arrayWithCapacity:fonts.count];
    for (NSString *fontFamily in fonts) {
        [titles addObject:@"T"];
    }
    
    return [NSArray arrayWithArray:titles];
}

- (NSArray *)createFontFamiliesForFontMenu
{
    NSArray *fonts = [WDWordDiary sharedWordDiary].fonts;
    NSMutableArray *fontsFamilies = [NSMutableArray arrayWithCapacity:fonts.count];
    for (WDFont *fontIt in fonts) {
        [fontsFamilies addObject:fontIt.family];
    }
    
    return [NSArray arrayWithArray:fontsFamilies];
}

#pragma mark - Updates

- (void)updateColorScheme:(WDColorScheme)newScheme;
{
    if (newScheme != self.backgroundColorScheme) {
        self.backgroundColorScheme = newScheme;
        [self configureColorSchemes];
    }
}

#pragma mark - Activacion de menus

- (void)showTodayWordMenu
{
    [self showMenuView:self.todayWordMenuView inInmediateMode:NO];
}

- (void)showPreviousWordMenu
{
    [self showMenuView:self.previousDayWordMenuView inInmediateMode:NO];
}

- (void)showDeletePreviousWordConfirmationMenu
{
    [self showMenuView:self.confirmWordActionMenuView inInmediateMode:NO];
}

- (void)showFontWordMenu
{
    [self showMenuView:self.fontsMenuView inInmediateMode:NO];
}

- (void)showBackgroundColorWordMenu
{
    [self showMenuView:self.backgroundColorMenuView inInmediateMode:NO];
}

#pragma mark - Eventos de controles de menu

- (void)todayWordMenuOptionPressed:(UIButton *)button
{
    if (button.tag == TAG_CONTROL_TODAYWORDMENU_WRITE) {
        [self.delegate writeSelectedWordOption];
    } else if (button.tag == TAG_CONTROL_TODAYWORDMENU_FONT) {
        [self showFontWordMenu];
    } else if (button.tag == TAG_CONTROL_TODAYWORDMENU_COLOR) {
        [self showBackgroundColorWordMenu];
    } else if (button.tag == TAG_CONTROL_TODAYWORDMENU_SETTINGS) {
    }
}

- (void)previousDayWordMenuOptionPressed:(UIButton *)button
{
    if (button.tag == TAG_CONTROL_PREVIOUSWORDMENU_DELETE) {
        [self showDeletePreviousWordConfirmationMenu];
    }
}

- (void)confirmWordActionCancelPressed:(UIButton *)button
{
    [self.delegate cancelDeleteWordFromConfirmationMenu];
}

- (void)confirmWordActionAcceptPressed:(UIButton *)button
{
    [self.delegate acceptDeleteWordFromConfirmationMenu];
}

- (void)backNavigationInfoButtonPressed:(UIButton *)sender
{
}

#pragma mark - Fonts Menu Controls Delegate

- (void)collectionOptionsMenuBackOptionSelected:(WDCollectionOptionsWordMenuView *)menu
{
    // Nota: Se retorna llamando al metodo de bajo nivel directamente con el fin de que haya animacion
    if (self.fontsMenuView == menu) {
        [self showMenuView:self.todayWordMenuView inInmediateMode:NO];
    } else if (self.backgroundColorMenuView == menu) {
        [self showMenuView:self.todayWordMenuView inInmediateMode:NO];
    }
}

- (void)collectionOptionsMenu:(WDCollectionOptionsWordMenuView *)menu optionSelected:(NSUInteger)indexOption
{
    if (self.fontsMenuView == menu) {
        [self.delegate changeToFontWithIndex:indexOption];
    } else if (self.backgroundColorMenuView == menu) {
        WDBackgroundCategory category = [WDUtils convertPickerColorIndexToBackgroundCategory:indexOption];
        [self.delegate changeToBackgroundCategory:category];
    }
}


@end
