//
//  MGRepositoryViewController.m
//  MVVMGitHub
//
//  Created by XingJie on 2016/12/23.
//  Copyright © 2016年 xingjie. All rights reserved.
//

#import "MGRepositoryViewController.h"
#import "MGRepositoryViewModel.h"
#import "MGRepositoriesCell.h"

@interface MGRepositoryViewController ()
<UITableViewDelegate,
UITableViewDataSource>

@property (nonatomic, strong, readwrite) MGRepositoryViewModel *viewModel;

@property (nonatomic, strong) UITableView *tableView;


@end

@implementation MGRepositoryViewController

#pragma mark - Instance Method
- (instancetype)initWithViewModel:(id<MGViewModelProtocol>)viewModel{
    
    if (self = [super init]) {
        self.viewModel = (MGRepositoryViewModel *)viewModel;
        self.viewModel.cancelFetchDataSignal = [self rac_signalForSelector:@selector(viewDidDisappear:)];
    }
    return self;
}
#pragma mark - Life Cycle
- (void)viewDidLoad {
    
    [super viewDidLoad];
    [self.view addSubview:self.tableView];
}
- (void)bindViewModel{
    
    @weakify(self);
    [[self rac_signalForSelector:@selector(viewDidAppear:)] subscribeNext:^(id x) {
        @strongify(self);
        [self.viewModel.fetchDataFromServiceCommand execute:@1];
    }];
    
    [[[RACObserve(self.viewModel, dataSource) filter:^BOOL(NSArray *value) {
        return value;
    }]deliverOn:[RACScheduler mainThreadScheduler]]
     subscribeNext:^(NSArray *dataSource) {
        NSLog(@"dataSource == %@",dataSource);
        @strongify(self);
        [self.tableView reloadData];
    }];
    
    [self.viewModel.fetchDataFromServiceCommand.executing subscribeNext:^(NSNumber*execut) {
        if ([execut boolValue]) {
            [SVProgressHUD showWithStatus:@"loading..."];
        }else{
            [SVProgressHUD dismissHUD];
            [self.tableView.mj_header endRefreshing];
        }
    }];
}
#pragma mark - Load Data

#pragma mark - Touch Action

#pragma mark - Delegate Method
//UITableViewDelegate
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    
    return [self.viewModel.dataSource count];
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    return [MGRepositoriesCell configCellForTableView:tableView
                                           repository:self.viewModel.dataSource[indexPath.row]
                                      reuseIdentifier:@"Cell"];
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    return [MGRepositoriesCell cellHeight];
}
#pragma mark - Lazy Load
- (UITableView *)tableView{
    
    if (_tableView == nil) {
        _tableView = [[UITableView alloc]initWithFrame:self.view.bounds style:UITableViewStyleGrouped];
        _tableView.dataSource = self;
        _tableView.delegate = self;
        @weakify(self);
        _tableView.mj_header = [MJRefreshNormalHeader headerWithRefreshingBlock:^{
            @strongify(self);
            [self.viewModel.fetchDataFromServiceCommand execute:0];
        }];
    }
    return _tableView;
}
@end
