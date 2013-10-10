//
//  Connector.m
//  RFCViewer
//
//  Created by 村上 幸雄 on 13/09/16.
//  Copyright (c) 2013年 Bitz Co., Ltd. All rights reserved.
//

#import "Connector.h"

NSString    *ConnectorDidBeginRfc = @"ConnectorDidBeginRfc";
NSString    *ConnectorInProgressRfc = @"ConnectorInProgressRfc";
NSString    *ConnectorDidFinishRfc = @"ConnectorDidFinishRfc";

@interface Connector () <RFCResponseParserDelegate>
@property (strong, nonatomic) NSOperationQueue  *queue;
@property (strong, nonatomic) NSMutableArray    *parsers;
- (void)_notifyRfcStatusWithParser:(RFCResponseParser *)parser;
@end

@implementation Connector

@synthesize queue = _queue;
@synthesize parsers = _parsers;

+ (Connector *)sharedConnector
{
    static Connector *_sharedInstance = nil;
    static dispatch_once_t onceToken;
    
    dispatch_once(&onceToken, ^{
        _sharedInstance = [[Connector alloc] init];
    });
	return _sharedInstance;
}

- (id)init
{
    DBGMSG(@"%s", __func__);
    self = [super init];
    if (self) {
        _queue = [[NSOperationQueue alloc]init];
        _parsers = [[NSMutableArray alloc] init];
    }
    return self;
}

- (void)dealloc
{
    DBGMSG(@"%s", __func__);
    self.queue = nil;
    self.parsers = nil;
}

- (BOOL)isNetworkAccessing
{
    return self.parsers.count > 0;
}

- (void)rfcIndexWithCompletionHandler:(RFCResponseParserCompletionHandler)completionHandler
{
    DBGMSG(@"%s", __func__);
    /* インデックスが0だと目次文書と判断させる */
    [self rfcWithIndex:0 completionHandler:completionHandler];
}

- (void)rfcWithIndex:(NSUInteger)index completionHandler:(RFCResponseParserCompletionHandler)completionHandler
{
    DBGMSG(@"%s", __func__);
    BOOL    networkAccessing = self.networkAccessing;
    
    /* パーサのインスタンスを生成 */
    RFCResponseParser   *parser = [[RFCResponseParser alloc] init];
    parser.index = index;
    parser.queue = self.queue;
    parser.delegate = self;
    parser.completionHandler = completionHandler;
    
    /* 通信開始 */
    [parser parse];
    if (parser.error) {
        /* 通信開始エラー */
        NSMutableDictionary *userInfo = [NSMutableDictionary dictionary];
        [userInfo setObject:parser forKey:@"parser"];
        [[NSNotificationCenter defaultCenter] postNotificationName:ConnectorDidFinishRfc
                                                            object:self
                                                          userInfo:userInfo];
        if (parser.completionHandler) {
            parser.completionHandler(parser);
        }
        return;
    }
    
    /* 通信中パーサを配列に格納 */
    [self.parsers addObject:parser];
    
    /* 通信中インジケータの更新 */
    if (networkAccessing != self.networkAccessing) {
        [self willChangeValueForKey:@"networkAccessing"];
        [self didChangeValueForKey:@"networkAccessing"];
    }
    
    /* 通信開始を通知 */
    NSMutableDictionary *userInfo = [NSMutableDictionary dictionary];
    [userInfo setObject:parser forKey:@"parser"];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:ConnectorDidBeginRfc object:self userInfo:userInfo];
}

- (void)cancelWithIndex:(NSUInteger)index
{
    DBGMSG(@"%s", __func__);
    NSArray *parsers = [self.parsers copy];
    for (RFCResponseParser *parser in parsers) {
        if (parser.index == index) {
            [parser cancel];
            
            NSMutableDictionary *userInfo = [NSMutableDictionary dictionary];
            [userInfo setObject:parser forKey:@"parser"];
            
            [[NSNotificationCenter defaultCenter] postNotificationName:ConnectorDidFinishRfc
                                                                object:self
                                                              userInfo:userInfo];
            
            /* 通信中インジケータの更新 */
            [self willChangeValueForKey:@"networkAccessing"];
            [self.parsers removeObject:parser];
            [self didChangeValueForKey:@"networkAccessing"];
        }
    }
}

- (void)cancelAll
{
    DBGMSG(@"%s", __func__);
    for (RFCResponseParser *parser in self.parsers) {
        [parser cancel];
    }
    
    NSMutableDictionary *userInfo = [NSMutableDictionary dictionary];
    [userInfo setObject:self.parsers forKey:@"parsers"];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:ConnectorDidFinishRfc object:self userInfo:userInfo];
    
    /* 通信中インジケータの更新 */
    [self willChangeValueForKey:@"networkAccessing"];
    [self.parsers removeAllObjects];
    [self didChangeValueForKey:@"networkAccessing"];
}

- (void)parser:(RFCResponseParser*)parser didReceiveResponse:(NSURLResponse*)response
{
    DBGMSG(@"%s", __func__);
}

- (void)parser:(RFCResponseParser *)parser didReceiveData:(NSData *)data
{
    DBGMSG(@"%s", __func__);
}

- (void)parserDidFinishLoading:(RFCResponseParser *)parser
{
    DBGMSG(@"%s", __func__);
    if ([self.parsers containsObject:parser]) {
        [self _notifyRfcStatusWithParser:parser];
    }
}

- (void)parser:(RFCResponseParser *)parser didFailWithError:(NSError*)error
{
    DBGMSG(@"%s", __func__);
    if ([self.parsers containsObject:parser]) {
        [self _notifyRfcStatusWithParser:parser];
    }
}

- (void)parserDidCancel:(RFCResponseParser *)parser
{
    DBGMSG(@"%s", __func__);
    if ([self.parsers containsObject:parser]) {
        [self _notifyRfcStatusWithParser:parser];
    }
}

- (void)_notifyRfcStatusWithParser:(RFCResponseParser *)parser
{
    DBGMSG(@"%s", __func__);
    NSMutableDictionary *userInfo = [NSMutableDictionary dictionary];
    [userInfo setObject:parser forKey:@"parser"];
    
    /* 通信完了を通知（通知センター） */
    [[NSNotificationCenter defaultCenter] postNotificationName:ConnectorDidFinishRfc
                                                        object:self
                                                      userInfo:userInfo];
    /* 通信完了を通知（Blocks） */
    if (parser.completionHandler) {
        parser.completionHandler(parser);
    }
    
    /* 通信中インジケータの更新 */
    [self willChangeValueForKey:@"networkAccessing"];
    [self.parsers removeObject:parser];
    [self didChangeValueForKey:@"networkAccessing"];
}

@end
