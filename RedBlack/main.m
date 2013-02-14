//
//  main.m
//  RedBlack
//
//  Created by Prachi Gauriar on 2/10/2013.
//  Copyright (c) 2013 Prachi Gauriar. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PGRedBlackTree.h"

int main(int argc, const char * argv[])
{
    @autoreleasepool {
        // Add objects
        PGRedBlackTree *tree = [PGRedBlackTree treeWithSelector:@selector(compare:)];
 
        NSDate *date = [NSDate date];
        printf("[tree contains:@10321.2] == %d, time: %fs\n", [tree containsObject:@10321.2], -[date timeIntervalSinceNow]);
 //        for (NSUInteger i = 1 ; i <= 6; ++i) {
//            [tree addObject:@(i)];
//        }
//        
//        printf("Before Removal\n%s\n", [[tree debugDescription] UTF8String]);
//        [tree removeObject:@2];
//        printf("After Removal\n%s\n", [[tree debugDescription] UTF8String]);

//        exit(1);

        date = [NSDate date];
        for (NSUInteger i = 100000; i != 0 ; --i) {
            for (NSUInteger j = 0; j < 5; ++j) {
                [tree addObject:@(i + 0.2 * j)];
            }
        }
        
        printf("Built a tree with %lu items; time: %fs\n", [tree count], -[date timeIntervalSinceNow]);

        date = [NSDate date];
        printf("[tree contains:@10321.2] == %d, time: %fs\n", [tree containsObject:@10321.2], -[date timeIntervalSinceNow]);

        printf("[tree contains:@99239.1] == %d, time: %fs\n", [tree containsObject:@99239.1], -[date timeIntervalSinceNow]);

        printf("First object: %s\n", [[[tree firstObject] description] UTF8String]);
        printf("Last object: %s\n", [[[tree lastObject] description] UTF8String]);
        
        // Looping tests
        date = [NSDate date];
        __block NSUInteger i = 0;
        [tree enumerateObjectsUsingBlock:^(id object, BOOL *stop) {
            NSComparisonResult result = [object compare:@50000];
            if (result > NSOrderedSame) {
                i += [object unsignedIntegerValue];
            }
        }];
        
        printf("Naive greater than loop resulted in i = %lu, time: %fs\n", i, -[date timeIntervalSinceNow]);
        
        date = [NSDate date];
        i = 0;
        [tree enumerateObjectsGreaterThanObject:@50000 usingBlock:^(id object, BOOL *stop) {
            i += [object unsignedIntegerValue];
        }];

        printf("-enumerateObjectsGreaterThanObject: resulted in i = %lu, time: %fs\n\n", i, -[date timeIntervalSinceNow]);
    }
    
    return 0;
}

