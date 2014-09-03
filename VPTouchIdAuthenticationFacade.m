//
//  VPBiometricsFacade.m
//  VPBiometricsFacade
//
//  Created by Vladimir Popko (visput).
//

#import "VPTouchIdAuthenticationFacade.h"

@import LocalAuthentication;
@import CoreFoundation;
@import UIKit;

static NSString *const kVPFeaturesDictionaryKey = @"VPFeaturesDictionaryKey";

@interface VPTouchIdAuthenticationFacade ()

@property (nonatomic, strong) LAContext *authenticationContext;

@end

@implementation VPTouchIdAuthenticationFacade

- (instancetype)init {
    self = [super init];
    if (self) {
        if (self.isIOS8AndLater) {
            self.authenticationContext = [[LAContext alloc] init];
        }
    }
    return self;
}


- (BOOL)isAuthenticationAvailable {
    return self.isIOS8AndLater && self.isPassByTouchIdAvailable;
}

- (BOOL)isAuthenticationEnabledForFeature:(NSString *)featureName {
    return self.isAuthenticationAvailable && [self loadIsAuthenticationEnabledForFeature:featureName];
}

- (void)enableAuthenticationForFeature:(NSString *)featureName
                           succesBlock:(void(^)())successBlock
                          failureBlock:(void(^)(NSError *error))failureBlock {
    if (self.isAuthenticationAvailable) {
        if ([self isAuthenticationEnabledForFeature:featureName]) {
            successBlock();
        } else {
            [self saveIsAuthenticationEnabled:YES forFeature:featureName];
            successBlock();
        }
    } else {
        failureBlock(self.authenticationUnavailabilityError);
    }
}

- (void)disableAuthenticationForFeature:(NSString *)featureName
                             withReason:(NSString *)reason
                            succesBlock:(void(^)())successBlock
                           failureBlock:(void(^)(NSError *error))failureBlock {
    if (self.isAuthenticationAvailable) {
        if ([self isAuthenticationEnabledForFeature:featureName]) {
            [self passByTouchIdWithReason:reason succesBlock:^{
                [self saveIsAuthenticationEnabled:NO forFeature:featureName];
                successBlock();
            } failureBlock:failureBlock];
        } else {
            successBlock();
        }
    } else {
        failureBlock(self.authenticationUnavailabilityError);
    }
}

- (void)authenticateForAccessToFeature:(NSString *)featureName
                            withReason:(NSString *)reason
                           succesBlock:(void(^)())successBlock
                          failureBlock:(void(^)(NSError *error))failureBlock {
    if (self.isAuthenticationAvailable) {
        if ([self isAuthenticationEnabledForFeature:featureName]) {
            [self passByTouchIdWithReason:reason
                              succesBlock:successBlock
                             failureBlock:failureBlock];
        } else {
            successBlock();
        }
    } else {
        failureBlock(self.authenticationUnavailabilityError);
    }
}

#pragma mark -
#pragma mark Touch ID

- (BOOL)isPassByTouchIdAvailable {
    return [self.authenticationContext canEvaluatePolicy:LAPolicyDeviceOwnerAuthenticationWithBiometrics error:NULL];
}

- (void)passByTouchIdWithReason:(NSString *)reason
                    succesBlock:(void(^)())successBlock
                   failureBlock:(void(^)(NSError *error))failureBlock {
    [self.authenticationContext evaluatePolicy:LAPolicyDeviceOwnerAuthenticationWithBiometrics localizedReason:reason reply:^(BOOL success, NSError *error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if (success) {
                successBlock();
            } else {
                failureBlock(error);
            }
        });
    }];
}

#pragma mark -
#pragma mark Storage

- (void)saveIsAuthenticationEnabled:(BOOL)isAuthenticationEnabled forFeature:(NSString *)featureName {
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    
    NSMutableDictionary *featuresDictionary = nil;
    if ([userDefaults valueForKey:kVPFeaturesDictionaryKey] == nil) {
        featuresDictionary = [NSMutableDictionary dictionary];
    } else {
        featuresDictionary = [NSMutableDictionary dictionaryWithDictionary:[userDefaults valueForKey:kVPFeaturesDictionaryKey]];
    }
    
    [featuresDictionary setValue:@(isAuthenticationEnabled) forKey:featureName];
    [userDefaults setValue:featuresDictionary forKey:kVPFeaturesDictionaryKey];
    [userDefaults synchronize];
}

- (BOOL)loadIsAuthenticationEnabledForFeature:(NSString *)featureName {
    return [[[[NSUserDefaults standardUserDefaults] valueForKey:kVPFeaturesDictionaryKey] valueForKey:featureName] boolValue];
}

#pragma mark -
#pragma mark Utils

- (BOOL)isIOS8AndLater {
    static CGFloat const kSystemVersionIOS8 = 8.0f;
    return [UIDevice currentDevice].systemVersion.floatValue >= kSystemVersionIOS8;
}

#pragma mark -
#pragma mark Error

- (NSError *)authenticationUnavailabilityError {
    return [NSError errorWithDomain:@"VPTouchIdAuthenticationDomain"
                               code:1000
                           userInfo:@{NSLocalizedDescriptionKey: NSLocalizedString(@"Authentication by Touch ID isn't available", nil)}];
}

@end
