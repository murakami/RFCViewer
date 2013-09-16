//
//  Document.m
//  RFCViewer
//
//  Created by 村上 幸雄 on 13/09/16.
//  Copyright (c) 2013年 Bitz Co., Ltd. All rights reserved.
//

#import "Document.h"

@interface Document ()
- (void)_clearDefaults;
- (void)_updateDefaults;
- (void)_loadDefaults;
@end

@implementation Document

@synthesize version = _version;

+ (Document *)sharedDocument;
{
    static Document *_sharedInstance = nil;
    static dispatch_once_t onceToken;
    
    dispatch_once(&onceToken, ^{
        _sharedInstance = [[Document alloc] init];
    });
	return _sharedInstance;
}

- (id)init
{
    DBGMSG(@"%s", __func__);
    self = [super init];
    if (self) {
        _version = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"];
    }
    return self;
}

- (void)dealloc
{
    DBGMSG(@"%s", __func__);
    self.version = nil;
}

- (void)load
{
    DBGMSG(@"%s", __func__);
    [self _loadDefaults];
}

- (void)save
{
    DBGMSG(@"%s", __func__);
    [self _updateDefaults];
}

- (void)_clearDefaults
{
    DBGMSG(@"%s", __func__);
    if ([[NSUserDefaults standardUserDefaults] objectForKey:@"version"]) {
        [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"version"];
    }
}

- (void)_updateDefaults
{
    DBGMSG(@"%s", __func__);
    NSString    *versionString = nil;
    if ([[NSUserDefaults standardUserDefaults] objectForKey:@"version"]) {
        versionString = [[NSUserDefaults standardUserDefaults] objectForKey:@"version"];
    }
    if ((versionString == nil) || ([versionString compare:self.version] != NSOrderedSame)) {
        [[NSUserDefaults standardUserDefaults] setObject:self.version forKey:@"version"];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
}

- (void)_loadDefaults
{
    DBGMSG(@"%s", __func__);
    NSString    *versionString = nil;
    if ([[NSUserDefaults standardUserDefaults] objectForKey:@"version"]) {
        versionString = [[NSUserDefaults standardUserDefaults] objectForKey:@"version"];
    }
    if ((versionString == nil) || ([versionString compare:self.version] != NSOrderedSame)) {
        /* バージョン不一致対応 */
    }
    else {
        /* 読み出し */
    }
}

@end

/* End Of File */