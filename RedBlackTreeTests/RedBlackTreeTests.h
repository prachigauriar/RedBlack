//
//  RedBlackTreeTests.h
//  RedBlackTreeTests
//
//  Created by Prachi Gauriar on 2/14/2013.
//  Copyright (c) 2013 Prachi Gauriar. All rights reserved.
//

#import <SenTestingKit/SenTestingKit.h>
#import "PGRedBlackTree.h"

@interface RedBlackTreeTests : SenTestCase


- (void)testInit;

- (void)testAdd;
- (void)testAddWithManyObjects;

- (void)testRemove;
- (void)testRemoveWithManyObjects;

@end
