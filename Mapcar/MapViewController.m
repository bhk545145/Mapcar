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
    for (BikeModel *bikeModelold in _bikeModelarray) {
        if (bikeModel.bikeid == bikeModelold.bikeid) {
            if (bikeModel.restorecount == bikeModelold.restorecount) {
                return;
            }else{
                //移除坐标
            }
            
        }
    }
    MAPointAnnotation *pointAnnotation = [[MAPointAnnotation alloc] init];
    pointAnnotation.coordinate = CLLocationCoordinate2DMake(bikeModel.lat - 0.006000, bikeModel.lon - 0.006300);
    pointAnnotation.title = bikeModel.name;
    pointAnnotation.subtitle = [NSString stringWithFormat:@"可租%ld，可还%ld",(long)bikeModel.rentcount,(long)bikeModel.restorecount];
    
    [_mapView addAnnotation:pointAnnotation];
    [_bikeModelarray addObject:bikeModel];
    
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
        MAPinAnnotationView*annotationView = (MAPinAnnotationView*)[mapView dequeueReusableAnnotationViewWithIdentifier:pointReuseIndentifier];
        if (annotationView == nil)
        {
            annotationView = [[MAPinAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:pointReuseIndentifier];
        }
        annotationView.canShowCallout= YES;       //设置气泡可以弹出，默认为NO
        annotationView.animatesDrop = YES;        //设置标注动画显示，默认为NO
        annotationView.draggable = NO;        //设置标注可以拖动，默认为NO
        annotationView.pinColor = MAPinAnnotationColorPurple;
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
        NSLog(@"latitude : %f,longitude: %f",userLocation.coordinate.latitude,userLocation.coordinate.longitude);
        _latitude = userLocation.coordinate.latitude;
        _longitude = userLocation.coordinate.longitude;
        
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
@end
