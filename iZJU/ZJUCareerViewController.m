//
//  ZJUCareerViewController.m
//  iZJU
//
//  Created by ricky on 13-6-29.
//  Copyright (c) 2013年 iZJU Studio. All rights reserved.
//

#import "ZJUCareerViewController.h"
#import "ZJUApp.h"
#import "UIView+iZJU.h"
#import "ZJURequest.h"
#import "ZJUCareerInfoListViewController.h"
#import "ZJUCareerNewsListViewController.h"
#import "ZJUCareerTalkListViewController.h"


static NSString *labels[] = {@"重要通知",@"综合招聘",@"宣讲会",@"实习生专场",@"一般招聘",@"实习实训",@"重要央企",@"事业单位",@"军工集团",@"高校招聘",@"博士后招聘",@"海外升学"};

@interface ZJUCareerViewController () <UITableViewDataSource, UITableViewDelegate>
@property (nonatomic, retain) UITableView *tableView;
@end

@implementation ZJUCareerViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        self.title = @"就业实习";
    }
    return self;
}

- (void)loadView
{
    [super loadView];
    /*
    _tableView = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStyleGrouped];
    _tableView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    _tableView.delegate = self;
    _tableView.dataSource = self;
    [self.view addSubview:_tableView];
     */
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    self.view.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"bg.png"]];
    
    static NSInteger numberOfColumes = 4;
    static CGFloat CELL_MARGIN = 8.0f;
    static CGFloat CELL_WIDTH = 64.0f;
    static CGFloat CELL_HEIGHT = 100.0f;
    
    CGFloat width = CELL_WIDTH + CELL_MARGIN;
    CGFloat height = CELL_HEIGHT + CELL_MARGIN;
    CGFloat startX = (self.view.width - width * numberOfColumes + CELL_MARGIN + CELL_WIDTH) / 2.0;
    CGFloat startY = CELL_HEIGHT / 2.0 + CELL_MARGIN;
    
    for (int i=0; i<12; ++i) {
        ZJUApp *app = [ZJUApp appWithTarget:self
                                     action:@selector(onApp:)];
        app.tag = i;
        app.iconImage = [UIImage imageNamed:[NSString stringWithFormat:@"%02d.jpg", i+1]];
        app.iconText = labels[i];
        app.label.textColor = [UIColor blackColor];
        app.center = CGPointMake(startX + width * (i % numberOfColumes), startY + height * (i / numberOfColumes));
        [self.view addSubview:app];
    }
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:NO
                                             animated:YES];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - UITable Delegate & Datasource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 12;
}

- (UITableViewCell*)tableView:(UITableView *)tableView
        cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell"];
    if (!cell) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault
                                       reuseIdentifier:@"Cell"] autorelease];
        cell.selectionStyle = UITableViewCellSelectionStyleGray;
    }
    cell.textLabel.text = labels[indexPath.row];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView
didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath
                             animated:YES];
    
    ZJUApp *app = [ZJUApp appWithTarget:nil
                                 action:NULL];
    app.tag = indexPath.row;
    app.iconText = labels[indexPath.row];
    [self onApp:app];
}

#pragma mark - Methods

- (void)onApp:(ZJUApp*)app
{
    switch (app.tag) {
        case 0:
        {
            ZJUCareerNewsListViewController *newsController = [[ZJUCareerNewsListViewController alloc] init];
            newsController.type = CareerNewsTypeNotice;
            newsController.title = app.iconText;
            [self.navigationController pushViewController:newsController
                                                 animated:YES];
            [newsController release];
        }
            break;
        case 1:
        {
            ZJUCareerNewsListViewController *newsController = [[ZJUCareerNewsListViewController alloc] init];
            newsController.type = CareerNewsTypeIntergated;
            newsController.title = app.iconText;
            [self.navigationController pushViewController:newsController
                                                 animated:YES];
            [newsController release];
        }
            break;
        case 2:
        case 3:
        {
            ZJUCareerTalkListViewController *talkController = [[ZJUCareerTalkListViewController alloc] init];
            talkController.type = app.tag - 2;
            talkController.title = app.iconText;
            [self.navigationController pushViewController:talkController
                                                 animated:YES];
            [talkController release];
        }
            break;
        case 4:
        case 5:
        case 6:
        case 7:
        case 8:
        case 9:
        case 10:
        case 11:
        {
            ZJUCareerInfoListViewController *infoController = [[ZJUCareerInfoListViewController alloc] init];
            infoController.type = app.tag - 4;
            infoController.title = app.iconText;
            [self.navigationController pushViewController:infoController
                                                 animated:YES];
            [infoController release];
        }
            break;
        default:
            break;
    }
}

@end
