//
//  PGRedBlackTreeNode.h
//  RedBlack
//
//  Created by Prachi Gauriar on 2/13/2013.
//  Copyright (c) 2013 Prachi Gauriar. All rights reserved.
//

#ifndef PGREDBLACKTREENODE_H
#define PGREDBLACKTREENODE_H

#import <Foundation/Foundation.h>

@class PGRedBlackTree;

typedef struct _PGRedBlackTreeNode PGRedBlackTreeNode;
struct _PGRedBlackTreeNode {
    PGRedBlackTreeNode *parent;
    PGRedBlackTreeNode *leftChild;
    PGRedBlackTreeNode *rightChild;
    BOOL isRed;
    id object;
};

extern PGRedBlackTreeNode *PGRedBlackTreeNodeCreate(PGRedBlackTreeNode *parent, id object);
extern void PGRedBlackTreeNodeFree(PGRedBlackTreeNode *node);
extern NSString *PGRedBlackTreeNodeAppendDebugDescription(PGRedBlackTreeNode *node, NSMutableString *description, NSUInteger indentDepth);

extern PGRedBlackTreeNode *PGRedBlackTreeNodeInOrderPredecessor(PGRedBlackTreeNode *node);
extern PGRedBlackTreeNode *PGRedBlackTreeNodeInOrderSuccessor(PGRedBlackTreeNode *node);

extern void PGRedBlackTreeNodeRotateLeftInTree(PGRedBlackTreeNode *node, PGRedBlackTree *tree);
extern void PGRedBlackTreeNodeRotateRightInTree(PGRedBlackTreeNode *node, PGRedBlackTree *tree);
extern BOOL PGRedBlackTreeNodeTraverseSubnodesWithBlock(PGRedBlackTreeNode *node, void (^block)(id obj, BOOL *stop));
extern BOOL PGRedBlackTreeNodeTraverseSubnodesEqualToObject(PGRedBlackTreeNode *node, id object, NSComparator cmp, void (^block)(id obj, BOOL *stop));
extern BOOL PGRedBlackTreeNodeTraverseSubnodesGreaterThanOrEqualToObject(PGRedBlackTreeNode *node, id object, NSComparator cmp, void (^block)(id obj, BOOL *stop));
extern BOOL PGRedBlackTreeNodeTraverseSubnodesGreaterThanObject(PGRedBlackTreeNode *node, id obj, NSComparator cmp, void (^block)(id, BOOL *));


NS_INLINE BOOL PGRedBlackTreeNodeIsLeftChild(PGRedBlackTreeNode *node)
{
    return node->parent && node == node->parent->leftChild;
};


NS_INLINE BOOL PGRedBlackTreeNodeIsRightChild(PGRedBlackTreeNode *node)
{
    return node->parent && node == node->parent->rightChild;
};


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
    if (!node || !node->parent) return NULL;
    return PGRedBlackTreeNodeIsLeftChild(node) ? node->parent->rightChild : node->parent->leftChild;
}

#endif
