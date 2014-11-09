//
//  ZJULibraryCell.m
//  iZJU
//
//  Created by ricky on 13-9-20.
//  Copyright (c) 2013年 iZJU Studio. All rights reserved.
//

#import "ZJULibraryCell.h"
#import "UIView+iZJU.h"

@implementation ZJULibraryCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        _cellStyle = style;
        
        self.backgroundColor = [UIColor clearColor];
    }
    return self;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    switch (self.cellStyle) {
        case UITableViewCellStyleDefault:
        {
            self.textLabel.frame = CGRectMake(4, 4, 280, self.contentView.height - 8);
        }
            break;
        case UITableViewCellStyleSubtitle:
        {
            CGFloat h = self.height - 2 * 6;
            
            self.imageView.contentMode = UIViewContentModeScaleAspectFit;
            self.imageView.frame = CGRectMake(6, 6, h * 3 / 4, h);
            
            CGFloat l = CGRectGetMaxX(self.imageView.frame) + 6;
            CGFloat w = self.contentView.width - l - 4;
            self.textLabel.left = l;
            self.textLabel.width = MIN(w, self.textLabel.width);
            self.detailTextLabel.left = l;
            self.detailTextLabel.width = w;//MIN(w, self.textLabel.width);
        }
            break;
        case UITableViewCellStyleValue2:
        {
            const CGFloat s = 56.0f;
            self.textLabel.right = s;
            self.detailTextLabel.left = s + 2;
            self.detailTextLabel.width = self.contentView.width - (s + 2) - 4;
        }
            break;
        default:
            break;
    }
    
}

@end
