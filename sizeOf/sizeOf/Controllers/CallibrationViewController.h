//
//  CallibrationViewController.h
//  sizeOf
//
//  Created by Nick Peretti on 4/18/15.
//  Copyright (c) 2015 Antumbra. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>
#import <MessageUI/MessageUI.h>
#import <ImageIO/ImageIO.h>

@interface CallibrationViewController : UIViewController <UIAlertViewDelegate,MFMailComposeViewControllerDelegate>

@property (nonatomic,strong) AVCaptureSession *captureSession;
@property (nonatomic,strong) AVCaptureDevice *captureDevice;
@property (nonatomic,strong) AVCaptureDeviceInput *captureInput;
@property (nonatomic,strong) AVCaptureVideoPreviewLayer *capturePreviewLayer;
@property (nonatomic,strong) AVCaptureConnection *captureConnection;
@property (nonatomic,strong) AVCaptureStillImageOutput *stillImageOutput;

@property (weak, nonatomic) IBOutlet UIButton *stepDownBtn;
@property (weak, nonatomic) IBOutlet UIButton *stepUpBtn;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
- (IBAction)sliderSlid:(id)sender;

- (IBAction)stepDown:(id)sender;
- (IBAction)stepUp:(id)sender;
- (IBAction)addDataPoint:(id)sender;
- (IBAction)emailData:(id)sender;

@end
