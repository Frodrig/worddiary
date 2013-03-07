//
//  WDAllWordsScreenViewController.m
//  Word Diary
//
//  Created by Fernando Rodríguez Martínez on 26/02/13.
//  Copyright (c) 2013 Fernando Rodríguez Martínez. All rights reserved.
//

#import "WDAllWordsScreenViewController.h"
#import "WDSelectedWordScreenViewController.h"
#import "WDTodayWordCell.h"
#import "WDPreviousDayWordCell.h"
#import "WDWordDiary.h"
#import "WDWord.h"
#import "WDFont.h"
#import "WDUtils.h"
#import "WDBackgroundStore.h"
#import "WDBackgroundView.h"

static const NSUInteger TAG_HEADERSECTION_LABEL = 50;

@interface WDAllWordsScreenViewController ()

@property (weak, nonatomic) IBOutlet UITableView   *allWordsTableView;
@property (strong, nonatomic) NSMutableDictionary  *words;
@property (strong, nonatomic) NSMutableArray       *headerViewsOfSections;

- (NSArray *) findWordsOfSection:(NSInteger)section;
- (BOOL)      haveTodayYearPreviousWords;
- (WDWord *)  findWordForIndexPath:(NSIndexPath *)indexPath;
- (WDWord *)  findTodayWord;

@end

@implementation WDAllWordsScreenViewController

#pragma mark - Synthesize

@synthesize allWordsTableView      = allWordsTableView_;
@synthesize words                  = words_;
@synthesize headerViewsOfSections  = headerViewsOfSections_;

#pragma mark - Getters & Setters
- (NSMutableArray *)headerViewsOfSections
{
    if (nil == headerViewsOfSections_) {
        headerViewsOfSections_ = [NSMutableArray array];
    }
    
    return headerViewsOfSections_;
}

#pragma mark - Init

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        [self prepareWordsContainer];
    }
    return self;
}

- (void)prepareWordsContainer
{
    // Nota: Dentro de cada año, las palabras estan de mas antiguas a mas nuevas (orden inverso al usado)
    self.words = [NSMutableDictionary dictionary];
    
    NSArray *wordsContainer = [WDWordDiary sharedWordDiary].words;
    for (WDWord *word in wordsContainer) {
        NSNumber *year = [NSNumber numberWithInteger:word.dateComponents.year];
        NSMutableArray *wordsOfYear = [self.words objectForKey:year];
        if (nil == wordsOfYear) {
            wordsOfYear = [NSMutableArray arrayWithObject:word];
            [self.words setObject:wordsOfYear forKey:year];
        } else {
            [wordsOfYear addObject:word];
        }
    }
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // Do any additional setup after loading the view from its nib.
    [self.allWordsTableView registerClass:[WDTodayWordCell class] forCellReuseIdentifier:@"WDTodayWordCell"];
    [self.allWordsTableView registerClass:[WDPreviousDayWordCell class] forCellReuseIdentifier:@"WDPreviousDayWordCell"];
    
    [self.allWordsTableView registerNib:[UINib nibWithNibName:@"WDTodayWordCell" bundle:nil] forCellReuseIdentifier:@"WDTodayWordCell"];
    [self.allWordsTableView registerNib:[UINib nibWithNibName:@"WDPreviousDayWordCell" bundle:nil] forCellReuseIdentifier:@"WDPreviousDayWordCell"];
    
    //self.allWordsTableView.backgroundColor = [UIColor blackColor];
    self.allWordsTableView.backgroundView = nil;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];

    // TODO: Para asegurarnos de que a la vuelta de la pantalla de seleccion esta todo reflejado, recargamos
    //       Esto hay que hacerlo de otra forma: usar notificaciones o similar para notificar y que en esta pantalla se produzca recarga
    //[self.allWordsTableView reloadData];
}

- (void)viewDidAppear:(BOOL)animated
{
    //[self.allWordsTableView reloadData];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - TableView Auxiliary Methods

- (NSArray *)findWordsOfSection:(NSInteger)section
{
    // Section 0 es hoy (año actual)
    // Section 1 año actual si despues de quitar la palabra actual tiene mas palabras
    // Ordenamos de manera descendente comparando contra el objeto 2 en un bloque
    NSArray *result = nil;
    NSArray *ordererKeys = self.words.allKeys;
    ordererKeys = [ordererKeys sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2) {
        NSNumber *keyObj1 = obj1;
        NSNumber *keyObj2 = obj2;
        return [keyObj2 compare:keyObj1];
    }];
    
    if (0 == section) {
        NSMutableArray *wordsOfTodayYear = [self.words objectForKey:[ordererKeys objectAtIndex:0]];
        result = [NSArray arrayWithObject:[wordsOfTodayYear objectAtIndex:0]];
    } else {
        NSInteger wordsKeyIndex = [self haveTodayYearPreviousWords] ? section - 1 : section;
        NSMutableArray *wordsOfSection = [self.words objectForKey:[ordererKeys objectAtIndex:wordsKeyIndex]];
        if (0 == wordsKeyIndex) {
            // Estamos en el año de la palabra actual que ocupa ademas la primera posicion, la descartamos
            result = [wordsOfSection subarrayWithRange:NSMakeRange(1, wordsOfSection.count - 1)];
            NSAssert(result.count < wordsOfSection.count, @"Se ha generado el subarray mal");
        } else {
            result = [NSArray arrayWithArray:wordsOfSection];
        }
    }
    
    return result;
}

- (BOOL)haveTodayYearPreviousWords
{
    NSCalendar *calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
    NSDate *todayDate = [NSDate date];
    NSDateComponents *todayDateComponents = [calendar components:NSYearCalendarUnit fromDate:todayDate];
    NSNumber *todayYear = [NSNumber numberWithInteger:todayDateComponents.year];
    NSMutableArray *todayYearWords = [self.words objectForKey:todayYear];
    
    return todayYearWords.count > 1;
}

- (WDWord *)findWordForIndexPath:(NSIndexPath *)indexPath
{
    NSArray *wordsOfSection = [self findWordsOfSection:indexPath.section];
    WDWord *word = [wordsOfSection objectAtIndex:indexPath.row];
    
    return word;
}

- (WDWord *)findTodayWord
{
    WDWord *todayWord = [self findWordForIndexPath:[NSIndexPath indexPathForItem:0 inSection:0]];
    
    return todayWord;
}

#pragma mark - UITableViewDelegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    CGFloat height = 70.0;
    if (indexPath.section == 0) {
        height = 200.0;
    }
    
    return height;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    WDWord *selectedWord = [self findWordForIndexPath:indexPath];
    WDSelectedWordScreenViewController *selectedWordScreenViewController = [[WDSelectedWordScreenViewController alloc] initWithSelectedWord:selectedWord];
    selectedWordScreenViewController.modalTransitionStyle = UIModalTransitionStyleFlipHorizontal;
    [self presentViewController:selectedWordScreenViewController animated:YES completion:nil];
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UIView *headerView = nil;
    if (section < self.headerViewsOfSections.count) {
        headerView = [self.headerViewsOfSections objectAtIndex:section];
    } else {
        NSArray *wordsOfSection = [self findWordsOfSection:section];
        WDWord *referenceWord = [wordsOfSection objectAtIndex:0];
        BOOL todaySection = [referenceWord isTodayWord];
        NSArray *nib = [[NSBundle mainBundle] loadNibNamed: todaySection ? @"WDTodayWordSectionHeader" : @"WDPreviousDaysWordSectionHeader" owner:self options:nil];
        headerView = [nib objectAtIndex:0];
        UILabel *label = (UILabel *)[headerView viewWithTag:TAG_HEADERSECTION_LABEL];
        label.text = todaySection ? NSLocalizedString(@"TAG_TODAYSECTION", @"") : [NSString stringWithFormat:@"%d", referenceWord.dateComponents.year];
        
        [self.headerViewsOfSections addObject:headerView];
    }
    
    return headerView;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 44.0;
    /*
    UIView *headerView = [self.headerViewsOfSections objectAtIndex:section];
  
    return headerView.frame.size.height;
     */
}

#pragma mark - UITableViewDataSource

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    WDWord *word = [self findWordForIndexPath:indexPath];
    
    UITableViewCell *retCell = nil;
    if (indexPath.section == 0) {
        static NSString *todayCellIdentifier = @"WDTodayWordCell";
        WDTodayWordCell *cell = [self.allWordsTableView dequeueReusableCellWithIdentifier:todayCellIdentifier];
        [[WDBackgroundStore sharedStore] releaseBackgroundWithID:cell.idBackground];
        cell.wordLabel.text = word.word;
        cell.wordLabel.font = [UIFont fontWithName:word.font.family size:[WDUtils sizeOfWordForUI:UI_ALLWORDSSCREEN_TODAYWORD andFont:word.font]];
        cell.backgroundView = [[WDBackgroundView alloc] initWithFrame:cell.contentView.bounds];        
        cell.idBackground = [[WDBackgroundStore sharedStore] createBackgroundOfCategory:BC_GRADIENT forView:cell.backgroundView];
        //cell.idBackground = [[WDBackgroundStore sharedStore] createBackgroundOfCategory:BC_BACKGROUNDIMAGE_TESTCELL forView:cell.backgroundView];
        retCell = cell;
    } else {
        static NSString *previousDaysCellIdentifier = @"WDPreviousDayWordCell";
        WDPreviousDayWordCell *cell = [self.allWordsTableView dequeueReusableCellWithIdentifier:previousDaysCellIdentifier];
        [[WDBackgroundStore sharedStore] releaseBackgroundWithID:cell.idBackground];
        cell.wordLabel.text = word.word;
        cell.wordLabel.font = [UIFont fontWithName:word.font.family size:[WDUtils sizeOfWordForUI:UI_ALLWORDSSCREEN_PREVIOUSWORD andFont:word.font]];
        cell.dateViewContainer.alpha = 0.3;
        if ([WDUtils englishIsTheCurrentAppLanguage]) {
            cell.oneDateLabel.text = [NSString stringWithFormat:@"%@,",[WDUtils abreviateMonthString:word.dateComponents.month]];
            cell.twoDateLabel.text = [NSString stringWithFormat:@"%d", word.dateComponents.day];
        } else {
            cell.oneDateLabel.text = [NSString stringWithFormat:@"%d,",word.dateComponents.day];
            cell.twoDateLabel.text = [WDUtils abreviateMonthString:word.dateComponents.month];
        }
                
        retCell = cell;
    }
    
    return retCell;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // La seccion 0 siempre esta reservada al dia actual
    // Si el año al que pertecene la palabra actual no tiene mas palabras no habra que contarlo
    NSInteger result = [self haveTodayYearPreviousWords] ? 1 + self.words.count : self.words.count;
    
    return result;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSArray *wordsOfSection = [self findWordsOfSection:section];
    
    return wordsOfSection.count;
}

@end
