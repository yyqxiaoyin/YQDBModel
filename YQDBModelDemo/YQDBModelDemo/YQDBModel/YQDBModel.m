//
//  DBModel.m
//  RunTimeDemo
//
//  Created by Mopon on 16/5/19.
//  Copyright © 2016年 Mopon. All rights reserved.
//

#import "YQDBModel.h"
#import <objc/runtime.h>
#import "YQDBHelper.h"

@implementation DBModel

+(void)initialize{

    if (self != [DBModel self]) {
        
        [self createTable];
    }
}

-(instancetype)init{

    self = [super init];
    if (self) {
        NSDictionary *dic = [self.class getAllProperties];
        _columeNames = [[NSMutableArray alloc] initWithArray:[dic objectForKey:@"name"]];
        _columeTypes = [[NSMutableArray alloc] initWithArray:[dic objectForKey:@"type"]];
    }
    return self;
}

#pragma mark - 获取所有属性
+(NSDictionary *)getProperties{

    NSMutableArray *proNames = [NSMutableArray array];
    NSMutableArray *proTypes = [NSMutableArray array];
    unsigned int count;
    objc_property_t *properties = class_copyPropertyList([self class], &count);
    for (int i = 0; i<count; i++) {
        objc_property_t property = properties[i];

//        获取属性名
        NSString *propertyName = [NSString stringWithUTF8String:property_getName(property)];

//        把属性名添加进属性名数组
        [proNames addObject:propertyName];
        
//        获取属性类型等参数
        NSString *propertyType = [NSString stringWithUTF8String:property_getAttributes(property)];
        
        if ([propertyType hasPrefix:@"T@"]) {
            [proTypes addObject:SQLTEXT];
        } else if ([propertyType hasPrefix:@"Ti"]||[propertyType hasPrefix:@"TI"]||[propertyType hasPrefix:@"Ts"]||[propertyType hasPrefix:@"TS"]||[propertyType hasPrefix:@"TB"]||[propertyType hasPrefix:@"Tq"]||[propertyType hasPrefix:@"TQ"]) {
            [proTypes addObject:SQLINTEGER];
        } else {
            [proTypes addObject:SQLREAL];
        }
    }
    free(properties);
    
    return [NSDictionary dictionaryWithObjectsAndKeys:proNames,@"name",proTypes,@"type",nil];
}

#pragma mark 获取所有属性包括主键
+(NSDictionary *)getAllProperties{

    NSDictionary *dict = [self.class getProperties];
    
    NSMutableArray *proNames = [NSMutableArray array];
    NSMutableArray *proTypes = [NSMutableArray array];
    
    [proNames addObject:primaryId];
    [proTypes addObject:[NSString stringWithFormat:@"%@ %@",SQLINTEGER,PrimaryKey]];
    [proNames addObjectsFromArray:[dict objectForKey:@"name"]];
    [proTypes addObjectsFromArray:[dict objectForKey:@"type"]];
    
    return [NSDictionary dictionaryWithObjectsAndKeys:proNames,@"name",proTypes,@"type",nil];
}

#pragma mark - 创建表
+ (BOOL)createTable{

    YQDBHelper *helper = [YQDBHelper shareInstance];
    __block BOOL res = YES;
    [helper.dbQueue inDatabase:^(FMDatabase *db) {
        NSString *tableName = NSStringFromClass(self.class);
        NSString *culumeAndType = [self.class getColumeAndTypeString];
        NSString *sql = [NSString stringWithFormat:@"CREATE TABLE IF NOT EXISTS %@(%@);",tableName,culumeAndType];
        if (![db executeUpdate:sql]) {
            res = NO;
            return ;
        }
        res = [self.class addNewColumn:db tableName:tableName];
    }];
    return res;
}

#pragma makr - 往表中添加新添加的字段
+(BOOL)addNewColumn:(FMDatabase *)db tableName:(NSString *)tableName{
    
    NSMutableArray *columns = [NSMutableArray array];
    FMResultSet *resultSet = [db getTableSchema:tableName];
    while ([resultSet next]) {//遍历取出数据库中所有字段名
        NSString *column = [resultSet stringForColumn:@"name"];
        [columns addObject:column];
    }
    NSDictionary *dict = [self.class getAllProperties];//取出所有属性列表字典
    NSArray *properties = [dict objectForKey:@"name"];//取出所有属性名字
    
    //        谓词查找数据库中没有的字段
    NSPredicate *filterPredicate = [NSPredicate predicateWithFormat:@"NOT (SELF IN %@)",columns];
    //过滤数组
    NSArray *resultArray = [properties filteredArrayUsingPredicate:filterPredicate];
    for (NSString *column in resultArray) {//遍历新增字段数组
        NSUInteger index = [properties indexOfObject:column];//取出属性在属性列表中的下标
        NSString *proType = [[dict objectForKey:@"type"] objectAtIndex:index];//根据下标查找对应的属性
        NSString *fieldSql = [NSString stringWithFormat:@"%@ %@",column,proType];
        NSString *sql = [NSString stringWithFormat:@"ALTER TABLE %@ ADD COLUMN %@ ",NSStringFromClass(self.class),fieldSql];//添加新加的字段到对应表中
        if (![db executeUpdate:sql]) {
            
            return NO;
        }
    }
    return YES;
}

#pragma mark - 获取由属性名跟类型组装的sql语句以创建表
+(NSString *)getColumeAndTypeString{

    NSMutableString *pars = [NSMutableString string];
    NSDictionary *dict = [self.class getAllProperties];
    
    NSMutableArray *names = [dict objectForKey:@"name"];
    NSMutableArray *types = [dict objectForKey:@"type"];
    
    for (int i =0; i<names.count; i++) {
        
        [pars appendFormat:@"%@ %@",[names objectAtIndex:i],[types objectAtIndex:i]];
        
        if (i != names.count - 1) {
            [pars appendString:@","];
        }
    }
    
    return pars;
}
#pragma 保存或者更新
- (BOOL)saveOrUpdate
{
    id primaryValue = [self valueForKey:primaryId];
    if ([primaryValue intValue] <= 0) {
        return [self save];
    }
    
    return [self update];
}

#pragma mark - 删除单个数据
- (BOOL)deleteObject{
    YQDBHelper *helper = [YQDBHelper shareInstance];
    __block BOOL res = NO;
    [helper.dbQueue inDatabase:^(FMDatabase *db) {
        
        NSString *tableName = NSStringFromClass(self.class);
        id primaryValue = [self valueForKey:primaryId];
        if (!primaryValue || primaryValue<=0) {
            return ;
        }
        NSString *sql = [NSString stringWithFormat:@"DELETE FROM %@ WHERE %@ = ?",tableName,primaryId];
        res = [db executeUpdate:sql withArgumentsInArray:@[primaryValue]];
        
    }];
    NSLog(res?@"删除成功":@"删除失败");
    return res;
}

#pragma mark - 更新单个数据
- (BOOL)update{

    YQDBHelper *helper = [YQDBHelper shareInstance];
    __block BOOL res = NO;
    [helper.dbQueue inDatabase:^(FMDatabase *db) {
        NSString *tableName = NSStringFromClass(self.class);
        id primaryValue = [self valueForKey:primaryId];
        if (!primaryValue || primaryValue<=0) {
            return ;
        }
        NSMutableString *keyString = [NSMutableString string];
        NSMutableArray *updateValues = [NSMutableArray array];
        for (int i = 0; i<self.columeNames.count; i++) {
            NSString *proName = [self.columeNames objectAtIndex:i];
            if ([proName isEqualToString:primaryId]) {
                continue;
            }
            [keyString appendFormat:@" %@=?,",proName];
            id value = [self valueForKey:proName];
            if (!value) {
                value = @"";
            }
            [updateValues addObject:value];
        }
//        删除最后一次遗留的“,”
        [keyString deleteCharactersInRange:NSMakeRange(keyString.length - 1, 1)];
        NSString *sql = [NSString stringWithFormat:@"UPDATE %@ SET %@ WHERE %@ =?",tableName,keyString,primaryId];
        [updateValues addObject:primaryValue];
        res = [db executeUpdate:sql withArgumentsInArray:updateValues];
        NSLog(res?@"更新成功":@"更新失败");
    }];
    return res;
}

#pragma mark - 查询所有数据
+ (NSArray *)findAll{

    YQDBHelper *helper = [YQDBHelper shareInstance];
    NSMutableArray *results = [NSMutableArray array];
    [helper.dbQueue inDatabase:^(FMDatabase *db) {
        NSString *tableName = NSStringFromClass(self.class);
        NSString *sql = [NSString stringWithFormat:@"SELECT * FROM %@",tableName];
        FMResultSet *resultSet = [db executeQuery:sql];
        while ([resultSet next]) {
            
            DBModel *model = [[self.class alloc]init];
            for (int i = 0; i <model.columeNames.count; i++) {
                NSString *columeName = [model.columeNames objectAtIndex:i];
                NSString *columeType = [model.columeTypes objectAtIndex:i];
                if ([columeType isEqualToString:SQLTEXT]) {
                    [model setValue:[resultSet stringForColumn:columeName] forKey:columeName];
                    
                }else{
                
                    [model setValue:[NSNumber numberWithLongLong:[resultSet longLongIntForColumn:columeName]] forKey:columeName];
                }
            }
            [results addObject:model];
            FMDBRelease(model);
        }
    }];
    
    return results;
}

#pragma mark - 保存单个数据
- (BOOL)save{

    NSString *tableName = NSStringFromClass(self.class);
    NSMutableString *keyString = [NSMutableString string];
    NSMutableString *valueString = [NSMutableString string];
    NSMutableArray *insertValues = [NSMutableArray array];
    
    for (int i =0;i<self.columeNames.count ; i++) {
        NSString *proName = [self.columeNames objectAtIndex:i];
        if ([proName isEqualToString:primaryId]) {
            continue;
        }
        [keyString appendFormat:@"%@,",proName];
        [valueString appendFormat:@"?,"];
        id value = [self valueForKey:proName];
        if (!value) {
            value = @"";
        }
        [insertValues addObject:value];
    }
//    分别去掉键跟值字符串最后边的","
    [keyString deleteCharactersInRange:NSMakeRange(keyString.length -1, 1)];
    [valueString deleteCharactersInRange:NSMakeRange(valueString.length -1, 1)];
    
    YQDBHelper *helper = [YQDBHelper shareInstance];
    __block BOOL res = NO;
    [helper.dbQueue inDatabase:^(FMDatabase *db) {
        NSString *sql = [NSString stringWithFormat:@"INSERT INTO %@(%@) VALUES (%@)",tableName,keyString,valueString];
        res = [db executeUpdate:sql withArgumentsInArray:insertValues];
        
        NSLog(res?@"插入成功":@"插入失败");
    }];
    return res;
}


#pragma mark - 数据库中是否存在表
+ (BOOL)isExistInTable{
    __block BOOL res = NO;
    YQDBHelper *jkDB = [YQDBHelper shareInstance];
    [jkDB.dbQueue inDatabase:^(FMDatabase *db) {
        NSString *tableName = NSStringFromClass(self.class);
        res = [db tableExists:tableName];
    }];
    return res;
}

- (NSString *)description
{
    NSString *result = @"";
    NSDictionary *dict = [self.class getAllProperties];
    NSMutableArray *proNames = [dict objectForKey:@"name"];
    for (int i = 0; i < proNames.count; i++) {
        NSString *proName = [proNames objectAtIndex:i];
            id  proValue = [self valueForKey:proName];
            result = [result stringByAppendingFormat:@"\n%@:%@",proName,proValue];
    }
    return result;
}
@end
