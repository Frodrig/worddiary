//
//  WDMainMenuViewController.m
//  Word Diary
//
//  Created by Fernando Rodríguez Martínez on 21/04/13.
//  Copyright (c) 2013 Fernando Rodríguez Martínez. All rights reserved.
//

#import "WDMainMenuViewController.h"

@interface WDMainMenuViewController ()

@end

@implementation WDMainMenuViewController

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

#pragma mark - Control Events

- (IBAction)addButtonPressed:(id)sender
{
    [self.delegate addOptionSelectedForMainMenuViewController:self];
}

- (IBAction)removeButtonPressed:(id)sender
{
    [self.delegate removeOptionSelectedForMainMenuViewController:self];
}

- (IBAction)settingsButtonPressed:(id)sender
{
    [self.delegate settingsOptionSelectedForMainMenuViewController:self];
}

- (IBAction)helpButtonPressed:(id)sender
{
    [self.delegate helpOptionSelectedForMainMenuViewController:self];
}

- (IBAction)infoButtonPressed:(id)sender
{
    [self.delegate infoOptionSelectedFormainMenuViewController:self];
}

@end
