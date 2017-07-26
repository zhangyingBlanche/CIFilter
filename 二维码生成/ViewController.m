//
//  ViewController.m
//  二维码生成
//
//  Created by 张银阁 on 2017/7/26.
//  Copyright © 2017年 张银阁. All rights reserved.
//

#import "ViewController.h"
#import <CoreImage/CoreImage.h>
@interface ViewController ()
@property(nonatomic,strong)    UIImageView *imageView;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    NSString *str=@"http://www.baidu.com";
    NSData *data=[str dataUsingEncoding:NSUTF8StringEncoding];
    CIFilter *filter=[CIFilter filterWithName:@"CIQRCodeGenerator" keysAndValues:@"inputMessage",data,@"inputCorrectionLevel" ,@"H",nil];
    CIImage *image=filter.outputImage;
    _imageView=[[UIImageView alloc]initWithFrame:CGRectMake(0, 30, 100, 100)];
    _imageView.image=[UIImage imageWithCIImage:image];
    [self.view addSubview:_imageView];
    
    UIButton *button=[[UIButton alloc]initWithFrame:CGRectMake(100, 50, 100, 30)];
    [button setTitle: @"解析图片" forState:UIControlStateNormal];
    [button setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [self.view addSubview:button];
    [button addTarget:self action:@selector(get2CodeData) forControlEvents:UIControlEventTouchUpInside];
    
    // Do any additional setup after loading the view, typically from a nib.
}

-(void)get2CodeData{
    CIDetector *detector=[CIDetector detectorOfType:CIDetectorTypeQRCode context:nil options:nil];
    UIImage *image=_imageView.image;
    
    CIImage *ciimage=image.CIImage;
    NSArray *feature=[detector featuresInImage:ciimage];
    CIQRCodeFeature *QRCodeFeature=[feature firstObject];
    UILabel *label=[[UILabel alloc]initWithFrame:CGRectMake(0, 130, 200, 30)];
    label.textColor=[UIColor grayColor];
    label.text=QRCodeFeature.messageString;
    [self.view addSubview:label];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
