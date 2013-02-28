//
//  WDEditingActualWordMenuViewController.m
//  Word Diary
//
//  Created by Fernando Rodríguez Martínez on 28/02/13.
//  Copyright (c) 2013 Fernando Rodríguez Martínez. All rights reserved.
//

#import "WDEditingActualWordMenuViewController.h"

@interface WDEditingActualWordMenuViewController ()

@end

@implementation WDEditingActualWordMenuViewController

#pragma mark - Synthesize

@synthesize selectedWord = selectedWord_;
@synthesize delegate     = delegate_;

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
 
    // Do any additional setup after loading the view from its nib.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - UI Events

- (IBAction)keyboardPressed:(id)sender
{
    if ([self.delegate respondsToSelector:@selector(keyboardOptionSelectedFromMenu:)]) {
        [self.delegate keyboardOptionSelectedFromMenu:self];
    }
}

- (IBAction)changeFontPressed:(id)sender
{
    if ([self.delegate respondsToSelector:@selector(changeFontOptionSelectedFromMenu:)]) {
        [self.delegate changeFontOptionSelectedFromMenu:self];
    }
}

- (IBAction)changeColorPressed:(id)sender
{
    if ([self.delegate respondsToSelector:@selector(changeColorOptionSelectedFromMenu:)]) {
        [self.delegate changeColorOptionSelectedFromMenu:self];
    }
}

- (IBAction)clearWordPressed:(id)sender
{
    if ([self.delegate respondsToSelector:@selector(removeWordSOptionelectedFromMenu:)]) {
        [self.delegate removeWordSOptionelectedFromMenu:self];
    }
}

@end
