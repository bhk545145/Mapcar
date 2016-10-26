//
//  MapViewController.m
//  Mapcar
//
//  Created by 白洪坤 on 16/8/26.
//  Copyright © 2016年 白洪坤. All rights reserved.
//

#import "MapViewController.h"
#import <MAMapKit/MAMapKit.h>
#import <AMapSearchKit/AMapSearchKit.h>
#import "AFNetworking.h"
#import "BikeModel.h"

#define BikeURL @"http://c.ggzxc.com.cn/wz/np_getBikes.do"

@interface MapViewController ()<MAMapViewDelegate,NSURLConnectionDataDelegate>
@property (nonatomic, strong) MAMapView *mapView;
@property (nonatomic, strong) NSMutableArray *bikeModelarray;
@property (nonatomic, assign) CLLocationDegrees latitude;
@property (nonatomic, assign) CLLocationDegrees longitude;
@property (nonatomic, assign) BOOL isZero;
@end

@implementation MapViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationItem.title = @"自行车";
    ///初始化地图
    _mapView = [[MAMapView alloc] initWithFrame:self.view.bounds];
    //开启定位
    _mapView.showsUserLocation = YES;
    //地图跟着位置移动
    [_mapView setUserTrackingMode: MAUserTrackingModeFollow animated:YES];
    [_mapView setZoomLevel:16.1 animated:YES];
    _mapView.delegate = self;
    ///把地图添加至view
    [self.view addSubview:_mapView];
    _bikeModelarray = [[NSMutableArray alloc]init];
    


}

- (void)BikePointAnnotation:(BikeModel *)bikeModel{
    
    MAPointAnnotation *pointAnnotation = [[MAPointAnnotation alloc] init];
    pointAnnotation.coordinate = CLLocationCoordinate2DMake(bikeModel.lat - 0.006000, bikeModel.lon - 0.006500);
    pointAnnotation.title = bikeModel.name;
    pointAnnotation.subtitle = [NSString stringWithFormat:@"可租%ld，可还%ld",(long)bikeModel.rentcount,(long)bikeModel.restorecount];
    [_mapView addAnnotation:pointAnnotation];
    [_bikeModelarray addObject:bikeModel];
    
}

- (void)BikeRemovePointAnnotation:(BikeModel *)bikeModel{
    MAPointAnnotation *pointAnnotation = [[MAPointAnnotation alloc] init];
    pointAnnotation.coordinate = CLLocationCoordinate2DMake(bikeModel.lat - 0.006000, bikeModel.lon - 0.006500);
    [_mapView removeAnnotation:pointAnnotation];
    //[_bikeModelarray removeObject:bikeModel];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];    
}

- (MAAnnotationView *)mapView:(MAMapView *)mapView viewForAnnotation:(id <MAAnnotation>)annotation
{
    if ([annotation isKindOfClass:[MAPointAnnotation class]])
    {
        static NSString *pointReuseIndentifier = @"pointReuseIndentifier";
        MAAnnotationView *annotationView = (MAAnnotationView*)[mapView dequeueReusableAnnotationViewWithIdentifier:pointReuseIndentifier];
        if (annotationView == nil)
        {
            annotationView = [[MAAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:pointReuseIndentifier];
        }
        NSInteger Bikecount = [[annotation.subtitle substringFromIndex:annotation.subtitle.length - 1] intValue];
        BOOL isPureInt = [self isPureInt:[annotation.subtitle substringFromIndex:annotation.subtitle.length - 2]];
        if (isPureInt) {
            annotationView.image = [UIImage imageNamed:@"58.png"];
        }else{
            if (Bikecount == 0) {
                annotationView.image = [UIImage imageNamed:@"29.png"];
            }else{
                annotationView.image = [UIImage imageNamed:@"58.png"];
            }
        }
        
        
        
        annotationView.canShowCallout = YES;
        //设置中心点偏移，使得标注底部中间点成为经纬度对应点
        annotationView.centerOffset = CGPointMake(0, -18);
        return annotationView;
    }
    return nil;
}

//当位置更新时，会进定位回调，通过回调函数，能获取到定位点的经纬度坐标
-(void)mapView:(MAMapView *)mapView didUpdateUserLocation:(MAUserLocation *)userLocation
updatingLocation:(BOOL)updatingLocation
{
    if(updatingLocation)
    {
        //取出当前位置的坐标
        //NSLog(@"latitude : %f,longitude: %f",userLocation.coordinate.latitude,userLocation.coordinate.longitude);
        _latitude = userLocation.coordinate.latitude + 0.006000;
        _longitude = userLocation.coordinate.longitude + 0.006500;
        
        NSString *bikeUrl = [NSString stringWithFormat:@"%@?lat=%f&lng=%f",BikeURL,_latitude,_longitude];
        NSURL *url=[NSURL URLWithString:bikeUrl];
        NSURLRequest *request = [NSURLRequest requestWithURL:url];
        NSOperationQueue *queue=[NSOperationQueue mainQueue];
        [NSURLConnection sendAsynchronousRequest:request queue:queue completionHandler:^(NSURLResponse * _Nullable response, NSData * _Nullable data, NSError * _Nullable connectionError) {
            if (!connectionError) {
                NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:nil];
                BikeModel *bikeModel;
                NSInteger countI = [dic[@"count"] integerValue];
                for (int i = 0;i < countI; i++) {
                    bikeModel = [BikeModel DeviceinfoWithDict:dic[@"data"][i]];
                    for (BikeModel *bikeModelold in _bikeModelarray) {
                        if (bikeModel.number == bikeModelold.number) {
                            if (bikeModel.restorecount == bikeModelold.restorecount) {
                                return;
                            }else{
                                //移除坐标
                                NSLog(@"旧：%@ 可租%ld，可还%ld",bikeModelold.name,bikeModelold.rentcount,bikeModelold.restorecount);
                                NSLog(@"新：%@ 可租%ld，可还%ld",bikeModel.name,bikeModel.rentcount,bikeModel.restorecount);
                                [self BikeRemovePointAnnotation:bikeModelold];
                            }
                        }
                    }
                    [self BikePointAnnotation:bikeModel];
                }
            }
        }];

    }
}

- (void)mapView:(MAMapView *)mapView didAddAnnotationViews:(NSArray *)views
{
    MAAnnotationView *view = views[0];
    
    // 放到该方法中用以保证userlocation的annotationView已经添加到地图上了。
    if ([view.annotation isKindOfClass:[MAUserLocation class]])
    {
        MAUserLocationRepresentation *pre = [[MAUserLocationRepresentation alloc] init];
        pre.fillColor = [UIColor colorWithRed:0.9 green:0.1 blue:0.1 alpha:0.3];
        pre.strokeColor = [UIColor colorWithRed:0.1 green:0.1 blue:0.9 alpha:1.0];
        pre.image = [UIImage imageNamed:@"location.png"];
        pre.lineWidth = 3;
        pre.lineDashPattern = @[@6, @3];
        
        [self.mapView updateUserLocationRepresentation:pre];
        
        view.calloutOffset = CGPointMake(0, 0);
    } 
}

- (BOOL)isPureInt:(NSString *)string{
    
    NSScanner* scan = [NSScanner scannerWithString:string];
    
    int val;
    
    return [scan scanInt:&val] && [scan isAtEnd];
    
}
@end
