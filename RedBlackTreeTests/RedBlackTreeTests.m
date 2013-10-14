//
//  RedBlackTreeTests.m
//  RedBlackTreeTests
//
//  Created by Prachi Gauriar on 2/14/2013.
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

#import "RedBlackTreeTests.h"
#import "PGRedBlackTreeNode.h"

static const NSUInteger PGLargeTreeSize = 10000;

@interface PGRedBlackTree (PropertyVerification)
- (BOOL)fulfillsProperties;
@end


@implementation RedBlackTreeTests

- (void)testInit
{
    NSArray *array = @[ @"B", @"a", @"2", @"1", @"10"];
    NSArray *sortedArray = [array sortedArrayUsingSelector:@selector(compare:)];
    
    // -init and +tree
    PGRedBlackTree *tree = [[PGRedBlackTree alloc] init];
    XCTAssertEqual([tree count], 0lu, @"tree's initial count is not 0");
    [tree addObjectsFromArray:array];
    XCTAssertEqualObjects([tree allObjects], sortedArray, @"-init is not using compare: as its selector.");
    [tree release];

    tree = [PGRedBlackTree tree];
    XCTAssertEqual([tree count], 0lu, @"tree's initial count is not 0");
    [tree addObjectsFromArray:array];
    XCTAssertEqualObjects([tree allObjects], sortedArray, @"+tree is not using compare: as its selector.");
    
    // -initWithSelector: and +treeWithSelector:
    XCTAssertNil([[PGRedBlackTree alloc] initWithSelector:NULL], @"-initWithSelector: does not return nil when selector is NULL.");
    XCTAssertNil([PGRedBlackTree treeWithSelector:NULL], @"+treeWithSelector: does not return nil when selector is NULL.");
    
    sortedArray = [array sortedArrayUsingSelector:@selector(localizedCaseInsensitiveCompare:)];
    tree = [[PGRedBlackTree alloc] initWithSelector:@selector(localizedCaseInsensitiveCompare:)];
    XCTAssertEqual([tree count], 0lu, @"tree's initial count is not 0");
    [tree addObjectsFromArray:array];
    XCTAssertEqualObjects([tree allObjects], sortedArray, @"-initWithSelector is not using localizedCaseInsensitiveCompare: as its selector.");
    [tree release];

    tree = [PGRedBlackTree treeWithSelector:@selector(localizedCaseInsensitiveCompare:)];
    XCTAssertEqual([tree count], 0lu, @"tree's initial count is not 0");
    [tree addObjectsFromArray:array];
    XCTAssertEqualObjects([tree allObjects], sortedArray, @"+treeWithSelector: is not using localizedCaseInsensitiveCompare: as its selector.");

    // -initWithComparator: and +treeWithComparator:
    XCTAssertNil([[PGRedBlackTree alloc] initWithComparator:NULL], @"-initWithComparator: does not return nil when comparator is NULL.");
    XCTAssertNil([PGRedBlackTree treeWithComparator:NULL], @"+treeWithComparator: does not return nil when comparator is NULL.");
    
    NSComparator comparator = ^NSComparisonResult(id object1, id object2) { return -1 * [object1 compare:object2]; };
    sortedArray = [array sortedArrayUsingComparator:comparator];
    tree = [[PGRedBlackTree alloc] initWithComparator:comparator];
    XCTAssertEqual([tree count], 0lu, @"tree's initial count is not 0");
    [tree addObjectsFromArray:array];
    XCTAssertEqualObjects([tree allObjects], sortedArray, @"-initWithComparator: is not using the correct comparator.");
    [tree release];

    tree = [PGRedBlackTree treeWithComparator:comparator];
    XCTAssertEqual([tree count], 0lu, @"tree's initial count is not 0");
    [tree addObjectsFromArray:array];
    XCTAssertEqualObjects([tree allObjects], sortedArray, @"+treeWithComparator: is not using the correct comparator.");
}


- (void)testAdd
{
    // Basic additions and handling duplicates, etc.
    PGRedBlackTree *tree = [[PGRedBlackTree alloc] init];
    XCTAssertEqual([tree count], 0lu, @"tree's initial count is not 0");

    XCTAssertFalse([tree containsObject:@"b"], @"tree contains an object that has not yet been added.");
    [tree addObject:@"b"];
    XCTAssertTrue([tree containsObject:@"b"], @"tree does not contain the object just added.");
    XCTAssertEqual([tree count], 1lu, @"tree's count was not updated after adding an object.");
    XCTAssertTrue([tree fulfillsProperties], @"tree does not fulfill red-black properties after adding an object.");

    XCTAssertFalse([tree containsObject:@"a"], @"tree contains an object that has not yet been added.");
    [tree addObject:@"a"];
    XCTAssertTrue([tree containsObject:@"a"], @"tree does not contain the object just added.");
    XCTAssertEqual([tree count], 2lu, @"tree's count was not updated after adding an object.");
    XCTAssertTrue([tree fulfillsProperties], @"tree does not fulfill red-black properties after adding an object.");

    [tree addObject:@"a"];
    XCTAssertTrue([tree containsObject:@"a"], @"tree does not contain the object just added.");
    XCTAssertEqual([tree count], 3lu, @"tree's count was not updated after adding an object.");
    XCTAssertTrue([tree fulfillsProperties], @"tree does not fulfill red-black properties after adding an object.");

    XCTAssertFalse([tree containsObject:@"c"], @"tree contains an object that has not yet been added.");
    [tree addObject:@"c"];
    XCTAssertTrue([tree containsObject:@"c"], @"tree does not contain the object just added.");
    XCTAssertEqual([tree count], 4lu, @"tree's count was not updated after adding an object.");
    XCTAssertTrue([tree fulfillsProperties], @"tree does not fulfill red-black properties after adding an object.");
    
    NSArray *allObjects = @[@"a", @"a", @"b", @"c"];
    XCTAssertEqualObjects([tree allObjects], allObjects, @"tree did not add objects in the correct order.");
    [tree release];
    
    NSComparator comparator = ^NSComparisonResult(id object1, id object2) { return [object2 compare:object1]; };
    tree = [[PGRedBlackTree alloc] initWithComparator:comparator];
    [tree addObjectsFromArray:allObjects];
    XCTAssertEqual([tree count], [allObjects count], @"tree's count was not correctly set after adding objects from an array.");
    XCTAssertEqualObjects([tree allObjects], [allObjects sortedArrayUsingComparator:comparator], @"tree did not add objects in the correct order.");
    for (NSNumber *number in allObjects) {
        XCTAssertTrue([tree containsObject:number], @"tree does not contain the object just added.");
    }

    [tree release];
}


- (void)testAddWithManyObjects
{
    // Seed the random number generator and output the seed so we can later reproduce any errors
    srandomdev();
    unsigned seed = (unsigned)random();
    NSLog(@"Using seed %d", seed);
    srandom(seed);
    
    // Use a custom comparator (reverse order) for these tests
    NSComparator comparator = ^NSComparisonResult(id object1, id object2) { return [object2 compare:object1]; };
    PGRedBlackTree *tree = [[PGRedBlackTree alloc] initWithComparator:comparator];
    
    // Allocate a bunch of (potentially duplicated) random numbers
    NSMutableArray *randomNumbers = [[NSMutableArray alloc] initWithCapacity:PGLargeTreeSize];
    for (NSUInteger i = 0; i < PGLargeTreeSize; ++i) {
        [randomNumbers addObject:@(random())];
    }
    
    // Add each of the numbers one-by-one. Test count, membership, and property fulfillment
    for (NSNumber *number in randomNumbers) {
        NSUInteger oldCount = [tree count];
        [tree addObject:number];
        XCTAssertTrue([tree containsObject:number], @"tree does not contain the object just added.");
        XCTAssertEqual([tree count], oldCount + 1, @"tree's count was not updated after adding an object.");
        XCTAssertTrue([tree fulfillsProperties], @"tree does not fulfill red-black properties after adding an object.");
    }
    
    // Make sure the numbers were added in the right order
    NSArray *sortedNumbers = [randomNumbers sortedArrayUsingComparator:comparator];
    @autoreleasepool {
        XCTAssertEqualObjects([tree allObjects], sortedNumbers, @"tree did not add objects in the correct order.");
    }
    
    [tree release];
    
    // Repeat the tests with addObjectsFromArray: this time
    tree = [[PGRedBlackTree alloc] initWithComparator:comparator];
    [tree addObjectsFromArray:randomNumbers];
    XCTAssertEqual([tree count], [randomNumbers count], @"tree's count was not correctly set after adding objects from an array.");
    
    @autoreleasepool {
        XCTAssertEqualObjects([tree allObjects], sortedNumbers, @"tree did not add objects in the correct order.");
    }
    
    XCTAssertTrue([tree fulfillsProperties], @"tree does not fulfill red-black properties after adding objects from an array.");
    
    for (NSNumber *number in randomNumbers) {
        XCTAssertTrue([tree containsObject:number], @"tree does not contain the object just added.");
    }
    
    [tree release];
}


- (void)testRemove
{
    PGRedBlackTree *tree = [PGRedBlackTree tree];
    
    [tree removeObject:nil];
    XCTAssertEqual([tree count], 0ul, @"tree removed a nil object");
    XCTAssertEqualObjects([tree allObjects], @[], @"tree contents is not correct after removing a nil object.");
    
    [tree removeObject:@"a"];
    XCTAssertEqual([tree count], 0ul, @"tree removed an object that it did not have.");
    XCTAssertEqualObjects([tree allObjects], @[], @"tree contents is not correct after removing an object that it did not contain.");
 
    NSMutableArray *allObjects = [NSMutableArray arrayWithArray:@[@"a", @"b", @"b", @"b", @"c"]];
    [tree addObjectsFromArray:allObjects];

    [tree removeObject:@"b"];
    [allObjects removeObjectAtIndex:1];
    XCTAssertEqual([tree count], [allObjects count], @"tree does not have the correct count after removing an object with duplicates in the tree.");
    XCTAssertTrue([tree containsObject:@"b"], @"tree removed many objects at once");
    XCTAssertEqualObjects([tree allObjects], allObjects, @"tree is not in the correct order after removing an object with duplicates in the tree.");
    XCTAssertTrue([tree fulfillsProperties], @"tree does not fulfill red-black properties after removing an object.");

    [tree removeObject:@"b"];
    [allObjects removeObjectAtIndex:1];
    XCTAssertEqual([tree count], [allObjects count], @"tree does not have the correct count after removing an object with duplicates in the tree.");
    XCTAssertTrue([tree containsObject:@"b"], @"tree removed many objects at once");
    XCTAssertEqualObjects([tree allObjects], allObjects, @"tree is not in the correct order after removing an object with duplicates in the tree.");
    XCTAssertTrue([tree fulfillsProperties], @"tree does not fulfill red-black properties after removing an object.");

    [tree removeAllObjects];
    [allObjects removeAllObjects];
    XCTAssertEqual([tree count], [allObjects count], @"tree does not have the correct count after removing all objects.");
    XCTAssertEqualObjects([tree allObjects], allObjects, @"tree is not in the correct order after removing all objects.");
    XCTAssertTrue([tree fulfillsProperties], @"tree does not fulfill red-black properties after removing all objects.");
    
    XCTAssertFalse([tree containsObject:@"b"], @"tree contains an object that has not yet been added.");
    [tree addObject:@"b"];
    XCTAssertTrue([tree containsObject:@"b"], @"tree does not contain the object just added.");
    XCTAssertEqual([tree count], 1lu, @"tree's count was not updated after adding an object.");
    XCTAssertTrue([tree fulfillsProperties], @"tree does not fulfill red-black properties after adding an object.");
}


- (void)testRemoveWithManyObjects
{
    srandomdev();
    unsigned seed = (unsigned)random();
    NSLog(@"Using seed %d", seed);
    srandom(seed);
    
    NSComparator comparator = ^NSComparisonResult(id object1, id object2) { return [object2 compare:object1]; };
    PGRedBlackTree *tree = [[PGRedBlackTree alloc] initWithComparator:comparator];
    
    // Generate a large set of random numbers
    NSMutableSet *randomNumberSet = [[NSMutableSet alloc] initWithCapacity:PGLargeTreeSize];
    for (NSUInteger i = 0; i < PGLargeTreeSize; ++i) {
        NSNumber *number = nil;
        
        do {
            number = @(random());
        } while([randomNumberSet containsObject:number]);
        
        [randomNumberSet addObject:number];
    }
    
    NSArray *randomNumbers = [randomNumberSet allObjects];
    [randomNumberSet release];
    
    [tree addObjectsFromArray:randomNumbers];
    
    NSMutableArray *sortedRandomNumbers = [randomNumbers mutableCopy];
    [sortedRandomNumbers sortUsingComparator:comparator];
    for (NSUInteger i = PGLargeTreeSize; i > 0; --i) {
        NSNumber *number = randomNumbers[i - 1];
        
        [tree removeObject:number];
        [sortedRandomNumbers removeObjectAtIndex:[sortedRandomNumbers indexOfObject:number]];
        
        XCTAssertFalse([tree containsObject:number], @"tree did not remove the object specified.");
        XCTAssertEqual([tree count], i - 1, @"tree's count was not correctly set after removing an object.");
        
        BOOL fulfillsProperties = [tree fulfillsProperties];
        XCTAssertTrue(fulfillsProperties, @"tree does not fulfill red-black properties after removing an object.");
        
        @autoreleasepool {
            XCTAssertEqualObjects([tree allObjects], sortedRandomNumbers, @"tree's objects are out of order after removal.");
        }
    }
}

@end

