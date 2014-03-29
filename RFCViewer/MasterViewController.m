//
//  MasterViewController.m
//  RFCViewer
//
//  Created by 村上 幸雄 on 13/09/15.
//  Copyright (c) 2013年 Bitz Co., Ltd. All rights reserved.
//

#import "Document.h"
#import "Connector.h"
#import "MasterViewController.h"
#import "DetailViewController.h"

@interface MasterViewController ()

@property (strong, nonatomic) UIBarButtonItem   *refreshItem;
@property (strong, nonatomic) NSMutableArray    *sectionIndexArray;
- (void)_refresh:(id)sender;
- (void)_refreshIndex:(id)sender;
- (void)_updateSectionIndexArray;
- (void)_updateNavigationItem:(BOOL)animated;
@end

@implementation MasterViewController

@synthesize refreshItem = _refreshItem;
@synthesize sectionIndexArray = _sectionIndexArray;

- (void)awakeFromNib
{
    DBGMSG(@"%s", __func__);
    [super awakeFromNib];
}

- (void)dealloc
{
    DBGMSG(@"%s", __func__);
    self.refreshItem = nil;
    self.sectionIndexArray = nil;
}

- (void)viewDidLoad
{
    DBGMSG(@"%s", __func__);
    [super viewDidLoad];
    
    self.refreshItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:(UIBarButtonSystemItemRefresh)
                                                                     target:self
                                                                     action:@selector(_refresh:)];
    
    if (! self.sectionIndexArray)
        self.sectionIndexArray = [[NSMutableArray alloc] init];
    
    UIRefreshControl    *refreshControl = [[UIRefreshControl alloc] init];
    [refreshControl addTarget:self action:@selector(_refreshIndex:) forControlEvents:UIControlEventValueChanged];
    self.refreshControl = refreshControl;
    
    __block MasterViewController * __weak blockWeakSelf = self;
    [[Connector sharedConnector] rfcIndexWithCompletionHandler:^(RFCResponseParser *parser) {
        MasterViewController *tempSelf = blockWeakSelf;
        if (! tempSelf) return;
        
        [Document sharedDocument].indexArray = parser.indexArray;
        [tempSelf _updateSectionIndexArray];
        [tempSelf.tableView reloadData];
    }];
}

- (void)viewWillAppear:(BOOL)animated
{
    DBGMSG(@"%s", __func__);
    [super viewWillAppear:animated];
    
    [self _updateNavigationItem:animated];
}

- (void)viewWillLayoutSubviews
{
    [super viewWillLayoutSubviews];
}

- (void)viewDidLayoutSubviews
{
    [super viewDidLayoutSubviews];
}

- (void)viewDidAppear:(BOOL)animated
{
    DBGMSG(@"%s", __func__);
    [super viewDidAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated
{
    DBGMSG(@"%s", __func__);
    [super viewWillDisappear:animated];
}

- (void)viewDidDisappear:(BOOL)animated
{
    DBGMSG(@"%s", __func__);
    [super viewDidDisappear:animated];
}

- (void)viewWillUnload
{
    DBGMSG(@"%s", __func__);
    [super viewWillUnload];
}

- (void)viewDidUnload
{
    DBGMSG(@"%s", __func__);
    [super viewDidUnload];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

#pragma mark - Table View

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [Document sharedDocument].indexArray.count;
}

- (NSArray *)sectionIndexTitlesForTableView:(UITableView *)tableView
{
    return self.sectionIndexArray;
}

- (NSInteger)tableView:(UITableView *)tableView sectionForSectionIndexTitle:(NSString *)title atIndex:(NSInteger)index
{
    NSInteger   row = 0;
    for (row = 0; row < [Document sharedDocument].indexArray.count; row++) {
        RFC *rfc = [[Document sharedDocument].indexArray objectAtIndex:row];
        if ((index * 1000) <= [rfc.rfcNumber integerValue]) {
            break;
        }
    }
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:row inSection:0];
    [self.tableView scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionTop animated:NO];
    return index;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell" forIndexPath:indexPath];
    
    RFC *rfc = [[Document sharedDocument].indexArray objectAtIndex:indexPath.row];
    cell.textLabel.text = rfc.rfcNumber;
    cell.detailTextLabel.text = rfc.title;
    return cell;
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([[segue identifier] isEqualToString:@"showDetail"]) {
        NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
        RFC *rfc = [[Document sharedDocument].indexArray objectAtIndex:indexPath.row];
        [[segue destinationViewController] setRfc:rfc];
    }
}

- (void)_refresh:(id)sender
{
    if (![Connector sharedConnector].networkAccessing) {
        __block MasterViewController * __weak blockWeakSelf = self;
        [[Connector sharedConnector] rfcIndexWithCompletionHandler:^(RFCResponseParser *parser) {
            MasterViewController *tempSelf = blockWeakSelf;
            if (! tempSelf) return;
            
            [Document sharedDocument].indexArray = parser.indexArray;
            [tempSelf _updateSectionIndexArray];
            [tempSelf.tableView reloadData];
        }];
    }
}

- (void)_refreshIndex:(id)sender
{
    [self.refreshControl beginRefreshing];
    if (![Connector sharedConnector].networkAccessing) {
        __block MasterViewController * __weak blockWeakSelf = self;
        [[Connector sharedConnector] rfcIndexWithCompletionHandler:^(RFCResponseParser *parser) {
            MasterViewController *tempSelf = blockWeakSelf;
            if (! tempSelf) return;
            
            [Document sharedDocument].indexArray = parser.indexArray;
            [tempSelf _updateSectionIndexArray];
            [tempSelf.tableView reloadData];
        }];
    }
    [self.refreshControl endRefreshing];
}

- (void)_updateSectionIndexArray
{
    if ((! [Document sharedDocument].indexArray) || ([Document sharedDocument].indexArray.count == 0))
        return;
    
    RFC *rfc = [[Document sharedDocument].indexArray lastObject];
    NSString    *lastNumberString = rfc.rfcNumber;
    NSInteger   lastNumber = [lastNumberString integerValue];
    NSInteger   n = lastNumber / 1000;
    DBGMSG(@"%s lastNumber(%d) n(%d)", __func__, (int)lastNumber, (int)n);
    [self.sectionIndexArray removeAllObjects];
    for (NSInteger i = 0; i <= n; i++) {
        NSString    *sectionIndex = [[NSString alloc] initWithFormat:@"%04d", (int)(i * 1000)];
        [self.sectionIndexArray addObject:sectionIndex];
    }
}

- (void)_updateNavigationItem:(BOOL)animated
{
    [self.navigationItem setRightBarButtonItem:self.refreshItem animated:animated];
}

@end
