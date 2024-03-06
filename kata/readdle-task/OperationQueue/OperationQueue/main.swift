//
//  main.swift
//  OperationQueue
//
//  Created by Volodymyr Myroniuk on 05.03.2024.
//

import Foundation

var sharedData = [String]()

let queue = OperationQueue()

let addSemaphore = DispatchSemaphore(value: 1)
let readSemaphore = DispatchSemaphore(value: 0)
let removeSemaphore = DispatchSemaphore(value: 0)

queue.addOperation {
    let symbols = ["A", "B", "C"]
    var index = 0
    
    while true {
        let symbol = symbols[index]
        index = (index + 1) % symbols.count
        
        addSemaphore.wait()
        
        sharedData.append(symbol)
        print("Thread 1 added symbol: \(symbol)")
        
        readSemaphore.signal()
        readSemaphore.signal()
    }
}

let maxReaders = 2
var readersCount = 0
let readerLock = NSLock()
for threadNumber in 2...maxReaders + 1 {
    queue.addOperation {
        while true {
            readSemaphore.wait()
            
            if let symbol = sharedData.first {
                print("Thread \(threadNumber) read symbol: \(symbol)")
            }
            
            readerLock.lock()
            readersCount += 1
            if (readersCount == maxReaders) {
                readersCount = 0
                removeSemaphore.signal()
            }
            readerLock.unlock()
        }
    }
}

queue.addOperation {
    while true {
        removeSemaphore.wait()
        
        if !sharedData.isEmpty {
            print("Thread 4 removed symbol: \(sharedData.removeFirst())")
        }
        
        addSemaphore.signal()
    }
}

RunLoop.current.run(mode: .default, before: .distantFuture)
