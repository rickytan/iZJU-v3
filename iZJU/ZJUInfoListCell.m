//
//  ZJUInfoListCell.m
//  iZJU
//
//  Created by ricky on 13-6-7.
//  Copyright (c) 2013年 iZJU Studio. All rights reserved.
//

#import "ZJUInfoListCell.h"
#import "UIView+iZJU.h"
#import "UIColor+RExtension.h"

#define CELL_PADDING_LEFT 12.0
#define CELL_PADDING_RIGHT 12.0
#define CELL_PADDING_TOP 12.0
#define CELL_PADDING_BOTTOM 10.0


static UIColor *blue = nil;
static UIColor *gray = nil;

@interface ZJUInfoListCell ()

@property (nonatomic, readonly) UIButton *userLabel;
- (void)onComment:(id)sender;
- (void)onUser:(id)sender;
@end

@implementation ZJUInfoListCell
@synthesize userLabel = _userLabel;
@synthesize comment = _comment;
@synthesize badgeImage = _badgeImage;

+ (void)initialize
{
    blue = [RGB(2, 81, 187) retain];
    gray = [[UIColor colorWithWhite:1.0*140/255
                              alpha:1.0] retain];
}

- (void)dealloc
{
    [_userLabel release];
    [_comment release];
    [_badgeImage release];
    
    [super dealloc];
}

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:UITableViewCellStyleSubtitle
                reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
        
        self.textLabel.textColor = blue;
        self.textLabel.highlightedTextColor = blue;
        self.detailTextLabel.textColor = gray;
        self.detailTextLabel.highlightedTextColor = gray;
        
        self.textLabel.font = [UIFont boldSystemFontOfSize:13];
        self.detailTextLabel.font = [UIFont systemFontOfSize:11];
        
        self.textLabel.shadowColor = [UIColor whiteColor];
        self.detailTextLabel.shadowColor = [UIColor whiteColor];
        
        self.textLabel.backgroundColor = [UIColor clearColor];
        self.detailTextLabel.backgroundColor = [UIColor clearColor];
        
        self.textLabel.numberOfLines = 2;
        
        self.textLabel.lineBreakMode = UILineBreakModeTailTruncation;
        self.detailTextLabel.lineBreakMode = UILineBreakModeTailTruncation;
        
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        self.backgroundColor = [UIColor clearColor];
        
    }
    return self;
}

- (void)didTransitionToState:(UITableViewCellStateMask)state
{
    [super didTransitionToState:state];
}

- (void)onAddNotification:(id)sender
{
    UITableView *table = (UITableView*)self.nextResponder;
    while (![table isKindOfClass:[UITableView class]]) {
        table = (UITableView*)table.nextResponder;
    }
    [table.delegate tableView:table
                performAction:@selector(onAddNotification:)
            forRowAtIndexPath:[table indexPathForCell:self]
                   withSender:sender];
}

- (void)onCancelNotification:(id)sender
{
    UITableView *table = (UITableView*)self.nextResponder;
    [table.delegate tableView:table
                performAction:@selector(onCancelNotification:)
            forRowAtIndexPath:[table indexPathForCell:self]
                   withSender:sender];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];
    // Configure the view for the selected state
    [self setNeedsDisplay];
}

- (void)setHighlighted:(BOOL)highlighted animated:(BOOL)animated
{
    [super setHighlighted:highlighted animated:animated];
    [self setNeedsDisplay];
}

- (void)drawRect:(CGRect)rect
{
    if (self.isSelected || self.isHighlighted) {
        [[UIColor colorWithWhite:0.7 alpha:0.4] setFill];
    }
    else
        [[UIColor clearColor] setFill];
    CGContextFillRect(UIGraphicsGetCurrentContext(), rect);
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    CGFloat width = self.contentView.width - CELL_PADDING_LEFT - CELL_PADDING_RIGHT;
    
    if (self.comment.text.length ==0 )
        [self.comment removeFromSuperview];
    else {
        [self.contentView addSubview:self.comment];
        [self.comment sizeToFit];
        self.comment.right = self.contentView.width - CELL_PADDING_RIGHT;
        self.comment.top = CELL_PADDING_TOP;
        width =  self.comment.left - CELL_PADDING_LEFT - 2;
    }
    
    //CGFloat leftCap = CELL_PADDING_LEFT;
    
    CGSize size = [self.textLabel.text sizeWithFont:self.textLabel.font
                                  constrainedToSize:CGSizeMake(width, CGFLOAT_MAX)];
    self.textLabel.bounds = CGRectMake(0, 0, size.width, size.height);
    self.textLabel.center = CGPointMake(self.comment.center.x, MAX(self.comment.center.y, 18));
    self.textLabel.left = CELL_PADDING_LEFT;
    //self.textLabel.width = self.comment.left - CELL_PADDING_LEFT - 2;
    //CGSize size = [self.textLabel sizeThatFits:CGSizeMake(self.textLabel.width, 0)];
    //self.textLabel.height = size.height;
    
    [self.detailTextLabel sizeToFit];
    self.detailTextLabel.bottom = self.contentView.height - CELL_PADDING_BOTTOM;
    self.detailTextLabel.left = CELL_PADDING_LEFT;
    
    if ([self.userLabel titleForState:UIControlStateNormal].length > 0) {
        [self.contentView addSubview:self.userLabel];
        [self.userLabel sizeToFit];
        self.userLabel.left = CELL_PADDING_LEFT;
        self.userLabel.bottom = self.contentView.height - CELL_PADDING_BOTTOM;
        
        self.detailTextLabel.center = self.userLabel.center;
        self.detailTextLabel.left = self.userLabel.right + 4;
    }
    else {
        [self.userLabel removeFromSuperview];
    }
    
    if (self.detailTextLabel.right > self.contentView.width - CELL_PADDING_RIGHT) {
        self.userLabel.top = MAX(self.textLabel.bottom + 2 - ((IS_IOS_7) ? 10 : 8), 30);
        self.userLabel.width = MIN(self.userLabel.width, self.contentView.width - CELL_PADDING_RIGHT - CELL_PADDING_LEFT);
        self.detailTextLabel.top = self.userLabel.bottom + 2 - ((IS_IOS_7) ? 8 : 0);
        self.detailTextLabel.left = CELL_PADDING_LEFT;
        self.detailTextLabel.width = MIN(self.detailTextLabel.width, self.contentView.width - CELL_PADDING_RIGHT - CELL_PADDING_LEFT);
    }
    
    if (_badgeImage.image) {
        [_badgeImage sizeToFit];
        [self.contentView addSubview:_badgeImage];
        _badgeImage.right = self.contentView.width - CELL_PADDING_RIGHT;
        _badgeImage.bottom = self.contentView.height - CELL_PADDING_BOTTOM;
    }
    else
        [_badgeImage removeFromSuperview];
}

- (UIButton*)userLabel
{
    if (!_userLabel) {
        _userLabel = [[UIButton buttonWithType:UIButtonTypeCustom] retain];
        _userLabel.titleLabel.lineBreakMode = UILineBreakModeTailTruncation;
        _userLabel.titleLabel.font = [UIFont systemFontOfSize:12];
        _userLabel.titleLabel.textColor = blue;
        _userLabel.titleLabel.shadowOffset = CGSizeMake(0, -1);
        _userLabel.titleLabel.minimumFontSize = 12;
        _userLabel.titleLabel.adjustsFontSizeToFitWidth = YES;
        _userLabel.adjustsImageWhenHighlighted = YES;
        _userLabel.userInteractionEnabled = NO;
        [_userLabel setTitleShadowColor:[UIColor whiteColor]
                               forState:UIControlStateNormal];
        [_userLabel setTitleColor:blue
                         forState:UIControlStateNormal];
        [_userLabel setTitleColor:[blue colorByLighting:-0.5]
                         forState:UIControlStateHighlighted];
        [_userLabel addTarget:self
                       action:@selector(onUser:)
             forControlEvents:UIControlEventTouchUpInside];
        [self.contentView addSubview:_userLabel];
    }
    return _userLabel;
}

- (void)setUserName:(NSString *)userName
{
    [self.userLabel setTitle:userName forState:UIControlStateNormal];
}

- (NSString*)userName
{
    return [self.userLabel titleForState:UIControlStateNormal];
}

- (void)setDelegate:(id<ZJUInfoListCellDelegate>)delegate
{
    _delegate = delegate;
    if (_delegate) {
        _userLabel.userInteractionEnabled = YES;
        _comment.userInteractionEnabled = YES;
    }
    else {
        _userLabel.userInteractionEnabled = NO;
        _comment.userInteractionEnabled = NO;
    }
}

- (ZJUCommentBubble*)comment
{
    if (!_comment) {
        _comment = [[ZJUCommentBubble alloc] init];
        _comment.userInteractionEnabled = NO;
        [_comment addTarget:self
                     action:@selector(onComment:)
           forControlEvents:UIControlEventTouchUpInside];
        [self.contentView addSubview:_comment];
    }
    return _comment;
}

- (UIImageView*)badgeImage
{
    if (!_badgeImage) {
        _badgeImage = [[UIImageView alloc] init];
        [self.contentView addSubview:_badgeImage];
    }
    return _badgeImage;
}

- (void)setTextGray:(BOOL)textGray
{
    if (_textGray != textGray) {
        _textGray = textGray;
        if (_textGray) {
            self.textLabel.textColor = gray;
            self.textLabel.highlightedTextColor = gray;
            
            _userLabel.titleLabel.textColor = gray;
            [_userLabel setTitleColor:gray
                             forState:UIControlStateNormal];
            [_userLabel setTitleColor:[gray colorByLighting:-0.5]
                             forState:UIControlStateHighlighted];
        }
        else {
            self.textLabel.textColor = blue;
            self.textLabel.highlightedTextColor = blue;
            
            _userLabel.titleLabel.textColor = blue;
            [_userLabel setTitleColor:blue
                             forState:UIControlStateNormal];
            [_userLabel setTitleColor:[blue colorByLighting:-0.5]
                             forState:UIControlStateHighlighted];
        }
    }
}

- (void)onComment:(id)sender
{
    if ([self.delegate respondsToSelector:@selector(infoListCellDidTapComment:)])
        [self.delegate infoListCellDidTapComment:self];
}

- (void)onUser:(id)sender
{
    if ([self.delegate respondsToSelector:@selector(infoListCellDidTapUsername:)])
        [self.delegate infoListCellDidTapUsername:self];
}

@end
