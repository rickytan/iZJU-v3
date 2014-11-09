//
//  ZJUBadgeButton.m
//  iZJU
//
//  Created by ricky on 13-6-10.
//  Copyright (c) 2013年 iZJU Studio. All rights reserved.
//

#import "ZJUBadgeButton.h"

@implementation ZJUBadgeButton

- (id)init
{
    return [self initWithFrame:CGRectZero];
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        //self.buttonType = UIButtonTypeCustom;
        self.contentEdgeInsets = UIEdgeInsetsMake(0, 4, 0, 4);
        self.titleLabel.font = [UIFont systemFontOfSize:9];
        [self setTitleColor:[UIColor whiteColor]
                   forState:UIControlStateNormal];
        [self setTitleColor:[UIColor lightGrayColor]
                   forState:UIControlStateHighlighted];
        self.titleLabel.textAlignment = UITextAlignmentCenter;
        //self.titleEdgeInsets = UIEdgeInsetsMake(1, 1, -1, -1);
        [self setBackgroundImage:[[UIImage imageNamed:@"badge.png"] resizableImageWithCapInsets:UIEdgeInsetsMake(0, 7, 0, 7)]
                        forState:UIControlStateNormal];
    }
    return self;
}

- (CGSize)sizeThatFits:(CGSize)size
{
    size = [super sizeThatFits:size];
    //size.width += 8.0;
    //size.height = 15.0;
    return size;
}

- (void)sizeToFit
{
    [super sizeToFit];
}

- (void)setText:(NSString *)text
{
    self.titleLabel.text = text;
    [self setTitle:text
          forState:UIControlStateNormal];
    [self sizeToFit];
}

- (NSString*)text
{
    return self.titleLabel.text;
}

- (void)setTextColor:(UIColor *)textColor
{
    self.titleLabel.textColor = textColor;
    [self setTitleColor:textColor
               forState:UIControlStateNormal];
}

- (UIColor*)textColor
{
    return self.titleLabel.textColor;
}

@end
