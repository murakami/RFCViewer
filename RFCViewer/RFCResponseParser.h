//
//  RFCResponseParser.h
//  RFCViewer
//
//  Created by 村上 幸雄 on 13/09/16.
//  Copyright (c) 2013年 Bitz Co., Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ResponseParserProtocol.h"

@interface RFCResponseParser : NSObject <ResponseParserProtocol>

@property (assign, nonatomic) NSUInteger                        index;
@property (strong, readonly, nonatomic) NSArray                 *indexArray;
@property (strong, readonly, nonatomic) NSString                *rfc;

@end
