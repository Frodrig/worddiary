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
#import "UIView+UIViewNibLoad.h"

static const NSUInteger VIEWS_CORNER_RADIUS                 = 10;
static const NSUInteger TAG_CONTROL_TODAYWORDMENU_WRITE     = 10;
static const NSUInteger TAG_CONTROL_TODAYWORDMENU_FONT      = 15;
static const NSUInteger TAG_CONTROL_TODAYWORDMENU_COLOR     = 20;
static const NSUInteger TAG_CONTROL_TODAYWORDMENU_CLEAR     = 25;
static const NSUInteger TAG_CONTROL_PREVIOUSWORDMENU_DELETE = 30;


@interface WDSelectedWordEditMenuViewController ()

@property (nonatomic, strong) WDTodayWordMenuView         *todayWorldMenuView;
@property (nonatomic, strong) WDPreviousWordMenuView      *previousDayWordMenuView;
@property (nonatomic, strong) WDConfirmWordActionMenuView *confirmWordActionMenuView;

- (void)showMenuView:(UIView *)menuView;

@end

@implementation WDSelectedWordEditMenuViewController

#pragma mark - Synthesize

@synthesize todayWorldMenuView        = todayWorldMenuView_;
@synthesize previousDayWordMenuView   = previousDayWordMenuView_;
@synthesize delegate                  = delegate_;
@synthesize confirmWordActionMenuView = confirmWordActionMenuView_;

#pragma mark - Init

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        todayWorldMenuView_ = (WDTodayWordMenuView *)[WDTodayWordMenuView createFromNib];
        previousDayWordMenuView_ = (WDPreviousWordMenuView *)[WDPreviousWordMenuView createFromNib];
        confirmWordActionMenuView_ = (WDConfirmWordActionMenuView *)[WDConfirmWordActionMenuView createFromNib];
    }
    
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // Fondo
    self.view.backgroundColor = [UIColor colorWithRed:0.25 green:0.25 blue:0.25 alpha:0.2];
    self.view.layer.cornerRadius = VIEWS_CORNER_RADIUS;
    
    // Menu principal para la palabra del dia de hoy
    self.todayWorldMenuView.backgroundColor = [self.view.backgroundColor copy];
    self.todayWorldMenuView.layer.cornerRadius = VIEWS_CORNER_RADIUS;
    [self.todayWorldMenuView.keyboardButton setTitle:NSLocalizedString(@"TAG_TODAYWORDMENU_WRITEOPTION", @"") forState:UIControlStateNormal];
    [self.todayWorldMenuView.fontButton setTitle:NSLocalizedString(@"TAG_TODAYWORDMENU_FONTOPTION", @"") forState:UIControlStateNormal];
    [self.todayWorldMenuView.backgroundColorButton setTitle:NSLocalizedString(@"TAG_TODAYWORDMENU_COLOROPTION", @"") forState:UIControlStateNormal];
    [self.todayWorldMenuView.eraseButton setTitle:NSLocalizedString(@"TAG_TODAYWORDMENU_ERASEOPTION", @"") forState:UIControlStateNormal];
    [self.todayWorldMenuView.keyboardButton addTarget:self action:@selector(todayWordMenuOptionPressed:) forControlEvents:UIControlEventTouchUpInside];
    [self.todayWorldMenuView.eraseButton addTarget:self action:@selector(todayWordMenuOptionPressed:) forControlEvents:UIControlEventTouchUpInside];

    // Menu principal para palabras previas
    self.previousDayWordMenuView.backgroundColor = [self.view.backgroundColor copy];
    self.previousDayWordMenuView.layer.cornerRadius = VIEWS_CORNER_RADIUS;
    [self.previousDayWordMenuView.deleteButton setTitle:NSLocalizedString(@"TAG_PREVIOUSWORDMENU_DELETEOPTION", @"") forState:UIControlStateNormal];
    [self.previousDayWordMenuView.deleteButton addTarget:self action:@selector(previousDayWordMenuOptionPressed:) forControlEvents:UIControlEventTouchUpInside];
    
    // Menu de confirmacion
    self.confirmWordActionMenuView.backgroundColor = [self.view.backgroundColor copy];
    self.confirmWordActionMenuView.layer.cornerRadius = VIEWS_CORNER_RADIUS;
    self.confirmWordActionMenuView.descriptionLabel.text = NSLocalizedString(@"TAG_CONFIRMACTIONMENU_DESCRIPTION", @"");
    [self.confirmWordActionMenuView.cancelButton setTitle:NSLocalizedString(@"TAG_CONFIRMACTIONMENU_CANCEL", @"") forState:UIControlStateNormal];
    [self.confirmWordActionMenuView.yesButton setTitle:NSLocalizedString(@"TAG_CONFIRMACTIONMENU_YES", @"") forState:UIControlStateNormal];
    [self.confirmWordActionMenuView.cancelButton addTarget:self action:@selector(confirmWordActionCancelPressed:) forControlEvents:UIControlEventTouchUpInside];
    [self.confirmWordActionMenuView.yesButton addTarget:self action:@selector(confirmWordActionAcceptPressed:) forControlEvents:UIControlEventTouchUpInside];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Metodos auxiliares

- (void)showMenuView:(UIView *)menuView
{
    NSSet *menus = [NSSet setWithObjects:self.todayWorldMenuView, self.previousDayWordMenuView, self.confirmWordActionMenuView, nil];
    for (UIView *viewIt in menus) {
        if (menuView == viewIt) {
            [self.view addSubview:menuView];
        } else {
            [viewIt removeFromSuperview];
        }
    }
}

#pragma mark - Activacion de menus

- (void)showTodayWordMenuWithClearButtonEnabled:(BOOL)enabled;
{
    [self showMenuView:self.todayWorldMenuView];
    self.todayWorldMenuView.eraseButton.enabled = enabled;
}

- (void)showPreviousWordMenu
{
    [self showMenuView:self.previousDayWordMenuView];
}

- (void) showDeletePreviousWordConfirmationMenu
{
    [self showMenuView:self.confirmWordActionMenuView];
}

#pragma mark - Menu Controls

- (void)todayWordMenuOptionPressed:(UIButton *)button
{
    if (button.tag == TAG_CONTROL_TODAYWORDMENU_WRITE) {
        [self.delegate writeSelectedWordOption];
    } else if (button.tag == TAG_CONTROL_TODAYWORDMENU_FONT) {
    } else if (button.tag == TAG_CONTROL_TODAYWORDMENU_COLOR) {
    } else if (button.tag == TAG_CONTROL_TODAYWORDMENU_CLEAR) {
        [self.delegate clearTodaySelectedWordOption];
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


@end
