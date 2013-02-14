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


const PGRedBlackTreeNode _PGRedBlackTreeNodeSentinel = { NULL, NULL, NULL, NO, NULL };
PGRedBlackTreeNode const * const PGRedBlackTreeNodeSentinel = &_PGRedBlackTreeNodeSentinel;


PGRedBlackTreeNode *PGRedBlackTreeNodeCreate(PGRedBlackTreeNode *parent, id object)
{
    PGRedBlackTreeNode *self = calloc(1, sizeof(struct _PGRedBlackTreeNode));
    if (self) {
        self->parent = parent;
        self->leftChild = (PGRedBlackTreeNode *)PGRedBlackTreeNodeSentinel;
        self->rightChild = (PGRedBlackTreeNode *)PGRedBlackTreeNodeSentinel;
        self->object = [object retain];
        self->isRed = YES;
    }
    
    return self;
}


void PGRedBlackTreeNodeFree(PGRedBlackTreeNode *self)
{
    [self->object release];
    if (!PGRedBlackTreeNodeIsSentinel(self->leftChild)) PGRedBlackTreeNodeFree(self->leftChild);

    // All this saving the right child business is to enable tail recursion
    PGRedBlackTreeNode *rightChild = self->rightChild;
    free(self);
    if (!PGRedBlackTreeNodeIsSentinel(rightChild)) PGRedBlackTreeNodeFree(rightChild);
}


void PGRedBlackTreeNodeFreeAndUpdateParent(PGRedBlackTreeNode *self)
{
    if (self->parent) {
        if (PGRedBlackTreeNodeIsLeftChild(self)) {
            self->parent->leftChild = (PGRedBlackTreeNode *)PGRedBlackTreeNodeSentinel;
        } else {
            self->parent->rightChild = (PGRedBlackTreeNode *)PGRedBlackTreeNodeSentinel;
        }
    }
    
    PGRedBlackTreeNodeFree(self);
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
    if (!PGRedBlackTreeNodeIsSentinel(self->leftChild)) {
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
    if (!PGRedBlackTreeNodeIsSentinel(self->rightChild)) {
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


PGRedBlackTreeNode *PGRedBlackTreeNodePredecessor(PGRedBlackTreeNode *self)
{
    if (PGRedBlackTreeNodeIsSentinel(self->leftChild)) return NULL;
    
    PGRedBlackTreeNode *node = self->leftChild;
    while (!PGRedBlackTreeNodeIsSentinel(node->rightChild)) {
        node = node->rightChild;
    }
    
    return node;
}


PGRedBlackTreeNode *PGRedBlackTreeNodeSuccessor(PGRedBlackTreeNode *self)
{
    if (PGRedBlackTreeNodeIsSentinel(self->rightChild)) return NULL;
    
    PGRedBlackTreeNode *node = self->rightChild;
    while (PGRedBlackTreeNodeIsSentinel(node->leftChild)) {
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
    if (!PGRedBlackTreeNodeIsSentinel(self->rightChild)) {
        self->rightChild->parent = self;
    }

    // Set other's parent to our parent
    if (!PGRedBlackTreeNodeIsSentinel(other)) {
        other->parent = self->parent;
    }

    // If we were the root of the tree, make other the root of the tree. Otherwise, if we were the right child, make other
    // the right child. If we were the left child, make it the left
    if (!self->parent) {
        [tree setRoot:other];
    } else if (PGRedBlackTreeNodeIsLeftChild(self)) {
        self->parent->leftChild = other;
    } else {
        self->parent->rightChild = other;
    }

    // Finally, set ourself as other's right child and it as our parent
    other->leftChild = self;
    if (!PGRedBlackTreeNodeIsSentinel(self)) {
        self->parent = other;
    }
}


void PGRedBlackTreeNodeRotateRightInTree(PGRedBlackTreeNode *self, PGRedBlackTree *tree)
{
    // Other starts off as our left child. We will end up as its right child, and its right child will become our left one
    PGRedBlackTreeNode *other = self->leftChild;

    // Set other's right child as our left and set ourself as its parent
    self->leftChild = other->rightChild;
    if (!PGRedBlackTreeNodeIsSentinel(self->leftChild)) {
        self->leftChild->parent = self;
    }

    // Set other's parent to our parent
    if (!PGRedBlackTreeNodeIsSentinel(other)) {
        other->parent = self->parent;
    }

    // If we were the root of the tree, make other the root of the tree. Otherwise, if we were the right child, make other
    // the right child. If we were the left child, make it the left
    if (!self->parent) {
        [tree setRoot:other];
    } else if (PGRedBlackTreeNodeIsLeftChild(self)) {
        self->parent->leftChild = other;
    } else {
        self->parent->rightChild = other;
    }

    // Finally, set ourself as other's right child and it as our parent
    other->rightChild = self;
    if (!PGRedBlackTreeNodeIsSentinel(self)) {
        self->parent = other;
    }
}


BOOL PGRedBlackTreeNodeTraverseSubnodesWithBlock(PGRedBlackTreeNode *self, void (^block)(id, BOOL *))
{
    if (PGRedBlackTreeNodeIsSentinel(self)) return NO;
    
    PGRedBlackTreeNode *node = self;
    BOOL stop = NO;

    // Go as far left as we can. This loop only goes down the tree.
    while (!PGRedBlackTreeNodeIsSentinel(node->leftChild)) {
        node = node->leftChild;
    }

    // Keep traversing as long as we haven't backed up past the root of this subtree, i.e., self. This loop only goes up the tree.
    while (node && node != self->parent) {
        // Execute the block on the node's object. If the block told us to stop traversing, stop.
        block(node->object, &stop);
        if (stop) return YES;

        // If the current node has a right child, go right one and then go left as far as we can before continuing.
        if (!PGRedBlackTreeNodeIsSentinel(node->rightChild)) {
            node = node->rightChild;

            // This loop only goes down the tree.
            while (!PGRedBlackTreeNodeIsSentinel(node->leftChild)) {
                node = node->leftChild;
            }

            continue;
        }

        // Otherwise, keep going back up until we either hit the root (self) or we're no longer the right child. This loop only goes up.
        while (node != self && PGRedBlackTreeNodeIsRightChild(node)) {
            node = node->parent;
        }

        node = node->parent;
    }

    return NO;
}


BOOL PGRedBlackTreeNodeTraverseSubnodesEqualToObject(PGRedBlackTreeNode *self, id object, NSComparator comparator, void (^block)(id, BOOL *))
{
    if (PGRedBlackTreeNodeIsSentinel(self)) return NO;
    
    BOOL stop = NO;
    NSComparisonResult result = comparator(self->object, object);

    // self->object < object, so we only need to check the right subtree
    if (result < NSOrderedSame) {
        return PGRedBlackTreeNodeTraverseSubnodesEqualToObject(self->rightChild, object, comparator, block);
    }
    
    // self->object == object, so we have to check both directions
    if (result == NSOrderedSame) {
        if (!PGRedBlackTreeNodeIsSentinel(self->leftChild)) {
            stop = PGRedBlackTreeNodeTraverseSubnodesEqualToObject(self->leftChild, object, comparator, block);
            if (stop) return YES;
        }

        block(self->object, &stop);
        if (stop) return YES;

        return PGRedBlackTreeNodeTraverseSubnodesEqualToObject(self->rightChild, object, comparator, block);
    }
    
    // self->object > object, so we only need to consider the left subtree
    return PGRedBlackTreeNodeTraverseSubnodesEqualToObject(self->leftChild, object, comparator, block);
}


BOOL PGRedBlackTreeNodeTraverseSubnodesGreaterThanOrEqualToObject(PGRedBlackTreeNode *self, id object, NSComparator comparator, void (^block)(id, BOOL *))
{
    if (PGRedBlackTreeNodeIsSentinel(self)) return NO;

    BOOL stop = NO;
    NSComparisonResult result = comparator(self->object, object);

    // self->object < object, so we only need to check the right subtree
    if (result < NSOrderedSame) {
        return PGRedBlackTreeNodeTraverseSubnodesGreaterThanOrEqualToObject(self->rightChild, object, comparator, block);
    }
    
    // self->object == object, so we have to check both directions
    if (result == NSOrderedSame) {
        if (!PGRedBlackTreeNodeIsSentinel(self->leftChild)) {
            stop = PGRedBlackTreeNodeTraverseSubnodesGreaterThanOrEqualToObject(self->leftChild, object, comparator, block);
            if (stop) return YES;
        }

        block(self->object, &stop);
        if (stop) return YES;

        return PGRedBlackTreeNodeTraverseSubnodesGreaterThanOrEqualToObject(self->rightChild, object, comparator, block);
    }
    
    // self->object > object, so we need to check the left subtree, but we and our right subtree need to be traversed no matter what
    if (!PGRedBlackTreeNodeIsSentinel(self->leftChild)) {
        stop = PGRedBlackTreeNodeTraverseSubnodesGreaterThanOrEqualToObject(self->leftChild, object, comparator, block);
        if (stop) return YES;
    }
    
    block(self->object, &stop);
    if (stop) return YES;
    
    return !PGRedBlackTreeNodeIsSentinel(self->rightChild) ? PGRedBlackTreeNodeTraverseSubnodesWithBlock(self->rightChild, block) : NO;
}


BOOL PGRedBlackTreeNodeTraverseSubnodesGreaterThanObject(PGRedBlackTreeNode *self, id object, NSComparator comparator, void (^block)(id, BOOL *))
{
    if (PGRedBlackTreeNodeIsSentinel(self)) return NO;

    BOOL stop = NO;
    NSComparisonResult result = comparator(self->object, object);
    if (result <= NSOrderedSame) {
        // self->object < object, so we only need to check the right subtree
        return PGRedBlackTreeNodeTraverseSubnodesGreaterThanObject(self->rightChild, object, comparator, block);
    }
    
    
    // self.object > object, so we need to check the left subtree, but we and our right subtree need to be traversed no matter what
    if (!PGRedBlackTreeNodeIsSentinel(self->leftChild)) {
        stop = PGRedBlackTreeNodeTraverseSubnodesGreaterThanObject(self->leftChild, object, comparator, block);
        if (stop) return YES;
    }
    
    block(self->object, &stop);
    if (stop) return YES;
    
    return !PGRedBlackTreeNodeIsSentinel(self->rightChild) ? PGRedBlackTreeNodeTraverseSubnodesWithBlock(self->rightChild, block) : NO;
}
