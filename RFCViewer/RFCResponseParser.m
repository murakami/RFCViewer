//
//  RFCResponseParser.m
//  RFCViewer
//
//  Created by 村上 幸雄 on 13/09/16.
//  Copyright (c) 2013年 Bitz Co., Ltd. All rights reserved.
//

#import "Document.h"
#import "RFCResponseParser.h"

@interface RFCResponseParser () <NSURLConnectionDataDelegate>
@property (assign, readwrite, nonatomic) ResponseParserNetworkSate   networkState;
@property (strong, readwrite, nonatomic) NSArray                    *indexArray;
@property (strong, nonatomic) NSURLConnection                       *urlConnection;
@property (strong, nonatomic) NSMutableData                         *downloadedData;
- (void)_notifyParserDidFinishLoading;
- (void)_notifyParserDidFailWithError:(NSError*)error;
- (NSError *)_errorWithCode:(NSInteger)code localizedDescription:(NSString *)localizedDescription;
- (void)_parseIndexArray;
@end

@implementation RFCResponseParser

@synthesize networkState = _networkState;
@synthesize index = _index;
@synthesize error = _error;
@synthesize queue = _queue;
@synthesize delegate = _delegate;
@synthesize completionHandler = _completionHandler;
@synthesize indexArray = _indexArray;
@synthesize urlConnection = _urlConnection;
@synthesize downloadedData = _downloadedData;

- (id)init
{
    DBGMSG(@"%s", __func__);
    self = [super init];
    if (self) {
        _networkState = ResponseParserNetworkSateNotConnected;
        _index = 0;
        _error = nil;
        _queue = nil;
        _delegate = nil;
        _completionHandler = NULL;
        _indexArray = nil;
        _urlConnection = nil;
        _downloadedData = nil;
    }
    return self;
}

- (void)dealloc
{
    DBGMSG(@"%s", __func__);
    self.networkState = ResponseParserNetworkSateNotConnected;
    self.index = 0;
    self.error = nil;
    self.queue = nil;
    self.delegate = nil;
    self.completionHandler = NULL;
    self.indexArray = nil;
    self.urlConnection = nil;
    self.downloadedData = nil;
}

- (void)parse
{
    DBGMSG(@"%s", __func__);
    NSString    *urlString = nil;
    
    /* 通信先 */
    if (self.index == 0) {
        /* 目次文書 */
        urlString = [Document sharedDocument].indexUrlString;
    }
    else {
        /* 指定された番号のRFC文書 */
        urlString = [[Document sharedDocument] rfcUrlStringWithIndex:self.index];
    }
    
    /* URLからNSURLRequestのインスタンスを生成 */
    NSURLRequest    *urlRequest = nil;
    if (urlString) {
        NSURL   *url;
        url = [NSURL URLWithString:urlString];
        if (url) {
            urlRequest = [NSURLRequest requestWithURL:url];
        }
    }
    DBGMSG(@"%s urlString(%@)", __func__, urlString);
    
    if (! urlRequest) {
        /* NSURLRequestインスタンスの生成失敗 */
        self.networkState = ResponseParserNetworkSateError;
        self.error = [self _errorWithCode:kResponseParserGenericError
                     localizedDescription:@"NSURLRequestの生成に失敗しました。"];
        return;
    }
    
    /* 受信データの格納バッファの用意 */
    self.downloadedData = [[NSMutableData alloc] init];
    
    /* NSURLConnectionインスタンスの生成（並列処理の為のキューを設定） */
    self.urlConnection = [[NSURLConnection alloc] initWithRequest:urlRequest
                                                         delegate:self
                                                 startImmediately:NO];
    [self.urlConnection setDelegateQueue:self.queue];
    
    /* 通信中インジケータの更新 */
    [self willChangeValueForKey:@"networkState"];
    self.networkState = ResponseParserNetworkSateInProgress;
    [self didChangeValueForKey:@"networkState"];
    
    /* 通信開始 */
    [self.urlConnection start];
}

- (void)cancel
{
    DBGMSG(@"%s", __func__);
    [self.urlConnection cancel];
    
    self.downloadedData = nil;
    
    [self willChangeValueForKey:@"networkState"];
    self.networkState = ResponseParserNetworkSateCanceled;
    [self didChangeValueForKey:@"networkState"];
    
    /*
    if ([[self.delegate class] conformsToProtocol:@protocol(RFCResponseParserDelegate)]) {
        [self.delegate parserDidCancel:self];
    }
    */
    if ([self.delegate respondsToSelector:@selector(parserDidCancel:)]) {
        [self.delegate parserDidCancel:self];
    }
    
    self.urlConnection = nil;
}

- (NSString *)rfc
{
    DBGMSG(@"%s", __func__);
    NSString    *result = [[NSString alloc] initWithData:self.downloadedData encoding:NSUTF8StringEncoding];
    return result;
}

- (void)connection:(NSURLConnection*)connection didReceiveResponse:(NSURLResponse*)response
{
    DBGMSG( @"%s [Main=%@]", __FUNCTION__, [NSThread isMainThread] ? @"YES" : @"NO ");
    /* デリゲートに通知 */
    /*
    if ([[self.delegate class] conformsToProtocol:@protocol(RFCResponseParserDelegate)]) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.delegate parser:self didReceiveResponse:response];
        });
    }
    */
    if ([self.delegate respondsToSelector:@selector(parser:didReceiveResponse:)]) {
        /* 主スレッドで実行させる */
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.delegate parser:self didReceiveResponse:response];
        });
    }
}

- (void)connection:(NSURLConnection*)connection didReceiveData:(NSData*)data
{
    DBGMSG( @"%s [Main=%@]", __FUNCTION__, [NSThread isMainThread] ? @"YES" : @"NO ");
    
    /* 受信データをバッファに格納 */
    [self.downloadedData appendData:data];
    
    /* デリゲートに通知 */
    /*
    if ([[self.delegate class] conformsToProtocol:@protocol(RFCResponseParserDelegate)]) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.delegate parser:self didReceiveData:data];
        });
    }
    */
    if ([self.delegate respondsToSelector:@selector(parser:didReceiveData:)]) {
        /* 主スレッドで実行させる */
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.delegate parser:self didReceiveData:data];
        });
    }
}

- (void)connectionDidFinishLoading:(NSURLConnection*)connection
{
    DBGMSG( @"%s [Main=%@]", __FUNCTION__, [NSThread isMainThread] ? @"YES" : @"NO ");
    
    /* 通信中インジケータの更新 */
    [self willChangeValueForKey:@"networkState"];
    self.networkState = ResponseParserNetworkSateFinished;
    [self didChangeValueForKey:@"networkState"];
    
    /* 目次文書 */
    if (self.index == 0) {
        /* 受信データのパース */
        [self _parseIndexArray];
    }
    
    /* 主スレッドで実行させる */
    dispatch_async(dispatch_get_main_queue(), ^{
        [self _notifyParserDidFinishLoading];
    });

    self.urlConnection = nil;
}

- (void)connection:(NSURLConnection*)connection didFailWithError:(NSError*)error
{
    DBGMSG( @"%s [Main=%@]", __FUNCTION__, [NSThread isMainThread] ? @"YES" : @"NO ");
    
    /* エラー情報を保持 */
    self.error = error;
    
    /* 通信中インジケータの更新 */
    [self willChangeValueForKey:@"networkState"];
    self.networkState = ResponseParserNetworkSateError;
    [self didChangeValueForKey:@"networkState"];
    
    /* 主スレッドで実行させる */
    dispatch_async(dispatch_get_main_queue(), ^{
        [self _notifyParserDidFailWithError:error];
    });
    
    self.urlConnection = nil;
}

- (void)_notifyParserDidFinishLoading
{
    DBGMSG( @"%s [Main=%@]", __FUNCTION__, [NSThread isMainThread] ? @"YES" : @"NO ");
    /* デリゲートに通知 */
    /*
    if ([[self.delegate class] conformsToProtocol:@protocol(RFCResponseParserDelegate)]) {
        [self.delegate parserDidFinishLoading:self];
    }
    */
    if ([self.delegate respondsToSelector:@selector(parserDidFinishLoading:)]) {
        [self.delegate parserDidFinishLoading:self];
    }
}

- (void)_notifyParserDidFailWithError:(NSError*)error
{
    DBGMSG( @"%s [Main=%@]", __FUNCTION__, [NSThread isMainThread] ? @"YES" : @"NO ");
    /* デリゲートに通知 */
    /*
    if ([[self.delegate class] conformsToProtocol:@protocol(RFCResponseParserDelegate)]) {
        [self.delegate parser:self didFailWithError:error];
    }
    */
    if ([self.delegate respondsToSelector:@selector(parser:didFailWithError:)]) {
        [self.delegate parser:self didFailWithError:error];
    }
}

- (NSError *)_errorWithCode:(NSInteger)code localizedDescription:(NSString *)localizedDescription
{
    NSDictionary    *userInfo = [NSDictionary dictionaryWithObject:localizedDescription forKey:NSLocalizedDescriptionKey];
    NSError         *error = [NSError errorWithDomain:@"RFCViewer" code:code userInfo:userInfo];
    return error;
}

- (void)_parseIndexArray
{
    DBGMSG( @"%s [Main=%@]", __FUNCTION__, [NSThread isMainThread] ? @"YES" : @"NO ");
    
    NSMutableArray  *indexArray = [[NSMutableArray alloc] init];
    
    NSString	*indexString = nil;
	NSString	*parsedString = nil;
	NSRange		range, subRange;
	NSUInteger	length;
    __block BOOL    isCreatedOn = NO;
    BOOL        isIndex = NO;
    NSMutableString *rfcString = nil;
    
	indexString = [[NSString alloc] initWithData:self.downloadedData
										encoding:NSUTF8StringEncoding];
	length = [indexString length];
	range = NSMakeRange(0, length);
	while (0 < range.length) {
        /* 行単位の取り出し */
		subRange = [indexString lineRangeForRange:NSMakeRange(range.location, 0)];
		parsedString = [indexString substringWithRange:subRange];
		
        /* 改行文字削除 */
		NSCharacterSet	*chSet = nil;
		NSScanner		*scanner = nil;
		chSet = [NSCharacterSet characterSetWithCharactersInString:@"\r\n"];
		scanner = [NSScanner scannerWithString:parsedString];
		if (![scanner isAtEnd]) {
			NSString	*line = nil;
			[scanner scanUpToCharactersFromSet:chSet intoString:&line];
			parsedString = line;
		}
        else {
            parsedString = @"";
        }
        //DBGMSG(@"[%@]", parsedString);
        
        /* 更新日付に到着 */
        NSError *error = nil;
        NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:@"\\(CREATED ON: (\\d{2}/\\d{2}/\\d{4})\\.\\)"
                                                                               options:NSRegularExpressionCaseInsensitive
                                                                                 error:&error];
        [regex enumerateMatchesInString:parsedString
                                options:0
                                  range:NSMakeRange(0, parsedString.length)
                             usingBlock:^(NSTextCheckingResult *match, NSMatchingFlags flags, BOOL *stop) {
                                 if (match.numberOfRanges) {
                                     isCreatedOn = YES;
                                 }
                             }];
        
        /* 目次に到達 */
        if ((isCreatedOn) && ([parsedString isEqualToString:@"RFC INDEX"])) {
            isIndex = YES;
        }
        else if (! isIndex) {
        }
        
        /* 区切り */
        else if ([parsedString isEqualToString:@""]) {
            if (rfcString) {
                /* 表題の取り出し */
                //DBGMSG(@"%@", rfcString);
                NSError *error = nil;
                NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:@"^([0-9]{4}+)\\s(.+?\\.)"
                                                                                       options:NSRegularExpressionCaseInsensitive
                                                                                         error:&error];
                __block NSString    *rfcNumber = nil;
                __block NSString    *title = nil;
                [regex enumerateMatchesInString:rfcString
                                        options:0
                                          range:NSMakeRange(0, rfcString.length)
                                     usingBlock:^(NSTextCheckingResult *match, NSMatchingFlags flags, BOOL *stop) {
                                         //NSRange    matchRange = [match range];
                                         NSRange    firstHalfRange = [match rangeAtIndex:1];
                                         NSRange    secondHalfRange = [match rangeAtIndex:2];
                                         rfcNumber = [rfcString substringWithRange:firstHalfRange];
                                         title = [rfcString substringWithRange:secondHalfRange];
                                     }];
                RFC *rfc = [[RFC alloc] init];
                rfc.rfcNumber = rfcNumber;
                rfc.title = title;
                //DBGMSG(@"%@ : %@", rfcNumber, rfc.title);
                [indexArray addObject:rfc];
            }
            rfcString = nil;
        }
        
        /* 先頭 */
        else {
            NSRange match = [parsedString rangeOfString:@"^[0-9]{4}+\\s" options:NSRegularExpressionSearch];
            if (match.location != NSNotFound) {
                //DBGMSG(@">>>>先頭");
                rfcString = [[NSMutableString alloc] initWithString:parsedString];
            }
            else if (rfcString) {
                [rfcString appendString:parsedString];
            }
        }		
		range.location = NSMaxRange(subRange);
		range.length -= subRange.length;
	}
    self.indexArray = indexArray;
}

@end
