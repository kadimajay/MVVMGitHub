//
//  MGExploreViewController.h
//  MVVMGitHub
//
//  Created by XingJie on 2016/12/23.
//  Copyright © 2016年 xingjie. All rights reserved.
//

#import "MGViewController.h"
@class MGExploreViewModel;
@interface MGExploreViewController : MGViewController

@property (nonatomic, strong, readonly) MGExploreViewModel *viewModel;


@end