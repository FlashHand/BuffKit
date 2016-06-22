//
// Created by BoWang on 16/5/20.
// Copyright (c) 2016 BoWang. All rights reserved.
//

#import "CellBuff.h"
#import <objc/runtime.h>
#import "FrameBuff.h"
CGFloat _BF_GET_WIDTH(){
    CGFloat w =[FrameBuff screenWidth];
    CGFloat h =[FrameBuff screenHeight];
    w=w>h?h:w;
    return w;
}
static void *annotation = (void *) @"annotation";
static void *annotationBG = (void *) @"annotationBG";
static void *cellBuff = (void *) @"cellBuff";
static void *annotationView = (void *) @"annotationView";
static CGFloat topY=0;
@implementation UITableViewCell(CellBuff)
#pragma mark gesture delegate
- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer {
    return [gestureRecognizer isKindOfClass:[UILongPressGestureRecognizer class]] || [gestureRecognizer locationInView:self].x >= 50;
}

- (BOOL)                         gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer
shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer {
    return NO;
}

#pragma mark - 列表标注
- (UIButton *)bfAnnotationBtn {
    return objc_getAssociatedObject(self, annotationBG);
}

- (void)setBfAnnotationBtn:(UIButton *)bfcellAnnotation {
    objc_setAssociatedObject(self, annotationBG, bfcellAnnotation, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}
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

- (UIView *)bfAnnotationView {
    return objc_getAssociatedObject(self, annotationView);
}

- (void)setBfAnnotationView:(UIView *)bfAnnotationView {
    objc_setAssociatedObject(self, annotationView, bfAnnotationView, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
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
    topY=diffPoint.y;
    //添加全屏按钮
    NSMutableArray *btnConstraints=[NSMutableArray array];
    self.bfAnnotationBtn = [[UIButton alloc] init];
    [self.bfAnnotationBtn setTranslatesAutoresizingMaskIntoConstraints:NO];
    [self.bfAnnotationBtn setBackgroundColor:[UIColor clearColor]];
    [self.bfAnnotationBtn addTarget:self
                             action:@selector(hideAnnotation)
                   forControlEvents:UIControlEventTouchUpInside];
    [([[UIApplication sharedApplication] delegate]).window addSubview:self.bfAnnotationBtn];
    UIButton *btn = self.bfAnnotationBtn;
    UIView *containerView=([[UIApplication sharedApplication] delegate]).window;
    NSDictionary *bindings = NSDictionaryOfVariableBindings(btn, containerView);
    NSLayoutFormatOptions ops = NSLayoutFormatAlignAllLeft | NSLayoutFormatAlignAllTop;
    NSArray *c1 = [NSLayoutConstraint constraintsWithVisualFormat:@"H:|-0-[btn(==containerView)]" options:ops metrics:nil views:bindings];
    NSArray *c2 = [NSLayoutConstraint constraintsWithVisualFormat:@"V:|-0-[btn(==containerView)]" options:ops metrics:nil views:bindings];
    [btnConstraints addObjectsFromArray:c1];
    [btnConstraints addObjectsFromArray:c2];
    [containerView addConstraints:btnConstraints];
    NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithString:self.bfAnnotation];
    NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
    [paragraphStyle setLineSpacing:5.0];
    CGRect labelBounds = [attributedString boundingRectWithSize:CGSizeMake(_BF_GET_WIDTH() - 30, 45) options:NSStringDrawingUsesLineFragmentOrigin context:nil];
    if (labelBounds.size.height<30){
        labelBounds.size.height=30;
    }
    if (labelBounds.size.width<30){
        labelBounds.size.width=30;
    }
    self.bfAnnotationView=[UIView new];
    [btn addSubview:self.bfAnnotationView];
    [self.bfAnnotationView setBackgroundColor:[UIColor clearColor]];
    [self.bfAnnotationView setFrame:CGRectMake(0, 0, _BF_GET_WIDTH(), labelBounds.size.height+10)];
    [self.bfAnnotationView setCenter:CGPointMake([FrameBuff screenWidth]/2.0, (diffPoint.y-self.bfAnnotationView.height/2))];
    UILabel *annotationLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0,labelBounds.size.width,labelBounds.size.height)];
    [annotationLabel setFont:self.buff.annotationFont];
    [annotationLabel setNumberOfLines:2];
    [annotationLabel setLineBreakMode:NSLineBreakByWordWrapping];
    [annotationLabel setBackgroundColor:[UIColor clearColor]];
    [annotationLabel setTextColor:self.buff.annotationTextColor];
    [annotationLabel setTextAlignment:NSTextAlignmentCenter];
    [annotationLabel setAttributedText:attributedString];
    //TODO:适应不同列表宽度
    //注释layer的位置
    CGPoint p1 = CGPointMake(0, 0);
    //箭头layer的位置
    CGPoint p2 = CGPointMake(0, 0);
    p2.x = self.bfAnnotationView.width/2;
    p2.y = labelBounds.size.height+5;
    p1.x=self.bfAnnotationView.width/2;
    p1.y= labelBounds.size.height/2;
    CAShapeLayer *annotationLayer = [CAShapeLayer layer];
    [annotationLayer setBounds:CGRectMake(0, 0, labelBounds.size.width+10, labelBounds.size.height)];
    [annotationLayer setPosition:p1];
    [annotationLayer setStrokeColor:[UIColor clearColor].CGColor];
    [annotationLayer setFillColor:self.buff.annotationBGColor.CGColor];
    [annotationLayer setOpacity:self.buff.annotationOpacity];
    [annotationLabel setCenter:p1];
    UIBezierPath *borderPath = [UIBezierPath bezierPathWithRoundedRect:CGRectMake(0, 0, labelBounds.size.width+10, labelBounds.size.height) cornerRadius:4];
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
    [self.bfAnnotationView.layer addSublayer:annotationLayer];
    [self.bfAnnotationView.layer addSublayer:arrowLayer];
    [self.bfAnnotationView addSubview:annotationLabel];
}

- (void)hideAnnotation {
    [self.bfAnnotationBtn removeFromSuperview];
}
#pragma mark Method swizzling
+(void)load{
    static dispatch_once_t cellBuffToken;
    dispatch_once(&cellBuffToken, ^{
        Class class=[UITableViewCell class];
        SEL origSel=@selector(layoutSubviews);
        SEL swizSel=@selector(bf_swizzled_layoutSubviews);
        Method origMethod=class_getInstanceMethod(class, origSel);
        Method swizMethod=class_getInstanceMethod(class, swizSel);
        BOOL didAddMethod=class_addMethod(class, origSel, method_getImplementation(swizMethod), method_getTypeEncoding(swizMethod));
        if (didAddMethod) {
            class_replaceMethod(class, swizSel, method_getImplementation(origMethod), method_getTypeEncoding(origMethod));
        }
        else{
            method_exchangeImplementations(origMethod, swizMethod);
        }
    });
}
-(void)bf_swizzled_layoutSubviews{
    [self bf_swizzled_layoutSubviews];
    [self.bfAnnotationView setCenter:CGPointMake([FrameBuff screenWidth]/2.0, (topY-self.bfAnnotationView.height/2))];
}
@end

@implementation CellBuff
- (instancetype)init {
    self = [super init];
    if (self) {
        self.annotationBGColor = [UIColor blackColor];
        self.annotationTextColor = [UIColor whiteColor];
        self.annotationFont = [UIFont systemFontOfSize:12];
        self.annotationOpacity = 0.8;
    }
    return self;
}
@end