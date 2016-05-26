//
// Created by BoWang on 16/5/20.
// Copyright (c) 2016 BoWang. All rights reserved.
//

#import "CellBuff.h"
#import <objc/runtime.h>

static void *annotation = (void *) @"annotation";
static void *annotationBG = (void *) @"annotationBG";
static void *cellBuff = (void *) @"cellBuff";

@implementation UITableViewCell (CellBuff)
#pragma mark gesture delegate

- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer {
    return [gestureRecognizer isKindOfClass:[UILongPressGestureRecognizer class]] || [gestureRecognizer locationInView:self].x >= 50;
}

- (BOOL)                         gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer
shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer {
    return NO;
}

#pragma mark - 列表标注

- (NSString *)bfAnnotation {
    return objc_getAssociatedObject(self, annotation);
}

- (void)setBfAnnotation:(NSString *)annotationStr {
    objc_setAssociatedObject(self, annotation, annotationStr, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    if (annotationStr.length > 0) {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            BOOL isLongPressExited = NO;
            for (UIGestureRecognizer *gest in self.gestureRecognizers) {
                if ([gest isKindOfClass:[UILongPressGestureRecognizer class]]) {
                    isLongPressExited = YES;
                }
            }
            if (!isLongPressExited) {
                UILongPressGestureRecognizer *annotationPress = [[UILongPressGestureRecognizer alloc]
                        initWithTarget:self action:@selector(showAnnotation:)];
                [self addGestureRecognizer:annotationPress];
                [annotationPress setDelegate:self];
            }

            dispatch_async(dispatch_get_main_queue(),
                    ^{
                        [self setUserInteractionEnabled:YES];
                    }
            );
        });

    }
}


- (UIButton *)bfAnnotationBtn {
    return objc_getAssociatedObject(self, annotationBG);
}

- (void)setBfAnnotationBtn:(UIButton *)bfcellAnnotation {
    objc_setAssociatedObject(self, annotationBG, bfcellAnnotation, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (CellBuff *)buff {
    return objc_getAssociatedObject(self, cellBuff);
}

- (void)setBuff:(CellBuff *)aBuff {
    objc_setAssociatedObject(self, cellBuff, aBuff, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (void)bf_setAnnotation:(NSString *)annotation {
    [self setBfAnnotation:annotation];
    CellBuff *aBuff = [[CellBuff alloc] init];
    self.buff = aBuff;
}

- (void)showAnnotation:(UILongPressGestureRecognizer *)gesture {
    CGFloat screenWidth = [[UIScreen mainScreen] bounds].size.width;
    CGPoint touchPoint1 = [gesture locationInView:([[UIApplication sharedApplication] delegate]).window];
    CGPoint touchPoint2 = [gesture locationInView:self];
    CGPoint diffPoint = CGPointMake(touchPoint1.x - touchPoint2.x, touchPoint1.y - touchPoint2.y);
    switch (gesture.state) {
        case UIGestureRecognizerStateBegan:
            [self showannotationBtnWithTouch:diffPoint];
            break;
        default:
            break;
    }
}

- (void)showannotationBtnWithTouch:(CGPoint)diffPoint {
    CGFloat screenWidth = [[UIScreen mainScreen] bounds].size.width;
    //添加全屏按钮
    self.bfAnnotationBtn = [[UIButton alloc] initWithFrame:CGRectMake(0, 0,
            [[UIScreen mainScreen] bounds].size.width,
            [[UIScreen mainScreen] bounds].size.height)];
    [self.bfAnnotationBtn setBackgroundColor:[UIColor clearColor]];
    [self.bfAnnotationBtn addTarget:self
                             action:@selector(hideAnnotation)
                   forControlEvents:UIControlEventTouchUpInside];
    [([[UIApplication sharedApplication] delegate]).window addSubview:self.bfAnnotationBtn];

    NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithString:self.bfAnnotation];
    NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
    //默认行间距为5.0
    [paragraphStyle setLineSpacing:5.0];
    //文字最大宽度不超过screenWidth-20,annotationMaxWidth的最大值为屏幕宽度,
    CGRect annotationBounds = [attributedString boundingRectWithSize:CGSizeMake(self.buff.annotationMaxWidth - 20, 45)
                                                             options:NSStringDrawingUsesLineFragmentOrigin
                                                             context:nil];
    //文字背景layer高度不低于20
    if (annotationBounds.size.height<30){
        annotationBounds.size.height=30;
    }
    //w是背景layer的宽度,不超过screenWidth-10
    CGFloat w = annotationBounds.size.width + 10;
    CGFloat h = annotationBounds.size.height;
    UILabel *annotationLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0,
            annotationBounds.size.width,
            annotationBounds.size.height)];
    [annotationLabel setFont:self.buff.annotationFont];
    [annotationLabel setNumberOfLines:2];
    [annotationLabel setLineBreakMode:NSLineBreakByWordWrapping];
    [annotationLabel setBackgroundColor:[UIColor clearColor]];
    [annotationLabel setTextColor:self.buff.annotationTextColor];
    [annotationLabel setTextAlignment:NSTextAlignmentCenter];
    [annotationLabel setAttributedText:attributedString];
    //TODO:适应不同列表宽度

    CGFloat annotationDiff;
    //注释layer的位置
    CGPoint p1 = CGPointMake(0, 0);
    //箭头layer的位置
    CGPoint p2 = CGPointMake(0, 0);

    p2.x = (CGFloat) (diffPoint.x + self.bounds.size.width / 2.0);
    p2.y = diffPoint.y - 5;
    p1.x=160;
    p1.y= (CGFloat) (diffPoint.y-10-annotationBounds.size.height/2.0);

    CAShapeLayer *annotationLayer = [CAShapeLayer layer];
    [annotationLayer setBounds:annotationBounds];
    [annotationLayer setPosition:p1];
    [annotationLayer setStrokeColor:[UIColor clearColor].CGColor];
    [annotationLayer setFillColor:self.buff.annotationBGColor.CGColor];
    [annotationLayer setOpacity:self.buff.annotationOpacity];
    [annotationLabel setCenter:p1];
    UIBezierPath *borderPath = [UIBezierPath bezierPathWithRoundedRect:annotationBounds
                                                          cornerRadius:4];
    [annotationLayer setPath:borderPath.CGPath];


    CAShapeLayer *arrowLayer = [CAShapeLayer layer];
    [arrowLayer setBounds:CGRectMake(0, 0, 10, 10)];
    [arrowLayer setPosition:p2];
    [arrowLayer setStrokeColor:[UIColor clearColor].CGColor];
    [arrowLayer setFillColor:self.buff.annotationBGColor.CGColor];
    [arrowLayer setOpacity:self.buff.annotationOpacity];
    UIBezierPath *arrowPath = [UIBezierPath bezierPath];
    [arrowPath moveToPoint:CGPointMake(0, 0)];
    [arrowPath addLineToPoint:CGPointMake(5, 10)];
    [arrowPath addLineToPoint:CGPointMake(10, 0)];
    [arrowLayer setPath:arrowPath.CGPath];

    [self.bfAnnotationBtn.layer addSublayer:annotationLayer];
    [self.bfAnnotationBtn.layer addSublayer:arrowLayer];
    [self.bfAnnotationBtn addSubview:annotationLabel];
}

- (void)hideAnnotation {
    [self.bfAnnotationBtn removeFromSuperview];
}
@end

@implementation CellBuff
- (instancetype)init {
    self = [super init];
    if (self) {
        self.annotationMaxWidth = [[UIScreen mainScreen] bounds].size.width;
        self.annotationBGColor = [UIColor blackColor];
        self.annotationTextColor = [UIColor whiteColor];
        self.annotationFont = [UIFont systemFontOfSize:12];
        self.annotationOpacity = 0.8;
    }
    return self;
}

- (void)setAnnotationmaxWidth:(CGFloat)annotationMaxWidth {
    CGFloat screenWidth = [[UIScreen mainScreen] bounds].size.width;
    if (annotationMaxWidth > screenWidth) {
        annotationMaxWidth = screenWidth;
    }
    _annotationMaxWidth = annotationMaxWidth;
}

@end