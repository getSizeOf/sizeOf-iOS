//
//  PointSelectorViewController.h
//  sizeOf
//
//  Created by Nick Peretti on 4/19/15.
//  Copyright (c) 2015 Antumbra. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PointSelectorViewController : UIViewController

-(instancetype)initWithImage:(UIImage *)picture andLensPos:(float)lensPos;
@property (weak, nonatomic) IBOutlet UILabel *statusLabel;

@end
