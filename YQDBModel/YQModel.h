//
//  YQModel.h
//  RunTimeDemo
//
//  Created by Mopon on 16/5/19.
//  Copyright © 2016年 Mopon. All rights reserved.
//

#import "YQDBModel.h"

@interface YQModel : DBModel

@property (nonatomic ,strong)NSString *name;

@property (nonatomic ,assign)NSInteger age;

@property (nonatomic ,strong)NSString *type;

@property (nonatomic ,strong)NSString *testClumn;

@end
