//
//  MGNavgationController.m
//  MVVMGitHub
//
//  Created by XingJie on 2017/2/21.
//  Copyright © 2017年 xingjie. All rights reserved.
//

#import "MGViewModelBasedNavigation.h"

@interface MGViewModelBasedNavigation ()

@property (nonatomic, strong, readwrite) MGViewModelMapper *viewModelMapper;

@end

@implementation MGViewModelBasedNavigation

@synthesize topViewModel = _topViewModel;
@synthesize viewModels = _viewModels;

- (void)pushViewModel:(id<MGViewModelProtocol>)viewModel animated:(BOOL)animated{
    
    if ([self.viewModels containsObject:viewModel]) {
        [self.viewModels removeObject:viewModel];
    }
    [self.viewModels addObject:viewModel];
    UIViewController *vc = (UIViewController *)[self.viewModelMapper viewControllerForViewModel:viewModel];
    if (![vc isKindOfClass:NSClassFromString(@"MGMainViewController")]&&
        ![vc isKindOfClass:NSClassFromString(@"MGExploreViewController")]&&
        ![vc isKindOfClass:NSClassFromString(@"MGProfileViewController")]&&
        ![vc isKindOfClass:NSClassFromString(@"MGRepositoryViewController")]) {
        [vc setHidesBottomBarWhenPushed:YES];
    }
    [self.navigationController pushViewController:vc animated:animated];
}
- (void)popToViewModel:(id<MGViewModelProtocol>)viewModel animated:(BOOL)animated{
    
    if (![self.viewModels containsObject:viewModel]) {
        NSAssert(NO, @"返回的控制器不在栈中");
    }
    NSInteger index = [self.viewModels indexOfObject:viewModel];
    [self.viewModels removeObjectsInRange:NSMakeRange(index+1, self.viewModels.count)];
    UIViewController *vc = [self.viewModelMapper viewControllerForViewModel:viewModel];
    [self.navigationController popToViewController:vc animated:animated];
}

- (void)popToRootViewControllerAnimated:(BOOL)animated{
    
    UIViewController *vc = [self.viewModelMapper viewControllerForViewModel:[self.viewModels firstObject]];
    [self.viewModels removeObjectsInRange:NSMakeRange(1, self.viewModels.count)];
    [self.navigationController popToViewController:vc animated:animated];
}

- (void)presentViewModel:(id<MGViewModelProtocol>)viewModel animated:(BOOL)animated{
    
    UIViewController *vc = [self.viewModelMapper viewControllerForViewModel:viewModel];
    [self.navigationController presentViewController:vc animated:animated completion:nil];
}

- (void)dissMissViewModel:(id<MGViewModelProtocol>)viewModel animated:(BOOL)animated{
    
    UIViewController *vc = [self.viewModelMapper viewControllerForViewModel:viewModel];
    [vc dismissViewControllerAnimated:animated completion:nil];
}

#pragma mark - lazy load
- (MGViewModelMapper *)viewModelMapper{
    
    if (_viewModelMapper==nil) {
        _viewModelMapper = [[MGViewModelMapper alloc]init];
    }
    return _viewModelMapper;
}
@end