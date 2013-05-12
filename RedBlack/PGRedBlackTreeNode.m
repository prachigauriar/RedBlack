//
//  PGRedBlackTreeNode.m
//  RedBlack
//
//  Created by Prachi Gauriar on 2/13/2013.
//  Copyright (c) 2013 Prachi Gauriar.
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy
//  of this software and associated documentation files (the "Software"), to deal
//  in the Software without restriction, including without limitation the rights
//  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//  copies of the Software, and to permit persons to whom the Software is
//  furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in
//  all copies or substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
//  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//  THE SOFTWARE.
//

#import "PGRedBlackTreeNode.h"
#import "PGRedBlackTree.h"


#pragma mark Private interfaces for PGRedBlackTree

@interface PGRedBlackTree (PrivateAccessors)
- (void)setRoot:(PGRedBlackTreeNode *)root;
@end


#pragma mark - Constants

const PGRedBlackTreeNode _PGRedBlackTreeNodeSentinel = { NULL, NULL, NULL, NO, NULL };
PGRedBlackTreeNode const * const PGRedBlackTreeNodeSentinel = &_PGRedBlackTreeNodeSentinel;


#pragma mark - Creation and deletion

PGRedBlackTreeNode *PGRedBlackTreeNodeCreate(PGRedBlackTreeNode *parent, id object)
{
    NSCAssert(!PGRedBlackTreeNodeIsSentinel(parent), @"parent is a sentinel");

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


void PGRedBlackTreeNodeFree(PGRedBlackTreeNode *self, BOOL freeChildren)
{
    NSCAssert(self, @"self is NULL");
    NSCAssert(!PGRedBlackTreeNodeIsSentinel(self), @"self is a sentinel");

    [self->object release];
    if (freeChildren) {
        if (!PGRedBlackTreeNodeIsSentinel(self->leftChild)) PGRedBlackTreeNodeFree(self->leftChild, YES);
        PGRedBlackTreeNode *rightChild = self->rightChild;
        free(self);
        if (!PGRedBlackTreeNodeIsSentinel(rightChild)) PGRedBlackTreeNodeFree(rightChild, YES);
    }
}


#pragma mark - Descriptions

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
    NSCAssert(self, @"self is NULL");
    NSCAssert(!PGRedBlackTreeNodeIsSentinel(self), @"self is a sentinel");
    
    NSString *indentString = PGRedBlackTreeNodeIndentString(indentDepth);
    NSString *indentPlus1String = PGRedBlackTreeNodeIndentString(indentDepth + 1);
    
    [description appendString:indentString];
    [description appendFormat:@"<node color=\"%@\">\n", self->isRed ? @"red" : @"black"];

    [description appendString:indentPlus1String];

    if (!PGRedBlackTreeNodeIsSentinel(self->leftChild)) {
        [description appendString:@"<left>\n"];
        PGRedBlackTreeNodeAppendDebugDescription(self->leftChild, description, indentDepth + 2);
        [description appendString:indentPlus1String];
        [description appendString:@"</left>\n"];
    } else {
        [description appendString:@"<left><node color=\"black\" sentinel=\"true\" /></left>\n"];
    }


    [description appendString:indentPlus1String];
    [description appendString:@"<object>"];
    [description appendString:[self->object debugDescription]];
    [description appendString:@"</object>\n"];

    [description appendString:indentPlus1String];

    if (!PGRedBlackTreeNodeIsSentinel(self->rightChild)) {
        [description appendString:@"<right>\n"];
        PGRedBlackTreeNodeAppendDebugDescription(self->rightChild, description, indentDepth + 2);
        [description appendString:indentPlus1String];
        [description appendString:@"</right>\n"];
    } else {
        [description appendString:@"<right><node color=\"black\" sentinel=\"true\" /></right>\n"];
    }
    
    [description appendString:indentString];
    [description appendString:@"</node>\n"];
    
    return description;
}


#pragma mark - Relationships

PGRedBlackTreeNode *PGRedBlackTreeNodePredecessor(PGRedBlackTreeNode *node)
{
    NSCAssert(node, @"node is NULL");
    if (!PGRedBlackTreeNodeIsSentinel(node)) return NULL;
    
    // If the node doesn't have a left child, keep going up and to the right
    if (PGRedBlackTreeNodeIsSentinel(node->leftChild)) {
        while (node->parent && PGRedBlackTreeNodeIsLeftChild(node)) {
            node = node->parent;
        }
        
        return node->parent;
    }

    // Otherwise, keep going down and to the right
    node = node->leftChild;
    while (!PGRedBlackTreeNodeIsSentinel(node->rightChild)) {
        node = node->rightChild;
    }
    
    return node;
}


PGRedBlackTreeNode *PGRedBlackTreeNodeSuccessor(PGRedBlackTreeNode *node)
{
    NSCAssert(node, @"node is NULL");
    if (PGRedBlackTreeNodeIsSentinel(node)) return NULL;

    // If the node doesn't have a right child, keep going up and to the left
    if (PGRedBlackTreeNodeIsSentinel(node->rightChild)) {
        while (node->parent && PGRedBlackTreeNodeIsRightChild(node)) {
            node = node->parent;
        }
        
        return node->parent;
    }

    // Otherwise, keep going down and to the left
    node = node->rightChild;
    while (!PGRedBlackTreeNodeIsSentinel(node->leftChild)) {
        node = node->leftChild;
    }
    
    return node;
}


#pragma mark - Rotation

void PGRedBlackTreeNodeRotateLeftInTree(PGRedBlackTreeNode *self, PGRedBlackTree *tree)
{
    NSCAssert(self, @"self is NULL");
    NSCAssert(!PGRedBlackTreeNodeIsSentinel(self), @"self is a sentinel");

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
    NSCAssert(self, @"self is NULL");
    NSCAssert(!PGRedBlackTreeNodeIsSentinel(self), @"self is a sentinel");

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


#pragma mark - Traversal

BOOL PGRedBlackTreeNodeTraverseSubnodesWithBlock(PGRedBlackTreeNode *self, void (^block)(PGRedBlackTreeNode *, BOOL *))
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
        block(node, &stop);
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


BOOL PGRedBlackTreeNodeTraverseSubnodesEqualToObject(PGRedBlackTreeNode *self, id object, NSComparator comparator,
                                                     void (^block)(PGRedBlackTreeNode *, BOOL *))
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

        block(self, &stop);
        if (stop) return YES;

        return PGRedBlackTreeNodeTraverseSubnodesEqualToObject(self->rightChild, object, comparator, block);
    }
    
    // self->object > object, so we only need to consider the left subtree
    return PGRedBlackTreeNodeTraverseSubnodesEqualToObject(self->leftChild, object, comparator, block);
}


BOOL PGRedBlackTreeNodeTraverseSubnodesGreaterThanOrEqualToObject(PGRedBlackTreeNode *self, id object, NSComparator comparator,
                                                                  void (^block)(PGRedBlackTreeNode *, BOOL *))
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

        block(self, &stop);
        if (stop) return YES;

        return PGRedBlackTreeNodeTraverseSubnodesGreaterThanOrEqualToObject(self->rightChild, object, comparator, block);
    }
    
    // self->object > object, so we need to check the left subtree, but we and our right subtree need to be traversed no matter what
    if (!PGRedBlackTreeNodeIsSentinel(self->leftChild)) {
        stop = PGRedBlackTreeNodeTraverseSubnodesGreaterThanOrEqualToObject(self->leftChild, object, comparator, block);
        if (stop) return YES;
    }
    
    block(self, &stop);
    if (stop) return YES;
    
    return !PGRedBlackTreeNodeIsSentinel(self->rightChild) ? PGRedBlackTreeNodeTraverseSubnodesWithBlock(self->rightChild, block) : NO;
}


BOOL PGRedBlackTreeNodeTraverseSubnodesGreaterThanObject(PGRedBlackTreeNode *self, id object, NSComparator comparator,
                                                         void (^block)(PGRedBlackTreeNode *, BOOL *))
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
    
    block(self, &stop);
    if (stop) return YES;
    
    return !PGRedBlackTreeNodeIsSentinel(self->rightChild) ? PGRedBlackTreeNodeTraverseSubnodesWithBlock(self->rightChild, block) : NO;
}


#pragma mark - Test helpers

BOOL PGRedBlackTreeNodeFulfillsProperties(PGRedBlackTreeNode *node, NSComparator comparator, NSUInteger blackNodeCount)
{
    // Note: Most of the return statements in this code are on their own line to aid in debugging
    
    // If we're a sentinel node, we're at the end of the recursion, so just run these first
    if (PGRedBlackTreeNodeIsSentinel(node)) {
        // Property 3
        if (!node->isRed && !node->object) {
            return YES;
        } else {
            return NO;
        }
    }
    
    if (!node->object) {
        return NO;
    }
    
    // Check the left child
    if (!PGRedBlackTreeNodeFulfillsProperties(node->leftChild, comparator, blackNodeCount)) return NO;
    
    // Properties 2 and 4
    if (node->isRed && (!node->parent || node->leftChild->isRed || node->leftChild->isRed)) {
        return NO;
    }
    
    if (PGRedBlackTreeNodeIsSentinel(node->leftChild) && PGRedBlackTreeNodeIsSentinel(node->rightChild)) {
        // Property 5
        if (blackNodeCount != PGRedBlackTreeNodeBlackNodeCountInPathFromNodeToRoot(node)) {
            return NO;
        }
    } else {
        // Basic BST test
        if (!PGRedBlackTreeNodeIsSentinel(node->leftChild) && comparator(node->leftChild->object, node->object) > NSOrderedSame) {
            return NO;
        }
        
        if (!PGRedBlackTreeNodeIsSentinel(node->rightChild) && comparator(node->rightChild->object, node->object) < NSOrderedSame) {
            return NO;
        }
    }
    
    // Check the right child
    return PGRedBlackTreeNodeFulfillsProperties(node->rightChild, comparator, blackNodeCount);
}


NSUInteger PGRedBlackTreeNodeBlackNodeCountInPathFromNodeToRoot(PGRedBlackTreeNode *node)
{
    NSUInteger blackNodeCount = 0;
    while (node) {
        if (!node->isRed) ++blackNodeCount;
        node = node->parent;
    }
    
    return blackNodeCount;
}