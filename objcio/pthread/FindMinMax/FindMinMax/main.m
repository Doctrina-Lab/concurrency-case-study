//
//  main.m
//  FindMinMax
//
//  Created by Volodymyr Myroniuk on 27.01.2024.
//

#import <Foundation/Foundation.h>

#import <pthread.h>
#import <stdlib.h>
#import <stdio.h>

typedef struct ThreadInfo {
    uint32_t* numbers;
    size_t count;
} ThreadInfo;

typedef struct ThreadResult {
    uint32_t min;
    uint32_t max;
} ThreadResult;

void* findMinAndMax(void* arg) {
    const ThreadInfo* const info = (ThreadInfo*)arg;

    uint32_t min = UINT32_MAX;
    uint32_t max = 0;

    for (size_t i = 0; i < info->count; ++i) {
        min = info->numbers[i] < min ? info->numbers[i] : min;
        max = info->numbers[i] > max ? info->numbers[i] : max;
    }
    free(arg);

    ThreadResult* result = (ThreadResult*)malloc(sizeof(ThreadResult));
    result->min = min;
    result->max = max;

    return result;
}

int main(int argc, const char** argv) {
    const size_t numbersCount = 1000000;
    uint32_t numbers[numbersCount];

    uint32_t expectedMin = UINT32_MAX;
    uint32_t expectedMax = 0;

    for (size_t i = 0; i < numbersCount; ++i) {
        const uint32_t number = arc4random();
        expectedMin = MIN(number, expectedMin);
        expectedMax = MAX(number, expectedMax);
        numbers[i] = number;
    }

    size_t threadsCount = 4;
    pthread_t threads[threadsCount];

    for (size_t i = 0; i < threadsCount; ++i) {
        ThreadInfo* const info = (ThreadInfo*)malloc(sizeof(ThreadInfo));
        size_t offset = (numbersCount / threadsCount) * i;
        info->numbers = &numbers[offset];
        info->count = numbersCount / threadsCount;
        int status = pthread_create(&threads[i], NULL, findMinAndMax, info);
        NSCAssert(status == 0, @"pthread_create() failed: %d", status);
    }

    uint32_t foundMin = UINT32_MAX;
    uint32_t foundMax = 0;

    for (size_t i = 0; i < threadsCount; ++i) {
        void* threadResult;
        int status = pthread_join(threads[i], &threadResult);
        NSCAssert(status == 0, @"pthread_join() failed: %d", status);
        
        ThreadResult* result = (ThreadResult*)threadResult;
        foundMin = MIN(result->min, foundMin);
        foundMax = MAX(result->max, foundMax);
        free(result);
    }

    printf("expectedMin = %ul, foundMin = %ul\n", expectedMin, foundMin);
    printf("expectedMax = %ul, foundMax = %ul\n", expectedMax, foundMax);

    return 0;
}
