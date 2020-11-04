// MIT License
//
// Copyright (c) 2017 Douglas Nassif Roma Junior
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.

#import <objc/runtime.h>
#import <objc/message.h>

#import "ReactNativeKeyboardManager.h"
#import "IQKeyboardManager.h"
#import <React/RCTLog.h>
#import <React/RCTRootView.h>

#import "RCTBaseTextInputView.h"

@implementation ReactNativeKeyboardManager

- (instancetype)init
{
    self = [super init];
    if (self) {
        Swizzle([RCTBaseTextInputView class], @selector(invalidateInputAccessoryView_backup), @selector(invalidateInputAccessoryView));
        Swizzle([RCTBaseTextInputView class], @selector(invalidateInputAccessoryView), @selector(invalidateInputAccessoryView_avoid));
    }
    return self;
}

void Swizzle(Class c, SEL orig, SEL new)
{
    Method origMethod = class_getInstanceMethod(c, orig);
    Method newMethod = class_getInstanceMethod(c, new);
    if(class_addMethod(c, orig, method_getImplementation(newMethod), method_getTypeEncoding(newMethod)))
    class_replaceMethod(c, new, method_getImplementation(origMethod), method_getTypeEncoding(origMethod));
    else
    method_exchangeImplementations(origMethod, newMethod);
}

- (UIColor *)colorFromHexString:(NSString *)hexString {
    unsigned rgbValue = 0;
    NSScanner *scanner = [NSScanner scannerWithString:hexString];
    [scanner setScanLocation:1]; // bypass '#' character
    [scanner scanHexInt:&rgbValue];
    return [UIColor colorWithRed:((rgbValue & 0xFF0000) >> 16)/255.0 green:((rgbValue & 0xFF00) >> 8)/255.0 blue:(rgbValue & 0xFF)/255.0 alpha:1.0];
}

+ (BOOL)requiresMainQueueSetup
{
    return YES;
}

BOOL debugging = NO;

RCT_EXPORT_MODULE(ReactNativeKeyboardManager);

RCT_EXPORT_METHOD(setEnableDebugging: (BOOL) enabled) {
    debugging = enabled;
    if (debugging) RCTLogInfo(@"KeyboardManager.setEnableDebugging: %d", enabled);
    [[IQKeyboardManager sharedManager] setEnableDebugging:enabled];
}

// UIKeyboard handling

RCT_EXPORT_METHOD(setEnable: (BOOL) enabled) {
    dispatch_sync(dispatch_get_main_queue(), ^{
        if (debugging) RCTLogInfo(@"KeyboardManager.setEnable: %d", enabled);
        [[IQKeyboardManager sharedManager] setEnable:enabled];
    });
}

RCT_EXPORT_METHOD(setKeyboardDistanceFromTextField: (CGFloat) distance) {
    if (debugging) RCTLogInfo(@"KeyboardManager.setKeyboardDistanceFromTextField: %f", distance);
    [[IQKeyboardManager sharedManager] setKeyboardDistanceFromTextField:distance];
}

// UIToolbar handling

RCT_EXPORT_METHOD(setToolbarPreviousNextButtonEnable: (BOOL) enabled) {
    if (debugging) RCTLogInfo(@"KeyboardManager.setToolbarPreviousNextButtonEnable: %d", enabled);
    if (enabled) {
        [[IQKeyboardManager sharedManager].toolbarPreviousNextAllowedClasses addObject:[RCTRootView class]];
    } else {
        [[IQKeyboardManager sharedManager].toolbarPreviousNextAllowedClasses removeObject:[RCTRootView class]];
    }
}

RCT_EXPORT_METHOD(setPreventShowingBottomBlankSpace: (BOOL) enabled) {
    if (debugging) RCTLogInfo(@"KeyboardManager.setPreventShowingBottomBlankSpace: %d", enabled);
    [[IQKeyboardManager sharedManager] setPreventShowingBottomBlankSpace:enabled];
}

RCT_EXPORT_METHOD(setEnableAutoToolbar: (BOOL) enabled) {
    dispatch_sync(dispatch_get_main_queue(), ^{
        if (debugging) RCTLogInfo(@"KeyboardManager.setEnableAutoToolbar: %d", enabled);
        [[IQKeyboardManager sharedManager] setEnableAutoToolbar:enabled];
    });
}

RCT_EXPORT_METHOD(setShouldToolbarUsesTextFieldTintColor: (BOOL) enabled) {
    if (debugging) RCTLogInfo(@"KeyboardManager.setShouldToolbarUsesTextFieldTintColor: %d", enabled);
    [[IQKeyboardManager sharedManager] setShouldToolbarUsesTextFieldTintColor:enabled];
}

RCT_EXPORT_METHOD(setToolbarTintColor: (NSString*) hexString) {
    dispatch_sync(dispatch_get_main_queue(), ^{
        if (debugging) RCTLogInfo(@"KeyboardManager.setToolbarTintColor: %@", hexString);
        UIColor* toolbarTintColor = [self colorFromHexString:hexString];
        [[IQKeyboardManager sharedManager] setToolbarTintColor: toolbarTintColor];
    });
}

RCT_EXPORT_METHOD(setToolbarBarTintColor: (NSString*) hexString) {
    dispatch_sync(dispatch_get_main_queue(), ^{
        if (debugging) RCTLogInfo(@"KeyboardManager.setToolbarBarTintColor: %@", hexString);
        UIColor* toolbarBarTintColor = [self colorFromHexString:hexString];
        [[IQKeyboardManager sharedManager] setToolbarBarTintColor: toolbarBarTintColor];
    });
}

RCT_EXPORT_METHOD(shouldShowToolbarPlaceholder: (BOOL) enabled) {
    if (debugging) RCTLogInfo(@"KeyboardManager.shouldShowToolbarPlaceholder: %d", enabled);
    [IQKeyboardManager sharedManager].shouldShowToolbarPlaceholder = enabled;
}

RCT_EXPORT_METHOD(setShouldShowTextFieldPlaceholder: (BOOL) enabled) {
    if (debugging) RCTLogInfo(@"KeyboardManager.setShouldShowTextFieldPlaceholder: %d", enabled);
    [[IQKeyboardManager sharedManager] setShouldShowTextFieldPlaceholder:enabled];
}

RCT_EXPORT_METHOD(setShouldShowToolbarPlaceholder: (BOOL) enabled) {
  if (debugging) RCTLogInfo(@"KeyboardManager.setShouldShowToolbarPlaceholder: %d", enabled);
  [[IQKeyboardManager sharedManager] setShouldShowToolbarPlaceholder:enabled];
}

RCT_EXPORT_METHOD(setToolbarDoneBarButtonItemText: (NSString *) text) {
    if (debugging) RCTLogInfo(@"KeyboardManager.setToolbarDoneBarButtonItemText: %@", text);
    [[IQKeyboardManager sharedManager] setToolbarDoneBarButtonItemText:text];
}

RCT_EXPORT_METHOD(setToolbarManageBehaviour: (NSInteger) autoToolbarType) {
    if (debugging) RCTLogInfo(@"KeyboardManager.setToolbarManageBehaviour: %ld", autoToolbarType);
    [[IQKeyboardManager sharedManager] setToolbarManageBehaviour:autoToolbarType];
}

// UIKeyboard Apparence overriding

RCT_EXPORT_METHOD(setOverrideKeyboardAppearance: (BOOL) enabled) {
    if (debugging) RCTLogInfo(@"KeyboardManager.setOverrideKeyboardAppearance: %d", enabled);
    [[IQKeyboardManager sharedManager] setOverrideKeyboardAppearance:enabled];
}

// UITextField/UITextView Resign handling

RCT_EXPORT_METHOD(setShouldResignOnTouchOutside: (BOOL) enabled) {
    if (debugging) RCTLogInfo(@"KeyboardManager.setShouldResignOnTouchOutside: %d", enabled);
    [[IQKeyboardManager sharedManager] setShouldResignOnTouchOutside:enabled];
}

RCT_EXPORT_METHOD(resignFirstResponder) {
    dispatch_sync(dispatch_get_main_queue(), ^{
      if (debugging) RCTLogInfo(@"KeyboardManager.resignFirstResponder");
      [[IQKeyboardManager sharedManager] resignFirstResponder];
    });
}

RCT_EXPORT_METHOD(reloadLayoutIfNeeded) {
    if (debugging) RCTLogInfo(@"KeyboardManager.reloadLayoutIfNeeded");
    dispatch_async(dispatch_get_main_queue(), ^{
        [[IQKeyboardManager sharedManager] reloadLayoutIfNeeded];
    });
}

// UIAnimation handling

RCT_EXPORT_METHOD(isKeyboardShowing: (RCTPromiseResolveBlock) resolve rejecter: (RCTPromiseRejectBlock) reject) {
    BOOL isKeyboardShowing = [IQKeyboardManager sharedManager].isKeyboardShowing;
    if (debugging) RCTLogInfo(@"KeyboardManager.isKeyboardShowing: %d", isKeyboardShowing);
    resolve([NSString stringWithFormat:@"%d", isKeyboardShowing]);
}

@end
