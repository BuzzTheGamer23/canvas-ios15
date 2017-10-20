//
// Copyright (C) 2016-present Instructure, Inc.
//
// This program is free software: you can redistribute it and/or modify
// it under the terms of the GNU General Public License as published by
// the Free Software Foundation, version 3 of the License.
//
// This program is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU General Public License for more details.
//
// You should have received a copy of the GNU General Public License
// along with this program.  If not, see <http://www.gnu.org/licenses/>.
//

#import "NativeLoginManager.h"
#import <React/RCTLog.h>
#import <React/RCTBridge.h>
#import <CanvasCore/CanvasCore-Swift.h>

@import CanvasKeymaster;
@import CocoaLumberjack;

CanvasApp _Nonnull CanvasAppStudent = @"student";
CanvasApp _Nonnull CanvasAppTeacher = @"teacher";

@interface NativeLoginManager ()

@property (nonatomic) NSDictionary *injectedLoginInfo;
@property (nonatomic) RACDisposable *loginObserver;
@property (nonatomic) RACDisposable *logoutObserver;
@property (nonatomic) RACDisposable *clientObserver;
@property (nonatomic) UIViewController *domainPicker;
@property (nonatomic) CKIClient *currentClient;
@property (nonatomic) BOOL shouldCleanupOnNextLogoutEvent;

- (void)setup;

@end

// Object used to send events to React Native about login
@interface NativeLogin : RCTEventEmitter

@property (nonatomic) BOOL isObserving;
@property (nonatomic) NSMutableDictionary *pendingEvents;

@end

static NativeLogin *_sharedInstance;

@implementation NativeLogin

+ (void)setSharedInstance:(NativeLogin *)login {
    _sharedInstance = login;
}

+ (NativeLogin *)sharedInstance {
    return _sharedInstance;
}

- (instancetype)init {
    self = [super init];
    self.isObserving = NO;
    self.pendingEvents = [NSMutableDictionary new];
    [NativeLogin setSharedInstance:self];
    
    // Each time one of these gets created, we need to re-setup the observing of keymaster stuff
    // Otherwise, the right events don't get triggered
    [[NativeLoginManager shared] setup];
    return self;
}

RCT_EXPORT_MODULE();

RCT_EXPORT_METHOD(logout)
{
    [[NativeLoginManager shared] setShouldCleanupOnNextLogoutEvent:YES];
    [TheKeymaster logout];
}

RCT_EXPORT_BLOCKING_SYNCHRONOUS_METHOD(loginInformation)
{
    NSDictionary *injected = [[NativeLoginManager shared] injectedLoginInfo];
    if (injected) {
        return injected;
    }
    
    // I imagine that we can extend this to checking keymaster in a synchronous way,
    // which would improve app startup time
    return nil;
}

RCT_EXPORT_METHOD(startObserving)
{
    self.isObserving = YES;
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(.25 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self.pendingEvents enumerateKeysAndObjectsUsingBlock:^(NSString *key, id obj, BOOL * _Nonnull stop) {
            [self sendEventWithName:key body:obj];
        }];
        [self.pendingEvents removeAllObjects];
    });
}

RCT_EXPORT_METHOD(stopObserving)
{
    self.isObserving = NO;
}

- (dispatch_queue_t)methodQueue {
    return dispatch_get_main_queue();
}

- (void)sendEventWithName:(NSString *)name body:(id)body {
    if (self.isObserving) {
        [super sendEventWithName:name body:body];
    }
    else {
        self.pendingEvents[name] = body;
    }
}

- (NSArray<NSString *> *)supportedEvents {
    return @[@"Login"];
}

@end

@implementation NativeLoginManager

+ (instancetype)shared {
    static NativeLoginManager *manager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        manager = [[NativeLoginManager alloc] init];
        manager.app = CanvasAppTeacher; // default to teacher app
    });
    return manager;
}

- (instancetype)init {
    
    self = [super init];
    if (self) {
        [self setup];
    }
    return self;
}

- (void)setup {
    
    self.shouldCleanupOnNextLogoutEvent = NO;
    [self.logoutObserver dispose];
    [self.loginObserver dispose];
    [self.clientObserver dispose];
    
    __weak NativeLoginManager *weakSelf = self;
    self.logoutObserver = [TheKeymaster.signalForLogout subscribeNext:^(UIViewController * _Nullable x) {
        __strong NativeLoginManager *self = weakSelf;
        self.domainPicker = x;
        if (self.injectedLoginInfo) { return; }
        
        if (self.shouldCleanupOnNextLogoutEvent) {
            [[HelmManager shared] showLoadingState];
            self.shouldCleanupOnNextLogoutEvent = NO;
        }
        
        [self.delegate didLogout:x];
        [self sendLoginEvent:nil];
    }];
    
    self.loginObserver = [TheKeymaster.signalForLogin subscribeNext:^(CKIClient * _Nullable client) {
        __strong NativeLoginManager *self = weakSelf;
        if (self.injectedLoginInfo) { return; }
        
        [self.delegate didLogin:client];
        [self sendLoginEvent:client];
    }];
}

- (void) sendLoginEvent:(CKIClient*) client {
    if (client == nil) {
        [[NativeLogin sharedInstance] sendEventWithName:@"Login" body:@{}];
        return;
    }
    
    NSDictionary *body = @{
                           @"appId": self.app,
                           @"authToken": client.accessToken,
                           @"user": client.currentUser.JSONDictionary,
                           @"baseURL": client.baseURL.absoluteString,
                           @"branding": client.branding ? [client.branding JSONDictionary] : @{},
                           };
    
    [[NativeLogin sharedInstance] sendEventWithName:@"Login" body:body];
}

#pragma MARK - CanvasKeymasterDelegate

- (void)injectLoginInformation:(NSDictionary *)info {
    
    NSMutableDictionary *mutableInfo = [info mutableCopy];
    mutableInfo[@"skipHydrate"] = @YES;
    self.injectedLoginInfo = mutableInfo;
    
    if (!info) {
        UIViewController *controller = self.domainPicker ?: [UIViewController new];
        [self.delegate didLogout:controller];
    }
    else {
        
        NSString *accessToken = info[@"authToken"];
        NSAssert(accessToken, @"You must provide an access token when injecting login information");
        [self.delegate didLogin:self.currentClient];
        [[[HelmManager shared] bridge] reload];
    }
}

@end
