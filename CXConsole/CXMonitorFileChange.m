//
//  CXMonitorConsole.m
//  CXConsole
//
//  Created by zainguo on 2019/10/17.
//  Copyright © 2019 zainguo. All rights reserved.
//

#import "CXMonitorFileChange.h"

@interface CXMonitorFileChange () {
    NSURL *_fileURL;
    dispatch_source_t _source;
    int _fileDes;
}

@property (nonatomic,copy) void (^monitorFileChangeBlock)(NSInteger type);

@end

@implementation CXMonitorFileChange
- (void)dealloc {
    [self close];
}

- (void)watcherForPath:(NSString *)filePath block:(void (^)(NSInteger type))block {
    self.monitorFileChangeBlock = block;
    _fileURL = [NSURL URLWithString:filePath];
    [self pm_startMonitorFile];
    
}
- (void)pm_startMonitorFile {
    
    _fileDes = open([[_fileURL path] fileSystemRepresentation], O_EVTONLY);
    if (_fileDes < 0) {
        return;
    }
    dispatch_queue_t defaultQueue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    _source = dispatch_source_create(DISPATCH_SOURCE_TYPE_VNODE,
                                     _fileDes,
                                     DISPATCH_VNODE_ATTRIB |
                                     DISPATCH_VNODE_DELETE |
                                     DISPATCH_VNODE_EXTEND |
                                     DISPATCH_VNODE_LINK |
                                     DISPATCH_VNODE_RENAME |
                                     DISPATCH_VNODE_REVOKE |
                                     DISPATCH_VNODE_WRITE,
                                     defaultQueue);
    __weak __typeof(self)weakSelf = self;
    dispatch_source_set_event_handler(_source, ^{
        __strong CXMonitorFileChange *strongSelf = weakSelf;
        unsigned long eventTypes = dispatch_source_get_data(strongSelf->_source);
        [strongSelf alertDelegateOfEvents:eventTypes];
    });
    dispatch_resume(_source);

}
- (void)close {
    
    close(_fileDes);
    dispatch_source_cancel(_source);
    _fileDes = 0;
    _source = nil;
}
- (void)alertDelegateOfEvents:(unsigned long)eventTypes {
    dispatch_async(dispatch_get_main_queue(), ^ {
        BOOL closeDispatchSource = NO;
        NSMutableSet *eventSet = [[NSMutableSet alloc] initWithCapacity:7];
        if (eventTypes & DISPATCH_VNODE_ATTRIB) {
            [eventSet addObject:@(DISPATCH_VNODE_ATTRIB)];
        }
        if (eventTypes & DISPATCH_VNODE_DELETE) {
            [eventSet addObject:@(DISPATCH_VNODE_DELETE)];
            closeDispatchSource = YES;
        }
        if (eventTypes & DISPATCH_VNODE_EXTEND) {
            [eventSet addObject:@(DISPATCH_VNODE_EXTEND)];
        }
        if (eventTypes & DISPATCH_VNODE_LINK) {
            [eventSet addObject:@(DISPATCH_VNODE_LINK)];
        }
        if (eventTypes & DISPATCH_VNODE_RENAME){
            [eventSet addObject:@(DISPATCH_VNODE_RENAME)];
            closeDispatchSource = YES;
        }
        if (eventTypes & DISPATCH_VNODE_REVOKE) {
            [eventSet addObject:@(DISPATCH_VNODE_REVOKE)];
        }
        if (eventTypes & DISPATCH_VNODE_WRITE) {
            [eventSet addObject:@(DISPATCH_VNODE_WRITE)];
        }
      
        for (NSNumber *eventType in eventSet) {
            if (self.monitorFileChangeBlock) {
                self.monitorFileChangeBlock([eventType unsignedIntegerValue]);
            }
        }
        if (closeDispatchSource) {
            [self close];
        }
    });
}

@end
