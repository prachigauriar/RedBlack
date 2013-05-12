//
//  PGRedBlackTreeNode.h
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

#ifndef PGREDBLACKTREENODE_H
#define PGREDBLACKTREENODE_H

#import <Foundation/Foundation.h>

@class PGRedBlackTree;


#pragma mark - Types and constants

typedef struct _PGRedBlackTreeNode PGRedBlackTreeNode;
struct _PGRedBlackTreeNode {
    PGRedBlackTreeNode *parent;
    PGRedBlackTreeNode *leftChild;
    PGRedBlackTreeNode *rightChild;
    BOOL isRed;
    id object;
};

extern PGRedBlackTreeNode const * const PGRedBlackTreeNodeSentinel;


#pragma mark - Creation and Deletion

extern PGRedBlackTreeNode *PGRedBlackTreeNodeCreate(PGRedBlackTreeNode *parent, id object);
extern void PGRedBlackTreeNodeFree(PGRedBlackTreeNode *self, BOOL freeChildren);


#pragma mark - Object accessors

NS_INLINE id PGRedBlackTreeNodeGetObject(PGRedBlackTreeNode *node)
{
    return [[node->object retain] autorelease];
}


NS_INLINE void PGRedBlackTreeNodeSetObject(PGRedBlackTreeNode *node, id object)
{
    if (node->object != object) {
        [node->object release];
        node->object = [object retain];
    }
}


#pragma mark - Descriptions

extern NSString *PGRedBlackTreeNodeAppendDebugDescription(PGRedBlackTreeNode *node, NSMutableString *description, NSUInteger indentDepth);


#pragma mark - Tests

NS_INLINE BOOL PGRedBlackTreeNodeIsSentinel(PGRedBlackTreeNode *node)
{
    return node == PGRedBlackTreeNodeSentinel;
}


NS_INLINE BOOL PGRedBlackTreeNodeIsLeftChild(PGRedBlackTreeNode *node)
{
    return node->parent && node == node->parent->leftChild;
}


NS_INLINE BOOL PGRedBlackTreeNodeIsRightChild(PGRedBlackTreeNode *node)
{
    return node->parent && node == node->parent->rightChild;
}


#pragma mark - Relationships

NS_INLINE PGRedBlackTreeNode *PGRedBlackTreeNodeGrandparent(PGRedBlackTreeNode *node)
{
    return node->parent ? node->parent->parent : NULL;
}


NS_INLINE PGRedBlackTreeNode *PGRedBlackTreeNodeUncle(PGRedBlackTreeNode *node)
{
    PGRedBlackTreeNode *grandparent = PGRedBlackTreeNodeGrandparent(node);
    if (!grandparent) return NULL;
    return PGRedBlackTreeNodeIsLeftChild(node->parent) ? grandparent->rightChild : grandparent->leftChild;
}


NS_INLINE PGRedBlackTreeNode *PGRedBlackTreeNodeSibling(PGRedBlackTreeNode *node)
{
    if (!node->parent) return NULL;
    return PGRedBlackTreeNodeIsLeftChild(node) ? node->parent->rightChild : node->parent->leftChild;
}

extern PGRedBlackTreeNode *PGRedBlackTreeNodePredecessor(PGRedBlackTreeNode *node);
extern PGRedBlackTreeNode *PGRedBlackTreeNodeSuccessor(PGRedBlackTreeNode *node);


#pragma mark - Rotation

extern void PGRedBlackTreeNodeRotateLeftInTree(PGRedBlackTreeNode *node, PGRedBlackTree *tree);
extern void PGRedBlackTreeNodeRotateRightInTree(PGRedBlackTreeNode *node, PGRedBlackTree *tree);


#pragma mark - Traversal

extern BOOL PGRedBlackTreeNodeTraverseSubnodesWithBlock(PGRedBlackTreeNode *node,
                                                        void (^block)(PGRedBlackTreeNode *n, BOOL *stop));
extern BOOL PGRedBlackTreeNodeTraverseSubnodesEqualToObject(PGRedBlackTreeNode *node,
                                                            id object, NSComparator cmp, void (^block)(PGRedBlackTreeNode *n, BOOL *stop));
extern BOOL PGRedBlackTreeNodeTraverseSubnodesGreaterThanOrEqualToObject(PGRedBlackTreeNode *node, id object,
                                                                         NSComparator cmp, void (^block)(PGRedBlackTreeNode *n, BOOL *stop));
extern BOOL PGRedBlackTreeNodeTraverseSubnodesGreaterThanObject(PGRedBlackTreeNode *node, id obj, NSComparator cmp,
                                                                void (^block)(PGRedBlackTreeNode *n, BOOL *stop));


#pragma mark - Test helpers

extern BOOL PGRedBlackTreeNodeFulfillsProperties(PGRedBlackTreeNode *node, NSComparator comparator, NSUInteger blackNodesOnPathToRoot);
extern NSUInteger PGRedBlackTreeNodeBlackNodeCountInPathFromNodeToRoot(PGRedBlackTreeNode *node);

#endif
