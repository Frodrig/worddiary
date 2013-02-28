//
//  WDEditingPreviousWordMenuViewController.m
//  Word Diary
//
//  Created by Fernando Rodríguez Martínez on 28/02/13.
//  Copyright (c) 2013 Fernando Rodríguez Martínez. All rights reserved.
//

#import "WDEditingPreviousWordMenuViewController.h"

@interface WDEditingPreviousWordMenuViewController ()

@end

#pragma mark - Init

@implementation WDEditingPreviousWordMenuViewController

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

- (IBAction)deleteButtonPressed:(id)sender
{
    if ([self.delegate performSelector:@selector(removeWordSOptionelectedFromMenu:) withObject:self]) {
        [self.delegate removeWordSOptionelectedFromMenu:self];
    }
}

@end
