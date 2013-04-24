//
//  WDWordScreenCollectionViewController.m
//  Word Diary
//
//  Created by Fernando Rodríguez Martínez on 15/04/13.
//  Copyright (c) 2013 Fernando Rodríguez Martínez. All rights reserved.
//

#import "WDWordScreenCollectionViewController.h"
#import "WDWordDiary.h"
#import "WDWord.h"
#import "WDPalette.h"
#import "WDStyle.h"
#import "WDUtils.h"
#import "WDWordScreenCollectionViewCell.h"
#import "WDWordCharacterCounterView.h"
#import "WDMainMenuViewController.h"
#import "WDAddWordDayViewController.h"
#import "WDSettingsScreenViewController.h"
#import "UIColor+hexColorCreation.h"
#import <QuartzCore/QuartzCore.h>

static const NSUInteger MAX_WORD_LENGHT = 20;

@interface WDWordScreenCollectionViewController ()

@property (nonatomic, strong) WDWordCharacterCounterView    *wordCharacterCounterView;
@property (nonatomic, strong) NSTimer                       *fadeDecoratorTextTimer;
@property (nonatomic, strong) UITapGestureRecognizer        *tapGestureRecognizer;
@property (nonatomic, strong) UITapGestureRecognizer        *dobleTapGestureRecognizer;
@property (nonatomic, strong) UIPanGestureRecognizer        *panGestureRecognizer;
//@property (nonatomic, strong) UILongPressGestureRecognizer  *longPressGestureRecognizer;
@property (nonatomic, strong) UIView                        *styleMenuView;
@property (nonatomic, strong) NSTimer                       *cursorColorTimer;
@property (nonatomic, strong) UIColor                       *cursorColor;
@property (nonatomic, strong) UIView                        *pannelBackgroundView;
@property (nonatomic, strong) WDMainMenuViewController      *mainMenuViewController;
@property (nonatomic, strong) NSIndexPath                   *indexPathForWordWhenAppear;
@property (nonatomic) BOOL                                  otherViewControllerInDismissMode;

- (NSUInteger)                       convertIndexPathToWordIndexContainer:(NSIndexPath *)indexPath;
- (NSIndexPath *)                    convertWordIndexContainerToIndexPath:(NSUInteger)index;

- (void)                             hideMainMenuViewController;

- (void)                             launchFadeDateAndDayTextTimer;
- (void)                             endFadeDateAndDayTextTimer;
- (void)                             fadeInDateAndDayTextOnCell:(WDWordScreenCollectionViewCell *)cell withInfiniteDuration:(BOOL)infiniteDuration;
- (void)                             fadeDateAndDayTextTimerHandle:(NSTimer *)timer;

- (void)                             tapGestureRecognizerHandle:(UITapGestureRecognizer *)gesture;
- (void)                             panGestureRecognizerHandle:(UIPanGestureRecognizer *)gesture;
//- (void)                             longPressGestureRecognizerHandle:(UILongPressGestureRecognizer *)gesture;
- (void)                             dobleTapGestureRecognizerHandle:(UITapGestureRecognizer *)gesture;

- (WDWordScreenCollectionViewCell *) findSelectedCell;
- (WDWord *)                         findSelectedWord;
- (WDWord *)                         findSelectedWordAtSectionIndex:(NSUInteger)sectionIndex;

- (NSIndexPath *)                    indexPathForLastWord;
- (NSIndexPath *)                    indexPathForWord:(WDWord *)word;

- (void)                             launchCursorColorTimer;
- (void)                             endCursorColorTimer;
- (void)                             cursorColorTimerHandle:(NSTimer *)timer;

- (void)                             styleButtonPressed:(UIButton *)button;

@end

@implementation WDWordScreenCollectionViewController

#pragma mark - Synthesize

@synthesize wordCharacterCounterView           = wordCharacterCounterView_;
@synthesize fadeDecoratorTextTimer             = fadeDecoratorTextTimer_;
@synthesize tapGestureRecognizer               = tapGestureRecognizer_;
@synthesize dobleTapGestureRecognizer          = dobleTapGestureRecognizer_;
@synthesize panGestureRecognizer               = panGestureRecognizer_;
//@synthesize longPressGestureRecognizer         = longPressGestureRecognizer_;
@synthesize cursorColorTimer                   = cursorColorTimer_;
@synthesize cursorColor                        = cursorColor_;
@synthesize styleMenuView                      = styleMenuView_;
@synthesize pannelBackgroundView               = pannelBackgroundView_;
@synthesize mainMenuViewController             = mainMenuViewController_;
@synthesize indexPathForWordWhenAppear         = indexPathForWordWhenAppear_;
@synthesize otherViewControllerInDismissMode   = otherWordViewControllerInDismissMode_;

#pragma mark - Properties

- (WDMainMenuViewController *)mainMenuViewController {
    if (nil == mainMenuViewController_) {
        mainMenuViewController_ = [[WDMainMenuViewController alloc] initWithNibName:nil bundle:nil];
        mainMenuViewController_.delegate = self;
        mainMenuViewController_.dataSource  = self;
        
    }
    return mainMenuViewController_;
}

- (UIView *)pannelBackgroundView {
    if (nil == pannelBackgroundView_) {
        pannelBackgroundView_ = [[UIView alloc] initWithFrame:self.view.frame];
        pannelBackgroundView_.backgroundColor = [UIColor blackColor];
    }
    return pannelBackgroundView_;
}

#pragma mark - Init

- (id)init
{
    self = [super initWithCollectionViewLayout:[[UICollectionViewFlowLayout alloc] init]];
    if (self) {
        // Teclado
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShowNotification:) name:UIKeyboardWillShowNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHideNotification:) name:UIKeyboardWillHideNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardDidHideNotification:) name:UIKeyboardDidHideNotification object:nil];
    }
    return self;
}

- (id)initWithCollectionViewLayout:(UICollectionViewLayout *)layout
{
    return [self init];
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    return [self init];
}

- (void) dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)viewDidLoad
{
    [super viewDidLoad];

	// Do any additional setup after loading the view.

    // Gestures
    self.panGestureRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(panGestureRecognizerHandle:)];
    [self.view addGestureRecognizer:self.panGestureRecognizer];
    
    self.dobleTapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(dobleTapGestureRecognizerHandle:)];
    self.dobleTapGestureRecognizer.numberOfTapsRequired = 2;
    self.dobleTapGestureRecognizer.numberOfTouchesRequired = 1;
    [self.view addGestureRecognizer:self.dobleTapGestureRecognizer];
    
    self.tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapGestureRecognizerHandle:)];
    [self.view addGestureRecognizer:self.tapGestureRecognizer];
    [self.tapGestureRecognizer requireGestureRecognizerToFail:self.dobleTapGestureRecognizer];
    
    /*
    self.longPressGestureRecognizer = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longPressGestureRecognizerHandle:)];
    self.longPressGestureRecognizer.minimumPressDuration = 0.15;
    self.longPressGestureRecognizer.allowableMovement = NO;
    [self.view addGestureRecognizer:self.longPressGestureRecognizer];
    [self.longPressGestureRecognizer requireGestureRecognizerToFail:self.tapGestureRecognizer];
    */
    
    // Collection
    self.collectionView.delegate = self;
    self.collectionView.dataSource = self;
    [self.collectionView registerNib:[UINib nibWithNibName:@"WDWordScreenCollectionViewCell" bundle:[NSBundle mainBundle]] forCellWithReuseIdentifier:@"WordScreenCell"];
    self.collectionView.pagingEnabled = YES;
    self.collectionView.showsHorizontalScrollIndicator = NO;
    self.collectionView.showsVerticalScrollIndicator = NO;
    
    // Counter
    self.wordCharacterCounterView = [[WDWordCharacterCounterView alloc] initWithFrame:CGRectMake(0.0, 0.0, 150.0, 88.0) andDataSource:self];
    self.wordCharacterCounterView.delegate = self;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    // Cfg layout
    UICollectionViewFlowLayout *flowLayout = (UICollectionViewFlowLayout *)self.collectionView.collectionViewLayout;
    flowLayout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
    flowLayout.minimumInteritemSpacing = 0;
    flowLayout.minimumLineSpacing = 0;
    const CGFloat edgeMargin = 3.0;
    flowLayout.itemSize = CGSizeMake(self.view.bounds.size.width - edgeMargin * 2, self.view.bounds.size.height - edgeMargin * 2);
    flowLayout.sectionInset = UIEdgeInsetsMake(edgeMargin, edgeMargin, edgeMargin, edgeMargin);
    
    // StyleMenu
    self.styleMenuView = [[UIView alloc] initWithFrame:CGRectMake(0.0, 0.0, self.view.bounds.size.width, 54.0)];
    NSArray *styles = [WDWordDiary sharedWordDiary].styles;
    const CGFloat areaPerButton = self.styleMenuView.bounds.size.width / styles.count;
    for (NSUInteger styleIt = 0; styleIt < styles.count; styleIt++) {
        UIButton *styleButtonIt = [UIButton buttonWithType:UIButtonTypeCustom];
        styleButtonIt.frame = CGRectMake(areaPerButton * styleIt, 0.0, areaPerButton, self.styleMenuView.bounds.size.height);
        [styleButtonIt setTitle:[NSString stringWithFormat:@"%d", styleIt] forState:UIControlStateNormal];
        styleButtonIt.backgroundColor = [UIColor colorWithWhite:0.3 alpha:0.2];
        styleButtonIt.autoresizingMask = UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleWidth;
        // Nota: Incremento en 1 en el tag debido a que no se permite guardar tags con valor 0
        styleButtonIt.tag = styleIt + 1;
        styleButtonIt.alpha = 0.0;
        [styleButtonIt addTarget:self action:@selector(styleButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
        [self.styleMenuView addSubview:styleButtonIt];
    }
    
    // Scroll a la ultima palabra
    [self.collectionView scrollToItemAtIndexPath:self.indexPathForWordWhenAppear == nil ? [self indexPathForLastWord] : self.indexPathForWordWhenAppear atScrollPosition:UICollectionViewScrollPositionNone animated:NO];
    self.indexPathForWordWhenAppear = nil;
    
    // Timers
    [self launchFadeDateAndDayTextTimer];
    [self launchCursorColorTimer];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Auxiliary

- (void)styleButtonPressed:(UIButton *)button
{
    WDWord *word = [self findSelectedWord];
    WDStyle *newStyle = [[WDWordDiary sharedWordDiary].styles objectAtIndex:button.tag - 1];
    if (newStyle != word.style) {
        word.style = newStyle;
        WDWordScreenCollectionViewCell *cell = [self findSelectedCell];
        [cell.wordRepresentationView setNeedsDisplay];
    }
}

- (void) fadeInDateAndDayTextOnCell:(WDWordScreenCollectionViewCell *)cell withInfiniteDuration:(BOOL)infiniteDuration;
{
    if (nil == self.fadeDecoratorTextTimer) {
        [cell fadeInDataAndDayText];
    }
    
    if (infiniteDuration) {
        [self.fadeDecoratorTextTimer invalidate];
        self.fadeDecoratorTextTimer = nil;
    } else {
        [self launchFadeDateAndDayTextTimer];
    }

}

- (NSUInteger) convertIndexPathToWordIndexContainer:(NSIndexPath *)indexPath
{
    NSUInteger retValue = [WDWordDiary sharedWordDiary].words.count - indexPath.section - 1;
    
    return retValue;
}

- (NSIndexPath *)convertWordIndexContainerToIndexPath:(NSUInteger)index
{
    NSIndexPath *retIndexPath = [NSIndexPath indexPathForRow:0 inSection:[WDWordDiary sharedWordDiary].words.count - index - 1];
    
    return retIndexPath;
}

- (WDWord *) findSelectedWordAtSectionIndex:(NSUInteger)sectionIndex
{
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:0 inSection:sectionIndex];
    NSUInteger wordIndexPath = [self convertIndexPathToWordIndexContainer:indexPath];
    
    return [[WDWordDiary sharedWordDiary].words objectAtIndex:wordIndexPath];
}

- (WDWord *) findSelectedWord
{
    WDWordScreenCollectionViewCell *selectedCell = [self findSelectedCell];
    WDWord *selectedWord = [self findSelectedWordAtSectionIndex:[self.collectionView indexPathForCell:selectedCell].section];
    
    return selectedWord;
}

- (NSIndexPath *) indexPathForLastWord
{
    return [NSIndexPath indexPathForRow:0 inSection:[WDWordDiary sharedWordDiary].words.count - 1];
}

- (NSIndexPath *)indexPathForWord:(WDWord *)word
{
    NSUInteger indexOfWord = [[WDWordDiary sharedWordDiary].words indexOfObject:word];
    NSIndexPath *indexPathOfWord = [self convertWordIndexContainerToIndexPath:indexOfWord];
    
    return indexPathOfWord;
}

- (WDWordScreenCollectionViewCell *) findSelectedCell
{
    NSUInteger sectionIndex = (self.collectionView.contentOffset.x / self.collectionView.bounds.size.width) + 0.5;
    WDWordScreenCollectionViewCell *cell = (WDWordScreenCollectionViewCell *)[self.collectionView cellForItemAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:sectionIndex]];
    
    return cell;
}

- (void)hideMainMenuViewController
{
    if (self.mainMenuViewController.view.superview != nil) {
        [UIView animateWithDuration:0.25 animations:^{
            self.pannelBackgroundView.alpha = 0.0;
            self.mainMenuViewController.view.alpha = 0.0;
        } completion:^(BOOL finished) {
            [self.pannelBackgroundView removeFromSuperview];
            [self.mainMenuViewController.view removeFromSuperview];
        }];
        [self.mainMenuViewController.view removeFromSuperview];
    }
}

/*
- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
 // MUY INTERESANTE PARA HACER EFECTO OSCURECIDO 
    NSLog(@"hey");
}
*/
/*
- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    NSLog(@"ops");
    if (self.pendingDeleteIndexPath) {
        [[WDWordDiary sharedWordDiary] removeWord:[self findSelectedWordAtSectionIndex:self.pendingDeleteIndexPath.section]];
        [self.collectionView deleteSections:[NSIndexSet indexSetWithIndex:self.pendingDeleteIndexPath.section]];
        
        // Debemos de recalcular el tag para todas las celdas que se hallaran a la derecha de la que hemos borrado
        // Trabajaremos con las celdas de la cache que tengan su tag incorrecto, lo sabremos al ir pidiendo celdas de forma
        // secuencial y ver que su tag no corresponde con la seccion a la que pertenecen. En el momento en que casen los valores
        // todo se habra ajustado (pues se estarán creando de nuevo celdas)
        NSIndexPath *indexPathFixTagIt = [NSIndexPath indexPathForRow:0 inSection:self.pendingDeleteIndexPath.section > 0 ? self.pendingDeleteIndexPath.section - 1 : 0];
        BOOL fixTagEnd = NO;
        while (!fixTagEnd) {
            WDWordScreenCollectionViewCell *cell = (WDWordScreenCollectionViewCell *)[self.collectionView cellForItemAtIndexPath:indexPathFixTagIt];
            if (cell.wordRepresentationView.tag != indexPathFixTagIt.section) {
                cell.wordRepresentationView.tag = indexPathFixTagIt.section;
                indexPathFixTagIt = [NSIndexPath indexPathForRow:indexPathFixTagIt.row inSection:self.pendingDeleteIndexPath.section + 1];
            } else {
                fixTagEnd = YES;
            }
        }

        self.pendingDeleteIndexPath = nil;
    }
}
*/
#pragma mark - UICollectionViewDelegate
/*
- (void)collectionView:(UICollectionView *)collectionView didEndDisplayingCell:(UICollectionViewCell *)cell forItemAtIndexPath:(NSIndexPath *)indexPath
{
    if ([[NSUserDefaults standardUserDefaults] boolForKey:@"REMOVE_DAYS_WITHOUT_WORDS"]) {
        NSUInteger wordIndexPathToCheck = [self convertIndexPathToWordIndexContainer:indexPath];
        WDWord *wordToCheck = [[WDWordDiary sharedWordDiary].words objectAtIndex:wordIndexPathToCheck];
        if (![wordToCheck isTodayWord] && wordToCheck.word.length == 0) {
            self.pendingDeleteIndexPath = indexPath;
        }
    }
}
*/
/*
- (void)collectionView:(UICollectionView *)collectionView didEndDisplayingCell:(UICollectionViewCell *)cell forItemAtIndexPath:(NSIndexPath *)indexPath
{
    if ([[NSUserDefaults standardUserDefaults] boolForKey:@"REMOVE_DAYS_WITHOUT_WORDS"]) {
        NSUInteger wordIndexPathToCheck = [self convertIndexPathToWordIndexContainer:indexPath];
        WDWord *wordToCheck = [[WDWordDiary sharedWordDiary].words objectAtIndex:wordIndexPathToCheck];
        if (![wordToCheck isTodayWord] && wordToCheck.word.length == 0) {
            self.pendingDeleteIndexPath = indexPath;
            BOOL scrollCollectionView = NO;
            NSIndexPath *newIndexPathForSelectedCell = [self.collectionView indexPathForCell:[self findSelectedCell]];
            if (newIndexPathForSelectedCell.section > indexPath.section) {
                newIndexPathForSelectedCell = [NSIndexPath indexPathForRow:0.0 inSection:newIndexPathForSelectedCell.section - 1];
                scrollCollectionView = YES;
            }
            [[WDWordDiary sharedWordDiary] removeWord:wordToCheck];
            [self.collectionView deleteSections:[NSIndexSet indexSetWithIndex:indexPath.section]];
            if (scrollCollectionView) {
                [self.collectionView scrollToItemAtIndexPath:newIndexPathForSelectedCell atScrollPosition:UICollectionViewScrollPositionNone animated:YES];
            }
            
            // Debemos de recalcular el tag para todas las celdas que se hallaran a la derecha de la que hemos borrado
            // Trabajaremos con las celdas de la cache que tengan su tag incorrecto, lo sabremos al ir pidiendo celdas de forma
            // secuencial y ver que su tag no corresponde con la seccion a la que pertenecen. En el momento en que casen los valores
            // todo se habra ajustado (pues se estarán creando de nuevo celdas)
            BOOL fixTagEnd = NO;
            while (!fixTagEnd) {
                WDWordScreenCollectionViewCell *cell = (WDWordScreenCollectionViewCell *)[self.collectionView cellForItemAtIndexPath:newIndexPathForSelectedCell];
                if (cell.wordRepresentationView.tag != newIndexPathForSelectedCell.section) {
                    cell.wordRepresentationView.tag = newIndexPathForSelectedCell.section;
                    newIndexPathForSelectedCell = [NSIndexPath indexPathForRow:newIndexPathForSelectedCell.row inSection:newIndexPathForSelectedCell.section + 1];
                } else {
                    fixTagEnd = YES;
                }
            }
        }
    }
}
*/
#pragma mark - UICollectionViewDataSource

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    // Nota IMPORTANTE: En el tag del wordRepresentation guardamos la seccion del indexPath
    WDWordScreenCollectionViewCell *cell = (WDWordScreenCollectionViewCell *)[collectionView dequeueReusableCellWithReuseIdentifier:@"WordScreenCell" forIndexPath:indexPath];
    cell.wordRepresentationView.dataSource = self;
    cell.wordRepresentationView.clearsContextBeforeDrawing = YES;
    cell.wordRepresentationView.tag = indexPath.section;
    
    WDWord *word = [[WDWordDiary sharedWordDiary].words objectAtIndex:[self convertIndexPathToWordIndexContainer:indexPath]];
    [cell setWord:word];
        
    return cell;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return 1.0;
}

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return [WDWordDiary sharedWordDiary].words.count;
}

#pragma mark - Timers

- (void)launchFadeDateAndDayTextTimer
{
    [self.fadeDecoratorTextTimer invalidate];
    self.fadeDecoratorTextTimer = [NSTimer scheduledTimerWithTimeInterval:2.0 target:self selector:@selector(fadeDateAndDayTextTimerHandle:) userInfo:nil repeats:NO];
}

- (void) endFadeDateAndDayTextTimer
{
    [self.fadeDecoratorTextTimer invalidate];
    self.fadeDecoratorTextTimer = nil;
}

- (void)fadeDateAndDayTextTimerHandle:(NSTimer *)timer
{
    WDWordScreenCollectionViewCell * visibleCell = [self.collectionView.visibleCells objectAtIndex:0];
    [visibleCell fadeOutDataAndDayText];
    
    self.fadeDecoratorTextTimer = nil;
}

- (void) launchCursorColorTimer
{
    [self.cursorColorTimer invalidate];
    self.cursorColorTimer = [NSTimer scheduledTimerWithTimeInterval:0.5 target:self selector:@selector(cursorColorTimerHandle:) userInfo:nil repeats:YES];
}

- (void) endCursorColorTimer
{
    [self.cursorColorTimer invalidate];
    self.cursorColorTimer = nil;
}

- (void)cursorColorTimerHandle:(NSTimer *)timer
{
    WDWord *selectedWord = [self findSelectedWord];
    if  (self.cursorColor) {
        CGFloat colorComponents[] = {0.0, 0.0, 0.0, 0.0};
        [self.cursorColor getRed:&colorComponents[0] green:&colorComponents[1] blue:&colorComponents[2] alpha:&colorComponents[3]];
        colorComponents[3] = colorComponents[3] < 1.0 ? 1.0 : 0.3;
        self.cursorColor = [UIColor colorWithRed:colorComponents[0] green:colorComponents[1] blue:colorComponents[2] alpha:colorComponents[3]];
    } else {
        self.cursorColor = [selectedWord.palette makeWordColorObject];
    }
    
    WDWordScreenCollectionViewCell *actualCell = [self findSelectedCell];
    [actualCell.wordRepresentationView setNeedsDisplay];
}

#pragma mark - Gesture Recognizer

- (void)tapGestureRecognizerHandle:(UITapGestureRecognizer *)gesture
{
    if (gesture == self.tapGestureRecognizer) {
        if (self.mainMenuViewController.view.superview != nil) {
            [self hideMainMenuViewController];
        } else {
            WDWordScreenCollectionViewCell *cell = [self findSelectedCell];
            CGPoint hitPoint = [gesture locationInView:cell];
            if (CGRectContainsPoint(cell.wordRepresentationContainerView.frame, hitPoint)) {
                WDWordScreenCollectionViewCell *cell = [self findSelectedCell];
                
                // Scroll
                self.collectionView.scrollEnabled = NO;
                
                // Date and Day
                [self endFadeDateAndDayTextTimer];
                
                // Wordcharacter counter
                self.wordCharacterCounterView.frame = CGRectMake((self.view.bounds.size.width - self.wordCharacterCounterView.bounds.size.width) / 2, -self.wordCharacterCounterView.bounds.size.height, self.wordCharacterCounterView.bounds.size.width, self.wordCharacterCounterView.bounds.size.height);
                [self.view addSubview:self.wordCharacterCounterView];
                
                // Wordrepresentation - WordCharacterCounter animation
                [UIView setAnimationCurve:UIViewAnimationCurveEaseOut];
                [UIView animateWithDuration:0.5 animations:^{
                    cell.wordRepresentationContainerView.center = CGPointMake(cell.wordRepresentationContainerView.center.x, cell.wordRepresentationContainerView.center.y - 0.30 * cell.wordRepresentationContainerView.bounds.size.height);
                    cell.dateContainerView.alpha = 0.0;
                    cell.dayDiaryContainerView.alpha = 0.0;
                    self.wordCharacterCounterView.frame = CGRectMake(self.wordCharacterCounterView.frame.origin.x, 0.0, self.wordCharacterCounterView.bounds.size.width, self.wordCharacterCounterView.bounds.size.height);
                } completion:^(BOOL finished) {
                    [self becomeFirstResponder];
                }];
                
                [[NSNotificationCenter defaultCenter] postNotification:[NSNotification notificationWithName:@"WDSelectedWordWillEnterInEditMode" object:nil]];
            } else {
                [self fadeInDateAndDayTextOnCell:cell withInfiniteDuration:NO];
            }
        }
    }
}

- (void)panGestureRecognizerHandle:(UIPanGestureRecognizer *)gesture
{
    if (!self.isFirstResponder) {
        const BOOL fadeOutText = gesture.state == UIGestureRecognizerStateBegan;
        const BOOL fadeInText = gesture.state == UIGestureRecognizerStateEnded;
        WDPalette *newPalette = nil;
        
        if (gesture == self.panGestureRecognizer) {
            switch (gesture.state) {
                case UIGestureRecognizerStateBegan:
                case UIGestureRecognizerStateChanged: {
                    CGPoint translation = [gesture translationInView:self.view];
                    if (![WDUtils is:translation.y equalsTo:0.0]) {
                        const CGFloat minimumDistance = 5.0;
                        WDWord *word = [self findSelectedWord];
                        if (translation.y < 0.0 && abs(translation.y) > minimumDistance) {
                            newPalette = [[WDWordDiary sharedWordDiary] findNextPaletteOfPalette:word.palette];
                        } else if (translation.y > 0.0 && translation.y > minimumDistance) {
                            newPalette = [[WDWordDiary sharedWordDiary] findPrevPaletteOfPalette:word.palette];
                        }
                    }
                } break;
                    
                default:
                    break;
            }
        }
        
        if (fadeInText || fadeOutText) {
            WDWordScreenCollectionViewCell *cell = [self findSelectedCell];

            if (fadeOutText) {
                [self endFadeDateAndDayTextTimer];
                [cell pauseBackgroundColorAnimation];
            }
            
            const CGFloat alphaValue = fadeInText ? 1.0 : 0.0;
            [UIView setAnimationCurve:UIViewAnimationCurveEaseOut];
            [UIView animateWithDuration:0.25 animations:^{
                cell.dateContainerView.alpha = alphaValue;
                cell.wordRepresentationContainerView.alpha = alphaValue;
                cell.dayDiaryContainerView.alpha = alphaValue;
            } completion:^(BOOL finished) {
                if (fadeInText) {
                    [self launchFadeDateAndDayTextTimer];
                    [cell resumeBackgroundColorAnimation];
                }
            }];
        }
        
        if (newPalette) {
            WDWord *word = [self findSelectedWord];
            word.palette = newPalette;
            WDWordScreenCollectionViewCell *cell = [self findSelectedCell];
            [cell refreshBackgroundColorOfWord:word];
            [gesture setTranslation:CGPointZero inView:self.view];
        }
    }
}

/*
- (void)longPressGestureRecognizerHandle:(UILongPressGestureRecognizer *)gesture
{
    if (gesture.state == UIGestureRecognizerStateBegan) {
        if (self.mainMenuViewController.view.superview == nil) {
            [self.view addSubview:self.pannelBackgroundView];
            [self.view addSubview:self.mainMenuViewController.view];
            self.mainMenuViewController.view.center = CGPointMake(self.view.bounds.size.width / 2, self.view.bounds.size.height / 2);
            self.pannelBackgroundView.alpha = self.mainMenuViewController.view.alpha = 0.0;
            [UIView animateWithDuration:0.25 animations:^{
                self.pannelBackgroundView.alpha = 0.8;
                self.mainMenuViewController.view.alpha = 1.0;
            }];
        }
    }
}
*/

- (void)dobleTapGestureRecognizerHandle:(UITapGestureRecognizer *)gesture
{
    if (self.mainMenuViewController.view.superview == nil) {
        [self.view addSubview:self.pannelBackgroundView];
        [self.view addSubview:self.mainMenuViewController.view];
        self.mainMenuViewController.view.center = CGPointMake(self.view.bounds.size.width / 2, self.view.bounds.size.height / 2);
        self.pannelBackgroundView.alpha = self.mainMenuViewController.view.alpha = 0.0;
        [UIView animateWithDuration:0.25 animations:^{
            self.pannelBackgroundView.alpha = 0.8;
            self.mainMenuViewController.view.alpha = 1.0;
        }];
    }
}

#pragma mark - WDWordRepresentatonViewDataSource

- (NSString *)selectedWordTextForWordRepresentationView:(WDWordRepresentationView *)wordRepresentation
{
    WDWord *selectedWord = [self findSelectedWordAtSectionIndex:wordRepresentation.tag];
    return selectedWord.word;
}

- (UIColor *)selectedWordColorForWordRepresentationView:(WDWordRepresentationView *)wordRepresentation
{
    WDWord *word = [self findSelectedWord];
    return [word.palette makeWordColorObject];
}

- (NSString *) selectedWordTextFamilyFontForWordRepresentationView:(WDWordRepresentationView *)wordRepresentation
{
    WDWord *selectedWord = [self findSelectedWordAtSectionIndex:wordRepresentation.tag];
    return selectedWord.style.familyFont;
}

- (CGFloat) selectedWordFontStartSizeForWordRepresentationView:(WDWordRepresentationView *)wordRepresentation
{
    const CGFloat startFontSize = 100.0;
    return [WDUtils isIPhone5Screen] ? startFontSize * 1.15 : startFontSize * 0.9;
}

- (BOOL)isKeyboardActiveForWordRepresentationView:(WDWordRepresentationView *)wordRepresentation
{
    BOOL firstResponder = [self isFirstResponder];
    return firstResponder;
}

- (UIColor *)selectedWordCursorColorForWordRepresentationView:(WDWordRepresentationView *)wordRepresentation
{
    return self.cursorColor;
}

#pragma mark - Keyboard

#pragma mark - UIView sobrecarga

- (BOOL)canResignFirstResponder
{
    return YES;
}

- (BOOL)canBecomeFirstResponder
{
    // Solo en caso de que no se este volviendo de la pantalla de añadir fecha
    return !self.otherViewControllerInDismissMode;
}

#pragma mark - UIKeyInput

- (void) deleteBackward
{
    WDWord *selectedWord = [self findSelectedWord];
    if (selectedWord.word.length > 0) {
        selectedWord.word = [selectedWord.word substringWithRange:NSMakeRange(0, selectedWord.word.length - 1)];
        
        WDWordScreenCollectionViewCell *cell = [self findSelectedCell];
        [cell.wordRepresentationView setNeedsDisplay];
        [[NSNotificationCenter defaultCenter] postNotification:[NSNotification notificationWithName:@"WDSelectedWordInEditModeRemoveLastCharacter" object:nil]];
    }
}

- (BOOL) hasText
{
    WDWord *selectedWord = [self findSelectedWord];
    return selectedWord.word.length > 0;
}

- (void) insertText:(NSString *)text
{
    WDWord *selectedWord = [self findSelectedWord];
    if ([text stringByTrimmingCharactersInSet:[NSCharacterSet newlineCharacterSet]].length == 0) {
        [self resignFirstResponder];
    } else if ([text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]].length > 0) {
        if (selectedWord.word.length < MAX_WORD_LENGHT) {
            selectedWord.word = [selectedWord.word stringByAppendingString:text];
            
            WDWordScreenCollectionViewCell *cell = [self findSelectedCell];
            [cell.wordRepresentationView setNeedsDisplay];
            [[NSNotificationCenter defaultCenter] postNotification:[NSNotification notificationWithName:@"WDSelectedWordInEditModeAddedNewCharacter" object:nil]];
        }
    }
}

#pragma mark KeyboardNotification

- (void) keyboardWillShowNotification:(NSNotification *)notification
{
    WDWordScreenCollectionViewCell *cell = [self findSelectedCell];
 
    // Efecto fantasma
    [cell.wordRepresentationView generateGosthWordRepresentation];
    cell.wordRepresentationView.keyboardMode = YES;
    cell.wordRepresentationView.alpha = 0;
    [UIView animateWithDuration:1.0 animations:^{
        cell.wordRepresentationView.alpha = 1.0;
    }];
    [cell.wordRepresentationView setNeedsDisplay];
    
    // Style Menu
    CGRect endFrameKeyboard = [[notification.userInfo objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue];
    self.styleMenuView.frame = CGRectMake(0.0, endFrameKeyboard.origin.y - self.styleMenuView.bounds.size.height, self.styleMenuView.bounds.size.width, self.styleMenuView.bounds.size.height);
    [self.view addSubview:self.styleMenuView];
    NSNumber *keybAnimationDuration = [notification.userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey];
    for (NSUInteger styleIt = 0; styleIt < [WDWordDiary sharedWordDiary].styles.count; styleIt++) {
        CGFloat animationDuration = (keybAnimationDuration.floatValue + styleIt) * 0.25;
        [UIView animateWithDuration:animationDuration animations:^{
            [self.styleMenuView viewWithTag:styleIt + 1].alpha = 1.0;
        }];
    }
}

- (void)keyboardWillHideNotification:(NSNotification *)notification
{
    WDWordScreenCollectionViewCell *cell = [self findSelectedCell];
    
    // Wordrepresentation
    [cell.wordRepresentationView generateGosthWordRepresentation];
    cell.wordRepresentationView.keyboardMode = NO;
    cell.wordRepresentationView.alpha = 0;
    [UIView animateWithDuration:1.0 animations:^{
        cell.wordRepresentationView.alpha = 1.0;
    }];
    [cell.wordRepresentationView setNeedsDisplay];
    
    // Stylemenu
    NSNumber *keybAnimationDuration = [notification.userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey];
    for (NSUInteger styleIt = 0; styleIt < [WDWordDiary sharedWordDiary].styles.count; styleIt++) {
        CGFloat animationDuration = (keybAnimationDuration.floatValue + styleIt) * 0.25;
        NSUInteger buttonIndexToChange = [WDWordDiary sharedWordDiary].styles.count - styleIt - 1;
        if (buttonIndexToChange == 0) {
            [UIView animateWithDuration:animationDuration animations:^{
                [self.styleMenuView viewWithTag:buttonIndexToChange + 1].alpha = 0.0;
            } completion:^(BOOL finished) {
                if (!self.isFirstResponder) {
                    [self.styleMenuView removeFromSuperview];
                }
                // Wordrepresentation & Wordcharacter
                [UIView setAnimationCurve:UIViewAnimationCurveEaseOut];
                [UIView animateWithDuration:0.5 animations:^{
                    cell.wordRepresentationContainerView.center = CGPointMake(cell.wordRepresentationContainerView.center.x, cell.wordRepresentationContainerView.center.y + 0.30 * cell.wordRepresentationContainerView.bounds.size.height);
                    self.wordCharacterCounterView.frame = CGRectMake(self.wordCharacterCounterView.frame.origin.x, -self.wordCharacterCounterView.bounds.size.height, self.wordCharacterCounterView.bounds.size.width, self.wordCharacterCounterView.bounds.size.height);
                } completion:^(BOOL finished) {
                    [self fadeInDateAndDayTextOnCell:cell withInfiniteDuration:NO];
                    [self.wordCharacterCounterView removeFromSuperview];
                }];
            }];
        } else {
            [UIView animateWithDuration:animationDuration animations:^{
                [self.styleMenuView viewWithTag:buttonIndexToChange + 1].alpha = 0.0;
            }];
        }
    }
}

- (void)keyboardDidHideNotification:(NSNotification *)notification
{
    self.collectionView.scrollEnabled = YES;
}

#pragma mark - WDWordCharacterCounterViewDataSource

- (NSUInteger)numberOfFreeCharactersOfEditWordForWordCharacterCounterView:(WDWordCharacterCounterView *)wordCharacterCounterView
{
    WDWord *selectedWord = [self findSelectedWord];
    return MAX_WORD_LENGHT - selectedWord.word.length;
}

- (UIColor *)colorForWordCharacterCounterView:(WDWordCharacterCounterView *)wordCharacterCounterView
{
    WDWord *selectedWord = [self findSelectedWord];
    return [selectedWord.palette makeWordColorObject];
}

#pragma mark - WDWordCharacterCounterViewDelegate

- (void)redrawNeededForWordForWordCharacterCounterView:(WDWordCharacterCounterView *)wordCharacterCounterView
{
    [self.wordCharacterCounterView setNeedsDisplay];
}

#pragma mark - WDWordMainMenuViewControllerDelegate

- (void)removeOptionSelectedForMainMenuViewController:(WDMainMenuViewController *)mainMenuViewController
{
    WDWord *selectedWord = [self findSelectedWord];
    if (![selectedWord isTodayWord]) {
        NSIndexPath *selectedWordIndexPath = [self indexPathForWord:selectedWord];
        [[WDWordDiary sharedWordDiary] removeWord:selectedWord];
        [self.collectionView deleteSections:[NSIndexSet indexSetWithIndex:selectedWordIndexPath.section]];
        [self hideMainMenuViewController];
    }    
}

- (void)addOptionSelectedForMainMenuViewController:(WDMainMenuViewController *)mainMenuViewController
{    
    WDAddWordDayViewController *addWorDayViewController = [[WDAddWordDayViewController alloc] initWithNibName:nil bundle:nil];
    addWorDayViewController.delegate = self;
    
    [self presentViewController:addWorDayViewController animated:YES completion:^{
        [self hideMainMenuViewController];
    }];
}

- (void)settingsOptionSelectedForMainMenuViewController:(WDMainMenuViewController *)mainMenuViewController
{
    WDSettingsScreenViewController *settingsScreenViewController = [[WDSettingsScreenViewController alloc] initWithNibName:nil bundle:nil];
    settingsScreenViewController.delegate = self;
    
    [self presentViewController:settingsScreenViewController animated:YES completion:^{
        [self hideMainMenuViewController];
    }];
}

- (void)helpOptionSelectedForMainMenuViewController:(WDMainMenuViewController *)mainMenuViewController
{
    
}

#pragma mark - WDWordMainMenuViewControllerDataSource

- (BOOL)removeOptionAvailableForMainMenuViewController:(WDMainMenuViewController *)mainMenuViewController
{
    return ![[self findSelectedWord] isTodayWord];
}

#pragma - WDAddWordDayViewControllerDelegate

- (void)addWordDayViewController:(WDAddWordDayViewController *)addWordDayViewController createdNewWord:(WDWord *)word
{
    NSIndexPath *indexPathForWord = [self indexPathForWord:word];
    [self.collectionView insertSections:[NSIndexSet indexSetWithIndex:indexPathForWord.section]];
}

- (void)addWordDayViewController:(WDAddWordDayViewController *)addWordDayViewController willDismissWithSelectedWord:(WDWord *)word
{
    self.indexPathForWordWhenAppear = [self indexPathForWord:word];
}

- (void)addWordDayViewControllerWillDismiss:(WDAddWordDayViewController *)addWordDayViewController
{
    self.otherViewControllerInDismissMode = YES;
    [self fadeInDateAndDayTextOnCell:[self findSelectedCell] withInfiniteDuration:NO];
}

- (void)addWordDayViewControllerDidDismiss:(WDAddWordDayViewController *)addWordDayViewController
{
    self.otherViewControllerInDismissMode = NO;
}

#pragma mark - WDSettingsScreenViewControllerDelegate

- (void)settingsScreenViewControllerWillDismiss:(WDSettingsScreenViewController *)settingsScreenViewController
{
    self.otherViewControllerInDismissMode = YES;
    [self fadeInDateAndDayTextOnCell:[self findSelectedCell] withInfiniteDuration:NO];
    
    self.indexPathForWordWhenAppear = [self indexPathForWord:[self findSelectedWord]];
}

- (void)settingsScreenViewControllerDidDismiss:(WDSettingsScreenViewController *)settingsScreenViewController
{
    self.otherViewControllerInDismissMode = NO;
}

- (void)wordWithIndex:(NSArray *)index removedFromSettingsScreenViewControllerRemoveAllEmptyWordDays:(WDSettingsScreenViewController *)settingsScreenViewController;
{
    [self.collectionView performBatchUpdates:^{
        for (NSNumber *indexWordIt in index) {
            // Nota: No se usa el metodo de conversion de indices porque en este punto ya hay desincronia: se ha borrado en el modelo pero no en el collection
            [self.collectionView deleteSections:[NSIndexSet indexSetWithIndex:[WDWordDiary sharedWordDiary].words.count - indexWordIt.unsignedIntegerValue]];
        }
        
    } completion:nil];
}

- (void) backgroundAnimationGradientSettingsUpdateFromSettingsScreenViewController:(WDSettingsScreenViewController *)settingsScreenViewController
{
    [self.collectionView reloadData];
}

@end
    