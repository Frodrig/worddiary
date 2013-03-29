//
//  WDSelectedWordEditMenuViewController.m
//  Word Diary
//
//  Created by Fernando Rodríguez Martínez on 08/03/13.
//  Copyright (c) 2013 Fernando Rodríguez Martínez. All rights reserved.
//

#import "WDSelectedWordEditMenuViewController.h"
#import <QuartzCore/QuartzCore.h>
#import "WDWordMenuView.h"
#import "WDTodayWordMenuViewPage1.h"
#import "WDWordMenuAuxiliaryViewPage2.h"
#import "WDPreviousDayWordMenuViewPage1.h"
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

@property (nonatomic, strong) WDWordMenuView                  *wordMenuView;
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

@synthesize wordMenuView                  = wordMenuView_;
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
        
        wordMenuView_ = (WDWordMenuView *)[WDWordMenuView createFromNib];
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
        
    // Menu principal
    self.wordMenuView.layer.cornerRadius = [WDUtils viewsCornerRadius];
    
    // Scroll
    self.wordMenuView.page2.frame = CGRectMake(self.wordMenuView.page1TodayWord.frame.size.width, 0.0, self.wordMenuView.page1TodayWord.bounds.size.width, self.wordMenuView.page1TodayWord.bounds.size.height);
    self.wordMenuView.scrollView.contentSize = CGSizeMake(self.wordMenuView.page1TodayWord.bounds.size.width + self.wordMenuView.page1TodayWord.bounds.size.width, self.wordMenuView.scrollView.bounds.size.height);
    [self.wordMenuView.scrollView addSubview:self.wordMenuView.page1TodayWord];
    [self.wordMenuView.scrollView addSubview:self.wordMenuView.page1PreviousDayWord];
    [self.wordMenuView.scrollView addSubview:self.wordMenuView.page2];
    self.wordMenuView.scrollView.delegate = self;
    
    // Page 1 Today Word
    [self.wordMenuView.page1TodayWord.keyboardButton setTitle:NSLocalizedString(@"TAG_TODAYWORDMENU_WRITEOPTION", @"") forState:UIControlStateNormal];
    [self.wordMenuView.page1TodayWord.keyboardButton addTarget:self action:@selector(todayWordMenuOptionPressed:) forControlEvents:UIControlEventTouchUpInside];
    [self.wordMenuView.page1TodayWord.fontButton setTitle:NSLocalizedString(@"TAG_TODAYWORDMENU_FONTOPTION", @"") forState:UIControlStateNormal];
    [self.wordMenuView.page1TodayWord.fontButton addTarget:self action:@selector(todayWordMenuOptionPressed:) forControlEvents:UIControlEventTouchUpInside];
    [self.wordMenuView.page1TodayWord.backgroundColorButton setTitle:NSLocalizedString(@"TAG_TODAYWORDMENU_COLOROPTION", @"") forState:UIControlStateNormal];
    [self.wordMenuView.page1TodayWord.backgroundColorButton addTarget:self action:@selector(todayWordMenuOptionPressed:) forControlEvents:UIControlEventTouchUpInside];
    self.wordMenuView.page1TodayWord.hidden = YES;
    
    // Page 1 Previous Day Word
    [self.wordMenuView.page1PreviousDayWord.deleteButton setTitle:NSLocalizedString(@"TAG_PREVIOUSWORDMENU_DELETEOPTION", @"") forState:UIControlStateNormal];
    [self configureButton:self.wordMenuView.page1PreviousDayWord.deleteButton withColorScheme:self.backgroundColorScheme];
    [self.wordMenuView.page1PreviousDayWord.deleteButton addTarget:self action:@selector(previousDayWordMenuOptionPressed:) forControlEvents:UIControlEventTouchUpInside];
    self.wordMenuView.page1PreviousDayWord.hidden = YES;
    
    // Page 2
    [self.wordMenuView.page2.tipsButton setTitle:NSLocalizedString(@"TAG_TODAYWORDMENU_TIPSOPTION", @"") forState:UIControlStateNormal];
    [self.wordMenuView.page2.tipsButton addTarget:self action:@selector(todayWordMenuOptionPressed:) forControlEvents:UIControlEventTouchUpInside];
    [self.wordMenuView.page2.supportButton setTitle:NSLocalizedString(@"TAG_TODAYWORDMENU_SUPPORTOPTION", @"") forState:UIControlStateNormal];
    [self.wordMenuView.page2.supportButton addTarget:self action:@selector(todayWordMenuOptionPressed:) forControlEvents:UIControlEventTouchUpInside];
    [self.wordMenuView.page2.aboutButton setTitle:NSLocalizedString(@"TAG_TODAYWORDMENU_ABOUTOPTION", @"") forState:UIControlStateNormal];
    [self.wordMenuView.page2.aboutButton addTarget:self action:@selector(todayWordMenuOptionPressed:) forControlEvents:UIControlEventTouchUpInside];
    
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
    self.wordMenuView.backgroundColor = [self.view.backgroundColor copy];
    
    [self configureButton:self.wordMenuView.page1TodayWord.keyboardButton withColorScheme:self.backgroundColorScheme];
    [self configureButton:self.wordMenuView.page1TodayWord.fontButton withColorScheme:self.backgroundColorScheme];
    [self configureButton:self.wordMenuView.page1TodayWord.backgroundColorButton withColorScheme:self.backgroundColorScheme];
    [self configureButton:self.wordMenuView.page1PreviousDayWord.deleteButton withColorScheme:self.backgroundColorScheme];
    [self configureButton:self.wordMenuView.page2.tipsButton withColorScheme:self.backgroundColorScheme];
    [self configureButton:self.wordMenuView.page2.aboutButton withColorScheme:self.backgroundColorScheme];
    [self configureButton:self.wordMenuView.page2.supportButton withColorScheme:self.backgroundColorScheme];
    //[self configureButton:self.todayWordMenuView.settingsButton withColorScheme:self.backgroundColorScheme];
    
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
    NSSet *menus = [NSSet setWithObjects:self.wordMenuView, self.fontsMenuView, self.backgroundColorMenuView, self.confirmWordActionMenuView, nil];
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
        if (menuToRemove == nil && (menuView == self.wordMenuView)) {
            [menuToRemove removeFromSuperview];
            self.view.alpha = 0.0;
            self.view.hidden = NO;
            [self.view addSubview:menuView];
            [UIView animateWithDuration:inmediate ? 0.0 : 0.5 animations:^{
                self.view.alpha = 1.0;
            }];
        } else {
            BOOL menuToShowIsNext = menuView != self.wordMenuView;
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
    self.wordMenuView.page1PreviousDayWord.hidden = YES;
    self.wordMenuView.page1TodayWord.hidden = NO;
    self.wordMenuView.pageView.currentPage = 0;
    [self.wordMenuView.scrollView scrollRectToVisible:self.wordMenuView.page1TodayWord.frame animated:NO];
    [self showMenuView:self.wordMenuView inInmediateMode:NO];
}

- (void)showPreviousWordMenu
{
    self.wordMenuView.page1PreviousDayWord.hidden = NO;
    self.wordMenuView.page1TodayWord.hidden = YES;
    self.wordMenuView.pageView.currentPage = 0;
    [self.wordMenuView.scrollView scrollRectToVisible:self.wordMenuView.page1PreviousDayWord.frame animated:NO];
    [self showMenuView:self.wordMenuView inInmediateMode:NO];
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
    if (button == self.wordMenuView.page1TodayWord.keyboardButton) {
        [self.delegate writeSelectedWordOption];
    } else if (button == self.wordMenuView.page1TodayWord.fontButton) {
        [self showFontWordMenu];
    } else if (button == self.wordMenuView.page1TodayWord.backgroundColorButton) {
        [self showBackgroundColorWordMenu];
    } else if (button == self.wordMenuView.page2.supportButton) {
        [self.delegate supportOptionSelected];
    } else if (button == self.wordMenuView.page2.tipsButton) {
        [self.delegate tipsOptionSelected];
    } else if (button == self.wordMenuView.page2.aboutButton) {
        [self.delegate infoOptionSelected];
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
        [self showMenuView:self.wordMenuView inInmediateMode:NO];
    } else if (self.backgroundColorMenuView == menu) {
        [self showMenuView:self.wordMenuView inInmediateMode:NO];
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

#pragma mark - UIScrollViewDelegate

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    
    self.wordMenuView.pageView.currentPage = scrollView.contentOffset.x == 0 ? 0 : 1;
    [self.wordMenuView.pageView updateCurrentPageDisplay];
}



@end
