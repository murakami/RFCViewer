//
//  RFC.m
//  RFCViewer
//
//  Created by 村上 幸雄 on 13/09/16.
//  Copyright (c) 2013年 Bitz Co., Ltd. All rights reserved.
//

#import "RFC.h"

@interface RFC ()
@end

@implementation RFC

@synthesize rfcNumber = _rfcNumber;
@synthesize title = _title;
@synthesize author1 = _author1;
@synthesize author2 = _author2;
@synthesize author3 = _author3;
@synthesize issueDate = _issueDate;
@synthesize format = _format;
@synthesize obsoletes = _obsoletes;
@synthesize obsoletedBy = _obsoletedBy;
@synthesize updates = _updates;
@synthesize updatedBy = _updatedBy;
@synthesize alsoFYI = _alsoFYI;
@synthesize status = _status;
@synthesize text = _text;

- (id)init
{
    //DBGMSG(@"%s", __func__);
    self = [super init];
    if (self) {
        _rfcNumber = nil;
        _title = nil;
        _author1 = nil;
        _author2 = nil;
        _author3 = nil;
        _issueDate = nil;
        _format = nil;
        _obsoletes = nil;
        _obsoletedBy = nil;
        _updates = nil;
        _updatedBy = nil;
        _alsoFYI = nil;
        _status = nil;
        _text = nil;
    }
    return self;
}

- (void)dealloc
{
    //DBGMSG(@"%s", __func__);
    self.rfcNumber = nil;
    self.title = nil;
    self.author1 = nil;
    self.author2 = nil;
    self.author3 = nil;
    self.issueDate = nil;
    self.format = nil;
    self.obsoletes = nil;
    self.obsoletedBy = nil;
    self.updates = nil;
    self.updatedBy = nil;
    self.alsoFYI = nil;
    self.status = nil;
    self.text = nil;
}

@end
