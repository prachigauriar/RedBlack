//
//  PGRedBlackTree.m
//  RedBlack
//
//  Created by Prachi Gauriar on 2/10/2013.
//  Copyright (c) 2013 Prachi Gauriar. All rights reserved.
//

#import "PGRedBlackTree.h"
#import "PGRedBlackTreeNode.h"

#pragma mark Tree private interface

@interface PGRedBlackTree ()

@property(readwrite, assign) PGRedBlackTreeNode *root;
@property(readwrite, copy) NSComparator comparator;

- (PGRedBlackTreeNode *)insertNodeWithObject:(id)object;
- (void)fixUpTreeInvariantsAfterInsertingNode:(PGRedBlackTreeNode *)node;

- (PGRedBlackTreeNode *)nodeForObject:(id)object;

- (NSArray *)enumeratedObjectsWithSelector:(SEL)selector object:(id)object;

@end


#pragma mark - Tree implementation

@implementation PGRedBlackTree

+ (PGRedBlackTree *)treeWithSelector:(SEL)selector
{
    return [[[self alloc] initWithSelector:selector] autorelease];
}


+ (PGRedBlackTree *)treeWithComparator:(NSComparator)comparator
{
    return [[[self alloc] initWithComparator:comparator] autorelease];
}


- (id)initWithSelector:(SEL)selector
{
    return [self initWithComparator:^NSComparisonResult(id object1, id object2) {
        return (NSComparisonResult)[object1 performSelector:selector withObject:object2];
    }];
}


- (id)initWithComparator:(NSComparator)comparator
{
    self = [super init];
    if (self) {
        self.comparator = comparator;
    }
    
    return self;
}


- (void)dealloc
{
    if (_root) PGRedBlackTreeNodeFree(_root);
    [_comparator release];    
    [super dealloc];
}


- (NSUInteger)count
{
    return _count;
}


- (NSString *)debugDescription
{
    return PGRedBlackTreeNodeAppendDebugDescription(_root, [NSMutableString string], 0);
}

#pragma mark - Insertion

- (void)addObject:(id)object
{
    NSAssert(object != nil, @"Attempted to insert a nil object");
    
    object = [object copy];
    PGRedBlackTreeNode *node = [self insertNodeWithObject:object];
    [object release];

    [self fixUpTreeInvariantsAfterInsertingNode:node];
    ++_count;
}
    

- (PGRedBlackTreeNode *)insertNodeWithObject:(id)object
{
    // If the tree has no root, just make the new node the root
    if (!_root) {
        PGRedBlackTreeNode *newNode = PGRedBlackTreeNodeCreate(nil, object);
        self.root = newNode;
        return newNode;
    }
    
    // Otherwise, figure out where we're supposed to be based on the comparator
    PGRedBlackTreeNode *node = _root;
    while (true) {
        if (_comparator(object, node->object) < NSOrderedSame) {
            // If node has no left child, we've found where to insert our node
            if (!node->leftChild) {
                PGRedBlackTreeNode *newNode = PGRedBlackTreeNodeCreate(node, object);
                node->leftChild = newNode;
                return newNode;
            }
            
            node = node->leftChild;
            continue;
        }
        
        // If node has no right child, we've found where to insert our node
        if (!node->rightChild) {
            PGRedBlackTreeNode *newNode = PGRedBlackTreeNodeCreate(node, object);
            node->rightChild = newNode;
            return newNode;
        }
        
        node = node->rightChild;
    }
}


- (void)fixUpTreeInvariantsAfterInsertingNode:(PGRedBlackTreeNode *)node
{
    while (true) {
        if (!node->parent) {
            // Case 1 - Node is the root
            node->isRed = NO;
            break;
        } else if (!node->parent->isRed) {
            // Case 2 - If node's parent is black, because we inserted a red between two blacks, and thus did not change the total
            // number of black nodes between the root and its leaf nodes
            break;
        }
        
        // Case 3 - Parent and uncle are red. Set the grandparent to red, parent and uncle to black, and fixup the grandparent
        PGRedBlackTreeNode *grandparent = PGRedBlackTreeNodeGrandparent(node);
        if (!grandparent) return;
        PGRedBlackTreeNode *uncle = PGRedBlackTreeNodeUncle(node);
        if (uncle && uncle->isRed) {
            node->parent->isRed = NO;
            uncle->isRed = NO;
            grandparent->isRed = YES;
            node = grandparent;
            continue;
        }
        
        // Case 4 - Node and its parent are red; grandparent and uncle are black. Before we can make node and its parent alternating colors,
        // we need to rotate under certain circumstances
        if (PGRedBlackTreeNodeIsRightChild(node) && PGRedBlackTreeNodeIsLeftChild(node->parent)) {
            PGRedBlackTreeNodeRotateLeftInTree(node->parent, self);
            node = node->leftChild;
            grandparent = node->parent->parent;
        } else if (PGRedBlackTreeNodeIsLeftChild(node) && PGRedBlackTreeNodeIsRightChild(node->parent)) {
            PGRedBlackTreeNodeRotateRightInTree(node->parent, self);
            node = node->rightChild;
            grandparent = node->parent->parent;
        }
        
        // Case 5 - We need to make sure that we and our parent aren't the same color using some rotation magic
        node->parent->isRed = NO;
        grandparent->isRed = YES;
        if (PGRedBlackTreeNodeIsLeftChild(node->parent)) {
            PGRedBlackTreeNodeRotateRightInTree(grandparent, self);
        } else {
            PGRedBlackTreeNodeRotateLeftInTree(grandparent, self);
        }
        
        break;
    }
}


#pragma mark - Membership

- (BOOL)containsObject:(id)object
{
    return [self member:object] != nil;
}


- (id)member:(id)object
{
    PGRedBlackTreeNode *node = [self nodeForObject:object];
    return node ? [[node->object retain] autorelease] : nil;
}


- (PGRedBlackTreeNode *)nodeForObject:(id)object
{
    if (!object) return NULL;
    
    PGRedBlackTreeNode *node = _root;
    while (node) {
        NSComparisonResult comparisonResult = self.comparator(object, node->object);
        
        if (comparisonResult < NSOrderedSame) {
            node = node->leftChild;
            continue;
        }
        
        if (comparisonResult == NSOrderedSame && [object hash] == [node->object hash] && [object isEqual:node->object]) {
            return node;
        }
        
        node = node->rightChild;
    }
    
    return NULL;
    
}


#pragma mark - Enumeration

- (void)enumerateObjectsUsingBlock:(void (^)(id, BOOL *))block
{
    PGRedBlackTreeNodeTraverseSubnodesWithBlock(_root, block);
}


- (void)enumerateObjectsLessThanObject:(id)object usingBlock:(void (^)(id, BOOL *))block
{
    PGRedBlackTreeNodeTraverseSubnodesWithBlock(_root, ^(id obj, BOOL *stop) {
        NSComparisonResult result = _comparator(obj, object);
        if (result >= NSOrderedSame) {
            *stop = YES;
            return;
        }
        
        block(obj, stop);
    });
}


- (void)enumerateObjectsLessThanOrEqualToObject:(id)object usingBlock:(void (^)(id, BOOL *))block
{
    PGRedBlackTreeNodeTraverseSubnodesWithBlock(_root, ^(id obj, BOOL *stop) {
        if (_comparator(obj, object) > NSOrderedSame) {
            *stop = YES;
            return;
        }
        
        block(obj, stop);
    });
}


- (void)enumerateObjectsEqualToObject:(id)object usingBlock:(void (^)(id, BOOL *))block
{
    PGRedBlackTreeNodeTraverseSubnodesEqualToObject(_root, object, _comparator, block);
}


- (void)enumerateObjectsGreaterThanOrEqualToObject:(id)object usingBlock:(void (^)(id, BOOL *))block
{
    PGRedBlackTreeNodeTraverseSubnodesGreaterThanOrEqualToObject(_root, object, _comparator, block);
}


- (void)enumerateObjectsGreaterThanObject:(id)object usingBlock:(void (^)(id, BOOL *))block
{
    PGRedBlackTreeNodeTraverseSubnodesGreaterThanObject(_root, object, _comparator, block);
}


#pragma mark - Returning objects with specific properties

- (NSArray *)objectsPassingTest:(BOOL (^)(id, BOOL *))predicate
{
    __block NSMutableArray *objects = [NSMutableArray array];
    
    [self enumerateObjectsUsingBlock:^(id object, BOOL *stop) {
        if (predicate(object, stop)) {
            [objects addObject:object];
        }
    }];
    
    return objects;
}


- (id)firstObject
{
    if (!_root) return nil;
    PGRedBlackTreeNode *node = _root;
    while (node->leftChild) {
        node = node->leftChild;
    }
    
    return [[node->object retain] autorelease];
}


- (id)lastObject
{
    if (!_root) return nil;
    PGRedBlackTreeNode *node = _root;
    while (node->rightChild) {
        node = node->rightChild;
    }
    
    return [[node->object retain] autorelease];
}


- (NSArray *)allObjects
{
    __block NSMutableArray *objects = [[NSMutableArray alloc] initWithCapacity:self.count];
    
    [self enumerateObjectsUsingBlock:^(id object, BOOL *stop) {
        [objects addObject:object];
    }];
    
    return objects;
}


- (NSArray *)enumeratedObjectsWithSelector:(SEL)selector object:(id)object
{
    __block NSMutableArray *objects = [NSMutableArray array];

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
    [self performSelector:selector withObject:object withObject:^(id object, BOOL *stop) {
        [objects addObject:object];
    }];
#pragma clang diagnostic pop

    return objects;

}


- (NSArray *)objectsLessThanObject:(id)object
{
    return [self enumeratedObjectsWithSelector:@selector(enumerateObjectsLessThanObject:usingBlock:) object:object];
}


- (NSArray *)objectsLessThanOrEqualToObject:(id)object
{
    return [self enumeratedObjectsWithSelector:@selector(enumerateObjectsLessThanOrEqualToObject:usingBlock:) object:object];
}


- (NSArray *)objectsEqualToObject:(id)object
{
    return [self enumeratedObjectsWithSelector:@selector(enumerateObjectsEqualToObject:usingBlock:) object:object];
}


- (NSArray *)objectsGreaterThanOrEqualToObject:(id)object
{
    return [self enumeratedObjectsWithSelector:@selector(enumerateObjectsGreaterThanOrEqualToObject:usingBlock:) object:object];
}


- (NSArray *)objectsGreaterThanObject:(id)object
{
    return [self enumeratedObjectsWithSelector:@selector(enumerateObjectsGreaterThanObject:usingBlock:) object:object];
}

@end


