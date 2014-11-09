//
//  UIImageView+RExtension.h
//  RImageView
//
//  Created by ricky on 13-3-30.
//  Copyright (c) 2013年 ricky. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIImageView (RExtension)
- (void)setGifImage:(NSURL*)imageURL;
- (void)setImageData:(NSData*)imageData;
@end
