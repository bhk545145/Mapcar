//
//  BikeModel.m
//  Mapcar
//
//  Created by 白洪坤 on 16/8/26.
//  Copyright © 2016年 白洪坤. All rights reserved.
//

#import "BikeModel.h"

@implementation BikeModel
- (id)initWithDict:(NSDictionary *)dict{
    if (self = [super init]) {
        _address = dict[@"address"];
        _areaname = dict[@"areaname"];
        _name = dict[@"name"];
        _bikenum = [dict[@"bikenum"] integerValue];
        _lat = [dict[@"lat"] floatValue];
        _lon = [dict[@"lon"] floatValue];
        _rentcount = [dict[@"rentcount"] integerValue];
        _restorecount = [dict[@"restorecount"] integerValue];
        
    }
    return self;
    
}

+ (id)DeviceinfoWithDict:(NSDictionary *)dict{
    return [[self alloc] initWithDict:dict];
}
@end
