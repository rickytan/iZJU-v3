//
//  ZJUInfoCommonViewController.m
//  iZJU
//
//  Created by ricky on 13-11-13.
//  Copyright (c) 2013年 iZJU Studio. All rights reserved.
//

#import "ZJUInfoCommonViewController.h"

@interface ZJUInfoCommonViewController ()

@end

@implementation ZJUInfoCommonViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        self.title = @"信息共享空间";
        self.appURL = [NSURL URLWithString:@"http://api.izju.org/v2/app/infocommon"];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
