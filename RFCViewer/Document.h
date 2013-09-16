//
//  Document.h
//  RFCViewer
//
//  Created by 村上 幸雄 on 13/09/16.
//  Copyright (c) 2013年 Bitz Co., Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "RFC.h"

@interface Document : NSObject

@property (strong, nonatomic) NSString              *version;
@property (strong, readonly, nonatomic) NSString    *indexUrlString;

+ (Document *)sharedDocument;
- (void)load;
- (void)save;
- (NSString *)rfcUrlStringWithIndex:(NSUInteger)index;

@end
