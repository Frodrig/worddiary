//
//  WDAllWordsScreenViewController.m
//  Word Diary
//
//  Created by Fernando Rodríguez Martínez on 26/02/13.
//  Copyright (c) 2013 Fernando Rodríguez Martínez. All rights reserved.
//

#import "WDAllWordsScreenViewController.h"
#import "WDTodayWordCell.h"
#import "WDPreviousDayWordCell.h"
#import "WDWordDiary.h"
#import "WDWord.h"
#import "WDUtils.h"

@interface WDAllWordsScreenViewController ()

@property (weak, nonatomic) IBOutlet UITableView   *allWordsTableView;
@property (strong, nonatomic) NSMutableDictionary  *words;

- (NSArray *) findWordsOfSection:(NSInteger)section;
- (BOOL)      haveTodayYearPreviousWords;
- (WDWord *)  findWordForIndexPath:(NSIndexPath *)indexPath;

@end

@implementation WDAllWordsScreenViewController

#pragma mark - Synthesize

@synthesize allWordsTableView = allWordsTableView_;
@synthesize words = words_;

#pragma mark - Init

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
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
    
    self.navigationItem.title = NSLocalizedString(@"TAG_ALLWORDSSCREENVIEWCONTROLLER_TITLE", @"");
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - TableView Auxiliary Methods

- (NSArray *)findWordsOfSection:(NSInteger)section
{
    // Section 0 es hoy (año actua)
    // Section 1 año actual si despues de quitar la palabra actual tiene mas palabras
    NSArray *result = nil;
    NSArray *ordererKeys = [self.words keysSortedByValueUsingSelector:@selector(compare:)];
    if (0 == section) {
        NSMutableArray *wordsOfTodayYear = [self.words objectForKey:[ordererKeys objectAtIndex:0]];
        result = [NSArray arrayWithObject:[wordsOfTodayYear objectAtIndex:0]];
    } else {
        NSInteger wordsKeyIndex = [self haveTodayYearPreviousWords] ? section - 1 : section;
        NSMutableArray *wordsOfSection = [self.words objectForKey:[ordererKeys objectAtIndex:wordsKeyIndex]];
        if (0 == wordsKeyIndex) {
            // Estamos en el año de la palabra actual que ocupa ademas la primera posicion, la descartamos
            result = [wordsOfSection subarrayWithRange:NSMakeRange(1, wordsOfSection.count - 1)];
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
    WDWord *word = [wordsOfSection objectAtIndex:indexPath.section];
    
    return word;
}

#pragma mark - UITableViewDelegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    CGFloat height = 70.0;
    if (indexPath.section == 0) {
        height = 66;
    }
    
    return height;
}


#pragma mark - UITableViewDataSource

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    WDWord *word = [self findWordForIndexPath:indexPath];
    
    UITableViewCell *retCell = nil;
    if (indexPath.section == 0) {
        static NSString *todayCellIdentifier = @"WDTodayWordCell";
        WDTodayWordCell *cell = [self.allWordsTableView dequeueReusableCellWithIdentifier:todayCellIdentifier];
        
        cell.wordLabel.text = word.word;
        retCell = cell;
    } else {
        static NSString *previousDaysCellIdentifier = @"WDPreviousDayWordCell";
        WDPreviousDayWordCell *cell = [self.allWordsTableView dequeueReusableCellWithIdentifier:previousDaysCellIdentifier];
        
        cell.wordLabel.text = word.word;
        cell.dayLabel.text = [NSString stringWithFormat:@"%d", word.dateComponents.day];
        cell.monthLabel.text = [WDUtils abreviateMonthString:word.dateComponents.year];
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

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    NSArray *wordsOfSection = [self findWordsOfSection:section];
    WDWord *referenceWord = [wordsOfSection objectAtIndex:0];
    
    NSCalendar *todayCalendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
    NSDate *todayDate = [NSDate date];
    NSDateComponents *todayDateComponents = [todayCalendar components:NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit fromDate:todayDate];
    
    NSString *result = nil;
    if ([referenceWord.dateComponents.date compare:todayDateComponents.date] == NSOrderedSame) {
        result = NSLocalizedString(@"TAG_TODAYSECTION", @"");
    } else {
        result = [NSString stringWithFormat:@"%d", referenceWord.dateComponents.year];
    }
    
    return result;
}

@end
