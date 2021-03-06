//
//  MGApiImpl+MGUser.h
//  MVVMGitHub
//
//  Created by XingJie on 2017/4/14.
//  Copyright © 2017年 xingjie. All rights reserved.
//

#import "MGApiImpl.h"

@interface MGApiImpl (MGUser)

- (RACSignal *)fetchUserInfoWithLoginName:(NSString *)loginName;

- (RACSignal *)fetchUserFollowersListWithLoginName:(NSString *)loginName;

- (RACSignal *)fetchUserFollowingListWithLoginName:(NSString *)loginName;

- (RACSignal *)fetchUserOrgListWithLoginName:(NSString *)loginName;

@end
