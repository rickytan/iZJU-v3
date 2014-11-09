//
//  UIImage+DD.m
//  DDMessage
//
//  Created by ricky on 13-9-7.
//  Copyright (c) 2013年 ricky. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>
#import "UIImage+DD.h"

@implementation UIImage (DD)

- (UIImage*)resizedImageWithSize:(CGSize)size
{
    UIGraphicsBeginImageContext(size);
    [self drawInRect:(CGRect){{0,0},size}];
    __autoreleasing UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return image;
}

- (UIImage*)resizedImageWithMaxHeight:(CGFloat)height maxWidth:(CGFloat)width
{
    CGFloat ratio = self.size.height / self.size.width;
    if (ratio > height / width) {
        height = MIN(height, self.size.height);
        return [self resizedImageWithSize:CGSizeMake(height / ratio, height)];
    }
    else {
        width = MIN(width, self.size.width);
        return [self resizedImageWithSize:CGSizeMake(width, width * ratio)];
    }
}

@end
