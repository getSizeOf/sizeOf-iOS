//
//  CaptureViewController.m
//  sizeOf
//
//  Created by Nick Peretti on 4/19/15.
//  Copyright (c) 2015 Antumbra. All rights reserved.
//

#import "CaptureViewController.h"
#import "MotionTracker.h"
#import <ImageIO/ImageIO.h>
#import "PointSelectorViewController.h"

@interface CaptureViewController () {
    UIVisualEffectView *blurView;
    MotionTracker *tracker;
}

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
    self.title = @"Camera";
    
    
    captureSession = [[AVCaptureSession alloc]init];
    [captureSession setSessionPreset:AVCaptureSessionPresetPhoto];
    NSArray *devices = [AVCaptureDevice devicesWithMediaType:AVMediaTypeVideo];
    for (AVCaptureDevice *d in devices) {
        if ([d hasMediaType:AVMediaTypeVideo]) {
            if (d.position == AVCaptureDevicePositionBack) {
                if ([d isFocusModeSupported:AVCaptureFocusModeAutoFocus]) {
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
    
    UIVisualEffect *blurEffect;
    blurEffect = [UIBlurEffect effectWithStyle:UIBlurEffectStyleExtraLight];
    
    blurView = [[UIVisualEffectView alloc] initWithEffect:blurEffect];
    
    blurView.frame = self.view.bounds;
    [self.view insertSubview:blurView belowSubview:cameraButton];
    
    tracker = [[MotionTracker alloc]initWithHandler:^(float x, float y, float z) {
        if(y>=-1.2&&y<=-0.8){
            blurView.alpha = fabs(-1.0-y)*5.0;
        }else {
            blurView.alpha = 1.0;
        }
        
        
    }];
    
}
-(void)configureDevice:(AVCaptureDevice *)device{
    [device lockForConfiguration:nil];
    [device setFocusMode:AVCaptureFocusModeAutoFocus];
    [device setWhiteBalanceMode:AVCaptureWhiteBalanceModeContinuousAutoWhiteBalance];
    [device setExposureMode:AVCaptureExposureModeContinuousAutoExposure];
    [device unlockForConfiguration];
}


- (IBAction)takePicture:(id)sender {
    cameraButton.backgroundColor = [UIColor colorWithWhite:0.830 alpha:0.650];
    AVCaptureConnection *videoConnection = nil;
    for (AVCaptureConnection *connection in stillImageOutput.connections)
    {
        for (AVCaptureInputPort *port in [connection inputPorts])
        {
            if ([[port mediaType] isEqual:AVMediaTypeVideo] )
            {
                videoConnection = connection;
                break;
            }
        }
        if (videoConnection) { break; }
    }
    float lensPOS = [[self captureDevice]lensPosition];
    [stillImageOutput captureStillImageAsynchronouslyFromConnection:videoConnection completionHandler:^(CMSampleBufferRef imageDataSampleBuffer, NSError *error) {
        
        
        CFDictionaryRef exifAttachments = CMGetAttachment( imageDataSampleBuffer, kCGImagePropertyExifDictionary, NULL);
        if (exifAttachments)
        {
            // Do something with the attachments.
            //NSDictionary *imageData = CFBridgingRelease(exifAttachments);
            NSLog(@"lens POS is %f attachements: %@",lensPOS,exifAttachments);
        }
        else{
            NSLog(@"no attachments");
        }
        NSData *imageData = [AVCaptureStillImageOutput jpegStillImageNSDataRepresentation:imageDataSampleBuffer];
        UIImage *image = [[UIImage alloc] initWithData:imageData];
        PointSelectorViewController *psv = [[PointSelectorViewController alloc]initWithImage:image andLensPos:lensPOS];
        [self.navigationController pushViewController:psv animated:YES];
    }];
}

- (IBAction)takePictureDown:(id)sender {
    cameraButton.backgroundColor = [UIColor colorWithRed:0.000 green:0.502 blue:1.000 alpha:1.000];
}

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event{
    UITouch *t = [touches allObjects][0];
    CGPoint p = [t locationInView:self.view];
    UIView *v = [[UIView alloc]initWithFrame:CGRectMake(p.x-5, p.y-5, 10, 10)];
    v.layer.cornerRadius = (v.frame.size.width+20)*0.5;
    v.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:v];
    [UIView animateWithDuration:0.5 animations:^{
        v.frame = CGRectMake(v.frame.origin.x-20, v.frame.origin.y-20, v.frame.size.width+40, v.frame.size.height+40);
        v.alpha =0.0;
    } completion:^(BOOL finished) {
        [v removeFromSuperview];
    }];
    float x = p.x/self.view.frame.size.width;
    float y = p.y/self.view.frame.size.height;
    if ([[self captureDevice]lockForConfiguration:nil]) {
        [[self captureDevice]setFocusPointOfInterest:CGPointMake(x, y)];
        [[self captureDevice] setFocusMode:AVCaptureFocusModeAutoFocus];
        [[self captureDevice]unlockForConfiguration];
    }
}

@end
