//
//  DOPDropDownMenu.m
//  DOPDropDownMenuDemo
//
//  Created by weizhou on 9/26/14.
//  Copyright (c) 2014 fengweizhou. All rights reserved.
//

#import "DOPDropDownMenu.h"
#import <CoreText/CoreText.h>

@implementation DOPIndexPath
- (instancetype)initWithColumn:(NSInteger)column row:(NSInteger)row {
    self = [super init];
    if (self) {
        _column = column;
        _row = row;
    }
    return self;
}

+ (instancetype)indexPathWithCol:(NSInteger)col row:(NSInteger)row {
    DOPIndexPath *indexPath = [[self alloc] initWithColumn:col row:row];
    return indexPath;
}
@end

#pragma mark - menu implementation

@interface DOPDropDownMenu ()
@property (nonatomic, assign) NSInteger currentSelectedMenudIndex;
@property (nonatomic, assign) BOOL show;
@property (nonatomic, assign) NSInteger numOfMenu;
@property (nonatomic, assign) CGPoint origin;
@property (nonatomic, strong) UIView *backGroundView;
@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) UIView *bottomShadow;

//data source
@property (nonatomic, copy) NSArray *array;

@property (nonatomic, strong) NSArray *placeholders;

//layers array
@property (nonatomic, copy) NSArray *titles;
@property (nonatomic, copy) NSArray *indicators;
@property (nonatomic, copy) NSArray *bgLayers;

/**
 Is equal to customIndicatorView.frame.origin.x
 @default 8
**/
@property (nonatomic, assign) CGFloat indicatorXOffset;

@property (nonatomic, weak) UIView *originalSuperView;

@end


@implementation DOPDropDownMenu

#pragma mark - getter
- (UIColor *)indicatorColor {
    if (!_indicatorColor) {
        _indicatorColor = [UIColor blackColor];
    }
    return _indicatorColor;
}

- (UIColor *)textColor {
    if (!_textColor) {
        _textColor = [UIColor blackColor];
    }
    return _textColor;
}

- (UIColor *)separatorColor {
    if (!_separatorColor) {
        _separatorColor = [UIColor blackColor];
    }
    return _separatorColor;
}

- (UIFont *)titleFont {
    if (!_titleFont) {
        _titleFont = [UIFont systemFontOfSize:14];
    }
    return _titleFont;
}

- (NSString *)titleForRowAtIndexPath:(DOPIndexPath *)indexPath {
    return [self.dataSource menu:self titleForRowAtIndexPath:indexPath];
}

#pragma mark - setter
- (void)setDataSource:(id<DOPDropDownMenuDataSource>)dataSource {
    _dataSource = dataSource;
    
    //configure view
    if ([_dataSource respondsToSelector:@selector(numberOfColumnsInMenu:)]) {
        _numOfMenu = [_dataSource numberOfColumnsInMenu:self];
    } else {
        _numOfMenu = 1;
    }
    
    CGFloat textLayerInterval = self.frame.size.width / ( _numOfMenu * 2);
    CGFloat bgLayerInterval = self.frame.size.width / _numOfMenu;
    
    NSMutableArray *tempTitles = [[NSMutableArray alloc] initWithCapacity:_numOfMenu];
    NSMutableArray *tempIndicators = [[NSMutableArray alloc] initWithCapacity:_numOfMenu];
    NSMutableArray *tempBgLayers = [[NSMutableArray alloc] initWithCapacity:_numOfMenu];
    
    for (int i = 0; i < _numOfMenu; i++) {
        //bgLayer
        CGPoint bgLayerPosition = CGPointMake((i+0.5)*bgLayerInterval, self.frame.size.height/2);
        CALayer *bgLayer = [self createBgLayerWithColor:self.backgroundColor andPosition:bgLayerPosition];
        [self.layer addSublayer:bgLayer];
        [tempBgLayers addObject:bgLayer];
        //title
        CGPoint titlePosition = CGPointMake( (i * 2 + 1) * textLayerInterval , self.frame.size.height / 2);
        NSString *titleString = [_dataSource menu:self titleForRowAtIndexPath:[DOPIndexPath indexPathWithCol:i row:0]];
        // If the placeHolder is not nil we use it
        if ([_dataSource respondsToSelector:@selector(menu:placeHolderForColumn:)]) {
            NSString *placeHolder = [_dataSource menu:self placeHolderForColumn:i];
            if (placeHolder) {
                titleString = placeHolder;
            }
        }
        
        CATextLayer *title = [self createTextLayerWithNSString:titleString withColor:self.textColor andPosition:titlePosition];
        [self.layer addSublayer:title];
        [tempTitles addObject:title];
        
        if (self.customIndicatorView) {
            self.indicatorXOffset = self.customIndicatorView.frame.origin.x;
            CALayer *layer = [CALayer layer];
            CGRect rect = CGRectMake(titlePosition.x + (title.bounds.size.width/2)  + self.indicatorXOffset, self.customIndicatorView.frame.origin.y, self.customIndicatorView.frame.size.width, self.customIndicatorView.frame.size.height);
            [layer setContents:(id)self.customIndicatorView.image.CGImage];
            // Ici on set la size
            [layer setFrame:rect];
            // Ici on set la bonne position
            [layer setPosition:CGPointMake(titlePosition.x + title.bounds.size.width / 2 + self.indicatorXOffset, self.customIndicatorView.frame.origin.y)];

            [self.layer addSublayer:layer];
            [tempIndicators addObject:layer];
        }
        else {
#warning Faire mieux ?!
            self.indicatorXOffset = 8;
            //indicator
            CAShapeLayer *indicator = [self createIndicatorWithColor:self.indicatorColor andPosition:CGPointMake(titlePosition.x + title.bounds.size.width / 2 + self.indicatorXOffset, self.frame.size.height / 2)];
            [self.layer addSublayer:indicator];
            [tempIndicators addObject:indicator];
        }
    }
    _titles = [tempTitles copy];
    _indicators = [tempIndicators copy];
    _bgLayers = [tempBgLayers copy];
}

-(void)layoutSubviews {
    [super layoutSubviews];
   // [self confiMenuWithSelectRow:0];
   /* for (CALayer *layer in self.titles) {
        layer.frame = self.bounds;
    }*/
    /*for (CALayer *layer in self.indicators) {
        layer.frame = self.bounds;
    }*/
    for (CALayer *layer in self.bgLayers) {
        layer.frame = self.bounds;
    }
}

- (void)setShowBottomShadow:(BOOL)showBottomShadow {
    CGFloat alpha = 0;
    if (showBottomShadow) {
        alpha = 1;
    }
    [self.bottomShadow setAlpha:alpha];
    _showBottomShadow = showBottomShadow;
}

- (void)setShowBackground:(BOOL)showBackground {
    CGFloat alpha = 0;
    if (showBackground) {
        alpha = 1;
    }
    [self.backGroundView setAlpha:alpha];
    _showBackground = showBackground;
}

#pragma mark - init method
- (instancetype)initWithOrigin:(CGPoint)origin andHeight:(CGFloat)height {
    CGSize screenSize = [UIScreen mainScreen].bounds.size;
    self = [self initWithFrame:CGRectMake(origin.x, origin.y, screenSize.width, height)];
    return self;
}


- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    CGSize screenSize = [UIScreen mainScreen].bounds.size;
    if (self) {
        _origin = frame.origin;
        _currentSelectedMenudIndex = -1;
        _show = NO;
        
        //tableView init
        _tableView = [[UITableView alloc] initWithFrame:CGRectMake(frame.origin.x, frame.origin.y + frame.size.height, frame.size.width, 0) style:UITableViewStylePlain];
        _tableView.rowHeight = 38;
        _tableView.dataSource = self;
        _tableView.delegate = self;
        
        //self tapped
        UIGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(menuTapped:)];
        [self addGestureRecognizer:tapGesture];
        
        //background init and tapped
        _backGroundView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, screenSize.width, screenSize.height)];
        _backGroundView.backgroundColor = [UIColor colorWithWhite:0.0 alpha:0.0];
        _backGroundView.opaque = NO;
        UIGestureRecognizer *gesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(backgroundTapped:)];
        [_backGroundView addGestureRecognizer:gesture];
        
        //add bottom shadow
        _bottomShadow = [[UIView alloc] initWithFrame:CGRectMake(0, self.frame.size.height-0.5, screenSize.width, 0.5)];
        _bottomShadow.backgroundColor = [UIColor lightGrayColor];
        [self addSubview:_bottomShadow];
        
        _showBackground = YES;
        _showBottomShadow = YES;
    }
    return self;
}

#pragma mark - init support
- (CALayer *)createBgLayerWithColor:(UIColor *)color andPosition:(CGPoint)position {
    CALayer *layer = [CALayer layer];
    layer.position = position;
    layer.bounds = CGRectMake(0, 0, self.frame.size.width/self.numOfMenu, self.frame.size.height-1);
    layer.backgroundColor = color.CGColor;
//    NSLog(@"bglayer bounds:%@",NSStringFromCGRect(layer.bounds));
//    NSLog(@"bglayer position:%@", NSStringFromCGPoint(position));
    
    return layer;
}

- (CAShapeLayer *)createIndicatorWithColor:(UIColor *)color andPosition:(CGPoint)point {
    CAShapeLayer *layer = [CAShapeLayer new];
    
    UIBezierPath *path = [UIBezierPath new];
    [path moveToPoint:CGPointMake(0, 0)];
    [path addLineToPoint:CGPointMake(8, 0)];
    [path addLineToPoint:CGPointMake(4, 5)];
    [path closePath];
    
    layer.path = path.CGPath;
    layer.lineWidth = 1.0;
    layer.fillColor = color.CGColor;
    
    CGPathRef bound = CGPathCreateCopyByStrokingPath(layer.path, nil, layer.lineWidth, kCGLineCapButt, kCGLineJoinMiter, layer.miterLimit);
    layer.bounds = CGPathGetBoundingBox(bound);
    CGPathRelease(bound);
    
    layer.position = point;
    
    return layer;
}

- (CATextLayer *)createTextLayerWithNSString:(NSString *)string withColor:(UIColor *)color andPosition:(CGPoint)point {
    
    CGSize size = [self calculateTitleSizeWithString:string];
    
    CATextLayer *layer = [CATextLayer new];
    layer.bounds = CGRectMake(0, 0, size.width, size.height);
    layer.string = string;
    layer.font = CTFontCreateWithName((__bridge CFStringRef)self.titleFont.fontName, self.titleFont.pointSize, NULL);
    layer.fontSize = self.titleFont.pointSize;
    layer.alignmentMode = kCAAlignmentCenter;
    layer.foregroundColor = color.CGColor;
    layer.contentsScale = [[UIScreen mainScreen] scale];
    
    layer.position = point;
    
    return layer;
}

- (CGSize)calculateTitleSizeWithString:(NSString *)string
{
    NSDictionary *dic = @{NSFontAttributeName: self.titleFont};
#warning magic number
    CGSize size = [string boundingRectWithSize:CGSizeMake(280, 0) options:NSStringDrawingTruncatesLastVisibleLine | NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading attributes:dic context:nil].size;
    size.width = (size.width < (self.frame.size.width / _numOfMenu) - 25) ? size.width : self.frame.size.width / _numOfMenu - 25;
    return size;
}

#pragma mark - gesture handle
- (void)menuTapped:(UITapGestureRecognizer *)paramSender {
    CGPoint touchPoint = [paramSender locationInView:self];
    //calculate index
    NSInteger tapIndex = touchPoint.x / (self.frame.size.width / _numOfMenu);
 
    for (int i = 0; i < _numOfMenu; i++) {
        if (i != tapIndex) {
            [self animateIndicator:_indicators[i] Forward:NO complete:^{
                [self animateTitle:_titles[i] show:NO complete:^{
                    
                }];
            }];
            [(CALayer *)self.bgLayers[i] setBackgroundColor:self.backgroundColor.CGColor];
        }
    }
    
    if (tapIndex == _currentSelectedMenudIndex && _show) {
        [self animateIdicator:_indicators[_currentSelectedMenudIndex] background:_backGroundView tableView:_tableView title:_titles[_currentSelectedMenudIndex] forward:NO complecte:^{
            _currentSelectedMenudIndex = tapIndex;
            _show = NO;
        }];
        [(CALayer *)self.bgLayers[tapIndex] setBackgroundColor:self.backgroundColor.CGColor];
    } else {
        _currentSelectedMenudIndex = tapIndex;
        [_tableView reloadData];
        [self animateIdicator:_indicators[tapIndex] background:_backGroundView tableView:_tableView title:_titles[tapIndex] forward:YES complecte:^{
            _show = YES;
        }];
        [(CALayer *)self.bgLayers[tapIndex] setBackgroundColor:[UIColor colorWithWhite:0.9 alpha:1.0].CGColor];
    }
}

- (void)backgroundTapped:(UITapGestureRecognizer *)paramSender
{
    [self animateIdicator:_indicators[_currentSelectedMenudIndex] background:_backGroundView tableView:_tableView title:_titles[_currentSelectedMenudIndex] forward:NO complecte:^{
        _show = NO;
    }];
    [(CALayer *)self.bgLayers[_currentSelectedMenudIndex] setBackgroundColor:self.backgroundColor.CGColor];
}

#pragma mark - animation method
- (void)animateIndicator:(CAShapeLayer *)indicator Forward:(BOOL)forward complete:(void(^)())complete {
    [CATransaction begin];
    [CATransaction setAnimationDuration:0.25];
    [CATransaction setAnimationTimingFunction:[CAMediaTimingFunction functionWithControlPoints:0.4 :0.0 :0.2 :1.0]];
    
    CAKeyframeAnimation *anim = [CAKeyframeAnimation animationWithKeyPath:@"transform.rotation"];
    anim.values = forward ? @[ @0, @(M_PI) ] : @[ @(M_PI), @0 ];
    
    if (!anim.removedOnCompletion) {
        [indicator addAnimation:anim forKey:anim.keyPath];
    } else {
        [indicator addAnimation:anim forKey:anim.keyPath];
        [indicator setValue:anim.values.lastObject forKeyPath:anim.keyPath];
    }
    
    [CATransaction commit];
    
    complete();
}

- (void)animateBackGroundView:(UIView *)view show:(BOOL)show complete:(void(^)())complete {
    if (self.showBackground) {
        if (show) {
            self.originalSuperView = self.superview;
            UIView *targetView = [[UIApplication sharedApplication] keyWindow];
            [targetView addSubview:view];
            
            self.frame = [self.superview convertRect:self.frame toView:targetView];
            self.origin = [targetView convertPoint:self.origin fromView:self.superview];
            [targetView addSubview:self];
            [UIView animateWithDuration:0.2 animations:^{
                view.backgroundColor = [UIColor colorWithWhite:0.0 alpha:0.3];
            }];
            
        } else {
            [UIView animateWithDuration:0.2 animations:^{
                view.backgroundColor = [UIColor colorWithWhite:0.0 alpha:0.0];
            } completion:^(BOOL finished) {
                
                self.frame = [self.superview convertRect:self.frame toView:self.originalSuperView];
                [self.originalSuperView addSubview:self];
                
                self.originalSuperView = nil;
                
                [view removeFromSuperview];
                
            }];
        }
    }
    
    complete();
}

- (void)animateTableView:(UITableView *)tableView show:(BOOL)show complete:(void(^)())complete {
    
    UIView *targetView = [[UIApplication sharedApplication] keyWindow];
    CGFloat yStart = self.frame.origin.y + self.frame.size.height;
    CGFloat yFinal = self.frame.origin.y + self.frame.size.height;
    CGFloat tableViewRowHeight = tableView.rowHeight;
    if (tableViewRowHeight == UITableViewAutomaticDimension) {
        tableViewRowHeight = tableView.estimatedRowHeight;
    }
    
    CGFloat tableViewHeight = ([tableView numberOfRowsInSection:0] > 5) ? (5 * tableViewRowHeight) : ([tableView numberOfRowsInSection:0] * tableViewRowHeight);
    if (self.menuDirection != DOPDirectionDown) {
        yStart = self.frame.origin.y;
        yFinal = self.frame.origin.y-tableViewHeight;
    }
    
  //  CGPoint origin = [targetView convertPoint:self.origin fromView:self.superview];
    if (show) {
        tableView.frame = CGRectMake(self.frame.origin.x, yStart, self.frame.size.width, 0);
       // tableView.frame = [targetView convertRect:tableView.frame fromView:self.originalSuperView];
        [targetView addSubview:tableView];
        
        [UIView animateWithDuration:0.2 animations:^{
            _tableView.frame = /*[self.originalSuperView convertRect:*/CGRectMake(self.frame.origin.x, yFinal, self.frame.size.width, tableViewHeight)/* toView:targetView]*/;
        }];
    } else {
        [UIView animateWithDuration:0.2 animations:^{
            _tableView.frame = /*[self.originalSuperView convertRect:*/CGRectMake(self.frame.origin.x, yStart, self.frame.size.width, 0)/* toView:targetView]*/;
        } completion:^(BOOL finished) {
            [tableView removeFromSuperview];
        }];
    }
    complete();
}

#warning rename to resizeTitle ?
- (void)animateTitle:(CATextLayer *)title show:(BOOL)show complete:(void(^)())complete {
    CGSize size = [self calculateTitleSizeWithString:title.string];

    title.bounds = CGRectMake(0, 0, size.width, size.height);
    if (complete) {
        complete();
    }

}

- (void)animateIdicator:(CAShapeLayer *)indicator background:(UIView *)background tableView:(UITableView *)tableView title:(CATextLayer *)title forward:(BOOL)forward complecte:(void(^)())complete{
    
    [self animateIndicator:indicator Forward:forward complete:^{
        [self animateTitle:title show:forward complete:^{
            [self animateBackGroundView:background show:forward complete:^{
                [self animateTableView:tableView show:forward complete:^{
                }];
            }];
        }];
    }];
    
    complete();
}

#pragma mark - table datasource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    NSAssert(self.dataSource != nil, @"menu's dataSource shouldn't be nil");
    if ([self.dataSource respondsToSelector:@selector(menu:numberOfRowsInColumn:)]) {
        return [self.dataSource menu:self
                numberOfRowsInColumn:self.currentSelectedMenudIndex];
    } else {
        NSAssert(0 == 1, @"required method of dataSource protocol should be implemented");
        return 0;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = nil;
    if ([self.dataSource respondsToSelector:@selector(menu:cellForRowAtIndexPath:)]) {
        cell = [self.dataSource menu:self cellForRowAtIndexPath:[DOPIndexPath indexPathWithCol:self.currentSelectedMenudIndex row:indexPath.row]];
    }
    
    if (!cell) {
        static NSString *identifier = @"DropDownMenuCell";
        cell = [tableView dequeueReusableCellWithIdentifier:identifier];
        if (!cell) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
        }
        NSAssert(self.dataSource != nil, @"menu's datasource shouldn't be nil");
        if ([self.dataSource respondsToSelector:@selector(menu:titleForRowAtIndexPath:)]) {
            cell.textLabel.text = [self.dataSource menu:self titleForRowAtIndexPath:[DOPIndexPath indexPathWithCol:self.currentSelectedMenudIndex row:indexPath.row]];
        } else {
            NSAssert(0 == 1, @"dataSource method needs to be implemented");
        }
        cell.backgroundColor = [UIColor whiteColor];
        cell.textLabel.font = [UIFont systemFontOfSize:14.0];
        cell.separatorInset = UIEdgeInsetsZero;
        
        if ([cell.textLabel.text isEqualToString: [(CATextLayer *)[_titles objectAtIndex:_currentSelectedMenudIndex] string]]) {
            cell.backgroundColor = [UIColor colorWithWhite:0.9 alpha:1.0];
        }
    }
    return cell;
}

-(void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    [cell setBackgroundColor:cell.contentView.backgroundColor];
}

#pragma mark - tableview delegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [self confiMenuWithSelectRow:indexPath.row];
    if (self.delegate || [self.delegate respondsToSelector:@selector(menu:didSelectRowAtIndexPath:)]) {
        [self.delegate menu:self didSelectRowAtIndexPath:[DOPIndexPath indexPathWithCol:self.currentSelectedMenudIndex row:indexPath.row]];
    }
}

- (void)confiMenuWithSelectRow:(NSInteger)row {
    CATextLayer *title = (CATextLayer *)_titles[_currentSelectedMenudIndex];
    title.string = [self.dataSource menu:self titleForRowAtIndexPath:[DOPIndexPath indexPathWithCol:self.currentSelectedMenudIndex row:row]];
    
    [self animateIdicator:_indicators[_currentSelectedMenudIndex] background:_backGroundView tableView:_tableView title:_titles[_currentSelectedMenudIndex] forward:NO complecte:^{
        _show = NO;
    }];
    [(CALayer *)self.bgLayers[_currentSelectedMenudIndex] setBackgroundColor:self.backgroundColor.CGColor];
    
    CAShapeLayer *indicator = (CAShapeLayer *)_indicators[_currentSelectedMenudIndex];
    indicator.position = CGPointMake(title.position.x + (title.frame.size.width/2)  +  self.indicatorXOffset, indicator.position.y);
}

- (void)dismiss {
    [self backgroundTapped:nil];
}




@end
