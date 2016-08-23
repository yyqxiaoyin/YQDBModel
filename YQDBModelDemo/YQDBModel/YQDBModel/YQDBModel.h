//
//  YQDBModel.h
//  YQDBModel
//
//  Created by Mopon on 16/8/23.
//  Copyright © 2016年 Mopon. All rights reserved.
//

#import <Foundation/Foundation.h>

/** SQLite五种数据类型 */
#define SQLTEXT     @"TEXT"//文本类型
#define SQLINTEGER  @"INTEGER"//整形
#define SQLREAL     @"REAL"//浮点型
#define SQLBLOB     @"BLOB"//二进制类型
#define SQLNULL     @"NULL"//空值

#define PrimaryKey  @"PRIMARY KEY AUTOINCREMENT"//主键类型
#define primaryId   @"pk"//主键名

@interface YQDBModel : NSObject

/**
 *  主键id
 */
@property (nonatomic, assign) int pk;

/**
 *  列名
 */
@property (retain, readonly, nonatomic) NSMutableArray *columeNames;

/**
 *  列类型
 */
@property (retain, readonly, nonatomic) NSMutableArray *columeTypes;

/**
 *  获取所有属性
 *
 *  @return 返回属性类型与属性名的字典
 */
+(NSDictionary *)getProperties;

/**
 *  获取所有属性（包括主键）
 *
 *  @return 返回属性类型与属性名的字典
 */
+(NSDictionary *)getAllProperties;

/**
 *  数据库中是否存在表
 */
+(BOOL)isExistInTable;

/**
 *  创建表
 */
+(BOOL)createTable;

/**
 *  保存单个数据
 */
-(BOOL)save;

/**
 *  保存或者更新(如果主键存在，更新数据，如果主键不存在，插入数据)
 */
-(BOOL)saveOrUpdate;

/**
 *  更新单个数据
 */
-(BOOL)update;

/**
 *  删除单个数据
 */
-(BOOL)deleteObject;

/**
 *  查询当前表的所有数据
 */
+(NSArray *)findAllObject;

@end
