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
        PGRedBlackTree *tree = [[PGRedBlackTree alloc] initWithSelector:@selector(compare:)];
        for (NSUInteger i = 1; i <= 5; ++i) {
            for (NSUInteger j = 0; j < 5; ++j) {
                [tree addObject:@(i + 0.2 * j)];
            }
        }

//        for (NSUInteger i = 10000; i > 0; --i) {
//            [tree containsObject:@(i)];
//        }
        
//        NSLog(@"%lu", [tree count]);
//
//        NSLog(@"Contains 3? %d", [tree containsObject:@3]);
//        NSLog(@"Contains 37? %d", [tree containsObject:@37]);
//        NSLog(@"%@", [tree allObjects]);
        
//        NSArray *evenStrings = [tree objectsPassingTest:^BOOL(id object, BOOL *stop) {
//            return [object unsignedIntegerValue] % 2 == 1;
//        }];
//
//        NSLog(@"%@", evenStrings);
        
//        [tree enumerateObjectsUsingBlock:^(id object, BOOL *stop) {
//            NSLog(@"%@", object);
//            *stop = [object intValue] % 3 == 0;
//        }];


        for (id object in [tree objectsGreaterThanObject:@3.6]) {
            NSLog(@"%@", object);
        }
        
//        NSLog(@"%@", [tree firstObject]);
//        NSLog(@"%@", [tree lastObject]);
//        
//        NSLog(@"%@", [tree debugDescription]);
    }
    
    return 0;
}

