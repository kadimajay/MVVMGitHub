//
//  MGExploreViewModel.m
//  MVVMGitHub
//
//  Created by XingJie on 2016/12/23.
//  Copyright © 2016年 xingjie. All rights reserved.
//

#import "MGExploreViewModel.h"
#import "MGApiService.h"
#import "MGRepositoriesModel.h"
#import "MGShowcasesModel.h"
#import "MGUserModel.h"

NSString *const kTrendReposDataSourceArrayKey = @"kTrendReposDataSourceArrayKey";
NSString *const kShowcasesDataSourceArrayKey = @"kShowcasesDataSourceArrayKey";
NSString *const kPopularUsersDataSourceArrayKey = @"kPopularUsersDataSourceArrayKey";
NSString *const kPopularReposDataSourceArrayKey = @"kPopularReposDataSourceArrayKey";

@interface MGExploreViewModel ()

@property (nonatomic, strong, readwrite) RACCommand *requestTrendReposCommand;
@property (nonatomic, strong, readwrite) RACCommand *requestPopularUsersCommand;
@property (nonatomic, strong, readwrite) RACCommand *requestShowcasesCommand;
@property (nonatomic, strong, readwrite) RACCommand *requestLanguageCommand;
@property (nonatomic, strong, readwrite) RACCommand *requestPopularReposCommand;

@property (nonatomic, strong, readwrite) NSMutableDictionary *dataSourceDict;

@property (nonatomic, strong) NSIndexSet *dataIndexSet;
@end

@implementation MGExploreViewModel

@synthesize page = _page;
@synthesize dataSource = _dataSource;
@synthesize didSelectedRowCommand = _didSelectedRowCommand;
@synthesize cancelFetchDataSignal = _cancelFetchDataSignal;
@synthesize fetchDataFromServiceCommand = _fetchDataFromServiceCommand;
@synthesize fetchDataFromServiceSuccess = _fetchDataFromServiceSuccess;

#define EXPLORE_BASE_URL @"http://trending.codehub-app.com/v2/"

- (void)initialize{
    
    self.dataSourceDict = [NSMutableDictionary dictionary];
    self.dataIndexSet = [NSIndexSet indexSetWithIndexesInRange:NSMakeRange(0, 10)];
    self.cancelFetchDataSignal = self.rac_willDeallocSignal;
    
    RACSubject *showcases = [RACSubject subject];
    RACSubject *popularUsers = [RACSubject subject];
    RACSubject *trendRepos = [RACSubject subject];
    RACSubject *popularRepos = [RACSubject subject];
    @weakify(self);
    [[[RACSignal combineLatest:@[showcases,popularUsers,trendRepos,popularRepos]
                        reduce:^id(NSNumber *showcases,NSNumber *popularUsers,
                                   NSNumber *trendRepos,NSNumber *popularRepos){
                            return @([showcases boolValue]&&[popularRepos boolValue]&&
                            [trendRepos boolValue]&&[popularUsers boolValue]);
    }] filter:^BOOL(NSNumber *value) {
        return [value boolValue];
    }] subscribeNext:^(id x) {
        @strongify(self);
        [self setFetchDataFromServiceSuccess:YES];
    }];
    
    
    self.fetchDataFromServiceCommand = [[RACCommand alloc]initWithSignalBlock:^RACSignal *(id input) {
        @strongify(self);
        [self.requestTrendReposCommand execute:nil];
        [self.requestShowcasesCommand execute:nil];
        [self.requestPopularUsersCommand execute:nil];
        [self.requestPopularReposCommand execute:nil];
        return [RACSignal empty];
    }];

    self.requestShowcasesCommand = [[RACCommand alloc]initWithSignalBlock:^RACSignal *(id input) {
        return [[[[[MGApiService starNetWorkRequestWithHttpMethod:GET
                                                         baseUrl:EXPLORE_BASE_URL
                                                            path:@"showcases"
                                                          params:nil] retry:2]
                 takeUntil:self.cancelFetchDataSignal] doNext:^(NSArray *dataArr) {
            @strongify(self);
            NSArray *showcases = [MGShowcasesModel mj_objectArrayWithKeyValuesArray:dataArr];
            [self.dataSourceDict setObject:showcases forKey:kShowcasesDataSourceArrayKey];
        }] doCompleted:^{
            [showcases sendNext:@YES];
        }];
    }];

    self.requestPopularUsersCommand = [[RACCommand alloc]initWithSignalBlock:^RACSignal *(RACTuple *input) {
        return [[[[[MGApiService starNetWorkRequestWithHttpMethod:GET
                                                          baseUrl:[NSString stringWithFormat:@"%@",MGSharedDelegate.client.baseURL]
                                                           path:@"/search/users"
                                                           params:@{@"q":@"language:objective-c",
                                                                    @"sort":@"followers",
                                                                    @"order":@"desc"}] retry:2]
                takeUntil:self.cancelFetchDataSignal] doNext:^(NSDictionary *dict) {
            @strongify(self);
            NSArray *popularUsers = [MGUserModel mj_objectArrayWithKeyValuesArray:[dict valueForKey:@"items"]];
            [self.dataSourceDict setObject:popularUsers forKey:kPopularUsersDataSourceArrayKey];
        }] doCompleted:^{
            [popularUsers sendNext:@YES];
        }];
    }];

    self.requestTrendReposCommand = [[RACCommand alloc]initWithSignalBlock:^RACSignal *(RACTuple *input) {
        return [[[[[MGApiService starNetWorkRequestWithHttpMethod:GET
                                                         baseUrl:EXPLORE_BASE_URL
                                                            path:@"trending"
                                                           params:@{@"since":@"weekly",
                                                                    @"language":@"objective-c"}] retry:2]
                 takeUntil:self.cancelFetchDataSignal] doNext:^(NSArray *dataArr) {
            @strongify(self);
            NSArray *trending = [MGRepositoriesModel mj_objectArrayWithKeyValuesArray:dataArr];
            [self.dataSourceDict setObject:trending forKey:kTrendReposDataSourceArrayKey];
        }] doCompleted:^{
            [trendRepos sendNext:@YES];
        }];
    }];
    
    self.requestPopularReposCommand =[[RACCommand alloc]initWithSignalBlock:^RACSignal *(id input) {
        return [[[[[MGApiService starNetWorkRequestWithHttpMethod:GET
                                                          baseUrl:[NSString stringWithFormat:@"%@",MGSharedDelegate.client.baseURL]
                                                             path:@"/search/repositories"
                                                           params:@{@"q":@"language:objective-c",
                                                                    @"sort":@"stars",
                                                                    @"order":@"desc"}] retry:2]
                  takeUntil:self.cancelFetchDataSignal] doNext:^(NSDictionary *dict) {
            @strongify(self);
            NSArray *popularRepo = [MGRepositoriesModel mj_objectArrayWithKeyValuesArray:[dict valueForKey:@"items"]];
            [self.dataSourceDict setObject:popularRepo forKey:kPopularReposDataSourceArrayKey];
        }] doCompleted:^{
            [popularRepos sendNext:@YES];
        }];
    }];
    

    /*
    self.requestLanguageCommand = [[RACCommand alloc]initWithSignalBlock:^RACSignal *(id input) {
        return [[[[MGApiService starNetWorkRequestWithHttpMethod:GET
                                                         baseUrl:EXPLORE_BASE_URL
                                                            path:@"languages"
                                                          params:nil] retry:2]
                 takeUntil:self.cancelFetchDataSignal] doNext:^(NSArray *dataArr) {
            NSArray *path = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
            NSString *documentsPath = [path objectAtIndex:0];
            NSString *plistPath = [documentsPath stringByAppendingPathComponent:@"github_language_name_slug.plist"];
            NSLog(@"plistPath--%@",plistPath);
            //写入文件
            [dataArr writeToFile:plistPath atomically:YES];
        }];
        
    }];
     */
}

@end
