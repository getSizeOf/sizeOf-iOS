//
//  CallibrationViewController.h
//  sizeOf
//
//  Created by Nick Peretti on 4/18/15.
//  Copyright (c) 2015 Antumbra. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>

@interface CallibrationViewController : UIViewController

@property (nonatomic,strong) AVCaptureSession *captureSession;
@property (nonatomic,strong) AVCaptureDevice *captureDevice;
@property (nonatomic,strong) AVCaptureDeviceInput *captureInput;
@property (nonatomic,strong) AVCaptureVideoPreviewLayer *capturePreviewLayer;

@property (weak, nonatomic) IBOutlet UIButton *stepDownBtn;
@property (weak, nonatomic) IBOutlet UIButton *stepUpBtn;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;

- (IBAction)stepDown:(id)sender;
- (IBAction)stepUp:(id)sender;

@end
