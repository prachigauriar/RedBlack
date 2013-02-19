//
//  PGRedBlackTree.m
//  RedBlack
//
//  Created by Prachi Gauriar on 2/10/2013.
//  Copyright (c) 2013 Prachi Gauriar. All rights reserved.
//

#import "PGRedBlackTree.h"

#import "PGRedBlackTreeNode.h"
#import "PGUtilities.h"

#pragma mark Red-Black Tree Properties

// For reference, these are the five properties of red-black trees.
//    1. A node is either red or black.
//    2. The root node is black.
//    3. All leaves (sentinels) are black.
//    4. A red node's children are black.
//    5. Every simple path from a given node to any of its descendant leaves contains the same number of black nodes.


#pragma mark - Private interfaces

@interface PGRedBlackTree ()

@property(readwrite, assign) NSUInteger count;
@property(readwrite, assign) PGRedBlackTreeNode *root;
@property(readwrite, copy) NSComparator comparator;

- (PGRedBlackTreeNode *)insertNodeWithObject:(id)object;
- (void)fixPropertiesAfterInsertionWithNode:(PGRedBlackTreeNode *)node;
- (void)fixPropertiesAfterRemovalWithNode:(PGRedBlackTreeNode *)node;

- (PGRedBlackTreeNode *)nodeForObject:(id)object;

- (NSArray *)enumeratedObjectsWithSelector:(SEL)selector object:(id)object;

@end


@interface PGRedBlackTree (PropertyVerification)
- (BOOL)fulfillsProperties;
@end


#pragma mark - Implementation


@implementation PGRedBlackTree

+ (PGRedBlackTree *)tree
{
    return [[[self alloc] init] autorelease];
}


+ (PGRedBlackTree *)treeWithSelector:(SEL)selector
{
    return [[[self alloc] initWithSelector:selector] autorelease];
}


+ (PGRedBlackTree *)treeWithComparator:(NSComparator)comparator
{
    return [[[self alloc] initWithComparator:comparator] autorelease];
}


- (id)init
{
    return [self initWithSelector:@selector(compare:)];
}


- (id)initWithSelector:(SEL)selector
{
    if (!selector) return nil;
    return [self initWithComparator:^NSComparisonResult(id object1, id object2) {
        return (NSComparisonResult)[object1 performSelector:selector withObject:object2];
    }];
}


- (id)initWithComparator:(NSComparator)comparator
{
    if (!comparator) return nil;

    self = [super init];
    if (self) {
        [self setComparator:comparator];
    }
    
    return self;
}


- (void)dealloc
{
    if (_root) PGRedBlackTreeNodeFree(_root, YES);
    [_comparator release];    
    [super dealloc];
}


- (NSString *)debugDescription
{
    if (!_root) return @"<tree></tree>";
    NSMutableString *description = [NSMutableString stringWithString:@"<tree>\n"];
    PGRedBlackTreeNodeAppendDebugDescription(_root, description, 1);
    [description appendString:@"</tree>\n"];
    return description;
}


#pragma mark - Insertion

- (void)addObject:(id)object
{
    if (!object) {
        @throw [NSException exceptionWithName:NSInvalidArgumentException
                                       reason:PGExceptionString(self, _cmd, @"Cannot add nil object.")
                                     userInfo:nil];
    }
    
    object = [object copy];
    PGRedBlackTreeNode *node = [self insertNodeWithObject:object];
    [object release];

    [self fixPropertiesAfterInsertionWithNode:node];
    [self setCount:_count + 1];
}


- (void)addObjectsFromArray:(NSArray *)array
{
    if (!array) return;
    for (id object in array) {
        [self addObject:object];
    }
}
    

- (PGRedBlackTreeNode *)insertNodeWithObject:(id)object
{
    // If the tree has no root, just make the new node the root
    if (!_root) {
        PGRedBlackTreeNode *newNode = PGRedBlackTreeNodeCreate(NULL, object);
        [self setRoot:newNode];
        return newNode;
    }
    
    // Otherwise, figure out where we're supposed to be based on the comparator
    PGRedBlackTreeNode *node = _root;
    while (true) {
        if (_comparator(object, node->object) < NSOrderedSame) {
            // If node has no left child, we've found where to insert our node
            if (PGRedBlackTreeNodeIsSentinel(node->leftChild)) {
                PGRedBlackTreeNode *newNode = PGRedBlackTreeNodeCreate(node, object);
                node->leftChild = newNode;
                return newNode;
            }
            
            node = node->leftChild;
            continue;
        }
        
        // If node has no right child, we've found where to insert our node
        if (PGRedBlackTreeNodeIsSentinel(node->rightChild)) {
            PGRedBlackTreeNode *newNode = PGRedBlackTreeNodeCreate(node, object);
            node->rightChild = newNode;
            return newNode;
        }
        
        node = node->rightChild;
    }
}


- (void)fixPropertiesAfterInsertionWithNode:(PGRedBlackTreeNode *)node
{
    while (true) {
        // Case 1: Node is the root, so make it black to fulfill Property 2 and we're done
        if (!node->parent) {
            node->isRed = NO;
            return;
        }
        
        // Case 2: If node's parent is black, we have inserted a red node between two blacks, and thus did not affect Property 5
        if (!node->parent->isRed) return;
        
        // Case 3: Parent is red. If our uncle is also red, we can set our grandparent to red, our parent and uncle to black,
        // and then fixup our grandparent
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
        
        // Case 4: Node and its parent are red; grandparent and uncle are black. If node is a right/left child and parent is
        // a left/right child, then we need to do a rotation and reset node and grandparent before moving on to case 5
        if (PGRedBlackTreeNodeIsRightChild(node) && PGRedBlackTreeNodeIsLeftChild(node->parent)) {
            PGRedBlackTreeNodeRotateLeftInTree(node->parent, self);
            node = node->leftChild;
            grandparent = node->parent->parent;
        } else if (PGRedBlackTreeNodeIsLeftChild(node) && PGRedBlackTreeNodeIsRightChild(node->parent)) {
            PGRedBlackTreeNodeRotateRightInTree(node->parent, self);
            node = node->rightChild;
            grandparent = node->parent->parent;
        }
        
        // Case 5: We are red, our parent is red, and our uncle is black. Make our parent black, make our grandparent red,
        // and do a rotation. Now everything should be fine.
        node->parent->isRed = NO;
        grandparent->isRed = YES;
        if (PGRedBlackTreeNodeIsLeftChild(node->parent)) {
            PGRedBlackTreeNodeRotateRightInTree(grandparent, self);
        } else {
            PGRedBlackTreeNodeRotateLeftInTree(grandparent, self);
        }
        
        return;
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
    return node ? PGRedBlackTreeNodeGetObject(node) : nil;
}


- (PGRedBlackTreeNode *)nodeForObject:(id)object
{
    if (!object || !_root) return NULL;
    __block PGRedBlackTreeNode *node = NULL;
    
    PGRedBlackTreeNodeTraverseSubnodesEqualToObject(_root, object, _comparator, ^(PGRedBlackTreeNode *candidateNode, BOOL *stop) {
        if (object == candidateNode->object || ([object hash] == [candidateNode->object hash] && [object isEqual:candidateNode->object])) {
            node = candidateNode;
            *stop = YES;
        }
    });
    
    
    return node;
}

#pragma mark - Removal

- (void)removeObject:(id)object
{
    // Note: this code is adapted from the pseudocode in CLRS.
    PGRedBlackTreeNode *node = [self nodeForObject:object];
    if (!node) return;
    
    PGRedBlackTreeNode *nodeToSpliceOut = node;
    
    // If neither child is a sentinel, we'll splice out either the node's predecessor or successor
    if (!PGRedBlackTreeNodeIsSentinel(node->leftChild) && !PGRedBlackTreeNodeIsSentinel(node->rightChild)) {
        // This fun bit of code simply changes up whether a predecessor or successor is the node we splice out. The reason
        // we do this is because it supposedly leads to a more balanced tree as time goes on. If the node we're removing is
        // the left child, we try to get the successor, and if that doesn't work, we get the predecessor. If it's the right
        // child (or doesn't have a parent), we do the opposite.
        if (PGRedBlackTreeNodeIsLeftChild(node)) {
            nodeToSpliceOut = PGRedBlackTreeNodeSuccessor(node);
            if (!nodeToSpliceOut) nodeToSpliceOut = PGRedBlackTreeNodePredecessor(node);
        } else {
            nodeToSpliceOut = PGRedBlackTreeNodePredecessor(node);
            if (!nodeToSpliceOut) nodeToSpliceOut = PGRedBlackTreeNodeSuccessor(node);
        }
    }
    
    // Pick the non-sentinel child of the node to splice out
    PGRedBlackTreeNode *child = PGRedBlackTreeNodeIsSentinel(nodeToSpliceOut->leftChild) ? nodeToSpliceOut->rightChild : nodeToSpliceOut->leftChild;

    // If the node we're splicing out has no non-sentinel children, fix properties with the node itself
    // before removing it. If we do this later, our parent pointers will be messed up
    if (!nodeToSpliceOut->isRed && PGRedBlackTreeNodeIsSentinel(child)) {
        [self fixPropertiesAfterRemovalWithNode:nodeToSpliceOut];
    }

    // If the child of the node we're splicing out isn't a sentinel, set its parent to its grandparent
    if (!PGRedBlackTreeNodeIsSentinel(child)) {
        child->parent = nodeToSpliceOut->parent;
    }
    
    // If the node we're removing is the root, set the root to the child
    if (!nodeToSpliceOut->parent) {
        _root = PGRedBlackTreeNodeIsSentinel(child) ? NULL : child;
    } else if (PGRedBlackTreeNodeIsLeftChild(nodeToSpliceOut)) {
        nodeToSpliceOut->parent->leftChild = child;
    } else {
        nodeToSpliceOut->parent->rightChild = child;
    }

    // If we're not the node to splice out, 
    if (node != nodeToSpliceOut) {
        PGRedBlackTreeNodeSetObject(node, nodeToSpliceOut->object);
    }
    
    if (!nodeToSpliceOut->isRed && !PGRedBlackTreeNodeIsSentinel(child)) {
        [self fixPropertiesAfterRemovalWithNode:child];
    }

    PGRedBlackTreeNodeFree(nodeToSpliceOut, NO);
    [self setCount:_count - 1];
}


- (void)fixPropertiesAfterRemovalWithNode:(PGRedBlackTreeNode *)node
{
    // Note: this code is adapted from the pseudocode in CLRS.
    while (node != _root && !node->isRed) {
        if (PGRedBlackTreeNodeIsLeftChild(node)) {
            PGRedBlackTreeNode *sibling = node->parent->rightChild;
            if (sibling->isRed) {
                sibling->isRed = NO;
                node->parent->isRed = YES;
                PGRedBlackTreeNodeRotateLeftInTree(node->parent, self);
                sibling = node->parent->rightChild;
            }
            
            if (!sibling->leftChild->isRed && !sibling->rightChild->isRed) {
                sibling->isRed = YES;
                node = node->parent;
                continue;
            }
            
            if (!sibling->rightChild->isRed) {
                sibling->leftChild->isRed = NO;
                sibling->isRed = YES;
                PGRedBlackTreeNodeRotateRightInTree(sibling, self);
                sibling = node->parent->rightChild;
            }
            
            sibling->isRed = node->parent->isRed;
            node->parent->isRed = NO;
            sibling->rightChild->isRed = NO;
            PGRedBlackTreeNodeRotateLeftInTree(node->parent, self);
            node = _root;
        } else {
            PGRedBlackTreeNode *sibling = node->parent->leftChild;
            if (sibling->isRed) {
                sibling->isRed = NO;
                node->parent->isRed = YES;
                PGRedBlackTreeNodeRotateRightInTree(node->parent, self);
                sibling = node->parent->leftChild;
            }
            
            if (!sibling->leftChild->isRed && !sibling->rightChild->isRed) {
                sibling->isRed = YES;
                node = node->parent;
                continue;
            }
            
            if (!sibling->leftChild->isRed) {
                sibling->rightChild->isRed = NO;
                sibling->isRed = YES;
                PGRedBlackTreeNodeRotateLeftInTree(sibling, self);
                sibling = node->parent->leftChild;
            }
            
            sibling->isRed = node->parent->isRed;
            node->parent->isRed = NO;
            sibling->leftChild->isRed = NO;
            PGRedBlackTreeNodeRotateRightInTree(node->parent, self);
            node = _root;
        }
        
    }

    node->isRed = NO;
}


- (void)removeAllObjects
{
    if (!_root) return;
    PGRedBlackTreeNodeFree(_root, YES);
    _root = nil;
    [self setCount:0];
}


#pragma mark - Enumeration

- (void)enumerateObjectsUsingBlock:(void (^)(id, BOOL *))block
{
    if (!block) {
        @throw [NSException exceptionWithName:NSInvalidArgumentException
                                       reason:PGExceptionString(self, _cmd, @"Cannot enumerate using nil block.")
                                     userInfo:nil];
    }
    
    if (!_root) return;
    PGRedBlackTreeNodeTraverseSubnodesWithBlock(_root, ^(PGRedBlackTreeNode *node, BOOL *stop) { block(node->object, stop); });
}


- (void)enumerateObjectsLessThanObject:(id)object usingBlock:(void (^)(id, BOOL *))block
{
    if (!block) {
        @throw [NSException exceptionWithName:NSInvalidArgumentException
                                       reason:PGExceptionString(self, _cmd, @"Cannot enumerate using nil block.")
                                     userInfo:nil];
    }

    if (!_root) return;
    PGRedBlackTreeNodeTraverseSubnodesWithBlock(_root, ^(PGRedBlackTreeNode *node, BOOL *stop) {
        NSComparisonResult result = _comparator(node->object, object);
        if (result >= NSOrderedSame) {
            *stop = YES;
            return;
        }
        
        block(node->object, stop);
    });
}


- (void)enumerateObjectsLessThanOrEqualToObject:(id)object usingBlock:(void (^)(id, BOOL *))block
{
    if (!block) {
        @throw [NSException exceptionWithName:NSInvalidArgumentException
                                       reason:PGExceptionString(self, _cmd, @"Cannot enumerate using nil block.")
                                     userInfo:nil];
    }

    if (!_root) return;
    PGRedBlackTreeNodeTraverseSubnodesWithBlock(_root, ^(PGRedBlackTreeNode *node, BOOL *stop) {
        if (_comparator(node->object, object) > NSOrderedSame) {
            *stop = YES;
            return;
        }
        
        block(node->object, stop);
    });
}


- (void)enumerateObjectsEqualToObject:(id)object usingBlock:(void (^)(id, BOOL *))block
{
    if (!block) {
        @throw [NSException exceptionWithName:NSInvalidArgumentException
                                       reason:PGExceptionString(self, _cmd, @"Cannot enumerate using nil block.")
                                     userInfo:nil];
    }

    if (!_root) return;
    PGRedBlackTreeNodeTraverseSubnodesEqualToObject(_root, object, _comparator, ^(PGRedBlackTreeNode *n, BOOL *s) { block(n->object, s); });
}


- (void)enumerateObjectsGreaterThanOrEqualToObject:(id)object usingBlock:(void (^)(id, BOOL *))block
{
    if (!block) {
        @throw [NSException exceptionWithName:NSInvalidArgumentException
                                       reason:PGExceptionString(self, _cmd, @"Cannot enumerate using nil block.")
                                     userInfo:nil];
    }

    if (!_root) return;
    PGRedBlackTreeNodeTraverseSubnodesGreaterThanOrEqualToObject(_root, object, _comparator, ^(PGRedBlackTreeNode *n, BOOL *s) { block(n->object, s); });
}


- (void)enumerateObjectsGreaterThanObject:(id)object usingBlock:(void (^)(id, BOOL *))block
{
    if (!block) {
        @throw [NSException exceptionWithName:NSInvalidArgumentException
                                       reason:PGExceptionString(self, _cmd, @"Cannot enumerate using nil block.")
                                     userInfo:nil];
    }

    if (!_root) return;
    PGRedBlackTreeNodeTraverseSubnodesGreaterThanObject(_root, object, _comparator, ^(PGRedBlackTreeNode *n, BOOL *s) { block(n->object, s); });
}


#pragma mark - Getting objects with specific properties

- (NSArray *)objectsPassingTest:(BOOL (^)(id, BOOL *))predicate
{
    if (!predicate) {
        @throw [NSException exceptionWithName:NSInvalidArgumentException
                                       reason:PGExceptionString(self, _cmd, @"Cannot test using nil predicate.")
                                     userInfo:nil];
    }

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
    while (!PGRedBlackTreeNodeIsSentinel(node->leftChild)) {
        node = node->leftChild;
    }
    
    return PGRedBlackTreeNodeGetObject(node);
}


- (id)lastObject
{
    if (!_root) return nil;
    PGRedBlackTreeNode *node = _root;
    while (!PGRedBlackTreeNodeIsSentinel(node->rightChild)) {
        node = node->rightChild;
    }
    
    return PGRedBlackTreeNodeGetObject(node);
}


- (NSArray *)allObjects
{
    __block NSMutableArray *objects = [[NSMutableArray alloc] initWithCapacity:_count];
    
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



#pragma mark - Test helpers

@implementation PGRedBlackTree (PropertyVerification)

- (BOOL)fulfillsProperties
{
    PGRedBlackTreeNode *node = _root;
    if (!node) return YES;
    
    // Keep going left until you find a leaf
    while (!PGRedBlackTreeNodeIsSentinel(node->leftChild)) {
        node = node->leftChild;
    }
    
    // If we didn't have a left child, check the right subtree for a leaf
    if (node == _root) {
        while (!PGRedBlackTreeNodeIsSentinel(node->rightChild)) {
            node = node->rightChild;
        }
    }
    
    return PGRedBlackTreeNodeFulfillsProperties(_root, _comparator, PGRedBlackTreeNodeBlackNodeCountInPathFromNodeToRoot(node));
}

@end