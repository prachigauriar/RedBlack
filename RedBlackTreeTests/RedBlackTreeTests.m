//
//  RedBlackTreeTests.m
//  RedBlackTreeTests
//
//  Created by Prachi Gauriar on 2/14/2013.
//  Copyright (c) 2013 Prachi Gauriar. All rights reserved.
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
    STAssertEquals([tree count], 0lu, @"tree's initial count is not 0");
    [tree addObjectsFromArray:array];
    STAssertEqualObjects([tree allObjects], sortedArray, @"-init is not using compare: as its selector.");
    [tree release];

    tree = [PGRedBlackTree tree];
    STAssertEquals([tree count], 0lu, @"tree's initial count is not 0");
    [tree addObjectsFromArray:array];
    STAssertEqualObjects([tree allObjects], sortedArray, @"+tree is not using compare: as its selector.");
    
    // -initWithSelector: and +treeWithSelector:
    STAssertNil([[PGRedBlackTree alloc] initWithSelector:NULL], @"-initWithSelector: does not return nil when selector is NULL.");
    STAssertNil([PGRedBlackTree treeWithSelector:NULL], @"+treeWithSelector: does not return nil when selector is NULL.");
    
    sortedArray = [array sortedArrayUsingSelector:@selector(localizedCaseInsensitiveCompare:)];
    tree = [[PGRedBlackTree alloc] initWithSelector:@selector(localizedCaseInsensitiveCompare:)];
    STAssertEquals([tree count], 0lu, @"tree's initial count is not 0");
    [tree addObjectsFromArray:array];
    STAssertEqualObjects([tree allObjects], sortedArray, @"-initWithSelector is not using localizedCaseInsensitiveCompare: as its selector.");
    [tree release];

    tree = [PGRedBlackTree treeWithSelector:@selector(localizedCaseInsensitiveCompare:)];
    STAssertEquals([tree count], 0lu, @"tree's initial count is not 0");
    [tree addObjectsFromArray:array];
    STAssertEqualObjects([tree allObjects], sortedArray, @"+treeWithSelector: is not using localizedCaseInsensitiveCompare: as its selector.");

    // -initWithComparator: and +treeWithComparator:
    STAssertNil([[PGRedBlackTree alloc] initWithComparator:NULL], @"-initWithComparator: does not return nil when comparator is NULL.");
    STAssertNil([PGRedBlackTree treeWithComparator:NULL], @"+treeWithComparator: does not return nil when comparator is NULL.");
    
    NSComparator comparator = ^NSComparisonResult(id object1, id object2) { return -1 * [object1 compare:object2]; };
    sortedArray = [array sortedArrayUsingComparator:comparator];
    tree = [[PGRedBlackTree alloc] initWithComparator:comparator];
    STAssertEquals([tree count], 0lu, @"tree's initial count is not 0");
    [tree addObjectsFromArray:array];
    STAssertEqualObjects([tree allObjects], sortedArray, @"-initWithComparator: is not using the correct comparator.");
    [tree release];

    tree = [PGRedBlackTree treeWithComparator:comparator];
    STAssertEquals([tree count], 0lu, @"tree's initial count is not 0");
    [tree addObjectsFromArray:array];
    STAssertEqualObjects([tree allObjects], sortedArray, @"+treeWithComparator: is not using the correct comparator.");
}


- (void)testAdd
{
    // Basic additions and handling duplicates, etc.
    PGRedBlackTree *tree = [[PGRedBlackTree alloc] init];
    STAssertEquals([tree count], 0lu, @"tree's initial count is not 0");

    STAssertFalse([tree containsObject:@"b"], @"tree contains an object that has not yet been added.");
    [tree addObject:@"b"];
    STAssertTrue([tree containsObject:@"b"], @"tree does not contain the object just added.");
    STAssertEquals([tree count], 1lu, @"tree's count was not updated after adding an object.");
    STAssertTrue([tree fulfillsProperties], @"tree does not fulfill red-black properties after adding an object.");

    STAssertFalse([tree containsObject:@"a"], @"tree contains an object that has not yet been added.");
    [tree addObject:@"a"];
    STAssertTrue([tree containsObject:@"a"], @"tree does not contain the object just added.");
    STAssertEquals([tree count], 2lu, @"tree's count was not updated after adding an object.");
    STAssertTrue([tree fulfillsProperties], @"tree does not fulfill red-black properties after adding an object.");

    [tree addObject:@"a"];
    STAssertTrue([tree containsObject:@"a"], @"tree does not contain the object just added.");
    STAssertEquals([tree count], 3lu, @"tree's count was not updated after adding an object.");
    STAssertTrue([tree fulfillsProperties], @"tree does not fulfill red-black properties after adding an object.");

    STAssertFalse([tree containsObject:@"c"], @"tree contains an object that has not yet been added.");
    [tree addObject:@"c"];
    STAssertTrue([tree containsObject:@"c"], @"tree does not contain the object just added.");
    STAssertEquals([tree count], 4lu, @"tree's count was not updated after adding an object.");
    STAssertTrue([tree fulfillsProperties], @"tree does not fulfill red-black properties after adding an object.");
    
    NSArray *allObjects = @[@"a", @"a", @"b", @"c"];
    STAssertEqualObjects([tree allObjects], allObjects, @"tree did not add objects in the correct order.");
    [tree release];
    
    NSComparator comparator = ^NSComparisonResult(id object1, id object2) { return [object2 compare:object1]; };
    tree = [[PGRedBlackTree alloc] initWithComparator:comparator];
    [tree addObjectsFromArray:allObjects];
    STAssertEquals([tree count], [allObjects count], @"tree's count was not correctly set after adding objects from an array.");
    STAssertEqualObjects([tree allObjects], [allObjects sortedArrayUsingComparator:comparator], @"tree did not add objects in the correct order.");
    for (NSNumber *number in allObjects) {
        STAssertTrue([tree containsObject:number], @"tree does not contain the object just added.");
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
        STAssertTrue([tree containsObject:number], @"tree does not contain the object just added.");
        STAssertEquals([tree count], oldCount + 1, @"tree's count was not updated after adding an object.");
        STAssertTrue([tree fulfillsProperties], @"tree does not fulfill red-black properties after adding an object.");
    }
    
    // Make sure the numbers were added in the right order
    NSArray *sortedNumbers = [randomNumbers sortedArrayUsingComparator:comparator];
    @autoreleasepool {
        STAssertEqualObjects([tree allObjects], sortedNumbers, @"tree did not add objects in the correct order.");
    }
    
    [tree release];
    
    // Repeat the tests with addObjectsFromArray: this time
    tree = [[PGRedBlackTree alloc] initWithComparator:comparator];
    [tree addObjectsFromArray:randomNumbers];
    STAssertEquals([tree count], [randomNumbers count], @"tree's count was not correctly set after adding objects from an array.");
    
    @autoreleasepool {
        STAssertEqualObjects([tree allObjects], sortedNumbers, @"tree did not add objects in the correct order.");
    }
    
    STAssertTrue([tree fulfillsProperties], @"tree does not fulfill red-black properties after adding objects from an array.");
    
    for (NSNumber *number in randomNumbers) {
        STAssertTrue([tree containsObject:number], @"tree does not contain the object just added.");
    }
    
    [tree release];
}


- (void)testRemove
{
    PGRedBlackTree *tree = [PGRedBlackTree tree];
    
    [tree removeObject:nil];
    STAssertEquals([tree count], 0ul, @"tree removed a nil object");
    STAssertEqualObjects([tree allObjects], [NSArray array], @"tree contents is not correct after removing a nil object.");
    
    [tree removeObject:@"a"];
    STAssertEquals([tree count], 0ul, @"tree removed an object that it did not have.");
    STAssertEqualObjects([tree allObjects], [NSArray array], @"tree contents is not correct after removing an object that it did not contain.");
 
    NSMutableArray *allObjects = [NSMutableArray arrayWithArray:@[@"a", @"b", @"b", @"b", @"c"]];
    [tree addObjectsFromArray:allObjects];

    [tree removeObject:@"b"];
    [allObjects removeObjectAtIndex:1];
    STAssertEquals([tree count], [allObjects count], @"tree does not have the correct count after removing an object with duplicates in the tree.");
    STAssertTrue([tree containsObject:@"b"], @"tree removed many objects at once");
    STAssertEqualObjects([tree allObjects], allObjects, @"tree is not in the correct order after removing an object with duplicates in the tree.");
    STAssertTrue([tree fulfillsProperties], @"tree does not fulfill red-black properties after removing an object.");

    [tree removeObject:@"b"];
    [allObjects removeObjectAtIndex:1];
    STAssertEquals([tree count], [allObjects count], @"tree does not have the correct count after removing an object with duplicates in the tree.");
    STAssertTrue([tree containsObject:@"b"], @"tree removed many objects at once");
    STAssertEqualObjects([tree allObjects], allObjects, @"tree is not in the correct order after removing an object with duplicates in the tree.");
    STAssertTrue([tree fulfillsProperties], @"tree does not fulfill red-black properties after removing an object.");

    [tree removeAllObjects];
    [allObjects removeAllObjects];
    STAssertEquals([tree count], [allObjects count], @"tree does not have the correct count after removing all objects.");
    STAssertEqualObjects([tree allObjects], allObjects, @"tree is not in the correct order after removing all objects.");
    STAssertTrue([tree fulfillsProperties], @"tree does not fulfill red-black properties after removing all objects.");
    
    STAssertFalse([tree containsObject:@"b"], @"tree contains an object that has not yet been added.");
    [tree addObject:@"b"];
    STAssertTrue([tree containsObject:@"b"], @"tree does not contain the object just added.");
    STAssertEquals([tree count], 1lu, @"tree's count was not updated after adding an object.");
    STAssertTrue([tree fulfillsProperties], @"tree does not fulfill red-black properties after adding an object.");
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
        NSNumber *number = [randomNumbers objectAtIndex:i - 1];
        
        [tree removeObject:number];
        [sortedRandomNumbers removeObjectAtIndex:[sortedRandomNumbers indexOfObject:number]];
        
        STAssertFalse([tree containsObject:number], @"tree did not remove the object specified.");
        STAssertEquals([tree count], i - 1, @"tree's count was not correctly set after removing an object.");
        
        BOOL fulfillsProperties = [tree fulfillsProperties];
        STAssertTrue(fulfillsProperties, @"tree does not fulfill red-black properties after removing an object.");
        
        @autoreleasepool {
            STAssertEqualObjects([tree allObjects], sortedRandomNumbers, @"tree's objects are out of order after removal.");
        }
    }
}

@end

