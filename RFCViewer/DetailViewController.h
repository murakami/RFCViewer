//
//  DetailViewController.h
//  RFCViewer
//
//  Created by 村上 幸雄 on 13/09/15.
//  Copyright (c) 2013年 Bitz Co., Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DetailViewController : UIViewController

@property (strong, nonatomic) id detailItem;

@property (weak, nonatomic) IBOutlet UILabel *detailDescriptionLabel;
@end
