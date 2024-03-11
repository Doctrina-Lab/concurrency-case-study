//
//  main.m
//  FindMinMax
//
//  Created by Volodymyr Myroniuk on 03.02.2024.
//

#import <Foundation/Foundation.h>
#import "FindMinMaxThread.h"

int main(int argc, const char** argv) {
    @autoreleasepool {
        const NSUInteger numbersCount = 1000000;
        NSMutableArray* numbers = [[NSMutableArray alloc] initWithCapacity:numbersCount];
        NSUInteger expectedMin = NSUIntegerMax;
        NSUInteger expectedMax = 0;
        for (NSUInteger i = 0; i < numbersCount; ++i) {
            const uint32_t number = arc4random();
            expectedMin = number < expectedMin ? number : expectedMin;
            expectedMax = number > expectedMax ? number : expectedMax;
            [numbers addObject:[NSNumber numberWithUnsignedInt:number]];
        }
        NSLog(@"expected min: %lu", expectedMin);
        NSLog(@"expected max: %lu", expectedMax);
        
        NSMutableSet* threads = [[NSMutableSet alloc] init];
        const NSUInteger threadsCount = 4;
        for (NSUInteger i = 0; i < threadsCount; ++i) {
            const NSUInteger subarrayCount = numbers.count / threadsCount;
            const NSUInteger offset = subarrayCount * i;
            const NSRange range = NSMakeRange(offset, subarrayCount);
            NSThread* thread = [[FindMinMaxThread alloc] initWithNumbers:[numbers subarrayWithRange:range]];
            [threads addObject:thread];
            [thread start];
        }

        NSUInteger min = NSUIntegerMax;
        NSUInteger max = 0;
        while (threads.count != 0) {
            for (FindMinMaxThread* thread in threads) {
                if (thread.isFinished) {
                    min = thread.min < min ? thread.min : min;
                    max = thread.max > max ? thread.max : max;
                    [threads removeObject:thread];
                    break;
                }
            }
        }

        NSLog(@"min: %lu", min);
        NSLog(@"max: %lu", max);
    }
    return 0;
}
