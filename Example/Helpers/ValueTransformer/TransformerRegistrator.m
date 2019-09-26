//
//  TransformerRegistrator.m
//  Example
//
//  Created by Alex Belozierov on 9/26/19.
//  Copyright © 2019 Alex Belozierov. All rights reserved.
//

#import "TransformerRegistrator.h"
#import "Example-Swift.h"

@implementation TransformerRegistrator

+ (void)registerWithName:(NSString *)name transformer:(ValueTransformerHandler)transformer {
    _ValueTransformer *valueTransformer = [[_ValueTransformer alloc] initWithTransformer:transformer];
    [NSValueTransformer setValueTransformer:valueTransformer forName:name];
}

@end
