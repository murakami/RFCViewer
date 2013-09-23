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
- (void)_refreshIndex:(id)sender;
@end

@implementation MasterViewController

- (void)awakeFromNib
{
    DBGMSG(@"%s", __func__);
    [super awakeFromNib];
}

- (void)dealloc
{
    DBGMSG(@"%s", __func__);
}

- (void)viewDidLoad
{
    DBGMSG(@"%s", __func__);
    [super viewDidLoad];
    
    UIRefreshControl    *refreshControl = [[UIRefreshControl alloc] init];
    [refreshControl addTarget:self action:@selector(_refreshIndex:) forControlEvents:UIControlEventValueChanged];
    self.refreshControl = refreshControl;
    
    __block MasterViewController * __weak blockWeakSelf = self;
    [[Connector sharedConnector] rfcIndexWithCompletionHandler:^(RFCResponseParser *parser) {
        MasterViewController *tempSelf = blockWeakSelf;
        if (! tempSelf) return;
        
        [Document sharedDocument].indexArray = parser.indexArray;
        [tempSelf.tableView reloadData];
    }];
}

- (void)viewWillAppear:(BOOL)animated
{
    DBGMSG(@"%s", __func__);
    [super viewWillAppear:animated];
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

- (void)_refreshIndex:(id)sender
{
    [self.refreshControl beginRefreshing];
    if (![Connector sharedConnector].networkAccessing) {
        __block MasterViewController * __weak blockWeakSelf = self;
        [[Connector sharedConnector] rfcIndexWithCompletionHandler:^(RFCResponseParser *parser) {
            MasterViewController *tempSelf = blockWeakSelf;
            if (! tempSelf) return;
            
            [Document sharedDocument].indexArray = parser.indexArray;
            [tempSelf.tableView reloadData];
        }];
    }
    [self.refreshControl endRefreshing];
}

@end
