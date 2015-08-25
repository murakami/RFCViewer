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

extern NSString * const ConnectorRequestTypeKey;
extern NSString * const ConnectorRequestTypeRFCIndex;
extern NSString * const ConnectorRequestTypeRFC;

extern NSString * const ConnectorRFCIndexKey;

@interface Connector : NSObject

@property (assign, readonly, nonatomic, getter=isNetworkAccessing) BOOL networkAccessing;

+ (Connector *)sharedConnector;
- (void)requestWithParams:(NSDictionary *)params completionHandler:(ResponseParserCompletionHandler)completionHandler;
- (void)cancelWithResponseParser:(id<ResponseParserProtocol>)aParser;
- (void)cancelWithParams:(NSDictionary *)params;
- (void)cancelAll;

@end
