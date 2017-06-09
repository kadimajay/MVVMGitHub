//
//  MGApiImpl+MGRepo.m
//  MVVMGitHub
//
//  Created by XingJie on 2017/4/14.
//  Copyright © 2017年 xingjie. All rights reserved.
//

#import "MGApiImpl+MGRepo.h"

@implementation MGApiImpl (MGRepo)
- (RACSignal *)fetchRepoDetailWithOwner:(NSString *)ower repoName:(NSString *)repoName{
    
    NSParameterAssert([ower isExist]);
    NSParameterAssert([repoName isExist]);
    NSString *path = [NSString stringWithFormat:@"repos/%@/%@",ower,repoName];
    return [self startNetWorkRequestWithHttpMethod:GET path:path params:nil];
}
@end
