//
//  RFC.m
//  RFCViewer
//
//  Created by 村上 幸雄 on 13/09/16.
//  Copyright (c) 2013年 Bitz Co., Ltd. All rights reserved.
//

#import "RFC.h"

@interface RFC ()
@property (strong, readwrite, nonatomic) NSString   *identifier;
@end

@implementation RFC

@synthesize identifier = _identifier;
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
        CFUUIDRef   uuid = CFUUIDCreate(NULL);
        _identifier = (NSString *)CFBridgingRelease(CFUUIDCreateString(NULL, uuid));
        _rfcNumber = @"";
        _title = @"";
        _author1 = @"";
        _author2 = @"";
        _author3 = @"";
        _issueDate = @"";
        _format = @"";
        _obsoletes = @"";
        _obsoletedBy = @"";
        _updates = @"";
        _updatedBy = @"";
        _alsoFYI = @"";
        _status = @"";
        _text = @"";
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)decoder
{
    //DBGMSG(@"%s", __func__);
    self = [super init];
    if (self) {
        _identifier = [decoder decodeObjectForKey:@"identifier"];
        _rfcNumber = [decoder decodeObjectForKey:@"rfcNumber"];
        _title = [decoder decodeObjectForKey:@"title"];
        _author1 = [decoder decodeObjectForKey:@"author1"];
        _author2 = [decoder decodeObjectForKey:@"author2"];
        _author3 = [decoder decodeObjectForKey:@"author3"];
        _issueDate = [decoder decodeObjectForKey:@"issueDate"];
        _format = [decoder decodeObjectForKey:@"format"];
        _obsoletes = [decoder decodeObjectForKey:@"obsoletes"];
        _obsoletedBy = [decoder decodeObjectForKey:@"obsoletedBy"];
        _updates = [decoder decodeObjectForKey:@"updates"];
        _updatedBy = [decoder decodeObjectForKey:@"updatedBy"];
        _alsoFYI = [decoder decodeObjectForKey:@"alsoFYI"];
        _status = [decoder decodeObjectForKey:@"status"];
        _text = [decoder decodeObjectForKey:@"text"];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)encoder
{
    //DBGMSG(@"%s", __func__);
    [encoder encodeObject:self.identifier forKey:@"identifier"];
    [encoder encodeObject:self.rfcNumber forKey:@"rfcNumber"];
    [encoder encodeObject:self.title forKey:@"title"];
    [encoder encodeObject:self.author1 forKey:@"author1"];
    [encoder encodeObject:self.author2 forKey:@"author2"];
    [encoder encodeObject:self.author3 forKey:@"author3"];
    [encoder encodeObject:self.issueDate forKey:@"issueDate"];
    [encoder encodeObject:self.format forKey:@"format"];
    [encoder encodeObject:self.obsoletes forKey:@"obsoletes"];
    [encoder encodeObject:self.obsoletedBy forKey:@"obsoletedBy"];
    [encoder encodeObject:self.updates forKey:@"updates"];
    [encoder encodeObject:self.updatedBy forKey:@"updatedBy"];
    [encoder encodeObject:self.alsoFYI forKey:@"alsoFYI"];
    [encoder encodeObject:self.status forKey:@"status"];
    [encoder encodeObject:self.text forKey:@"text"];
}

- (void)dealloc
{
    //DBGMSG(@"%s", __func__);
    self.identifier = nil;
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
