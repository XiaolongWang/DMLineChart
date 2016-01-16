//
//  DMLine.m
//  DMLineChart
//
//  Created by Daming on 16/1/7.
//  Copyright © 2016年 wxl. All rights reserved.
//

#import "DMLine.h"

#import <libkern/OSAtomic.h>

@implementation DMLineFaceModel
-(instancetype) initWithLineColor:(UIColor *)lineColor lineWidth:(NSInteger)lineWidth
{
    if (self = [super init]) {
        self.lineColor = lineColor;
        self.lineWidth = lineWidth;
    }
    return self;
}

+(instancetype)faceModelWithLineColor:(UIColor *)lineColor lineWidth:(NSInteger)lineWidth
{
    DMLineFaceModel *model = [[DMLineFaceModel alloc]initWithLineColor:lineColor lineWidth:lineWidth];
    return model;
}

@end

@interface DMLine()
{
    CGPoint ori_scroll;
    CGPoint pan_start;
    CGPoint pan_moved;
}

@property (nonatomic,strong)NSMutableArray <CAShapeLayer*> *lineLayers;
@property (nonatomic,strong)CAScrollLayer *containLayer;

@end

#define isRespondsToNumberOfPointInSection ([self.dataSource respondsToSelector:@selector(lineView:numberOfPointInSection:)])
#define isRespondsToValueForPointAtIndex ([self.dataSource respondsToSelector:@selector(lineView:valueForPointAtIndex:)])
#define isRespondsToNumberOfSection ([self.dataSource respondsToSelector:@selector(numberOfSection)])
#define isRespondsToLineFaceInSection ([self.dataSource respondsToSelector:@selector(lineView:lineFaceInSection:)])

@implementation DMLine

-(instancetype)initWithFrame:(CGRect)frame{
    if (self = [super initWithFrame:frame]) {
        ori_scroll = CGPointMake(0, 0);
        UIPanGestureRecognizer *pan = [[UIPanGestureRecognizer alloc]initWithTarget:self action:@selector(panAction:)];
        pan.delaysTouchesBegan = NO;
        [self addGestureRecognizer:pan];
    }
    return self;
}

-(void)panAction:(UIPanGestureRecognizer*)pan
{
    switch (pan.state) {
        case UIGestureRecognizerStateBegan:
            [self panBegan:pan];
            break;
        case UIGestureRecognizerStateChanged:
            [self panChanged:pan];
            break;
        case UIGestureRecognizerStateEnded:
            [self panEnded:pan];
            break;
            
        default:
            break;
    }
}

-(void)panBegan:(UIPanGestureRecognizer*)pan
{
    pan_moved = pan_start = [pan locationInView:self];
}

-(void)panChanged:(UIPanGestureRecognizer*)pan
{
    [CATransaction setDisableActions:YES];
    CGPoint current = [pan locationInView:self];
    CGPoint arr = CGPointMake(current.x - pan_moved.x, current.y-pan_moved.y);
    pan_moved = current;
    ori_scroll.x -= arr.x;
    //ori_scroll.y -= arr.y;
    if (ori_scroll.x>0) {
        [_containLayer scrollToPoint:ori_scroll];
    }
}

-(void)panEnded:(UIPanGestureRecognizer*)pan
{

}

-(void)prepareLineLayers
{
    NSInteger numberOfSection = 0;
    if (isRespondsToNumberOfSection) {
        numberOfSection = [_dataSource numberOfSection];
    }
    else return;
    
    NSInteger max_numberOfPointInSection = 0;
    NSInteger numberOfPointInSection[numberOfSection];
    if (isRespondsToNumberOfPointInSection) {
        for (int i = 0; i<numberOfSection ; i++) {
            numberOfPointInSection[i] = [_dataSource lineView:self numberOfPointInSection:i];
            max_numberOfPointInSection = (numberOfPointInSection[i]>max_numberOfPointInSection)?numberOfPointInSection[i]:max_numberOfPointInSection;
        }
    }
    else return;
    
    CGRect containRect = CGRectMake(0, 0, self.lineSep*max_numberOfPointInSection, self.bounds.size.height);
    
    //这里先创建一个滑动Layer
    if (!_containLayer) {
        _containLayer = [CAScrollLayer layer];
    }
    _containLayer.frame = self.bounds;
    _containLayer.backgroundColor = [UIColor clearColor].CGColor;
    _containLayer.contentsRect = containRect;
    [self.layer addSublayer:_containLayer];
    
    BOOL lineFaceIsRespond = isRespondsToLineFaceInSection;
    
    //这里有两种情况，一种是lineLayers还未初始化过，需要初始化一遍；还有一种情况是lineLayers中已经存在layer了，这时候不需要清理在重新初始化，处于性能的考虑，重新配置Layer显然是更好的选择。
    
    if (!_lineLayers) {
        _lineLayers = [@[] mutableCopy];
        
        for (int i = 0; i<numberOfSection; i++) {
            CAShapeLayer *lineLayer = [CAShapeLayer layer];
            
            //默认情况
            DMLineFaceModel *fm = [DMLineFaceModel faceModelWithLineColor:[UIColor blueColor] lineWidth:3];
            //用户配置
            if (lineFaceIsRespond) {
                fm = [_dataSource lineView:self lineFaceInSection:i];
            }
            
            CGRect layerRect = CGRectMake(0, 0, numberOfPointInSection[i], self.bounds.size.height);
            
            lineLayer.strokeColor = fm.lineColor.CGColor;
            lineLayer.lineWidth = fm.lineWidth;
            lineLayer.fillColor = [UIColor clearColor].CGColor;
            lineLayer.frame = layerRect;
            [_containLayer addSublayer:lineLayer];
            [_lineLayers addObject:lineLayer];
        }
    }else{
        for (int i = 0; i<numberOfSection; i++) {
            DMLineFaceModel *fm = [DMLineFaceModel faceModelWithLineColor:[UIColor blueColor] lineWidth:3];
            //用户配置
            if (lineFaceIsRespond) {
                fm = [_dataSource lineView:self lineFaceInSection:i];
            }
            CAShapeLayer *lineLayer;
            if (i<_lineLayers.count) {
                lineLayer = _lineLayers[i];
            }else{
                lineLayer = [CAShapeLayer layer];
                [_lineLayers addObject:lineLayer];
            }
            
            CGRect layerRect = CGRectMake(0, 0, numberOfPointInSection[i], self.bounds.size.height);
            
            lineLayer.strokeColor = fm.lineColor.CGColor;
            lineLayer.lineWidth = fm.lineWidth;
            lineLayer.fillColor = [UIColor clearColor].CGColor;
            lineLayer.frame = layerRect;
            [_containLayer addSublayer:lineLayer];
        }
    }
}

-(void)updateWithAnmationType:(DMLineAnimationType)type
{
    static BOOL isReloading;
    
    if (isReloading) {
        return;
    }
    isReloading = YES;
    
    [self prepareLineLayers];
    
    NSInteger numberOfSection = 0;
    if (isRespondsToNumberOfSection) {
        numberOfSection = [_dataSource numberOfSection];
    }
    
    if (numberOfSection > 0) {
        for (int i = 0 ; i<numberOfSection; i++) {
            [self drawLineWithAnimationType:type inSection:i];
        }
    }
    isReloading = NO;
}

-(void)drawLineWithAnimationType:(DMLineAnimationType)type inSection:(NSInteger)section
{
    _lineLayers[section].path = [self getLinePathOfSection:section].CGPath;
    [self startAnimationWithType:type inSection:section];
}

-(UIBezierPath *)getLinePathOfSection:(NSInteger)section
{
    UIBezierPath *path = [UIBezierPath bezierPath];
    
    NSInteger numOfPoint = 0;
    if (isRespondsToNumberOfPointInSection) {
        numOfPoint = [_dataSource lineView:self numberOfPointInSection:section];
    }
    
    if (isRespondsToValueForPointAtIndex) {
        if (numOfPoint>=1) {
            NSNumber *pointValue = [_dataSource lineView:self valueForPointAtIndex:[NSIndexPath indexPathForItem:0 inSection:section]];
            CGPoint point = CGPointMake(0, [pointValue integerValue]);
            [path moveToPoint:point];
        }else{
            return nil;
        }
    }
    
    for (int i = 1 ; i<numOfPoint; i++) {
        NSNumber *pointValue = [_dataSource lineView:self valueForPointAtIndex:[NSIndexPath indexPathForItem:i inSection:section]];
        CGPoint point = CGPointMake(i*self.lineSep, [pointValue integerValue]);
        [path addLineToPoint:point];
    }
    
    return path;
}

-(void)startAnimationWithType:(DMLineAnimationType)type inSection:(NSInteger)section
{
    if (type == DMLineAnimationTypeStrokeEnd) {
        [_lineLayers[section] addAnimation:[self strokeEndAnimation] forKey:@"StrokeAnimation"];
    }
    else if(type == DMLineAnimationTypePath)
    {
        [_lineLayers[section] addAnimation:[self pathAnimationInSection:section] forKey:@"PathAnimation"];
    }else if (type == DMLineAnimationTypeNone){
        //[_lineLayers[section] setNeedsDisplay];
    }
}

-(CABasicAnimation *)pathAnimationInSection:(NSInteger)section
{
    CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"path"];
    //这里的fromValue直接从呈现树中获取path
    animation.fromValue = (__bridge id _Nullable)([_lineLayers[section].presentationLayer path]);
    animation.toValue = (__bridge id _Nullable)([_lineLayers[section].modelLayer path]);
    animation.duration = 0.3;
    animation.delegate = self;
    animation.fillMode = kCAFillModeBoth;
    return animation;
}

-(CABasicAnimation *)strokeEndAnimation
{
    CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"strokeEnd"];
    animation.fromValue = @(0);
    animation.toValue = @(1);
    animation.duration = 3;
    animation.delegate = self;
    animation.fillMode = kCAFillModeBoth;
    return animation;
}

-(void)animationDidStop:(CAAnimation *)anim finished:(BOOL)flag
{
    if ([[anim valueForKey:@"keyPath"] isEqualToString:@"strokeEnd"]) {
        //_lineLayer.strokeEnd = [((CABasicAnimation *)anim).toValue integerValue];
    }else if([[anim valueForKey:@"keyPath"] isEqualToString:@"path"]) {
        //_lineLayer.strokeEnd = [((CABasicAnimation *)anim).toValue integerValue];
    }
}

-(CGFloat)lineSep
{
    if (_lineSep< 1) {
        _lineSep = 1;
    }
    return _lineSep;
}

@end
