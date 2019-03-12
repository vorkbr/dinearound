//
//  NSDictionary+CGCheckin.h
//  Byte
//
//  Created by RYAN VANALSTINE on 11/17/13.
//  Copyright (c) 2013 Byte, LLC. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSDictionary (Additions)
- (id)objectForKeyNotNull:(id)key;
- (id)valueForKeyPathNotNull:(id)key;
+ (NSDictionary *)productionEnvironment;
+ (NSDictionary *)environments;


- (id)safeObjectForKey:(id<NSCopying>)key withClass:(Class)aClass;
- (id)objectOrNilForKey:(id<NSCopying>)key withClass:(Class)aClass;

- (NSDictionary *)safeDictionaryForKey:(id<NSCopying>)key;
- (NSNumber *)safeNumberForKey:(id<NSCopying>)key;

- (NSArray *)arrayOrNilForKey:(id<NSCopying>)key;
- (NSDictionary *)dictionaryOrNilForKey:(id<NSCopying>)key;
- (NSNumber *)numberOrNilForKey:(id<NSCopying>)key;

// Key Paths

- (id)safeObjectForKeyPath:(NSString *)keyPath withClass:(Class)aClass;
- (id)objectOrNilForKeyPath:(NSString *)keyPath withClass:(Class)aClass;

- (NSArray *)safeArrayForKeyPath:(NSString *)keyPath;
- (NSNumber *)safeNumberForKeyPath:(NSString *)keyPath;
- (NSString *)safeStringForKeyPath:(NSString *)keyPath;

- (NSNumber *)numberOrNilForKeyPath:(NSString *)keyPath;
- (NSString *)stringOrNilForKeyPath:(NSString *)keyPath;

- (NSInteger)safeIntegerForKeyPath:(NSString *)keyPath;
- (double)safeFloatForKeyPath:(NSString *)keyPath;
- (BOOL)safeBoolForKeyPath:(NSString *)keyPath;


@end
