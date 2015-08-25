//
//  DetailViewController.m
//  RFCViewer
//
//  Created by 村上 幸雄 on 13/09/15.
//  Copyright (c) 2013年 Bitz Co., Ltd. All rights reserved.
//

#import "Document.h"
#import "Connector.h"
#import "RFCResponseParser.h"
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
        self.title = self.rfc.rfcNumber;
        self.rfcTextView.text = self.rfc.text;
    }
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    if (self.rfc.text) {
        [self configureView];
    }
    
    /* RFC文書の取得要求を投げる */
    __block DetailViewController * __weak blockWeakSelf = self;
    [[Connector sharedConnector] requestWithParams:@{ConnectorRequestTypeKey: ConnectorRequestTypeRFCIndex,
                                                         ConnectorRFCIndexKey: self.rfc.rfcNumber}
                                     completionHandler:^(id<ResponseParserProtocol> parser) {
        /* 応答を受けた際の処理 */
        DetailViewController *tempSelf = blockWeakSelf;
        if (! tempSelf) return;
        
        RFCResponseParser *rfcResponseParser = parser;
        if (parser && rfcResponseParser.rfc) {
            tempSelf.rfc.text = rfcResponseParser.rfc;
        }
        [tempSelf configureView];
    }];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

@end
