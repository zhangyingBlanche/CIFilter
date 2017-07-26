//
//  ViewController.h
//  滤镜
//
//  Created by 张银阁 on 2017/7/10.
//  Copyright © 2017年 张银阁. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ViewController : UIViewController
@property (weak, nonatomic) IBOutlet UIImageView *oldImage;

@property (weak, nonatomic) IBOutlet UILabel *labelName;

@property(nonatomic,strong)CIImage *orignalImage;
@property(nonatomic,strong)UIImage *filterImage;


@end

