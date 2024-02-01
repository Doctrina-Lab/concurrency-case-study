//
//  main.m
//  FindMinMax
//
//  Created by Volodymyr Myroniuk on 27.01.2024.
//

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
        expectedMin = number < expectedMin ? number : expectedMin;
        expectedMax = number > expectedMax ? number : expectedMax;
        numbers[i] = number;
    }

    size_t threadsCount = 4;
    pthread_t threads[threadsCount];
    size_t offset = 0;

    for (size_t i = 0; i < threadsCount; ++i) {
        ThreadInfo* info = (ThreadInfo*)malloc(sizeof(ThreadInfo));
        info->numbers = &numbers[offset];
        info->count = numbersCount / threadsCount;
        offset += numbersCount / threadsCount;
        int status = pthread_create(&threads[i], NULL, findMinAndMax, info);
        if (status != 0) {
            printf("error: create thread\n");
            free(info);
        }
    }

    uint32_t foundMin = UINT32_MAX;
    uint32_t foundMax = 0;

    for (size_t i = 0; i < threadsCount; ++i) {
        void* threadResult;
        int status = pthread_join(threads[i], &threadResult);
        if (status == 0) {
            ThreadResult* result = (ThreadResult*)threadResult;
            foundMin = result->min < foundMin ? result->min : foundMin;
            foundMax = result->max > foundMax ? result->max : foundMax;
            free(result);
        } else {
            printf("error: join thread\n");
        }
    }

    printf("expectedMin = %d, foundMin = %d\n", expectedMin, foundMin);
    printf("expectedMax = %d, foundMax = %d\n", expectedMax, foundMax);

    return 0;
}
