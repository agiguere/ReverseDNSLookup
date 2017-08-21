//
//  ReverseDNSLookup.m
//  ReverseDNSLookup
//
//  Created by Alexandre Giguere on 2017-08-21.
//  Copyright © 2017 Alexandre Giguere. All rights reserved.
//

#import "ReverseDNSLookup.h"
#include <arpa/inet.h>
#include <sys/socket.h>
#include <objc/runtime.h>

@implementation ReverseDNSLookup

- (nonnull instancetype)initWithAdress:(nonnull NSString*)address {
    self = [super init];
    
    if (self) {
        _address = address;
    }
    
    return self;
}

- (void)resolveWithCompletionHandler:(void (^_Nonnull)(NSString * _Nullable name))completionHandler {
    
    //: Let's set up the `sockaddr_in` C structure using the initializer.
    struct sockaddr_in sin;
    
    memset(&sin, 0, sizeof(sin));
    
    sin.sin_len = sizeof(sin);
    sin.sin_family = AF_INET;
    sin.sin_port = htons(0);
    sin.sin_addr.s_addr = inet_addr([self.address UTF8String]); //INADDR_ANY;
    //memset(&sin.sin_zero, 0, sizeof(sin.sin_zero)); // to validate
    
    //: Now convert the structure into a `CFData` object.
    CFDataRef address = CFDataCreate(kCFAllocatorDefault, (UInt8 *)&sin, sizeof(struct sockaddr_in));
    
    //: Create the `CFHostRef` with the `CFData` object and store the retained value for later use.
    CFHostRef host = CFHostCreateWithAddress(kCFAllocatorDefault, address);
    
    void (^hostCallBack)(CFHostRef, CFHostInfoType, const CFStreamError *, void *) = ^(CFHostRef theHost, CFHostInfoType typeInfo, const CFStreamError *error, void *info) {
        NSString *name;
        
        Boolean resolved;
        
        CFArrayRef cfNames = CFHostGetNames(theHost, &resolved);
        
        NSMutableArray *hostnames = [NSMutableArray array];
        
        for (int currentIndex = 0; currentIndex < [(__bridge NSArray *)cfNames count]; currentIndex++) {
            [hostnames addObject:[(__bridge NSArray *)cfNames objectAtIndex:currentIndex]];
        }
        
        if (hostnames.count == 1) {
            NSString *hostName = hostnames.firstObject;
            name = hostName;
        }
        
        //: After the info resolution clean up either way.
        CFHostSetClient(theHost, NULL, NULL);
        CFHostCancelInfoResolution(theHost, kCFHostNames);
        CFHostUnscheduleFromRunLoop(theHost, CFRunLoopGetCurrent(), kCFRunLoopDefaultMode);
        
        completionHandler(name);
    };
    
    CFHostClientContext    ctx = {
        .version         = 0,
        .info             = (__bridge void*)self,
        .retain             = nil, //CFRetain
        .release         = nil, //CFRelease
        .copyDescription = nil, //CFCopyDescription,
    };
    
    IMP hostclientCallback_objectiveC_pointer = imp_implementationWithBlock(hostCallBack);
    
    CFHostSetClient(host, hostclientCallback_objectiveC_pointer, &ctx);
    
    CFHostScheduleWithRunLoop(host, CFRunLoopGetCurrent(), kCFRunLoopCommonModes); //kCFRunLoopDefaultMode
    
    CFStreamError error;
    
    Boolean started = CFHostStartInfoResolution(host, kCFHostNames, &error);
    
    NSLog(@"started: %d", started);
}

@end
