//
//  RFC.h
//  RFCViewer
//
//  Created by 村上 幸雄 on 13/09/16.
//  Copyright (c) 2013年 Bitz Co., Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface RFC : NSObject
@property (strong, nonatomic) NSString  *title;
@property (strong, nonatomic) NSString  *author1;
@property (strong, nonatomic) NSString  *author2;
@property (strong, nonatomic) NSString  *author3;
@property (strong, nonatomic) NSString  *issueDate;
@property (strong, nonatomic) NSString  *format;
@property (strong, nonatomic) NSString  *obsoletes;
@property (strong, nonatomic) NSString  *obsoletedBy;
@property (strong, nonatomic) NSString  *updates;
@property (strong, nonatomic) NSString  *updatedBy;
@property (strong, nonatomic) NSString  *alsoFYI;
@property (strong, nonatomic) NSString  *status;
@end
