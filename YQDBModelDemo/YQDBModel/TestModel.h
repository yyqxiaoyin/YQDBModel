//
//  TestModel.h
//  YQDBModel
//
//  Created by Mopon on 16/8/23.
//  Copyright © 2016年 Mopon. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "YQDBModel.h"


@interface TestModel : YQDBModel

@property (nonatomic ,strong)NSString *name;

@property (nonatomic, assign) int friends;

@property (nonatomic ,strong)NSNumber *books;

@property (nonatomic, assign) float height;

@property (nonatomic, assign) double weight;

@property (nonatomic, assign) NSInteger level;

@property (nonatomic ,strong) UIImage *head;

@end
