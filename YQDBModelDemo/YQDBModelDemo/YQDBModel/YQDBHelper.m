//
//  YQDBHelper.m
//  RunTimeDemo
//
//  Created by Mopon on 16/5/19.
//  Copyright © 2016年 Mopon. All rights reserved.
//

#import "YQDBHelper.h"


@interface YQDBHelper ()

@property (nonatomic, retain) FMDatabaseQueue *dbQueue;

@end

@implementation YQDBHelper

+ (instancetype)shareInstance
{
    static YQDBHelper *instance = nil;
    static dispatch_once_t predicate;
    dispatch_once(&predicate, ^{
        instance = [[self alloc] init];
    });
    return instance;
}

+ (NSString *)dbPathWithDirectoryName:(NSString *)directoryName{

    NSString *docsdir = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
    NSFileManager *fileManager = [[NSFileManager alloc] init];
    if (directoryName.length ==0) {
        docsdir = [docsdir stringByAppendingPathComponent:@"YQDB"];
    }else{
        docsdir = [docsdir stringByAppendingPathComponent:directoryName];
    }
    BOOL isDir;
    BOOL exit =[fileManager fileExistsAtPath:docsdir isDirectory:&isDir];
    if (!exit || !isDir) {//如果文件夹不存在。则创建
        [fileManager createDirectoryAtPath:docsdir withIntermediateDirectories:YES attributes:nil error:nil];
    }
    NSString *dbpath = [docsdir stringByAppendingPathComponent:@"yqdb.sqlite"];
    return dbpath;
}
#pragma mark - 数据库路径
+ (NSString *)dbPath{
    return [self dbPathWithDirectoryName:nil];
}

- (FMDatabaseQueue *)dbQueue{
    
    if (_dbQueue == nil) {
        _dbQueue = [FMDatabaseQueue databaseQueueWithPath:[self.class dbPath]];
    }
    return _dbQueue;
}



@end
