//
//  ZJUCommentCell.m
//  iZJU
//
//  Created by ricky on 13-8-3.
//  Copyright (c) 2013年 iZJU Studio. All rights reserved.
//

#import "ZJUCommentCell.h"
#import "Toast+UIView.h"
#import "ZJULoginViewController.h"
#import "ZJUCommentReplyViewController.h"
#import "ZJUUser.h"
#import "NSDate+RExtension.h"
#import <QuartzCore/QuartzCore.h>

#define REFER_PADDING           4.0f
#define CONTENT_PADDING_TOP     24.0f
#define USER_FONT               [UIFont systemFontOfSize:12]
#define DATE_FONT               [UIFont systemFontOfSize:10]
#define CONTENT_FONT            [UIFont systemFontOfSize:12]

#define MAX_EMBED_LEVEL         4

@interface ZJUCommentReferView : UIView
{
@private
    UILabel             * _userLabel;
    UILabel             * _dateLabel;
    UILabel             * _contentLabel;
}
@property (nonatomic, retain) ZJUCommentReferView *subReferView;
@property (nonatomic, retain) NSDictionary *referItem;
@property (nonatomic, assign) BOOL shrinkSubReferView;
@property (nonatomic, assign) NSUInteger newsID;
@property (nonatomic, readonly) UILabel *dateLabel;

+ (CGFloat)heightWithWidth:(CGFloat)width andItem:(NSDictionary*)item;
+ (instancetype)referViewWithReferItem:(NSDictionary*)item;

@end

@implementation ZJUCommentReferView
@synthesize referItem = _referItem;
@synthesize dateLabel = _dateLabel;

+ (CGFloat)heightWithWidth:(CGFloat)width
                   andItem:(NSDictionary *)item
{
    CGSize size = CGSizeZero;
    @try {
        NSString *content = [item objectForKey:@"c"] ? [item objectForKey:@"c"] : @"";
        size = [content sizeWithFont:CONTENT_FONT
                   constrainedToSize:CGSizeMake(width - 2 * REFER_PADDING, CGFLOAT_MAX)
                       lineBreakMode:NSLineBreakByWordWrapping];
    }
    @catch (NSException *exception) {
        
    }
    
    return size.height + CONTENT_PADDING_TOP + REFER_PADDING;
}

+ (instancetype)referViewWithReferItem:(NSDictionary *)item
{
    ZJUCommentReferView *view = [[[ZJUCommentReferView alloc] init] autorelease];
    view.referItem = item;
    return view;
}

- (void)dealloc
{
    [_userLabel release];
    [_dateLabel release];
    [_contentLabel release];
    [_subReferView release];
    [super dealloc];
}

- (id)init
{
    return [self initWithFrame:CGRectZero];
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.layer.borderColor = [UIColor lightGrayColor].CGColor;
        self.layer.borderWidth = 1.0f;
        
        _userLabel = [[UILabel alloc] init];
        _userLabel.backgroundColor = [UIColor clearColor];
        _userLabel.textColor = [UIColor blueColor];
        _userLabel.font = USER_FONT;
        
        _dateLabel = [[UILabel alloc] init];
        _dateLabel.backgroundColor = [UIColor clearColor];
        _dateLabel.textColor = [UIColor lightGrayColor];
        _dateLabel.textAlignment = UITextAlignmentRight;
        _dateLabel.font = DATE_FONT;
        
        _contentLabel = [[UILabel alloc] init];
        _contentLabel.backgroundColor = [UIColor clearColor];
        _contentLabel.font = CONTENT_FONT;
        _contentLabel.numberOfLines = 0;
        _contentLabel.lineBreakMode = UILineBreakModeWordWrap;
        
        [self addSubview:_userLabel];
        [self addSubview:_dateLabel];
        [self addSubview:_contentLabel];
    }
    return self;
}

- (CGSize)sizeThatFits:(CGSize)size
{
    size.height = [ZJUCommentReferView heightWithWidth:size.width
                                               andItem:self.referItem];
    if (self.subReferView) {
        CGSize subsize = [self.subReferView sizeThatFits:CGSizeMake(size.width - (self.shrinkSubReferView ? 2 * REFER_PADDING : 0), 0)];
        size.height += subsize.height + (self.shrinkSubReferView ? REFER_PADDING : 0);
    }
    return size;
}

- (BOOL)canBecomeFirstResponder
{
    return YES;
}

- (BOOL)canPerformAction:(SEL)action
              withSender:(id)sender
{
    return action == @selector(copy:) || action == @selector(reply:);
}

- (BOOL)resignFirstResponder
{
    [[UIMenuController sharedMenuController] setMenuVisible:NO
                                                   animated:YES];
    return YES;
}

- (void)reply:(id)sender
{
    if ([ZJUUser currentUser].isLogin) {
        ZJUCommentReplyViewController *replyController = [[ZJUCommentReplyViewController alloc] init];
        replyController.newsID = self.newsID;
        replyController.replyCommentID = [[self.referItem objectForKey:@"id"] unsignedIntValue];
        UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:replyController];
        nav.navigationBar.translucent = NO;
        [self.window.rootViewController presentModalViewController:nav
                                                          animated:YES];
        [replyController release];
        [nav release];
    }
    else {
        ZJULoginViewController *loginController = [[ZJULoginViewController alloc] init];
        [self.window.rootViewController presentModalViewController:loginController
                                                          animated:YES];
        [loginController release];
    }
    [self resignFirstResponder];
}

- (void)copy:(id)sender
{
    [[UIPasteboard generalPasteboard] setString:_contentLabel.text];
    [self.window makeToast:@"已复制！"];
    [self resignFirstResponder];
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    [[UIMenuController sharedMenuController] setMenuVisible:NO];
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    if (CGRectContainsPoint(self.bounds, [[touches anyObject] locationInView:self])) {
        [self becomeFirstResponder];
        [[UIMenuController sharedMenuController] setTargetRect:_contentLabel.frame
                                                        inView:self];
        [[UIMenuController sharedMenuController] setMenuVisible:YES
                                                       animated:YES];
    }
}


- (void)layoutSubviews
{
    [super layoutSubviews];
    
    CGFloat width = self.bounds.size.width;
    
    CGFloat y = CONTENT_PADDING_TOP;
    
    [_userLabel sizeToFit];
    [_dateLabel sizeToFit];
    
    CGSize size = [self.subReferView sizeThatFits:CGSizeMake(width - (self.shrinkSubReferView ? 2 * REFER_PADDING : 0), 0)];
    if (self.shrinkSubReferView) {
        self.subReferView.frame = (CGRect){{REFER_PADDING, REFER_PADDING}, size };
    }
    else {
        self.subReferView.frame = (CGRect){{0, 0}, size};
    }
    
    y += CGRectGetMaxY(self.subReferView.frame);
    
    _userLabel.frame = (CGRect){{REFER_PADDING, CGRectGetMaxY(self.subReferView.frame) + 4.0 }, _userLabel.bounds.size};
    _dateLabel.frame = (CGRect){{width - REFER_PADDING - CGRectGetWidth(_dateLabel.bounds), CGRectGetMaxY(self.subReferView.frame) + 5.0 }, _dateLabel.bounds.size};
    _contentLabel.frame = UIEdgeInsetsInsetRect(self.bounds, UIEdgeInsetsMake(y, REFER_PADDING, REFER_PADDING, REFER_PADDING));
}

- (void)setSubReferView:(ZJUCommentReferView *)subReferView
{
    if (_subReferView != subReferView) {
        [_subReferView removeFromSuperview];
        [_subReferView release];
        _subReferView = [subReferView retain];
        [self addSubview:_subReferView];
        [self setNeedsLayout];
    }
}

- (void)setReferItem:(NSDictionary *)referItem
{
    if (_referItem != referItem) {
        [_referItem release];
        _referItem = [referItem retain];
        
        _userLabel.text = [[self.referItem objectForKey:@"u"] isKindOfClass:[NSNull class]] ? @"" : [self.referItem objectForKey:@"u"];
        _dateLabel.text = [[self.referItem objectForKey:@"d"] isKindOfClass:[NSNull class]] ? @"" : [self.referItem objectForKey:@"d"];
        _contentLabel.text = [[self.referItem objectForKey:@"c"] isKindOfClass:[NSNull class]] ? @"" : [self.referItem objectForKey:@"c"];
    }
}

@end

#define CELL_PADDING    8.0f

@implementation ZJUCommentCell
{
    ZJUCommentReferView             * _referView;
    UILabel                         * _userLabel;
    UILabel                         * _dateLabel;
    UILabel                         * _contentLabel;
}

+ (CGFloat)heightWithItem:(NSDictionary *)commentItem
{
    CGSize size = CGSizeZero;
    @try {
        NSString *c = [commentItem objectForKey:@"c"] ? [commentItem objectForKey:@"c"] : @"";
        size = [c sizeWithFont:CONTENT_FONT
             constrainedToSize:CGSizeMake(320 - 2 * CELL_PADDING, CGFLOAT_MAX)
                 lineBreakMode:NSLineBreakByWordWrapping];
    }
    @catch (NSException *exception) {
        
    }
    
    size.height += CONTENT_PADDING_TOP + CELL_PADDING;
    
    if ([[commentItem objectForKey:@"r"] isKindOfClass:[NSArray class]]) {
        NSArray *refers = (NSArray*)[commentItem objectForKey:@"r"];
        if (refers.count > 0)
            size.height += CELL_PADDING;
        
        int count = 0;
        for (NSDictionary *item in refers) {
            CGFloat width = 320 - 2 * CELL_PADDING - 2 * count * REFER_PADDING;
            CGFloat height = [ZJUCommentReferView heightWithWidth:width
                                                          andItem:item];
            size.height += height;
            
            if (count < MAX_EMBED_LEVEL - 1) {
                size.height += REFER_PADDING;
                ++count;
            }
        }
    }
    return size.height;
}

- (void)dealloc
{
    [_userLabel release];
    [_dateLabel release];
    [_contentLabel release];
    [super dealloc];
}

- (id)initWithStyle:(UITableViewCellStyle)style
    reuseIdentifier:(NSString *)reuseIdentifier
{
    NSAssert(style == UITableViewCellStyleDefault, @"Must use Default style");
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
        self.backgroundColor = [UIColor clearColor];
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        self.contentView.backgroundColor = [UIColor clearColor];
        
        _userLabel = [[UILabel alloc] init];
        _userLabel.backgroundColor = [UIColor clearColor];
        _userLabel.textColor = [UIColor blueColor];
        _userLabel.font = USER_FONT;
        
        _dateLabel = [[UILabel alloc] init];
        _dateLabel.backgroundColor = [UIColor clearColor];
        _dateLabel.textColor = [UIColor lightGrayColor];
        _dateLabel.textAlignment = UITextAlignmentRight;
        _dateLabel.font = DATE_FONT;
        
        _contentLabel = [[UILabel alloc] init];
        _contentLabel.backgroundColor = [UIColor clearColor];
        _contentLabel.font = CONTENT_FONT;
        _contentLabel.numberOfLines = 0;
        _contentLabel.lineBreakMode = UILineBreakModeWordWrap;
        
        [self.contentView addSubview:_userLabel];
        [self.contentView addSubview:_dateLabel];
        [self.contentView addSubview:_contentLabel];
    }
    return self;
}

- (ZJUCommentReferView*)buildReferView
{
    if ([[self.commentItem objectForKey:@"r"] isKindOfClass:[NSArray class]]) {
        NSArray *references = (NSArray*)[self.commentItem objectForKey:@"r"];
        __autoreleasing ZJUCommentReferView *lastView = nil;
        int count = references.count;
        int level = 0;
        BOOL shrink = NO;
        for (NSDictionary *referItem in references) {
            
            if (count > MAX_EMBED_LEVEL)
                --count;
            else
                shrink = YES;
            
            ZJUCommentReferView *referView = [ZJUCommentReferView referViewWithReferItem:referItem];
            referView.subReferView = lastView;
            referView.shrinkSubReferView = shrink;
            referView.newsID = self.newsID;
            referView.dateLabel.text = [NSString stringWithFormat:@"%d", ++level];
            lastView = referView;
        }
        [self.contentView addSubview:lastView];
        return lastView;
    }
    return nil;
}

- (BOOL)canBecomeFirstResponder
{
    return YES;
}

- (BOOL)canPerformAction:(SEL)action
              withSender:(id)sender
{
    return action == @selector(copy:) || action == @selector(reply:);
}

- (BOOL)resignFirstResponder
{
    [[UIMenuController sharedMenuController] setMenuVisible:NO
                                                   animated:YES];
    return [super resignFirstResponder];
}

- (void)reply:(id)sender
{
    if ([ZJUUser currentUser].isLogin) {
        ZJUCommentReplyViewController *replyController = [[ZJUCommentReplyViewController alloc] init];
        replyController.newsID = self.newsID;
        replyController.replyCommentID = [[self.commentItem objectForKey:@"id"] unsignedIntValue];
        UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:replyController];
        nav.navigationBar.translucent = NO;
        [self.window.rootViewController presentModalViewController:nav
                                                          animated:YES];
        [replyController release];
        [nav release];
    }
    else {
        ZJULoginViewController *loginController = [[ZJULoginViewController alloc] init];
        [self.window.rootViewController presentModalViewController:loginController
                                                          animated:YES];
        [loginController release];
    }
    [self resignFirstResponder];
}

- (void)copy:(id)sender
{
    [[UIPasteboard generalPasteboard] setString:_contentLabel.text];
    [self.window makeToast:@"已复制！"];
    [self resignFirstResponder];
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    CGFloat width = self.bounds.size.width;
    
    CGFloat y = CONTENT_PADDING_TOP;
    
    [_userLabel sizeToFit];
    [_dateLabel sizeToFit];
    
    if (_referView) {
        CGSize size = CGSizeMake(width - 2 * CELL_PADDING, 0);
        size = [_referView sizeThatFits:size];
        _referView.frame = (CGRect){{CELL_PADDING, CELL_PADDING}, size};
        y += CGRectGetMaxY(_referView.frame);
    }
    
    _userLabel.frame = (CGRect){{CELL_PADDING, CGRectGetMaxY(_referView.frame) + 4.0 }, _userLabel.bounds.size};
    _dateLabel.frame = (CGRect){{width - CELL_PADDING - CGRectGetWidth(_dateLabel.bounds), CGRectGetMaxY(_referView.frame) + 5.0 }, _dateLabel.bounds.size};
    
    _contentLabel.frame = UIEdgeInsetsInsetRect(self.bounds, UIEdgeInsetsMake(y, CELL_PADDING, CELL_PADDING, CELL_PADDING));
}

- (void)setCommentItem:(NSDictionary *)commentItem
{
    if (_commentItem != commentItem) {
        [_commentItem release];
        _commentItem = [commentItem retain];
        
        [_referView removeFromSuperview];
        _referView = [self buildReferView];
        
        _userLabel.text = [[self.commentItem objectForKey:@"u"] isKindOfClass:[NSNull class]] ? @"" : [self.commentItem objectForKey:@"u"];
        NSString *dateStr = [[self.commentItem objectForKey:@"d"] isKindOfClass:[NSNull class]] ? @"" : [self.commentItem objectForKey:@"d"];
        _dateLabel.text = [[NSDate dateFromString:dateStr] humanPreferredTimeString];
        _contentLabel.text = [[self.commentItem objectForKey:@"c"] isKindOfClass:[NSNull class]] ? @"" : [self.commentItem objectForKey:@"c"];
    }
}

- (void)showMenu
{
    [self becomeFirstResponder];
    [[UIMenuController sharedMenuController] setTargetRect:_contentLabel.frame
                                                    inView:self.contentView];
    [[UIMenuController sharedMenuController] setMenuVisible:YES
                                                   animated:YES];
}

@end
