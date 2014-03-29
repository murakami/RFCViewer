//
//  Document.m
//  RFCViewer
//
//  Created by 村上 幸雄 on 13/09/16.
//  Copyright (c) 2013年 Bitz Co., Ltd. All rights reserved.
//

#import "Document.h"

@interface Document ()
@property (strong, readwrite, nonatomic) NSString   *indexUrlString;
@property (strong, nonatomic) NSString              *baseUrlString;
- (void)_clearDefaults;
- (void)_updateDefaults;
- (void)_loadDefaults;
- (NSString*)_modelDir;
- (NSString*)_modelPath;
@end

@implementation Document

@synthesize version = _version;
@synthesize indexUrlString = _indexUrlString;
@synthesize indexArray = _indexArray;
@synthesize baseUrlString = _baseUrlString;

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
        _indexUrlString = @"http://www.rfc-editor.org/rfc/rfc-index.txt";
        _indexArray = [[NSArray alloc] init];
        _baseUrlString = @"http://www.ietf.org/rfc";
    }
    return self;
}

- (void)dealloc
{
    DBGMSG(@"%s", __func__);
    self.version = nil;
    self.indexUrlString = nil;
    self.indexArray = nil;
    self.baseUrlString = nil;
}

- (void)load
{
    DBGMSG(@"%s", __func__);
    [self _loadDefaults];
    
    NSString    *modelPath = [self _modelPath];
    if ((! modelPath) || (! [[NSFileManager defaultManager] fileExistsAtPath:modelPath])) {
        return;
    }
    
    NSArray *indexArray;
    indexArray = [NSKeyedUnarchiver unarchiveObjectWithFile:modelPath];
    if (indexArray) {
        self.indexArray = indexArray;
    }
}

- (void)save
{
    DBGMSG(@"%s", __func__);
    [self _updateDefaults];
    
    NSFileManager   *fileManager = [NSFileManager defaultManager];
    
    NSString    *modelDir = [self _modelDir];
    if (![fileManager fileExistsAtPath:modelDir]) {
        NSError *error = nil;
        [fileManager createDirectoryAtPath:modelDir
               withIntermediateDirectories:YES
                                attributes:nil
                                     error:&error];
    }
    
    NSString    *modelPath = [self _modelPath];
    [NSKeyedArchiver archiveRootObject:self.indexArray toFile:modelPath];
}

- (NSString *)rfcUrlStringWithIndex:(NSUInteger)index
{
    NSString *urlString = [[NSString alloc] initWithFormat:@"%@/rfc%04u.txt", self.baseUrlString, (unsigned int)index];
    return urlString;
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

- (NSString*)_modelDir
{
    NSArray*    paths;
    NSString*   path;
    paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    if ([paths count] < 1) {
        return nil;
    }
    path = [paths objectAtIndex:0];
    
    path = [path stringByAppendingPathComponent:@".model"];
    return path;
}

- (NSString*)_modelPath
{
    NSString*   path;
    path = [[self _modelDir] stringByAppendingPathComponent:@"model.dat"];
    return path;
}

@end

/* End Of File */