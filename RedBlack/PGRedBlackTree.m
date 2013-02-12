//
//  PGRedBlackTree.m
//  RedBlack
//
//  Created by Prachi Gauriar on 2/10/2013.
//  Copyright (c) 2013 Prachi Gauriar. All rights reserved.
//

#import "PGRedBlackTree.h"


#pragma mark Tree node interface

@interface PGRedBlackTreeNode : NSObject

@property(readwrite, assign, getter = isRed) BOOL red;
@property(readwrite, weak) PGRedBlackTreeNode *parent;
@property(readwrite, retain) PGRedBlackTreeNode *leftChild;
@property(readwrite, retain) PGRedBlackTreeNode *rightChild;
@property(readwrite, retain) id object;

+ (PGRedBlackTreeNode *)sentinelNodeWithParent:(PGRedBlackTreeNode *)parent;

- (id)initWithParent:(PGRedBlackTreeNode *)parent object:(id)object;

- (BOOL)isSentinel;
- (BOOL)isLeftChild;
- (BOOL)isRightChild;

- (PGRedBlackTreeNode *)grandparent;
- (PGRedBlackTreeNode *)uncle;
- (PGRedBlackTreeNode *)sibling;

- (void)rotateLeftInTree:(PGRedBlackTree *)tree;
- (void)rotateRightInTree:(PGRedBlackTree *)tree;

- (BOOL)traverseSubnodesWithBlock:(void (^)(id, BOOL *))block;
- (BOOL)traverseSubnodesEqualToObject:(id)object usingComparator:(NSComparator)comparator withBlock:(void (^)(id, BOOL *))block;
- (BOOL)traverseSubnodesGreaterThanOrEqualToObject:(id)object usingComparator:(NSComparator)comparator withBlock:(void (^)(id, BOOL *))block;
- (BOOL)traverseSubnodesGreaterThanObject:(id)object usingComparator:(NSComparator)comparator withBlock:(void (^)(id, BOOL *))block;

@end


#pragma mark - Tree private interface

@interface PGRedBlackTree ()

@property(readwrite, retain) PGRedBlackTreeNode *root;
@property(readwrite, copy) NSComparator comparator;
@property(readwrite, assign) NSUInteger count;

- (PGRedBlackTreeNode *)insertNodeWithObject:(id)object;
- (void)fixUpTreeInvariantsAfterInsertingNode:(PGRedBlackTreeNode *)node;

- (NSArray *)enumeratedObjectsWithSelector:(SEL)selector object:(id)object;

@end


#pragma mark - Tree implementation

@implementation PGRedBlackTree

+ (PGRedBlackTree *)treeWithSelector:(SEL)comparator
{
    return [[self alloc] initWithSelector:comparator];
}


+ (PGRedBlackTree *)treeWithComparator:(NSComparator)comparator
{
    return [[self alloc] initWithComparator:comparator];
}


- (id)initWithSelector:(SEL)selector
{
    return [self initWithComparator:^NSComparisonResult(id object1, id object2) {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
        return (NSComparisonResult)[object1 performSelector:selector withObject:object2];
#pragma clang diagnostic pop
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


- (NSString *)debugDescription
{
    return [_root debugDescription];
}


#pragma mark - Insertion

- (void)addObject:(id <NSCopying>)object
{
    NSAssert(object != nil, @"Attempted to insert a nil object");
    PGRedBlackTreeNode *node = [self insertNodeWithObject:[object copyWithZone:nil]];
    [self fixUpTreeInvariantsAfterInsertingNode:node];
    ++self.count;
}
    

- (PGRedBlackTreeNode *)insertNodeWithObject:(id)object
{
    // If the tree has no root, just make the new node the root
    if (!_root) {
        PGRedBlackTreeNode *newNode = [[PGRedBlackTreeNode alloc] initWithParent:nil object:object];
        newNode.leftChild = [PGRedBlackTreeNode sentinelNodeWithParent:nil];
        newNode.rightChild = [PGRedBlackTreeNode sentinelNodeWithParent:nil];
        self.root = newNode;
        return newNode;
    }
    
    // Otherwise, figure out where we're supposed to be based on the comparator
    PGRedBlackTreeNode *node = _root;
    while (true) {
        if (_comparator(object, node.object) == NSOrderedAscending) {
            PGRedBlackTreeNode *leftChild = node.leftChild;
            
            // If left child is a sentinel, we've found where to insert our node. Reuse the sentinel as one of ours
            if ([leftChild isSentinel]) {
                PGRedBlackTreeNode *newNode = [[PGRedBlackTreeNode alloc] initWithParent:node object:object];
                node.leftChild = newNode;

                newNode.leftChild = leftChild;
                leftChild.parent = newNode;

                newNode.rightChild = [PGRedBlackTreeNode sentinelNodeWithParent:node];
                return newNode;
            }
            
            node = node.leftChild;
            continue;
        }
        
        PGRedBlackTreeNode *rightChild = node.rightChild;
        
        // If right child is a sentinel, we've found where to insert our node. Reuse the sentinel as one of ours
        if ([rightChild isSentinel]) {
            PGRedBlackTreeNode *newNode = [[PGRedBlackTreeNode alloc] initWithParent:node object:object];
            node.rightChild = newNode;

            newNode.rightChild = rightChild;
            rightChild.parent = newNode;
            
            newNode.leftChild = [PGRedBlackTreeNode sentinelNodeWithParent:node];
            return newNode;
        }
        
        node = node.rightChild;
    }
}


- (void)fixUpTreeInvariantsAfterInsertingNode:(PGRedBlackTreeNode *)node
{
    while (true) {
        PGRedBlackTreeNode *parent = node.parent;
        if (!parent) {
            // Case 1 - Node is the root
            node.red = NO;
            break;
        } else if (![parent isRed]) {
            // Case 2 - If node's parent is black, because we inserted a red between two blacks, and thus did not change the total
            // number of black nodes between the root and its leaf nodes
            break;
        }
        
        // Case 3 - Parent and uncle are red. Set the grandparent to red, parent and uncle to black, and fixup the grandparent
        PGRedBlackTreeNode *grandparent = node.grandparent;
        PGRedBlackTreeNode *uncle = node.uncle;
        if ([uncle isRed]) {
            parent.red = NO;
            uncle.red = NO;
            grandparent.red = YES;
            node = grandparent;
            continue;
        }
        
        // Case 4 - Node and its parent are red; grandparent and uncle are black. Before we can make node and its parent alternating colors,
        // we need to rotate underst certain circumstances
        if ([node isRightChild] && [parent isLeftChild]) {
            [parent rotateLeftInTree:self];
            node = node.leftChild;
            parent = node.parent;
            grandparent = node.grandparent;
        } else if ([node isLeftChild] && [parent isRightChild]) {
            [parent rotateRightInTree:self];
            node = node.rightChild;
            parent = node.parent;
            grandparent = node.grandparent;
        }
        
        // Case 5 - We need to make sure that we and our parent aren't the same color using some rotation magic
        parent.red = NO;
        grandparent.red = YES;
        if ([parent isLeftChild]) {
            [grandparent rotateRightInTree:self];
        } else {
            [grandparent rotateLeftInTree:self];
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
    if (!object) return nil;
    
    PGRedBlackTreeNode *node = self.root;
    while (node && !node.isSentinel) {
        id nodeObject = node.object;
        NSComparisonResult comparisonResult = self.comparator(object, nodeObject);
        
        if (comparisonResult == NSOrderedAscending) {
            node = node.leftChild;
            continue;
        }
        
        if (comparisonResult == NSOrderedSame && [object hash] == [nodeObject hash] && [object isEqual:nodeObject]) {
            return nodeObject;
        }
        
        node = node.rightChild;
    }
    
    return nil;
}


#pragma mark - Enumeration

- (void)enumerateObjectsUsingBlock:(void (^)(id, BOOL *))block
{
    [_root traverseSubnodesWithBlock:block];
}


- (void)enumerateObjectsLessThanObject:(id)object usingBlock:(void (^)(id, BOOL *))block
{
    [_root traverseSubnodesWithBlock:^(id obj, BOOL *stop) {
        if (_comparator(obj, object) >= NSOrderedSame) {
            *stop = YES;
            return;
        }
        
        block(obj, stop);
    }];
}


- (void)enumerateObjectsLessThanOrEqualToObject:(id)object usingBlock:(void (^)(id, BOOL *))block
{
    [_root traverseSubnodesWithBlock:^(id obj, BOOL *stop) {
        if (_comparator(obj, object) > NSOrderedSame) {
            *stop = YES;
            return;
        }
        
        block(obj, stop);
    }];
}


- (void)enumerateObjectsEqualToObject:(id)object usingBlock:(void (^)(id, BOOL *))block
{
    [_root traverseSubnodesEqualToObject:object usingComparator:_comparator withBlock:block];
}


- (void)enumerateObjectsGreaterThanOrEqualToObject:(id)object usingBlock:(void (^)(id, BOOL *))block
{
    [_root traverseSubnodesGreaterThanOrEqualToObject:object usingComparator:_comparator withBlock:block];
}


- (void)enumerateObjectsGreaterThanObject:(id)object usingBlock:(void (^)(id, BOOL *))block
{
    [_root traverseSubnodesGreaterThanObject:object usingComparator:_comparator withBlock:block];
}


#pragma mark - Returning objects with specific properties

- (NSArray *)objectsPassingTest:(BOOL (^)(id, BOOL *))predicate
{
    __block NSMutableArray *objects = [[NSMutableArray alloc] init];
    
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
    while (true) {
        PGRedBlackTreeNode *leftChild = node.leftChild;
        if ([leftChild isSentinel]) {
            return node.object;
        }
        
        node = leftChild;
    }
}


- (id)lastObject
{
    if (!_root) return nil;
    
    PGRedBlackTreeNode *node = _root;
    while (true) {
        PGRedBlackTreeNode *rightChild = node.rightChild;
        if ([rightChild isSentinel]) {
            return node.object;
        }
        
        node = rightChild;
    }
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
    __block NSMutableArray *objects = [[NSMutableArray alloc] init];

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


#pragma mark - Tree node implementation

@implementation PGRedBlackTreeNode

+ (PGRedBlackTreeNode *)sentinelNodeWithParent:(PGRedBlackTreeNode *)parent
{
    PGRedBlackTreeNode *node = [[self alloc] initWithParent:parent object:nil];
    node.red = NO;
    return node;
}


- (id)init
{
    [self doesNotRecognizeSelector:_cmd];
    return nil;
}


- (id)initWithParent:(PGRedBlackTreeNode *)parent object:(id)object
{
    self = [super init];
    if (self) {
        self.parent = parent;
        self.object = object;
        self.red = YES;
    }
    
    return self;
}


- (NSString *)debugDescription
{
    if ([self isSentinel]) {
        return @"<node sentinel=\"true\" />\n";
    }
    
    NSMutableString *description = [NSMutableString stringWithFormat:@"<node color=\"%@\">\n", [self isRed] ? @"red" : @"black"];
    [description appendString:@"<left>\n"];
    [description appendString:[_leftChild debugDescription]];
    [description appendString:@"</left>\n"];
    
    [description appendString:@"<object>"];
    [description appendString:[_object debugDescription]];
    [description appendString:@"</object>\n"];

    [description appendString:@"<right>\n"];
    [description appendString:[_rightChild debugDescription]];
    [description appendString:@"</right>\n"];
    
    [description appendString:@"</node>\n"];

    return description;
}


#pragma mark - Node types

- (BOOL)isSentinel
{
    return _object == nil;
}


- (BOOL)isLeftChild
{
    return _parent && self == _parent.leftChild;
}


- (BOOL)isRightChild
{
    return _parent && self == _parent.rightChild;
}


#pragma mark - Relationships

- (PGRedBlackTreeNode *)grandparent
{
    return _parent.parent;
}


- (PGRedBlackTreeNode *)uncle
{
    PGRedBlackTreeNode *grandparent = self.grandparent;
    return [_parent isLeftChild] ? grandparent.rightChild : grandparent.leftChild;
}


- (PGRedBlackTreeNode *)sibling
{
    return [self isLeftChild] ? _parent.rightChild : _parent.leftChild;
}


#pragma mark - Rotation

- (void)rotateLeftInTree:(PGRedBlackTree *)tree
{
    // Other starts off as our right child. We will end up as its left child, and its left child will become our right one
    PGRedBlackTreeNode *other = _rightChild;
    
    // Set other's left child as our right and set ourself as its parent
    self.rightChild = other.leftChild;
    if (_rightChild) {
        _rightChild.parent = self;
    }
    
    // Set other's parent to our parent
    other.parent = _parent;
    
    // If we were the root of the tree, make other the root of the tree. Otherwise, if we were the right child, make other
    // the right child. If we were the left child, make it the left
    if (!other.parent) {
        tree.root = other;
    } else if ([self isLeftChild]) {
        _parent.leftChild = other;
    } else {
        _parent.rightChild = other;
    }
    
    // Finally, set ourself as other's right child and it as our parent
    other.leftChild = self;
    self.parent = other;
}


- (void)rotateRightInTree:(PGRedBlackTree *)tree
{
    // Other starts off as our left child. We will end up as its right child, and its right child will become our left one
    PGRedBlackTreeNode *other = _leftChild;
    
    // Set other's right child as our left and set ourself as its parent
    self.leftChild = other.rightChild;
    if (_leftChild) {
        _leftChild.parent = self;
    }
    
    // Set other's parent to our parent
    other.parent = _parent;
    
    // If we were the root of the tree, make other the root of the tree. Otherwise, if we were the right child, make other
    // the right child. If we were the left child, make it the left
    if (!other.parent) {
        tree.root = other;
    } else if ([self isLeftChild]) {
        _parent.leftChild = other;
    } else {
        _parent.rightChild = other;
    }
    
    // Finally, set ourself as other's right child and it as our parent
    other.rightChild = self;
    self.parent = other;
}


#pragma mark - Traversal

- (BOOL)traverseSubnodesWithBlock:(void (^)(id object, BOOL *stop))block
{
    if ([self isSentinel]) return NO;

    PGRedBlackTreeNode *node = self;
    BOOL stop = NO;

    // Go as far left as we can
    while (![node.leftChild isSentinel]) {
        node = node.leftChild;
    }
    
    // Keep traversing as long as we haven't backed up past the root of this subtree, i.e., self
    while (node != _parent) {
        // Execute the block on the node's object. If the block told us to stop traversing, stop.
        block(node.object, &stop);
        if (stop) return YES;
        
        // If the current node has a right child, go right one and then go left as far as we can before continuing
        if (![node.rightChild isSentinel]) {
            node = node.rightChild;
            
            while (![node.leftChild isSentinel]) {
                node = node.leftChild;
            }
            
            continue;
        }
        
        // Otherwise, keep going back up until we either hit the root (self) or we're no longer the right child
        while (node != self && [node isRightChild]) {
            node = node.parent;
        }
        
        node = node.parent;
    }
    
    return NO;
}


- (BOOL)traverseSubnodesEqualToObject:(id)object usingComparator:(NSComparator)comparator withBlock:(void (^)(id, BOOL *))block
{
    if ([self isSentinel]) return NO;
    
    BOOL stop = NO;
    NSComparisonResult result = comparator(_object, object);
    if (result == NSOrderedAscending) {
        // self.object < object, so we only need to check the right subtree
        return [_rightChild traverseSubnodesEqualToObject:object usingComparator:comparator withBlock:block];
    } else if (result == NSOrderedSame) {
        // If they're equal, we have to check both directions
        stop = [_leftChild traverseSubnodesEqualToObject:object usingComparator:comparator withBlock:block];
        if (stop) return YES;
        
        block(_object, &stop);
        if (stop) return YES;
        
        return [_rightChild traverseSubnodesEqualToObject:object usingComparator:comparator withBlock:block];
    } else if (result == NSOrderedDescending) {
        // self.object > object, so we only need to consider the left subtree
        return [_leftChild traverseSubnodesEqualToObject:object usingComparator:comparator withBlock:block];
    }
    
    return NO;
}


- (BOOL)traverseSubnodesGreaterThanOrEqualToObject:(id)object usingComparator:(NSComparator)comparator withBlock:(void (^)(id, BOOL *))block
{
    if ([self isSentinel]) return NO;

    BOOL stop = NO;
    NSComparisonResult result = comparator(_object, object);
    if (result == NSOrderedAscending) {
        // self.object < object, so we only need to check the right subtree
        return [_rightChild traverseSubnodesGreaterThanOrEqualToObject:object usingComparator:comparator withBlock:block];
    } else if (result == NSOrderedSame) {
        // If they're equal, we have to check both directions
        stop = [_leftChild traverseSubnodesGreaterThanOrEqualToObject:object usingComparator:comparator withBlock:block];
        if (stop) return YES;

        block(_object, &stop);
        if (stop) return YES;

        return [_rightChild traverseSubnodesGreaterThanOrEqualToObject:object usingComparator:comparator withBlock:block];
    } else if (result == NSOrderedDescending) {
        // self.object > object, so we need to check the left subtree, but we and our right subtree need to be traversed no matter what
        stop = [_leftChild traverseSubnodesGreaterThanOrEqualToObject:object usingComparator:comparator withBlock:block];
        if (stop) return YES;
        
        block(_object, &stop);
        if (stop) return YES;
        
        return [_rightChild traverseSubnodesWithBlock:block];
    }

    return NO;
}


- (BOOL)traverseSubnodesGreaterThanObject:(id)object usingComparator:(NSComparator)comparator withBlock:(void (^)(id, BOOL *))block
{
    if ([self isSentinel]) return NO;
    
    BOOL stop = NO;
    NSComparisonResult result = comparator(_object, object);
    if (result == NSOrderedAscending || result == NSOrderedSame) {
        // self.object < object, so we only need to check the right subtree
        return [_rightChild traverseSubnodesGreaterThanObject:object usingComparator:comparator withBlock:block];
    } else if (result == NSOrderedDescending) {
        // self.object > object, so we need to check the left subtree, but we and our right subtree need to be traversed no matter what
        stop = [_leftChild traverseSubnodesGreaterThanObject:object usingComparator:comparator withBlock:block];
        if (stop) return YES;
        
        block(_object, &stop);
        if (stop) return YES;
        
        return [_rightChild traverseSubnodesWithBlock:block];
    }
    
    return NO;
}


@end
