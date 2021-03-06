//
//  CallibrationViewController.m
//  sizeOf
//
//  Created by Nick Peretti on 4/18/15.
//  Copyright (c) 2015 Antumbra. All rights reserved.
//

#import "CallibrationViewController.h"
#import "PointsViewController.h"

@interface CallibrationViewController () {
    float focalLength;
    float stepperLength;
    float margin;
    CGPoint startPoint;
    AVCaptureDeviceFormat *currentFormat;
    NSMutableDictionary *dataPoints;
    int count;
    UIImage *capturedImage;
}

@end

@implementation CallibrationViewController

@synthesize captureSession,captureDevice,captureInput,capturePreviewLayer,titleLabel,stepDownBtn,stepUpBtn,captureConnection,stillImageOutput;

-(instancetype)init{
    self = [super initWithNibName:@"CallibrationViewController" bundle:nil];
    if (self) {
        focalLength = 0.500000;
        stepperLength = 0.01;
        margin = 40.0;
        dataPoints = [[NSMutableDictionary alloc]init];
        count = 0;
    }
    return self;
}


- (void)viewDidLoad {
    [super viewDidLoad];
    
    UIView *midline = [[UIView alloc]init];
    midline.backgroundColor = [UIColor whiteColor];
    float yh = (stepUpBtn.frame.origin.y+stepUpBtn.frame.size.height+margin)+(((self.view.frame.size.height-margin)-(stepUpBtn.frame.origin.y+stepUpBtn.frame.size.height+margin))*0.5);
    midline.frame = CGRectMake(0, yh, self.view.frame.size.width, 0.5);
    [self.view addSubview:midline];
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

    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(pointesPicked:) name:@"pickedPointes" object:nil];
    
}
-(void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    focalLength = 0.5;
    [self focusToLength:focalLength withDevice:[self captureDevice]];
}

-(void)configureDevice:(AVCaptureDevice *)device{
    [device lockForConfiguration:nil];
    [device setFocusMode:AVCaptureFocusModeLocked];
   // NSLog(@"%f",[captureDevice activeFormat].videoMaxZoomFactor);
    [device rampToVideoZoomFactor:4.0 withRate:1];
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


- (IBAction)sliderSlid:(id)sender {
    float completion = [(UISlider *)sender value];
    if ([[self captureDevice] lockForConfiguration:nil]){
    [[self captureDevice] setFocusMode:AVCaptureFocusModeLocked];
    float zoom  = 1.0 + 12.0 * completion;
    [[self captureDevice] setVideoZoomFactor:zoom];
    [[self captureDevice] unlockForConfiguration];
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

- (IBAction)addDataPoint:(id)sender {
    
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
    
    [stillImageOutput captureStillImageAsynchronouslyFromConnection:videoConnection completionHandler:^(CMSampleBufferRef imageDataSampleBuffer, NSError *error) {
        
        
        CFDictionaryRef exifAttachments = CMGetAttachment( imageDataSampleBuffer, kCGImagePropertyExifDictionary, NULL);
        if (exifAttachments)
        {
            // Do something with the attachments.
            NSLog(@"attachements: %@", exifAttachments);
        }
        else{
            NSLog(@"no attachments");
        }
        NSData *imageData = [AVCaptureStillImageOutput jpegStillImageNSDataRepresentation:imageDataSampleBuffer];
        capturedImage = [[UIImage alloc] initWithData:imageData];
        
        
        
        UIAlertView *lert = [[UIAlertView alloc]initWithTitle:@"New Data Point" message:[NSString stringWithFormat:@"Lens position of %2.9f",[[self captureDevice] lensPosition]] delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Add", nil];
        lert.alertViewStyle = UIAlertViewStylePlainTextInput;
        UITextField *field = [lert textFieldAtIndex:0];
        field.placeholder = @"Enter distance in CM";
        field.keyboardType = UIKeyboardTypeDecimalPad;
        lert.delegate = self;
        [lert show];
    }];
    
 
}

- (IBAction)emailData:(id)sender {
    NSString *path = [[self applicationDocumentsDirectory].path
                      stringByAppendingPathComponent:@"distances.plist"];
    [self showEmail:path];    
}

- (void)showEmail:(NSString*)file {
    
    NSString *emailTitle = @"Lens Data";
    NSString *messageBody = @"Here is the lens data";
    NSArray *toRecipents = @[@"nicholasperetti@gmail.com"];
    
    MFMailComposeViewController *mc = [[MFMailComposeViewController alloc] init];
    mc.mailComposeDelegate = self;
    [mc setSubject:emailTitle];
    [mc setMessageBody:messageBody isHTML:NO];
    [mc setToRecipients:toRecipents];
    
    // Determine the file name and extension
    NSString *filename = @"distances";

    
    // Get the resource path and read the file using NSData
    //NSString *filePath = [[NSBundle mainBundle] pathForResource:filename ofType:extension];
    NSData *fileData = [NSData dataWithContentsOfFile:file];
    
    // Determine the MIME type
    NSString *mimeType = @"application/xml";
    
    // Add attachment
    [mc addAttachmentData:fileData mimeType:mimeType fileName:filename];
    
    // Present mail view controller on screen
    [self presentViewController:mc animated:YES completion:NULL];
    
}

- (void) mailComposeController:(MFMailComposeViewController *)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error
{
    switch (result)
    {
        case MFMailComposeResultCancelled:
            NSLog(@"Mail cancelled");
            break;
        case MFMailComposeResultSaved:
            NSLog(@"Mail saved");
            break;
        case MFMailComposeResultSent:
            NSLog(@"Mail sent");
            break;
        case MFMailComposeResultFailed:
            NSLog(@"Mail sent failure: %@", [error localizedDescription]);
            break;
        default:
            break;
    }
    
    // Close the Mail Interface
    [self dismissViewControllerAnimated:YES completion:NULL];
}

-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    if (buttonIndex!=alertView.cancelButtonIndex) {
        NSNumber *distance = [NSNumber numberWithFloat:[[alertView textFieldAtIndex:0].text floatValue]];
        NSNumber *lensPost = [NSNumber numberWithFloat:[[self captureDevice] lensPosition]];
        [dataPoints setObject:@[distance,lensPost] forKey:[NSString stringWithFormat:@"%i",count]];
        
        PointsViewController *pvc = [[PointsViewController alloc]initWithImage:capturedImage];
        [self presentViewController:pvc animated:YES completion:nil];
        
    }
}

- (void)pointesPicked:(NSNotification *)notification
{
    NSDictionary *dict = [notification userInfo];
    NSArray *points = [dict valueForKey:@"points"];
    int p1=0;
    int p2=0;
    int c = 0;
    for (NSValue *v in points) {
        CGPoint p = [v CGPointValue];
        if (c==0) {
            p1 = p.y;
        }else {
            p2 = p.y;
        }
        NSLog(@"%f %f",p.x,p.y);
        c++;
    }
    NSLog(@"pixels height %i",abs(p2-p1));
    
    
    
    count++;
    NSString *path = [[self applicationDocumentsDirectory].path
                      stringByAppendingPathComponent:@"distances.plist"];
    [dataPoints writeToFile:path atomically:YES];
    
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
    focalLength = (p.y-(stepUpBtn.frame.origin.y+stepUpBtn.frame.size.height+margin))/((self.view.frame.size.height-margin)-(stepUpBtn.frame.origin.y+stepUpBtn.frame.size.height+margin));
    [self focusToLength:focalLength withDevice:[self captureDevice]];
}
- (NSURL *)applicationDocumentsDirectory {
    return [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory
                                                   inDomains:NSUserDomainMask] lastObject];
}

@end
