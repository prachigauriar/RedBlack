//
//  PGRedBlackTree.h
//  RedBlack
//
//  Created by Prachi Gauriar on 2/10/2013.
//  Copyright (c) 2013 Prachi Gauriar. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface PGRedBlackTree : NSObject

@property(readonly, assign) NSUInteger count;

+ (PGRedBlackTree *)treeWithSelector:(SEL)comparator;
+ (PGRedBlackTree *)treeWithComparator:(NSComparator)comparator;

- (id)initWithSelector:(SEL)comparator;
- (id)initWithComparator:(NSComparator)comparator;

- (void)addObject:(id <NSCopying>)object;

- (BOOL)containsObject:(id)object;
- (id)member:(id)object;

- (void)enumerateObjectsUsingBlock:(void (^)(id object, BOOL *stop))block;
- (void)enumerateObjectsLessThanObject:(id)object usingBlock:(void (^)(id, BOOL *))block;
- (void)enumerateObjectsLessThanOrEqualToObject:(id)object usingBlock:(void (^)(id, BOOL *))block;
- (void)enumerateObjectsEqualToObject:(id)object usingBlock:(void (^)(id, BOOL *))block;
- (void)enumerateObjectsGreaterThanOrEqualToObject:(id)object usingBlock:(void (^)(id, BOOL *))block;
- (void)enumerateObjectsGreaterThanObject:(id)object usingBlock:(void (^)(id, BOOL *))block;

- (NSArray *)objectsPassingTest:(BOOL (^)(id object, BOOL *stop))predicate;

- (id)firstObject;
- (id)lastObject;
- (NSArray *)allObjects;

- (NSArray *)objectsLessThanObject:(id)object;
- (NSArray *)objectsLessThanOrEqualToObject:(id)object;
- (NSArray *)objectsEqualToObject:(id)object;
- (NSArray *)objectsGreaterThanOrEqualToObject:(id)object;
- (NSArray *)objectsGreaterThanObject:(id)object;

//- (void)removeObject:(id)object;

@end

