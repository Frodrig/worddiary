//
//  WDIndexDiaryCollectionViewController.m
//  Word Diary
//
//  Created by Fernando Rodríguez Martínez on 10/04/13.
//  Copyright (c) 2013 Fernando Rodríguez Martínez. All rights reserved.
//

#import "WDIndexDiaryCollectionViewController.h"
#import "WDWordDiary.h"
#import "WDIndexDiaryCollectionViewCell.h"
#import "WDUtils.h"
#import "WDWord.h"
#import "WDPalette.h"
#import "WDEmotion.h"
#import "WDStyle.h"
#import "UIColor+hexColorCreation.h"
#import <QuartzCore/QuartzCore.h>

@interface WDIndexDiaryCollectionViewController ()

#pragma mark - Properties

@property (nonatomic) CGSize                         cellsSize;
@property (nonatomic, strong) NSIndexPath            *selectedCellIndexPath;
@property (nonatomic, strong) UITapGestureRecognizer *dobleTapGestureRecognizer;

- (UICollectionViewFlowLayout *)     createAndConfigureCollectionViewFlowLayout;
- (void)                             dobleTapHandle:(UITapGestureRecognizer *)gestureRecognizer;

- (void)                             showWordAtSelectedCell;

@end

@implementation WDIndexDiaryCollectionViewController

#pragma mark - Synthesize

@synthesize cellsSize                 = cellsSize_;
@synthesize selectedCellIndexPath     = selectedCellIndexPath_;
@synthesize dobleTapGestureRecognizer = dobleTapGestureRecognizer_;
@synthesize delegate                  = delegate_;
@synthesize dataSource                = dataSource_;

#pragma mark - Init

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    return [self init];
}


- (id)initWithCollectionViewLayout:(UICollectionViewLayout *)layout
{
    return [self init];
}

- (id)init
{
    self = [super initWithCollectionViewLayout:[[UICollectionViewFlowLayout alloc] init]];
    if (self) {
        // ...
        selectedCellIndexPath_ = [NSIndexPath indexPathForRow:0 inSection:0];
        dobleTapGestureRecognizer_ = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(dobleTapHandle:)];
        dobleTapGestureRecognizer_.numberOfTapsRequired = 2.0;
        dobleTapGestureRecognizer_.numberOfTouchesRequired = 1.0;
        [self.view addGestureRecognizer:dobleTapGestureRecognizer_];
    }
    
    return self;
}


- (void)viewDidLoad
{
    [super viewDidLoad];
    
	// Do any additional setup after loading the view.
    self.collectionView.delegate = self;
    self.collectionView.dataSource = self;
    
    // Cell
    [self.collectionView registerNib:[UINib nibWithNibName:@"WDIndexDiaryCollectionViewCell" bundle:[NSBundle mainBundle]] forCellWithReuseIdentifier:@"WDIndexDiaryCollectionViewCell"];
    
    // Adjustments
    self.collectionView.showsVerticalScrollIndicator = NO;
    self.collectionView.showsHorizontalScrollIndicator = NO;
    self.collectionView.pagingEnabled = NO;
    self.collectionView.layer.cornerRadius = 10.0;
    self.collectionView.clipsToBounds = YES;
    self.collectionView.layer.masksToBounds = YES;
    self.collectionView.opaque = YES;
    self.collectionView.bounces = NO;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    self.collectionView.collectionViewLayout = [self createAndConfigureCollectionViewFlowLayout];
    
    self.selectedCellIndexPath = [NSIndexPath indexPathForRow:[self.dataSource selectedIndexWordForIndexDiaryCollectionViewController:self] inSection:0];
    [self.collectionView scrollToItemAtIndexPath:self.selectedCellIndexPath atScrollPosition:UICollectionViewScrollPositionCenteredHorizontally animated:NO];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    [self showWordAtSelectedCell];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Gesture Recognizer

- (void)dobleTapHandle:(UITapGestureRecognizer *)gestureRecognizer
{
    CGPoint tapLocation = [gestureRecognizer locationInView:self.collectionView];
    NSIndexPath *indexPath = [self.collectionView indexPathForItemAtPoint:tapLocation];
    if (indexPath) {
        NSLog(@"%d %d", indexPath.row, [WDWordDiary sharedWordDiary].words.count - indexPath.row - 1);
        [self.delegate indexDiaryScreenViewController:self wordSelectedAtIndex:[WDWordDiary sharedWordDiary].words.count - indexPath.row - 1];
    }
}

#pragma mark - Auxiliary Init

- (UICollectionViewFlowLayout *) createAndConfigureCollectionViewFlowLayout
{
    UICollectionViewFlowLayout *collectionViewFlow = [[UICollectionViewFlowLayout alloc] init];
    
    const CGFloat numItemsPerRow = 5.0;
    const CGFloat xSeparator = 0.0;
    const CGFloat ySeparator = 0;
    
    CGFloat widthOfItems = self.collectionView.bounds.size.width / numItemsPerRow;//(self.collectionView.bounds.size.width / numItemsPerRow) - (xSeparator * numItemsPerRow);
    CGFloat heightOfItems =  self.collectionView.bounds.size.height;//self.collectionView.bounds.size.height / 3.0;
    self.cellsSize = CGSizeMake(widthOfItems, heightOfItems);
    
    
    collectionViewFlow.itemSize = self.cellsSize;
    collectionViewFlow.minimumInteritemSpacing = xSeparator;
    collectionViewFlow.minimumLineSpacing = ySeparator;
    collectionViewFlow.scrollDirection = UICollectionViewScrollDirectionHorizontal;
        
    return collectionViewFlow;
}

#pragma mark - UICollectionViewDataSource

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    WDIndexDiaryCollectionViewCell *cell = [self.collectionView dequeueReusableCellWithReuseIdentifier:@"WDIndexDiaryCollectionViewCell" forIndexPath:indexPath];    
   
    WDWord *word = [[WDWordDiary sharedWordDiary].words objectAtIndex:[WDWordDiary sharedWordDiary].words.count - indexPath.row - 1];
    const BOOL isTodayWord = [word isTodayWord];
    WDPalette* palette = [word.emotion findPaletteOfIdName:word.paletteIdNameOfEmotion];
    
    cell.dayDiaryLabel.text = [WDUtils convertNumberToStringWithTwoDigitsMin:[NSNumber numberWithInteger:[[WDWordDiary sharedWordDiary] findIndexPositionForWord:word]]];
    cell.dayDiaryLabel.textColor = [UIColor colorWithHexadecimalValue:palette.wordColor withAlphaComponent:NO skipInitialCharacter:NO];
    cell.dateLabel.text = [[word yearAsString] stringByAppendingFormat:@"\n%@", isTodayWord ? NSLocalizedString(@"TAG_TODAY", @"") : [word dayAndMonthAbreviateAsString]];
    cell.dateLabel.textColor = [cell.dayDiaryLabel.textColor copy];
    cell.contentView.backgroundColor = [UIColor colorWithHexadecimalValue:palette.backgroundColor withAlphaComponent:NO skipInitialCharacter:NO];
    
    return cell;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return [WDWordDiary sharedWordDiary].words.count;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    return self.cellsSize;

    if ([indexPath compare:self.selectedCellIndexPath] == NSOrderedSame) {
        return CGSizeMake(self.cellsSize.width * 2, self.cellsSize.height);
    } else {
        return self.cellsSize;
    }
}

#pragma mark - UICollectionViewDelegate

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    self.selectedCellIndexPath = indexPath;
    
    [self showWordAtSelectedCell];
}

#pragma mark - Auxiliary - Actions

- (void)showWordAtSelectedCell
{
    WDIndexDiaryCollectionViewCell *cell = (WDIndexDiaryCollectionViewCell *)[self.collectionView cellForItemAtIndexPath:self.selectedCellIndexPath];
    WDWord *selectedWord = [[WDWordDiary sharedWordDiary].words objectAtIndex:[WDWordDiary sharedWordDiary].words.count - self.selectedCellIndexPath.row - 1];
    WDPalette* palette = [selectedWord.emotion findPaletteOfIdName:selectedWord.paletteIdNameOfEmotion];
    [cell showInitialLetterOfWord:selectedWord.word fontFamily:selectedWord.style.familyFont andColor:[UIColor colorWithHexadecimalValue:palette.wordColor withAlphaComponent:NO skipInitialCharacter:NO]];

}

@end
