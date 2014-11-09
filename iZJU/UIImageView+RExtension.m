//
//  UIImageView+RExtension.m
//  RImageView
//
//  Created by ricky on 13-3-30.
//  Copyright (c) 2013年 ricky. All rights reserved.
//

#import "UIImageView+RExtension.h"
#import <ImageIO/ImageIO.h>

@implementation UIImageView (RExtension)

- (void)setImageData:(NSData *)imageData
{
    CGImageSourceRef source = nil;
    
    NSData *data = imageData;
    
    if (!data) {
        return;
    }
    
    NSDictionary *options = [NSDictionary dictionaryWithObject:(id)kCGImagePropertyGIFDictionary
                                                        forKey:(id)kCGImageSourceTypeIdentifierHint];
    source = CGImageSourceCreateWithData((CFDataRef)data, (CFDictionaryRef)options);
    if (!source) {
        
        return;
    }
    
    if (CGImageSourceGetStatus(source) != kCGImageStatusComplete) {
        NSLog(@"File format not supportted");
        CFRelease(source);
        return;
    }
    
    CFIndex count = CGImageSourceGetCount(source);
    if (count == 0) {
        NSLog(@"No frames");
        CFRelease(source);
        return;
    }
    
    NSMutableArray *images = [NSMutableArray arrayWithCapacity:count];
    for (CFIndex i=0; i < count; ++i) {
        CGImageRef image = CGImageSourceCreateImageAtIndex(source, i, NULL);
        if (image) {
            [images addObject:[UIImage imageWithCGImage:image]];
            CFRelease(image);
        }
        else {
            NSLog(@"Frame %lu load failed!",i);
        }
    }
    
    CFRelease(source);
    
    if (images.count == 1)
        self.image = images.lastObject;
    else {
        self.animationImages = [NSArray arrayWithArray:images];
        
        NSDictionary *properties = [(NSDictionary*)CGImageSourceCopyProperties(source, NULL) autorelease];
        properties = [properties objectForKey:(id)kCGImagePropertyGIFDictionary];
        
        NSTimeInterval delay = [[properties objectForKey:(id)kCGImagePropertyGIFDelayTime] floatValue];
        delay = MAX(delay, 0.1);
        CGFloat loopCount = [[properties objectForKey:(id)kCGImagePropertyGIFLoopCount] floatValue];
        
        self.animationRepeatCount = loopCount;
        self.animationDuration = delay * count;
        
        [self startAnimating];
    }
}

- (void)setGifImage:(NSURL*)imageURL
{
    [NSURLConnection sendAsynchronousRequest:[NSURLRequest requestWithURL:imageURL]
                                       queue:[NSOperationQueue currentQueue]
                           completionHandler:^(NSURLResponse *r, NSData *d, NSError *e) {
                               [self setImageData:d];
                           }];
    
}

@end
