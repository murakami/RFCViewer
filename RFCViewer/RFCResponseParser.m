//
//  RFCResponseParser.m
//  RFCViewer
//
//  Created by 村上 幸雄 on 13/09/16.
//  Copyright (c) 2013年 Bitz Co., Ltd. All rights reserved.
//

#import "RFCResponseParser.h"

@interface RFCResponseParser () <NSURLConnectionDataDelegate>
@property (assign, readwrite, nonatomic) RFCNetworkSate networkState;
@property (strong, nonatomic) NSURLConnection           *urlConnection;
@property (strong, nonatomic) NSMutableData             *downloadedData;
@property (strong, nonatomic) NSOperationQueue          *queue;
- (void)_parse;
- (void)_notifyParserDidFinishLoading;
- (void)_notifyParserDidFailWithError:(NSError*)error;
- (NSError *)_errorWithCode:(NSInteger)code localizedDescription:(NSString *)localizedDescription;
@end

@implementation RFCResponseParser

@synthesize networkState = _networkState;
@synthesize indexUrlString = _indexUrlString;
@synthesize baseUrlString = _baseUrlString;
@synthesize error = _error;
@synthesize delegate = _delegate;
@synthesize completionHandler = _completionHandler;
@synthesize urlConnection = _urlConnection;
@synthesize downloadedData = _downloadedData;
@synthesize queue = _queue;

- (id)init
{
    DBGMSG(@"%s", __func__);
    self = [super init];
    if (self) {
        _networkState = kRFCNetworkStateNotConnected;
        _indexUrlString = @"http://www.rfc-editor.org/rfc/rfc-index.txt";
        _baseUrlString = @"http://www.ietf.org/rfc";
        _error = nil;
        _delegate = nil;
        _completionHandler = NULL;
        _urlConnection = nil;
        _downloadedData = nil;
        _queue = nil;
    }
    return self;
}

- (void)dealloc
{
    DBGMSG(@"%s", __func__);
    self.networkState = kRFCNetworkStateNotConnected;
    self.indexUrlString = nil;
    self.baseUrlString = nil;
    self.error = nil;
    self.delegate = nil;
    self.completionHandler = NULL;
    self.urlConnection = nil;
    self.downloadedData = nil;
    self.queue = nil;
}

- (void)parseWithIndex:(NSUInteger)index queue:(NSOperationQueue *)queue
{
    DBGMSG(@"%s", __func__);
    NSString    *urlString = nil;
    self.queue = queue;
    
    if (index == 0) {
        urlString = self.indexUrlString;
    }
    else {
        NSMutableString *urlMutableString = [[NSMutableString alloc] initWithFormat:@"%@/rfc%04u.txt",
                                             self.baseUrlString, index];
        urlString = urlMutableString;
    }
    
    NSURLRequest    *urlRequest = nil;
    if (urlString) {
        NSURL   *url;
        url = [NSURL URLWithString:urlString];
        if (url) {
            urlRequest = [NSURLRequest requestWithURL:url];
        }
    }
    
    if (! urlRequest) {
        self.error = [self _errorWithCode:kRFCResponseParserGenericError localizedDescription:@"NSURLRequestの生成に失敗しました。"];
        if (self.completionHandler) {
            self.completionHandler(self);
        }
        return;
    }
    
    self.downloadedData = [[NSMutableData alloc] init];
        
    self.urlConnection = [[NSURLConnection alloc] initWithRequest:urlRequest
                                                         delegate:self
                                                 startImmediately:NO];
    [self.urlConnection setDelegateQueue: self.queue];
    
    [self willChangeValueForKey:@"networkState"];
    self.networkState = kRFCNetworkStateInProgress;
    [self didChangeValueForKey:@"networkState"];
    
    [self.urlConnection start];
}

- (void)cancel
{
    DBGMSG(@"%s", __func__);
    [self.urlConnection cancel];
    
    self.downloadedData = nil;
    
    [self willChangeValueForKey:@"networkState"];
    self.networkState = kRFCNetworkStateCanceled;
    [self didChangeValueForKey:@"networkState"];
    
    if ([self.delegate respondsToSelector:@selector(parserDidCancel:)]) {
        [self.delegate parserDidCancel:self];
    }
    if (self.completionHandler) {
        self.completionHandler(self);
    }
    
    self.urlConnection = nil;
}

- (NSDictionary *)indexDictionary
{
    DBGMSG(@"%s", __func__);
}

- (NSString *)rfc
{
    DBGMSG(@"%s", __func__);
    NSString    *result = [[NSString alloc] initWithData:self.downloadedData encoding:NSUTF8StringEncoding];
    return result;
}

- (void)_parse
{
}

- (void)_notifyParserDidFinishLoading
{
}

- (void)_notifyParserDidFailWithError:(NSError*)error
{
}

- (NSError *)_errorWithCode:(NSInteger)code localizedDescription:(NSString *)localizedDescription
{
    NSDictionary    *userInfo = [NSDictionary dictionaryWithObject:localizedDescription forKey:NSLocalizedDescriptionKey];
    NSError         *error = [NSError errorWithDomain:@"RFCViewer" code:code userInfo:userInfo];
    return error;
}

@end
