//
//  Connector.h
//  RFCViewer
//
//  Created by 村上 幸雄 on 13/09/16.
//  Copyright (c) 2013年 Bitz Co., Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ResponseParserProtocol.h"

extern NSString * const ConnectorDidBegin;
extern NSString * const ConnectorInProgress;
extern NSString * const ConnectorDidFinish;
extern NSString * const ConnectorParser;
extern NSString * const ConnectorParsers;
extern NSString * const ConnectorNetworkAccessing;

@interface Connector : NSObject

@property (assign, readonly, nonatomic, getter=isNetworkAccessing) BOOL networkAccessing;

+ (Connector *)sharedConnector;
- (void)requestWithParams:(NSDictionary *)params completionHandler:(ResponseParserCompletionHandler)completionHandler;
- (void)cancelWithIndex:(NSUInteger)index;
- (void)cancelWithResponseParser:(id<ResponseParserProtocol>)aParser;
- (void)cancelAll;

@end
