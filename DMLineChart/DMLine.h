//
//  DMLine.h
//  DMLineChart
//
//  Created by Daming on 16/1/7.
//  Copyright © 2016年 wxl. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DMLineFaceModel : NSObject

@property (nonatomic,strong) UIColor *lineColor;
@property (nonatomic,assign) CGFloat lineWidth;

-(instancetype) initWithLineColor:(UIColor *)lineColor lineWidth:(NSInteger)lineWidth;
+(instancetype) faceModelWithLineColor:(UIColor *)lineColor lineWidth:(NSInteger)lineWidth;

@end

@class DMLine;
@protocol DMLineDataSource <NSObject>

@required

- (NSInteger)numberOfSection;

- (NSInteger)lineView:(DMLine *)lineView numberOfPointInSection:(NSInteger)section;

- (NSNumber*)lineView:(DMLine *)lineView valueForPointAtIndex:(NSIndexPath *)index;

- (DMLineFaceModel *)lineView:(DMLine *)lineView lineFaceInSection:(NSInteger)section;

@end

typedef NS_ENUM(NSUInteger, DMLineAnimationType) {
    DMLineAnimationTypeNone,
    DMLineAnimationTypeStrokeEnd,
    DMLineAnimationTypePath,
};

@interface DMLine : UIView

@property (nonatomic,weak) id<DMLineDataSource> dataSource;
//配置line的属性
@property (nonatomic,assign) CGFloat lineSep;


-(void)updateWithAnmationType:(DMLineAnimationType)type;

@end
