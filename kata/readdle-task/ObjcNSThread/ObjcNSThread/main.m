//
//  main.m
//  ObjcNSThread
//
//  Created by Volodymyr Myroniuk on 12.03.2024.
//

#import <Foundation/Foundation.h>

int main(int argc, const char * argv[]) {
    @autoreleasepool {
        NSMutableArray* sharedData = [[NSMutableArray alloc] init];
        
        [NSThread detachNewThreadWithBlock:^{
            NSArray* symbols = @[@"A", @"B", @"C"];
            size_t index = 0;
            
            while (1) {
                NSString* symbol = symbols[index];
                index = (index + 1) % symbols.count;
                
                [sharedData addObject:symbol];
                printf("Thread 1 added symbol: %s\n", [symbol cStringUsingEncoding:NSUTF8StringEncoding]);
            }
        }];
    }

    [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode beforeDate:[NSDate distantFuture]];
    
    return 0;
}
