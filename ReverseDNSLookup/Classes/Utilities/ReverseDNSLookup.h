//
//  ReverseDNSLookup.h
//  ReverseDNSLookup
//
//  Created by Alexandre Giguere on 2017-08-21.
//  Copyright © 2017 Alexandre Giguere. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ReverseDNSLookup : NSObject

@property NSString * _Nonnull address;

- (nonnull instancetype)initWithAdress:(nonnull NSString*)address;
- (void)resolveWithCompletionHandler:(void (^_Nonnull)(NSString * _Nullable name))completionHandler;

@end
