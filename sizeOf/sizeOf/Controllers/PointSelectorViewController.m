//
//  PointSelectorViewController.m
//  sizeOf
//
//  Created by Nick Peretti on 4/19/15.
//  Copyright (c) 2015 Antumbra. All rights reserved.
//

#import "PointSelectorViewController.h"

@interface PointSelectorViewController () {
    UIImage *image;
    UIImageView *bg;
    float lensPosition;
    UIView *box;
    int selectedCorner;
    double sensorHeight;
    double sensorWidth;
    int pixelHeight;
    int pixelWidth;
}

@end

@implementation PointSelectorViewController

@synthesize statusLabel;


-(instancetype)initWithImage:(UIImage *)picture andLensPos:(float)lensPos{
    self = [super initWithNibName:@"PointSelectorViewController" bundle:nil];
    if (self) {
        image = picture;
        lensPosition = lensPos;
        selectedCorner = 0;
        sensorHeight = 0.00276; 					//height of image sensor (m)
        sensorWidth = 0.00368;	 				//width of image sensor (m)
        pixelHeight = 2448;	 						//vertical pixel height (px)
        pixelWidth = 3264;
        
    }
    return self;
}

-(void)viewDidLoad{
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor colorWithRed:0.092 green:0.482 blue:0.920 alpha:1.000];
    self.title = @"Adjust Box";
   // self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(done)];
    
    
    bg = [[UIImageView alloc]initWithImage:image];
    bg.contentMode = UIViewContentModeScaleAspectFit;
    bg.frame = CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height);
    [self.view addSubview:bg];
    
    box = [[UIView alloc]initWithFrame:CGRectMake(self.view.frame.size.width*0.25, self.view.frame.size.height*0.25, self.view.frame.size.width*0.5, self.view.frame.size.height*0.50)];
    box.backgroundColor = [UIColor clearColor];
    box.layer.borderColor = [UIColor whiteColor].CGColor;
    box.layer.borderWidth = 1.0;
    [self.view addSubview:box];
    
    statusLabel.text = @"";
    statusLabel.numberOfLines = 3;
    statusLabel.frame = CGRectMake(0, bg.frame.size.height, self.view.frame.size.width, self.view.frame.size.height-bg.frame.size.height);
}

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event{
    UITouch *t = [touches allObjects][0];
    CGPoint p = [t locationInView:self.view];
    
    int closestDist = 999999;
    for (int i = 0; i<4; i++) {
        CGPoint corner;
        if (i==0) {
            corner = CGPointMake(box.frame.origin.x, box.frame.origin.y);
        }
        if (i==1) {
            corner = CGPointMake(box.frame.origin.x+box.frame.size.width, box.frame.origin.y);
        }
        if (i==2) {
            corner = CGPointMake(box.frame.origin.x+box.frame.size.width, box.frame.origin.y+box.frame.size.height);
        }
        if (i==3) {
            corner = CGPointMake(box.frame.origin.x, box.frame.origin.y+box.frame.size.height);
        }
        float dist = [self distancefrom:p to:corner];
        if (dist<closestDist) {
            selectedCorner = i;
            closestDist = dist;
        }
    }
    
}
-(void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event{
    UITouch *t = [touches allObjects][0];
    CGPoint p = [t locationInView:self.view];
    if (selectedCorner==0) {
        //corner = CGPointMake(box.frame.origin.x, box.frame.origin.y);
        float w = (box.frame.origin.x+box.frame.size.width)-p.x;
        float h = (box.frame.origin.y+box.frame.size.height)-p.y;
        box.frame = CGRectMake(p.x, p.y, w, h);
    }
    if (selectedCorner==1) {
        //corner = CGPointMake(box.frame.origin.x+box.frame.size.width, box.frame.origin.y);
        float w = p.x-(box.frame.origin.x);
        float h = (box.frame.origin.y+box.frame.size.height)-p.y;
        box.frame = CGRectMake(box.frame.origin.x, p.y, w, h);
    }
    if (selectedCorner==2) {
        //corner = CGPointMake(box.frame.origin.x+box.frame.size.width, box.frame.origin.y+box.frame.size.height);
        float w = p.x-(box.frame.origin.x);
        float h = p.y-(box.frame.origin.y);
        box.frame = CGRectMake(box.frame.origin.x, box.frame.origin.y, w, h);
    }
    if (selectedCorner==3) {
        float h = p.y-(box.frame.origin.y);
        float w = (box.frame.origin.x+box.frame.size.width)-p.x;
        box.frame = CGRectMake(p.x, box.frame.origin.y, w, h);
    }
 
    float imageScale = image.size.width/self.view.frame.size.width;
    CGRect scaledRect = CGRectMake(box.frame.origin.x*imageScale, box.frame.origin.y*imageScale, box.frame.size.width*imageScale, box.frame.size.height*imageScale);
    [self handleSize:CGSizeMake(scaledRect.size.width, scaledRect.size.height)];
}
-(float)distancefrom:(CGPoint)p1 to:(CGPoint)p2{
    CGFloat xDist = (p2.x - p1.x);
    CGFloat yDist = (p2.y - p1.y);
    float distance = sqrt((xDist * xDist) + (yDist * yDist));
    return distance;
}

-(void)handleSize:(CGSize)pixelSize{
    
    double dist = [self lensToDist:lensPosition];
    double fLenEff = [self focalLengthComp:dist];
    
    //double objHeight = objectHeight(dist, pixelHeight, sensorHeight, fLenEff, subHeight);
    double objHeight = [self objectHeight:dist pixelHeight:pixelHeight sensorHeight:sensorHeight fleneff:fLenEff subH:(double)pixelSize.width];
    
    //double objWidth = objectWidth(dist, pixelWidth, sensorWidth, fLenEff, subWidth);
    double objWidth = [self objectWidth:dist pixelWidth:pixelWidth sensorWidth:sensorWidth fleneff:fLenEff subW:(double)pixelSize.height];
    
    statusLabel.text = [NSString stringWithFormat:@" %2.5f Lens -> %f M away \n Width = %f Meters \n Height = %f Meters ",lensPosition,dist,objHeight,objWidth];
    
    
}

-(double)lensToDist:(double)lensPos
{
    if(lensPos <= 0.69){
        return (((5868*(pow(lensPos,5.0)))-(8131*(pow(lensPos,4.0)))+(4139*(pow(lensPos,3.0)))-(860.4*(pow(lensPos,2.0)))+(80.56 * lensPos) + 7.717)/100);
    }
    else{
        return (((370.0*lensPos)-166.3)/100);
    }
}


-(double)focalLengthComp:(double)dist{
    if(dist <= .175){
        return ((-657.274*(pow(dist,4.0))+(254.198*(pow(dist,3.0)))+(21.39*(pow(dist,2.0)))-(16.748 * dist) + 4.739)/1000);
    }
    else
        return (-0.008143*dist + 3.201)/1000;

}

-(double)objectHeight:(double)dist pixelHeight:(int)ph sensorHeight:(double)sh fleneff:(double)fLenEff subH:(double)subHeight{
    return (sh * dist * subHeight) / (fLenEff * ph);
}


-(double)objectWidth:(double)dist pixelWidth:(int)pw sensorWidth:(double)sw fleneff:(double)fLenEff subW:(double)subWidth{
    return (sw * dist * subWidth) / (fLenEff * pw);
}



@end
