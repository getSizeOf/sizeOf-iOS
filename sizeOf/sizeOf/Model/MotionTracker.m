//
//  MotionTracker.m
//  sizeOf
//
//  Created by Nick Peretti on 4/19/15.
//  Copyright (c) 2015 Antumbra. All rights reserved.
//

#import "MotionTracker.h"

@implementation MotionTracker {
    CMMotionManager *man;
    float cy;
}

-(instancetype)initWithHandler:(void (^)(float, float, float))handler{
    self = [super init];
    if (self) {
        man = [[CMMotionManager alloc]init];
        [man setAccelerometerUpdateInterval:1.0/60.0];
        cy = -1.0;
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [man startAccelerometerUpdatesToQueue:[NSOperationQueue mainQueue] withHandler:^(CMAccelerometerData *accelerometerData, NSError *error) {
                cy = (0.9*cy)+(0.1*accelerometerData.acceleration.y);
                handler(accelerometerData.acceleration.x,cy,accelerometerData.acceleration.z);
            }];
        });
        ;
    }
    return self;
}

@end
