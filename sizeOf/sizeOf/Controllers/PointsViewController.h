//
//  PointsViewController.h
//  sizeOf
//
//  Created by Nick Peretti on 4/18/15.
//  Copyright (c) 2015 Antumbra. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PointsViewController : UIViewController <UIScrollViewDelegate>

-(instancetype)initWithImage:(UIImage *)pic;

- (IBAction)doneTapped:(id)sender;
@property (weak, nonatomic) IBOutlet UILabel *statusLabel;
@property (weak, nonatomic) IBOutlet UIScrollView *imageScroll;

@end
