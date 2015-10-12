## VPBiometricAuthenticationFacade v1.0.3
VPBiometricAuthenticationFacade is a high level wrapper for [LocalAuthentication](https://developer.apple.com/library/ios/documentation/LocalAuthentication/Reference/LocalAuthentication_Framework/) framework that provides ability to enable, disable and grant access to your application features by evaluating biometric policy (Touch ID). 

Full description of project is available [here (RUS)](http://habrahabr.ru/post/235699/)

### Installation
##### Cocoa Pods
Add to your Podfile ```pod "BiometricAuthenticationFacade"```.
##### Drag&Drop
1. Drag and drop BiometricAuthenticationFacade.xcodeproj to your project;
2. Add BiometricAuthenticationFacade to Build Settings -> Target Dependencies;
3. Add BiometricAuthenticationFacade.framework to Build Settings -> Link Binary With Libraries;
4. Add LocalAuthentication standard framework to your project.

### Usage
##### Import framework header
```objective-c
#import <BiometricAuthenticationFacade/VPBiometricAuthenticationFacade.h>
```
##### Create object instance
```objective-c
VPBiometricAuthenticationFacade *biometricFacade = [[VPBiometricAuthenticationFacade alloc] init];
```  

##### Check if biometric authentication is available on current device
```objective-c
if (biometricFacade.isAuthenticationAvailable) {
    // Authentication available
}
```  

##### Check if authentication for specific feature is enabled
```objective-c
if ([biometricFacade isAuthenticationEnabledForFeature:@"My secure feature"]) {
    // Authentication enabled
}
```  

##### Enable authentication for specific feature
```objective-c
[biometricFacade enableAuthenticationForFeature:@"My secure feature" succesBlock:^{
    // Authentication enabled
} failureBlock:^(NSError *error) {
    // Failed to enable authentication
}];
```
Method calls failure block if biometric authentication isn't available on current device. Error code ```kVPBiometricsUnavailabilityErrorCode```.

##### Disable authentication for specific feature
```objective-c
[biometricFacade disableAuthenticationForFeature:@"My secure feature" withReason:@"Authentication reason" succesBlock:^{
    // Authentication disabled
} failureBlock:^(NSError *error) {
    // Failed to disable authentication
}];
```
"Reason" parameter is app-provided reason for requesting authentication. This string should be provided in the user’s current language and should be short and clear. It will be displayed in the sub-title of the authentication dialog.  

Execution of this method leads to display system authentication dialog.  
Method calls failure block in next cases:  
1. If biometric authentication isn't available on current device. Error code ```kVPBiometricsUnavailabilityErrorCode```;  
2. If user cancels authentication. Error code ```kLAErrorUserCancel```;  
3. If user failed to pass authentication. Error code ```kLAErrorAuthenticationFailed```;  
4. If user taps the fallback button (Enter Password). Error code ```kLAErrorUserFallback```;  
5. If another application goes to foreground. Error code ```kLAErrorSystemCancel```.

##### Authenticate for access to specific feature
```objective-c
[biometricFacade authenticateForAccessToFeature:@"My secure feature" withReason:@"Authentication reason" succesBlock:^{
    // Access granted
} failureBlock:^(NSError *error) {
    // Access denied
}];
```
Execution of this method leads to display system authentication dialog.  
See previous method description to understand "reason" parameter and possible error codes in failureBlock.

##### Notes
1. Blocks in all methods are called on the main thread;  
2. Internal implementation of LocalAuthentication framework uses cache time in approximately 15 minutes. It means that if you successfully pass biometric authentication and then will try repeat the process in short period of time then system won't show authentication dialog, it will grant access immediately. If you need avoid such behaviour with cache time you have to use new instance of ```VPBiometricAuthenticationFacade``` for every attempt to pass authentication.

### System Requirements
It requires building with iOS SDK 8.0 and later. However it can be integrated to app with lower target version.

### License
VPBiometricAuthenticationFacade is released under the MIT license. See LICENSE for details.
