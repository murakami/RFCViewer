//
//  DetailViewController.h
//  RFCViewer
//
//  Created by 村上 幸雄 on 13/09/15.
//  Copyright (c) 2013年 Bitz Co., Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Document.h"
#import "Connector.h"

@interface DetailViewController : UIViewController

@property (strong, nonatomic) RFC   *rfc;

@property (weak, nonatomic) IBOutlet UITextView *rfcTextView;
@end
