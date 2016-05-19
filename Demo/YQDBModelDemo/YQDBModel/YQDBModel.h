//
//  DBModel.h
//  RunTimeDemo
//
//  Created by Mopon on 16/5/19.
//  Copyright © 2016年 Mopon. All rights reserved.
//

#import <Foundation/Foundation.h>

/** SQLite五种数据类型 */
#define SQLTEXT     @"TEXT"
#define SQLINTEGER  @"INTEGER"
#define SQLREAL     @"REAL"
#define SQLBLOB     @"BLOB"
#define SQLNULL     @"NULL"
#define PrimaryKey  @"PRIMARY KEY AUTOINCREMENT"

#define primaryId   @"pk"

@interface DBModel : NSObject
/** 主键 id */
@property (nonatomic, assign)int pk;
/** 列名 */
@property (retain, readonly, nonatomic) NSMutableArray         *columeNames;
/** 列类型 */
@property (retain, readonly, nonatomic) NSMutableArray         *columeTypes;

/**
 *  获取所有属性。返回类型与属性名的字典
 */
+ (NSDictionary *)getProperties;

/**
 *  获取所有属性，包含主键PK
 */
+ (NSDictionary *)getAllProperties;

/**
 *  数据库中是否存在表
 */
+ (BOOL)isExistInTable;

/**
 * 创建表
 * 如果已经创建，返回YES
 */
+ (BOOL)createTable;

/** 保存或更新
 * 如果不存在主键，保存，
 * 有主键，则更新
 */
- (BOOL)saveOrUpdate;

/** 保存单个数据 */
- (BOOL)save;
/**
 *  删除单个数据
 */
- (BOOL)deleteObject;
/**
 *  查询所有数据
 */
+ (NSArray *)findAll;

/**
 *  更新单个数据
 */
- (BOOL)update;

@end
