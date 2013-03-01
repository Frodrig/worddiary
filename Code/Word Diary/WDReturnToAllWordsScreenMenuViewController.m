//
//  WDReturnToAllWordsScreenMenuViewController.m
//  Word Diary
//
//  Created by Fernando Rodríguez Martínez on 01/03/13.
//  Copyright (c) 2013 Fernando Rodríguez Martínez. All rights reserved.
//

#import "WDReturnToAllWordsScreenMenuViewController.h"

@interface WDReturnToAllWordsScreenMenuViewController ()

@end

@implementation WDReturnToAllWordsScreenMenuViewController

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
    // Do any additional setup after loading the view from its nib.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - UIControls Events

- (IBAction)returnButtonPressed:(id)sender
{
    [self.delegate exitToAllWordsScreenOptionSelected:self];
}

@end
