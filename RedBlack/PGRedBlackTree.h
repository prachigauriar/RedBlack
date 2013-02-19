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
 @result A new empty tree.
 */
+ (PGRedBlackTree *)tree;

/*!
 @abstract Creates and returns a tree that uses the specified selector to compare its objects.
 @discussion All objects added to the new tree must respond to the specified selector.
 @param selector The selector used to compare objects in the new tree. May not be NULL.
 @result A new tree or nil if selector is NULL.
 */
+ (PGRedBlackTree *)treeWithSelector:(SEL)selector;

/*!
 @abstract Creates and returns a tree that uses the specified block to compare its objects.
 @param comparator The block used to compare objects in the new tree. This block follows the same
     conventions as comparator blocks in Foundation. May not be nil.
 @result A new tree or nil if comparator is nil.
 */
+ (PGRedBlackTree *)treeWithComparator:(NSComparator)comparator;


/*!
 @abstract Returns an initialized tree that uses compare: as its selector.
 @discussion All objects added to the tree must respond to compare:.
 @result A newly initialized tree.
 */
- (id)init;

/*!
 @abstract Returns an initialized tree that uses the specified selector to compare its objects.
 @discussion All objects added to the tree must respond to the specified selector.
 @param selector The selector used to compare objects in the new tree. May not be NULL.
 @result A newly initialized tree or nil if selector is NULL.
 */
- (id)initWithSelector:(SEL)selector;

/*!
 @abstract Returns an initialized tree that uses the specified block to compare its objects.
 @param comparator The block used to compare objects in the new tree. This block follows the same conventions as comparator
     blocks in Foundation. May not be nil.
 @result A newly initialized tree or nil if comparator is nil.
 */
- (id)initWithComparator:(NSComparator)comparator;

/*!
 @abstract Returns the number of objects in the tree.
 @result The number of items in the tree.
 */
- (NSUInteger)count;

/*!
 @abstract Adds a copy of the specified object to the tree.
 @discussion Because a red-black tree is a type of binary search tree, it is very important that its objects not
     mutate after they have been added to the tree. If an object's mutation affected its comparison value the object
     would no longer be located where it should be in the . To prevent this, the implementation of -addObject: adds 
     a copy of the object to the tree. If your object is immutable, it is recommended that your object's implementation
     of -copyWithZone: merely increments the object's retain count.
 @param object The object whose copy will be added. May not be nil.
 @throws NSInvalidArgumentException if object is nil
 */
- (void)addObject:(id <NSCopying>)object;

/*!
 @abstract Adds a copy of each object in the specified array to the tree. 
 @discussion If array is nil, this method does nothing. Otherwise, it simply repeatedly invokes addObject: on the
     tree using the objects in array.
 @param array The array to add objects from
 */
- (void)addObjectsFromArray:(NSArray *)array;

/*!
 @abstract Returns whether an object equivalent to the one specified is in the tree.
 @discussion This method returns YES if and only if [tree member:object] returns a valid object.
 @param object The object whose membership in the tree is being tested.
 @result Returns YES when an object equivalent to the one specified is in the tree and NO otherwise.
 */
- (BOOL)containsObject:(id)object;

/*!
 @abstract Returns an object in the tree that is equivalent to the one specified.
 @discussion This method works by first finding a candidate object for which the tree's comparator returns
     NSOrderedSame when comparing it to the specified object. It then checks if the specified object's hash is equal
     to that of the candidate object. It then uses -isEqual: to check that the objects are equal. If so, it returns
     the candidate object; otherwise, it looks for another candidate.
 
     Due to this behavior, it is imperative that objects added to the tree have implementations of -hash and -isEqual: 
     that are consistent with the tree's comparator. That is, if -isEqual: returns true for two objects, -hash should
     return the same value for both objects and the tree's comparator should return NSOrderedSame when comparing them.
     Failing to do so could make it imposible to correctly check for membership or remove specific objects from the tree.
 
     If you are only interested in objects that are equal to the specified object according to the tree's comparator, see
     -enumerateObjectsEqualToObject: or -objectsEqualToObject:.
 @param object The object being searched for.
 @result The object in the tree that is equivalent to the one specified, or nil if there is no such object.
 */
- (id)member:(id)object;

/*!
 @abstract Removes the specified object from the tree.
 @discussion If the object is in the tree multiple times, only the one returned by -member: is removed. Does nothing if
     the object is not in the tree.
 @param object The object to remove.
 */
- (void)removeObject:(id)object;

/*!
 @abstract Removes all objects from the tree.
 */
- (void)removeAllObjects;

/*!
 @abstract Executes the specified block using each object in the tree in ascending order according to the tree's comparator.
 @param block The block to apply to the elements in the tree. May not be nil. The block takes two arguments:
 @param obj The element in the tree.
 @param stop A reference to a Boolean value. The block can set the value to YES to stop further processing of the tree. The
     stop argument is an out-only argument. You should only ever set this Boolean to YES within the block.
 @throws NSInvalidArgumentException if block is nil.
 */
- (void)enumerateObjectsUsingBlock:(void (^)(id obj, BOOL *stop))block;

/*!
 @abstract Executes the specified block using each object in the tree that is less than the specified object in ascending
     order according to the tree's comparator.
 @param block The block to apply to the elements in the tree. May not be nil. The block takes two arguments:
 @param obj The element in the tree.
 @param stop A reference to a Boolean value. The block can set the value to YES to stop further processing of the tree. The
     stop argument is an out-only argument. You should only ever set this Boolean to YES within the block.
 @throws NSInvalidArgumentException if block is nil.
 */
- (void)enumerateObjectsLessThanObject:(id)object usingBlock:(void (^)(id obj, BOOL *stop))block;

/*!
 @abstract Executes the specified block using each object in the tree that is less than or equal to the specified object
     in ascending order according to the tree's comparator.
 @param block The block to apply to the elements in the tree. May not be nil. The block takes two arguments:
 @param obj The element in the tree.
 @param stop A reference to a Boolean value. The block can set the value to YES to stop further processing of the tree. The
     stop argument is an out-only argument. You should only ever set this Boolean to YES within the block.
 @throws NSInvalidArgumentException if block is nil.
 */
- (void)enumerateObjectsLessThanOrEqualToObject:(id)object usingBlock:(void (^)(id obj, BOOL *stop))block;

/*!
 @abstract Executes the specified block using each object in the tree that is equal to the specified object in ascending
     order according to the tree's comparator.
 @param block The block to apply to the elements in the tree. May not be nil. The block takes two arguments:
 @param obj The element in the tree.
 @param stop A reference to a Boolean value. The block can set the value to YES to stop further processing of the tree. The
     stop argument is an out-only argument. You should only ever set this Boolean to YES within the block.
 @throws NSInvalidArgumentException if block is nil.
 */
- (void)enumerateObjectsEqualToObject:(id)object usingBlock:(void (^)(id obj, BOOL *stop))block;

/*!
 @abstract Executes the specified block using each object in the tree that is greater than or equal to the specified object in
     ascending order according to the tree's comparator.
 @param block The block to apply to the elements in the tree. May not be nil. The block takes two arguments:
 @param obj The element in the tree.
 @param stop A reference to a Boolean value. The block can set the value to YES to stop further processing of the tree. The
     stop argument is an out-only argument. You should only ever set this Boolean to YES within the block.
 @throws NSInvalidArgumentException if block is nil.
 */
- (void)enumerateObjectsGreaterThanOrEqualToObject:(id)object usingBlock:(void (^)(id obj, BOOL *stop))block;

/*!
 @abstract Executes the specified block using each object in the tree that is greater than the specified object in ascending
     order according to the tree's comparator.
 @param block The block to apply to the elements in the tree. May not be nil. The block takes two arguments:
 @param obj The element in the tree.
 @param stop A reference to a Boolean value. The block can set the value to YES to stop further processing of the tree. The
     stop argument is an out-only argument. You should only ever set this Boolean to YES within the block.
 @throws NSInvalidArgumentException if block is nil.
 */
- (void)enumerateObjectsGreaterThanObject:(id)object usingBlock:(void (^)(id obj, BOOL *stop))block;

/*!
 @abstract Returns the first object in the tree.
 @discussion This object is guaranteed to be less than or equal to every other object in the tree according to the tree's 
     comparator.
 @result The first object in the tree, or nil if the tree is empty.
 */
- (id)firstObject;

/*!
 @abstract Returns the last object in the tree.
 @discussion This object is guaranteed to be greater than or equal to every other object in the tree according to the tree's
     comparator.
 @result The last object in the tree, or nil if the tree is empty.
 */
- (id)lastObject;

/*!
 @abstract Returns all in the tree in ascending order according to the tree's comparator.
 */
- (NSArray *)allObjects;

/*!
 @abstract Returns the objects in the tree that pass a test in the specified block.
 @param predicate The block to apply to elements in the tree. May not be nil. The block takes two arguments:
 @param obj The element in the tree.
 @param stop A reference to a Boolean value. The block can set the value to YES to stop further processing of the tree. The
     stop argument is an out-only argument. You should only ever set this Boolean to YES within the block.
 @throws NSInvalidArgumentException if predicate is nil.
 @result The objects in the tree that pass a test in the specified block.
 */
- (NSArray *)objectsPassingTest:(BOOL (^)(id obj, BOOL *stop))predicate;

/*!
 @abstract Returns the objects in the tree that are less than the specified object according to the tree's comparator.
 @result The objects in the tree that are less than the specified object.
 */
- (NSArray *)objectsLessThanObject:(id)object;

/*!
 @abstract Returns the objects in the tree that are less than or equal to the specified object according to the tree's
     comparator.
 @result The objects in the tree that are less than or equal to the specified object.
 */
- (NSArray *)objectsLessThanOrEqualToObject:(id)object;

/*!
 @abstract Returns the objects in the tree that are equal to the specified object according to the tree's comparator.
 @result The objects in the tree that are equal to the specified object.
 */
- (NSArray *)objectsEqualToObject:(id)object;

/*!
 @abstract Returns the objects in the tree that are greater than or equal to the specified object according to the tree's
     comparator.
 @result The objects in the tree that are greater than or equal to the specified object.
 */
- (NSArray *)objectsGreaterThanOrEqualToObject:(id)object;

/*!
 @abstract Returns the objects in the tree that are greater than the specified object according to the tree's comparator.
 @result The objects in the tree that are equal to the specified object.
 */
- (NSArray *)objectsGreaterThanObject:(id)object;

@end
