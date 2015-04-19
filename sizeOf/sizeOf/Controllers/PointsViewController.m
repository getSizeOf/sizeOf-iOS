//
//  PointsViewController.m
//  sizeOf
//
//  Created by Nick Peretti on 4/18/15.
//  Copyright (c) 2015 Antumbra. All rights reserved.
//

#import "PointsViewController.h"

@interface PointsViewController (){
    NSMutableArray *pointArray;
    UIImage *image;
    int count;
    NSMutableArray *pointViews;
}

@end

@implementation PointsViewController

@synthesize imageScroll,statusLabel;

-(instancetype)initWithImage:(UIImage *)pic{
    self = [super initWithNibName:@"PointsViewController" bundle:nil];
    if (self) {
        statusLabel.text = @"Tap p1";
        image = pic;
        count = 0;
        pointArray = [[NSMutableArray alloc]init];
        pointViews = [[NSMutableArray alloc]init];
        
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    [imageScroll setDelegate:self];
    imageScroll.contentSize =  CGSizeMake(image.size.width, image.size.height);
    UIImageView *bg = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, image.size.width, image.size.height)];
    bg.image = image;
    [imageScroll addSubview:bg];
//    [imageScroll setMinimumZoomScale:5.0];
 //   [imageScroll setMaximumZoomScale:5.0];
    
    UITapGestureRecognizer *recognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(receivedTap:)];
    [recognizer setNumberOfTapsRequired:1];
    [recognizer setNumberOfTouchesRequired:1];
    [imageScroll addGestureRecognizer:recognizer];
}

-(void)drawPoints{
    for (UIView *point in pointViews) {
        [point removeFromSuperview];
    }
    [pointViews removeAllObjects];
    int c = 0;
    int p1 = 0;
    int p2 = 0;
    for (NSValue *v in pointArray) {
        CGPoint p = [v CGPointValue];
        if (c==0) {
            p1 = p.y;
        }else {
            p2 = p.y;
        }
        c++;
        UIView *v =[[UIView alloc]initWithFrame:CGRectMake(p.x-5, p.y-5, 10, 10)];
        v.layer.cornerRadius = 5;
        v.backgroundColor = [UIColor greenColor];
        [imageScroll addSubview:v];
        [pointViews addObject:v];
    }
   // NSLog(@"Pixel height is %i",abs(p2-p1));
    
    statusLabel.text = [NSString stringWithFormat:@"Pixel height is %i",abs(p2-p1)];
}

- (void)receivedTap:(UIGestureRecognizer *)gestureRecognizer
{
    CGPoint coords = [gestureRecognizer locationInView:imageScroll];
    NSValue *v = [NSValue valueWithCGPoint:coords];
    pointArray[count%2]=v;
    count++;
    [self drawPoints];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (IBAction)doneTapped:(id)sender {
    //NSArray *po = [NSArray arrayWithArray:pointArray];
    //[[NSNotificationCenter defaultCenter]postNotificationName:@"pickedPointes" object:nil userInfo:@{@"points":po}];
    [[self presentingViewController]dismissViewControllerAnimated:YES completion:^{
        NSArray *po = [NSArray arrayWithArray:pointArray];
        [[NSNotificationCenter defaultCenter]postNotificationName:@"pickedPointes" object:nil userInfo:@{@"points":po}];
    }];
    
}
@end
