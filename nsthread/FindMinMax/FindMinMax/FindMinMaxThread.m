//
//  FindMinMaxThread.m
//  FindMinMax
//
//  Created by Volodymyr Myroniuk on 05.02.2024.
//

#import "FindMinMaxThread.h"

@interface FindMinMaxThread ()
@property (nonatomic, readwrite) NSUInteger min;
@property (nonatomic, readwrite) NSUInteger max;
@end

@implementation FindMinMaxThread {
    NSArray* _numbers;
}

- (nonnull instancetype)initWithNumbers:(nonnull NSArray *)numbers {
    self = [super init];
    if (self) {
        _numbers = numbers;
        _min = NSUIntegerMax;
        _max = 0;
    }
    return self;
}

- (void)main {
    for (NSNumber* number in _numbers) {
        NSUInteger integer = [number unsignedIntegerValue];
        self.min = integer < _min ? integer : _min;
        self.max = integer > _max ? integer : _max;
    }
}

@end
