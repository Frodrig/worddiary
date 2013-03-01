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
#import "WDUtils.h"

static const NSUInteger TAG_1FONT_BUTTON = 100;
static const NSUInteger TAG_2FONT_BUTTON = 105;
static const NSUInteger TAG_3FONT_BUTTON = 110;
static const NSUInteger TAG_4FONT_BUTTON = 115;

@interface WDFontMenuSelectorViewController ()

- (void)    prepareButtonFont:(UIButton *)button withFont:(WDFont *)font andWord:(NSString *)word;
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

- (void)prepareButtonFont:(UIButton *)button withFont:(WDFont *)font andWord:(NSString *)word
{
    [button setTitle:word forState:UIControlStateNormal];
    button.titleLabel.font = [UIFont fontWithName:font.family size:[WDUtils sizeOfWordForUI:UI_SELECTEDWORDSCREEN_FONTMENU andFont:font]];
    [button addTarget:self action:@selector(buttonFontPressed:) forControlEvents:UIControlEventTouchUpInside];
}

- (void)prepareButtonFonts
{
    NSArray *buttonFonts = [NSArray arrayWithObjects:[NSNumber numberWithUnsignedInteger:TAG_1FONT_BUTTON],
                                                     [NSNumber numberWithUnsignedInteger:TAG_2FONT_BUTTON],
                                                     [NSNumber numberWithUnsignedInteger:TAG_3FONT_BUTTON],
                                                     [NSNumber numberWithUnsignedInteger:TAG_4FONT_BUTTON],
                                                     nil];
    NSArray *buttonCharacters = [NSArray arrayWithObjects:@"a", @"a", @"a", @"a", nil];
    NSArray *fonts = [WDWordDiary sharedWordDiary].fonts;
    NSAssert(buttonFonts.count == fonts.count, @"No hay coincidencia entre la cantidad de fuentes y la cantidad de botones");
    
    for (NSUInteger index = 0; index < buttonFonts.count; ++index) {
        NSNumber *buttonTag = [buttonFonts objectAtIndex:index];
        [self prepareButtonFont:(UIButton *)[self.view viewWithTag:buttonTag.integerValue] withFont:[fonts objectAtIndex:index] andWord:[buttonCharacters objectAtIndex:index]];
    }
}

#pragma mark - UIButton Events

- (void)buttonFontPressed:(UIButton *)sender
{
    NSUInteger fontIndex = 0;
    if (sender.tag == TAG_2FONT_BUTTON) {
        fontIndex = 1;
    } else if (sender.tag == TAG_3FONT_BUTTON) {
        fontIndex = 2;
    } else if (sender.tag == TAG_4FONT_BUTTON) {
        fontIndex = 3;
    }
    
    NSArray *fonts = [WDWordDiary sharedWordDiary].fonts;
    WDFont *font = [fonts objectAtIndex:fontIndex];
    [self.delegate fontMenuSelector:self selectedFont:font];
}

@end
