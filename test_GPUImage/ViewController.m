//
//  ViewController.m
//  test_GPUImage
//
//  Created by apeng on 2018/1/30.
//  Copyright © 2018年 rongxin. All rights reserved.
//
#import "GPUImageBeautifyFilter.h"
#import "ViewController.h"
#import <Photos/Photos.h>
#import "UIButton+Custom.h"
#import "GPUImage.h"

#define ScreenW [UIScreen mainScreen].bounds.size.width
#define ScreenH [UIScreen mainScreen].bounds.size.height

@interface ViewController ()
@property (strong, nonatomic) GPUImageStillCamera *camera;
@property (strong, nonatomic) GPUImageView *GPUImageView;
@property (strong, nonatomic) GPUImageFilter *currentFilter;
@property (strong, nonatomic) UIButton *selectedBtn;
@property (weak,nonatomic) UISlider *mySlider;
@property (copy, nonatomic) NSArray *filterArr;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    
    [self cameraFilter];
    
//    [self pictureFilter];
    
    
}
#pragma mark 相机动态渲染
-(void)cameraFilter {
    //初始化相机，第一个参数表示相册的尺寸，第二个参数表示前后摄像头
    _camera = [[GPUImageStillCamera alloc] initWithSessionPreset:AVCaptureSessionPreset1280x720 cameraPosition:AVCaptureDevicePositionFront];
    // 相机方向
    _camera.outputImageOrientation = UIInterfaceOrientationPortrait;
    
    //哈哈镜效果
    GPUImageStretchDistortionFilter *stretchDistortionFilter = [[GPUImageStretchDistortionFilter alloc] init];
    
    //亮度
    GPUImageBrightnessFilter *BrightnessFilter = [[GPUImageBrightnessFilter alloc] init];
    
    //伽马线滤镜
    GPUImageGammaFilter *gammaFilter = [[GPUImageGammaFilter alloc] init];
    
    //边缘检测
    GPUImageXYDerivativeFilter *XYDerivativeFilter = [[GPUImageXYDerivativeFilter alloc] init];
    
    //怀旧
    GPUImageSepiaFilter *sepiaFilter = [[GPUImageSepiaFilter alloc] init];
    
    //反色
    GPUImageColorInvertFilter *invertFilter = [[GPUImageColorInvertFilter alloc] init];
    
    //饱和度
    GPUImageSaturationFilter *saturationFilter = [[GPUImageSaturationFilter alloc] init];
    
    //美颜
    GPUImageBeautifyFilter *beautyFielter = [[GPUImageBeautifyFilter alloc] init];
    
    //素描
    GPUImageSketchFilter *sketchFilter = [[GPUImageSketchFilter alloc] init];
    
    //黑白
    GPUImageMonochromeFilter *thresholdFilter = [[GPUImageMonochromeFilter alloc] init];
    
    // 滤镜数组
    _filterArr = @[stretchDistortionFilter,BrightnessFilter,gammaFilter,XYDerivativeFilter,sepiaFilter,invertFilter,saturationFilter,beautyFielter,sketchFilter,thresholdFilter];
    
    // 初始化GPUImageView
    _GPUImageView = [[GPUImageView alloc] initWithFrame:self.view.bounds];
    
    [_camera addTarget:stretchDistortionFilter];
    [stretchDistortionFilter addTarget:_GPUImageView];
    
    _currentFilter = stretchDistortionFilter;
    
    [self.view addSubview:_GPUImageView];
    [_camera startCameraCapture];
    
    //创建UI
    [self creatUI];
}

- (void)creatUI{
    //风格按钮
    NSArray *titleArr = @[@"哈哈镜",@"亮度",@"伽马线",@"边缘检测",@"怀旧",@"反色",@"饱和度",@"美颜",@"素描",@"黑白"];
    for (int i = 0; i < 10; i ++) {
        UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
        btn.frame = CGRectMake(10, 40+i*40, 80, 30);
        btn.layer.cornerRadius = 5;
        [btn setTitle:titleArr[i] forState:UIControlStateNormal];
        [btn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [btn setBackgroundColor:[UIColor lightGrayColor]];
        btn.alpha = 0.6;
        btn.tag = i + 100;
        [btn addTarget:self action:@selector(filterStyleIsClicked:) forControlEvents:UIControlEventTouchUpInside];
        [self.view addSubview:btn];
        if (0 == i) {
            _selectedBtn = btn;
            [btn setBackgroundColor:[UIColor blueColor]];
        }
    }
    
    //照相的按钮
    UIButton *catchImageBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    catchImageBtn.frame = CGRectMake((ScreenW-60)/2, ScreenH-80, 60, 60);
    [catchImageBtn addTarget:self action:@selector(capturePhoto:) forControlEvents:UIControlEventTouchUpInside];
    [catchImageBtn setBackgroundImage:[UIImage imageNamed:@"photo.png"] forState:UIControlStateNormal];
    [self.view addSubview:catchImageBtn];
    
    // UISlider
    UISlider *slider = [[UISlider alloc] initWithFrame:CGRectMake((ScreenW-200)/2, ScreenH-130, 200, 30)];
    slider.value = 0.5;
    [slider addTarget:self action:@selector(sliderValueChanged:) forControlEvents:UIControlEventValueChanged];
    [self.view addSubview:slider];
    _mySlider = slider;
    
    //切换前后摄像机
    UIButton *switchBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    //设置2s内不可以连续点击,防止用户连续点击
    switchBtn.custom_acceptEventInterval = 1;
    switchBtn.frame = CGRectMake(ScreenW-60, 30, 44, 35);
    [switchBtn setImage:[UIImage imageNamed:@"switch.png"] forState:UIControlStateNormal];
    [switchBtn addTarget:self action:@selector(switchIsChanged:) forControlEvents:UIControlEventTouchUpInside];
    
    [self.view addSubview:switchBtn];
}

//滑动slider滚动条
- (void)sliderValueChanged:(UISlider *)slider {
    if ([_currentFilter isKindOfClass:[GPUImageStretchDistortionFilter class]]) {
        GPUImageStretchDistortionFilter *filter = (GPUImageStretchDistortionFilter *)_currentFilter;
        //The center about which to apply the distortionsfc, with a default of (0.5, 0.5)
        filter.center = CGPointMake(slider.value, 0.5);
    }else if ([_currentFilter isKindOfClass:[GPUImageBrightnessFilter class]]){
        // Brightness ranges from -1.0 to 1.0, with 0.0 as the normal level
        GPUImageBrightnessFilter *filter = (GPUImageBrightnessFilter*)_currentFilter;
        filter.brightness = slider.value*2-1;
    }else if ([_currentFilter isKindOfClass:[GPUImageGammaFilter class]]){
        GPUImageGammaFilter *filter = (GPUImageGammaFilter*)_currentFilter;
        // Gamma ranges from 0.0 to 3.0, with 1.0 as the normal level
        filter.gamma = slider.value*3;
    }else if ([_currentFilter isKindOfClass:[GPUImageSaturationFilter class]]){
        GPUImageSaturationFilter *filter = (GPUImageSaturationFilter*)_currentFilter;
        //Saturation ranges from 0.0 (fully desaturated) to 2.0 (max saturation), with 1.0 as the normal level
        filter.saturation = slider.value*2;
    }
}

//切换前后镜头
- (void)switchIsChanged:(UIButton *)sender {
    [_camera rotateCamera];
}

//选择照片的风格
-(void)filterStyleIsClicked:(UIButton*)sender {
    [self.selectedBtn setBackgroundColor:[UIColor lightGrayColor]];
    [sender setBackgroundColor:[UIColor blueColor]];
    self.mySlider.value = 0.5;
    if (3 == (sender.tag-100) || 4 == (sender.tag-100) || 5 == (sender.tag-100) || 7 == (sender.tag-100) || 8 == (sender.tag-100) || 9 == (sender.tag-100)) {
        self.mySlider.hidden = YES;
    }else{
        self.mySlider.hidden = NO;
    }
    
    GPUImageFilter *filter = self.filterArr[sender.tag - 100];
    [_camera removeAllTargets];
    [_camera addTarget:filter];
    [filter addTarget:self.GPUImageView];
    
    self.currentFilter = filter;
    
    _selectedBtn = sender;
}

// 开始拍照
-(void)capturePhoto:(UIButton *)sender {
    [_camera capturePhotoAsPNGProcessedUpToFilter:_currentFilter withCompletionHandler:^(NSData *processedPNG, NSError *error) {
        
        [[PHPhotoLibrary sharedPhotoLibrary] performChanges:^{
            
            PHAssetChangeRequest *req = [PHAssetChangeRequest creationRequestForAssetFromImage:[UIImage imageWithData:processedPNG]];
            
        } completionHandler:^(BOOL success, NSError * _Nullable error) {
            NSLog(@"success = %d, error = %@", success, error);
        }];
    }];
}

#pragma mark  静态图片加滤镜
-(void)pictureFilter {
    UIImage *inputIamge = [UIImage imageNamed:@"tree.jpg"];
    
    UIImageView *preImageView = [[UIImageView alloc] initWithImage:inputIamge];
    preImageView.frame = CGRectMake(0, 0, 300, 200);
    preImageView.center = CGPointMake(self.view.center.x, self.view.center.y - 150);
    [self.view addSubview:preImageView];
    
    // 使用黑白素描滤镜
    GPUImageSketchFilter *disFilter = [[GPUImageSketchFilter alloc] init];
    [disFilter forceProcessingAtSize:inputIamge.size];
    [disFilter useNextFrameForImageCapture];
    // 获取数据源
    GPUImagePicture *stillImageSource = [[GPUImagePicture alloc] initWithImage:inputIamge];
    // 加上滤镜
    [stillImageSource addTarget:disFilter];
    // 开始渲染
    [stillImageSource processImage];
    // 获取渲染后的图片
    UIImage *newImage = [disFilter imageFromCurrentFramebuffer];
    
    // 加载出来
    UIImageView *finishImageView = [[UIImageView alloc] initWithImage:newImage];
    finishImageView.frame = CGRectMake(0, 0, 300, 200);
    finishImageView.center = CGPointMake(self.view.center.x, self.view.center.y + 150);
    [self.view addSubview:finishImageView];
    
    self.view.backgroundColor = [UIColor lightGrayColor];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
