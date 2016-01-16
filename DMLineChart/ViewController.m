//
//  ViewController.m
//  DMLineChart
//
//  Created by Daming on 16/1/7.
//  Copyright © 2016年 wxl. All rights reserved.
//

#import "ViewController.h"
#import "DMLine.h"


@interface ViewController ()<DMLineDataSource>

@property (nonatomic,weak) DMLine *lineView;
@property (nonatomic,strong) NSArray *dataArray;
@property (nonatomic,strong) NSArray *dataArray2;
@property (nonatomic,strong) NSArray *dataArray3;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    [self loadLineChart];
}

-(void)loadLineChart
{
    DMLine *lineView = [[DMLine alloc]initWithFrame:self.view.bounds];
    lineView.dataSource = self;
    [self.view insertSubview:lineView atIndex:0];
    lineView.lineSep = 10;
    [lineView updateWithAnmationType:DMLineAnimationTypeStrokeEnd];
    self.lineView = lineView;
}

- (NSInteger)numberOfSection
{
    return 3;
}

- (NSInteger)lineView:(DMLine *)lineView numberOfPointInSection:(NSInteger)section
{
    if (section == 0) {
        return _dataArray.count;
    }else
    if (section == 1) {
        return _dataArray2.count;
    }else
    if (section == 2) {
        return _dataArray3.count;
    }
    return 0;
}

- (NSValue*)lineView:(DMLine *)lineView valueForPointAtIndex:(NSIndexPath *)index
{
    NSInteger row = index.item;
    
    if (index.section == 0) {
        if (row<_dataArray.count) {
            return _dataArray[row];
        }else{
            return @(0);
        }
    }else
    if (index.section == 1) {
        if (row<_dataArray2.count) {
            return _dataArray2[row];
        }else{
            return @(0);
        }
    }else
    if (index.section == 2) {
        if (row<_dataArray3.count) {
            return _dataArray3[row];
        }else{
            return @(0);
        }
    }
    return @(0);
}

- (DMLineFaceModel *)lineView:(DMLine *)lineView lineFaceInSection:(NSInteger)section
{
    if (section == 0) {
        DMLineFaceModel *faceModel = [DMLineFaceModel faceModelWithLineColor:[UIColor blueColor] lineWidth:1];
        return faceModel;
    }else
    if (section == 1) {
        DMLineFaceModel *faceModel = [DMLineFaceModel faceModelWithLineColor:[UIColor yellowColor] lineWidth:3];
        return faceModel;
    }else
    if (section == 2) {
        DMLineFaceModel *faceModel = [DMLineFaceModel faceModelWithLineColor:[UIColor orangeColor] lineWidth:2];
        return faceModel;
    }
    return nil;
}

- (IBAction)resetAction:(id)sender {
    _dataArray = [self getDemoArray];
    _dataArray2 = [self getDemoArray];
    _dataArray3 = [self getDemoArray];
    [self.lineView updateWithAnmationType:DMLineAnimationTypeStrokeEnd];
}

-(NSArray<NSValue *> *)getDemoArray
{
    NSMutableArray *dataArray = [NSMutableArray array];
    NSInteger first = arc4random()%((int)self.view.bounds.size.height);
    [dataArray addObject:@(first)];
    for (int i = 1; i < 100; i++) {
        NSInteger rd = arc4random()%2==1 ? -1 : 1;
        NSInteger plus = arc4random()%20 ;
        NSInteger value = [dataArray[i-1] integerValue]+plus*rd;
        [dataArray addObject:@(value)];
    }
    return dataArray;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
