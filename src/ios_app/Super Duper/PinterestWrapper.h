//
//  PinterestWrapper.h
//  Super Duper
//
//  Created by Curtis Wingert on 1/5/15.
//  Copyright (c) 2015 LK (ad)Ventures, LLC. All rights reserved.
//

#import <Pinterest/Pinterest.h>

@interface PinterestWrapper : NSObject

@property (nonatomic, retain) Pinterest*  pinterest;

+ (PinterestWrapper *)sharedInstance;
+ (PinterestWrapper *)sharedInstance:(NSString *)clientId urlSchemeSuffix:(NSString *)urlSchemeSuffix;
- (void)pinRecipe:(NSString *)imageUrl sourceURL:(NSString *)sourceURL description:(NSString *)description;

@end




