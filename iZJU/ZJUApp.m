//
//  ZJUApp.m
//  iZJU
//
//  Created by ricky on 13-6-28.
//  Copyright (c) 2013年 iZJU Studio. All rights reserved.
//

#import "ZJUApp.h"
#import "UIView+iZJU.h"

@interface ZJUApp ()

@end

static UIEdgeInsets buttonMargin = {.top = 4, .bottom = 4, .left = 4, .right = 4};

@implementation ZJUApp
@synthesize label = _label;
@synthesize button = _button;

+ (id)appWithTarget:(id)target action:(SEL)action
{
    ZJUApp *app = [[ZJUApp alloc] init];
    app.target = target;
    app.action = action;
    return [app autorelease];
}

- (void)dealloc
{
    [_label release];
    [_button release];
    [super dealloc];
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        self.backgroundColor = [UIColor clearColor];
        [self sizeToFit];
        
        [self addSubview:self.button];
        [self addSubview:self.label];
    }
    return self;
}

- (CGSize)sizeThatFits:(CGSize)size
{
    return CGSizeMake(64, 88);
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    _button.top = buttonMargin.top;
    _button.left = buttonMargin.left;
    _button.width = self.width - buttonMargin.left - buttonMargin.right;
    _button.height = _button.width;
    
    [self.label sizeToFit];
    self.label.width = MIN(self.width + 12, self.label.width);
    self.label.center = CGPointMake(self.width / 2, self.height / 2);
    self.label.bottom = self.height - 4;
}

- (UILabel*)label
{
    if (!_label) {
        _label = [[UILabel alloc] init];
        _label.font = [UIFont systemFontOfSize:14];
        _label.backgroundColor = [UIColor clearColor];
        _label.textAlignment = UITextAlignmentCenter;
        _label.textColor = [UIColor whiteColor];
        _label.lineBreakMode = UILineBreakModeMiddleTruncation;
        _label.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleTopMargin;
    }
    return _label;
}

- (UIButton*)button
{
    if (!_button) {
        _button = [[UIButton alloc] init];
        _button.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        _button.imageView.contentMode = UIViewContentModeScaleAspectFit ;
        _button.imageView.clipsToBounds = NO;
        _button.exclusiveTouch = NO;
        [_button addTarget:self
                    action:@selector(onPress:)
          forControlEvents:UIControlEventTouchUpInside];
    }
    return _button;
}

- (void)setIconImage:(UIImage *)iconImage
{
    [self.button setBackgroundImage:iconImage
                           forState:UIControlStateNormal];
}

- (UIImage*)iconImage
{
    return [self.button backgroundImageForState:UIControlStateNormal];
}

- (void)setIconText:(NSString *)iconText
{
    self.label.text = iconText;
}

- (NSString*)iconText
{
    return self.label.text;
}

- (void)onPress:(id)sender
{
    if ([self.target respondsToSelector:self.action])
        [self.target performSelector:self.action
                          withObject:self];
}

@end
