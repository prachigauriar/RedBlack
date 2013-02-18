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

/*!
 @abstract Creates and returns a tree that uses compare: as its selector.
 @discussion All objects added to the tree must respond to compare:.
 @result A new empty tree
 */
+ (PGRedBlackTree *)tree;

/*!
 @abstract Creates and returns a tree that uses the specified selector to compare its objects.
 @discussion All objects added to the new tree must respond to the specified selector.
 @param selector The selector used to compare objects in the new tree. May not be NULL.
 @result A new tree or nil if selector is NULL
 */
+ (PGRedBlackTree *)treeWithSelector:(SEL)selector;

/*!
 @abstract Creates and returns a tree that uses the specified block to compare its objects.
 @param comparator The block used to compare objects in the new tree. This block follows the same
     conventions as comparator blocks in Foundation. May not be NULL.
 @result A new tree or nil if comparator is NULL
 */
+ (PGRedBlackTree *)treeWithComparator:(NSComparator)comparator;


/*!
 @abstract Returns an initialized tree that uses compare: as its selector.
 @discussion All objects added to the tree must respond to compare:.
 @result A newly initialized tree
 */
- (id)init;

/*!
 @abstract Returns an initialized tree that uses the specified selector to compare its objects.
 @discussion All objects added to the tree must respond to the specified selector.
 @param selector The selector used to compare objects in the new tree. May not be NULL.
 @result A newly initialized tree or nil if selector is NULL
 */
- (id)initWithSelector:(SEL)selector;

/*!
 @abstract Returns an initialized tree that uses the specified block to compare its objects.
 @param comparator The block used to compare objects in the new tree. This block follows the same
     conventions as comparator blocks in Foundation. May not be NULL.
 @result A newly initialized tree or nil if comparator is NULL
 */
- (id)initWithComparator:(NSComparator)comparator;

/*!
 @abstract Returns the number of objects in the receiver.
 @result The number of items in the receiver
 */
- (NSUInteger)count;

/*!
 @abstract Adds a copy of the specified object to the receiver.
 @discussion Because a red-black tree is a type of binary search tree, it is very important that its objects
     not mutate after they have been added to the tree. If an object's mutation affected its comparison value
     the object would no longer be located where it should be in the . To prevent this, the implementation
     of -addObject: adds a copy of the object to the tree. If your object is immutable, it is recommended that
     your object's implementation of -copyWithZone: merely increments the object's retain count.
 @param object The object whose copy will be added. May not be nil.
 @throws NSInvalidArgumentException if object is nil
 */
- (void)addObject:(id <NSCopying>)object;

/*!
 @abstract Adds a copy of each object in the specified array to the receiver. 
 @discussion If array is nil, this method does nothing. Otherwise, it simply repeatedly invokes addObject: on the
     receiver using the objects in array.
 @param array The array to add objects from
 */
- (void)addObjectsFromArray:(NSArray *)array;

/*!
 @abstract Returns whether an object equivalent to the one specified is in the receiver.
 @discussion This method returns YES if and only if [receiver member:object] returns a valid object.
 @param object The object whose membership in the receiver is being tested.
 @result Returns YES when an object equivalent to the one specified is in the receiver and NO otherwise.
 */
- (BOOL)containsObject:(id)object;

/*!
 @abstract Returns the object in the receiver that is equivalent to the one specified.
 @discussion This method works by first finding a candidate object for which the receiver's comparator returns
 NSOrderedSame when comparing it to the specified object. 
 
 */
- (id)member:(id)object;

- (void)removeObject:(id)object;
- (void)removeAllObjects;

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


@interface PGRedBlackTree (PropertyVerification)

- (BOOL)fulfillsProperties;

@end
