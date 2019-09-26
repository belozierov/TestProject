//
//  TransformerRegistrator.h
//  Example
//
//  Created by Alex Belozierov on 9/26/19.
//  Copyright © 2019 Alex Belozierov. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface TransformerRegistrator : NSObject

typedef id _Nullable (^ValueTransformerHandler)(id _Nullable __strong);
+ (void)registerWithName:(NSString *)name transformer:(ValueTransformerHandler)transformer;

@end

NS_ASSUME_NONNULL_END
