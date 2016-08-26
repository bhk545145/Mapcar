//
//  BikeModel.h
//  Mapcar
//
//  Created by 白洪坤 on 16/8/26.
//  Copyright © 2016年 白洪坤. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface BikeModel : NSObject

@property (nonatomic,strong) NSString *address;
@property (nonatomic,strong) NSString *areaname;
@property (nonatomic,assign) NSInteger bikenum;
@property (nonatomic,strong) NSString *createTime;
@property (nonatomic,strong) NSString *guardType;
@property (nonatomic,assign) NSInteger bikeid;
@property (nonatomic,assign) float lat;
@property (nonatomic,assign) NSInteger len;
@property (nonatomic,assign) float lon;
@property (nonatomic,strong) NSString *name;
@property (nonatomic,assign) NSInteger number;
@property (nonatomic,assign) NSInteger rentcount;
@property (nonatomic,assign) NSInteger restorecount;
@property (nonatomic,strong) NSString *serviceType;
@property (nonatomic,assign) NSInteger sort;
@property (nonatomic,strong) NSString *stationPhone;
@property (nonatomic,strong) NSString *stationPhone2;
@property (nonatomic,strong) NSString *useflag;

- (id)initWithDict:(NSDictionary *)dict;
+ (id)DeviceinfoWithDict:(NSDictionary *)dict;
@end
