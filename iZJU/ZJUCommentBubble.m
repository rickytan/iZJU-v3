//
//  ZJUCommentBubble.m
//  iZJU
//
//  Created by ricky on 13-6-7.
//  Copyright (c) 2013年 iZJU Studio. All rights reserved.
//

#import "ZJUCommentBubble.h"

@implementation ZJUCommentBubble

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
        self.titleLabel.font = [UIFont boldSystemFontOfSize:10];
        self.textColor = [UIColor whiteColor];
        self.titleEdgeInsets = UIEdgeInsetsMake(0, 2, 0, 9);
        [self setBackgroundImage:[[UIImage imageNamed:@"comment-bg.png"] resizableImageWithCapInsets:UIEdgeInsetsMake(2, 2, 2, 9)]
                        forState:UIControlStateNormal];
    }
    return self;
}

- (CGSize)sizeThatFits:(CGSize)size
{
    size = [super sizeThatFits:size];
    size.width += 11.0;
    size.height = 18.0;
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
