//
//  DetailViewController.m
//  RFCViewer
//
//  Created by 村上 幸雄 on 13/09/15.
//  Copyright (c) 2013年 Bitz Co., Ltd. All rights reserved.
//

#import "Document.h"
#import "Connector.h"
#import "DetailViewController.h"

@interface DetailViewController ()
- (void)configureView;
@end

@implementation DetailViewController

@synthesize rfc = _rfc;
@synthesize rfcTextView = _rfcTextView;

#pragma mark - Managing the detail item

- (void)setRfc:(RFC *)rfc
{
    if (_rfc != rfc) {
        _rfc = rfc;
        
        [self configureView];
    }
}

- (void)configureView
{
    if (self.rfc) {
        self.rfcTextView.text = self.rfc.text;
    }
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    if (self.rfc.text) {
        [self configureView];
    }
    
    __block DetailViewController * __weak blockWeakSelf = self;
    [[Connector sharedConnector] rfcWithIndex:[self.rfc.rfcNumber integerValue] completionHandler:^(RFCResponseParser *parser) {
        DetailViewController *tempSelf = blockWeakSelf;
        if (! tempSelf) return;
        
        tempSelf.rfc.text = parser.rfc;
        [tempSelf configureView];
    }];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

@end
