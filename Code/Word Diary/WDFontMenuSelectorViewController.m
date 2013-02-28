//
//  WDFontMenuSelectorViewController.m
//  Word Diary
//
//  Created by Fernando Rodríguez Martínez on 28/02/13.
//  Copyright (c) 2013 Fernando Rodríguez Martínez. All rights reserved.
//

#import "WDFontMenuSelectorViewController.h"
#import "WDFont.h"
#import "WDWordDiary.h"

static const NSUInteger TAG_1FONT_BUTTON = 100;
static const NSUInteger TAG_2FONT_BUTTON = 105;
static const NSUInteger TAG_3FONT_BUTTON = 110;
static const NSUInteger TAG_4FONT_BUTTON = 115;

@interface WDFontMenuSelectorViewController ()

- (CGFloat) sizeButtonOfFamilyFont:(WDFont *)font;
- (void)    prepareButtonFont:(UIButton *)button withFont:(WDFont *)font;
- (void)    prepareButtonFonts;

@end

@implementation WDFontMenuSelectorViewController

#pragma mark - Synthesize

@synthesize delegate = delegate_;

#pragma mark - Init

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // Botones con las fuentes
    [self prepareButtonFonts];
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (CGFloat)sizeButtonOfFamilyFont:(WDFont *)font
{
    return 32.0;
}

- (void)prepareButtonFont:(UIButton *)button withFont:(WDFont *)font
{
    button.titleLabel.font = [UIFont fontWithName:font.family size:[self sizeButtonOfFamilyFont:font]];
    [button addTarget:self action:@selector(buttonFontPressed:) forControlEvents:UIControlEventTouchUpInside];
}

- (void)prepareButtonFonts
{
    
}

#pragma mark - UIButton Events

- (void)buttonFontPressed:(UIButton *)sender
{
}

@end
