//
//  ZBReourceLoaderManager.m
//  ZBPlayer
//
//  Created by Mzhangzb on 23/01/2018.
//  Copyright © 2018 zhangzhengbin. All rights reserved.
//

#import "ZBReourceLoaderManager.h"

@implementation ZBReourceLoaderManager

// 开始播放器需要资源管理者加载的 资源请求
-(BOOL)resourceLoader:(AVAssetResourceLoader *)resourceLoader shouldWaitForLoadingOfRequestedResource:(AVAssetResourceLoadingRequest *)loadingRequest{
    NSLog(@"loadingRequest %@",loadingRequest);
    //1 判断本地有没有该文件的缓存 return
    
    //2 判断当前有没有在下载 如果没有就下载 return
    
    //3 当前有在下载 判断获取资源区间&是否需要重新下载，如果是的话就直接重新下载return
    
    //4 处理所有请求，并且在下载的过程中 不断的处理请求
    
    
    //填充响应信息头
    loadingRequest.contentInformationRequest.contentLength = 4093201;
    loadingRequest.contentInformationRequest.contentType = @"public.mp3";
    //允许数据一部分一分部分的响应
    loadingRequest.contentInformationRequest.byteRangeAccessSupported = YES;
    
    // 响应数据给外界 NSDataReadingMappedIfSafe 模式只是把地址给到映射到内存
    NSData *data = [NSData dataWithContentsOfFile:@"/Users/hengxinyongli/Desktop/235319.mp3" options:NSDataReadingMappedIfSafe error:nil];
    long long requestOffset = loadingRequest.dataRequest.requestedOffset;
    NSInteger requestLength = loadingRequest.dataRequest.requestedLength;
    NSData * subData = [data subdataWithRange:NSMakeRange(requestOffset, requestLength)];
    [loadingRequest.dataRequest respondWithData:subData];
    // 完成本次请求（所有数据给完了 才能调用完成方法）
    [loadingRequest finishLoading];
    
    return YES;
}

-(void)resourceLoader:(AVAssetResourceLoader *)resourceLoader didCancelLoadingRequest:(AVAssetResourceLoadingRequest *)loadingRequest{
    NSLog(@"取消某个请求");
    
    
}

//处理所有的请求
- (void)handleAllRequest{
    
    
    
    
    
    
}
@end
