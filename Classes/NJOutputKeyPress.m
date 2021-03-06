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

-(instancetype)init {
    self = [super init];
    if (self != nil) {
        _keyCode = 0;
        _isTurboOn = NO;
        _turboTimeBetweenToggledInSeconds = 0.0333;
    }
    return self;
}

+ (NSString *)serializationCode {
    return @"key press";
}

- (NSDictionary *)serialize {
    if (_keyCode != NJKeyInputFieldEmpty) {
        NSDictionary *retDict = @{
            @"type": self.class.serializationCode,
            @"key": @(_keyCode),
            @"isTurboOn": [NSNumber numberWithBool:_isTurboOn],
            @"turboTimeBetweenToggledInSeconds": [NSNumber numberWithDouble:_turboTimeBetweenToggledInSeconds]
        };
        NSLog(@"NJOutputKeyPress serialize retDict: %@", retDict);
        return retDict;
    } else {
        return nil;
    }
}

+ (NJOutput *)outputWithSerialization:(NSDictionary *)serialization {
    NSLog(@"outputWithSerialization: %@", serialization);
    NJOutputKeyPress *output = [[NJOutputKeyPress alloc] init];
    output.keyCode = [serialization[@"key"] shortValue];
    output.isTurboOn = [serialization[@"isTurboOn"] boolValue];
    output.turboTimeBetweenToggledInSeconds = [serialization[@"turboTimeBetweenToggledInSeconds"] doubleValue];
    return output;
}

- (void)trigger {
    if (_keyCode != NJKeyInputFieldEmpty) {
        CGEventRef keyDown = CGEventCreateKeyboardEvent(NULL, _keyCode, YES);
        CGEventPost(kCGHIDEventTap, keyDown);
        CFRelease(keyDown);
        
        [_turboTimer invalidate];
        _turboTimer = nil;
        
        NSLog(@"isTurboOn: %@", self.isTurboOn ? @"YES" : @"NO");
        if (self.isTurboOn == YES) {
            // create a new timer
            _turboIsKeyDown = YES;
            _turboTimer =
            [NSTimer scheduledTimerWithTimeInterval:self.turboTimeBetweenToggledInSeconds
                                             target:self
                                           selector:@selector(_turboTimerCallback:)
                                           userInfo:nil
                                            repeats:YES];
            [[NSRunLoop mainRunLoop] addTimer:_turboTimer forMode:NSRunLoopCommonModes];
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
