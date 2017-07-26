//
//  ViewController.m
//  滤镜
//
//  Created by 张银阁 on 2017/7/10.
//  Copyright © 2017年 张银阁. All rights reserved.
//

#import "ViewController.h"
#import <CoreImage/CoreImage.h>
#import <AVFoundation/AVFoundation.h>
#import <SpriteKit/SpriteKit.h>
#import <ImageIO/ImageIO.h>
@interface ViewController ()
{
    int i;
    UITouch *touch;
}
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    touch=[[UITouch alloc]init];
    /*
     1.创建上下文  CIcontext
     2.创建过滤器设置效果，过滤的图片 CIimage定义过滤图片、CiFilter过滤器
     3.获得输出的图片
     4.呈现图片
     */
    CIContext *contexts=[CIContext context];
    CIFilter *filter=[CIFilter filterWithName:@"CISepiaTone"];
    [filter setValue:@0.8 forKey:kCIInputIntensityKey];
    CIImage *inputImage = [CIImage imageWithContentsOfURL:[[NSBundle mainBundle] URLForResource:@"0" withExtension:@"png"]];
    [filter setValue:inputImage forKey:kCIInputImageKey];
    CIImage *outputImage=filter.outputImage;
    CGImageRef cgimage=[contexts createCGImage:outputImage fromRect:CGRectMake(0, 0, 100, 100)];
    self.oldImage.image = [UIImage imageWithCGImage:cgimage];
    
    
    
    //创建过滤链
    CIFilter *colorFilter=[CIFilter filterWithName:@"CIPhotoEffectProcess" withInputParameters:@{kCIInputImageKey: inputImage}];
    CIImage *bloomImage=[colorFilter.outputImage imageByApplyingFilter:@"CIBloom" withInputParameters:@{
                                                                                                       kCIInputRadiusKey: @10.0,
                                                                                                       kCIInputIntensityKey: @1.0
                                                                                                       }];
    
    CIImage *cropImage=[bloomImage imageByCroppingToRect:CGRectMake(0, 0, 20, 20)];
    
    
    //处理video
    CIFilter *videofilter=[CIFilter filterWithName:@"CIGaussianBlur"];
    NSURL *url=[NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:@"1" ofType:@".mp4" ]];
    AVURLAsset *urlAsset=[[AVURLAsset alloc]initWithURL:url options:nil];
    AVVideoComposition *compos=[AVVideoComposition videoCompositionWithAsset:urlAsset applyingCIFiltersWithHandler:^(AVAsynchronousCIImageFilteringRequest * _Nonnull request) {
        
        [videofilter setValue:request.sourceImage.imageByClampingToExtent forKey:kCIInputImageKey];
        float seconds=CMTimeGetSeconds(request.compositionTime);
        [videofilter setValue:@(seconds*10.0) forKey:kCIInputRadiusKey];
        CIImage *outimage=videofilter.outputImage;
        [request finishWithImage:outimage context:nil];
    }];
    
    CIImage *myImage=[[CIImage alloc]init];
    CIContext *context = [CIContext context];                    // 1
    NSDictionary *opts = @{ CIDetectorAccuracy : CIDetectorAccuracyHigh };      // 2
    CIDetector *detector = [CIDetector detectorOfType:CIDetectorTypeFace
                                              context:context
                                              options:opts];                    // 3
    
    //检测人脸
   opts = @{ CIDetectorImageOrientation :[[inputImage properties] valueForKey:kCGImagePropertyOrientation] }; // 4
    NSArray *features = [detector featuresInImage:inputImage options:opts];
    
    for (CIFaceFeature *f in features) {
        //NSLog(@"%@", NSStringFromRect(f.bounds));
        
        if (f.hasLeftEyePosition) {
            NSLog(@"Left eye %g %g", f.leftEyePosition.x, f.leftEyePosition.y);
        }
        if (f.hasRightEyePosition) {
            NSLog(@"Right eye %g %g", f.rightEyePosition.x, f.rightEyePosition.y);
        }
        if (f.hasMouthPosition) {
            NSLog(@"Mouth %g %g", f.mouthPosition.x, f.mouthPosition.y);
        }
    }
    
    NSDictionary *options = @{ CIDetectorImageOrientation :
                                   [[inputImage properties] valueForKey:kCGImagePropertyOrientation] };
    NSArray *adjustments = [inputImage autoAdjustmentFiltersWithOptions:options];
    for (CIFilter *filter in adjustments) {
        [filter setValue:inputImage forKey:kCIInputImageKey];
        myImage = filter.outputImage;
    }
    
  /* i=0;
    [NSTimer scheduledTimerWithTimeInterval:5.0f repeats:YES block:^(NSTimer * _Nonnull timer) {
        
        [self blurImage:i];
        i++;
        
        if (i==8) {
            i=0;
        }
    }];*/
    // Do any additional setup after loading the view, typically from a nib.
}

-(void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    for (touch in touches) {;
        SKSpriteNode *sprite=[SKSpriteNode spriteNodeWithImageNamed:@"Spaceship"];
        [sprite setScale:0.5];
        sprite.position=[touch locationInView:self.view];
        
        
    }
}

-(void)blurImage:(int) number{
    
    if (number==0) {
        self.orignalImage = [CIImage imageWithContentsOfURL:[[NSBundle mainBundle] URLForResource:@"0" withExtension:@"png"]];
        //获取滤镜，并设置（使用KVO键值输入）
        CIFilter *filter = [CIFilter filterWithName:@"CIBoxBlur" keysAndValues:@"inputImage", self.orignalImage, @"inputRadius", @1.0f, nil];
        //从滤镜中获取图片
        CIImage *result = filter.outputImage;
        self.filterImage = [UIImage imageWithCIImage:result];
        //将图片添加到filterImageView上
        self.oldImage.image = _filterImage;
        self.labelName.text=@"CIBoxBlur";
    }
    if (number==1) {
        self.orignalImage = [CIImage imageWithContentsOfURL:[[NSBundle mainBundle] URLForResource:@"0" withExtension:@"png"]];
        //获取滤镜，并设置（使用KVO键值输入）
        CIFilter *filter = [CIFilter filterWithName:@"CIDiscBlur" keysAndValues:@"inputImage", self.orignalImage, @"inputRadius", @1.0f, nil];
        //从滤镜中获取图片
        CIImage *result = filter.outputImage;
        self.filterImage = [UIImage imageWithCIImage:result];
        //将图片添加到filterImageView上
        self.oldImage.image = _filterImage;
        self.labelName.text=@"CIDiscBlur";

    }
    
    if (number==2) {
        self.orignalImage = [CIImage imageWithContentsOfURL:[[NSBundle mainBundle] URLForResource:@"0" withExtension:@"png"]];
        //获取滤镜，并设置（使用KVO键值输入）
        CIFilter *filter = [CIFilter filterWithName:@"CIGaussianBlur" keysAndValues:@"inputImage", self.orignalImage, @"inputRadius", @1.0f, nil];
        //从滤镜中获取图片
        CIImage *result = filter.outputImage;
        self.filterImage = [UIImage imageWithCIImage:result];
        //将图片添加到filterImageView上
        self.oldImage.image = _filterImage;
        self.labelName.text=@"CIGaussianBlur";

    }
    
    
    if (number==3) {
        self.orignalImage = [CIImage imageWithContentsOfURL:[[NSBundle mainBundle] URLForResource:@"0" withExtension:@"png"]];
        //获取滤镜，并设置（使用KVO键值输入）
        CIFilter *filter = [CIFilter filterWithName:@"CIMaskedVariableBlur" keysAndValues:@"inputImage", self.orignalImage, @"inputRadius", @1.0f,@"inputMask",self.orignalImage, nil];
        //从滤镜中获取图片
        CIImage *result = filter.outputImage;
        self.filterImage = [UIImage imageWithCIImage:result];
        //将图片添加到filterImageView上
        self.oldImage.image = _filterImage;
        self.labelName.text=@"CIMaskedVariableBlur";

    }
    
    if (number==4) {
//        self.orignalImage = [CIImage imageWithContentsOfURL:[[NSBundle mainBundle] URLForResource:@"0" withExtension:@"png"]];
//        //获取滤镜，并设置（使用KVO键值输入）
//        CIFilter *filter = [CIFilter filterWithName:@"CIMedianFilter" keysAndValues:@"inputImage", self.orignalImage, nil];
//        //从滤镜中获取图片
//        CIImage *result = filter.outputImage;
//        self.filterImage = [UIImage imageWithCIImage:result];
//        //将图片添加到filterImageView上
//        self.oldImage.image = _filterImage;
    }
    
    if (number==5) {
        self.orignalImage = [CIImage imageWithContentsOfURL:[[NSBundle mainBundle] URLForResource:@"0" withExtension:@"png"]];
        //获取滤镜，并设置（使用KVO键值输入）
        CIFilter *filter = [CIFilter filterWithName:@"CIMotionBlur" keysAndValues:@"inputImage", self.orignalImage, @"inputRadius", @1.0f,@"inputAngle",@10.0f,nil];
        //从滤镜中获取图片
        CIImage *result = filter.outputImage;
        self.filterImage = [UIImage imageWithCIImage:result];
        //将图片添加到filterImageView上
        self.oldImage.image = _filterImage;
        self.labelName.text=@"CIMotionBlur";

    }
    
    if (number==6) {
        self.orignalImage = [CIImage imageWithContentsOfURL:[[NSBundle mainBundle] URLForResource:@"0" withExtension:@"png"]];
        //获取滤镜，并设置（使用KVO键值输入）
        CIFilter *filter = [CIFilter filterWithName:@"CINoiseReduction" keysAndValues:@"inputImage", self.orignalImage, @"inputNoiseLevel", @0.02f,@"inputSharpness",@0.40f,nil];
        //从滤镜中获取图片
        CIImage *result = filter.outputImage;
        self.filterImage = [UIImage imageWithCIImage:result];
        //将图片添加到filterImageView上
        self.oldImage.image = _filterImage;
        self.labelName.text=@"CINoiseReduction";

    }

    if (number==7) {
        CIVector *vetor=[CIVector vectorWithX:100 Y:100];
        self.orignalImage = [CIImage imageWithContentsOfURL:[[NSBundle mainBundle] URLForResource:@"0" withExtension:@"png"]];
        //获取滤镜，并设置（使用KVO键值输入）
        CIFilter *filter = [CIFilter filterWithName:@"CIZoomBlur" keysAndValues:@"inputImage", self.orignalImage, @"inputCenter", vetor,@"inputAmount",@20.0f,nil];
        //从滤镜中获取图片
        CIImage *result = filter.outputImage;
        self.filterImage = [UIImage imageWithCIImage:result];
        //将图片添加到filterImageView上
        self.oldImage.image = _filterImage;
        self.labelName.text=@"CIZoomBlur";

    }

}



- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
