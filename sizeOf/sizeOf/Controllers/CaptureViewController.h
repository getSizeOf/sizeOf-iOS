//
//  CaptureViewController.h
//  sizeOf
//
//  Created by Nick Peretti on 4/19/15.
//  Copyright (c) 2015 Antumbra. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>

@interface CaptureViewController : UIViewController

@property (weak, nonatomic) IBOutlet UIButton *cameraButton;
- (IBAction)takePicture:(id)sender;
- (IBAction)takePictureDown:(id)sender;

-(instancetype)init;

@property (nonatomic,strong) AVCaptureSession *captureSession;
@property (nonatomic,strong) AVCaptureDevice *captureDevice;
@property (nonatomic,strong) AVCaptureDeviceInput *captureInput;
@property (nonatomic,strong) AVCaptureVideoPreviewLayer *capturePreviewLayer;
@property (nonatomic,strong) AVCaptureConnection *captureConnection;
@property (nonatomic,strong) AVCaptureStillImageOutput *stillImageOutput;

@end
