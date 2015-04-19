//
//  MotionTracker.h
//  sizeOf
//
//  Created by Nick Peretti on 4/19/15.
//  Copyright (c) 2015 Antumbra. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreMotion/CoreMotion.h>

@interface MotionTracker : NSObject

-(instancetype)initWithHandler:(void(^)(float x,float y,float z))handler;

@end
