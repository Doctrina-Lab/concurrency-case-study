//
//  main.swift
//  Thread
//
//  Created by Volodymyr Myroniuk on 08.03.2024.
//

import Foundation

var sharedData = [String]()

let addSemaphore = DispatchSemaphore(value: 1)
let readSemaphore = DispatchSemaphore(value: 0)
let removeSemaphore = DispatchSemaphore(value: 0)

let maxReaders = 5
var readersCounter = 0
let readersCounterLock = NSLock()

Thread.detachNewThread {
    let symbols = ["A", "B", "C"]
    var index = 0
    
    while true {
        let symbol = symbols[index]
        index = (index + 1) % symbols.count
        
        addSemaphore.wait()
        sharedData.append(symbol)
        print("Thread 1 added symbol: \(symbol)")
        (0..<maxReaders).forEach { _ in readSemaphore.signal() }
    }
}

for reader in 2...maxReaders + 1 {
    Thread.detachNewThread {
        while true {
            readSemaphore.wait()
            if let symbol = sharedData.first {
                print("Thread \(reader) read symbol: \(symbol)")
            }
            
            readersCounterLock.lock()
            readersCounter = (readersCounter + 1) % maxReaders
            if readersCounter ==  0 { removeSemaphore.signal() }
            readersCounterLock.unlock()
        }
    }
}

Thread.detachNewThread {
    while true {
        removeSemaphore.wait()
        if !sharedData.isEmpty {
            let symbol = sharedData.removeFirst()
            print("Thread \(maxReaders + 2) removed symbol: \(symbol)")
        }
        addSemaphore.signal()
    }
}

RunLoop.current.run(mode: .default, before: .distantFuture)
