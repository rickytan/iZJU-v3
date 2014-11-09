//
//  ZJULibraryViewController.m
//  iZJU
//
//  Created by ricky on 13-8-23.
//  Copyright (c) 2013年 iZJU Studio. All rights reserved.
//

#import "ZJUBookDetailViewController.h"
#import "ZJULibraryCell.h"
#import "Toast+UIView.h"
#import "UIView+iZJU.h"
#import "SVProgressHUD.h"
#import <SDWebImage/UIImageView+WebCache.h>

@interface ZJUBookDetailViewController () <UISearchBarDelegate, UISearchDisplayDelegate>
@property (nonatomic, assign) UIImageView *bookCoverImageView;
@end

@implementation ZJUBookDetailViewController

- (void)dealloc
{
    self.book = nil;
    [super dealloc];
}

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:UITableViewStyleGrouped];
    if (self) {
        self.title = @"详情";
        
    }
    return self;
}

- (void)loadView
{
    [super loadView];
    
    _bookCoverImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"placeholder-book.png"]];
    _bookCoverImageView.contentMode = UIViewContentModeScaleAspectFit;
    _bookCoverImageView.frame = CGRectMake(10, 10, 90, 90 / 3 * 4);
    [self.tableView addSubview:_bookCoverImageView];
    [_bookCoverImageView release];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.tableView.backgroundView = [[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"bg.png"]] autorelease];
    self.tableView.rowHeight = 64.0f;
    if (IS_IOS_7)
        self.tableView.separatorInset = UIEdgeInsetsMake(0, 8, 0, 8);
    
    [self.bookCoverImageView setImageWithURL:[NSURL URLWithString:self.book.coverImage]
                            placeholderImage:[UIImage imageNamed:@"placeholder-book.png"]];
}

- (void)viewDidLayoutSubviews
{
    [super viewDidLayoutSubviews];
    
    UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0
                                                                                     inSection:0]];
    CGFloat r = cell.right;
    //CGFloat t = cell.top;
    cell.width = self.tableView.bounds.size.width - 100;
    cell.right = r;
    
    cell = [self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:1
                                                                    inSection:0]];
    r = cell.right;
    cell.width = self.tableView.bounds.size.width - 100;
    cell.right = r;
    
    cell = [self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:2
                                                                    inSection:0]];
    r = cell.right;
    cell.width = self.tableView.bounds.size.width - 100;
    cell.right = r;
    
    self.bookCoverImageView.frame = CGRectMake(10, 10, 90, 90 / 3 * 4);
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Methods


#pragma mark - UISearchDisplay Delegate

#pragma mark - UITable Delegate & Datasource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 2 + self.book.items.count;
}

- (NSInteger)tableView:(UITableView *)tableView
 numberOfRowsInSection:(NSInteger)section
{
    switch (section) {
        case 0:
            return 3;
            break;
        case 1:
            return 1;
            break;
        default:
            return 4;
            break;
    }
}

- (NSString*)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    if (section == 2)
        return @"单册状态";
    return nil;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    CGFloat height = 36.0f;
    switch (indexPath.section) {
        case 0:
            return 36.0f;
            break;
        case 1:
        {
            NSString *text = (self.book.summary.length == 0) ? @"无描述" : self.book.summary;
            CGSize size = [text sizeWithFont:[UIFont systemFontOfSize:12]
                           constrainedToSize:CGSizeMake(280, CGFLOAT_MAX)
                               lineBreakMode:NSLineBreakByWordWrapping];
            height = MAX(size.height + 8, height);
        }
            break;
    }
    return height;
}

- (UITableViewCell*)tableView:(UITableView *)tableView
        cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = nil;
    switch (indexPath.section) {
        case 0:
        {
            cell = [tableView dequeueReusableCellWithIdentifier:@"DetailCell"];
            if (!cell) {
                cell = [[[ZJULibraryCell alloc] initWithStyle:UITableViewCellStyleValue2
                                              reuseIdentifier:@"DetailCell"] autorelease];
                cell.textLabel.font = [UIFont systemFontOfSize:12];
                cell.detailTextLabel.font = [UIFont systemFontOfSize:12];
                cell.selectionStyle = UITableViewCellSelectionStyleNone;
            }
            
            cell.accessoryType = UITableViewCellAccessoryNone;
            
            switch (indexPath.row) {
                case 0:
                    cell.textLabel.text = @"书名：";
                    cell.detailTextLabel.text = self.book.name;
                    break;
                case 1:
                    cell.textLabel.text = @"作者：";
                    cell.detailTextLabel.text = self.book.author;
                    break;
                case 2:
                    cell.textLabel.text = @"出版社：";
                    cell.detailTextLabel.text = self.book.publish;
                    break;
                default:
                    break;
            }
        }
            break;
        case 1:
        {
            cell = [tableView dequeueReusableCellWithIdentifier:@"DetailCellSummary"];
            if (!cell) {
                cell = [[[ZJULibraryCell alloc] initWithStyle:UITableViewCellStyleDefault
                                              reuseIdentifier:@"DetailCellSummary"] autorelease];
                cell.textLabel.font = [UIFont systemFontOfSize:12];
                cell.textLabel.textColor = [UIColor blackColor];
                cell.textLabel.numberOfLines = 0;
                cell.textLabel.lineBreakMode = NSLineBreakByWordWrapping;
                cell.selectionStyle = UITableViewCellSelectionStyleNone;
            }
            cell.textLabel.text = (self.book.summary.length == 0) ? @"无描述" : self.book.summary;
        }
            break;
        default:
        {
            cell = [tableView dequeueReusableCellWithIdentifier:@"DetailCell"];
            if (!cell) {
                cell = [[[ZJULibraryCell alloc] initWithStyle:UITableViewCellStyleValue2
                                              reuseIdentifier:@"DetailCell"] autorelease];
                cell.textLabel.font = [UIFont systemFontOfSize:12];
                cell.detailTextLabel.font = [UIFont systemFontOfSize:12];
                cell.selectionStyle = UITableViewCellSelectionStyleNone;
            }
            
            ZJULibraryItem *item = self.book.items[indexPath.section - 2];
            
            cell.accessoryType = UITableViewCellAccessoryNone;
            switch (indexPath.row) {
                case 0:
                    cell.textLabel.text = @"分馆：";
                    cell.detailTextLabel.text = item.sublibrary;
                    break;
                case 1:
                    cell.textLabel.text = @"索书号：";
                    if (item.locationID.length > 0) {
                        cell.detailTextLabel.text = item.locationID;
                        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
                    }
                    else {
                        cell.detailTextLabel.text = @"无";
                        cell.accessoryType = UITableViewCellAccessoryNone;
                    }
                    break;
                case 2:
                    cell.textLabel.text = @"条码：";
                    cell.detailTextLabel.text = item.barcode;
                    break;
                case 3:
                {
                    cell.textLabel.text = @"状态：";
                    if (item.isHold)
                        cell.detailTextLabel.text = [NSString stringWithFormat:@"%@ 预约保留", item.status];
                    else if (item.returnDate)
                        cell.detailTextLabel.text = [NSString stringWithFormat:@"%@ 应还日期：%@", item.status, item.returnDate];
                    else
                        cell.detailTextLabel.text = item.status;
                }
                    break;
                default:
                    break;
            }
        }
            break;
    }
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section >= 2 && indexPath.row == 1) {
        ZJULibraryItem *item = self.book.items[indexPath.section - 2];
        [[UIPasteboard generalPasteboard] setString:item.locationID];
        [SVProgressHUD showSuccessWithStatus:@"已复制！"];
    }
}

@end
