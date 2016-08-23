//
//  YQDBModelHelper.m
//  YQDBModel
//
//  Created by Mopon on 16/8/23.
//  Copyright © 2016年 Mopon. All rights reserved.
//

#import "YQDBHelper.h"

@interface YQDBHelper ()

@property (nonatomic ,strong)FMDatabaseQueue *dbQueue;

@end

@implementation YQDBHelper

+(instancetype)shareInstance{

    static YQDBHelper *instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        
        instance = [[self alloc]init];
    });
    return instance;
}

+(NSString *)dbPathWithDirectorName:(NSString *)directoryName{

    NSString *docsdir = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
    NSFileManager *fileManager = [NSFileManager defaultManager];
    if (directoryName.length == 0) {
        docsdir = [docsdir stringByAppendingPathComponent:@"YQDB"];
    }else{
        docsdir = [docsdir stringByAppendingPathComponent:directoryName];
    }
    
    BOOL isDir;
    BOOL exit = [fileManager fileExistsAtPath:docsdir isDirectory:&isDir];
    if (exit || !isDir) {//如果文件夹不存在。创建文件夹
        [fileManager createDirectoryAtPath:docsdir withIntermediateDirectories:YES attributes:nil error:nil];
    }
    
    NSString *dbPath = [docsdir stringByAppendingPathComponent:@"yqdb.sqlite"];
    

    return dbPath;
}

+(NSString *)dbPath{

    return [self dbPathWithDirectorName:nil];

}

-(FMDatabaseQueue *)dbQueue{

    if (_dbQueue == nil) {
        
        _dbQueue = [FMDatabaseQueue databaseQueueWithPath:[[self class] dbPath]];
        
    }
    
    return _dbQueue;
}

@end
