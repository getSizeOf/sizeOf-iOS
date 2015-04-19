//
//  CaptureViewController.m
//  sizeOf
//
//  Created by Nick Peretti on 4/19/15.
//  Copyright (c) 2015 Antumbra. All rights reserved.
//

#import "CaptureViewController.h"

@interface CaptureViewController ()

@end

@implementation CaptureViewController

@synthesize cameraButton,captureConnection,captureDevice,captureInput,capturePreviewLayer,captureSession,stillImageOutput;


-(instancetype)init{
    self = [super initWithNibName:@"CaptureViewController" bundle:nil];
    if (self) {
        
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    cameraButton.layer.cornerRadius = cameraButton.frame.size.width*0.5;
    self.title = @"Take Picture";
    
    
    captureSession = [[AVCaptureSession alloc]init];
    [captureSession setSessionPreset:AVCaptureSessionPresetPhoto];
    NSArray *devices = [AVCaptureDevice devicesWithMediaType:AVMediaTypeVideo];
    for (AVCaptureDevice *d in devices) {
        if ([d hasMediaType:AVMediaTypeVideo]) {
            if (d.position == AVCaptureDevicePositionBack) {
                if ([d isFocusModeSupported:AVCaptureFocusModeContinuousAutoFocus]) {
                    captureDevice = d;
                }
            }
        }
    }
    if (captureDevice!=nil) {
        NSError *err;
        captureInput = [AVCaptureDeviceInput deviceInputWithDevice:captureDevice error:&err];
        if (!err) {
            if ([captureSession canAddInput:captureInput]) {
                [captureSession addInput:captureInput];
            }
        }else {
            NSLog(@"%@",err);
        }
        
    }else {
        NSLog(@"capture device is lame");
    }
    
    stillImageOutput = [[AVCaptureStillImageOutput alloc]init];
    if ([captureSession canAddOutput:stillImageOutput]) {
        [captureSession addOutput:stillImageOutput];
    }
    
    capturePreviewLayer = [AVCaptureVideoPreviewLayer layerWithSession:[self captureSession]];
    [self.view.layer insertSublayer:capturePreviewLayer atIndex:0];
    CGRect bounds=self.view.layer.bounds;
    capturePreviewLayer.videoGravity = AVLayerVideoGravityResizeAspectFill;
    capturePreviewLayer.bounds=bounds;
    capturePreviewLayer.position=CGPointMake(CGRectGetMidX(bounds), CGRectGetMidY(bounds));
    [captureSession startRunning];
    [self configureDevice:[self captureDevice]];
    
}
-(void)configureDevice:(AVCaptureDevice *)device{
    [device lockForConfiguration:nil];
    [device setFocusMode:AVCaptureFocusModeContinuousAutoFocus];
    [device unlockForConfiguration];
}


- (IBAction)takePicture:(id)sender {
    cameraButton.backgroundColor = [UIColor colorWithWhite:0.830 alpha:0.650];
}

- (IBAction)takePictureDown:(id)sender {
    cameraButton.backgroundColor = [UIColor colorWithRed:0.000 green:0.502 blue:1.000 alpha:1.000];
}

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event{
    UITouch *t = [touches allObjects][0];
    CGPoint p = [t locationInView:self.view];
    UIView *v = [[UIView alloc]initWithFrame:CGRectMake(p.x-5, p.y-5, 10, 10)];
    v.layer.cornerRadius = v.frame.size.width*0.5;
    v.backgroundColor = [UIColor whiteColor];
    [self.view]
    float x = p.x/self.view.frame.size.width;
    float y = p.y/self.view.frame.size.height;
    if ([[self captureDevice]lockForConfiguration:nil]) {
        [[self captureDevice]setFocusPointOfInterest:CGPointMake(x, y)];
        [[self captureDevice]setExposurePointOfInterest:CGPointMake(x, y)];
        [[self captureDevice]unlockForConfiguration];
    }
}

@end
