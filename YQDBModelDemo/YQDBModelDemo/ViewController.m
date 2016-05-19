//
//  ViewController.m
//  YQDBModelDemo
//
//  Created by Mopon on 16/5/19.
//  Copyright © 2016年 Mopon. All rights reserved.
//

#import "ViewController.h"
#import "YQModel.h"

@interface ViewController ()

@property (nonatomic ,strong)YQModel *model;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.model = [[YQModel alloc]init];
    self.model.name = @"张三";
    self.model.age = 13;
    self.model.type = @"type1";
    self.model.testClumn = @"testClum1";
}

- (IBAction)save:(id)sender {
    
    [self.model save];
}
- (IBAction)update:(id)sender {
    
    YQModel *model =[[YQModel findAll]firstObject];
    model.name = @"00000";
    model.age = 0;
    model.type = @"00";
    model.testClumn = @"00";
    [model saveOrUpdate];
    
}
- (IBAction)search:(id)sender {
    
    NSArray *arr = [YQModel findAll];
    
    for (YQModel *model in arr) {
        NSLog(@"%@",model);
    }
    
}
- (IBAction)delete:(id)sender {
    
    YQModel *model = [[YQModel findAll]firstObject];
    
    [model deleteObject];
    
}
@end
