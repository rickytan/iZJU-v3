//
//  ZJUEditingViewController.h
//  iZJU
//
//  Created by ricky on 13-6-26.
//  Copyright (c) 2013年 iZJU Studio. All rights reserved.
//

#import "ZJUBaseTableViewController.h"

@class ZJUEditingViewController;

@protocol ZJUEditingViewControllerDelegate <NSObject>
@optional
- (void)editingViewController:(ZJUEditingViewController*)controller didEndEditingWithText:(NSString*)text;
- (void)editingViewControllerDidCancelEditing:(ZJUEditingViewController *)controller;

@end

typedef enum {
    EditingTypeTextField,
    EditingTypeTextView,
    EditingTypePhone,
    EditingTypeOptions,
    EditingTypeDate,
} EditingType;

@interface ZJUEditingViewController : ZJUBaseTableViewController
@property (nonatomic, assign) id<ZJUEditingViewControllerDelegate> delegate;
@property (nonatomic, assign) id target;
@property (nonatomic, assign) SEL action;
@property (nonatomic, retain, readwrite) NSString *string;
@property (nonatomic, assign) EditingType type;
@property (nonatomic, retain) NSArray *options;     // Must set for EditingTypeOptions
@end
