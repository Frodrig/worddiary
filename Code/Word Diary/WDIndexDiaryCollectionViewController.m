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
#import "UIColor+hexColorCreation.h"
#import <QuartzCore/QuartzCore.h>

@interface WDIndexDiaryCollectionViewController ()

#pragma mark - Properties

@property (nonatomic) CGSize      cellsSize;
@property (nonatomic) NSIndexPath *selectedCellIndexPath;

- (UICollectionViewFlowLayout *) createAndConfigureCollectionViewFlowLayout;

@end

@implementation WDIndexDiaryCollectionViewController

#pragma mark - Synthesize

@synthesize cellsSize             = cellsSize_;
@synthesize selectedCellIndexPath = selectedCellIndexPath_;

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
    /*
    const CGFloat numItemsPerRow = 4.0;
    const CGFloat xSeparator = 0;
    const CGFloat ySeparator = 0;
        
    CGFloat widthOfItems = (self.collectionView.bounds.size.width / numItemsPerRow) - (xSeparator * numItemsPerRow);
    CGFloat heightOfItems = self.collectionView.bounds.size.height / 3.0;
    self.cellsSize = CGSizeMake(widthOfItems, heightOfItems);
    
    UICollectionViewFlowLayout *flowLayout = (UICollectionViewFlowLayout *)self.collectionView.collectionViewLayout;
    flowLayout.itemSize = self.cellsSize;
    flowLayout.minimumInteritemSpacing = xSeparator;
    flowLayout.minimumLineSpacing = ySeparator;
    flowLayout.scrollDirection = UICollectionViewScrollDirectionVertical;
    
    //[self.view.layer addSublayer:[WDUtils createEdgeMaskLayerWithBounds:self.collectionView.bounds]];
    //cell.layer.cornerRadius = 0.0;
    //cell.layer.masksToBounds = NO;
     */
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Auxiliary Init

- (UICollectionViewFlowLayout *) createAndConfigureCollectionViewFlowLayout
{
    UICollectionViewFlowLayout *collectionViewFlow = [[UICollectionViewFlowLayout alloc] init];
    
    const CGFloat numItemsPerRow = 4.0;
    const CGFloat xSeparator = 0;
    const CGFloat ySeparator = 0;
    
    CGFloat widthOfItems = (self.collectionView.bounds.size.width / numItemsPerRow) - (xSeparator * numItemsPerRow);
    CGFloat heightOfItems = self.collectionView.bounds.size.height / 3.0;
    self.cellsSize = CGSizeMake(widthOfItems, heightOfItems);
    
    collectionViewFlow.itemSize = self.cellsSize;
    collectionViewFlow.minimumInteritemSpacing = xSeparator;
    collectionViewFlow.minimumLineSpacing = ySeparator;
    collectionViewFlow.scrollDirection = UICollectionViewScrollDirectionVertical;
        
    return collectionViewFlow;
}


#pragma mark - UICollectionViewDataSource

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    
    WDIndexDiaryCollectionViewCell *cell = [self.collectionView dequeueReusableCellWithReuseIdentifier:@"WDIndexDiaryCollectionViewCell" forIndexPath:indexPath];    
    
    /*
    cell.dayDiaryLabel.text = [WDUtils convertNumberToStringWithTwoDigitsMin:[NSNumber numberWithInteger:indexPath.row]];
    cell.backgroundColor = indexPath.row % 2 == 0 ? [UIColor lightGrayColor] : [UIColor colorWithWhite:0.75 alpha:1.0];
    //cell.layer.cornerRadius = 0.0;
    //cell.layer.masksToBounds = NO;
    //cell.layer.shouldRasterize = YES;
    cell.opaque = YES;
    */
    
    WDWord *word = [[WDWordDiary sharedWordDiary].words objectAtIndex:indexPath.row];
    WDPalette* palette = [word.emotion findPaletteOfIdName:word.paletteIdNameOfEmotion];
    cell.dayDiaryLabel.text = [WDUtils convertNumberToStringWithTwoDigitsMin:[NSNumber numberWithInteger:[[WDWordDiary sharedWordDiary] findIndexPositionForWord:word]]];
    cell.dayDiaryLabel.textColor = [UIColor colorWithHexadecimalValue:palette.wordColor withAlphaComponent:NO skipInitialCharacter:NO];
    cell.dateLabel.text = [word yearAsString];
    cell.dateLabel.text = [word isTodayWord] ? NSLocalizedString(@"TAG_TODAY", @"") : [cell.dateLabel.text stringByAppendingString:[NSString stringWithFormat:@"\n%@", [word dayAndMonthAsString]]];
    cell.dateLabel.textColor = [cell.dayDiaryLabel.textColor copy];
    cell.contentView.backgroundColor = [UIColor colorWithHexadecimalValue:palette.backgroundColor withAlphaComponent:NO skipInitialCharacter:NO];
    
    if ([indexPath compare:self.selectedCellIndexPath] != NSOrderedSame) {
        cell.dayDiaryLabel.alpha = 0.5;
        cell.dateLabel.alpha = 0.5;
    } else {
        cell.dayDiaryLabel.alpha = 1;
        cell.dayDiaryLabel.alpha = 1;
    }
    
    return cell;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return [WDWordDiary sharedWordDiary].words.count;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    if ([indexPath compare:self.selectedCellIndexPath] == NSOrderedSame) {
        return CGSizeMake(self.cellsSize.width * 2, self.cellsSize.height);
    } else {
        return self.cellsSize;
    }
}

#pragma mark - UICollectionViewDelegate

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    NSIndexPath *prevSelectedIndexPath = self.selectedCellIndexPath;
    if ([prevSelectedIndexPath compare:indexPath] != NSOrderedSame) {
        self.selectedCellIndexPath = indexPath;
        [self.collectionView.collectionViewLayout invalidateLayout];
    }
}

@end
