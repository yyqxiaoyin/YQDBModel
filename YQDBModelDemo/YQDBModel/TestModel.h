//
//  TestModel.h
//  YQDBModel
//
//  Created by Mopon on 16/8/23.
//  Copyright © 2016年 Mopon. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "YQDBModel.h"

@class MyModel;

@interface TestModel : YQDBModel

@property (nonatomic ,strong)NSString *name;

@property (nonatomic, assign) int friends;

@property (nonatomic ,strong)NSNumber *books;

@property (nonatomic, assign) float height;

@property (nonatomic, assign) double weight;

@property (nonatomic, assign) NSInteger level;

@property (nonatomic ,strong) UIImage *head;

@property (nonatomic ,strong) NSArray *arr;

@property (nonatomic ,strong)NSMutableArray *arr1;

@property (nonatomic ,strong)NSDictionary *dict;

@property (nonatomic ,strong)MyModel *myModel;

@end

@interface MyModel : YQDBModel

@property (nonatomic ,strong)NSString *subName;

@property (nonatomic ,strong)NSDictionary *dic;

@end
