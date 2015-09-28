//
//  PinterestWrapper.m
//  Super Duper
//
//  Created by Curtis Wingert on 1/5/15.
//  Copyright (c) 2015 LK (ad)Ventures, LLC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PinterestWrapper.h"


@implementation PinterestWrapper : NSObject

+ (PinterestWrapper *)sharedInstance {
    static PinterestWrapper *sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[PinterestWrapper alloc] init];
        sharedInstance.pinterest = [[Pinterest alloc] initWithClientId:@"1442249" urlSchemeSuffix:@"pin1442249"];
    });
    
    return sharedInstance;
}

+ (PinterestWrapper *)sharedInstance:(NSString *)clientId urlSchemeSuffix:(NSString *)urlSchemeSuffix {
    static PinterestWrapper *sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[PinterestWrapper alloc] init];
        sharedInstance.pinterest = [[Pinterest alloc] initWithClientId:clientId urlSchemeSuffix:urlSchemeSuffix];
    });
    
    return sharedInstance;
}

- (void)pinRecipe:(NSString *)imageUrl sourceURL:(NSString *)sourceURL description:(NSString *)description {
    [self.pinterest createPinWithImageURL:[NSURL URLWithString:imageUrl]
                                sourceURL:[NSURL URLWithString:@"http://getsuperduper.com"]
                              description:description];
}
@end
