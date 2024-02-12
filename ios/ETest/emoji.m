//
//  emoji.m
//  ETest
//
//  Created by Alec Nossa on 2/12/24.
//

#import <Foundation/Foundation.h>
#import "React/RCTBridgeModule.h"
@interface RCT_EXTERN_MODULE(EmojiModule, NSObject)
RCT_EXTERN_METHOD(getEmoji:(NSString *)text resolver:(RCTPromiseResolveBlock)resolve rejecter:(RCTPromiseRejectBlock)reject)
@end
