//
//  ResponseParserProtocol.h
//  RFCViewer
//
//  Created by 村上幸雄 on 2015/07/20.
//  Copyright (c) 2015年 Bitz Co., Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol ResponseParserProtocol;

#define kResponseParserNoError       0
#define kResponseParserGenericError  1

typedef enum _ResponseParserNetworkState {
    ResponseParserNetworkSateNotConnected = 0,
    ResponseParserNetworkSateInProgress,
    ResponseParserNetworkSateFinished,
    ResponseParserNetworkSateError,
    ResponseParserNetworkSateCanceled,
} ResponseParserNetworkSate;

typedef void (^ResponseParserCompletionHandler)(id<ResponseParserProtocol> parser);

@protocol ResponseParserDelegate <NSObject>
- (void)parser:(id<ResponseParserProtocol>)parser didReceiveResponse:(NSURLResponse*)response;
- (void)parser:(id<ResponseParserProtocol>)parser didReceiveData:(NSData *)data;
- (void)parserDidFinishLoading:(id<ResponseParserProtocol>)parser;
- (void)parser:(id<ResponseParserProtocol>)parser didFailWithError:(NSError*)error;
- (void)parserDidCancel:(id<ResponseParserProtocol>)parser;
@end

@protocol ResponseParserProtocol <NSObject>

@property (assign, readonly, nonatomic) ResponseParserNetworkSate   networkState;
@property (strong, nonatomic) NSError                               *error;
@property (strong, nonatomic) NSOperationQueue                      *queue;
@property (weak, nonatomic) id<ResponseParserDelegate>              delegate;
@property (copy, nonatomic) ResponseParserCompletionHandler         completionHandler;

- (void)parse;
- (void)cancel;

@end

/* End Of File */