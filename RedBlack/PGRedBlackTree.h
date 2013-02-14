//
//  PGRedBlackTree.h
//  RedBlack
//
//  Created by Prachi Gauriar on 2/10/2013.
//  Copyright (c) 2013 Prachi Gauriar. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface PGRedBlackTree : NSObject {
    NSUInteger _count;
}

+ (PGRedBlackTree *)treeWithSelector:(SEL)comparator;
+ (PGRedBlackTree *)treeWithComparator:(NSComparator)comparator;

- (id)initWithSelector:(SEL)comparator;
- (id)initWithComparator:(NSComparator)comparator;

- (NSUInteger)count;

- (void)addObject:(id <NSCopying>)object;

- (BOOL)containsObject:(id)object;
- (id)member:(id)object;

- (void)removeObject:(id)object;

- (void)enumerateObjectsUsingBlock:(void (^)(id obj, BOOL *stop))block;
- (void)enumerateObjectsLessThanObject:(id)object usingBlock:(void (^)(id obj, BOOL *stop))block;
- (void)enumerateObjectsLessThanOrEqualToObject:(id)object usingBlock:(void (^)(id obj, BOOL *stop))block;
- (void)enumerateObjectsEqualToObject:(id)object usingBlock:(void (^)(id obj, BOOL *stop))block;
- (void)enumerateObjectsGreaterThanOrEqualToObject:(id)object usingBlock:(void (^)(id obj, BOOL *stop))block;
- (void)enumerateObjectsGreaterThanObject:(id)object usingBlock:(void (^)(id obj, BOOL *stop))block;

- (id)firstObject;
- (id)lastObject;
- (NSArray *)allObjects;

- (NSArray *)objectsPassingTest:(BOOL (^)(id obj, BOOL *stop))predicate;

- (NSArray *)objectsLessThanObject:(id)object;
- (NSArray *)objectsLessThanOrEqualToObject:(id)object;
- (NSArray *)objectsEqualToObject:(id)object;
- (NSArray *)objectsGreaterThanOrEqualToObject:(id)object;
- (NSArray *)objectsGreaterThanObject:(id)object;

@end

