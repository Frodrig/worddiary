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
#import "UIView+RoundedCorners.h"
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

- (NSUInteger)                       convertIndexRowToWordDiaryIndex:(NSUInteger)indexRow;

- (UICollectionViewFlowLayout *)     createAndConfigureCollectionViewFlowLayout;

- (void)                             tapHandle:(UITapGestureRecognizer *)gestureRecognizer;
- (void)                             longTapPressHandle:(UITapGestureRecognizer *)gestureRecognizer;
- (void)                             swipeCellRecognizer:(UISwipeGestureRecognizer *)gestureRecognizer;

- (void)                             removeMenuFromPendingRemoveMenusWithIndexPath:(NSIndexPath *)indexPath;
- (void)                             removeButtonPressed:(UIButton *)button;

- (void)                             showWordAtSelectedCell;

- (void)                             prepareCellInRemoveModeWithUpDirection:(BOOL)up andDuration:(CGFloat)duration;

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
    self.collectionView.clipsToBounds = YES;
    self.collectionView.layer.masksToBounds = YES;
    self.collectionView.opaque = YES;
    self.collectionView.bounces = NO;
    self.collectionView.backgroundColor = [UIColor clearColor];
    
    //[self.collectionView addRoundedCorners:UIRectCornerTopLeft | UIRectCornerTopRight withRadius:10.0];
    
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

- (void)prepareCellInRemoveModeWithUpDirection:(BOOL)up andDuration:(CGFloat)duration
{
    if (self.indexPathOfCellInRemoveMode) {
        const CGFloat moveDistance = 122.0;
        WDIndexDiaryCollectionViewCell *cell = (WDIndexDiaryCollectionViewCell *)[self.collectionView cellForItemAtIndexPath:self.indexPathOfCellInRemoveMode];
        NSIndexPath *indexPathOfCell = [self.indexPathOfCellInRemoveMode copy];

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
            removeBtn.enabled = ![[[WDWordDiary sharedWordDiary].words objectAtIndex:[self convertIndexRowToWordDiaryIndex:self.indexPathOfCellInRemoveMode.row]] isTodayWord];
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
        [UIView animateWithDuration:duration animations:^{
            cell.frame = CGRectMake(cell.frame.origin.x, up ? cell.frame.origin.y - moveDistance : cell.frame.origin.y + moveDistance, cell.frame.size.width, cell.frame.size.height);
        } completion:^(BOOL finished) {
            if (up) {
                // Cambiamos posicion menu para poder aceptar los eventos sobre el boton. En caso contrario estara detras del collectionview y no recibira
                // Nota: Inicialmente se pone detras para consegir el efecto persiana
                [self.view.superview insertSubview:removeMenuView aboveSubview:self.view];
            } else {
                // Destruimos el menu
                [self removeMenuFromPendingRemoveMenusWithIndexPath:indexPathOfCell];
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
            [self.delegate indexDiaryScreenViewController:self wordDoubleTapSelectedAtIndex:[self convertIndexRowToWordDiaryIndex:indexPath.row]];
        } else if (gestureRecognizer == self.singleTapGestureRecognizer) {
            self.selectedCellIndexPath = indexPath;
            
            
            WDIndexDiaryCollectionViewCell *cell = (WDIndexDiaryCollectionViewCell *)[self.collectionView cellForItemAtIndexPath:indexPath];
            const NSUInteger wordIndex = [self convertIndexRowToWordDiaryIndex:indexPath.row];
            WDWord *word = [[WDWordDiary sharedWordDiary].words objectAtIndex:wordIndex];
            WDPalette* palette = [word.emotion findPaletteOfIdName:word.paletteIdNameOfEmotion];
            
            [cell showInitialLetterOfWord:word.word fontFamily:word.style.familyFont andColor:[UIColor colorWithHexadecimalValue:palette.wordColor withAlphaComponent:NO skipInitialCharacter:NO]];
            [self.delegate indexDiaryScreenViewController:self wordSingleTapSelectedAtIndex:[self convertIndexRowToWordDiaryIndex:indexPath.row]];
            
            cell.keyContainerView.backgroundColor = [UIColor whiteColor];
            [UIView animateWithDuration:1 animations:^{
                cell.keyContainerView.backgroundColor = [UIColor colorWithHexadecimalValue:palette.backgroundColor withAlphaComponent:NO skipInitialCharacter:NO];
            } completion:^(BOOL finished) {
                cell.keyContainerView.backgroundColor = [UIColor clearColor];
            }];
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
            [self prepareCellInRemoveModeWithUpDirection:NO andDuration:0.3];
        }
        self.indexPathOfCellInRemoveMode = [self.collectionView indexPathForItemAtPoint:tapLocation];
        [self prepareCellInRemoveModeWithUpDirection:YES andDuration:0.3];
    } else if (gestureRecognizer == self.swipeCellDownRecognizer) {
        if (newCellIndexPathToRemove == self.indexPathOfCellInRemoveMode) {
            [self prepareCellInRemoveModeWithUpDirection:NO andDuration:0.3];
            self.indexPathOfCellInRemoveMode = nil;
        }
    }
}

#pragma mark - Auxiliary 

- (UICollectionViewFlowLayout *) createAndConfigureCollectionViewFlowLayout
{
    UICollectionViewFlowLayout *collectionViewFlow = [[UICollectionViewFlowLayout alloc] init];
    
    const CGFloat numItemsPerRow = 4.0;
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

- (NSUInteger)convertIndexRowToWordDiaryIndex:(NSUInteger)indexRow
{
    return [WDWordDiary sharedWordDiary].words.count - indexRow - 1;
}

#pragma mark - UICollectionViewDataSource

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    WDIndexDiaryCollectionViewCell *cell = [self.collectionView dequeueReusableCellWithReuseIdentifier:@"WDIndexDiaryCollectionViewCell" forIndexPath:indexPath];    
   
    WDWord *word = [[WDWordDiary sharedWordDiary].words objectAtIndex:[self convertIndexRowToWordDiaryIndex:indexPath.row]];
    const BOOL isTodayWord = [word isTodayWord];
    WDPalette* palette = [word.emotion findPaletteOfIdName:word.paletteIdNameOfEmotion];
    
    cell.dayDiaryLabel.text = [WDUtils convertNumberToStringWithTwoDigitsMin:[NSNumber numberWithInteger:[[WDWordDiary sharedWordDiary] findIndexPositionForWord:word]]];
    cell.dayDiaryLabel.textColor = [UIColor colorWithHexadecimalValue:palette.wordColor withAlphaComponent:NO skipInitialCharacter:NO];
    cell.dateLabel.text = [[word yearAsString] stringByAppendingFormat:@"\n%@", isTodayWord ? NSLocalizedString(@"TAG_TODAY", @"") : [word dayAndMonthAbreviateAsString]];
    cell.dateLabel.textColor = [cell.dayDiaryLabel.textColor copy];
    cell.layer.borderWidth = 0.5;
    cell.layer.borderColor = [UIColor blackColor].CGColor;
    cell.contentView.backgroundColor = [UIColor colorWithHexadecimalValue:palette.backgroundColor withAlphaComponent:NO skipInitialCharacter:NO];

    [cell configureRoundedCorners];
    
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
    [self prepareCellInRemoveModeWithUpDirection:NO andDuration:0];

    // Nota: en el tag TAMBIEN se halla el row de la celda
    NSAssert(self.indexPathOfCellInRemoveMode.row == button.tag, @"Problemas de corcondancia entre el boton para borrar celda y la celda seleccionada a borrar");
    NSUInteger wordDiaryIndex = [self convertIndexRowToWordDiaryIndex:self.indexPathOfCellInRemoveMode.row];
    [[WDWordDiary sharedWordDiary] removeWordAtIndexPosition:wordDiaryIndex];
    
    // Nota: El borrado logico del menu se hace tras el borrado de las celdas, para que todo este correcto visualmente, ponemos el boton detras de la view
    UIView *removeMenuView = [self.pendingRemoveMenus objectForKey:[NSNumber numberWithUnsignedInteger:self.indexPathOfCellInRemoveMode.row]];
    [self.view.superview insertSubview:removeMenuView belowSubview:self.view];
    
    [self.collectionView performBatchUpdates:^{
        [self.collectionView deleteItemsAtIndexPaths:[NSArray arrayWithObject:self.indexPathOfCellInRemoveMode]];
        //ToDo: Recarga de palabras
    } completion:^(BOOL finished) {
        [self removeMenuFromPendingRemoveMenusWithIndexPath:self.indexPathOfCellInRemoveMode];
        self.indexPathOfCellInRemoveMode = nil;
    }];
}

#pragma mark - UIScrollViewDelegate

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    if (self.indexPathOfCellInRemoveMode) {
        [self prepareCellInRemoveModeWithUpDirection:NO andDuration:0];
        self.indexPathOfCellInRemoveMode = nil;
    }
}

@end
