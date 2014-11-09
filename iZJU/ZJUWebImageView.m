//
//  ZJUWebImageView.m
//  iZJU
//
//  Created by ricky on 13-6-13.
//  Copyright (c) 2013年 iZJU Studio. All rights reserved.
//

#import "ZJUWebImageView.h"
#import "Toast+UIView.h"
#import "UIImageView+RExtension.h"

@interface ZJUWebImageView () <NSURLConnectionDelegate, UIScrollViewDelegate, UIGestureRecognizerDelegate>
{
    NSMutableData                   * _imageData;
    UITapGestureRecognizer          * _doubleTap;
    BOOL                              _zoomIn;
}
@property (nonatomic, readonly) UIWindow *contentWindow;
@property (nonatomic, assign) UIActivityIndicatorView *spinnerView;
@property (nonatomic, assign) UIScrollView *scrollView;
@property (nonatomic, assign) UIView *filterView;
@property (nonatomic, assign) UIImageView *imageView;
@property (nonatomic, assign) UIToolbar *bottomBar;
- (void)onDownload:(id)sender;
@end

@implementation ZJUWebImageView
@synthesize contentWindow = _contentWindow;
@synthesize spinnerView = _spinnerView;
@synthesize imageURL = _imageURL;
@synthesize imageView = _imageView;

- (void)dealloc
{
    [_contentWindow removeFromSuperview];
    [_contentWindow release];
    _contentWindow = nil;
    
    [_imageData release];
    
    self.imageURL = nil;
    
    [super dealloc];
}

- (id)init
{
    return [self initWithFrame:[UIScreen mainScreen].bounds];
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        self.autoresizesSubviews = YES;
        self.backgroundColor = [UIColor clearColor];
        self.originRect = [UIScreen mainScreen].bounds;
        
        self.placeholderImage = [UIImage imageNamed:@"photo-placeholder.png"];
        
        _filterView = [[UIView alloc] initWithFrame:self.bounds];
        _filterView.backgroundColor = [UIColor blackColor];
        _filterView.alpha = 0.0;
        [self addSubview:_filterView];
        [_filterView release];
        
        _scrollView = [[UIScrollView alloc] initWithFrame:self.bounds];
        _scrollView.bounces = YES;
        _scrollView.showsHorizontalScrollIndicator = NO;
        _scrollView.showsVerticalScrollIndicator = NO;
        _scrollView.delegate = self;
        _scrollView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        [self addSubview:_scrollView];
        [_scrollView release];
        
        _imageView = [[UIImageView alloc] initWithFrame:self.scrollView.bounds];
        _imageView.contentMode = UIViewContentModeScaleAspectFit;
        _imageView.alpha = 0.0;
        [_scrollView addSubview:_imageView];
        [_imageView release];
        
        _spinnerView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
        _spinnerView.autoresizingMask = UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleTopMargin;
        _spinnerView.center = self.center;
        [self addSubview:_spinnerView];
        [_spinnerView release];
        
        _bottomBar = [[UIToolbar alloc] initWithFrame:CGRectMake(0, self.bounds.size.height - 44, self.bounds.size.width, 44)];
        _bottomBar.autoresizingMask = UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleWidth;
        //_bottomBar.backgroundColor = [UIColor blackColor];
        _bottomBar.barStyle = UIBarStyleBlackTranslucent;
        _bottomBar.hidden = YES;
        [self addSubview:_bottomBar];
        [_bottomBar release];
        
        UIBarButtonItem *downloadItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"download.png"]
                                                                         style:UIBarButtonItemStylePlain
                                                                        target:self
                                                                        action:@selector(onDownload:)];
        UIBarButtonItem *spacer = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace
                                                                                target:nil
                                                                                action:nil];
        _bottomBar.items = @[spacer, downloadItem];
        [spacer release];
        [downloadItem release];
        
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self
                                                                              action:@selector(onTap:)];
        tap.delegate = self;
        [self.scrollView addGestureRecognizer:tap];
        [tap release];
        
        UITapGestureRecognizer *doubleTap = [[UITapGestureRecognizer alloc] initWithTarget:self
                                                                                    action:@selector(onDoubleTap:)];
        doubleTap.numberOfTapsRequired = 2;
        doubleTap.delegate = self;
        [self addGestureRecognizer:doubleTap];
        _doubleTap = doubleTap;
        [doubleTap release];
        
        [tap requireGestureRecognizerToFail:doubleTap];
    }
    return self;
}

- (UIWindow*)contentWindow
{
    if (!_contentWindow) {
        _contentWindow = [[UIWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
        _contentWindow.backgroundColor = [UIColor clearColor];
        _contentWindow.windowLevel = UIWindowLevelStatusBar + 1;
    }
    return _contentWindow;
}

- (void)setUpScaleAndFrame
{
    CGSize imgSize = self.imageView.image.size;
    CGSize size = self.scrollView.bounds.size;
    
    CGFloat hfactor = size.width / imgSize.width;
    CGFloat vfactor = size.height / imgSize.height;
    CGFloat factor = MIN(hfactor, vfactor);
    
    self.imageView.bounds = (CGRect){{0,0}, {imgSize.width * factor, imgSize.height * factor}};
    
    if (hfactor > 1.0 && vfactor > 1.0)
        factor = 1.0;
    
    [UIView setAnimationsEnabled:NO];
    self.scrollView.minimumZoomScale = 1.0;
    self.scrollView.maximumZoomScale = 1.0 / factor;
    self.scrollView.zoomScale = 1.0;
    [UIView setAnimationsEnabled:YES];
}

- (void)startLoadImage
{
    
    if ([self.imageURL isKindOfClass:[NSString class]])
        self.imageURL = [NSURL URLWithString:(NSString*)self.imageURL];
    
    NSURLCache *cache = [NSURLCache sharedURLCache];
    
    NSURLRequest *request = [NSURLRequest requestWithURL:self.imageURL
                                             cachePolicy:NSURLRequestReturnCacheDataElseLoad
                                         timeoutInterval:6.0];
    NSCachedURLResponse *response = [cache cachedResponseForRequest:request];
    if (response) {
        [self.imageView setImageData:response.data];
        self.imageView.alpha = 1.0;
        
        [UIView animateWithDuration:0.35
                              delay:0.0
                            options:UIViewAnimationOptionCurveEaseOut
                         animations:^{
                             self.filterView.alpha = 1.0;
                             [self setUpScaleAndFrame];
                             [self centeringImageView];
                         }
                         completion:^(BOOL finished) {
                             
                             self.bottomBar.hidden = NO;
                         }];
     
    }
    else {
        [self.spinnerView startAnimating];
        NSURLConnection *connection = [NSURLConnection connectionWithRequest:request
                                                                    delegate:self];
        [connection start];
        
        [UIView animateWithDuration:0.35
                              delay:0.0
                            options:UIViewAnimationOptionCurveEaseOut
                         animations:^{
                             self.filterView.alpha = 1.0;
                         }
                         completion:^(BOOL finished) {
                             
                         }];
    }
}

- (void)show
{
    self.contentWindow.hidden = NO;
    
    self.frame = self.contentWindow.bounds;
    self.imageView.frame = self.originRect;
    self.imageView.image = self.placeholderImage;
    self.filterView.alpha = 0.0;
    
    [self.contentWindow addSubview:self];

    [self startLoadImage];
}

- (void)dismiss
{
    self.scrollView.zoomScale = self.scrollView.minimumZoomScale;
    [self centeringImageView];
    
    self.bottomBar.hidden = YES;
    [UIView animateWithDuration:0.35
                          delay:0.0
                        options:UIViewAnimationOptionCurveEaseOut
                     animations:^{
                         self.filterView.alpha = 0.0;
                         self.imageView.frame = self.originRect;
                     }
                     completion:^(BOOL finished) {
                         [self removeFromSuperview];
                         self.contentWindow.hidden = YES;
                         [self.contentWindow removeFromSuperview];
                     }];
}

- (void)centeringImageView
{
    CGSize boundsSize = self.scrollView.bounds.size;
    CGRect frameToCenter = self.imageView.frame;
    
    // Horizontally
    if (frameToCenter.size.width <= boundsSize.width) {
        frameToCenter.origin.x = floorf((boundsSize.width - frameToCenter.size.width) / 2.0);
	} else {
        frameToCenter.origin.x = 0;
	}
    
    // Vertically
    if (frameToCenter.size.height <= boundsSize.height) {
        frameToCenter.origin.y = floorf((boundsSize.height - frameToCenter.size.height) / 2.0);
	} else {
        frameToCenter.origin.y = 0;
	}
    
    self.imageView.frame = frameToCenter;
}

- (void)onTap:(UITapGestureRecognizer*)tap
{
    switch (tap.state) {
        case UIGestureRecognizerStateEnded:
            [self dismiss];
            break;
            
        default:
            break;
    }
}

- (void)onDoubleTap:(UITapGestureRecognizer*)tap
{
    switch (tap.state) {
        case UIGestureRecognizerStateEnded:
            if (!_zoomIn) {
                CGPoint point = [tap locationInView:self.imageView];
                [self.scrollView zoomToRect:(CGRect){point, CGSizeZero}
                                   animated:YES];
                
                [self centeringImageView];
            }
            else {
                [self.scrollView setZoomScale:self.scrollView.minimumZoomScale
                                     animated:YES];
                
                [self centeringImageView];
            }
            break;
            
        default:
            break;
    }
}

- (void)onDownload:(id)sender
{
    UIImageWriteToSavedPhotosAlbum(self.imageView.image, self, @selector(image:didFinishSavingWithError:contextInfo:), NULL);
}

- (void)image:(UIImage *)image
didFinishSavingWithError:(NSError *)error
  contextInfo:(void *)contextInfo
{
    if (!error)
        [[UIApplication sharedApplication].keyWindow makeToast:@"已保存！"];
    else
        [[UIApplication sharedApplication].keyWindow makeToast:@"保存失败..."];
}

#pragma mark - NSConnection Delegate

- (void)connection:(NSURLConnection *)connection
  didFailWithError:(NSError *)error
{
    self.imageView.image = [UIImage imageNamed:@"error-placeholder.png"];
    [self.spinnerView stopAnimating];
    
    [UIView animateWithDuration:0.35
                     animations:^{
                         self.imageView.alpha = 1.0;
                     }];
}

- (void)connection:(NSURLConnection *)connection
didReceiveResponse:(NSURLResponse *)response
{
    [_imageData release];
    _imageData = [[NSMutableData alloc] initWithCapacity:10*1024];
}

- (void)connection:(NSURLConnection *)connection
    didReceiveData:(NSData *)data
{
    [_imageData appendData:data];
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
    [self.imageView setImageData:_imageData];
    [UIView animateWithDuration:0.35
                     animations:^{
                         self.imageView.alpha = 1.0;
                         [self setUpScaleAndFrame];
                         [self centeringImageView];
                     }
                     completion:^(BOOL finished) {
                         self.bottomBar.hidden = NO;
                     }];
    
    [self.spinnerView stopAnimating];
}

#pragma mark - UIGesture Delegate

- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer
{
    if (gestureRecognizer == _doubleTap) {
        return self.scrollView.maximumZoomScale > 1.0f;
    }
    return YES;
}

#pragma mark - UIScroll Delegate

- (void)scrollViewWillBeginZooming:(UIScrollView *)scrollView
                          withView:(UIView *)view
{
    _zoomIn = YES;
}

- (void)scrollViewDidZoom:(UIScrollView *)scrollView
{
    [self centeringImageView];
}

- (UIView*)viewForZoomingInScrollView:(UIScrollView *)scrollView
{
    return self.imageView;
}

- (void)scrollViewDidEndZooming:(UIScrollView *)scrollView
                       withView:(UIView *)view
                        atScale:(float)scale
{
    [self centeringImageView];
    if (scale == scrollView.minimumZoomScale)
        _zoomIn = NO;
}

@end
