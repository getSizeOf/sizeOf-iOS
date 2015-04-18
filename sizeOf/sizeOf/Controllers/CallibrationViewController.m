//
//  CallibrationViewController.m
//  sizeOf
//
//  Created by Nick Peretti on 4/18/15.
//  Copyright (c) 2015 Antumbra. All rights reserved.
//

#import "CallibrationViewController.h"

@interface CallibrationViewController () {
    float focalLength;
    float stepperLength;
    CGPoint startPoint;
}

@end

@implementation CallibrationViewController

@synthesize captureSession,captureDevice,captureInput,capturePreviewLayer,titleLabel,stepDownBtn,stepUpBtn;

-(instancetype)init{
    self = [super initWithNibName:@"CallibrationViewController" bundle:nil];
    if (self) {
        focalLength = 0.500000;
        stepperLength = 0.001;
        
    }
    return self;
}


- (void)viewDidLoad {
    [super viewDidLoad];
    captureSession = [[AVCaptureSession alloc]init];
    [captureSession setSessionPreset:AVCaptureSessionPresetPhoto];
    NSArray *devices = [AVCaptureDevice devicesWithMediaType:AVMediaTypeVideo];
    for (AVCaptureDevice *d in devices) {
        if ([d hasMediaType:AVMediaTypeVideo]) {
            if (d.position == AVCaptureDevicePositionBack) {
                if ([d isFocusModeSupported:AVCaptureFocusModeLocked]) {
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
    
    capturePreviewLayer = [AVCaptureVideoPreviewLayer layerWithSession:[self captureSession]];
    [self.view.layer insertSublayer:capturePreviewLayer atIndex:0];
    CGRect bounds=self.view.layer.bounds;
    capturePreviewLayer.videoGravity = AVLayerVideoGravityResizeAspectFill;
    capturePreviewLayer.bounds=bounds;
    capturePreviewLayer.position=CGPointMake(CGRectGetMidX(bounds), CGRectGetMidY(bounds));
    [captureSession startRunning];
    [self configureDevice:[self captureDevice]];
    
    
    
    
    
}
-(void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    focalLength = 0.5;
    [self focusToLength:focalLength withDevice:[self captureDevice]];
}

-(void)configureDevice:(AVCaptureDevice *)device{
    [device lockForConfiguration:nil];
    [device setFocusMode:AVCaptureFocusModeLocked];
    [device unlockForConfiguration];
}

-(void)focusToLength:(float)value withDevice:(AVCaptureDevice *)device{
    titleLabel.text = [NSString stringWithFormat:@"Requested %2.3f\nActual %2.9f",focalLength,[[self captureDevice] lensPosition]];
    if (value<=1.000&&value>=0.0000) {
        [device lockForConfiguration:nil];
        [device setFocusModeLockedWithLensPosition:value completionHandler:^(CMTime syncTime) {
            titleLabel.text = [NSString stringWithFormat:@"Requested %2.3f\nActual %2.9f",focalLength,[[self captureDevice] lensPosition]];
        }];
        [device unlockForConfiguration];
        
    }
}


- (IBAction)stepDown:(id)sender {
    
    
    focalLength = focalLength - stepperLength;
    [self focusToLength:focalLength withDevice:[self captureDevice]];
    
}

- (IBAction)stepUp:(id)sender {
    
    focalLength = focalLength + stepperLength;
    [self focusToLength:focalLength withDevice:[self captureDevice]];
    
}

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event{
    UITouch *t = [touches allObjects][0];
    CGPoint p = [t locationInView:self.view];
    startPoint = p;
}
-(void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event{
    UITouch *t = [touches allObjects][0];
    CGPoint p = [t locationInView:self.view];
    //float percentY = (p.y-(self.view.frame.size.height*0.25))/(self.view.frame.size.height*0.5);
    focalLength = (p.y-(stepUpBtn.frame.origin.y+stepUpBtn.frame.size.height+20))/(self.view.frame.size.height-(stepUpBtn.frame.origin.y+stepUpBtn.frame.size.height-20));
    [self focusToLength:focalLength withDevice:[self captureDevice]];
}
@end
