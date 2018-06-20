//
//  ZJJDragBallView.m
//  ZJJDragSynechiaMsgBall
//
//  Created by 张锦江 on 2018/6/19.
//  Copyright © 2018年 xtayqria. All rights reserved.
//
// 球的半径
#define BALL_R              11
// 回弹振动偏移量
#define VIBRATE_OFFSET      10
// 拉伸长度大于此值时，断裂
#define DRAG_MAX_LENGTH     SCREEN_WIDTH/4
// 断裂后，放在距离原位置中心点附近多少，圆球出现
#define APPEAR_CENTER_L     50

#import "ZJJDragBallView.h"
#import "Header.h"

@interface ZJJDragBallView () {
    UILabel *_circleLabel; // 展示消息个数的 label
    CAShapeLayer *_shapeLayer; // 画出拉伸轮廓的 layer
    UILabel *_tempLabel; // 拉走的 label
}

@end

@implementation ZJJDragBallView

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        _circleLabel = [self customLabelPoint:CGPointMake(self.frame.size.width/2, self.frame.size.height/2) bounds:CGRectMake(0, 0, 2*BALL_R, 2*BALL_R)];
        UIPanGestureRecognizer *pan = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(panGesture:)];
        [_circleLabel addGestureRecognizer:pan];
    }
    return self;
}

- (void)setMsgCount:(int)msgCount {
    _msgCount = msgCount;
    [self creatViewWithNumber:msgCount];
}

- (void)creatViewWithNumber:(int)number {
    if (number > 0) {
        _circleLabel.text = [NSString stringWithFormat:@"%d",number];
        [self addSubview:_circleLabel];
    }
}

- (void)panGesture:(UIPanGestureRecognizer *)gesture {
    [_shapeLayer removeFromSuperlayer];
    [_tempLabel removeFromSuperview];
    CGPoint endPoint = [gesture locationInView:self];
    float a = endPoint.y - _circleLabel.center.y;
    float b = endPoint.x - _circleLabel.center.x;
    float c = sqrt(a*a+b*b);
    if (gesture.state == UIGestureRecognizerStateChanged) {
        // 拖拽显示的 label
        _tempLabel = [self customLabelPoint:endPoint bounds:CGRectMake(0, 0, 2*BALL_R, 2*BALL_R)];
        [self addSubview:_tempLabel];
            /* 让原图变小 */
            // 球变小后的半径
        float small_ball_r = (1 - c/SCREEN_WIDTH)*BALL_R;
        _circleLabel.bounds = CGRectMake(0, 0, 2*small_ball_r, 2*small_ball_r);
        _circleLabel.layer.cornerRadius = small_ball_r;
        _circleLabel.clipsToBounds = YES;
            // 原图上边
        CGPoint origin_up_point = CGPointMake(small_ball_r*(b/(c*sqrt(2)) - a/(c*sqrt(2)))+_circleLabel.center.x, small_ball_r*(b/(c*sqrt(2)) + a/(c*sqrt(2)))+_circleLabel.center.y);
            // 原图下边
        CGPoint origin_down_point = CGPointMake(small_ball_r*(b/(c*sqrt(2)) + a/(c*sqrt(2)))+_circleLabel.center.x, _circleLabel.center.y-small_ball_r*(b/(c*sqrt(2)) - a/(c*sqrt(2))));
            // 目标上边
        CGPoint end_up_point = CGPointMake(endPoint.x - BALL_R*(b/(c*sqrt(2)) + a/(c*sqrt(2))) , endPoint.y + BALL_R*(b/(c*sqrt(2)) - a/(c*sqrt(2))));
            // 目标下边
        CGPoint end_down_point = CGPointMake(endPoint.x - BALL_R*(b/(c*sqrt(2)) - a/(c*sqrt(2))), endPoint.y - BALL_R*(b/(c*sqrt(2)) + a/(c*sqrt(2))));
            // 控制点上边
        CGPoint up_control_point = CGPointMake((end_up_point.x-origin_down_point.x)/2+origin_down_point.x, (end_up_point.y-origin_down_point.y)/2+origin_down_point.y);
            // 控制点下边
        CGPoint down_control_point = CGPointMake((end_down_point.x-origin_up_point.x)/2+origin_up_point.x, (origin_up_point.y-end_down_point.y)/2+end_down_point.y);
        // CGPath
        CGMutablePathRef ref = CGPathCreateMutable();
        CGPathMoveToPoint(ref, nil, origin_up_point.x, origin_up_point.y);
        CGPathAddLineToPoint(ref, nil, origin_down_point.x, origin_down_point.y);
        CGPathAddQuadCurveToPoint(ref, nil, down_control_point.x, down_control_point.y, end_down_point.x, end_down_point.y);
        CGPathAddLineToPoint(ref, nil, end_up_point.x, end_up_point.y);
        CGPathAddQuadCurveToPoint(ref, nil, up_control_point.x, up_control_point.y, origin_up_point.x, origin_up_point.y);
        CGPathCloseSubpath(ref);
        // 创建轨迹
        _shapeLayer = [CAShapeLayer layer];
        _shapeLayer.path = ref;
        _shapeLayer.strokeColor = [UIColor clearColor].CGColor;
        _shapeLayer.fillColor = [UIColor redColor].CGColor;
        if (!_circleLabel.hidden) {
            [self.layer addSublayer:_shapeLayer];
        }
        if (c >= DRAG_MAX_LENGTH) {
            _circleLabel.hidden = YES;
            [_shapeLayer removeFromSuperlayer];
        }
        CGPathRelease(ref);
    } else if (gesture.state == UIGestureRecognizerStateEnded) {
        _circleLabel.bounds = CGRectMake(0, 0, 2*BALL_R, 2*BALL_R);
        _circleLabel.layer.cornerRadius = BALL_R;
        _circleLabel.clipsToBounds = YES;
        if (!_circleLabel.hidden) {
            // 开始回弹动画
            [UIView animateWithDuration:0.05 animations:^{
                _circleLabel.center = CGPointMake(self.frame.size.width/2 - VIBRATE_OFFSET*b/c, self.frame.size.height/2 - VIBRATE_OFFSET*a/c);
            } completion:^(BOOL finished) {
                [UIView animateWithDuration:0.1 animations:^{
                    _circleLabel.center = CGPointMake(self.frame.size.width/2 + VIBRATE_OFFSET*b/c, self.frame.size.height/2 + VIBRATE_OFFSET*a/c);
                } completion:^(BOOL finished) {
                    [UIView animateWithDuration:0.05 animations:^{
                        _circleLabel.center = CGPointMake(self.frame.size.width/2 - VIBRATE_OFFSET*b/(2*c), self.frame.size.height/2 - VIBRATE_OFFSET*a/(2*c));
                    } completion:^(BOOL finished) {
                        [UIView animateWithDuration:0.1 animations:^{
                            _circleLabel.center = CGPointMake(self.frame.size.width/2 + VIBRATE_OFFSET*b/(2*c), self.frame.size.height/2 + VIBRATE_OFFSET*a/(2*c));
                        } completion:^(BOOL finished) {
                            _circleLabel.center = CGPointMake(self.frame.size.width/2, self.frame.size.height/2);
                        }];
                    }];
                }];
            }];
        } else if (c <= APPEAR_CENTER_L) {
            _circleLabel.hidden = NO;
        }
    }
}

- (UILabel *)customLabelPoint:(CGPoint)point bounds:(CGRect)bounds {
    UILabel *label = [[UILabel alloc] init];
    label.center = point;
    label.bounds = bounds;
    label.backgroundColor = [UIColor redColor];
    label.font = [UIFont systemFontOfSize:10.0f];
    label.textColor = [UIColor whiteColor];
    label.textAlignment = NSTextAlignmentCenter;
    label.layer.cornerRadius = bounds.size.width/2;
    label.clipsToBounds = YES;
    label.hidden = NO;
    label.userInteractionEnabled = YES;
    return label;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
