//
//  UITableView+MGAdd.m
//  MVVMGitHub
//
//  Created by XingJie on 2017/6/8.
//  Copyright © 2017年 xingjie. All rights reserved.
//

#import "UITableView+MGAdd.h"


@implementation UITableView (MGAdd)

static NSString *bindeKey = @"bindeKey";

#pragma mark - Add Property
- (void)setBinder:(MGTableViewBinder *)binder{
    
    objc_setAssociatedObject(self, &bindeKey, binder, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}
- (MGTableViewBinder *)binder{
    
    return objc_getAssociatedObject(self, &bindeKey);
}

#pragma mark - Instancetype

+ (instancetype)createTableWithFrame:(CGRect)frame binder:(UITableViewCreateBlock)tableViewCreateBlock{
    NSParameterAssert(tableViewCreateBlock);
    UITableView *tableView = [[UITableView alloc]initWithFrame:frame style:UITableViewStyleGrouped];
    tableView.backgroundColor = MGWhiteColor;
    MGTableViewBinder *binder = [MGTableViewBinder binderWithTable:tableView];
    tableView.delegate = binder;
    tableView.dataSource = binder;
    tableView.emptyDataSetSource = binder;
    tableView.emptyDataSetDelegate = binder;
    tableView.binder = binder;
    tableViewCreateBlock(binder);
    NSAssert(binder.reuseXibCellClass.count!=0||binder.reuseNoXibCellClass.count!=0, @"请先注册复用的Cell");
    NSAssert(binder.dataSourceSignal!=nil, @"设置数据源信号");
    NSAssert(binder.cellConfigBlock!=nil, @"请设置不同IndexPath Cell的复用标识");
    NSAssert(binder.errors!=nil, @"设置数据请求失败信号");
    return tableView;
}
+ (instancetype)createTableWithBinder:(UITableViewCreateBlock)tableViewCreateBlock{
    return [UITableView createTableWithFrame:CGRectZero binder:tableViewCreateBlock];
}

#pragma mark - EndRefresh
- (void)headerEndRefresh{
    if ([self.mj_header isRefreshing]) {
        [self.mj_header endRefreshing];
    }
}

- (void)footerEndRefresh{
    if ([self.mj_footer isRefreshing]) {
        [self.mj_footer endRefreshing];
    }
}

- (void)footerEndRefreshWithNoMoreData{
    if ([self.mj_footer isRefreshing]) {
        [self.mj_footer endRefreshingWithNoMoreData];
    }
}

- (void)endRefresh{
    if ([self.mj_header isRefreshing]) {
        [self.mj_header endRefreshing];
    }
    if ([self.mj_footer isRefreshing]) {
        [self.mj_footer endRefreshing];
    }
}

@end
