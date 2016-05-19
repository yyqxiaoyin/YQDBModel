//
//  YQDBHelper.h
//  RunTimeDemo
//
//  Created by Mopon on 16/5/19.
//  Copyright © 2016年 Mopon. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FMDB.h"

@interface YQDBHelper : NSObject
@property (nonatomic, retain, readonly) FMDatabaseQueue *dbQueue;

+ (instancetype)shareInstance;

/**
 *  数据库路径
 *
 *  @return 路径字符串
 */
+ (NSString *)dbPath;

@end
