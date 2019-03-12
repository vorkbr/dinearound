//
//  NSDictionary+CGCheckin.m
//  Byte
//
//  Created by RYAN VANALSTINE on 11/17/13.
//  Copyright (c) 2013 Byte, LLC. All rights reserved.
//

#import "NSDictionary+Additions.h"

@implementation NSDictionary (Additions)
- (id)objectForKeyNotNull:(id)key {
    id object = [self objectForKey:key];
    if (object == [NSNull null]) return nil;
    
    return object;
}
- (id)valueForKeyPathNotNull:(id)key {
    id object = [self valueForKeyPath:key];
    if (object == [NSNull null]) return nil;
    
    return object;
}
+ (NSDictionary *)environments {
    NSString *path = [[NSBundle mainBundle] bundlePath];
    NSString *finalPath = [path stringByAppendingPathComponent:@"Environments.plist"];
    NSDictionary *plistData = [NSDictionary dictionaryWithContentsOfFile:finalPath];
    return [plistData objectForKey: @"Environments"];
}
+ (NSDictionary *)productionEnvironment {
    return [self environments][@"Production"];
//    return [self environments][@"Staging Server"];
}

#pragma mark Keys

/// An assertion is made if the the object is missing or is not of the right class.
/// For builds that have assertions turned off, this method will return nil if
/// there is no object for the given key or the object is not the expected class.
- (id)safeObjectForKey:(id<NSCopying>)key withClass:(Class)aClass {
    id object = [self objectOrNilForKey:key withClass:aClass];
    NSAssert(object, @"Expected object of class %@ to be returned for key %@", aClass, key);
    return object;
}
/// No assertion is made on the object. It is assumed that nil is appropriate.
- (id)objectOrNilForKey:(id<NSCopying>)key withClass:(Class)aClass {
    id object = [self objectForKey:key];
    return [object isKindOfClass:aClass] ? object : nil;
}

- (NSDictionary *)safeDictionaryForKey:(id<NSCopying>)key {
    return [self safeObjectForKey:key withClass:[NSDictionary class]];
}
- (NSNumber *)safeNumberForKey:(id<NSCopying>)key {
    return [self safeObjectForKey:key withClass:[NSNumber class]];
}

- (NSArray *)arrayOrNilForKey:(id<NSCopying>)key {
    return [self objectOrNilForKey:key withClass:[NSArray class]];
}
- (NSDictionary *)dictionaryOrNilForKey:(id<NSCopying>)key {
    return [self objectOrNilForKey:key withClass:[NSDictionary class]];
}
- (NSNumber *)numberOrNilForKey:(id<NSCopying>)key {
    return [self objectOrNilForKey:key withClass:[NSNumber class]];
}

#pragma mark Key Paths

- (id)safeObjectForKeyPath:(NSString *)keyPath withClass:(Class)aClass {
    id object = [self objectOrNilForKeyPath:keyPath withClass:aClass];
    NSAssert(object, @"Expected object of class %@ to be returned for key path %@", aClass, keyPath);
    return object;
}
- (id)objectOrNilForKeyPath:(NSString *)keyPath withClass:(Class)aClass {
    id object = [self valueForKeyPath:keyPath];
    return [object isKindOfClass:aClass] ? object : nil;
}

- (NSArray *)safeArrayForKeyPath:(NSString *)keyPath {
    return [self safeObjectForKeyPath:keyPath withClass:[NSArray class]];
}
- (NSNumber *)safeNumberForKeyPath:(NSString *)keyPath {
    return [self safeObjectForKeyPath:keyPath withClass:[NSNumber class]];
}
- (NSString *)safeStringForKeyPath:(NSString *)keyPath {
    return [self safeObjectForKeyPath:keyPath withClass:[NSString class]];
}

- (NSNumber *)numberOrNilForKeyPath:(NSString *)keyPath {
    return [self objectOrNilForKeyPath:keyPath withClass:[NSNumber class]];
}
- (NSString *)stringOrNilForKeyPath:(NSString *)keyPath {
    return [self objectOrNilForKeyPath:keyPath withClass:[NSString class]];
}
- (NSInteger)safeIntegerForKeyPath:(NSString *)keyPath {
    id object = [self valueForKeyPath:keyPath];
    
    if ([object isKindOfClass:[NSNumber class]]) {
        NSNumber *number = (NSNumber *)object;
        return number.integerValue;
    }
    
    if ([object isKindOfClass:[NSString class]]) {
        NSString *string = (NSString *)object;
        return string.integerValue;
    }
    
    return 0;
}

- (double)safeFloatForKeyPath:(NSString *)keyPath {
    id object = [self valueForKeyPath:keyPath];
    
    if ([object isKindOfClass:[NSNumber class]]) {
        NSNumber *number = (NSNumber *)object;
        return number.doubleValue;
    }
    
    if ([object isKindOfClass:[NSString class]]) {
        NSString *string = (NSString *)object;
        return string.doubleValue;
    }
    
    return .0;
}

- (BOOL)safeBoolForKeyPath:(NSString *)keyPath {
    id object = [self valueForKeyPath:keyPath];
    
    if ([object isKindOfClass:[NSNumber class]]) {
        NSNumber *number = (NSNumber *)object;
        return number.boolValue;
    }
    
    if ([object isKindOfClass:[NSString class]]) {
        NSString *string = (NSString *)object;
        return string.boolValue;
    }
    
    return NO;
}

@end
