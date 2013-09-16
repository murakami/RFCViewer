//
//  RFCResponseParser.h
//  RFCViewer
//
//  Created by 村上 幸雄 on 13/09/16.
//  Copyright (c) 2013年 Bitz Co., Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>

@class RFCResponseParser;

#define kRFCResponseParserNoError       0
#define kRFCResponseParserGenericError  1

typedef enum _RFCNetworkState {
    kRFCNetworkStateNotConnected = 0,
    kRFCNetworkStateInProgress,
    kRFCNetworkStateFinished,
    kRFCNetworkStateError,
    kRFCNetworkStateCanceled,
} RFCNetworkSate;

typedef void (^RFCResponseParserCompletionHandler)(RFCResponseParser *parser);

@protocol RFCResponseParserDelegate <NSObject>
- (void)parser:(RFCResponseParser*)parser didReceiveResponse:(NSURLResponse*)response;
- (void)parser:(RFCResponseParser *)parser didReceiveData:(NSData *)data;
- (void)parserDidFinishLoading:(RFCResponseParser *)parser;
- (void)parser:(RFCResponseParser *)parser didFailWithError:(NSError*)error;
- (void)parserDidCancel:(RFCResponseParser *)parser;
@end

@interface RFCResponseParser : NSObject

@property (assign, readonly, nonatomic) RFCNetworkSate          networkState;
@property (strong, nonatomic) NSString                          *indexUrlString;
@property (strong, nonatomic) NSString                          *baseUrlString;
@property (strong, nonatomic) NSError                           *error;
@property (weak, nonatomic) id<RFCResponseParserDelegate>       delegate;
@property (copy, nonatomic)RFCResponseParserCompletionHandler   completionHandler;
@property (strong, readonly, nonatomic) NSDictionary            *indexDictionary;
@property (strong, readonly, nonatomic) NSString                *rfc;

- (void)parseWithIndex:(NSUInteger)index queue:(NSOperationQueue *)queue;
- (void)cancel;

@end
