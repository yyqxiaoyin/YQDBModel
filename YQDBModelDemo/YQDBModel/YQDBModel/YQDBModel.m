//
//  YQDBModel.m
//  YQDBModel
//
//  Created by Mopon on 16/8/23.
//  Copyright © 2016年 Mopon. All rights reserved.
//

#import "YQDBModel.h"
#import "YQDBHelper.h"
#import <objc/runtime.h>
#import <UIKit/UIKit.h>

@implementation YQDBModel

+(void)initialize{

    if (self != [YQDBModel self]) {
        
        [self createTable];
    }
}

-(instancetype)init{

    self = [super init];
    if (self) {
     
        NSDictionary *dict = [self.class getAllProperties];
        _columeNames = [NSMutableArray arrayWithArray:[dict objectForKey:@"name"]];
        _columeTypes = [NSMutableArray arrayWithArray:[dict objectForKey:@"type"]];
    }
    return self;
}

-(void)encodeWithCoder:(NSCoder *)aCoder{

    [_columeNames enumerateObjectsUsingBlock:^(NSString*  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        
        [aCoder encodeObject:[self valueForKey:obj] forKey:obj];
        
    }];
}

-(instancetype)initWithCoder:(NSCoder *)aDecoder{

    if (self = [super init]) {
        NSDictionary *dict = [self.class getAllProperties];
        NSMutableArray *columeNames = [NSMutableArray arrayWithArray:[dict objectForKey:@"name"]];
        NSMutableArray *columeTypes = [NSMutableArray arrayWithArray:[dict objectForKey:@"type"]];
        
        for (int i= 0; i<columeNames.count; i++) {
            
            NSString *columeName = columeNames[i];
            NSString *type = columeTypes[i];
            
            if ([type isEqualToString:SQLTEXT] ||[type isEqualToString:SQLBLOB]) {
                
                [self setValue:[aDecoder decodeObjectForKey:columeName] forKey:columeName];
            }
        }
    }
    return self;
}

#pragma mark - 创建表
+(BOOL)createTable{
    
    YQDBHelper *helper = [YQDBHelper shareInstance];
    
    __block BOOL res = YES;
    [helper.dbQueue inTransaction:^(FMDatabase *db, BOOL *rollback) {
        
        NSString *tableName = NSStringFromClass([self class]);
        NSString *culumeAndType = [[self class] getColumeAndTypeSQLString];
        NSString *sql = [NSString stringWithFormat:@"CREATE TABLE IF NOT EXISTS %@(%@)",tableName,culumeAndType];
        if (![db executeUpdate:sql]) {
            res = NO;
            return ;
        }
        res = [self.class addNewColumn:db tableName:tableName];
    }];
    
    return res;
}

#pragma mark - 数据库中是否已经存在表
+(BOOL)isExistInTable{

    __block BOOL res = NO;
    
    YQDBHelper *helper = [YQDBHelper shareInstance];
    [helper.dbQueue inTransaction:^(FMDatabase *db, BOOL *rollback) {
       
        NSString *tableName = NSStringFromClass([self class]);
        
        res = [db tableExists:tableName];
    }];
    
    return res;
}

#pragma mark - 往表中添加新添加的字段
+(BOOL)addNewColumn:(FMDatabase *)db tableName:(NSString *)tableName{

    NSMutableArray *columns = [NSMutableArray array];
    FMResultSet *resultSet = [db getTableSchema:tableName];
    while ([resultSet next]) {
        //遍历取出数据库表中所有字段名
        NSString *column = [resultSet stringForColumn:@"name"];
        [columns addObject:column];
    }
    
    NSDictionary *dict = [self.class getAllProperties];//取出所有属性名跟属性类型的字典
    NSArray *properties = [dict objectForKey:@"name"];//取出所有属性名
    
    //谓词查找数据库中没有的字段
    NSPredicate *filterPredicate = [NSPredicate predicateWithFormat:@"NOT (SELF IN %@)",columns];
    
    //过滤出数据库表中没有的字段数组
    NSArray* resultArray = [properties filteredArrayUsingPredicate:filterPredicate];
    
    for (NSString *column in resultArray) {
        
        //取出属性在所有属性数组中的下标
        NSUInteger index = [properties indexOfObject:column];
        
        //根据下标查找对应的属性类型
        NSString *proType = [[dict objectForKey:@"type"] objectAtIndex:index];
        
        //组装sql语句新添加字段
        NSString *fieldSql = [NSString stringWithFormat:@"%@ %@",column,proType];
        
        NSString *sql = [NSString stringWithFormat:@"ALTER TABLE %@ ADD COLUMN %@",NSStringFromClass([self class]),fieldSql];
        
        if (![db executeUpdate:sql]) {
            
            return NO;
        }
    }
    return YES;
}

#pragma mark - 获取所有属性字典（不包括主键）
+(NSDictionary *)getProperties{

    NSMutableArray *proNames = @[].mutableCopy;
    NSMutableArray *proTypes = @[].mutableCopy;
    unsigned int count = 0;
    
    Ivar *ivarList = class_copyIvarList([self class], &count);
    
    for (int i = 0; i<count; i++) {
        
        Ivar ivar = ivarList[i];
        //获取属性名
        NSString *propertyName = [[NSString stringWithUTF8String:ivar_getName(ivar)] substringFromIndex:1];
        //把属性名添加到属性名数组
        [proNames addObject:propertyName];
        
        //获取属性类型
        NSString *propertyType = [NSString stringWithUTF8String:ivar_getTypeEncoding(ivar)];
        
        
        if ([propertyType containsString:@"NS"] || [propertyType containsString:@"UI"]) {
            
            //裁剪字符串中包含的转义字符
            NSRange range = [propertyType rangeOfString:@"\""];
            propertyType = [propertyType substringFromIndex:range.location +range.length];
            range = [propertyType rangeOfString:@"\""];
            propertyType = [propertyType substringToIndex:range.location];
            
            //判断属性类型
            if ([propertyType isEqualToString:@"NSString"]) {
                
                [proTypes addObject:SQLTEXT];//文本类型
                
            }
            else {
                
                [proTypes addObject:SQLBLOB];//二进制类型
            }
        }
        else if ([propertyType isEqualToString:@"i"] || [propertyType isEqualToString:@"q"]){
            [proTypes addObject:SQLINTEGER];//整形
        }else if ([propertyType isEqualToString:@"f"] || [propertyType isEqualToString:@"d"]){
            [proTypes addObject:SQLREAL];//浮点类型
        }else{
            
            [proTypes addObject:SQLBLOB];//二进制类型
        }
    }
    
    free(ivarList);
    return [NSDictionary dictionaryWithObjectsAndKeys:proNames,@"name",proTypes,@"type",nil];
}

#pragma mark - 获取所有属性（包括主键）
+(NSDictionary *)getAllProperties{

    NSDictionary *dict = [self getProperties];
    NSMutableArray *proNames = @[].mutableCopy;
    NSMutableArray *proTypes = @[].mutableCopy;
    
    [proNames addObject:primaryId];//添加上主键的名字
    [proTypes addObject:[NSString stringWithFormat:@"%@ %@",SQLINTEGER,PrimaryKey]];//添加主键的类型。自增长
    [proNames addObjectsFromArray:[dict objectForKey:@"name"]];//添加子类的属性名
    [proTypes addObjectsFromArray:[dict objectForKey:@"type"]];//添加子类的属性类型
    
    return [NSDictionary dictionaryWithObjectsAndKeys:proNames,@"name",proTypes,@"type",nil];
}

#pragma mark - 获取由属性名跟类型组装的sql用来创建表
+(NSString *)getColumeAndTypeSQLString{

    NSMutableString *pars = [NSMutableString string];
    NSDictionary *dict = [[self class] getAllProperties];
    
    NSMutableArray *names = [dict objectForKey:@"name"];
    NSMutableArray *types = [dict objectForKey:@"type"];
    
    for (int i =0; i<names.count; i++) {
        
        [pars appendFormat:@"%@ %@",[names objectAtIndex:i],[types objectAtIndex:i]];
        if (i != names.count -1) {
            [pars appendString:@","];

        }
    }
    
    return pars;
}

#pragma mark - 保存单个数据
-(BOOL)save{
    
    NSString *tableName = NSStringFromClass([self class]);
    NSMutableString *keyString = [NSMutableString string];
    NSMutableString *valueString = [NSMutableString string];
    NSMutableArray *insertValues = [NSMutableArray array];
    
    for (int i = 0; i<self.columeNames.count; i++) {
        
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
        NSString *columnType = [self.columeTypes objectAtIndex:i];
        if ([columnType isEqualToString:SQLBLOB]) {//二进制类型
            NSData *data = [NSKeyedArchiver archivedDataWithRootObject:value];
            value = data;
        }
        
        [insertValues addObject:value];
    }
    
    // 去掉键跟值字符串最后边的","
    [keyString deleteCharactersInRange:NSMakeRange(keyString.length -1, 1)];
    [valueString deleteCharactersInRange:NSMakeRange(valueString.length -1, 1)];
    
    YQDBHelper *helper = [YQDBHelper shareInstance];
    __block BOOL res = NO;
    NSString *sql = [NSString stringWithFormat:@"INSERT INTO %@ (%@) VALUES(%@)",tableName,keyString,valueString];
    [helper.dbQueue inTransaction:^(FMDatabase *db, BOOL *rollback) {
       
        res =  [db executeUpdate:sql withArgumentsInArray:insertValues];
        
        NSLog(res?@"插入成功":@"插入失败");
        
    }];
    
    return res;
}

#pragma mark - 保存或者更新单个数据
-(BOOL)saveOrUpdate{

    id primaryValue = [self valueForKey:primaryId];
    if ([primaryValue intValue] <=0 ) {
        
        return [self save];
    }
    return [self update];
}

#pragma mark - 更新单个数据
-(BOOL)update{

    YQDBHelper *helper = [YQDBHelper shareInstance];
    __block BOOL res = NO;
    [helper.dbQueue inTransaction:^(FMDatabase *db, BOOL *rollback) {
       
        NSString *tableName = NSStringFromClass([self class]);
        id primaryValue = [self valueForKey:primaryId];
        if (!primaryValue || primaryValue <=0) {
            
            return ;
        }
        NSMutableString *keyString = [NSMutableString string];
        NSMutableArray *updatValues = [NSMutableArray array];
        
        for (int i = 0; i<self.columeNames.count; i++) {
        
            NSString *proName = [self.columeNames objectAtIndex:i];
            if ([proName isEqualToString:primaryId]) {
                continue;
            }
            
            [keyString appendFormat:@" %@ = ?,",proName];
            id value = [self valueForKey:proName];
            if (!value) {
                value = @"";
            }
            [updatValues addObject:value];
        }
        
            //删除keystring最后一个单引号'
            [keyString deleteCharactersInRange:NSMakeRange(keyString.length - 1, 1)];
            
            NSString *sql = [NSString stringWithFormat:@"UPDATE %@ SET %@ WHERE %@ = ?",tableName,keyString,primaryId];
            [updatValues addObject:primaryValue];
            
            res = [db executeUpdate:sql withArgumentsInArray:updatValues];
            NSLog(res?@"更新成功":@"更新失败");
    }];
 
    return res;
}

#pragma mark - 删除单个数据
-(BOOL)deleteObject{

    YQDBHelper *helper = [YQDBHelper shareInstance];
    __block BOOL res = NO;
    [helper.dbQueue inTransaction:^(FMDatabase *db, BOOL *rollback) {
        NSString *tableName = NSStringFromClass([self class]);
        id primaryValue = [self valueForKey:primaryId];
        if (!primaryValue || primaryValue <= 0) {
            return ;
        }
        NSString *sql = [NSString stringWithFormat:@"DELETE FROM %@ WHERE %@ = ?",tableName,primaryId];
        
        res = [db executeUpdate:sql withArgumentsInArray:@[primaryValue]];
    }];
    
    NSLog(res?@"删除成功":@"删除失败");
    return res;
}


#pragma mark - 查询所有数据
+(NSArray *)findAllObject{

    YQDBHelper *helper = [YQDBHelper shareInstance];
    NSMutableArray *results = [NSMutableArray array];
    [helper.dbQueue inTransaction:^(FMDatabase *db, BOOL *rollback) {
       
        NSString *tableName = NSStringFromClass([self class]);
        NSString *sql = [NSString stringWithFormat:@"SELECT * FROM %@",tableName];
        FMResultSet *resultSet = [db executeQuery:sql];
        while ([resultSet next]) {
            YQDBModel *model = [[[self class] alloc]init];
            for (int i =0 ; i<model.columeNames.count; i++) {
                
                NSString *columnName = [model.columeNames objectAtIndex:i];
                NSString *columnType = [model.columeTypes objectAtIndex:i];
        
                if ([columnType isEqualToString:SQLTEXT]) {
                    
                    [model setValue:[resultSet stringForColumn:columnName] forKey:columnName];
                    
                }else if ([columnType isEqualToString:SQLBLOB]) {
                    
                    NSData *data = [resultSet dataForColumn:columnName];
                    
                    id value = [NSKeyedUnarchiver unarchiveObjectWithData:data];
                    
                    [model setValue:value forKey:columnName];
                    
                }else{
                
                    [model setValue:@([resultSet longLongIntForColumn:columnName]) forKey:columnName];
                }
            }
            [results addObject:model];
            FMDBRelease(model);
        }
    }];
    
    return results;
}

-(NSString *)description{


    NSMutableString *str = [NSMutableString stringWithFormat:@"\n%@:\n",NSStringFromClass([self class])];
    
    for (int i =0; i<_columeNames.count; i++) {
        
        [str appendFormat:@"\n%@ = %@",_columeNames[i],[self valueForKey:_columeNames[i]]];
    }
    
    return str;
    
}

@end
