//
//  UIView+iZJU.m
//  iZJU
//
//  Created by ricky on 13-6-7.
//  Copyright (c) 2013年 iZJU Studio. All rights reserved.
//

#import "UIView+iZJU.h"
#import <QuartzCore/QuartzCore.h>

typedef CGFloat (^TimingBlock)(CGFloat);

@interface CAKeyframeAnimation (CLAnimation)
+ (id)animationPositionFrom:(CGPoint)start
                         to:(CGPoint)end
                   duration:(NSTimeInterval)duration
                     frames:(NSInteger)frames
            withTimingBlock:(TimingBlock)block;
+ (id)animationScaleFrom:(CGFloat)start
                      to:(CGFloat)end
                duration:(NSTimeInterval)duration
                  frames:(NSInteger)frames
         withTimingBlock:(TimingBlock)block;
@end

@implementation CAKeyframeAnimation (CLAnimation)

+ (id)animationPositionFrom:(CGPoint)start
                         to:(CGPoint)end
                   duration:(NSTimeInterval)duration
                     frames:(NSInteger)frames
            withTimingBlock:(TimingBlock)block
{
    CAKeyframeAnimation *animation = [CAKeyframeAnimation animationWithKeyPath:@"position"];
    animation.calculationMode = kCAAnimationLinear;
    animation.repeatCount = 0;
    animation.duration = duration;
    
    NSMutableArray *values = [NSMutableArray arrayWithCapacity:frames];
    CGFloat time = 0.0f;
    NSAssert(frames > 1,@"Frames must be larger than 1");
    CGFloat timeStep = 1.0f / (frames - 1);
    CGPoint delta = CGPointMake(end.x - start.x, end.y - start.y);
    for (int i=0; i<frames ; ++i) {
        CGPoint p = CGPointMake(start.x + block(time)*delta.x,
                                start.y + block(time)*delta.y);
        [values addObject:[NSValue valueWithCGPoint:p]];
        time += timeStep;
    }
    animation.values = values;
    
    return animation;
}

+ (id)animationScaleFrom:(CGFloat)start
                      to:(CGFloat)end
                duration:(NSTimeInterval)duration
                  frames:(NSInteger)frames
         withTimingBlock:(TimingBlock)block
{
    CAKeyframeAnimation *animation = [CAKeyframeAnimation animationWithKeyPath:@"transform"];
    animation.calculationMode = kCAAnimationLinear;
    animation.repeatCount = 0;
    animation.duration = duration;
    
    NSMutableArray *values = [NSMutableArray arrayWithCapacity:frames];
    CGFloat time = 0.0f;
    NSAssert(frames > 1,@"Frames must be larger than 1");
    CGFloat timeStep = 1.0f / (frames - 1);
    CGFloat delta = end - start;
    for (int i=0; i<frames ; ++i) {
        CGFloat f = start + block(time)*delta;
        CATransform3D transform = CATransform3DMakeScale(f, f, 1);
        [values addObject:[NSValue valueWithCATransform3D:transform]];
        time += timeStep;
    }
    animation.values = values;
    
    return animation;
}

@end


@implementation UIView (iZJU)

- (void)setTop:(CGFloat)top
{
    CGRect rect = self.frame;
    rect.origin.y = top;
    self.frame = rect;
}

- (void)setBottom:(CGFloat)bottom
{
    CGRect rect = self.frame;
    rect.origin.y = bottom - rect.size.height;
    self.frame = rect;
}

- (void)setLeft:(CGFloat)left
{
    CGRect rect = self.frame;
    rect.origin.x = left;
    self.frame = rect;
}

- (void)setRight:(CGFloat)right
{
    CGRect rect = self.frame;
    rect.origin.x = right - rect.size.width;
    self.frame = rect;
}

- (void)setX:(CGFloat)x
{
    self.left = x;
}

- (void)setY:(CGFloat)y
{
    self.top = y;
}

- (void)setWidth:(CGFloat)width
{
    CGRect rect = self.frame;
    rect.size.width = width;
    self.frame = rect;
}

- (void)setHeight:(CGFloat)height
{
    CGRect rect = self.frame;
    rect.size.height = height;
    self.frame = rect;
}

- (CGFloat)left
{
    return self.frame.origin.x;
}

- (CGFloat)right
{
    return self.frame.origin.x + self.frame.size.width;
}

- (CGFloat)top
{
    return self.frame.origin.y;
}

- (CGFloat)bottom
{
    return self.frame.origin.y + self.frame.size.height;
}

- (CGFloat)x
{
    return self.left;
}

- (CGFloat)y
{
    return self.top;
}

- (CGFloat)width
{
    return self.bounds.size.width;
}

- (CGFloat)height
{
    return self.bounds.size.height;
}

- (void)moveEaseOutBounceTo:(CGPoint)point
{
    [self moveEaseOutBounceTo:point duration:0.35];
}

- (void)moveEaseOutBounceTo:(CGPoint)point duration:(NSTimeInterval)duration
{
    
    TimingBlock block = ^(CGFloat ratio){
        CGFloat s = 7.5625f;
        CGFloat p = 2.75f;
        CGFloat l;
        if (ratio < (1.0f/p))
        {
            l = s * powf(ratio, 2.0f);
        }
        else
        {
            if (ratio < (2.0f/p))
            {
                ratio -= 1.5f/p;
                l = s * powf(ratio, 2.0f) + 0.75f;
            }
            else
            {
                if (ratio < 2.5f/p)
                {
                    ratio -= 2.25f/p;
                    l = s * powf(ratio, 2.0f) + 0.9375f;
                }
                else
                {
                    ratio -= 2.625f/p;
                    l = s * powf(ratio, 2.0f) + 0.984375f;
                }
            }
        }
        return l;
    };
    
    CAKeyframeAnimation *animation = [CAKeyframeAnimation animationPositionFrom:self.center
                                                                             to:point
                                                                       duration:duration
                                                                         frames:32
                                                                withTimingBlock:block];
    
    [self.layer addAnimation:animation
                      forKey:@"CLAnimation"];
    self.layer.position = point;
}

@end
