//
//  NJOutputKeyPress.m
//  Enjoy
//
//  Created by Sam McCall on 5/05/09.
//

#import "NJOutputKeyPress.h"

#import "NJKeyInputField.h"

@implementation NJOutputKeyPress {
    NSTimer *_turboTimer;
    BOOL _turboIsKeyDown;
}

+ (NSString *)serializationCode {
    return @"key press";
}

- (NSDictionary *)serialize {
    return _keyCode != NJKeyInputFieldEmpty
        ? @{ @"type": self.class.serializationCode, @"key": @(_keyCode) }
        : nil;
}

+ (NJOutput *)outputWithSerialization:(NSDictionary *)serialization {
    NJOutputKeyPress *output = [[NJOutputKeyPress alloc] init];
    output.keyCode = [serialization[@"key"] shortValue];
    return output;
}

- (void)trigger {
    if (_keyCode != NJKeyInputFieldEmpty) {
        CGEventRef keyDown = CGEventCreateKeyboardEvent(NULL, _keyCode, YES);
        CGEventPost(kCGHIDEventTap, keyDown);
        CFRelease(keyDown);
        
        [_turboTimer invalidate];
        _turboTimer = nil;
        
        if (self.isTurboOn == YES) {
            // create a new timer
            _turboIsKeyDown = YES;
            _turboTimer =
            [NSTimer scheduledTimerWithTimeInterval:0.025
                                             target:self
                                           selector:@selector(_turboTimerCallback:)
                                           userInfo:nil
                                            repeats:YES];
        }
    }
}

- (void)untrigger {
    if (_keyCode != NJKeyInputFieldEmpty) {
        CGEventRef keyUp = CGEventCreateKeyboardEvent(NULL, _keyCode, NO);
        CGEventPost(kCGHIDEventTap, keyUp);
        CFRelease(keyUp);
        
        [_turboTimer invalidate];
        _turboTimer = nil;
        
        _turboIsKeyDown = NO;
    }
}

- (void)_turboTimerCallback:(NSTimer*)timer {
    NSLog(@"_turboIsKeyDown: %@ auto toggle the keycode: %hu timer: %@", _turboIsKeyDown ? @"YES" : @"NO", _keyCode, timer);
    
    if (_keyCode != NJKeyInputFieldEmpty) {
        if (_turboIsKeyDown == YES) {
            CGEventRef keyUp = CGEventCreateKeyboardEvent(NULL, _keyCode, NO);
            CGEventPost(kCGHIDEventTap, keyUp);
            CFRelease(keyUp);
        } else {
            CGEventRef keyDown = CGEventCreateKeyboardEvent(NULL, _keyCode, YES);
            CGEventPost(kCGHIDEventTap, keyDown);
            CFRelease(keyDown);
        }
        _turboIsKeyDown = !_turboIsKeyDown;
    }
}

@end
