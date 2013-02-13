//
//  PGRedBlackTreeNode.m
//  RedBlack
//
//  Created by Prachi Gauriar on 2/13/2013.
//  Copyright (c) 2013 Prachi Gauriar. All rights reserved.
//

#import "PGRedBlackTreeNode.h"
#import "PGRedBlackTree.h"


@interface PGRedBlackTree (PrivateAccessors)
- (void)setRoot:(PGRedBlackTreeNode *)root;
@end


PGRedBlackTreeNode *PGRedBlackTreeNodeCreate(PGRedBlackTreeNode *parent, id object)
{
    PGRedBlackTreeNode *self = calloc(1, sizeof(struct _PGRedBlackTreeNode));
    if (self) {
        self->parent = parent;
        self->object = [object retain];
        self->isRed = YES;
    }
    
    return self;
}


void PGRedBlackTreeNodeFree(PGRedBlackTreeNode *self)
{
    [self->object release];
    if (self->leftChild) PGRedBlackTreeNodeFree(self->leftChild);

    // All this saving the right child business is to enable tail recursion
    PGRedBlackTreeNode *rightChild = self->rightChild;
    free(self);
    if (rightChild) PGRedBlackTreeNodeFree(rightChild);
}


static NSString *PGRedBlackTreeNodeIndentString(NSUInteger indentDepth)
{
    if (indentDepth == 0) return @"";
    
    NSMutableString *string = [NSMutableString stringWithCapacity:indentDepth * 2];
    
    while (indentDepth--) {
        [string appendString:@"  "];
    }
    
    return string;
}


NSString *PGRedBlackTreeNodeAppendDebugDescription(PGRedBlackTreeNode *self, NSMutableString *description, NSUInteger indentDepth)
{
    [description appendFormat:@"<node color=\"%@\">\n", self->isRed ? @"red" : @"black"];
    
    NSString *indentPlus1String = PGRedBlackTreeNodeIndentString(indentDepth + 1);
    NSString *indentPlus2String = PGRedBlackTreeNodeIndentString(indentDepth + 2);

    [description appendString:indentPlus1String];
    [description appendString:@"<left>\n"];

    [description appendString:indentPlus2String];
    if (self->leftChild) {
        PGRedBlackTreeNodeAppendDebugDescription(self->leftChild, description, indentDepth + 2);
    } else {
        [description appendString:@"<node color=\"black\" sentinel=\"true\" />\n"];
    }

    [description appendString:indentPlus1String];
    [description appendString:@"</left>\n"];

    [description appendString:indentPlus1String];
    [description appendString:@"<object>"];
    [description appendString:[self->object debugDescription]];
    [description appendString:@"</object>\n"];

    [description appendString:indentPlus1String];
    [description appendString:@"<right>\n"];

    [description appendString:indentPlus2String];
    if (self->rightChild) {
        PGRedBlackTreeNodeAppendDebugDescription(self->rightChild, description, indentDepth + 2);
    } else {
        [description appendString:@"<node color=\"black\" sentinel=\"true\" />\n"];
    }

    [description appendString:indentPlus1String];
    [description appendString:@"</right>\n"];
    
    [description appendString:PGRedBlackTreeNodeIndentString(indentDepth)];
    [description appendString:@"</node>\n"];
    
    return description;
}


PGRedBlackTreeNode *PGRedBlackTreeNodeInOrderPredecessor(PGRedBlackTreeNode *self)
{
    if (!self->leftChild) return NULL;
    
    PGRedBlackTreeNode *node = self->leftChild;
    while (node->rightChild) {
        node = node->rightChild;
    }
    
    return node;
}


PGRedBlackTreeNode *PGRedBlackTreeNodeInOrderSuccessor(PGRedBlackTreeNode *self)
{
    if (!self->rightChild) return NULL;
    
    PGRedBlackTreeNode *node = self->rightChild;
    while (node->leftChild) {
        node = node->leftChild;
    }
    
    return node;
}


void PGRedBlackTreeNodeRotateLeftInTree(PGRedBlackTreeNode *self, PGRedBlackTree *tree)
{
    // Other starts off as our right child. We will end up as its left child, and its left child will become our right one
    PGRedBlackTreeNode *other = self->rightChild;

    // Set other's left child as our right and set ourself as its parent
    self->rightChild = other->leftChild;
    if (self->rightChild) {
        self->rightChild->parent = self;
    }

    // Set other's parent to our parent
    other->parent = self->parent;

    // If we were the root of the tree, make other the root of the tree. Otherwise, if we were the right child, make other
    // the right child. If we were the left child, make it the left
    if (!other->parent) {
        [tree setRoot:other];
    } else if (PGRedBlackTreeNodeIsLeftChild(self)) {
        self->parent->leftChild = other;
    } else {
        self->parent->rightChild = other;
    }

    // Finally, set ourself as other's right child and it as our parent
    other->leftChild = self;
    self->parent = other;
}


void PGRedBlackTreeNodeRotateRightInTree(PGRedBlackTreeNode *self, PGRedBlackTree *tree)
{
    // Other starts off as our left child. We will end up as its right child, and its right child will become our left one
    PGRedBlackTreeNode *other = self->leftChild;

    // Set other's right child as our left and set ourself as its parent
    self->leftChild = other->rightChild;
    if (self->leftChild) {
        self->leftChild->parent = self;
    }

    // Set other's parent to our parent
    other->parent = self->parent;

    // If we were the root of the tree, make other the root of the tree. Otherwise, if we were the right child, make other
    // the right child. If we were the left child, make it the left
    if (!other->parent) {
        [tree setRoot:other];
    } else if (PGRedBlackTreeNodeIsLeftChild(self)) {
        self->parent->leftChild = other;
    } else {
        self->parent->rightChild = other;
    }

    // Finally, set ourself as other's right child and it as our parent
    other->rightChild = self;
    self->parent = other;
}


BOOL PGRedBlackTreeNodeTraverseSubnodesWithBlock(PGRedBlackTreeNode *self, void (^block)(id, BOOL *))
{
    PGRedBlackTreeNode *node = self;
    BOOL stop = NO;

    // Go as far left as we can
    while (node->leftChild) {
        node = node->leftChild;
    }

    // Keep traversing as long as we haven't backed up past the root of this subtree, i.e., self
    while (node && node != self->parent) {
        // Execute the block on the node's object. If the block told us to stop traversing, stop.
        block(node->object, &stop);
        if (stop) return YES;

        // If the current node has a right child, go right one and then go left as far as we can before continuing
        if (node->rightChild) {
            node = node->rightChild;

            while (node->leftChild) {
                node = node->leftChild;
            }

            continue;
        }

        // Otherwise, keep going back up until we either hit the root (self) or we're no longer the right child
        while (node != self && PGRedBlackTreeNodeIsRightChild(node)) {
            node = node->parent;
        }

        node = node->parent;
    }

    return NO;
}


BOOL PGRedBlackTreeNodeTraverseSubnodesEqualToObject(PGRedBlackTreeNode *self, id object, NSComparator comparator, void (^block)(id, BOOL *))
{
    BOOL stop = NO;
    NSComparisonResult result = comparator(self->object, object);

    // self->object < object, so we only need to check the right subtree
    if (result < NSOrderedSame) {
        return self->rightChild ? PGRedBlackTreeNodeTraverseSubnodesEqualToObject(self->rightChild, object, comparator, block) : NO;
    }
    
    // self->object == object, so we have to check both directions
    if (result == NSOrderedSame) {
        if (self->leftChild) {
            stop = PGRedBlackTreeNodeTraverseSubnodesEqualToObject(self->leftChild, object, comparator, block);
            if (stop) return YES;
        }

        block(self->object, &stop);
        if (stop) return YES;

        return self->rightChild ? PGRedBlackTreeNodeTraverseSubnodesEqualToObject(self->rightChild, object, comparator, block) : NO;
    }
    
    // self->object > object, so we only need to consider the left subtree
    return self->leftChild ? PGRedBlackTreeNodeTraverseSubnodesEqualToObject(self->leftChild, object, comparator, block) : NO;
}


BOOL PGRedBlackTreeNodeTraverseSubnodesGreaterThanOrEqualToObject(PGRedBlackTreeNode *self, id object, NSComparator comparator, void (^block)(id, BOOL *))
{
    BOOL stop = NO;
    NSComparisonResult result = comparator(self->object, object);

    // self->object < object, so we only need to check the right subtree
    if (result < NSOrderedSame) {
        return self->rightChild ? PGRedBlackTreeNodeTraverseSubnodesGreaterThanOrEqualToObject(self->rightChild, object, comparator, block) : NO;
    }
    
    // self->object == object, so we have to check both directions
    if (result == NSOrderedSame) {
        if (self->leftChild) {
            stop = PGRedBlackTreeNodeTraverseSubnodesGreaterThanOrEqualToObject(self->leftChild, object, comparator, block);
            if (stop) return YES;
        }

        block(self->object, &stop);
        if (stop) return YES;

        return self->rightChild ? PGRedBlackTreeNodeTraverseSubnodesGreaterThanOrEqualToObject(self->rightChild, object, comparator, block) : NO;
    }
    
    // self->object > object, so we need to check the left subtree, but we and our right subtree need to be traversed no matter what
    if (self->leftChild) {
        stop = PGRedBlackTreeNodeTraverseSubnodesGreaterThanOrEqualToObject(self->leftChild, object, comparator, block);
        if (stop) return YES;
    }
    
    block(self->object, &stop);
    if (stop) return YES;
    
    return self->rightChild ? PGRedBlackTreeNodeTraverseSubnodesWithBlock(self->rightChild, block) : NO;
}


BOOL PGRedBlackTreeNodeTraverseSubnodesGreaterThanObject(PGRedBlackTreeNode *self, id object, NSComparator comparator, void (^block)(id, BOOL *))
{
    BOOL stop = NO;
    NSComparisonResult result = comparator(self->object, object);
    if (result <= NSOrderedSame) {
        // self->object < object, so we only need to check the right subtree
        return self->rightChild ? PGRedBlackTreeNodeTraverseSubnodesGreaterThanObject(self->rightChild, object, comparator, block) : NO;
    }
    
    
    // self.object > object, so we need to check the left subtree, but we and our right subtree need to be traversed no matter what
    if (self->leftChild) {
        stop = PGRedBlackTreeNodeTraverseSubnodesGreaterThanObject(self->leftChild, object, comparator, block);
        if (stop) return YES;
    }
    
    block(self->object, &stop);
    if (stop) return YES;
    
    return self->rightChild ? PGRedBlackTreeNodeTraverseSubnodesWithBlock(self->rightChild, block) : NO;
}
