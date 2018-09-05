//
//  NSObject+LanguageManager.m
//  CanvasCore
//
//  Created by Layne Moseley on 5/21/18.
//  Copyright © 2018 Instructure, Inc. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CanvasCore/CanvasCore-Swift.h>
@import React;

@interface LocalizationManager (React) <RCTBridgeModule>

@end

@implementation LocalizationManager (React)

RCT_EXPORT_MODULE(LocalizationManager);

RCT_EXPORT_METHOD(setCurrentLocale:(NSString *)locale) {
    [LocalizationManager setCurrentLocale:locale];
}

- (dispatch_queue_t)methodQueue {
    return dispatch_get_main_queue();
}

@end
