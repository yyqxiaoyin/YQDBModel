//
//  ViewController.m
//  YQDBModel
//
//  Created by Mopon on 16/8/23.
//  Copyright © 2016年 Mopon. All rights reserved.
//

#import "ViewController.h"
#import "YQDBModel/YQDBHelper.h"
#import "TestModel.h"


@interface ViewController ()

@property (nonatomic ,strong)TestModel *model;

@property (nonatomic ,strong)UIImageView *imageView;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];


    
    UIImageView *imageView = [[UIImageView alloc]init];
    imageView.frame = CGRectMake(200, 200, 100, 100);
    [self.view addSubview:imageView];
    _imageView = imageView;
    
    [YQDBHelper dbPath];
    NSLog(@"%@",[YQDBHelper shareInstance].dbQueue);
    
    TestModel *model = [[TestModel alloc]init];
    
    model.name = @"张三";
    model.friends = 10;
    model.books = @15;
    model.height = 1.689;
    model.weight = 120.54;
    model.level = 5;
    model.head = [UIImage imageNamed:@"meinv"];
    
    model.myModel = [[MyModel alloc]init];
    
    _model = model;
    

}
- (IBAction)insert:(id)sender {
    
    TestModel *model = [[TestModel alloc]init];
    
    model.name = @"张三（插入）";
    model.friends = 10;
    model.books = @15;
    model.height = 1.689;
    model.weight = 120.54;
    model.level = 5;
    model.head = [UIImage imageNamed:@"meinv"];
    model.arr = @[@"1个",@"2个",@"3个"];
    model.arr1 = [NSMutableArray arrayWithObjects:@"可变1",@"可变2",@"可变3", nil];
    model.dict = @{@"1":@"一"};
    
    MyModel *myModel = [[MyModel alloc]init];
    myModel.subName = @"hahahahahah";
    model.myModel = myModel;
    model.myModel.dic = @{@"M":@"模型"};
    
    [model save];
    
    NSLog(@"%@",model);
}
- (IBAction)delete:(id)sender {
    
    TestModel *model = [[TestModel findAllObject] firstObject];
    [model deleteObject];
    
}
- (IBAction)update:(id)sender {
    _model = [[TestModel findAllObject]lastObject];
    _model.name = @"李四";
    _model.friends = 20;
    _model.books = @25;
    _model.height = 2.689;
    _model.weight = 220.54;
    _model.level = 25;
    _model.head = [UIImage imageNamed:@"meinv"];
    [_model update];
}
- (IBAction)find:(id)sender {
    
    NSArray *arr =  [TestModel findAllObject];
    NSLog(@"%@",arr);
    TestModel *model = [arr lastObject];

    [self logModel:model];
    
}

-(void)logModel:(TestModel *)model{

    NSLog(@"%@ class = %@",model.name,[model.name class]);
    
    NSLog(@"%d",model.friends);
    
    NSLog(@"%@ class = %@",model.books,[model.books class]);
    
    NSLog(@"%f",model.height);
    
    NSLog(@"%f",model.weight);
    
    NSLog(@"%lu",model.level);
    
    NSLog(@"%@ class = %@",model.head,[model.head class]);
    
    NSArray *arr = model.arr;
    
    NSMutableArray *arr1 = model.arr1;
    
    NSLog(@"%@  %@",arr,[model.arr class]);
    
    NSLog(@"可变:%@  %@",arr1,[model.arr1 class]);
    
    NSDictionary *dic = model.dict;
    NSLog(@"%@  %@",dic,[model.dict class]);
    
    NSLog(@"%@ %@",model.myModel.subName,[model.myModel class]);
    NSLog(@"%@ %@",model.myModel.dic,[model.myModel class]);
    
    self.imageView.image = model.head;
}


@end
