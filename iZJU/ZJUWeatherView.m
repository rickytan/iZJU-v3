//
//  ZJUWeatherView.m
//  iZJU
//
//  Created by ricky on 13-8-25.
//  Copyright (c) 2013年 iZJU Studio. All rights reserved.
//

#import "ZJUWeatherView.h"

@implementation ZJUWeatherView
{
    NSUInteger              _currentFrame;
    NSUInteger              _totalFrame;
    
    NSTimer               * _timer;
    
    BOOL                    _horizontal;
}

- (void)dealloc
{
    self.image = nil;
    [_timer invalidate];
    [_timer release];
    [super dealloc];
}

- (void)commonInit
{
    self.backgroundColor = [UIColor clearColor];
    self.duration = 1.0;
    self.userInteractionEnabled = NO;
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        [self commonInit];
    }
    return self;
}

- (void)setImage:(UIImage *)image
{
    if (_image != image) {
        [_image release];
        _image = [image retain];
        
        _currentFrame = 0;
        
        CGSize size = self.image.size;
        if (size.width >= size.height) {
            _horizontal = YES;
            _totalFrame = size.width / size.height;
        }
        else {
            _horizontal = NO;
            _totalFrame = size.height / size.width;
        }
        [self setNeedsDisplay];
    }
}

- (void)startAnimation
{
    if (!self.image) {
        NSLog(@"You must set image first!");
        return;
    }
    if (_timer.isValid)
        return;
    
    _timer = [NSTimer scheduledTimerWithTimeInterval:self.duration / _totalFrame
                                              target:self
                                            selector:@selector(onTimer:)
                                            userInfo:nil
                                             repeats:YES];
}

- (void)stopAnimation
{
    [_timer invalidate];
    [_timer release];
    _timer = nil;
}

- (CGSize)sizeThatFits:(CGSize)size
{
    CGFloat v = MIN(self.image.size.width, self.image.size.height);
    return CGSizeMake(v, v);
}

// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
    CGFloat v = MAX(self.bounds.size.width, self.bounds.size.height);
    if (_horizontal) {
        [self.image drawInRect:(CGRect){{- v * _currentFrame, 0}, {v * _totalFrame, v}}];
    }
    else {
        [self.image drawInRect:(CGRect){{0, - v * _currentFrame}, {v, v * _totalFrame}}];
    }
}

- (void)onTimer:(NSTimer*)timer
{
    _currentFrame = (_currentFrame + 1) % _totalFrame;
    [self setNeedsDisplay];
}

@end
