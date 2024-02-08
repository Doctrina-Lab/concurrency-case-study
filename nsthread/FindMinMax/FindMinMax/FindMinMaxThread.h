//
//  FindMinMaxThread.h
//  FindMinMax
//
//  Created by Volodymyr Myroniuk on 05.02.2024.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface FindMinMaxThread : NSThread

@property (nonatomic, readonly) NSUInteger min;
@property (nonatomic, readonly) NSUInteger max;

- (instancetype)initWithNumbers:(NSArray*)numbers;

@end

NS_ASSUME_NONNULL_END
