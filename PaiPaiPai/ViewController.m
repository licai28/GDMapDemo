//
//  ViewController.m
//  PaiPaiPai
//
//  Created by MoneyLee on 2018/6/1.
//  Copyright © 2018年 MoneyLee. All rights reserved.
//

#import "ViewController.h"
#import <MAMapKit/MAMapKit.h>
#import <AMapFoundationKit/AMapFoundationKit.h>

@interface ViewController ()<MAMapViewDelegate>

@property (nonatomic,strong)MAMapView * mapView;
@property (nonatomic, strong) MACircle * circleView;
@property (nonatomic, strong) MAPolygon *polygon;
@property (nonatomic, strong) NSMutableArray *annotations;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    ///地图需要v4.5.0及以上版本才必须要打开此选项（v4.5.0以下版本，需要手动配置info.plist）
    [AMapServices sharedServices].enableHTTPS = YES;
    
    ///初始化地图
    _mapView = [[MAMapView alloc] initWithFrame:self.view.bounds];
    _mapView.userTrackingMode = MAUserTrackingModeFollow;
    
    ///如果您需要进入地图就显示定位小蓝点，则需要下面两行代码
    _mapView.showsUserLocation = YES;
    _mapView.showsScale = NO;
    _mapView.zoomLevel = 13;
    _mapView.showTraffic = YES;
    _mapView.showsCompass = NO;
    _mapView.delegate = self;
    //_mapView.desiredAccuracy = 100;
    ///把地图添加至view
    [self.view addSubview:_mapView];

    //自定义定位小蓝点
    //初始化 MAUserLocationRepresentation 对象
    MAUserLocationRepresentation *r = [[MAUserLocationRepresentation alloc] init];
    
    r.showsAccuracyRing = NO;///精度圈是否显示，默认YES
    r.showsHeadingIndicator = YES;///是否显示方向指示(MAUserTrackingModeFollowWithHeading模式开启)。默认为YES
//    r.fillColor = [UIColor redColor];///精度圈 填充颜色, 默认 kAccuracyCircleDefaultColor
//    r.strokeColor = [UIColor blueColor];///精度圈 边线颜色, 默认 kAccuracyCircleDefaultColor
//    r.lineWidth = 2;///精度圈 边线宽度，默认0
//    r.enablePulseAnnimation = NO;///内部蓝色圆点是否使用律动效果, 默认YES
//    r.locationDotBgColor = [UIColor greenColor];///定位点背景色，不设置默认白色
//    r.locationDotFillColor = [UIColor grayColor];///定位点蓝色圆点颜色，不设置默认蓝色
//    r.image = [UIImage imageNamed:@"endPoint"]; ///定位图标, 与蓝色原点互斥
//
    [_mapView updateUserLocationRepresentation:r];
    
    [self initAnnotations];

    //屏幕中心点标记
    UIImageView * image = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, 10, 10)];
    image.backgroundColor = [UIColor redColor];
    image.center = self.view.center;
    [self.view addSubview:image];
    
    CLLocationCoordinate2D coor = _mapView.centerCoordinate;
    
    //以当前地图中心点为圆心 绘制半径为1000米的圆
    _circleView = [MACircle circleWithCenterCoordinate:coor radius:3000];
    [self.mapView addOverlay:_circleView];
    
    
    
}




#pragma mark - Initialization
- (void)initAnnotations{
    
    //位于东经122゜25'---123゜48’，北纬41゜12’，---42゜17’，之间
    
    self.annotations = [NSMutableArray array];

    for (int i = 0; i < 1000; i ++) {

        CGFloat ls = [self randomBetween:41 AndBigNum:42 AndPrecision:1000000];
        
        CGFloat lw = [self randomBetween:123 AndBigNum:124 AndPrecision:1000000];
        
        NSLog(@"lw:%lf----ls:%lf",lw,ls);

//        NSString * nls = [NSString stringWithFormat:@"41.76%f",ls];
//        NSString * nlw = [NSString stringWithFormat:@"123.42%f",ls];

        MAPointAnnotation *a1 = [[MAPointAnnotation alloc] init];

        a1.coordinate = (CLLocationCoordinate2D){ls,lw};
        a1.title      = [NSString stringWithFormat:@"anno: %d", i];
        a1.subtitle = [NSString stringWithFormat:@"自定义点标记内容: %d",i];
        [self.annotations addObject:a1];

    }

//    CLLocationCoordinate2D coordinates[5] = {
//        {41.762321, 123.427694},
//        {41.760184, 123.430480},
//        {41.762163, 123.432707},
//        {41.751406, 123.431525},
//        {41.748655, 123.406589},
//    };
//
//    for (int i = 0; i < 5; ++i)
//    {
//        MAPointAnnotation *a1 = [[MAPointAnnotation alloc] init];
//        a1.coordinate = coordinates[i];
//        a1.title      = [NSString stringWithFormat:@"anno: %d", i];
//        a1.subtitle = [NSString stringWithFormat:@"自定义点标记内容: %d",i];
//        [self.annotations addObject:a1];
//    }
}

- (float)randomBetween:(float)smallNum AndBigNum:(float)bigNum AndPrecision:(NSInteger)precision{

    //求两数之间的差值
    float subtraction = bigNum - smallNum;
    //取绝对值
    subtraction = ABS(subtraction);
    //乘以精度的位数
    subtraction *= precision;
    //在差值间随机
    float randomNumber = arc4random() % ((int) subtraction + 1);
    //随机的结果除以精度的位数
    randomNumber /= precision;
    //将随机的值加到较小的值上
    float result = MIN(smallNum, bigNum) + randomNumber;
    //返回结果
    return result;
    
}

//自定义标记点位置发生改变
- (void)mapView:(MAMapView *)mapView annotationView:(MAAnnotationView *)view didChangeDragState:(MAAnnotationViewDragState)newState fromOldState:(MAAnnotationViewDragState)oldState {
    
    //定位点拖拽结束
//    if(newState == MAAnnotationViewDragStateEnding) {
//
//    }
}

#pragma mark - MAMapViewDelegate
//绘制区域图形的相关属性配置 可以是矩形 多边形 圆形
- (MAOverlayRenderer *)mapView:(MAMapView *)mapView rendererForOverlay:(id <MAOverlay>)overlay
{
    if ([overlay isKindOfClass:[MACircle class]])
    {
        MACircleRenderer * polygonRenderer = [[MACircleRenderer alloc]initWithCircle:overlay];
        polygonRenderer.lineWidth   = 1.f;
        // polygonRenderer.strokeColor = [UIColor yellowColor];
        polygonRenderer.fillColor = [UIColor colorWithRed:0.73 green:0.73 blue:0.73 alpha:0.2];
        return polygonRenderer;
    }
    return nil;
}



#pragma mark - Map Delegate

/*!
 @brief 根据anntation生成对应的View
 @param mapView 地图View
 @param annotation 指定的标注
 @return 生成的标注View
 */
- (MAAnnotationView*)mapView:(MAMapView *)mapView viewForAnnotation:(id <MAAnnotation>)annotation {
    
    //定位蓝点  如果不在此判断 自身的定位点样式会被其他自定义的样式修改
    if ([annotation isKindOfClass:[MAUserLocation class]]) {
        return nil;
    }

    if ([annotation isKindOfClass:[MAPointAnnotation class]]){

        static NSString *reuseIndetifier = @"annotationReuseIndetifier";
        MAAnnotationView *annotationView = (MAAnnotationView *)[mapView dequeueReusableAnnotationViewWithIdentifier:reuseIndetifier];
        if (annotationView == nil){
            annotationView = [[MAAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:reuseIndetifier];
        }
        
        annotationView.image = [UIImage imageNamed:@"qwuh"];
        annotationView.canShowCallout               = YES;
        annotationView.draggable                    = YES;
        annotationView.rightCalloutAccessoryView    = [UIButton buttonWithType:UIButtonTypeDetailDisclosure];
        //设置中心点偏移，使得标注底部中间点成为经纬度对应点
        annotationView.centerOffset = CGPointMake(0, -18);
        return annotationView;
    
    }
    
    return nil;
}

//点击屏幕获取经纬度 (手动获取模拟数据使用)
- (void)mapView:(MAMapView *)mapView didSingleTappedAtCoordinate:(CLLocationCoordinate2D)coordinate{
    NSLog(@"%f ---- %f",coordinate.latitude,coordinate.longitude);
    //41.737987 ---- 123.422523
    //41.765668 ---- 123.434932
    //41.794761 ---- 123.409902
}

/**
 * @brief 地图区域改变过程中会调用此接口 since 4.6.0
 * @param mapView 地图View
 */
- (void)mapViewRegionChanged:(MAMapView *)mapView{
    
    //移动地图 根据新的中心点坐标 改变所绘制图形的位置
    [self.circleView setCircleWithCenterCoordinate:mapView.centerCoordinate radius:3000];
    //遍历所有的自定义坐标点
    for (int i = 0; i < self.annotations.count; i ++) {
        
        MAPointAnnotation *a1 = self.annotations[i];
        CLLocationCoordinate2D loc1 = a1.coordinate;
        
//        [self.mapView addAnnotation:a1];

        if(MACircleContainsCoordinate(loc1, self.circleView.coordinate, 3000)) {
            NSLog(@"在区域内 新增自定义坐标点");
            [self.mapView addAnnotation:a1];

        } else {
            NSLog(@"不在区域内 移除自定义坐标点");
            [self.mapView removeAnnotation:a1];
        }

    }
    
}


/**
 * @brief 地图移动结束后调用此接口
 * @param mapView       地图view
 * @param wasUserAction 标识是否是用户动作
 */
- (void)mapView:(MAMapView *)mapView mapDidMoveByUser:(BOOL)wasUserAction{
    if (wasUserAction) {
        //当前地图的中心点，改变该值时，地图的比例尺级别不会发生变化
    }
}

/**
 * @brief 定位失败后，会调用此函数
 * @param mapView 地图View
 * @param error 错误号，参考CLError.h中定义的错误号
 */
- (void)mapView:(MAMapView *)mapView didFailToLocateUserWithError:(NSError *)error{
    NSLog(@"定位失败");
}

/**
 * @brief 地图初始化完成（在此之后，可以进行坐标计算）
 * @param mapView 地图View
 */
- (void)mapInitComplete:(MAMapView *)mapView{
//    NSLog(@"当前经纬度%lf--%lf",mapView.userLocation.coordinate.latitude,mapView.userLocation.coordinate.longitude);
}




/*!
 @brief 当mapView新添加annotation views时调用此接口
 @param mapView 地图View
 @param views 新添加的annotation views
 */
- (void)mapView:(MAMapView *)mapView didAddAnnotationViews:(NSArray *)views {
    
}

/*!
 @brief 当选中一个annotation views时调用此接口
 @param mapView 地图View
 @param views 选中的annotation views
 */
- (void)mapView:(MAMapView *)mapView didSelectAnnotationView:(MAAnnotationView *)view {
    
}

/*!
 @brief 当取消选中一个annotation views时调用此接口
 @param mapView 地图View
 @param views 取消选中的annotation views
 */
- (void)mapView:(MAMapView *)mapView didDeselectAnnotationView:(MAAnnotationView *)view {
    
}

/*!
 @brief 标注view的accessory view(必须继承自UIControl)被点击时调用此接口
 @param mapView 地图View
 @param annotationView callout所属的标注view
 @param control 对应的control
 */
- (void)mapView:(MAMapView *)mapView annotationView:(MAAnnotationView *)view calloutAccessoryControlTapped:(UIControl *)control {
    
}



- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
