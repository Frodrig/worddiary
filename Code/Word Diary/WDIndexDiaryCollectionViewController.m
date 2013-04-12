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

@property (nonatomic) CGSize                               cellsSize;
@property (nonatomic, strong) NSIndexPath                  *selectedCellIndexPath;
@property (nonatomic, strong) UITapGestureRecognizer       *dobleTapGestureRecognizer;
@property (nonatomic, strong) UITapGestureRecognizer       *singleTapGestureRecognizer;
@property (nonatomic, strong) UILongPressGestureRecognizer *longPressRecognizer;
@property (nonatomic, strong) UISwipeGestureRecognizer     *swipeCellUpRecognizer;
@property (nonatomic, strong) UISwipeGestureRecognizer     *swipeCellDownRecognizer;
@property (nonatomic, strong) NSIndexPath                  *indexPathOfCellInRemoveMode;
@property (nonatomic, strong) NSMutableDictionary          *pendingRemoveMenus;

- (UICollectionViewFlowLayout *)     createAndConfigureCollectionViewFlowLayout;

- (void)                             tapHandle:(UITapGestureRecognizer *)gestureRecognizer;
- (void)                             longTapPressHandle:(UITapGestureRecognizer *)gestureRecognizer;
- (void)                             swipeCellRecognizer:(UISwipeGestureRecognizer *)gestureRecognizer;

- (void)                             removeMenuFromPendingRemoveMenusWithIndexPath:(NSIndexPath *)indexPath;
- (void)                             removeButtonPressed:(UIButton *)button;

- (void)                             showWordAtSelectedCell;

- (void)                             prepareCellInRemoveModeWithUpDirection:(BOOL)up;

@end

@implementation WDIndexDiaryCollectionViewController

#pragma mark - Synthesize

@synthesize cellsSize                   = cellsSize_;
@synthesize selectedCellIndexPath       = selectedCellIndexPath_;
@synthesize dobleTapGestureRecognizer   = dobleTapGestureRecognizer_;
@synthesize singleTapGestureRecognizer  = singleTapGestureRecognizer_;
@synthesize delegate                    = delegate_;
@synthesize longPressRecognizer         = longPressRecognizer_;
@synthesize dataSource                  = dataSource_;
@synthesize indexPathOfCellInRemoveMode = indexPathOfCellInRemoveMode_;
@synthesize swipeCellUpRecognizer       = swipeCellUpRecognizer_;
@synthesize swipeCellDownRecognizer     = swipeCellDownRecognizer_;
@synthesize pendingRemoveMenus          = pendingRemoveMenus_;

#pragma mark - Properties

- (NSMutableDictionary *)pendingRemoveMenus
{
    if (nil == pendingRemoveMenus_) {
        pendingRemoveMenus_ = [[NSMutableDictionary alloc] init];
    }
    
    return pendingRemoveMenus_;
}

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
        // Gestures - Solo creacion
        dobleTapGestureRecognizer_ = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapHandle:)];
        dobleTapGestureRecognizer_.numberOfTapsRequired = 2.0;
        dobleTapGestureRecognizer_.numberOfTouchesRequired = 1.0;
        dobleTapGestureRecognizer_.delegate = self;
        
        singleTapGestureRecognizer_ = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapHandle:)];
        singleTapGestureRecognizer_.numberOfTapsRequired = 1.0;
        singleTapGestureRecognizer_.numberOfTouchesRequired = 1.0;
        [singleTapGestureRecognizer_ requireGestureRecognizerToFail:dobleTapGestureRecognizer_];
        singleTapGestureRecognizer_.delegate = self;
        
        longPressRecognizer_ = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longTapPressHandle:)];
        longPressRecognizer_.numberOfTouchesRequired = 1.0;
        longPressRecognizer_.minimumPressDuration = 0.5;
        longPressRecognizer_.delegate = self;
        
        swipeCellUpRecognizer_ = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(swipeCellRecognizer:)];
        swipeCellUpRecognizer_.numberOfTouchesRequired = 1.0;
        swipeCellUpRecognizer_.direction = UISwipeGestureRecognizerDirectionUp;
        swipeCellUpRecognizer_.delegate = self;
        
        swipeCellDownRecognizer_ = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(swipeCellRecognizer:)];
        swipeCellDownRecognizer_.numberOfTouchesRequired = 1.0;
        swipeCellDownRecognizer_.direction = UISwipeGestureRecognizerDirectionDown;
        swipeCellDownRecognizer_.delegate = self;
    }
    
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
	// Do any additional setup after loading the view.
    self.collectionView.delegate = self;
    self.collectionView.dataSource = self;
    
    // Gestures
    [self.view addGestureRecognizer:self.longPressRecognizer];
    [self.view addGestureRecognizer:self.dobleTapGestureRecognizer];
    [self.view addGestureRecognizer:self.singleTapGestureRecognizer];
    [self.view addGestureRecognizer:self.swipeCellUpRecognizer];
    [self.view addGestureRecognizer:self.swipeCellDownRecognizer];
    
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
    self.collectionView.backgroundColor = [UIColor clearColor];
    
    self.view.backgroundColor = [UIColor clearColor];
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

#pragma mark - Auxiliary Gesture Recognizer

- (void)prepareCellInRemoveModeWithUpDirection:(BOOL)up
{
    if (self.indexPathOfCellInRemoveMode) {
        const CGFloat moveDistance = 122.0;
        UICollectionViewCell *cell = [self.collectionView cellForItemAtIndexPath:self.indexPathOfCellInRemoveMode];

        // Menu
        UIView *removeMenuView = nil;
        if (up) {
            UICollectionViewLayoutAttributes *cellAttributes = [self.collectionView layoutAttributesForItemAtIndexPath:self.indexPathOfCellInRemoveMode];
            CGRect cellFrameInGlobalView = CGRectMake(cellAttributes.frame.origin.x - self.collectionView.contentOffset.x, cellAttributes.frame.origin.y, cellAttributes.frame.size.width, cellAttributes.frame.size.height);
           
            removeMenuView = [[UIView alloc] initWithFrame:CGRectMake(cellFrameInGlobalView.origin.x,
                                                                      cellFrameInGlobalView.origin.y + cellFrameInGlobalView.size.height - moveDistance,
                                                                      cellFrameInGlobalView.size.width,
                                                                      cellFrameInGlobalView.origin.y + cellFrameInGlobalView.size.height)];
            removeMenuView.backgroundColor = [UIColor clearColor];
            removeMenuView.opaque = NO;
            removeMenuView.userInteractionEnabled = YES;
            [self.view.superview insertSubview:removeMenuView belowSubview:self.view];
            
            UIButton *removeBtn = [UIButton buttonWithType:UIButtonTypeCustom];
            removeBtn.frame = CGRectMake(0.0, 0.0, cellFrameInGlobalView.size.width, moveDistance);
            [removeBtn setImage:[UIImage imageNamed:@"37-white-circle-x"] forState:UIControlStateNormal];
            removeBtn.backgroundColor = [UIColor clearColor];
            [removeBtn addTarget:self action:@selector(removeButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
            removeBtn.userInteractionEnabled = YES;
            removeBtn.tag = self.indexPathOfCellInRemoveMode.row;
            [removeMenuView addSubview:removeBtn];
                        
            [self.pendingRemoveMenus setObject:removeMenuView forKey:[NSNumber numberWithUnsignedInteger:self.indexPathOfCellInRemoveMode.row]];
        } else {
            // Mandamos el menu atras para conseguir efecto persiana
           removeMenuView = [self.pendingRemoveMenus objectForKey:[NSNumber numberWithUnsignedInteger:self.indexPathOfCellInRemoveMode.row]];
            [self.view.superview insertSubview:removeMenuView belowSubview:self.view];
        }
        
        // Animacion 
        [UIView setAnimationCurve:UIViewAnimationCurveEaseOut];
        [UIView animateWithDuration:0.25 animations:^{
            cell.frame = CGRectMake(cell.frame.origin.x, cell.frame.origin.y, cell.frame.size.width, up ? cell.frame.size.height - moveDistance : cell.frame.size.height + moveDistance);
        } completion:^(BOOL finished) {
            NSIndexPath *indexPathForCell = [self.collectionView indexPathForCell:cell];
            if (up) {
                // Cambiamos posicion menu para poder aceptar los eventos sobre el boton. En caso contrario estara detras del collectionview y no recibira
                // Nota: Inicialmente se pone detras para consegir el efecto persiana
                [self.view.superview insertSubview:removeMenuView aboveSubview:self.view];
            } else {
                // Destruimos el menu
                [self removeMenuFromPendingRemoveMenusWithIndexPath:indexPathForCell];
                if (self.pendingRemoveMenus.count == 0) {
                    self.view.userInteractionEnabled = YES;
                }
            }
        }];
    }
}

#pragma mark - Gesture Recognizer Delegate

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch
{
    BOOL retShouldReceive = YES;
    
    if (self.indexPathOfCellInRemoveMode != nil) {
        retShouldReceive = gestureRecognizer == self.swipeCellDownRecognizer || gestureRecognizer == self.swipeCellUpRecognizer ? YES : NO;
    }
    
    return retShouldReceive;
}

#pragma mark - Gesture Recognizer

- (void)tapHandle:(UITapGestureRecognizer *)gestureRecognizer
{
    CGPoint tapLocation = [gestureRecognizer locationInView:self.collectionView];
    NSIndexPath *indexPath = [self.collectionView indexPathForItemAtPoint:tapLocation];
    if (indexPath) {
        if (gestureRecognizer == self.dobleTapGestureRecognizer) {
            [self.delegate indexDiaryScreenViewController:self wordDoubleTapSelectedAtIndex:[WDWordDiary sharedWordDiary].words.count - indexPath.row - 1];
        } else if (gestureRecognizer == self.singleTapGestureRecognizer) {
            self.selectedCellIndexPath = indexPath;
            [self.delegate indexDiaryScreenViewController:self wordSingleTapSelectedAtIndex:[WDWordDiary sharedWordDiary].words.count - indexPath.row - 1];
            
            /*
             UICollectionViewCell *cell = [self.collectionView cellForItemAtIndexPath:indexPath];
             CAGradientLayer *keyGradient = [CAGradientLayer layer];
             keyGradient.colors = [NSArray arrayWithObjects:(id)[UIColor colorWithWhite:0.0 alpha:1].CGColor, (id)[UIColor colorWithWhite:0.0 alpha:1.0].CGColor ,nil];
             keyGradient.locations = [NSArray arrayWithObjects:@"0.0", @"1.0", nil];
             keyGradient.bounds = cell.bounds;
             keyGradient.anchorPoint = CGPointZero;
             keyGradient.opacity = 0.1;
             [cell.layer addSublayer:keyGradient];
             
             [UIView animateWithDuration:1.5 animations:^{
             // keyGradient.opacity = 0.0;
             } completion:^(BOOL finished) {
             //[keyGradient removeFromSuperlayer];
             }];
             */
            //[self showWordAtSelectedCell];
        }
    }
}

- (void)longTapPressHandle:(UITapGestureRecognizer *)gestureRecognizer
{
    if (gestureRecognizer.state == UIGestureRecognizerStateBegan) {
        CGPoint tapLocation = [gestureRecognizer locationInView:self.collectionView];
        self.indexPathOfCellInRemoveMode = [self.collectionView indexPathForItemAtPoint:tapLocation];
        
        [UIView animateWithDuration:0.5 animations:^{
            UICollectionViewCell *cell = [self.collectionView cellForItemAtIndexPath:self.indexPathOfCellInRemoveMode];
            //cell.center = CGPointMake(cell.center.x, cell.center.y - 88);
            cell.frame = CGRectMake(cell.frame.origin.x, cell.frame.origin.y + 88, cell.frame.size.width, cell.frame.size.height - 88);
        }];
        
        self.collectionView.scrollEnabled = NO;
    } else if (gestureRecognizer.state == UIGestureRecognizerStateEnded) {
        [UIView animateWithDuration:0.5 animations:^{
            UICollectionViewCell *cell = [self.collectionView cellForItemAtIndexPath:self.indexPathOfCellInRemoveMode];
           // cell.center = CGPointMake(cell.center.x, cell.center.y + 88);
            cell.frame = CGRectMake(cell.frame.origin.x, cell.frame.origin.y - 88, cell.frame.size.width, cell.frame.size.height + 88);
        }];
        
        self.indexPathOfCellInRemoveMode = nil;
        
        self.collectionView.scrollEnabled = YES;
    }
}

- (void)swipeCellRecognizer:(UISwipeGestureRecognizer *)gestureRecognizer
{
    CGPoint tapLocation = [gestureRecognizer locationInView:self.collectionView];
    NSIndexPath *newCellIndexPathToRemove = [self.collectionView indexPathForItemAtPoint:tapLocation];
    
    if (gestureRecognizer == self.swipeCellUpRecognizer) {
        if (newCellIndexPathToRemove != self.indexPathOfCellInRemoveMode) {
            [self prepareCellInRemoveModeWithUpDirection:NO];
        }
        self.indexPathOfCellInRemoveMode = [self.collectionView indexPathForItemAtPoint:tapLocation];
        [self prepareCellInRemoveModeWithUpDirection:YES];
    } else if (gestureRecognizer == self.swipeCellDownRecognizer) {
        if (newCellIndexPathToRemove == self.indexPathOfCellInRemoveMode) {
            [self prepareCellInRemoveModeWithUpDirection:NO];
            self.indexPathOfCellInRemoveMode = nil;
        }
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
    [cell preparePianoDecoratorRoundCorners];
    
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

#pragma mark - Auxiliary - Actions

- (void)showWordAtSelectedCell
{
    WDIndexDiaryCollectionViewCell *cell = (WDIndexDiaryCollectionViewCell *)[self.collectionView cellForItemAtIndexPath:self.selectedCellIndexPath];
    WDWord *selectedWord = [[WDWordDiary sharedWordDiary].words objectAtIndex:[WDWordDiary sharedWordDiary].words.count - self.selectedCellIndexPath.row - 1];
    WDPalette* palette = [selectedWord.emotion findPaletteOfIdName:selectedWord.paletteIdNameOfEmotion];
    [cell showInitialLetterOfWord:selectedWord.word fontFamily:selectedWord.style.familyFont andColor:[UIColor colorWithHexadecimalValue:palette.wordColor withAlphaComponent:NO skipInitialCharacter:NO]];
}

- (void)removeMenuFromPendingRemoveMenusWithIndexPath:(NSIndexPath *)indexPath
{
    UIView *removeMenu = [self.pendingRemoveMenus objectForKey:[NSNumber numberWithUnsignedInteger:indexPath.row]];
    [self.pendingRemoveMenus removeObjectForKey:removeMenu];
    [removeMenu removeFromSuperview];
}

- (void)removeButtonPressed:(UIButton *)button
{
    // En el tag se hallara el row de la celda
    NSLog(@"Llega evento");
    return;
    [self.collectionView performBatchUpdates:^{
        NSAssert(self.indexPathOfCellInRemoveMode.row == button.tag, @"Problemas de corcondancia entre el boton para borrar celda y la celda seleccionada a borrar");
        [self.collectionView deleteItemsAtIndexPaths:[NSArray arrayWithObject:self.indexPathOfCellInRemoveMode]];
        [self removeMenuFromPendingRemoveMenusWithIndexPath:self.indexPathOfCellInRemoveMode];
        self.indexPathOfCellInRemoveMode = nil;
    } completion:^(BOOL finished) {
    }];
}

@end
