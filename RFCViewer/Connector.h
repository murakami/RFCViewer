//
//  Connector.h
//  RFCViewer
//
//  Created by 村上 幸雄 on 13/09/16.
//  Copyright (c) 2013年 Bitz Co., Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "RFCResponseParser.h"

extern NSString *ConnectorDidBeginRfc;
extern NSString *ConnectorInProgressRfc;
extern NSString *ConnectorDidFinishRfc;

@interface Connector : NSObject

@property (assign, readonly, nonatomic, getter=isNetworkAccessing) BOOL networkAccessing;

+ (Connector *)sharedConnector;
- (void)rfcIndexWithCompletionHandler:(RFCResponseParserCompletionHandler)completionHandler;
- (void)rfcWithIndex:(NSUInteger)index completionHandler:(RFCResponseParserCompletionHandler)completionHandler;
- (void)cancelWithIndex:(NSUInteger)index;
- (void)cancelAll;

@end
