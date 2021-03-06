//
//  Connector.m
//  RFCViewer
//
//  Created by 村上 幸雄 on 13/09/16.
//  Copyright (c) 2013年 Bitz Co., Ltd. All rights reserved.
//

#import "Connector.h"
#import "RFCResponseParser.h"

NSString * const ConnectorDidBegin              = @"ConnectorDidBegin";
NSString * const ConnectorInProgress            = @"ConnectorInProgress";
NSString * const ConnectorDidFinish             = @"ConnectorDidFinish";
NSString * const ConnectorParser                = @"parser";
NSString * const ConnectorParsers               = @"parsers";
NSString * const ConnectorNetworkAccessing      = @"networkAccessing";

NSString * const ConnectorRequestTypeKey        = @"ConnectorRequestTypeKey";
NSString * const ConnectorRequestTypeRFCIndex   = @"ConnectorRequestTypeRFCIndex";
NSString * const ConnectorRequestTypeRFC        = @"ConnectorRequestTypeRFC";

NSString * const ConnectorRFCIndexKey           = @"ConnectorRFCIndexKey";

@interface Connector () <ResponseParserDelegate>
@property (strong, nonatomic) NSOperationQueue  *queue;
@property (strong, nonatomic) NSMutableArray    *parsers;
- (id<ResponseParserProtocol>)_parserWithParams:(NSDictionary *)params
                                          queue:(NSOperationQueue *)queue
                                       delegate:(id<ResponseParserDelegate>)delegate
                              completionHandler:(ResponseParserCompletionHandler)completionHandler;
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

- (void)requestWithParams:(NSDictionary *)params completionHandler:(ResponseParserCompletionHandler)completionHandler
{
    DBGMSG(@"%s", __func__);
    BOOL    networkAccessing = self.networkAccessing;
    
    /* パーサのインスタンスを生成 */
    id<ResponseParserProtocol>  parser = [self _parserWithParams:params
                                                           queue:self.queue
                                                        delegate:self
                                               completionHandler:completionHandler];
    if (! parser) {
        /* パーサのインスタンスを生成エラー */
        NSMutableDictionary *userInfo = [NSMutableDictionary dictionary];
        [userInfo setObject:[NSNull null] forKey:ConnectorParser];
        [[NSNotificationCenter defaultCenter] postNotificationName:ConnectorDidFinish
                                                            object:self
                                                          userInfo:userInfo];
        if (parser.completionHandler) {
            parser.completionHandler(nil);
        }
        return;
    }
    
    /* 通信開始 */
    [parser parse];
    if (parser.error) {
        /* 通信開始エラー */
        NSMutableDictionary *userInfo = [NSMutableDictionary dictionary];
        [userInfo setObject:parser forKey:ConnectorParser];
        [[NSNotificationCenter defaultCenter] postNotificationName:ConnectorDidFinish
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
        [self willChangeValueForKey:ConnectorNetworkAccessing];
        [self didChangeValueForKey:ConnectorNetworkAccessing];
    }
    
    /* 通信開始を通知 */
    NSMutableDictionary *userInfo = [NSMutableDictionary dictionary];
    [userInfo setObject:parser forKey:ConnectorParser];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:ConnectorDidBegin object:self userInfo:userInfo];
}

- (void)_rfcIndexWithCompletionHandler:(ResponseParserCompletionHandler)completionHandler
{
    DBGMSG(@"%s", __func__);
    /* インデックスが0だと目次文書と判断させる */
    [self _rfcWithIndex:0 completionHandler:completionHandler];
}

- (void)_rfcWithIndex:(NSUInteger)index completionHandler:(ResponseParserCompletionHandler)completionHandler
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
        [userInfo setObject:parser forKey:ConnectorParser];
        [[NSNotificationCenter defaultCenter] postNotificationName:ConnectorDidFinish
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
        [self willChangeValueForKey:ConnectorNetworkAccessing];
        [self didChangeValueForKey:ConnectorNetworkAccessing];
    }
    
    /* 通信開始を通知 */
    NSMutableDictionary *userInfo = [NSMutableDictionary dictionary];
    [userInfo setObject:parser forKey:ConnectorParser];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:ConnectorDidBegin object:self userInfo:userInfo];
}

- (id<ResponseParserProtocol>)_parserWithParams:(NSDictionary *)params
                                          queue:(NSOperationQueue *)queue
                                       delegate:(id<ResponseParserDelegate>)delegate
                              completionHandler:(ResponseParserCompletionHandler)completionHandler
{
    DBGMSG(@"%s", __func__);
    id<ResponseParserProtocol> parser = nil;
    
    if (params) {
        NSString    *request = params[ConnectorRequestTypeKey];
        if (request && [request isEqualToString:ConnectorRequestTypeRFCIndex]) {
            RFCResponseParser *rfcResponseParser = [[RFCResponseParser alloc] init];
            rfcResponseParser.index = 0;
            rfcResponseParser.queue = self.queue;
            rfcResponseParser.delegate = self;
            rfcResponseParser.completionHandler = completionHandler;
            parser = rfcResponseParser;
        }
        else if (request && [request isEqualToString:ConnectorRequestTypeRFC]) {
            RFCResponseParser *rfcResponseParser = [[RFCResponseParser alloc] init];
            NSUInteger  index = 1;
            NSNumber    *indexNumber = params[ConnectorRFCIndexKey];
            if (indexNumber && [indexNumber isKindOfClass:[NSNumber class]]) {
                index = indexNumber.unsignedIntegerValue;
            }
            rfcResponseParser.index = index;
            rfcResponseParser.queue = self.queue;
            rfcResponseParser.delegate = self;
            rfcResponseParser.completionHandler = completionHandler;
            parser = rfcResponseParser;
        }
    }
    return parser;
}

- (void)cancelWithIndex:(NSUInteger)index
{
    DBGMSG(@"%s", __func__);
    NSArray *parsers = [self.parsers copy];
    for (RFCResponseParser *parser in parsers) {
        if (parser.index == index) {
            [parser cancel];
            
            NSMutableDictionary *userInfo = [NSMutableDictionary dictionary];
            [userInfo setObject:parser forKey:ConnectorParser];
            
            [[NSNotificationCenter defaultCenter] postNotificationName:ConnectorDidFinish
                                                                object:self
                                                              userInfo:userInfo];
            
            /* 通信中インジケータの更新 */
            [self willChangeValueForKey:ConnectorNetworkAccessing];
            [self.parsers removeObject:parser];
            [self didChangeValueForKey:ConnectorNetworkAccessing];
        }
    }
}

- (void)cancelWithResponseParser:(id<ResponseParserProtocol>)aParser
{
    DBGMSG(@"%s", __func__);
}

- (void)cancelWithParams:(NSDictionary *)params
{
    DBGMSG(@"%s", __func__);
}

- (void)cancelAll
{
    DBGMSG(@"%s", __func__);
    for (RFCResponseParser *parser in self.parsers) {
        [parser cancel];
    }
    
    NSMutableDictionary *userInfo = [NSMutableDictionary dictionary];
    [userInfo setObject:self.parsers forKey:ConnectorParsers];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:ConnectorDidFinish object:self userInfo:userInfo];
    
    /* 通信中インジケータの更新 */
    [self willChangeValueForKey:ConnectorNetworkAccessing];
    [self.parsers removeAllObjects];
    [self didChangeValueForKey:ConnectorNetworkAccessing];
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
    [userInfo setObject:parser forKey:ConnectorParser];
    
    /* 通信完了を通知（通知センター） */
    [[NSNotificationCenter defaultCenter] postNotificationName:ConnectorDidFinish
                                                        object:self
                                                      userInfo:userInfo];
    /* 通信完了を通知（Blocks） */
    if (parser.completionHandler) {
        parser.completionHandler(parser);
    }
    
    /* 通信中インジケータの更新 */
    [self willChangeValueForKey:ConnectorNetworkAccessing];
    [self.parsers removeObject:parser];
    [self didChangeValueForKey:ConnectorNetworkAccessing];
}

@end
