//
//  UIColor+RExtension.m
//  RTUsefulExtension
//
//  Created by ricky on 13-4-27.
//  Copyright (c) 2013年 ricky. All rights reserved.
//

#import "UIColor+RExtension.h"

@implementation UIColor (RExtension)

- (UIColor*)colorByLighting:(CGFloat)rate
{
    CGFloat hue, saturation, brightness, alpha;
    if ([self getHue:&hue
          saturation:&saturation
          brightness:&brightness
               alpha:&alpha]) {
        brightness += brightness * rate;
        brightness = MAX(MIN(brightness, 1.0), 0.0);
        return [UIColor colorWithHue:hue
                          saturation:saturation
                          brightness:brightness
                               alpha:alpha];
    }
    
    CGFloat white;
    if ([self getWhite:&white
                 alpha:&alpha]) {
        white += white * rate;
        white = MAX(MIN(white, 1.0), 0.0);
        return [UIColor colorWithWhite:white
                                 alpha:alpha];
    }
    
    return self;
}

@end
